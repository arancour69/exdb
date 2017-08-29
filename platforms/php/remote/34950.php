source: http://www.securityfocus.com/bid/44605/info

PHP is prone to a vulnerability because it fails to sufficiently sanitize user-supplied input.

Exploiting this issue can allow attackers to provide unexpected input and possibly bypass input-validation protection mechanisms. This can aid in further attacks that may utilize crafted user-supplied input.

Versions prior to PHP 5.3.4 are vulnerable.

<?php
$ill=chr(0xf0).chr(0xc0).chr(0xc0).chr(0xa7);
$ill=addslashes($ill);
echo utf8_decode("$ill");
echo htmlspecialchars ($ill,ENT_QUOTES,"utf-8" );
?>