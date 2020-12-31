#!c:/perl/bin/perl.exe
#!c:/cygwin/bin/perl.exe --
use strict;
use IO::File;
use CGI qw(:standard);

my $__trace = 0;
my %all = ();
my @symbols = ();
my $seeDir = "../httpdocs/see";
my $NEW_BROWSER_SESSIONS_PER_ADVANCE = 10;
my %symbolsShown = ();

sub JsBegin
{
  print "<script language='JavaScript'>\n";
}

sub JsEnd
{
  print "</script>\n";
}

sub JsWarn
{
  my($s) = @_;
  JsBegin();
  #print "alert(unescape('" + escape($s) + "'))\n";
  print "alert('$s')\n";

  JsEnd();
}

sub loadAll
{
  my $fn = "$seeDir/data/all";
  print "loadAll($fn)...\n" if $__trace;
  my $f = new IO::File("< $fn");
  if (!defined $f)
  {
    JsWarn("cannot open $fn");
  }
  else
  {
    while (<$f>)
    {
      chomp;
      next if /^#/;
      if (/^([^=]+)=(.*)$/)
      {
        my($key, $val) = ($1, $2);
        $all{$key} = $val;
        if ($key =~ m{^Last\.(.*)})
        {
          my $symbol = $1;
          push @symbols, $symbol;
        }
      }
      else
      {
        JsWarn("bad data seen in see/data/all: $_");
      }
    }
  }
  print "Loaded " . @symbols . "\n" if $__trace;
}

sub printHtmlTable
{
  JsBegin();
  print "var symbols = new Array()\n";
  
  foreach my $symbol (@symbols)
  {
    print "symbols.push('" . $symbol . "')\n";
  }
  JsEnd();
}


sub init()
{
  print header();
  print start_html("see");
  #print "Should detect updates to http://www.federalreserve.gov/newsevents/testimony/bernanke20090224a.htm, etc.<br>\n";
  print getDatum("date_generated") . "<br>\n";

  print <<"END";
  <!-- <a href=http://caps.fool.com>caps.fool.com</a> (picked CHK at 32.26 (8/31/07)<br>-->

  <script language="JavaScript">
  function refresh()
  {
    window.location = '/cgi-bin/see_data.cgi?refresh=y'
  }
  var openIndex=0
  function open10more()
  {
    var last = Math.min(openIndex + $NEW_BROWSER_SESSIONS_PER_ADVANCE, symbols.length)
    // go backwards so that the browser window order will naturally lead the user through the list in the right order
    for (var j = last-1; j >= openIndex; j--)
    {
      window.open('http://finance.google.com/finance?q=' + symbols[j])
    }
    openIndex = (last==symbols.length) ? 0 : last
  }

  </script>
  <!--<font size=-2>-->
  <input type=button value=re onclick="refresh()">
  <input type=button value=more onclick="open10more()">
  <table border=1 cellpadding=0 cellspacing=0>
  <!--
} Just to make my emacs indent get over to the left for the 'END':
-->
END

my $r = param("refresh");
if (defined $r && $r eq "y")
{
  system("sh /cygdrive/c/users/nsproul/Dropbox/adyn/cgi-bin/see_data_refresh.sh");
}

loadAll();

}

sub getChartURL
{
  my($symbol, $t) = @_;
  die "bad t=$t" unless ($t eq "1dy" || $t eq "3mo" || $t eq "6mo" || $t eq "1yr");
  return "/see/data/$symbol.mw.htm" if $t eq "1dy";
  return "http://custom.marketwatch.com/custom/ibg/html-intchart.asp?symb=$symbol&time=$t";
}

sub getGoogleFinanceURL
{
  my($symbol) = @_;
  return "http://finance.google.com/finance?q=$symbol";
}

sub System
{
  my($cmd) = @_;
  #print STDERR "Executing command: $cmd\n";
  system($cmd);
}


sub isKeyReversal
{
  my($symbol) = @_;
  my $High = getPriceChangeDatum("High.$symbol");
  my $Open = getPriceChangeDatum("Open.$symbol");
  my $Low = getPriceChangeDatum("Low.$symbol");
  my $Last = getPriceChangeDatum("Last.$symbol");
  my $High52 = getPriceChangeDatum("52-Wk_High.$symbol");
  my $Low52 = getPriceChangeDatum("52-Wk_Low.$symbol");
  die "undefined   data for $symbol: $High/$Open/$Low/$Last/$High52/$Low52" unless defined $High && defined $Open && defined $Low && defined $Last && defined $High52 && defined $Low52;
  if (!$High || !$Open || !$Low || !$Last || !$High52 || !$Low52)
  {
    print "incomplete data for $symbol: $High/$Open/$Low/$Last/$High52/$Low52" if $__trace;
    return 0;  
  }

  if ($Open > $Last && $High52==$High)
  {
    System("c:/cygwin/bin/sh /cygdrive/c/Users/nelsons/Dropbox/adyn/cgi-bin/remember_trade.sh KR short $symbol $Last");
    return 1;
  }
  if ($Open < $Last && $Low52==$Low)
  {
    System("c:/cygwin/bin/sh /cygdrive/c/Users/nelsons/Dropbox/adyn/cgi-bin/remember_trade.sh KR long $symbol $Last");
    return 1;
  }
  return 0;
}

