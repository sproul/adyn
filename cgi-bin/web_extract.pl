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


sub SniffSymbol
{
  my($symbol) = @_;

  my $url = 'http://www.nqb.com/quote/company_profile.jsp?symbol=' . $symbol;
  print "Examining a <a href=\"$url\">financial information web site</a> for symbol $symbol...<p>\n";

  my $page = web_get::get($url);

  #print "$page\n";

  while ($page =~ /[;>:]([\w\s\.]+), (CFO|CEO|Pres(ident|\.))/g)
  {
    Result($2, $1);
  }

  if ($page =~ /Phone: ([-\d]+)/)
  {
    Result("Reception", "HQ", $1);
  }

  my $webSite = undef;

  if ($page =~ m{Company Website: <a href=(http://[\w/\.]+)})
  {
    $webSite = $1;
  }

  if ($__anyHits)
  {
    print "</table>\n";
    print "</center>\n";

    my $callingHost = $query->remote_host();
    my $updateUrl;
    if ($callingHost eq "127.0.0.1")
    {
      $updateUrl = "http://$callingHost:7080/apps2/all/rolodex_frames.asp";
    }
    else
    {
      $updateUrl = "https://www.monroesecurities.biz/apps2/all/rolodex_frames.asp";
    }

    my $qs = "op=get_contacts&company_symbol=$symbol";
    for (my $j = 0; $j < scalar(@names); $j++)
    {
      my $name = $names[$j];
      my $phone = $phones{$name};
      my $title = $titles{$name};
      $qs .= "&name$j=$name&phone$j=$phone&title$j=$title";
    }

    $qs =~ s/ /%20/g;

    print "<p><a href=$updateUrl?$qs><b>Click here</b></a> to insert this information into the Monroe rolodex.<p>\n";

    if (defined $webSite)
    {
      print "See the <a href=$webSite>$symbol company web site</a> for more info.\n";
    }
  }
  else
  {
    print "No information extracted.\n";

    if (defined $webSite)
    {
      print "See the <a href=$webSite>$symbol company web site</a> for info.\n";
    }
  }
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

  my $symbol  = $query->url_param("symbol");
  SniffSymbol($symbol);


  print "</font>\n"
  . "</body>\n"
  . "</html>\n";
                    
}
Main();
