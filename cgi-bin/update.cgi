#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
# weightChangesString format: verb_eat_11/-1:verb_eat_1/2
use strict;
use diagnostics;
use IO::File;
use Ndmp;
use nutil;
use teacher_user;
use CGI qw(:standard);
use adyn_cgi_util;

my $__debugMode = 0;

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
  my $weightChangesString = adyn_cgi_util::param($query, "weightChanges");

  if (!defined $userID)
  { 
    $__debugMode = 1;
    print "Configuration error\n";
  }
  else
  { 
    my $user = new teacher_user($userID);
    if (defined $user)
    { 
      $user->ApplyDeltas($weightChangesString);
    }
    else
    {
      print "update.cgi: no user defined\n";
    } 
  }

  if ($__debugMode)
  {
    print "userId=" . nutil::ToString($userID) . "\n";
    print "weightChanges=$weightChangesString\n" if defined $weightChangesString;
  } 
}

Main();
