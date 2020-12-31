use diagnostics;
use IO::File;

my $trace = 0;

my $lang            =$ARGV[0];
my $noAddendKeyCycle=$ARGV[1]; # If this is set, then ignore data files which do not hook in addends, and only print a single cycle for each addend.
my $dataFile        =$ARGV[2];
my $combineToOneLine=$ARGV[3];
my $fn;
my $f;

sub Init
{
  if ($noAddendKeyCycle eq "0")
  {
    $noAddendKeyCycle = 0;
  }

  if (-f $dataFile)
  {
    $fn = $dataFile;
  }
  else
  {
    $fn = "/cygdrive/c/Users/nelsons/Dropbox/adyn/httpdocs/teacher/data/$dataFile";
  }
  $f = new IO::File("< $fn");
  if (!$f)
  {
    die "Dump_one_lang.pl: couldn't open $fn\n";
  }
}

Init();

my $s;
my $english;
my $key;
my $addendKey;
my $firstAddendSeen = undef;

while (<$f>)
{
  my $line = $_;
  print "read $line\n" if $trace;

  if ($line =~ m{'$lang' => '(.*)'})
  {
    $s = $1;
    print "got my target lang: $s\n" if $trace;
  }
  elsif ($line =~ m{'English' => '(.*)'})
  {
    $english = $1;
    $english =~ s/\^D.//g;
    $english =~ s/\\//g;
    $english =~ s/ +/ /g;
    print "saw english\n" if $trace;
  }
  elsif ($line =~ m{'addendKey' => '(.*)'})
  {
    $addendKey = "$1";
    if ($noAddendKeyCycle)
    {
      if (!defined $firstAddendSeen)
      {
	$firstAddendSeen = $addendKey;
      }
      elsif ($firstAddendSeen eq $addendKey)
      {
	print "exiting because of a full addend cycle\n" if $trace;
	exit(0);
      }
    }
  }
  elsif ($line =~ m{'id' => '?(\d+)})
  {
    $key = "$dataFile.$1";
    print "got id $key\n" if $trace;
  }
  elsif ($line =~ /^}/)
  {
    print "found end of entry ($s/$key)\n" if $trace;

    if (defined $s && defined $key)
    {
      $s =~ s/{}(.*?){.*?}/$1/g;
      $s =~ s/\^D.//g;
      $s =~ s/\\//g;
      $s =~ s/_h/h/g;
      $s =~ s/ +/ /g;

      if ($combineToOneLine)
      {
	if (defined $addendKey)
	{
	  print "$key/$addendKey: $s##$english\n";
	}
	elsif (!$noAddendKeyCycle)
	{
	  print "$key: $s##$english\n";
	}
      }
      else
      {
	if (defined $addendKey)
	{
	  print "# $english\n" if $lang ne "English";
	  print "$key/$addendKey: $s\n\n";
	}
	elsif (!$noAddendKeyCycle)
	{
	  print "# $english\n";
	  print "$key: $lang: $s\n\n";
	}
      }
    }
    print "getting ready for next\n" if $trace;
    
    $s = undef;
    $key = undef;
    $addendKey = undef;
  }
}

# test with: cd $HOME/Dropbox/adyn/httpdocs/teacher/;perl -w Dump_one_lang.pl German 0 base 1