use strict;
use diagnostics;
use IO::File;
use nutil;

my $reviewer;
my $lang;

sub Init
{
  my $arg = $ARGV[0];
  if (! -f $arg)
  {
    $lang = $arg;
    $reviewer = undef;
    return undef;
  }
  else
  {
    my $reviewerOutputFn = $ARGV[0];
    die "can't parse $reviewerOutputFn" unless $reviewerOutputFn =~ m{/corrections([\.\d\.]*)?\.([a-z]+)\.};
    $reviewer = $2;
    if ($reviewer =~ /^(marge|c|josse|celine|martin)$/)
    {
      $lang = "French";
    }
    elsif ($reviewer =~ /^(annette|j|juliane|mommy)$/)
    {
      $lang = "German";
    }
    else
    {
      die "what lang does $reviewer do?";
    }

    my $reviewerOutput = new IO::File("< $reviewerOutputFn");
    if (!defined $reviewerOutput)
    {
      die "can't open $reviewerOutputFn";
    }
    return $reviewerOutput;
  }
}

sub LoadTranslations
{
  my($xlationFn) = @_;
  my %h = ();
  if (-f $xlationFn)
  {
    my $in = new IO::File("< $xlationFn");
    while (<$in>)
    {
      my $s = $_;
      chop $s;

      my $english;
      my $other;
      my $reviewers;

      if ($s =~ /^(.*)##(.*)##(.*)$/)
      {
	$other = $1;
	$english = $2;
	$reviewers = $3;
      }
      elsif ($s =~ /^(.*)##(.*)$/)
      {
	$other = $1;
	$english = $2;
	$reviewers = "";
      }
      else
      {
	die "didn't understand $s";
      }
      my $key = "$other##$english";
      #print "save_rvw::LoadTranslations($xlationFn): $key -> $reviewers\n";
      my $oldReviewers = $h{$key};
      if (defined $oldReviewers)
      {
	if ($oldReviewers !~ $reviewers)
	{
	  $h{$key} = "$oldReviewers$reviewers";
	}
      }
      else
      {
	$h{$key} = $reviewers;
      }
    }
  }
  return %h;
}


sub SaveTranslations
{
  my($hRef, $xlationFn) = @_;
  my $out = new IO::File("> $xlationFn");
  die "can't open $xlationFn" unless defined $out;
  
  foreach my $key (sort keys %$hRef)
  {
    die "didn't parse $key" unless $key =~ /^(.*)##(.*)$/;
    my $other = $1;
    my $english = $2;
    my $reviewers = $hRef->{$key};
    print $out "$other##$english##$reviewers\n";
  }
  $out->close();
}


sub ReflectReviewerOutput
{
  my($langReviewedRef, $reviewerOutput) = @_;
  while (<$reviewerOutput>)
  {
    my $english = $_;
    chop $english;
    $english =~ s/^# //;
    $english =~ s/ *$//;
        
    my $other = <$reviewerOutput>;
    chop $other;
    $other =~ s/ *$//;

    my $key = "$other##$english";
    my $previousReviewers = $langReviewedRef->{$key};
    if (!defined $previousReviewers)
    {
      $previousReviewers = "";
    }
    if ($previousReviewers !~ /;$reviewer\b/)
    {
      $langReviewedRef->{$key} = "$previousReviewers;$reviewer";
    }

    my $blankLine = <$reviewerOutput>;
    if (!defined $blankLine)
    {
      last;
    }
    if ($blankLine !~ /^$/)
    {
      print "expected a blank line after\n$english\n";
      exit(0);
    }
  }
}

sub WriteReviewerTodoFile
{
  my($langRawRef, $langReviewedRef, $reviewerTodoFn) = @_;
  my $reviewerTodoF = new IO::File("> $reviewerTodoFn");
  die "couldn't open $reviewerTodoFn" unless defined $reviewerTodoF;

  foreach my $key (sort keys %$langRawRef)
  {
    my $previousReviewers = $langReviewedRef->{$key};
    #print "save_rvw::WriteReviewerTodoFile($langRawRef, $langReviewedRef, $reviewerTodoFn): $key:\n " . nutil::ToString($previousReviewers) . "\n\n";
    next if defined $previousReviewers && $previousReviewers;

    die "didn't parse $key" unless $key =~ /^(.*)##(.*)$/;
    my $other = $1;
    my $english = $2;
    print $reviewerTodoF "# $english\n$other\n\n";
  }

  $reviewerTodoF->close();
}

my $reviewerOutput = Init();
my %langRaw  = LoadTranslations("can/review/$lang.raw");
my %langReviewed = LoadTranslations("can/review/$lang.reviewed");
if (defined $reviewerOutput)
{
  ReflectReviewerOutput(\%langReviewed, $reviewerOutput);
}
SaveTranslations(\%langReviewed, "can/review/$lang.reviewed");
WriteReviewerTodoFile(\%langRaw, \%langReviewed, "can/review/$lang.to_be_reviewed");
system("wc -l can/review/$lang.to_be_reviewed");
system("ls -l can/review/$lang.to_be_reviewed");
