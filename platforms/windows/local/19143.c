/*
source: http://www.securityfocus.com/bid/180/info

Beginning April 1, 2001 and continuing through April 8, 2001, Windows applications will be offset by one hour - even though the system clock will show the proper time. This is due to the MSVCRT.DLL not correctly interpreting Daylight Savings time during any year in which April 1st falls on a Sunday. In these instances, the DLL is fooled into thinking that DST begins one week later on April 8th.

MSVCRT.DLL shipping with MS VC++ versions 4.1, 4.2, 5.0 and 6.0 are thought to be vulnerable. 
*/

//
// APRIL1.C -- Simple test program for the "April's Fools 2001" bug
//
// by Richard M. Smith (rms@pharlap.com)
// copyright (C) 1999
//

#include <stdio.h>
#include <time.h>
#include <string.h>

#define SECS_PER_HOUR (60 * 60)
#define SECS_PER_DAY (24 * SECS_PER_HOUR)
#define SECS_PER_YEAR (365 * SECS_PER_DAY)

#define START (3 * SECS_PER_DAY)
#define INCR (23 * SECS_PER_HOUR)
#define MAXTIMES ((0x80000000L - START) / INCR)

void print_time(time_t mytime);

char *month_tab[] =
{
"January",
"February",
"March",
"April",
"May",
"June",
"July",
"August",
"September",
"October",
"November",
"December"
};

char *dow_tab[] =
{
"Sunday",
"Monday",
"Tuesday",
"Wednesday",
"Thursday",
"Friday",
"Saturday"
};

int main()

{

print_time(0x3AC796D0); // Sunday, April 1, 2001
print_time(0x3ACF2B70); // Saturday, April 7, 2001
print_time(0x3AD06EE0); // Sunday, April 8, 2001
return 0;

}

//
// print_time -- print out a time_t value converted by localtime()
//

void print_time(time_t mytime)

{

char month[100];
char dow[100];
struct tm *tmp;

tmp = localtime(&mytime);
if(tmp == NULL)
{
printf("0x%08lX = Invalid time\n", mytime);
return;
}
if(tmp->tm_mon >= 0 && tmp->tm_mon <= 11)
strcpy(month, month_tab[tmp->tm_mon]);
else
sprintf(month, "BadMonth=%d", tmp->tm_mon);
if(tmp->tm_wday >= 0 && tmp->tm_wday <= 6)
strcpy(dow, dow_tab[tmp->tm_wday]);
else
sprintf(month, "BadDOW=%d", tmp->tm_wday);
printf("0x%08lX = %s, %s %d, %d -- %d:%02d:%02d %s -- DOY=%d\n",
mytime, dow, month, tmp->tm_mday, tmp->tm_year + 1900,
tmp->tm_hour, tmp->tm_min, tmp->tm_sec, _tzname[tmp->tm_isdst != 0],
tmp->tm_yday);
return;