source: http://www.securityfocus.com/bid/12903/info

ESMI PayPal Storefront is prone to an SQL injection vulnerability. This issue is due to a failure in the application to properly sanitize user-supplied input before using it in as SQL query.

Successful exploitation could result in a compromise of the application, disclosure or modification of data, or may permit an attacker to exploit vulnerabilities in the underlying database implementation. 

http://www.example.com/hv/ecdis/pages.php?idpages='SQLINJECTION