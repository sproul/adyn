#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use IO::File;
use Ndmp;
use nutil;
use teacher_user;
use adyn_cgi_util;
use CGI qw(:standard);

my $__debugMode = 1;

sub Main
{
  my $query;
  if (-d "c:/")
  {
    $query = new CGI(\*STDIN);
  }
  else
  {
    $query = new CGI;
  }

  print $query->header(
  -status=>'200 OK',
  -expires=>'-1d',
  -type=>'text/html');
     
  $__debugMode            = adyn_cgi_util::param($query, "debugMode");
  my $userID              = adyn_cgi_util::param($query, "userID");
  my $data = adyn_cgi_util::param($query, "data");
  
  print "uID=" . nutil::ToString($userID) . ", data=" . nutil::ToString($data) . "\n" if $__debugMode;
  if (!defined $userID || !defined $data)
  {
    $__debugMode = 1;
    print "Configuration error\n";
    adyn_cgi_util::MailAdyn("config error: mail relay from $userID", $data);
  }
  else
  {
    adyn_cgi_util::MailAdyn("mail relay from $userID", $data);
  }
  if ($__debugMode)
  {
    print "userId=$userID\n";
    print "data=$data\n"; 
  } 
}

Main();

# test with: cd $HOME/Dropbox/adyn/cgi-bin;(echo userID=test; echo data=hi)|perl -w hi_nelson.cgi
