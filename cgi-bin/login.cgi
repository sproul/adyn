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
  
  my $session_id = adyn_cgi_util::VerifyLogin($query);
  if ($session_id)
  {
    print "ok: $session_id";
  }
}

Main();

# b http://127.0.0.1:81/cgi-bin/login.cgi?whichPanel=simple_choose.htm&userID=nsproul&pw=x
# test with: export REMOTE_ADDR=4.4.4.4; cd $HOME/Dropbox/adyn/cgi-bin/;(echo userID=nsproul; echo pw=x)|perl -w login.cgi
# test with: export REMOTE_ADDR=4.4.4.4; cd $HOME/Dropbox/adyn/cgi-bin/;(echo userID=nsproul; echo session_id=as2zI4M4cp0lE)|perl -w login.cgi
