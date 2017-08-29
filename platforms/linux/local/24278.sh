source: http://www.securityfocus.com/bid/10717/info

IM-Switch Insecure Temporary File Handling Symbolic Link VulnerabilityIt is reported that im-switch is prone to a local insecure temporary file handling symbolic link vulnerability. This issue is due to a design error that allows the application to insecurely write to a temporary file that is created with a predictable file name.

The im-switch utility will write to this temporary file before verifying its existence; this would facilitate a symbolic link attack.

An attacker may exploit this issue to corrupt arbitrary files. This corruption may potentially result in the elevation of privileges, or in a system wide denial of service. 

$ bash -c 'i=1;while [ $i -lt 65536 ]; do ln -s /etc/IMPORTANT_FILE
/tmp/imswitcher$i; let "i++"; done' 