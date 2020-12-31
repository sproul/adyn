#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use CGI qw(:standard);
use IO::File;

my $__anyHits = 0;
my @names = ();
my %phones = ();
my %titles = ();

my $query;

sub Result
{
  my($title, $name, $phone) = @_;
  $phone = '' if !defined $phone;

  if (!$__anyHits)
  {
    $__anyHits = 1;
    print "<center>\n";
    print "<table border=1 cellpadding=1 cellspacing=1 width=90% >\n";
    print "<tr><td><b>Title</b></td><td><b>Name</b></td><td><b>Phone</b></td></tr>\n";
  }

  push @names, $name;
  $phones{$name} = $phone;
  $titles{$name} = $title;

  print "<tr><td>$title &nbsp;</td><td>$name &nbsp;</td><td>$phone &nbsp;</td></tr>\n";
}

sub System
{
  my($s) = @_;
  Print("System($s);");
  system($s);
}

sub Print
{
  my($s) = @_;
  print "$s<br>\n";
}

sub Unwrap
{
  my($fn) = @_;

  if ($fn =~ m{(.*).gz$})
  {
    $fn = $1;
    if (-f "$fn.gz")
    {
      System("gzip -d $fn.gz");
    }
  }

  if ($fn =~ m{(.*)/([^/]+)$})
  {
    my $dir = $1;
    $fn = $2;
    Print "cd $dir";

    chdir($dir);
  }

  if ($fn =~ m{\.tar$})
  {
    my $f = IO::File->new("tar xvf $fn|");
    while (<$f>)
    {
      print "$_<br>\n";
    }
    $f->close();
  }
  unlink($fn);
}



sub Main
{
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

  my $f  = $query->url_param("f");
  if (defined $f)
  {
    # the ../ is designed to get us to the top of the web site tree:
    Unwrap("../$f");
  } 

  print "</font>\n"
  . "</body>\n"
  . "</html>\n";
                        
}
Main();