sub getPercentChangeOffHours
{
  my($symbol) = @_;
  # maybe should use http://www.tradingday.com/c/afterhourstrading/pmpg.html to list off hours movers
  return getPriceChangeDatum("changeOffHours.$symbol");
}

sub getPercentChange
{
  my($symbol) = @_;
  return getPriceChangeDatum("change.$symbol");
}

sub getPriceChangeDatum
{
  my($key) = @_;
  my $val = getDatum($key);
  if ($val && ($val !~ /^-?[\.0-9]*$/))
  {
    warn "bad \"$val\" for $key";
    return "";  # used to do '9999999999' -- msg in a bottle
  }
  return $val;
}

sub getDatum
{
  my($key) = @_;
  my $x = $all{$key};
  if (defined $x)
  {
    return $x;
  }
  return '';
}

sub formatPercent
{
  my($n) = @_;
  return int($n * 100) / 100;
}

sub printSymbolRow
{
  my($symbol) = @_;
  return if defined $symbolsShown{$symbol};
  $symbolsShown{$symbol} = 1;

  my $lowerSymbol = $symbol;
  $lowerSymbol =~ s/(.*)/\L$1/;

  my $percentChange = getPercentChange($symbol);
  my $percentChangeHtml = $percentChange;
  if ($percentChangeHtml ne '')
  {
    if ($percentChange !~ /^-?[\.\d]+$/)
    {
      warn "Bad computation for $symbol: percentChange=$percentChange";
      $percentChangeHtml = $percentChange = 0;
    }

    $percentChangeHtml = "<font color=red>$percentChange</font>" if abs($percentChange) > 3;
  } 

  my $keyReversal = (isKeyReversal($symbol) ? "KR" : "&nbsp;");
  
  my($positionOpenDate, $positionChange, $whoSays);
  
  if (!getDatum("positionOpenDate.$symbol"))
  {
    ($positionOpenDate, $positionChange, $whoSays) = ("&nbsp;", "&nbsp;", "&nbsp;");
  }
  else
  {
    my $positionType = getDatum("positionType.$symbol");
    $positionOpenDate = getDatum("positionOpenDate.$symbol");
    $positionOpenDate =~ s{/\d\d\d\d$}{};
    
    my $positionOpenPrice = getPriceChangeDatum("positionOpenPrice.$symbol");
    my $lastPrice = getPriceChangeDatum("Last.$symbol");
    
    $positionChange = "<font color=" . (($positionType eq "short") ? "red" : "blue") . ">" . formatPercent(($lastPrice - $positionOpenPrice) * 100 / $positionOpenPrice) . "</font>";
    
    $whoSays ="<font color=" . (($positionType eq "short") ? "red" : "blue") . ">" . getDatum("whoSays.$symbol") . "</font>";
  }
  my $percentChangeOffHours = getPercentChangeOffHours($symbol);
  my $percentChangeOffHoursHtml = $percentChangeOffHours;
  if ($percentChangeOffHoursHtml ne '')
  {
    $percentChangeOffHoursHtml = "<font color=#cccccc><a href=dummy_link_to_provoke_color_change>$percentChangeOffHours</a></font>" if abs($percentChangeOffHours) > 1.5;
    $percentChangeOffHoursHtml = "<blink>$percentChangeOffHoursHtml</blink>" if abs($percentChangeOffHours) > 5;
  }

  print "<tr><td><a target=$symbol href=" . getGoogleFinanceURL($symbol) . ">$lowerSymbol</a></td>"
  . "<td>" . $percentChangeHtml . "</td>"
  . "<td>" . $percentChangeOffHoursHtml . "</td>"
  . "<td>" . $keyReversal . "</td>"
   . "<td>" . $whoSays . "</td>"
  . "<td>" . $positionOpenDate . "</td>"
  . "<td>" . $positionChange . "</td>"  
  . "</tr>\n";
}

init();
foreach my $symbol (@symbols)
{
  printSymbolRow($symbol);
}
printHtmlTable();
print "</table></body></html>\n";
