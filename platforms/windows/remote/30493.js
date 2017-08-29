source: http://www.securityfocus.com/bid/25301/info

Microsoft XML Core Services is prone to an integer-overflow vulnerability because the application fails to ensure that integer values are not overrun.

Attackers can exploit this issue by enticing unsuspecting users to view malicious web content. Specially crafted scripts could issue requests to MSXML that trigger memory corruption.

Successfully exploiting this issue allows remote attackers to corrupt heap memory and execute arbitrary code in the context of the affected application. Failed exploit attempts will result in a denial-of-service condition. 

//var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
//xmlDoc.loadXML("<dummy></dummy>");
//var txt = xmlDoc.createTextNode("huh");
//var out = txt.substringData(1,0x7fffffff);