package nutil;
use strict;
use diagnostics;
use Ndmp;
use DirHandle;

sub random_init
{
  my($seed) = @_;
  if (!defined $seed)
  {
    $seed = $$|time;
  }
  srand($seed);
}


sub random	# return a randomom int ranging from 0 to $max
{
  my($max) = @_;
  my $x = rand();
  my $val = int((($x * $max) + 0.5));
  #print STDERR "random($max): $x: $val\n";
  return $val;
}

sub MakeLowerCase
{
  my($s) = @_;
  $s =~ s/(.*)/\L$1/;
  return $s;
}

sub shuffleCopy
{
  my($to, $from) = @_;
  @$to = ();
  my $max = @$from - 1;
  for (my $j = 0; $j <= $max; $j++)
  {
    my $x = random($max);

    while (!defined $from->[$x])
    {
      $x++;
      $x = 0 if $x > $max;
    }
    $to->[$j] = $from->[$x];
    $from->[$x] = undef;
  }
}

sub GetStack
{
  eval('my $x = 1/0;'); 		# force an exception
  my $sst = $@;
  $sst =~ s/.*?GetStack.*?$//ms;	# remove the beginning of the factory so there is no record of the divide-by-zero
  return $sst;
}

sub Warn
{
  my($s) = @_;
  print STDERR "nutil::Warn: " . nutil::ToString($s);
  print STDERR GetStack();
}

sub ToString
{
  my($val) = @_;
  if (!defined $val)
  {
    return "undef";
  }
  return $val;
}

sub HashGet
{
  my($hashRef, $key) = @_;
  my $val = $hashRef->{$key};
  if (!defined $val)
  {
    Ndmp::Hh("cannot find $key in hash", %$hashRef);
    nutil::Warn("cannot find $key in hash");
  }
  return $val;
}

sub min
{
  my(@ns) = @_;
  my $minSoFar = $ns[0];
  foreach my $n (@ns)
  {
    $minSoFar = $n if $n < $minSoFar;
  }
  return $minSoFar;
}

sub max
{
  my(@ns) = @_;
  my $maxSoFar = $ns[0];
  foreach my $n (@ns)
  {
    $maxSoFar = $n if $n > $maxSoFar;
  }
  return $maxSoFar;
}

sub ls
{
  my($dir) = @_;

  my $d = new DirHandle $dir;
  die "no dir $dir" unless (defined $d);
  my @dirContents = ();
  while (defined($_ = $d->read))
  {
    my $child = $_;

    next if $child =~ /^\./;
    push @dirContents, $child;
  }
  $d->close();
  return @dirContents;
}

sub http_post
{
  my($url, $postData) = @_;

  require HTTP::Request;
  require LWP::UserAgent;

  my $request = HTTP::Request->new("POST");
  my $contentRef = $request->content_ref();
  $$contentRef = $postData;
  $request->url($url);
  my $ua = new LWP::UserAgent();
  my $response = $ua->request($request);
  my $s;
  if ($response->is_success)
  {
    $s = $response->content;
  }
  else
  {
    $s = $response->error_as_HTML;
    warn "http_post: failure for $url: $s";
  }

  $s =~ s/\r//g;
  return $s;
}

sub sleep
{
  my($t) = @_;
  select(undef,undef,undef,$t);
}

1;
# test with: perl -w $DROP/adyn/cgi-bin/nutil.pm
