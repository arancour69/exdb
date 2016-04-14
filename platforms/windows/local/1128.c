/*
  Will be moved to tools section shortly /str0ke

  Name: Windows Genuine Advantage Validation Patch
  Copyright: NeoSecurityTeam
  Author: HaCkZaTaN <hck_zatan@hotmail.com>
  Date: 31/07/05 21:42
  Description: LegitCheckControl.dll (1.3.254.0) 
  
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³þþ                   -==[N]eo [S]ecurity [T]eam Inc.==-                   þþ³
 ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
 ³°³     TiTLE : Windows Genuine Advantage Validation                       ³°³  ³°ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´°³
 ³°³    AUTHOR : HaCkZaTaN                                                  ³°³  ÚÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄ¿
 ³þþ                           -==Information==-                            þþ³  ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
 ³°³                                                                        ³°³  ³°³ LegitCheckControl.dll (1.3.254.0)                                      ³°³  ³°³                                                                        ³°³
 ÚÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄ¿
 ³þþ                           -==Contact==-                                þþ³
 ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
 ³°³                                                                        ³°³
 ³°³   [N]eo [S]ecurity [T]eam [NST]® - http://www.neosecurityteam.net/     ³°³
 ³°³   HaCkZaTaN <hck_zatan@hotmail.com>                                    ³°³
 ³°³   Irc.GigaChat.Net #uruguay                                            ³°³
 ³°³                                                                        ³°³
 ÚÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄ¿
 ³þþ                              -==Greets==-                              þþ³
 ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
 ³°³                                                                        ³°³
 ³°³                            NST's Staff                                 ³°³
 ³°³                            erg0t                                       ³°³
 ³°³                            ][GB][                                      ³°³
 ³°³                            Beford                                      ³°³
 ³°³                            LINUX                                       ³°³
 ³°³                            Heap                                        ³°³
 ³°³                            CrashCool                                   ³°³
 ³°³                            Makoki                                      ³°³
 ³°³                            And my Colombian people                     ³°³
 ³°³                                                                        ³°³  ÚÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄ¿
 ³þþ                   -==[N]eo [S]ecurity [T]eam Inc.==-                   þþ³
 ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÙ
                          ÛÛÛÛ   ÛÛÛÛ ÛÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛÛÛÛ
                           ÛÛÛÛÛ  ÛÛ  ÛÛÛ       ÛÛ  ÛÛÛ  ÛÛ
                           ÛÛ ÛÛÛÛÛÛ  ÛÛÛÛÛÛÛÛÛ     ÛÛÛ
                           ÛÛ   ÛÛÛÛ        ÛÛÛ     ÛÛÛ
                          ÛÛÛÛ    ÛÛÛ ÛÛÛÛÛÛÛÛÛ    ÛÛÛÛÛ

*/

#include <stdio.h>

typedef struct bytepair BYTEPAIR;

struct bytepair
{
       long offset;
       char val;
}; 

static const BYTEPAIR byte_pairs[3]= { 
{0x2BE98, 0x33},
{0x2BE99, 0xC0},
{0x2BE9A, 0x90},
};

int main(int argc, char *argv[])
{
    FILE *LegitCheckControl;
    int i;

    printf("\n\t±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Ü\n"
           "\t±Ûßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß±Û\n"
           "\t±Û                                                         ±Û\n"
           "\t±Û           [N]eo [S]ecurity [T]eam [N][S][T]             ±Û\n"
           "\t±Û      [Windows Genuine Advantage Validation Patch]       ±Û\n"
           "\t±Û             LegitCheckControl.dll (1.3.254.0)           ±Û\n"
           "\t±Û                                                         ±Û\n"
           "\t±Û ÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛ   ÛÛÛÛ   ÛÛ ÛÛ ÛÛÛÛ  ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  ÛÛÛÛ  ÛÛ  ÛÛ   ÛÛÛ   ÛÛ ÛÛÛ  ÛÛÛ  ÛÛÛ ÛÛ ÛÛ ÛÛ ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  Û ÛÛÛ ÛÛ  ÛÛ   ÛÛÛ   ÛÛ      ÛÛÛ  ÛÛÛ    ÛÛ    ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  Û ÛÛÛ ÛÛ  ÛÛ   ÛÛÛ   ÛÛÛÛ    ÛÛÛ  ÛÛÛ    ÛÛ    ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  Û   ÛÛÛÛ  ÛÛ   ÛÛÛ    ÛÛÛÛÛ  ÛÛÛ  ÛÛÛ    ÛÛ    ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  Û    ÛÛÛ  ÛÛ   ÛÛÛ      ÛÛÛ  ÛÛÛ  ÛÛÛ    ÛÛ    ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ  Û    ÛÛÛ  ÛÛ   ÛÛÛ   ÛÛ ÛÛÛ  ÛÛÛ  ÛÛÛ    ÛÛ    ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ ÛÛÛ    ÛÛ  ÛÛ   ÛÛÛ   Û ÛÛ    ÛÛÛ  ÛÛÛ   ÛÛÛÛ   ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛ            ÛÛ   ÛÛÛ           ÛÛÛ  ÛÛÛ          ÛÛÛ ±Û\n"
           "\t±Û ÛÛÛÛ          ÛÛÛ   ÛÛÛÛ         ÛÛÛÛ  ÛÛÛÛ        ÛÛÛÛ ±Û\n"
           "\t±Û                                                         ±Û\n"
           "\t±Û                 [ HaCkZaTaN  ..... ]                    ±Û\n"
           "\t±Û                 [ Paisterist ..... ]                    ±Û\n"
           "\t±Û                 [ Daemon21   ..... ]                    ±Û\n"
           "\t±Û                 [ g30rg3_x   ..... ]                    ±Û\n"
           "\t±Û            [ Http://WwW.NeoSecurityTeam.Net ]           ±Û\n"
           "\t±Û                                                         ±Û\n"
           "\t±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Û\n"
           "\t ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß\n\n\n");
           
           getchar();
           LegitCheckControl = fopen("LegitCheckControl.dll", "r+");
           
           if (LegitCheckControl == (FILE *)0)
           {
                       printf("LegitCheckControl.dll not found. Aborting.\n\n");
                       printf("Hit <Enter> to quit.");
                       getchar();
                       return 1;
           }
           
           printf("Starting...\n");
           
           for (i = 0; i < 3; i++)
           {
               fseek(LegitCheckControl, byte_pairs[i].offset, SEEK_SET);
               fwrite(&byte_pairs[i].val, 1, 1, LegitCheckControl);
           }
           
           fclose(LegitCheckControl);
           printf("->Patch completed.\n\n");
           printf("Done, enjoy...\n\n");
           getchar();

           return 0;
}

// milw0rm.com [2005-08-01]
