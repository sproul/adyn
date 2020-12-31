#!/usr/bin/perl --
use strict;
use diagnostics;
use CGI qw(:standard);

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
  -type=>'text/plain');

  print "hi\n";
}
Main();
