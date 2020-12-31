#!/usr/bin/perl --
use strict;
use diagnostics;
use web_get;

my $url = $ARGV[0];
my $user = undef;
my $pw = undef;

if ($#ARGV >= 2)
{
  $user = $ARGV[1];
  $pw = $ARGV[2];
}
print web_get::get($url, $user, $pw);
