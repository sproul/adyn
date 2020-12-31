#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use IO::File;
use teacher_user;
use Ndmp;
#perl -MCPAN -e 'install Bundle::LWP'
#use MIME::Base64;
use Digest::MD5;
#use URI;
#use Net::FTP;
#use HTML::Tagset;
#use HTML::Parser;
#use HTML::HeadParser;
#use LWP::UserAgent;

use CGI qw(:standard);

sub Main
{
  my   $query;
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

  print "<html>"
  . "<body bgcolor=#cccccc>\n"
  . "<font face='arial'>\n";

  system("perl -version");
  print "<br>\n";

  print "ok\n";


  print "</font>\n"
  . "</body>\n"
  . "</html>\n";
                              
}
Main();
