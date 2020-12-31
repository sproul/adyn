#!/usr/bin/perl --
use strict;
use diagnostics;
use web_get;
use CGI qw(:standard);

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
  my($f) = @_;

  if ($f =~ m{(.*).gz$})
  {
    $f = $1;
    System("gzip -d $f.gz");
  }

  if ($f =~ m{(.*)/([^/]+)$})
  {
    my $dir = $1;
    $f = $2;
    Print "cd $dir";

    chdir($dir);
  }
    
  if ($f =~ m{\.tar$})
  {
    System("tar xvf $f");
  }
  #unlink($f);
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
    if (-f $f)
    {
      Unwrap($f);
    }
    else
    {
      print "Cannot find $f\n"; 
    } 
  } 

  print "</font>\n"
  . "</body>\n"
  . "</html>\n";
                        
}
Main();
