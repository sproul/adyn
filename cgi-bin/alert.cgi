#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use IO::File;
use adyn_cgi_util;
use CGI qw(:standard);

sub write_file
{
  my($out_fn, $subject, $body) = @_;
  my $f = new IO::File("> $out_fn");
  if (!$f)
  {
    die("alert.cgi could not open $out_fn: $!");
  }
  $f->write("alert.cgi: $subject\n");
  $f->write("$body") if $body;
  $f->write("\n") if $body !~ /\n$/;
  $f->write("EOF\n");
  $f->close();
}

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

  my $body = adyn_cgi_util::param($query, "body");
  my $subject = adyn_cgi_util::param($query, "subject");
  my $host = $ENV{'HOST'};
  if (!$host)
  {
    $host = "alert.cgi.ENV_HOST_UNSET";
  }
  my $out_fn = adyn_cgi_util::param($query, "out_fn", "/www-data-msgs/todo.$host.www");
  if ($out_fn !~ m{^/www-data-msgs/})
  {
    die "error: illegal output file $out_fn: I require that you only write to /www-data-msgs";
  }
  else
  {
    write_file($out_fn, $subject, $body);
    write_file("/tmp_from_parent/alert_cgi.out", $subject, $body);
    print "ok";
  }
}

Main();

# test with: cd $DROP/adyn/cgi-bin/; (echo body=body0; echo subject=subject0) | perl -w alert.cgi
