#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
#
# browser:
#
# http://127.0.0.1:2082/cgi-bin/browser_tab_spawner.cgi?polling_delay_in_seconds=5&just_show_js=n
#
# w7 bash:
#
# echo 'url=http://127.0.0.1:2082/cgi-bin/choose.cgi?session_id=asos9t7PNxx/Y&whichPanel=simple_choose.htm&promptLang=Spanish&promptLang=English&exerciseSetTargetSize=30&lang_Italian=Italian&exerciseType=verb_common&reviewPercentage=50&tense=present&userID=t3, out=abc' > /www-data-msgs/browser_tab_spawner/input; (echo polling_delay_in_seconds=1; echo just_show_js=n) | perl -w $DROP/adyn/cgi-bin/browser_tab_spawner.cgi
use strict;
use diagnostics;
use IO::File;
use File::Copy;
use adyn_cgi_util;
use CGI qw(:standard);

# bash: browser -sync_with_output URL
#       bash: writes URL, OUTPUT_FN to /www-data-msgs/browser_tab_spawner/input
#       bash: if no browser is actively running browser_tab_spawner.cgi, then
#               browser /cgi-bin/browser_tab_spawner.cgi
#       cgi: /cgi-bin/browser_tab_spawner.cgi
#               cgi: touches /www-data-msgs/browser_tab_spawner/heartbeat
#               cgi: reads /www-data-msgs/browser_tab_spawner/input for work, then generates js to,
#                       js: for each line,
#                               js: execute that work, call alert.cgi to update OUTPUT_FN
#                       js: wait polling_delay_in_seconds
#                       js: call back to /cgi-bin/browser_tab_spawner.cgi
#       bash: cat OUTPUT_FN

sub Print
{
  my($s) = @_;
  $s .= "\n";
  $s =~ s/\n/<br>\n/g;
  print $s;
}


sub Touch_empty_file
{
  my($fn) = @_;
  my $f = new IO::File("> $fn");
  if ($f)
  {
    $f->close();
  }
}

my $query;
if (-d "c:/")
{
  $query = new CGI(\*STDIN);
}
else
{
  $query = new CGI;
}
Touch_empty_file("/www-data-msgs/browser_tab_spawner/heartbeat");
print $query->header(-status=>'200 OK', -expires=>'-1d', -type=>'text/html');
print adyn_cgi_util::html_header("browser_tab_spawner", undef, 1); 

my $polling_delay_in_seconds = adyn_cgi_util::param($query, "polling_delay_in_seconds");

my $just_show_js             = adyn_cgi_util::param_bool($query, "just_show_js");
my $host = $ENV{'HOST'};
sleep($polling_delay_in_seconds);
my $fn = "/www-data-msgs/browser_tab_spawner/input";
my $refresh_url = "/cgi-bin/browser_tab_spawner.cgi?polling_delay_in_seconds=$polling_delay_in_seconds";
if ($just_show_js)
{
  $refresh_url .= "&just_show_js=y";
}

my $js = "var refresh_url = \"$refresh_url\"\n";
#===============================================================================JS
$js .= <<'EOF';

var window_to_out_fn = new Object()
    
function status(h)
{
    $('#status_span').html("<b>" + h + "</b>")
}

function open_window(url, out_fn)
{
  win = window.open(url)
  window_to_out_fn[win] = out_fn
}

window.setInterval(function()
{
  var no_work_waiting = true
  for (key in window_to_out_fn)
  {
    no_work_waiting = false
    status('waiting on (at least) ' + window_to_out_fn[key])
    break
  }
  if (no_work_waiting)
  {
      status("no work waiting, refresh to " + refresh_url)
      window.location.href = refresh_url
  }
}, 2000)

EOF
#===============================================================================JS

if (! -f $fn)
{
  Print("browser_tab_spawner.cgi sees no $fn, just relax and then we will look again...");
}
else
{
  my $work_fn = "$fn.work";
  File::Copy::move($fn, $work_fn);
  my $f = new IO::File("< $work_fn");
  if (!$f)
  {
    Print("browser_tab_spawner.cgi could not open $work_fn: $!");
  }
  else
  {
    while( my $line = <$f>)
    {
      Print("Read $line");
      if ($line !~ m{url=(.*), out=(.*)})
      {
        Print("bad line $line in $fn");
      }
      else
      {
        my($url, $out_fn) = ($1, $2);
        $js .= "open_window(\"$url\", \"$out_fn\")\n";
        Print("Spawning window to $url...");
      }
    }
    $f->close();
    #unlink($work_fn);
  }
}

print "<span id=status_span>Initially no status</span>\n";
if (!$just_show_js)
{
  print "<script type=\"text/javascript\" src=\"/teacher/html/jquery-1.9.0.js\"></script>\n";
  print "<script type=\"text/javascript\">$js</script>\n";
}
#Print("<font size=-1><i>//============================================================================= JS begin");
#Print($js);
#Print(                 "//============================================================================= JS end</font></i>");
