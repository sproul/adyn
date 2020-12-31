package grammar;
use strict;
use diagnostics;
use nutil;
use French_grammar;
use Spanish_grammar;
use English_grammar;
use German_grammar;
use Italian_grammar;
use teacher_DumpedPerl;
use minimal_grammar;

my %__langGrammarObjects = ();
my $__trace = 0;

sub StripPunctuation
{
	my($token) = @_;
	
	$token =~ s/,c/__c/g;		# preserve ,c
	$token =~ s/_[!\?]//g;
	$token =~ s/[{}",!\?\.]//g;
	$token =~ s/__c/,c/g;
		
	$token =~ s/\^D.//g;
	$token =~ s/\^D$//;
	$token =~ s/-$//;
	return $token;
}

sub NormalizeToken
{
	my($token) = @_;
	$token = StripPunctuation($token);
	$token = grammar::MakeLowerCase($token);
	return $token;
}

sub MakeLowerCase
{
	my($token) = @_;
	# protect German double-s:
	$token =~ s/BB/__sss__/g;
	
	$token = nutil::MakeLowerCase($token);
		
	# restore
	$token =~ s/__sss__/BB/g;
	return $token;
}

sub Eval
{
  my($s) = @_;
  print "Eval($s)\n";
  eval($s);
  if ($@)
  {
    print "eval failed: ($s): $@\n";
  }
}

sub IsCapitalized
{
  my($s) = @_;
  return ($s =~ m{^({})?[/`#:]*[A-Z]});
}

sub Capitalize
{
  my($s) = @_;
  nutil::Warn() if !defined $s;
  
  # Re: the leading ({})?: I just want to ignore the '{}' inserted by ,g.ConformToCharacteristics:
  
  if ($s =~ /^{}(.*)/)
  {
    return "{}" . Capitalize($1);
  }
 
  $s =~ s/^(.)/\U$1/;
  $s =~ s{^([/`~\^])(.)}{$1\U$2};# capitalize an accented char (e.g., "/el" -> "/El")
  $s =~ s{^_(.)(.)}{_$1\U$2};	# capitalize an accented char (e.g., "_!no sigas" -> "_!No sigas")
  return $s;
}

sub UnCapitalize
{
  my($s) = @_;
  nutil::Warn() if !defined $s;

  # Re: the leading ({})?: I just want to ignore the '{}' inserted by ,g.ConformToCharacteristics:

  if ($s =~ /^{}(.*)/)
  {
    return "{}" . UnCapitalize($1);
  }

  $s =~ s/^(.)/\L$1/;
  $s =~ s{^([/`~\^])(.)}{$1\L$2};# capitalize an accented char (e.g., "/el" -> "/El")
  $s =~ s{^_(.)(.)}{_$1\L$2};	# capitalize an accented char (e.g., "_!no sigas" -> "_!No sigas")
  return $s;
}

sub GetLangGrammar
{
  my($lang, $readyToRegen) = @_;
  my $g = $__langGrammarObjects{$lang};
  if (defined $g)
  {
    return $g;
  }

  if ($lang eq "English")
  {
    $g = new English_grammar();
  }
  else
  {
    $g = teacher_DumpedPerl::Load($lang, $readyToRegen);
    if (defined $g)
    {
      $g->{"usingCachedGrammarInfo"} = 1;
      print "GetLangGrammar($lang): got cached\n" if $__trace;
      #$g->DumpValids();
    }
    else
    {
      print "GetLangGrammar($lang): did not get cached\n" if $__trace;
      $g->{"usingCachedGrammarInfo"} = 0;

      my $s = "\$g = new ${lang}_grammar();";
      eval($s);
      if ($@)
      {
	print "grammar.GetLangGrammar assumes $lang is not a special language\n" if $__trace;
	$s = "\$g = new minimal_grammar(\"$lang\");";
	eval($s);
	if ($@)
	{
	  die "evaluation failed: $s: $@";
	}
      }
    }
  }
  $__langGrammarObjects{$lang} = $g;
  $g->InitAll_even_if_cached();
  return $g;
}

sub UnregexpifyTeacherToken
{
  my($s) = @_;
  $s =~ s/\^/%%/g;
  $s =~ s/\\/=/g;
  return $s;
}

sub RegexpifyTeacherToken
{
  my($s) = @_;
  $s =~ s/%%/^/g;
  $s =~ s/=/\\/g;
  return $s;
}

sub GetGlobalIdForThisDataFile
{
  my($id) = @_;
  my $val = $id;
  $val =~ s/\.\d+$/.0/;
  print "grammar::GetGlobalIdForThisDataFile($id): $val\n" if $__trace;
  return $val;
}

sub ChoosePronoun
{
  my($id, $tense) = @_;
  
  my %allPronouns = ();
  $allPronouns{"p1"} = 
  $allPronouns{"p2a"} = 
  $allPronouns{"p2b"} = 
  $allPronouns{"p3a"} = 
  $allPronouns{"p3b"} = 
  $allPronouns{"s1"} = 
  $allPronouns{"s2a"} = 
  $allPronouns{"s2b"} = 
  $allPronouns{"s3a"} = 
  $allPronouns{"s3b"} = 1;
  
  my %pronouns = %allPronouns;
    
  if ($id =~ /(.*)\.(\d+)$/)
  {
    # rm pronouns already associated w/ $tense in data file
    my $df = $1;
    my $n = $2;
    for (my $j = 0; $j < $n; $j++)
    {
      my $jtense = tdb::Get("df.$j", "tense");
      next unless defined $jtense;
      next unless $jtense eq $tense;
      
      my $jpronoun = tdb::Get("df.$j", "pronoun");
      next unless $jtense eq $tense;
      delete($pronouns{$jpronoun});
    }
  } 
  
  my @pronouns = keys(%pronouns);
  if (!@pronouns)
  {
    @pronouns = keys(%allPronouns);
  } 
  my $which = nutil::random(scalar(@pronouns) - 1);
  return $pronouns[$which];
}


1;

# xtest with: cd $HOME/Dropbox/adyn/httpdocs/teacher/; perl -w grammar.pm
