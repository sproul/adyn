use strict;
use diagnostics;
use nutil;
use HTTP::Request;
use LWP::UserAgent;
use filer;
use Time::HiRes;


my @__users = nutil::ls("usr");
my %__requestCount = ();
my %__timeElapsed = ();

my $__t0;

sub startClock
{
  $__t0 = [Time::HiRes::gettimeofday()];
}

sub stopClock
{
  my($user) = @_;
  my $elapsed = Time::HiRes::tv_interval ( $__t0, [Time::HiRes::gettimeofday()]);

  $__timeElapsed{$user} = 0 if !defined $__timeElapsed{$user};
  $__timeElapsed{$user} += $elapsed;
}

sub GetDefaultFormSettings
{
  my %h = ();

  $h{"exerciseSetTargetSize"} = "15";
  $h{"exerciseType"} = "verb_all";
  $h{"lang_French"} = "1";
  $h{"lang_German"} = "1";
  $h{"lang_Italian"} = "1";
  $h{"lang_Spanish"} = "1";
  $h{"canonizedTest"} = "1";
  $h{"$randomSeed"} = "123456";
  $h{"reviewPercentage"} = "50";
  return \%h;
}

sub Execute_choose_cgi
{
  my($formSettings, $userID) = @_;
  $__requestCount{$userID}++;
  my $formSettingsS = "";
  foreach my $formSetting (keys %$formSettings)
  {
    $formSettingsS .= "&" if $formSettingsS;
    $formSettingsS .= $formSetting . "=" . $formSettings->{$formSetting};
  }

  $formSettingsS .= "&userID=$userID";
  my $url = "http://127.0.0.1/bin/choose.cgi";
  #print "calling http_post: $url?$formSettingsS...\n";

  startClock();
  my $content = nutil::http_post($url, $formSettingsS);
  stopClock($userID);
  return $content;
}

sub SummarizePerformance
{
  foreach my $userID (keys %__timeElapsed)
  {
    my $requestCount = $__requestCount{$userID};
    my $timeElapsed = $__timeElapsed{$userID};;
    my $timePerRequest = $requestCount / $timeElapsed;
    print "$userID: $requestCount requests in $timeElapsed seconds: $timePerRequest\n";
  }
}


sub ExecuteStandardTests
{
  #my($@@) = @_;

  foreach my $user (@__users)
  {
    my $formSettings = GetDefaultFormSettings();
    my $outputFn = "output/$user.out";
    my $output = Execute_choose_cgi($formSettings, $user);
    filer::setContent($outputFn, $output, 1);
    #die "sdlkj";
    #warn "only doing this once"; last;
  }
}

for (my $j = 0; $j < 30; $j++)
{
  ExecuteStandardTests();
}
SummarizePerformance();
