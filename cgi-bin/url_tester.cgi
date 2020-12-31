#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use IO::File;
use adyn_cgi_util;
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


  print $query->header(-status=>'200 OK', -expires=>'-1d', -type=>'text/plain');

  my $arg1 = adyn_cgi_util::param($query, "arg1");
  my $arg2 = adyn_cgi_util::param($query, "arg2");
  print $arg1 . "/" . $arg2;
}

Main();

# test with: cd $DROP/adyn/cgi-bin/; (echo arg1=1; echo arg2=2) | perl -w url_tester.cgi
