package German_grammar;
use o_token;
use Argv_db;
use strict;
use diagnostics;
use arrayOfArrays;
use nlist;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);

# alphabetize
my $__MassageAndFootnoteTrace;	# set in init based on -MassageAndFootnoteDebug flag
my $__compoundPastParticiple = undef;
my $__compoundPastParticipleVerb = undef;
my $__inMainClause = 1;
my $__verbPrefixList1 = ":uberein|wiederher|zur:uck";
my $__verbPrefixList2 = "ab|an|auf|aus|bei|durch|ein|fest|fort|heim|herein|hinunder|mit|nach|nieder|spazieren|um|voll|vor|wahr|weg|weh|wieder|zu";
my $__waitingInfinitive = undef;
my $__waitingPastParticiple = undef;
my $__waitingPastParticipleVerb = undef;

sub ExplainCase
{
  my($self, $case, $why, $currentToken) = @_;

  $currentToken = "%currentToken%" unless defined $currentToken;
      
  return "$currentToken is in the"
  . PrintCase($case)
  . " case "
  . $why;
}

sub SeparatePrefix
{
  my($self, $v, $verb_b) = @_;
  my($prefix, $base);
  if ($v =~ /^(an)(strengen)$/)
  {
    ($prefix, $base) = ($1, $2);
  }
  # Each of the prefixes in the first clause of the elsif expression below
  # is a superstring of another possible separable prefix in the second clause, and 
  # therefore must be tested for separately:
  
  elsif ($v =~ /^($__verbPrefixList1)(.*)/	
  ||     $v =~ /^($__verbPrefixList2)(.*)/)
  {
    ($prefix, $base) = ($1, $2);
        
    if (!defined $verb_b)
    {
      $verb_b = $v;
    }
    $verb_b =~ s/^$prefix//;
    my $argsRef = $self->GetVerbArgs($verb_b, 1);
    if (!defined $argsRef)
    {
      #print "German_grammar::SeparatePrefix($v): could not find $verb_b\n";
      ($prefix, $base) = ('', $v);
    } 
    else
    {
      $self->{"separableVerbPrefix"} = $prefix;
    }
  }
  else
  {
    ($prefix, $base) = ('', $v);
  }
  #print "German_grammar::$self->SeparatePrefix($v): ($prefix, $base)\n";
  return ($prefix, $base);
}

sub TransformPastParticiple
{
  my($self, $oldPp, $oldVerb, $newVerb, $before, $after, $suffixBefore, $suffixAfter) = @_;
              
  my($prefix, $base) = $self->SeparatePrefix($newVerb);
  my     $newPp;
  if ($prefix && ($base eq $oldVerb))
  {
    $newPp = $prefix . $self->GetPastParticiple($oldVerb);
  }
  else
  {
    if (!ShouldPrependGeToPastParticiple($newVerb))
    {
      $oldPp =~ s/^ge//;
    }
    my $s = $self->SUPER::DuplicatePattern($oldPp, $before, $after, $suffixBefore, $suffixAfter);
    #print "German_grammar::TransformPastParticiple-1($oldPp, $oldVerb, $newVerb, $before, $after, " . nutil::ToString($suffixBefore) . ", " . nutil::ToString($suffixAfter) . "): $s\n";
    if ($after !~ /(gesch)/) 
    {
      if ($before =~ /^\^(.*)/)
      {
	$before = "^ge$1";
	$after = "ge$after" if ShouldPrependGeToPastParticiple($newVerb);
	$s = $self->SUPER::DuplicatePattern($s, $before, $after);
	#print "German_grammar::TransformPastParticiple-2: $s\n";
      }
      if (defined $suffixBefore
      &&  ($suffixBefore =~ /^\^(.*)/))
      {
	$suffixBefore = "^ge$1";
	$suffixAfter  = "ge$suffixAfter" if ShouldPrependGeToPastParticiple($newVerb);
	$s = $self->SUPER::DuplicatePattern($s, $suffixBefore, $suffixAfter);
	#print "German_grammar::TransformPastParticiple-3: $s\n";
      }
    }
    $newPp = $s;
  } 
  #print "German_grammar::TransformPastParticiple($oldPp, $oldVerb, $newVerb, $before, $after): $newPp\n";
  return $newPp;
}

sub GetStem
{
  my($self, $verb, $tense) = @_;
        
  my $conjugationStem = $self->SUPER::GetStem($verb, $tense);
  if (defined $conjugationStem)
  {
    #print "SUPER::GetStem returned $conjugationStem\n";
  }
  else
  {
    if ($verb =~ /(\S+)( .*)$/)
    {
      return $self->GetStem($1, $tense);
    } 
    
    if ($verb =~ /(.*)2$/)
    {
      return $self->GetStem($1, $tense);
    } 
            
    my $argsRef = $self->GetVerbArgs($verb);
    my($stem_b, $inf_b, $pastParticiple_b,
    $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2b_b, $s3_b, $p1_b, $p2b_b, $p3_b, $argRef_reflexive_a, $argRef_reflexive_b) = @$argsRef;
    if ($tense eq "past participle"
    ||  $tense eq "preterite"
    ||  $tense eq "imperfect")
    {
      if ($verb =~ /(.*[^e])n$/)
      { 
	$conjugationStem = $1;
      } 
      elsif ($verb =~ /(.*[nt][dm])en$/		# atmen, finden
      ||     $verb =~ /(.*[f][n])en$/)		# :offnen
      { 
	$conjugationStem = $1 . "e";
      } 
      else
      {
	die $verb unless $verb =~ /(.*)..$/;
	$conjugationStem = $1;
      } 
      if ($tense eq "past participle")
      {
	$conjugationStem = SoftenStem($conjugationStem);
      }
    }
    elsif ($tense =~ /^(k1|k2)$/)
    {
      if (($verb !~ /(.*)e[lr]?n$/)
      &&  ($verb !~ /(.*)n$/))
      {
	die $verb;
      }
      $conjugationStem = $1;
                        
      if ($tense eq "k2")
      {
	$conjugationStem = SoftenStem($conjugationStem) if (!defined $self->GetOverride($verb, "vowels"));
      }
    }
    elsif (($tense eq "future")
    || ($tense eq "conditional"))
    {
      $conjugationStem = $verb;
    } 
  }
  #print "GetStem($verb, $tense) => $conjugationStem\n";
  return $conjugationStem;
}
  

sub PossiblyAddPronouns
{
  my($self, $tense, $reflexive_b, $verb_b) = @_;
  #print "PossiblyAddPronouns($tense, $reflexive_b, $verb_b)\n";
  my $p1 = "";

  if ($tense eq "imperative")
  {
    $p1 = " wir";
  }

  if (!$reflexive_b)
  {
    return [ "", "", "", "", "$p1", "", "" ];
  }
  elsif ($self->GetOverride($verb_b, 'dative'))
  {
    return [ " mir", " sich", " dir", " sich", "$p1 uns", " euch", " sich" ];
  }
  else	# acc.
  {
    return [ " mich", " sich", " dich", " sich", "$p1 uns", " euch", " sich" ];
  }
}

sub GetHelperVerb
{
  my($self, $verb, $reflexive) = @_;
  if (defined $self->Get__hasSecondaryHelperVerb($verb))
  {
    return "sein";
  }
  return "haben";
}

sub GetPastParticiple
{
  my($self, $verb) = @_;
  my $val = undef;
      
  if ($verb =~ /^werden(.*)$/)
  {
    if ($1 || $self->{"trailingString"})
    {
      $val = "worden";
    } 
  }
    
  if (!defined $val)
  {
    if ($verb =~ /sich (.*)$/)
    {
      $verb = $1;
    } 
    if ($verb =~ /(\S+)( .*)$/)
    {
      $val = $self->GetPastParticiple($1);
    } 
    else
    {
      $val = $self->GetOverride($verb, "past participle");
    }
  }    
    
  if (!defined $val)
  {
    my($prefix, $base) = $self->SeparatePrefix($verb);
    if ($prefix)
    {
      $val = $prefix . $self->GetPastParticiple($base);
    }
    else
    {
      if (!ShouldPrependGeToPastParticiple($verb))
      {
	$val = "";
      }
      else
      {
	$val = "ge";
      } 
      $val .= $self->GetStem($verb, "past participle") . "t"; 
    } 
  }
  #print "GetPastParticiple($verb) = $val\n";
  return $val;
}

sub GetVTtoSParms
{
  my($self, $verb_b, $tense, $trailingString_a, $trailingString_b, $reflexive_a, $reflexive_b, $compoundPast) = @_;

  #print "GetVTtoSParms($verb_b, $tense, $trailingString_a, $trailingString_b, reflexive_b=$reflexive_b)\n";
  my $argsRef = $self->GetVerbArgs($verb_b);

  #Ndmp::Ah("GetVTtoSParms: argsRef for $verb_b", $argsRef);

  my($stem_b, $inf_b, $pastParticiple_b,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2b_b, $s3_b, $p1_b, $p2b_b, $p3_b, $argRef_reflexive_a, $argRef_reflexive_b) = @$argsRef;

  #print "GetVTtoSParms($verb_b, $tense, $trailingString_a, $trailingString_b, $reflexive_a, $reflexive_b, $compoundPast)\n	Got stem_b=$stem_b, inf_b=$inf_b, pastParticiple_b=$pastParticiple_b, stem_a=$stem_a, inf_a=$inf_a, s1_a=$s1_a, s2_a=$s2_a, s3_a=$s3_a, p1_a=$p1_a, p2_a=$p2_a, p3_a=$p3_a, s1_b=$s1_b, s2b_b=$s2b_b, s3_b=$s3_b, p1_b=$p1_b, p2b_b=$p2b_b, p3_b=$p3_b, argRef_reflexive_a=$argRef_reflexive_a, argRef_reflexive_b=$argRef_reflexive_b)\n";

  die "kx" unless !defined $p1_b || ($self->VerbArgs_get_p1_b($argsRef) eq $p1_b);
  die "kz"         unless  $self->VerbArgs_get_stem_b($argsRef) eq $stem_b;

  $reflexive_a = $argRef_reflexive_a unless defined $reflexive_a;
  $reflexive_b = $argRef_reflexive_b unless defined $reflexive_b;

  if ($verb_b =~ /(sich )(.*)/)
  {
    $reflexive_b = $1;
    $verb_b = $2;
  }
  if ($verb_b =~ /^(\S+) (.*)/)
  {
    $verb_b = $1;

    my $x = $2;
    if (!$trailingString_b)
    {
      $self->{"trailingString"} = " $x";
    }
    $trailingString_b .= " $x";
  }
  my $verb_a = $self->Build_verb_a($stem_a, $inf_a);
  my $pastParticiple_a = $self->GetPastParticiple_English($verb_a);
  my $resetEnglish = undef;
  my $dummy;
  if ($verb_a =~ /^(\S+) (.*)/)  # e.g., "be worth"
  {
    $trailingString_a = " $2$trailingString_a";
    $resetEnglish = "$1";
  }
  elsif ($compoundPast && ($verb_a eq "be"))
  {
    # ^etre is apparently being used as an auxiliary verb in a compound
    # past phrase.  The English translation for this is going to be based
    # on the verb "to have".  Change the English parameters:
    $resetEnglish = "have";
  }

  if (defined $resetEnglish)
  {
    $argsRef = $self->Get__verbsByEnglish($resetEnglish);
    die "Wanted to reset English to $resetEnglish but couldn't." unless defined $argsRef;

    ($dummy, $dummy, $dummy,
    $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a) = @$argsRef;

    #print "Switching English': $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a\n";

    $stem_a = $resetEnglish;
    $inf_a = "";
    $verb_a = $self->Build_verb_a($stem_a, $inf_a);
    $pastParticiple_a = $self->GetPastParticiple_English($verb_a);
  }

  my($s3a_a, $s3b_a) = ($s3_a, $s3_a);
  my($s3a_b, $s3b_b) = ($s3_b, $s3_b);
  my $s2a_b = $s3_b;
  my $s2a_a = $s2_a;
  my($p2a_b, $p3a_b) = ($p1_b, $p1_b);
  my $p3b_b = undef;

  die "bad stem" unless defined $stem_a;

  if ($tense =~ /^(past|pluperfect|past_k2)$/)
  {
    my $helperVerb_b = $self->GetHelperVerb($verb_b, $reflexive_b);
    ($dummy, $dummy, $dummy, $dummy,
    $dummy, $dummy, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b, $reflexive_a, $reflexive_b)
    = $self->GetVTtoSParms($helperVerb_b,
    $self->GetHelperTense($tense),
    " " . $self->GetPastParticiple_English($verb_a) . $trailingString_a,
    " " . $self->GetPastParticiple($verb_b) . $trailingString_b,
    $reflexive_a,
    $reflexive_b,
    1);
  }
  else
  {
    if (($tense eq "past_conditional")
    || ($tense eq "future_perfect")
    || ($tense eq "future")
    || ($tense eq "conditional"))
    {
      if (($tense eq "past_conditional")
      || ($tense eq "future_perfect"))
      {
	$pastParticiple_b = $self->GetPastParticiple($verb_b);
      }
      my $tense_GetEnglishConjugation;
      my $helperVerb_b = $self->GetHelperVerb($verb_b);
      if ($tense =~ /^future/)
      {
	$tense_GetEnglishConjugation = "future";
	($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b) = ("werde", "wirst", "wird", "werden", "werdet");
	if ($tense eq "future")
	{
	  $trailingString_b = " $verb_b$trailingString_b";
	}
	else
	{
	  $trailingString_a = " " . $self->GetPastParticiple_English($verb_a) . $trailingString_a;
	  $trailingString_b = " $pastParticiple_b $helperVerb_b$trailingString_b";
	  $verb_a = "have";
	}
      }
      elsif ($tense =~ /conditional$/)
      {
	$tense_GetEnglishConjugation = "conditional";
	($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b) = ("w:urde", "w:urdest", "w:urde", "w:urden", "w:urdet");
	if ($tense eq "conditional")
	{
	  $trailingString_b = " $verb_b$trailingString_b";
	}
	else
	{
	  $trailingString_a = " " . $self->GetPastParticiple_English($verb_a) . $trailingString_a;
	  $trailingString_b = " $pastParticiple_b $helperVerb_b$trailingString_b";
	  $verb_a = "have";
	}
      }
      else
      {
	die $tense;
      }
      $s3b_b = $s3a_b;
      $p2a_b = $s2a_b = $p3a_b = $p1_b;
      ($s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a) = $self->GetEnglishConjugation("__unused__", $tense_GetEnglishConjugation, $verb_a, $compoundPast, $trailingString_a);  ###### these parms aren't used for input: , $s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a);
    }
    else
    {
      my $seperablePrefix = "";
      ($seperablePrefix, $stem_b) = $self->SeparatePrefix($stem_b, $verb_b);

      if ($seperablePrefix)
      {
	$trailingString_b .= " " . $seperablePrefix;
      }
      if (($tense eq "preterite")
      || ($tense eq "imperfect")
      || ($tense eq "k1")
      || ($tense eq "k2"))
      {
	($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b) = $self->ResolveEndings($stem_b, $inf_b, $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $tense);
	#print "from resolve end: ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b)\n";
      }
      elsif (($tense eq "present")
      || ($tense eq "imperative"))
      {
	my $overriddenConjugation = $self->GetOverrideList($verb_b, "imperative");
	if (($tense eq "imperative") && (defined $overriddenConjugation))
	{
	  ($s2b_b, $p1_b, $p2b_b) = @$overriddenConjugation;
	}
	else
	{
	  $s1_b  = $self->PossibleSpellingChange($tense, $verb_b, $stem_b, $s1_b)	if defined $s1_b;
	  $s2b_b = $self->PossibleSpellingChange($tense, $verb_b, $stem_b, $s2b_b)	if defined $s2b_b;
	  $s3a_b = $self->PossibleSpellingChange($tense, $verb_b, $stem_b, $s3a_b)	if defined $s3a_b;
	  $p1_b  = $self->PossibleSpellingChange($tense, $verb_b, $stem_b, $p1_b)	if defined $p1_b;
	  $p2b_b = $self->PossibleSpellingChange($tense, $verb_b, $stem_b, $p2b_b)	if defined $p2b_b;
	}
      }
      else
      {
	die $tense;
      }
      ($s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a) = $self->GetEnglishConjugation("__unused__", $tense, $verb_a, $compoundPast, $trailingString_a, $s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a);
    }
    $s3b_a = $s3a_a;
    $p3b_b = $p3a_b = $s2a_b = $p2a_b = $p1_b;
    $s3b_b = $s3a_b;

    $p1_b = "sind" if ($tense eq "imperative") && ($verb_b =~ /^sein( .*)?/); 		# hackeroo!

    # If we've already called this routine, then the reflexive pronouns will already be in place.
    # Guard against redundant reflexive pronouns being added:
    my $x = $self->PossiblyAddPronouns($tense, $reflexive_b, $verb_b);

    $s1_b  .= $x->[0] . $trailingString_b;
    $s2a_b .= $x->[1] . $trailingString_b;
    $s2b_b .= $x->[2] . $trailingString_b;
    $s3a_b .= $x->[3] . $trailingString_b;
    $p1_b  .= $x->[4] . $trailingString_b;
    $p2b_b .= $x->[5] . $trailingString_b;
    $p3a_b .= $x->[6] . $trailingString_b;
    $p3b_b = $p3a_b;
    $p2a_b = $s2a_b;
    $s3b_b = $s3a_b;
  } # else not 'past' or 'pluperfect'
  if ($reflexive_a && !$compoundPast)
  {
    $s1_a = $self->InsertReflexivePronoun_English($s1_a, "myself");
    $s2_a = $self->InsertReflexivePronoun_English($s2_a, "yourself");
    $s3a_a = $self->InsertReflexivePronoun_English($s3a_a, "himself");
    $s3b_a = $self->InsertReflexivePronoun_English($s3b_a, "herself");
    $p1_a = $self->InsertReflexivePronoun_English($p1_a, "ourselves");
    $p2_a = $self->InsertReflexivePronoun_English($p2_a, "yourselves");
    $p3_a = $self->InsertReflexivePronoun_English($p3_a, "themselves");
  }
  return ($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b,
  $reflexive_a, $reflexive_b);
}

sub GetPersonalPronouns
{
  my($self, $reflexive, @actions) = @_; # @actions was $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b
  return ("ich ", "Sie\n", "du\n", "er ", "sie ", "wir ", "Sie\n ", "ihr\n ", "sie ", "sie ");
}

sub VTtoS
{
  my($self, $verb_b, $tense, $doingVerbTable) = @_;
  #print "VTtoS($verb_b, $tense)\n";

  delete($self->{"separableVerbPrefix"});
  delete($self->{"trailingString"});

  my($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b,
  $reflexive_a, $reflexive_b)
  = $self->GetVTtoSParms($verb_b,$tense,'','',undef,undef,0);
  #print "GetPersonalPronouns($verb_b, $reflexive_b)\n";

  my $hdr_inf_a = $self->Get_verb_a_withToIfAppropriate($verb_b);

  $self->VerbGenInit($verb_b);
  my @s = ();
  my @p = ();
  if ($tense eq "imperative")
  {
    push @s, $self->X($tense, "$s2_a!", "s2a", "${s2a_b}!", $s2a_b) if defined $s2a_b;
    push @s, $self->X($tense, "$s2_a!", "s2b", "${s2b_b}!", $s2b_b) if defined $s2b_b;
    $self->X(         $tense, "don't $s2_a!", "s2b_no", "${s2b_b} nicht!", $s2b_b) if defined $s2b_b;
    push @p, $self->X($tense, "let's $p1_a!", "p1", "${p1_b}!", $p1_b) if defined $p1_b;
    $self->X(         $tense, "let's not $p1_a!", "p1_no", "${p1_b} nicht!", $p1_b) if defined $p1_b;
    push @p, $self->X($tense, "$p2_a!", "p2a", "${p2a_b}!", $p2a_b) if defined $p2a_b;
    push @p, $self->X($tense, "$p2_a!", "p2b", "${p2b_b}!", $p2b_b) if defined $p2b_b;
    $self->X(   $tense, "don't $p2_a!", "p2b_no", "$p2b_b nicht!", $p2b_b) if defined $p2b_b;
  }
  else
  {
    my($pp_s1_b, $pp_s2a_b, $pp_s2b_b, $pp_s3a_b, $pp_s3b_b, $pp_p1_b, $pp_p2a_b, $pp_p2b_b, $pp_p3a_b, $pp_p3b_b) = $self->GetPersonalPronouns($reflexive_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b);
    if ($self->GetOverride("$verb_b", "it only"))
    {
      push @s, $self->X($tense, "it $s3a_a", "s3a", "es $s3a_b", $s3a_b) ;
    }
    else
    {
      push @s, $self->X($tense, "I $s1_a", "s1", "$pp_s1_b$s1_b", $s1_b) if defined $s1_b;
      push @s, $self->X($tense, "you $p2_a", "p2a", "$pp_p2a_b\n$p2a_b", $p2a_b) if defined $p2a_b;
      push @s, $self->X($tense, "you $s2_a", "s2b", "$pp_s2b_b\n$s2b_b", $s2b_b) if defined $s2b_b;
      $self->X(         $tense, "you $s2_a", "s2a", "$pp_p2a_b$p2a_b", $p2a_b) if defined $p2a_b;
      push @s, $self->X($tense, "he $s3a_a", "s3a", "$pp_s3a_b$s3a_b", $s3a_b) if defined $s3a_b;
      push @s, $self->X($tense, "she $s3b_a", "s3b", "$pp_s3b_b$s3b_b", $s3b_b) if defined $s3b_b;

      push @p, $self->X($tense, "we $p1_a", "p1", "$pp_p1_b$p1_b", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "you $p2_a", "p2a", "$pp_p2a_b\n$p2a_b", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "you $p2_a", "p2b", "$pp_p2b_b\n$p2b_b", $p2b_b) if defined $p2b_b;
      push @p, $self->X($tense, "they $p3_a", "p3", "$pp_p3a_b$p3a_b", $p3a_b) if defined $p3a_b;
    }
  }
  return $self->ComposeVTOutput($tense, $hdr_inf_a, $verb_b, $doingVerbTable, \@s, \@p);
}

sub GetTenses
{
  return [ "present", "past", "preterite", "imperfect", "future", "conditional", "past_conditional", "future_perfect", "pluperfect", "k1", "k2", "past_k2", "imperative" ];
}

sub SoftenStem
{
  my($stem) = @_;
  $stem =~ s/(d|gn|t)$/${1}e/;
  return $stem;
}

sub PossibleSpellingChange
{
  my($self, $tense, $verb_b, $stem, $s) = @_;
  #print "PossibleSpellingChange($tense, $verb_b, $stem, $s)...";
  if ($tense eq "imperative")
  {
    if ($s =~ /(.*)st$/)	# s2b_b?
    {
      $s = $1;
      # bergen -> birg!, brechen -> brich!, schelten -> schild!, schwellen -> schwill!
      # BUT: l:achele!
      $s .= "e" if $verb_b =~ /eln$/ || $s !~ /(ch|rg|ld|l)$/;
      $s =~ s/://;		# no s2b_b-specific umlaut
      $stem = SoftenStem($stem) if $s !~ /^-e/;
    }
  }
  elsif ($stem =~ /([dt])$/)
  {
    if ($s =~ /^-(st|t)$/)
    {
      $stem .= "e";
    } 
  }
  elsif ($stem =~ /[^aeiou][io]BB$/)
  {
    if ($tense =~ /^(preterite)$/
    ||  $tense =~ /^(imperfect)$/)
    {
      if ($s =~ /^-(st)$/)
      {
	$stem =~ s/BB$/sse/;
      } 
      elsif ($s =~ /^-(en)$/)
      {
	$stem =~ s/BB$/ss/;
      } 
    } 
  }
  elsif ($stem =~ /BB$/)
  {
    if ($tense =~ /^(preterite)$/
    ||  $tense =~ /^(imperfect)$/)
    {
      if ($s =~ /^-(st)$/)
      {
	$stem .= "e";
      } 
    } 
  }
          
  $s = $self->Combine($stem, $s);
  $s =~ s/ee$/e/;		# don't overdo it
  $s =~ s/zst$/zt/;		# sitzen (du)
  $s =~ s/stst$/st/;		# bersten (du)
  $s =~ s/BBst$/BBt/;		# essen (du)
  $s =~ s/tt$/tet/;		# bersten (ihr)
  #print "...yielded $s\n";
  return $s;
}

sub Combine
{
  my($self, $stem, $possibleSuffix) = @_;
  my $s = $self->SUPER::Combine($stem, $possibleSuffix);
  nutil::Warn() if !defined $s;
  $s =~ s/_ss/_s/;		# don't allow sz-ligature to live next to an 's'
  return $s;
}

sub SplitItem
{
  my($self, $stem) = @_;
  die $stem unless defined $stem;
  if ($stem =~ m{(.*);(.*);(.*)})
  {
    return ($1, $2, $3);
  }
  if ($stem =~ m{(.*);(.*)})
  {
    return ($1, $1, $2);
  }
  return ($stem, $stem, $stem);
}
    
sub StrongEndingsAreAppropriate
{
  my($self, $verb_b) = @_;
           
  my $x = $self->GetOverride($verb_b, "imperfect_strong");
  $x = 0 unless defined $x;
  return $x;
}


sub AddEndings
{
  my($self, $verb_b, $stem_b, $tense) = @_;
          
  #print "AddEndings($verb_b, $stem_b, $tense)\n";
  my ($stem_s12, $stem_sp3, $stem_p12) = $self->SplitItem($stem_b);
  if ($tense eq "preterite"
  ||  $tense eq "imperfect")
  {
    if ($self->StrongEndingsAreAppropriate($verb_b))
    {
      return (
      "${stem_b}",
      $self->PossibleSpellingChange($tense, $verb_b, $stem_b, "-st"),
      "${stem_b}",
      "${stem_b}en",
      $self->PossibleSpellingChange($tense, $verb_b, $stem_b, "-t"),
      );
    }
    else
    {
      $stem_b = SoftenStem($stem_b) unless ($verb_b =~ /^(haben)$/) || defined $self->GetOverride($verb_b, "vowels");
      return (
      "${stem_b}te",
      "${stem_b}test",
      "${stem_b}te",
      "${stem_b}ten",
      "${stem_b}tet",
      );
    }
  } 
  elsif (($tense eq "k2")
  ||     ($tense eq "k1"))
  {
    if ($self->StrongEndingsAreAppropriate($verb_b)
    ||  ($tense eq "k1"))
    {
      return (
      "${stem_b}e",
      "${stem_b}est",
      "${stem_b}e",
      "${stem_b}en",
      "${stem_b}et",
      );
    }
    else
    {
      return (
      "${stem_b}te",
      "${stem_b}test",
      "${stem_b}te",
      "${stem_b}ten",
      "${stem_b}tet",
      );
    }
  } 
  else
  {
    die $tense;
  }
}

sub ResolveEndings
{
  my($self, $stem_b, $inf_b, $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $tense) = @_;
  my $verb_b = "$stem_b$inf_b";
          			
  my $conjugation = $self->GetOverrideList($verb_b, $tense);
  if (defined $conjugation)
  {
    #print "German_grammar::ResolveEndings($verb_b, $tense): found overridden con\n";
    #Ndmp::Ah("ResolveEndings fetched overridden tense for ($verb_b, $tense)", $conjugation);
    return @$conjugation;
  }
  #print "German_grammar::ResolveEndings($verb_b, $tense): no overridden con\n";
      
  my $conjugationStem = $self->GetOverride("$verb_b", "$tense");
      					
  if (defined $conjugationStem)
  {
    #print "ResolveEndings: taking $conjugationStem from Override\n";
  }
  else
  {
    $conjugationStem = $self->GetStem($verb_b, $tense);
  }
  ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b) = $self->AddEndings($verb_b, $conjugationStem, $tense);
  #print "AddEndings returned $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b \n"; 
  return ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b);
}

sub MakeRecursive
{
  my($self, $verb) = @_;
  return "sich $verb";
}

sub StripReflexivity
{
  my($self, $verb_b) = @_;
  $verb_b =~ s/^sich //;
  return $verb_b;
}

sub SetReflexivity_b
{
  my($self, $verb_b, $argsRef) = @_;
  #Ndmp::Ah("SetReflexivity_b", $argsRef);
  my $reflexive_b = '';
  if ($verb_b =~ /^(sich )/)
  {
    $reflexive_b = $verb_b;
  }
  $argsRef->[18] = $reflexive_b;
  return $reflexive_b;
}

sub EqVerbDerivePatterns 
{
  my($self, $verb, $paradigmVerb) = @_;
  die $verb unless defined $paradigmVerb;
  
  $verb = $2 if $verb =~ /^(sich )(.*)/;
  $verb = $1 if $verb =~ /(.*)2$/;
  if ($verb =~ /(\S+)( .*)$/)
  {
    $verb = $1;
  } 
        
  if ($verb =~ /sich (.*)$/)
  {
    $verb = $1;
  }
  my $a1;
  my $b1;
  my $b2 = undef;
  my $a2 = undef;
      
  if ($verb =~ /(.*)$paradigmVerb$/)
  {
    my $commonPrefix = $1;
            
    die $paradigmVerb unless $paradigmVerb =~ /^(.)/;
    my $paradigmVerbLetter1 = $1;
                
    $b1 =  "^$paradigmVerbLetter1";
    $a1 =  "$commonPrefix$paradigmVerbLetter1";
  }
  elsif ($paradigmVerb =~ /^ge(.*)/
  && $verb =~ /(.*)$1$/)
  {
    my $commonPrefix = $1;
            
    die $paradigmVerb unless $paradigmVerb =~ /^ge(.)/;
    my $paradigmVerbLetter1 = $1;
                
    $b1 =  "^ge$paradigmVerbLetter1";
    $a1 =  "$commonPrefix$paradigmVerbLetter1";
  }
  elsif ($paradigmVerb =~ m{^(bergen|heben|nehmen|schwellen|sehen)$})
  {
    die $verb unless $verb =~ /(.*)e(.*)en$/;
    $a1 = $1;
    $a2 = $2;
    die $verb unless $paradigmVerb =~ /(.*)e([^aeiou]*)en$/;
    $b1 = "^$1";
    $b2 = "$2";
  }
  elsif ($paradigmVerb =~ m{^(raten|fahren)$})
  {
    die $verb unless $verb =~ /(.*)a([^aeiou]*)en$/;
    $a1 = $1;
    $a2 = $2;
    die $verb unless $paradigmVerb =~ /(.*)a([^aeiou]*)en$/;
    $b1 = "^$1";
    $b2 = "$2";
  }
  elsif ($paradigmVerb =~ m{^(befehlen|brechen)$})
  {
    die $verb unless $verb =~ /(.*)......$/;
    $a1 = $1;
    die $verb unless $paradigmVerb =~ /(.*)......$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{^(messen|singen)$})
  {
    die $verb unless $verb =~ /(.*).....$/;
    $a1 = $1;
    die $verb unless $paradigmVerb =~ /(.*).....$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{^(gehen|passen)$})
  {
    die $verb unless $verb =~ /(.*)....$/;
    $a1 = $1;
    die $verb unless $paradigmVerb =~ /(.*)....$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{^(l:acheln)$})
  {
    die $verb unless $verb =~ /(.*)...$/;
    $a1 = $1;
    die $verb unless $paradigmVerb =~ /(.*)...$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{^(kennen)$})
  {
    die $verb unless $verb =~ /(.*)e(..)en$/;
    $a1 = $1;
    $a2 = $2;
    die $verb unless $paradigmVerb =~ /^(.*)e(..)en$/;
    $b1 = "^$1";
    $b2 = "$2";
  }
  else
  {
    die $verb unless $verb =~ /(.*)..$/;
    $a1 = $1;
    die $verb unless $paradigmVerb =~ /(.*)..$/;
    $b1 = "^$1";
  }
        
  if ((defined $b2) && ($b2 ne $a2))
  {
    return ($b1, $a1, $b2, $a2);
  } 
  else
  {
    return ($b1, $a1);
  } 
}

sub IsStemChangingVerb
{
  my($self, $v) = @_;
  my $o = $self->GetOverride($v, "k1");
  my $rc;
  if (!defined $o)
  {
    $rc = 0;
  }
  else
  {
    $rc = ($o =~ /;/);
  }
  #print "IsStemChangingVerb($v): $rc\n" if $rc;
  return $rc;
}
  
sub VerbsOnlyDifferInReflexivity
{
  my($self, $verb1, $verb2) = @_;
  $verb1 = $1 if $verb1 =~ /sich (.*)$/;
  $verb2 = $1 if $verb2 =~ /sich (.*)$/;
  return $verb1 eq $verb2;
}

sub GetAuxiliaryVerbs
{
  my($self) = @_;
  return ( "haben", "sein" );
}

sub VowelChangingVerb
{
  my($self, $verb_b, $verb_a, $vowelsSetting, $pastParticiple, $paradigmVerb) = @_;
  if (!defined $paradigmVerb)
  {
    if ($verb_b =~ /den$/)
    {
      $paradigmVerb = 'atmen';
    }
    else
    {
      $paradigmVerb = 'kaufen';
    }
  }
  $self->EqVerb($verb_b, $verb_a, $paradigmVerb, 1);
  $self->Override($verb_b, 'vowels', $vowelsSetting);
  if (defined $pastParticiple)
  {
    $self->Override($verb_b, 'past participle', $pastParticiple);
  }
  return undef;
}


sub GetOverrideList
{
  my($self, $verb, $tense) = @_;
  if ($tense =~ /^(preterite)$/)
  {
    $tense =~ s/preterite/imperfect/;
  }
  return $self->SUPER::GetOverrideList($verb, $tense);
}

sub GetOverride
{
  my($self, $verb, $what) = @_;
  if ($what =~ /^(preterite)$/)
  {
    $what =~ s/preterite/imperfect/;
  }
  return $self->SUPER::GetOverride($verb, $what);
}

sub Override
{
  my($self, $verb_b, $what, $val, $onlyIfNotYetSet) = @_;
  $self->SUPER::Override($verb_b, $what, $val, $onlyIfNotYetSet);
  if ($what eq "unused conditional")
  {
    # My assumption here is that if the conditional tense is being redirected (presumably for
    # a verb in the RequiresK2 category), then we will want to redirect the past_conditional tense also:
    $self->SUPER::Override($verb_b, "unused past_conditional", $val, $onlyIfNotYetSet);
  }
  elsif (($what eq "vowels") && ($val ne "t"))
  {
    my($infVowel, $imperfectStemVowel, $pastParticipleVowel, $konjunctivIIVowel, $imperfect_strongSetting) = ParseStrongSetting($verb_b, $val);

    $self->SUPER::Override($verb_b, 'imperfect_strong', $imperfect_strongSetting, 1);

    my $imperfectStem = $verb_b;
    
    $imperfectStem =~ s/$infVowel([^aeiou]*)(e?)n$/$imperfectStemVowel$1/;
    $self->SUPER::Override($verb_b, "imperfect", $imperfectStem, 1);

    my $pastParticiple = $verb_b;
    $pastParticiple =~ s/$infVowel([^aeiou]*e?n)/$pastParticipleVowel$1/;
    $pastParticiple =~ s/(.*)\..*/$1/;
    if ($verb_b !~ /^(ver|ge|er|be.*[aeiou].*)/)
    {
      #print "ShouldPrependGeToPastParticiple would have vetoed $verb_b\n" unless ShouldPrependGeToPastParticiple( $verb_b);
      $pastParticiple = "ge" . $pastParticiple;
    } 
    else
    {
      #print "ShouldPrependGeToPastParticiple would have allowed $verb_b\n" if ShouldPrependGeToPastParticiple( $verb_b);
    }

    $self->SUPER::Override($verb_b, "past participle", $pastParticiple, 1);
                    
    my $pastSubjunctive;
    if (!defined $konjunctivIIVowel)
    {
      $pastSubjunctive = $imperfectStem;
    }
    elsif ($konjunctivIIVowel eq "-")
    {
      $pastSubjunctive = undef;
    }
    else
    {
      $pastSubjunctive = $verb_b; 
      $pastSubjunctive =~ s/$infVowel([^aeiou]*)(e?)n$/$konjunctivIIVowel$1/;
    }
    
    if (defined $pastSubjunctive)
    {
      $self->SUPER::Override($verb_b, "k2", $pastSubjunctive, 1);
    } 
    else
    {
      $self->SUPER::Override($verb_b, "unused k2",      "conditional");
      $self->SUPER::Override($verb_b, "unused past_k2", "past_conditional");
    } 
    #print "German_grammar::Override($verb_b, $what, $val): imperfect=$imperfectStem, pp=$pastParticiple, pastSubjunctive=$pastSubjunctive\n";
  }
  return undef;
}

sub ParseStrongSetting
{
  my($verb_b, $vowelsSetting) = @_;
  my($infVowel, $imperfectStemSetting, $pastParticipleVowel, $konjunctivIIVowel) = split(/;/, $vowelsSetting);
  warn "no $infVowel in $verb_b" unless $verb_b =~ /$infVowel/;

  die $vowelsSetting unless defined $pastParticipleVowel;
  my $imperfect_strongSetting = 1;
  my $imperfectStemVowel;
  if ($imperfectStemSetting =~ /(.*)-te$/)
  {
    $imperfectStemVowel = $1;
    $imperfect_strongSetting = 0;
  }
  else
  {
    $imperfectStemVowel = $imperfectStemSetting;
  }

  if (!defined $konjunctivIIVowel)
  {
    $konjunctivIIVowel = $imperfectStemVowel;
    $konjunctivIIVowel =~ s/([aou])/:$1/;
  }
  #print "German_grammar::ParseStrongSetting($verb_b, $vowelsSetting): $infVowel, $imperfectStemVowel, $pastParticipleVowel, $konjunctivIIVowel, $imperfect_strongSetting\n";
  return ($infVowel, $imperfectStemVowel, $pastParticipleVowel, $konjunctivIIVowel, $imperfect_strongSetting);
}

sub TruncateExtraneousTrailingConsonants
{
  my($s1, $s2) = @_;

  if ($s1 =~ /(.*[aeiou])([^aeiou]+)$/)
  {
    my $s1_withoutTrailingConsonants1 = $1;
    my $trailingConsonants1 = $2;
    if ($s2 =~ /(.*[aeiou])([^aeiou]+)$/)
    {
      my $s2_withoutTrailingConsonants2 = $1;
      my $trailingConsonants2 = $2;
      if ($trailingConsonants1 eq $trailingConsonants2)
      {
	$s1 = $s1_withoutTrailingConsonants1;
	$s2 = $s2_withoutTrailingConsonants2;
      }
    }
  }
  return ($s1, $s2);
}


sub DescribeStemVowelChange
{
  my($self, $fromVowel, $toVowel, $context) = @_;

  #	print "German_grammar::DescribeStemVowelChange($fromVowel, $toVowel, $context):";
  
  ($fromVowel, $toVowel) = TruncateExtraneousTrailingConsonants($fromVowel, $toVowel);
  
  #	print " $fromVowel/$toVowel\n";
  
  my $nothingButVowels = (($fromVowel =~ /^[aeiou]+$/) && ($toVowel =~ /^[aeiou]+$/));

  return "with a stem "
  . ($nothingButVowels ? "vowel " : "")
  . "change from <font color=red><i>$fromVowel</i></font> to <font color=red><i>$toVowel</i></font> in the " 
  . $context;
}


sub GetStemChange
{
  my($self, $infVowel, $otherVowel, $context) = @_;
        
  my $s;
  if ($otherVowel eq "-")
  {
    #$s = "which is never used in the " . $context;    # it's awkward to report this in other tenses
    $s = "";
  }
  else
  {
    #print "German_grammar::GetStemChange($infVowel, $otherVowel, $context)\n";
    if ($otherVowel =~ /(.+)\./)	# used to override to the end a past participle, e.g., "andt." for wenden
    {
      $otherVowel = $1;			# skip the trailing stuff for the purposes of this summary
    }

    if ($infVowel ne $otherVowel)
    {
      $s = $self->DescribeStemVowelChange($infVowel, $otherVowel, $context);
    }
    else
    {
      $s = "";
    }
  }
  return $s;
}

sub GetS3Change
{
  my($self, $verb_b) = @_;
  my $val = undef;
  my $argsRef = $self->GetVerbArgs($verb_b);
  my $stem_b = $self->VerbArgs_get_stem_b($argsRef);
  my $infVowel;
  if ($verb_b =~ /^$stem_b(:?[aeiou]+)/)
  {
    $infVowel = $1;
  }
  else
  {
    return "";
  }
  my $s3_b   = $self->VerbArgs_get_s3_b($argsRef);
          
  if (!defined $s3_b)
  {
    Ndmp::Ah("bad s3_b", $argsRef);
    die "bad s3_b"; 
  } 
  my $s3_vowel;
  if ($s3_b =~ /^-(:?[aeiou]+)/)
  {
    $s3_vowel = $1;
  }
  else
  {
    return "";
  } 
  if ($infVowel eq $s3_vowel)
  {
    return "";
  }
  my $context = "third person singular of the " . $self->GetTenseLink("present");
  my $s3VowelChange = $self->DescribeStemVowelChange($infVowel, $s3_vowel, $context);
  return $s3VowelChange;
}


sub GetStemChanges
{
  my($self, $verb_b) = @_;
    
  if ($verb_b =~ /^sich (.*)/)
  {
    $verb_b = $1; 
  }
  
  my $vowelsSetting = $self->GetOverride($verb_b, "vowels");
          
  if (!defined $vowelsSetting)
  {
    return (0, "", "", "", 1, "");
  }
  my($infVowel, $imperfectStemVowel, $pastParticipleVowel, $k2Vowel, $imperfect_strongSetting) = ParseStrongSetting($verb_b, $vowelsSetting);
                                                                                    
  my $imperfectVowelChange = $self->GetStemChange($infVowel, $imperfectStemVowel, $self->GetTenseLink("imperfect"));

  my $pastParticipleVowelChange = $self->GetStemChange($infVowel, $pastParticipleVowel, "past participle");
  
  my $k2VowelChange = $self->GetStemChange($infVowel, $k2Vowel, $self->GetTenseLink("k2"));
      
  my $s3VowelChange = $self->GetS3Change($verb_b);
  
  return (1, $imperfectVowelChange, $pastParticipleVowelChange, $k2VowelChange, $imperfect_strongSetting, $s3VowelChange);
}

sub MakePointWithParentheticalAdditions
{
  my($self, $mainPoint, @parentheticalAdditions) = @_;
  
  my $s = $self->SUPER::MakePointWithParentheticalAdditions($mainPoint, @parentheticalAdditions);
  
  my $phrase_i_dont_want_endlessly_repeated = "with a stem vowel change ";
  $s =~ s/$phrase_i_dont_want_endlessly_repeated/__save_first_one__/;
  $s =~ s/$phrase_i_dont_want_endlessly_repeated//g;
  $s =~ s/__save_first_one__/$phrase_i_dont_want_endlessly_repeated/;
  return $s;
}

sub DescribeStrongVerbTraits
{
  my($self, $verb_b, @traits) = @_;
  # first figure out how many non-null traits there are:
  my @nonNullTraits = ();
  for (my $j = 0; $j < scalar(@traits); $j++)
  {
    my $trait = $traits[$j];
    if ($trait)
    {
      push @nonNullTraits, $trait;
    }
  }
  my $s = "";
  if (scalar(@nonNullTraits) == 0)
  {
    $s = " with, however, no stem vowel changes for any tense.";
  }
  elsif (scalar(@nonNullTraits) == 1)
  {
    $s .= " " . $nonNullTraits[0] . ".";
  }
  else
  {
    $s .= ": ";
    for (my $j = 0; $j < scalar(@nonNullTraits); $j++)
    {
      $s .= $self->AddBullettedPoint($nonNullTraits[$j]);
    }
  }
  #print "German_grammar::DescribeStrongVerbTraits($traits[0], $traits[1], $traits[2], $traits[3]): $s\n";
  return $s;
}

sub MakeAdditionalNotes
{
  my($self, $context, $verb_b) = @_;
  #print "German_grammar::MakeAdditionalNotes($context, $verb_b)\n";
  die $context unless defined $verb_b;
  my $add = "";

  my($isStrongVerb, $imperfectVowelChange, $pastParticipleVowelChange, $k2VowelChange, $imperfect_strongSetting, $s3VowelChange) = $self->GetStemChanges($verb_b);
  if ($isStrongVerb)
  {
    my $strongWeakUrl = "German.html#=Verbs=strong_and_weak";
    $self->VerifyURL($strongWeakUrl);
    $add .= ",$verb_b is a " . $self->MakeLink(",strong verb", $strongWeakUrl) . "";

    my $paradigmVerb = $self->GetVerbThatThisOneIsPatternedAfter($verb_b);
    if (defined $paradigmVerb)
    {
      my $url = $self->GetVerbTableLink($paradigmVerb, "$paradigmVerb", 0);
      if (defined $url)
      {
	$add .= " conjugated like <i>$url</i>";
      }
    }
    $add .= $self->DescribeStrongVerbTraits($verb_b, $imperfectVowelChange, $pastParticipleVowelChange, $s3VowelChange, $k2VowelChange);
    #print "German_grammar::MakeAdditionalNotes($context, $verb_b): strong\n";
  }

  if (IsModalAuxiliary($verb_b))
  {
    my $url = "German.html#=Verbs=modal_auxiliary";
    $self->VerifyURL($url);
    $add .= $self->{"noteDivider"} . "<i>$verb_b</i> is a " . $self->MakeLink("modal auxiliary verb", $url) . ".";
    #print "German_grammar::MakeAdditionalNotes($context, $verb_b): aux\n";
  }
  if ($context eq "k2")
  {
    if (RequiresK2($verb_b))
    {
      $add .= $self->{"noteDivider"} if $add;
      $add .= "Although normally\nk2\n is interchangeable with the\nconditional composed with ,w:urde, German speakers never use ,w:urde with ,$verb_b.";
    }
  }
  elsif ($context eq "imperative")
  {
    my $pronounCode = tdb::Get($self->GetCurrentId(), 'pronoun');
    if (defined $pronounCode
    && $pronounCode =~ /s2b/
    && $self->Get__currentToken() !~ /st$/)
    {
      $add .= $self->{"noteDivider"} if $add;
      $add .= "The second person imperative familiar form drops the trailing <i>st</i>.";
    }
  }
  if ($isStrongVerb && ($context =~ /^(preterite|imperfect)$/) && !$imperfect_strongSetting)
  {
    $add .= $self->{"noteDivider"} . "Despite being a strong verb, ,$verb_b takes weak endings (,-te, ,-test, etc.) in this tense.";
  }
  
  #print "German_grammar::MakeAdditionalNotes($context, $verb_b): $isStrongVerb/$imperfectVowelChange, $pastParticipleVowelChange, $k2VowelChange: $add\n";
  
  return $add;
}

sub OnEndOfGrammarGeneration
{
  my($self) = @_;
  $self->UnAutoLink("sein");	# verb gets confused with possessive pronoun
  $self->OverrideVerbTableLookup("w:urde", ";conditional.werden;");
  $self->OverrideVerbTableLookup("w:urdest", ";conditional.werden;");
  $self->OverrideVerbTableLookup("w:urden", ";conditional.werden;");
  $self->OverrideVerbTableLookup("w:urdet", ";conditional.werden;");
  $self->SUPER::OnEndOfGrammarGeneration();
}  

sub SeparatedFormOf
{
  my($self, $context, $verb_b, $tokens, $note) = @_;
  return $self->RawFormOf($context, $verb_b, "<i>$tokens</i> constitutes a\nseparated verb\n making up ", $note);
}

sub IsACompoundPastTense
{
  my($self, $context) = @_;
  my $val;
  if ($context =~ /^(k2)$/)
  {
    $val = 0;
  }
  $val = ($context =~ /(past|future_perfect)/);
  print "German_grammar::IsACompoundPastTense($context): $val\n" if $__MassageAndFootnoteTrace;
  return $val;
}

sub AdjustCase
{
  my($self, $key, $other, $verb_b) = @_;
  my $newCase;
  my $verb_a = $self->Get_verb_a($verb_b);
  
  my $dataFile = "verb_" .  $verb_a;
  $dataFile =~ s/ /_/g;
    
  if ($self->AddendIsSubject("$dataFile.0"))
  {
    $newCase = 'n';
  }
  else
  {
    $newCase = 'a';
    $other =~ s/>(.)n>/>$1$newCase>/g;
  } 
  #print "German_grammar::AdjustCase($key, $other, $verb_b): $other\n";
  return $other;
}

sub ContainsInfinitivePhrase
{
  my($self, $s) = @_;
  my $infinitivePhrase = $self->SUPER::ContainsInfinitivePhrase($s);
  if ($infinitivePhrase && $s =~ /zu $infinitivePhrase\b/)
  {
    $infinitivePhrase = "zu $infinitivePhrase";
  }
  return $infinitivePhrase;
}

sub InsertNicht
{
  my($self, $key, $addendKey, $other, $addend, $separableVerbPrefix, $tense, $placeToInsertAddend) = @_;
  my $note = undef;
  my $insertBeforeAddend = 0;
  my $insertAfterAddend = 0;

  nutil::Warn() if !defined $other;
  if ($addendKey =~ /(vocab_(days|months_and_seasons|time))/)
  {
    $insertBeforeAddend = 1;
    $note = "nicht_time";
  }
  elsif ($placeToInsertAddend != $self->{"NO_OP"})
  {
    $insertAfterAddend = 1;
    $note = "nicht_past_participle";
  }
  elsif ($self->ContainsInfinitivePhrase($addend))
  {
    $insertBeforeAddend = 1;
    $note = "nicht_infinitive";
  }
  elsif ($other =~ s/ ({}.*{)?(am|an|im|in|nach|zu|zum|zur) /" nicht " . (defined $1 ? $1 : "") . "$2 "/e)
  {
    # /e above was to avoid 'An undefined value' warning
    $note = "nicht_preposition";
  }
  elsif ($other =~ />L>/	# predicate adjective?
  || $other !~ /{/)		# no noun, meaning that it must be a predicate adverb?
  {
    $insertBeforeAddend = 1;
    $note = "nicht_predicate";
  }
  elsif (defined $separableVerbPrefix && $other =~ /$separableVerbPrefix.$/)
  {
    $other =~ s/$separableVerbPrefix(.)$/nicht $separableVerbPrefix$1/;
    $note = "nicht_separable";
  }
  else
  {
    $other =~ s/(.)$/ nicht$1/;
  }

  if ($insertBeforeAddend)
  {
    if ($addend =~ /[{}]/)
    {
      $other =~ s/{/nicht {/;	# }}
    }
    else
    {
      $other =~ s/$addend/nicht $addend/;
    }
  }
  elsif ($insertAfterAddend)
  {
    if ($addend =~ /[{}]/)
    {
      $other =~ s/(}[^{}]+)$/$1 nicht/;
    }
    else
    {
      $other =~ s/$addend/$addend nich/;
    }
  }

  if (defined $note)
  {
    tdb::Set($key, $self->MakeTokenNoteKey("nicht", "2"), $note);
  }
  #print "German_grammar::InsertNicht($key, $addendKey, $other, $addend, " . nutil::ToString($separableVerbPrefix) . "): " . nutil::ToString($note) . "\n";
  return $other;
}

sub CompositeNoun
{
  my($self, $noun, $nounSuffix) = @_;

  my $newNoun  = $noun . $nounSuffix;

  if (!defined $self->HashGet("nounGenderHash", $newNoun))
  {
    my $baseNoun       = grammar::Capitalize($nounSuffix);
    my $gender         = $self->HashGet("nounGenderHash", $baseNoun);
    my $plural         = $self->HashGet("pluralHash",     $baseNoun);
    my $genitiveSuffix = $self->HashGet("genitiveSuffixHash",     $baseNoun);

    $self->Noun($newNoun, $gender, $plural, $genitiveSuffix);
    #print "German_grammar::CompositeNoun($noun, $nounSuffix): Noun($newNoun, $gender, $plural, " . nutil::ToString($genitiveSuffix) . ")\n";
  }
}

sub PossiblyAddSuffix
{
  my($self, $key, $adjustedAddend) = @_;
  my $addend_nounSuffix = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), "German/addend_nounSuffix");
  if (defined $addend_nounSuffix)
  {
    if ($adjustedAddend =~ /([^{} >]+)>([^>]+)>}$/)
    {
      my $oldNoun = $1;
      my $newNoun = $oldNoun . $addend_nounSuffix;
      $self->CompositeNoun($oldNoun, $addend_nounSuffix);
      $adjustedAddend =~ s/$oldNoun>/$newNoun>/;
    }
    else
    {
      warn "$key: could not resolve $adjustedAddend";
    }
  }
  return $adjustedAddend;
}

sub PossiblySubtractZu
{
  my($self, $tense, $verb_b, $key, $addendKey, $parmAdjustedAddend) = @_;
  my $adjustedAddend = $parmAdjustedAddend;

  # retain "zu" for future_perfect, past_conditional?  Add this condition:
  # ($tense =~ /^(present|past|preterite|imperfect|future|conditional|pluperfect|k1|k2)$/)
  
  if ($adjustedAddend =~ /^zu (.*)/)
  {
    my $inf = $1;
    my $infNoteKey = "suppress_German_note#$inf;;German";
    my $suppressSetting = tdb::Get($addendKey, $infNoteKey);
    if (IsModalAuxiliary($verb_b)
    && defined $suppressSetting
    && ($suppressSetting eq 'Infinitive'))
    {
      $adjustedAddend = $inf;
      tdb::Set($key, $self->MakeTokenNoteKey($inf, "2"), 'no_zu_after_modals');
    }
  }
  #print "German_grammar::PossiblySubtractZu($verb_b, $key, $addendKey, $parmAdjustedAddend): $adjustedAddend\n";
  return $adjustedAddend;
}

sub InsertAddend
{
  my($self, $key, $other, $adjustedAddend, $tense, $verb_b, $addendKey) = @_;

  ##print "German_grammar::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey)\n";

  $adjustedAddend = $self->PossiblyAddSuffix($key, $adjustedAddend);
  $adjustedAddend = $self->PossiblySubtractZu($tense, $verb_b, $key, $addendKey, $adjustedAddend);

  my $trailingString = $self->{"trailingString"};
  if (defined $trailingString)
  {
    $adjustedAddend = "$adjustedAddend $trailingString";

    die "don't see \"$trailingString\" in \"$other\"" unless $other =~ /$trailingString\b/;

    $other =~ s/$trailingString\b//;
  }

  my $containedNicht = ($other =~ s/ nicht(.)$/$1/);
  #print "German_grammar::InsertAddend($other): $containedNicht\n";

  my $placeToInsertAddend = $self->{"NO_OP"};

  if ($adjustedAddend =~ /^(es |daBB)/)
  {
    # the 'es' is considered to start a separate phrase, which should come after
    # the rest of the translation.  Just use the default SUPER:
    $other = $self->SUPER::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey);
  }
  elsif ($tense =~ /^(k1)$/)
  {
    if ($self->AddendIsSubject($key))
    {
      $placeToInsertAddend = 0; # insert et end
    }
    else
    {
      $placeToInsertAddend = 1; # insert behind verb form
    }
    $other = $self->SUPER::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend);
  }
  elsif ($tense =~ /^(past|future|pluperfect)$/
  || ($tense eq "conditional" && !RequiresK2($verb_b))		# normal (ie, w:urde) conditional
  || ($tense eq "past_conditional" && RequiresK2($verb_b)))	# past_k2
  {
    if ($adjustedAddend =~ /^es\.\.\. (.*)/)
    {
      my $adjustedAddendFollowingEs = $1;
      # insert pp between 'es' and rest, e.g.,
      # 'German' => 'Sie haben es [vorbezogen] fr:uher auszugehen.',
      $other =~ s/(\S+)([\.!\?])$/es $1 $adjustedAddendFollowingEs$2/;
    }
    else
    {
      $placeToInsertAddend = 1; # insert behind pp
      $other = $self->SUPER::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend);
    }
  }
  elsif ($tense =~ /^(future_perfect)$/
  || ($tense eq "past_conditional" && !RequiresK2($verb_b)))	# normal (ie, w:urde) past_conditional
  {
    if ($adjustedAddend =~ /^es\.\.\. (.*)/)
    {
      my $adjustedAddendFollowingEs = $1;
      # insert [pp . 'haben'] between 'es' and rest, e.g.,
      # 'German' => 'Ich werde es [vorgezogen haben] mehr geld zu verdienen.',
      $other =~ s/(\S+ \S+)([\.!\?])$/es $1 $adjustedAddendFollowingEs$2/;
    }
    else
    {
      $placeToInsertAddend = 2; # insert behind pp and aux. (e.g., 'sein' or 'haben')
      $other = $self->SUPER::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend);
    }
  }
  else
  {
    my $adjustedAddendFollowingEs = "";
    if ($adjustedAddend =~ /^es\.\.\.( .*)/)
    {
      $adjustedAddendFollowingEs = $1;
      $adjustedAddend =~ s/^es.*/es/;
    }
    $other = $self->SUPER::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey);
    my $separableVerbPrefix = $self->{"separableVerbPrefix"};
    if (defined $separableVerbPrefix)
    {
      $other =~ s/\b($separableVerbPrefix) (.*)([\.!\?])/$2 $1$3/;	# move seperated prefix to eoln
    }

    $other =~ s/(.)$/$adjustedAddendFollowingEs$1/ if $adjustedAddendFollowingEs;
  }
  if ($containedNicht)
  {
    $other = $self->InsertNicht($key, $addendKey, $other, $adjustedAddend, $self->{"separableVerbPrefix"}, $tense, $placeToInsertAddend);
  }
  #print "German_grammar::InsertAddend($key): $other, $adjustedAddend, $addendKey)\n";
  $other = $self->AdjustCase($key, $other, $verb_b);
  ##print "German_grammar::InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey): $other\n";
  return $other;
}

sub ShouldPrependGeToPastParticiple
{
  my($verb_b) = @_;
  return (($verb_b !~ /ieren$/) && ($verb_b !~ /^(be|ein|emp|ent|er|ge|:uber|unter|ver|wieder)[^aeiou]*[aeiou]+[^aeiou]+[aeiou]+/));	# not beten, etc.
}

sub LooksLikeRecursiveUse
{
  my($self, $rawToken, $s) = @_;
  
  my $val = 0;
  if ($rawToken =~ /n$/)
  {
    if ($s =~ /wir $rawToken uns\b/i
    ||  $s =~ /sie $rawToken sich\b/i
    ||  $s =~ /$rawToken Sie sich\b.*!/i)
    {
      $val = 1;
    }
  }
  else
  {
    if ($s =~ /sie $rawToken sich\b/
    ||  $s =~ /er $rawToken sich\b/i
    ||  $s =~ /du $rawToken dich\b/i
    ||  $s =~ /ich $rawToken mich\b/i
    ||  $s =~ /$rawToken (dich|euch)\b.*!/i)
    {
      $val = 1;
    }
  }
  #print "German_grammar::LooksLikeRecursiveUse($rawToken, $s): $val\n";
  return $val;
}

sub PruneVerbsByRecursiveness
{
  my($self, $vtlVal, $pruneRecursiveVerbs) = @_;
  for (my $j = 0;; $j++)
  {
    my $verb = $vtlVal->Get($j, 1);
    last unless defined $verb;
    my $isRecursive = $self->IsRecursive($verb);
    if (( $pruneRecursiveVerbs && !$isRecursive)
    ||  (!$pruneRecursiveVerbs &&  $isRecursive))
    {
      # ok, we know we'll be left w/ at least one possibility.  Go ahead and prune.
      # [LooksLikeRecursiveUse is unreliable for German, so I don't want to abort the VtlLookup
      # on its say-so alone.]
      $self->SUPER::PruneVerbsByRecursiveness($vtlVal, $pruneRecursiveVerbs);
      return;
    }
  }
}

sub IsRecursive
{
  my($self, $verb) = @_;
  my $val = ($verb =~ /^sich /);
  #print "German_grammar::IsRecursive($verb): $val\n";
  return $val;
}

sub CookTense
{
  my($self, $tense, $precedingWord) = @_;
  if ($tense eq "past")
  {
    $tense = "perfect";
  }
  elsif ($tense eq "preterite")
  {
    $tense = "imperfect";
  }
  elsif ($tense eq "k1")
  {
    $tense = "<i>Konjunctiv I</i>";
  }
  elsif ($tense eq "k2")
  {
    $tense = "<i>Konjunctiv II</i>";
  }
  elsif ($tense eq "past_k2")
  {
    $tense = "Pluperfect <i>Konjunctiv II</i>";
  }
  return $self->SUPER::CookTense($tense, $precedingWord);
}

sub UpdateVtlOnly
{
  my($self, $tense) = @_;
  return 1 if $tense eq "imperfect";
  return 0;
}

sub Init
{
  my($self, $lang) = @_;
  $self->{"s2a_possessive"} = "Ihr";
  $self->{"s2b_possessive"} = "dein";
  $self->{"p2a_possessive"} = "Ihr";
  $self->{"p2b_possessive"} = "euer";
  $self->{"regular_verbs_regexp"} = "(kaufen)";
  $self->SUPER::Init($lang);

  $self->HashPut("validGrammarURLs", "German.html#=Verbs=pastFlavors", 1);	# stop complaints about the below
  
  $self->SaveNote('whyPerfectInsteadOfImperfect', 'It would not have been absolutely wrong to use the past tense here instead of the past perfect.', 'Verbs=pastFlavors', 'the past vs. the past perfect tenses');
  $self->SaveNote('whyImperfectInsteadOfPerfect', 'It would not have been absolutely wrong to use the past perfect tense here instead of the past.', 'Verbs=pastFlavors', 'the past vs. the past perfect tenses');
}

sub De
{
  die "unused";
  my($self, $nominativeDeterminer, $why) = @_;
  my $adjustedDeterminer = $self->Get__currentToken();
  my $case = undef;
  if ($adjustedDeterminer =~ /den/ && $nominativeDeterminer =~ /der/)
  {
    $case = "accusative";
  }
  elsif (($adjustedDeterminer =~ /der/ && $nominativeDeterminer =~ /die/)
  ||     ($adjustedDeterminer =~ /dem/))
  {
    $case = "dative";
  }
  elsif ($adjustedDeterminer =~ /den/)
  {
    $case = "plural dative";
  }
  elsif ($adjustedDeterminer =~ /des/)
  {
    $case = "genitive";
  }

  my $url = "German.html#=Articles";
  $self->VerifyURL($url);

  my $s = ",$nominativeDeterminer becomes ,$adjustedDeterminer in the\n$case\n";
  $s .= "which is required because $why " if defined $why;
  $s .= "(cf. " . $self->MakeLink("German articles", $url) . ").";
  return $s;
}

sub MassageAndFootnoteInitData
{
  my($self) = @_;
  print "German_grammar::MassageAndFootnoteInitData()\n" if $__MassageAndFootnoteTrace;
  $self->ClearMostRecentVerbNoted();
  $__compoundPastParticiple = undef;
  $__compoundPastParticipleVerb = undef;
  $__waitingInfinitive = undef;
  $__waitingPastParticiple = undef;
  $__waitingPastParticipleVerb = undef;
  $__inMainClause = 1;
}

sub IsSeparatedVerbPrefix
{
  my($self, $possibleVerbPrefix) = @_;

  if ($possibleVerbPrefix =~ /^($__verbPrefixList1|$__verbPrefixList2)$/)
  {
    return 1;
  }
  else
  {
    return 0;
  }
}

sub PossiblyIdSeparatedVerbPrefix
{
  my($self, $notesByVerbRef, $possibleVerbPrefix, $id, $mostRecentVerbNoted, $mostRecentVerbToken, $mostRecentVerbContext) = @_;

  if ($self->IsSeparatedVerbPrefix($possibleVerbPrefix))
  {
    my $prefixVerb = "$possibleVerbPrefix$mostRecentVerbNoted";
    if ($self->IsAnInfinitive($prefixVerb, "PossiblyIdSeparatedVerbPrefix"))
    {
      print "German_grammar::PossiblyIdSeparatedVerbPrefix($notesByVerbRef, $possibleVerbPrefix): sees separated verb; adjusting note to reflect this...\n" if $__MassageAndFootnoteTrace;

      $self->UnproposeVerbTenseNote($mostRecentVerbNoted, $mostRecentVerbToken);
      $self->ProposeVerbTenseNote($prefixVerb, $mostRecentVerbToken, 0, $mostRecentVerbContext, "SeparatedFormOf(\"$mostRecentVerbContext\", \"$prefixVerb\", \"$mostRecentVerbToken... $possibleVerbPrefix\")", $id);
      return 1;
    }
  }
  else
  {
    print "German_grammar::PossiblyIdSeparatedVerbPrefix(): $possibleVerbPrefix doesn't look like a prefix\n" if $__MassageAndFootnoteTrace;
  }

  return 0;
}

sub SetTenseAreaIfNeeded
{
  my($self, $id, $context, $execute, $token) = @_;

  if ($self->IsAnInfinitive($token, "SetTenseAreaIfNeeded"))
  {
    # because German infinitive forms overlap with forms in numerous tenses,
    # I disable any complaints about area mismatches where the token is a German
    # infinitive.
    return;
  }
  else
  {
    $self->SUPER::SetTenseAreaIfNeeded($id, $context, $execute, $token);
  }
}

sub LooksLikeWerdenPresent
{
  my($mostRecentVerbContext) = @_;
  # this is goofy -- I know -- but werden's k1 forms have a lot in common with its present forms,
  # and so frequently $mostRecentVerbContext records a k1 instance; but it almost always should be
  # present tense.  I hide away this idiosyncrasies within this routine.
  return ($mostRecentVerbContext =~ /^(present|k1)$/);
}

sub ProposeVerbTenseNote
{
  my($self, $verb, $token, $possiblyAmbiguous, $context, $note, $id) = @_;
  my $lastToken = $self->MassageAndFootnoteGetToken(-1);
  if ($context eq "k1"
  && $self->IsSeparatedVerbPrefix($lastToken))
  {
    my $possiblePrefixVerb = $lastToken . $verb;
    if ($self->IsAnInfinitive($possiblePrefixVerb, "German_grammar::ProposeVerbTenseNote"))
    {
      $note = "FormOf(\"k1\", \"$possiblePrefixVerb\", undef, \"$lastToken$token\")";
      return $self->SUPER::ProposeVerbTenseNote($possiblePrefixVerb, $token, $possiblyAmbiguous, $context, $note, $id);
    }
  }
  return $self->SUPER::ProposeVerbTenseNote($verb, $token, $possiblyAmbiguous, $context, $note, $id);
}

sub MassageAndFootnoteForOneToken
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified) = @_;

  if ($thisTokenIsPermanentlyIdentified)
  {
    return;
  }

  if ($normalizedToken eq "zu")
  {
    return;
  }


  my $lastToken = $self->MassageAndFootnoteGetToken(-1);
  # 		Following 'if' previously had this condition too:
  #  || IsModalAuxiliary( $lastToken))
  #
  # That screwed up 'German' => 'Ich werde {}die Br:ucke{der Br:ucke>s>} bauen k:onnen haben.',
  # w/ only 'werde' (present tense) being flagged.
  if ($lastToken eq "zu")
  {
    print "German_grammar::MassageAndFootnoteForOneToken: looks like an infinitive: ignoring...\n" if $__MassageAndFootnoteTrace;
    return;
  }

  if ($__inMainClause)
  {
    if ($token =~ /^(bevor|daBB)$/)
    {
      $__inMainClause = 0;
    }
    else
    {
      $self->MassageAndFootnoteForOneToken_mainClause($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef);
    }
  }
  else
  {
    $self->MassageAndFootnoteForOneToken_otherClauses($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef);
  }
}

sub MassageAndFootnoteForOneToken_mainClause
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef) = @_;
  my $mostRecentVerbNoted = $self->MostRecentVerbNoted();
  print "German_grammar::MassageAndFootnoteForOneToken_mainClause(): mostRecentVerbNoted=" . nutil::ToString($mostRecentVerbNoted) . "\n" if $__MassageAndFootnoteTrace;

  if (defined $mostRecentVerbNoted)
  {
    my $ref = $notesByVerbRef->{$mostRecentVerbNoted};
    die $mostRecentVerbNoted unless defined $ref;
    my($mostRecentVerbToken, $possiblyAmbiguous, $mostRecentVerbContext, $note) = @$ref;

    if ($self->PossiblyIdSeparatedVerbPrefix($notesByVerbRef, $token, $id, $mostRecentVerbNoted, $mostRecentVerbToken, $mostRecentVerbContext))
    {
      return;
    }

    if ($mostRecentVerbNoted eq "werden")
    {
      if (!defined $__compoundPastParticiple)
      {
	my($dummy1, $compoundPastParticipleVerb, $dummy2) = $self->VtlLookup($normalizedToken, $id, "past participle");
	if (defined $compoundPastParticipleVerb)
	{
	  my $nextToken = $self->MassageAndFootnoteGetToken(1);
	  if ($nextToken =~ /^(haben|sein)$/)
	  {
	    $__compoundPastParticipleVerb = $compoundPastParticipleVerb;
	    $__compoundPastParticiple = $normalizedToken;
	    print "German_grammar::MassageAndFootnoteForOneToken_mainClause($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): saw pp/verb: $__compoundPastParticiple/$__compoundPastParticipleVerb\n" if $__MassageAndFootnoteTrace;
	    return;
	  }
	}
      }
      if ($self->IsAnInfinitive($normalizedToken, "MassageAndFootnoteForOneToken_mainClause.werden is recent"))
      {
	print "German_grammar::MassageAndFootnoteForOneToken_mainClause($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): found compound werden tense: replacing old werden 'FormOf'\n" if $__MassageAndFootnoteTrace;
	$self->UnproposeVerbTenseNote("werden", $mostRecentVerbToken);

	my $context;
	if (($normalizedToken =~ /^(haben|sein)$/) && (defined $__compoundPastParticiple))
	{
	  if ($mostRecentVerbContext eq "conditional")
	  {
	    $context = "past_conditional";
	  }
	  elsif (LooksLikeWerdenPresent($mostRecentVerbContext))
	  {
	    $context = "future_perfect";
	  }
	  else
	  {
	    warn "German_grammar::MassageAndFootnoteForOneToken_mainClause($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): confusion 1:  $mostRecentVerbContext\n";
	    return;
	  }
	  $self->ProposeVerbTenseNote($__compoundPastParticipleVerb, $normalizedToken, 0, $context, "CompoundFormOf(\"$context\", \"$__compoundPastParticipleVerb\", \"$mostRecentVerbToken $__compoundPastParticiple $normalizedToken\")", $id);
	}
	else
	{
	  if ($mostRecentVerbContext eq "conditional")
	  {
	    $context = "conditional";
	  }
	  elsif (LooksLikeWerdenPresent($mostRecentVerbContext))
	  {
	    $context = "future";
	  }
	  else
	  {
	    warn "German_grammar::MassageAndFootnoteForOneToken_mainClause($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): confusion 2:  $mostRecentVerbContext\n";
	    return;
	  }
	  $self->ProposeVerbTenseNote($normalizedToken, $normalizedToken, 0, $context, "CompoundFormOf(\"$context\", \"$normalizedToken\", \"$mostRecentVerbToken $normalizedToken\")", $id);
	}
	$self->MassageAndFootnoteInitData();
	return;
      }
    }
  }
  $self->SUPER::MassageAndFootnoteForOneToken($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, 0);
}

sub MassageAndFootnoteForOneToken_otherClauses
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef) = @_;

  my $context;
  if (!defined $__waitingPastParticiple)
  {
    my($dummy1, $waitingPastParticipleVerb, $dummy2) = $self->VtlLookup($normalizedToken, $id, "past participle");
    if (defined $waitingPastParticipleVerb)
    {
      print "German_grammar::MassageAndFootnoteForOneToken_otherClauses($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): saw waitingPastParticiple\n" if $__MassageAndFootnoteTrace;
      $__waitingPastParticipleVerb = $waitingPastParticipleVerb;
      $__waitingPastParticiple = $normalizedToken;
      return 1;
    }
  }
  else
  {
    my($contextFound, $verbFound, $dummy) = $self->VtlLookup($normalizedToken, $id);
    if (defined $verbFound && ($verbFound =~ /^(haben|sein)$/))
    {
      $context = $self->Pastify($contextFound);
      if (defined $context)
      {
	$self->ProposeVerbTenseNote($__waitingPastParticipleVerb, $token, 0, $context, "CompoundFormOf(\"$context\", \"$__waitingPastParticipleVerb\", \"$__waitingPastParticiple $normalizedToken\")", $id);
	return 1;
      }
    }
  }

  if (!defined $__waitingInfinitive)
  {
    if ($self->IsAnInfinitive($normalizedToken, "MassageAndFootnoteForOneToken_otherClauses.!waitingInfinitive") && !$self->ProcessingLastToken())
    {
      print "German_grammar::MassageAndFootnoteForOneToken_otherClauses($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef): saw waitingInfinitive\n" if $__MassageAndFootnoteTrace;
      $__waitingInfinitive = $token;
      return 1;
    }
  }
  else
  {
    if ($normalizedToken =~ /^w:urde/)
    {
      $context = "conditional";
      $self->ProposeVerbTenseNote($__waitingInfinitive, $normalizedToken, 0, $context, "CompoundFormOf(\"$context\", \"$__waitingInfinitive\", \"$__waitingInfinitive $normalizedToken\")", $id);
      $__waitingInfinitive = undef;
      return 1;
    }
    if ($normalizedToken =~ /^werde/)
    {
      $context = "future";
      $self->ProposeVerbTenseNote($__waitingInfinitive, $normalizedToken, 0, $context, "CompoundFormOf(\"$context\", \"$__waitingInfinitive\", \"$__waitingInfinitive $normalizedToken\")", $id);
      $__waitingInfinitive = undef;
      return 1;
    }
  }
  $self->SUPER::MassageAndFootnoteForOneToken($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, 0);
}


sub MassageAndFootnoteForOneExercise
{
  my($self, $id) = @_;
  $self->MassageAndFootnoteInitData();
  $__MassageAndFootnoteTrace = (Argv_db::FlagSet("MassageAndFootnoteDebug"));
  
  my $ambiguousCount = $self->SUPER::MassageAndFootnoteForOneExercise($id);

  if (tdb::IsPropSet($id, "areas", "imperfect"))
  {
    $self->SetNote($id, "", "whyImperfectInsteadOfPerfect");
  }
  return $ambiguousCount;
}
  
sub VtlUpdateVetoed
{
  my($self, $verb_b) = @_;

  # My German version of MassageAndFootnoteOneToken deals with separated verbs,
  # but it works correctly only if the verb is initially identified as
  # the base verb.  To achieve this, I need to not allow separated verbs
  # to clutter up the vtl.
  #
  # we do, however, need to have the separated verb past participle recorded
  # (which is done above)
  return IsSeparatedVerb($verb_b);
}

sub ResolveVtlLookupAmbiguity
{
  my($self, $token, $vtlVal, $areas, $id) = @_;
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "imperfect", "preterite");
  $self->SUPER::ResolveVtlLookupAmbiguity($token, $vtlVal, $areas, $id);
}


sub VtlUpdateInitVerb
{
  my($self, $verb_b) = @_;
  my $val = $verb_b;
  if ($val =~ /^sich /)
  {
    $val =~ s/(sich \w+) .*/$1/;
  }
  else
  {
    $val =~ s/(\w+) .*/$1/;
  }
  #print "German_grammar::VtlUpdateInitVerb($verb_b): $val\n";
  return $val;
}

sub VtlUpdate
{
  my($self, $key, $tense, $verb_b) = @_;
  #print "German_grammar::VtlUpdate($key, $tense)\n";
  if ($tense =~ /^(present|imperative|imperfect|past participle|preterite|k2|k1)$/)
  {
    #print "German_grammar::VtlUpdate($key, $tense): tense ok\n";
    $verb_b = $self->{"vtlUpdateVerb_b"} unless defined $verb_b;
        
    if (!defined $verb_b)
    {
      #print "German_grammar::VtlUpdate($key, $tense): no verb_b\n";
    }
    else
    {
      #print "German_grammar::VtlUpdate($key, $tense): saw $verb_b\n";
      # strip out prompting
      $key =~ s/\(.*\)//s;
      $key =~ s/\n/ /g;
      $key =~ s/ +/ /g;
      $key =~ s/ $//;
      
      # strip out pronouns
      $key =~ s/^/ /;
      $key =~ s/ ([dms]ich|uns|[mdw]ir|sie|euch|ih[mnr]|ihnen)\b//gi;	# wir is included for ersatz p1 imperative
      $key =~ s/^ //;

      # strip out separated prefixes
      $key =~ s/ ($__verbPrefixList1)//;
      $key =~ s/ ($__verbPrefixList2)//;
                
      #print "German_grammar::VtlUpdate($key, $tense) post: $key\n";
          
      $self->SUPER::VtlUpdate($key, $tense, $verb_b);
    } 
  } 
}

sub GetAuxTense
{
  my($self, $id) = @_;
  
  my $s;
  $s = tdb::Get($id, "tense");
  my $areas = tdb::Get($id, "areas");
  if (!defined $s)
  {
    $s = $areas;
  }
  elsif (($s eq "past_conditional") && ($areas =~ /past_k2/))
  {
    $s = "past_k2";
  } 
  
  my $val = undef;
  if ($s =~ /^(.*\|)?past_k2(\|.*)?/)
  {
    $val = "k2";
  }
  elsif ($s =~ /^(.*\|)?past_conditional(\|.*)?/)
  {
    $val = "conditional";
  }
  elsif ($s =~ /^(.*\|)?(past|future)(\|.*)?/)
  {
    $val = "present";
  }
  elsif ($s =~ /^(.*\|)?future_perfect(\|.*)?/)
  {
    $val = "present";
  }
  elsif ($s =~ /^(.*\|)?pluperfect(\|.*)?/)
  {
    $val = "imperfect";
  }
  print "German_grammar::GetAuxTense($id ($s)): " . nutil::ToString($val) . "\n" if $__MassageAndFootnoteTrace;
  return $val;
}

sub IsSeparatedVerb
{
  my($verb_b) = @_;
    
  my $val = ($verb_b !~ /^(sich )?(wiederholen)$/)
  && ($verb_b =~ /^(sich )?($__verbPrefixList1|$__verbPrefixList2)[^B]/);  # [^B] => not followed by BB (e.g., beiBBen)
    
  #print "IsSeparatedVerb($verb_b): $val\n";
  return $val;
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->Init("German");
                    
  return $self;
}

sub CombinedSeparatedVerb
{
  my($self, $context, $verb) = @_;
  $self->FormOf($context, $verb);
}

sub IsModalAuxiliary
{
  my($verb_b) = @_;
  nutil::Warn() if !defined $verb_b;
  return $verb_b =~ /^(d:urfen|k:onnen|m:ogen|m:ussen|sollen|wollen)$/; 
}

sub RequiresK2
{
  my($verb_b) = @_;
  return IsModalAuxiliary($verb_b) || $verb_b =~ /^(haben|sein|werden)$/;
}
  
sub GetTenseOverride
{
  my($self, $verb_b, $tense) = @_;
  
  if ($tense =~ /^(conditional|past_conditional)$/)
  {
    if (RequiresK2($verb_b))
    {
      my $replacementTense;
      if ($tense eq "conditional")
      {
	$replacementTense = "k2";
      }
      else
      {
	$replacementTense = "past_k2";
      }
      my $cookedReplacementTense = $self->CookTense($replacementTense);
      
      my $s = "<center>\nUsing <i>$verb_b</i> in the $tense tense with <i>\nwerden\n</i> is considered stilted.<br>Instead you are advised to use the " . $self->MakeLink("$cookedReplacementTense tense", $self->GetTenseURL($replacementTense)) . " (cf. <a href=#$replacementTense>$cookedReplacementTense conjugation for <i>$verb_b</i></a>).\n</center>";
      $s = $self->Cook($s);
      $s =~ s/\n/ /g;
      return $s;
    }
  }
  return $self->SUPER::GetTenseOverride($verb_b, $tense);
}


sub Cook
{
  my($self, $s) = @_;
  $s =~ s/^k1/Konjuntiv I/gm;
  $s =~ s/^k2/Konjuntiv II/gm;
  $s =~ s/^past_k2/Pluperfect Konjuntiv II/gm;
  return $self->SUPER::Cook($s);
}

sub X
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm, $suppressVtl) = @_;
  #print "German_grammar::X($tense, $english, $pronounCode, $other, $verbForm, " . nutil::ToString($suppressVtl) . ")\n";
  my $verb_b = $self->{"verb_b"};
  if (RequiresK2($verb_b))
  {
    if ($tense eq "conditional")
    {
      return "k2_only_for_this_verb_(ie, no conditional)";
    }
    elsif ($tense eq "past_conditional")
    {
      return "past_k2_only_for_this_verb_(ie, no past_conditional)";
    }
    elsif ($tense =~ /^(k2|past_k2)$/)
    {
      if (!$suppressVtl)
      {
	$self->VtlUpdate($verbForm, $tense);
	$suppressVtl = 1;
      } 
      if ($tense eq "k2")
      {
	$tense = "conditional";
      } 
      elsif ($tense eq "past_k2")
      {
	$tense = "past_conditional";
      } 
      else
      {
	die $tense;
      }
    }
  }
  my $x = $self->SUPER::X($tense, $english, $pronounCode, $other, $verbForm, $suppressVtl);
  return $x;
}

sub Pastify
{
  my($self, $context) = @_;
  if ($context eq "k2")
  {
    return "past_k2";
  }
  else
  {
    return $self->SUPER::Pastify($context);
  }
}

sub Prep
{
  my($self, $preposition, $english, $case) = @_;
  $self->HashPut("prepositions", $preposition, $case);
  return "<tr><td>\n$preposition\n</td><td>$english</td></tr>\n";
}

sub ExplainSuffix
{
  my($stem, $suffix, $case) = @_;
  return "<i>$stem</i> takes a suffix of <i>-$suffix</i> in the $case case.";
}

sub ShouldUseInfinitiveAsPastParticipleWithBareInfinitive
{
  my($verb_b) = @_;
  return (IsModalAuxiliary($verb_b) || ($verb_b =~ /^(sehen|h:oren|lassen)$/));
}

sub UseInfinitiveAsPastParticipleWithBareInfinitive
{
  my($self, $key, $other, $verb_b) = @_;
  my $pastParticipleForDoubleInfinitives =                          $verb_b;
  my $pastParticipleForOther             = $self->GetPastParticiple($verb_b);
  if ($other =~ /\b(\S+) $pastParticipleForOther/)
  {
    my $inf = $1;
    my $infSuppressionKey = "suppress_German_note#" . $inf . ";;German";
    my $infSuppression = tdb::Get($key, $infSuppressionKey, "addendKey");
    if (defined $infSuppression && $infSuppression eq 'Infinitive')
    {
      $other =~ s/$pastParticipleForOther/$pastParticipleForDoubleInfinitives/;
      $self->VtlOverride($pastParticipleForDoubleInfinitives, $key, "past participle", $verb_b, 0);
      $self->SetNote($key, $pastParticipleForDoubleInfinitives, "ExplainInfinitiveUsedAsPastParticiple()", 1);
    }
  }
  #print "German_grammar::UseInfinitiveAsPastParticipleWithBareInfinitive($key, $other, $verb_b): $pastParticipleForOther/$pastParticipleForDoubleInfinitives/\n";
  return $other;
}

sub OnExerciseGeneration
{
  my($self, $key, $english, $tense, $pronounCode, $other, $verbForm, $verb_a, $verb_b) = @_;

  my $separableVerbPrefix = $self->{"separableVerbPrefix"};
  if ($tense eq "k1")
  {
    #print "German_grammar::OnExerciseGeneration($key, $english, $other, $verbForm)\n";
    if (defined $separableVerbPrefix)
    {
      #print "German_grammar::OnExerciseGeneration($key, $other, $verbForm ($separableVerbPrefix))...";
      $other =~ s/ $separableVerbPrefix//;		# since I'm doing that ...daBB thing, rejoin the prefix to verb

      $verbForm =~ s/ $separableVerbPrefix//;
      #print "[vf=$verbForm]\n";

      $other =~ s/$verbForm/$separableVerbPrefix^D $verbForm/;
    }

    my $recursivePronounAndOrTrailingStuff = "";
    #
    # need to work with 'sich unterhalen gut' also.
    #
    #$recursivePronounAndOrTrailingStuff = $1 if ($verbForm =~ / (mir|sich|dir|sich|uns|euch|mich|dich)$/);
    #
    $recursivePronounAndOrTrailingStuff = $2 if ($verbForm =~ /(\S+) (.*)/);
    if ($recursivePronounAndOrTrailingStuff)
    {
      #print "1:$other\n";
      #                                         # start:                             'sie fortbewege sich'
      $other =~ s/ $recursivePronounAndOrTrailingStuff//;		# rm recursive pronoun               'sie fortbewege'
      #print "2:$other\n";
      $other =~ s/ / $recursivePronounAndOrTrailingStuff /;	# move it to follow the first space  'sie sich fortbewege'
    }



    #print "3:$other\n";
  }

  ($english, $other, $verbForm) = $self->SUPER::OnExerciseGeneration($key, $english, $tense, $pronounCode, $other, $verbForm, $verb_a, $verb_b);
  if (ShouldUseInfinitiveAsPastParticipleWithBareInfinitive($verb_b))
  {
    $other = $self->UseInfinitiveAsPastParticipleWithBareInfinitive($key, $other, $verb_b);
  }
  return ($english, $other, $verbForm);
}

# Hammer 13.3.2a
sub ExplainInfinitiveUsedAsPastParticiple
{
  my($self) = @_;
  my $currentToken = $self->Get__currentToken();
  my $verb_b = $currentToken;
  my $usualPastParticiple = $self->GetPastParticiple($verb_b);
  my $s = "Yes, ,$verb_b is serving as a past participle here; although one would normally expect to see\n,$usualPastParticiple\n in its place, when ";
  my $isModalAuxiliary = IsModalAuxiliary($verb_b);
  if ($isModalAuxiliary)
  {
    $s .= "any " . $self->MakeLink("modal auxiliary verb", "German.html#German=Verbs=modal_auxiliary");
  }
  else
  {
    $s .= "<i>$verb_b</i>";
  }
  $s .= "\'s past participle follows an infinitive, it takes a special form which -- confusingly -- is the same as ";
  if ($isModalAuxiliary)
  {
    $s .= "the modal auxiliary verb";
  }
  else
  {
    $s .= "<i>$verb_b</i>";
  }
  $s .= "\'s infinitive.  ";
  if ($isModalAuxiliary)
  {
    $s .= "This is also true for the verbs\n,sehen, ,h:oren, and ,lassen.\n";
  }
  else
  {
    $s .= "This is true for the verbs\n,sehen, ,h:oren, and ,lassen, and also for all of the\n" . $self->MakeLink("modal auxiliary verbs", "German.html#German=Verbs=modal_auxiliary") . ".";
    $s .= "<i>$verb_b</i>";
  }
  return $s;
}


sub Noun
{
  my($self, $noun, $gender, $plural, $genitiveSuffix) = @_;
  if (defined $genitiveSuffix)
  {
    $self->HashPut("genitiveSuffixHash", $noun, $genitiveSuffix);
  }
  return $self->SUPER::Noun($noun, $gender, $plural);
}

# char 1: gender
# char 2: singularOrPlural
# char 3: case
sub Mutable
{
  my($self,
  $whatItIsLink, $whatItIs,
  $msn, $msa, $msd, $msg,
  $fsn, $fsa, $fsd, $fsg,
  $nsn, $nsa, $nsd, $nsg,
  $pn, $pa, $pd, $pg) = @_;

  my $hdr = ['', 'nominative', 'accusative', 'dative', 'genitive'];
  my $m = ['masculine singular', $msn, $msa, $msd, $msg];
  my $f = ['feminine singular', $fsn, $fsa, $fsd, $fsg];
  my $n = ['neuter singular', $nsn, $nsa, $nsd, $nsg];
  my $p = (!defined $pn ? undef : ['plural', $pn, $pa, $pd, $pg]);

  my %flavors = ();
  $flavors{'whatItIs'} = $self->MakeGrammarLink($whatItIs, $whatItIsLink);
  $flavors{'msa'} = $msa;
  $flavors{'msd'} = $msd;
  $flavors{'msg'} = $msg;
  $flavors{'fs'} = $fsn;
  $flavors{'ms'} = $msn;
  $flavors{'fsa'} = $fsa;
  $flavors{'fsd'} = $fsd;
  $flavors{'fsg'} = $fsg;
  $flavors{'ns'} = $nsn;
  $flavors{'nsa'} = $nsa;
  $flavors{'nsd'} = $nsd;
  $flavors{'nsg'} = $nsg;
  
  $self->HashPut("mutables", $msn, \%flavors);
  
  if (defined $p)
  {
    $flavors{'p'} = $pn;
    $flavors{'pn'} = $pn;
    $flavors{'pa'} = $pa;
    $flavors{'pd'} = $pd;
    $flavors{'pg'} = $pg;
  } 
  $self->SaveMutable($msn, \%flavors);
  if (defined $p)
  {  
    return $self->Table([$hdr, $m, $f, $n, $p]);
  }
  else
  {
    return $self->Table([$hdr, $m, $f, $n]);
  }
}

sub GenAdjectiveSuffixExercise
{
  my($self, $prompt, $mutableHash, $mutableSrc, $gender, $singularOrPlural, $case, $suffix, $name) = @_;
      
  my $mutated = undef;
  if (defined $mutableHash)
  {
    my $oToken = $self->CheckMutables($mutableHash, $mutableSrc, $gender, $singularOrPlural, $case);
    $mutated = $oToken->GetToken();
  }
  print "{\n'English' => '";
  if (defined $mutated)
  {
    print "<i>$mutated</i> + ";
  }
  print "$prompt" if defined $prompt;
  print "adj +"
  . $self->PrintGender($gender)
  . $self->PrintSingularOrPlural($singularOrPlural) . " noun in the"
  . PrintCase($case)
  . " case: what is the appropriate adjective suffix, if any?',\n";
           
  print "'German' => '-$suffix (from the $name)',\n},\n";
}

sub PossiblyGenAdjectiveSuffixExercises
{
  my($self, $name, $hRef) = @_;

  my $prompt;
  my $mutableSrc = undef;
  my $mutableHash = undef;
  my $mutableSrc2 = undef;
  my $mutableHash2 = undef;
  my $prompt2 = undef;
  if ($name eq 'adj_weak_endings')
  {
    $mutableSrc = "der";
    $mutableSrc2 = "dieser";
    $prompt  = 'def article';
    $prompt2 = 'demonstrative adjective';
    $mutableHash  = $self->HashGet("mutables", "der");
    $mutableHash2 = $self->HashGet("mutables", "dieser");
  }
  elsif ($name eq 'adj_mixed_endings')
  {
    $mutableSrc = "mein";
    $mutableSrc2 = "ein";
    $mutableHash  = $self->HashGet("mutables", "ein");
    $mutableHash2 = $self->HashGet("mutables", "mein");
    $prompt = 'indef article';
    $prompt2 = 'possessive pronoun';
  }
  elsif ($name eq 'adj_strong_endings')
  {
    $prompt = undef;
  }
  else
  {
    return;
  }
  foreach my $key (keys %$hRef)
  {
    $name =~ s/^adj_//;
    $name =~ s/_/ /;
    
    die $key unless $key =~ /^([mfn])([ps])([nadg])$/;
    
    my($gender, $singularOrPlural, $case) = ($1, $2, $3);
    my $suffix = $hRef->{$key};
    $self->GenAdjectiveSuffixExercise($prompt,  $mutableHash,  $mutableSrc,  $gender, $singularOrPlural, $case, $suffix, $name);
    if (!defined $prompt2)
    {
      next;
    }
    if (defined $mutableSrc2 && $mutableSrc2 eq "ein" && $singularOrPlural eq "p")
    {
      next;
    }
    $self->GenAdjectiveSuffixExercise($prompt2, $mutableHash2, $mutableSrc2, $gender, $singularOrPlural, $case, $suffix, $name);
  }
}


# char 1: gender
# char 2: singularOrPlural
# char 3: case
sub Endings
{
  my($self, 
  $name,
  $msn, $msa, $msd, $msg,
  $fsn, $fsa, $fsd, $fsg,
  $nsn, $nsa, $nsd, $nsg,
  $pn, $pa, $pd, $pg) = @_;
        
  my $hdr = ['', 'nominative', 'accusative', 'dative', 'genitive'];
  my $m = ['masculine singular', "-$msn", "-$msa", "-$msd", "-$msg"];
  my $f = ['feminine singular', "-$fsn", "-$fsa", "-$fsd", "-$fsg"];
  my $n = ['neuter singular', "-$nsn", "-$nsa", "-$nsd", "-$nsg"];
  my $p = (!defined $pn ? undef : ['plural', "-$pn", "-$pa", "-$pd", "-$pg"]);
    
  my %flavors = ();
  $flavors{'msn'} = $msn;
  $flavors{'msa'} = $msa;
  $flavors{'msd'} = $msd;
  $flavors{'msg'} = $msg; 
  $flavors{'fsn'} = $fsn;
  $flavors{'fsa'} = $fsa;
  $flavors{'fsd'} = $fsd;
  $flavors{'fsg'} = $fsg; 
  $flavors{'nsn'} = $nsn;
  $flavors{'nsa'} = $nsa;
  $flavors{'nsd'} = $nsd;
  $flavors{'nsg'} = $nsg;

  $self->HashPut("endings", $name, \%flavors);
  
  my $s;
  if (defined $p)
  {
    $flavors{'mpn'} = $flavors{'npn'} = $flavors{'fpn'} = $pn;
    $flavors{'mpa'} = $flavors{'npa'} = $flavors{'fpa'} = $pa;
    $flavors{'mpd'} = $flavors{'npd'} = $flavors{'fpd'} = $pd;
    $flavors{'mpg'} = $flavors{'npg'} = $flavors{'fpg'} = $pg;
    $s = $self->Table([$hdr, $m, $f, $n, $p]);
  }
  else
  {
    $s = $self->Table([$hdr, $m, $f, $n]);
  }
  
  # if an ending is prefixed w/ '!', make it red + bold:
  $s =~ s{-!([\w/`:#]+)}{<font color=red><b>-$1</b></font>}g;
  $s =~ s/--/-/g;
    
  #$self->PossiblyGenAdjectiveSuffixExercises($name, \%flavors);
  return $s;
}

sub MutableDer
{
  my($self, $whatItIsLink, $whatItIs, $stem) = @_;
      
  # dieser, diesen, diesem, dieses,
  # diese, diese, dieser, dieser,
  # dieses, dieses, diesem, dieses,
  # diese, diese, diesen, dieser
      
  return $self->Mutable($whatItIsLink, $whatItIs, "${stem}er", "${stem}en", "${stem}em", "${stem}es",
  "${stem}e",  "${stem}e",  "${stem}er", "${stem}er",
  "${stem}es", "${stem}es", "${stem}em", "${stem}es",
  "${stem}e",  "${stem}e",  "${stem}en", "${stem}er");
}

sub MutableEin
{
  my($self, $whatItIsLink, $whatItIs, $stem) = @_;
  # 'ein', 'einen', 'einem', 'eines', 'eine', 'eine', 'einer', 'einer', 'ein', 'ein', 'einem', 'eines'
              
  my($pn, $pa, $pd, $pg);
  if ($stem =~ /^(ein|kein)$/)
  {
    ($pn, $pa, $pd, $pg) = (undef, undef, undef, undef);
  }
  else
  {
    ($pn, $pa, $pd, $pg) = ("${stem}e",  "${stem}e",  "${stem}en", "${stem}er");
  } 
  
  return $self->Mutable($whatItIsLink, $whatItIs, "${stem}", "${stem}en", "${stem}em", "${stem}es",
  "${stem}e",  "${stem}e",  "${stem}er", "${stem}er",
  "${stem}",   "${stem}",   "${stem}em", "${stem}es",
  $pn, $pa, $pd, $pg);
}


sub IsStrongMasculineNoun
{
  my($self, $noun, $gender) = @_;
  my $val = ($gender eq 'm' && defined $self->HashGet("genitiveSuffixHash", $noun));
  print "German_grammar::IsStrongMasculineNoun($noun, $gender): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub CanonicalCharacteristics
{
  my($self, $gender, $singularOrPlural, $magic) = @_;
  # nominative is the canonical case
  return $magic eq 'n' && $self->SUPER::CanonicalCharacteristics($gender, $singularOrPlural);
}

sub AddSuffix
{
  my($base, $suffix) = @_;
  if ($base =~ /e$/ && $suffix =~ /^e(.*)/)
  {
    $suffix = $1;
  }
  return $base . $suffix;
}


sub GetEnding
{
  my($endings, $gender, $singularOrPlural, $case) = @_;

  my $suffix;
  $suffix = $endings->{"$gender$singularOrPlural$case"};
  $suffix = $endings->{"$singularOrPlural$case"} if !defined $suffix;
  $suffix = $endings->{"$gender$singularOrPlural"} if !defined $suffix;

  if (!defined $suffix)
  {
    foreach my $key (sort keys %$endings)
    {
      print "$key => " . $endings->{$key} . "\n";
    }
    nutil::Warn("German_grammar::CanonicalCharacteristics($endings, $gender, $singularOrPlural, $case): no suffix found");
  }
  return $suffix;
}

sub MakeAdjectiveConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $case) = @_;
  my $verb_b = $self->{"verb_b"};
  my $oToken = new o_token($self, $token);
  my $explanation = undef;

  if ($verb_b =~ /^(sein|werden|finden|haben)$/)
  {
    $explanation = "The reason there is no case ending for this adjective is that it is being used with <i>$verb_b</i>, a linking verb (cf. " . $self->MakeLink("adjectives", $self->{"lang"} . ".html#=Adjectives") . " for more info).";
  }
  else
  {
    my $s = $self->{"phrase"};
    $s =~ s/irgend//g;	# simplify interpretation of, e.g., irgendwelch
    $s =~ s/^nach //;
    if ($s =~ /\b(der|dieser|jeder|jener|mancher|solcher|welcher) $token\b/)
    {
      my $whatWasFollowed = $1;
      my $adj_weak_endings = $self->HashGet("endings", "adj_weak_endings");
      my $suffix = GetEnding($adj_weak_endings, $gender, $singularOrPlural, $case);
      $oToken->SetToken(AddSuffix($token, $suffix));
            
      $explanation = "<i>$token</i> adds the " . $self->MakeGrammarLink("weak ending", "=Adjectives=weak_endings") . " <i>-$suffix</i> to become %currentToken% when following a ";
      if ($whatWasFollowed eq 'der')
      {
	$explanation .= "" . $self->MakeGrammarLink("definite article", "=Articles=definite_articles") . ".";
      }
      else
      {
	$explanation .= "" . $self->MakeGrammarLink("demonstrative adjective", "=demonstrative_adjectives") . ".";
      }
    }
    elsif ($s =~ /\b(ein|kein|mein|sein|euer|ihr|unser|Ihr) $token\b/)
    {
      my $whatWasFollowed = $1;
      my $adj_mixed_endings = $self->HashGet("endings", "adj_mixed_endings");
      my $suffix = GetEnding($adj_mixed_endings, $gender, $singularOrPlural, $case);
      $oToken->SetToken(AddSuffix($token, $suffix));
      $explanation = "<i>$token</i> adds the " . $self->MakeGrammarLink("mixed ending", "=Adjectives=mixed_endings") . " <i>-$suffix</i> to become %currentToken% when following ";
      if ($whatWasFollowed eq 'ein')
      {
	$explanation .= "an " . $self->MakeGrammarLink("indefinite article", "=Articles=indefinite_articles") . ".";
      }
      elsif ($whatWasFollowed eq 'kein')
      {
	$explanation .= "a (in this case, negative) " . $self->MakeGrammarLink("indefinite article", "=Articles=indefinite_articles") . ".";
      }
      else
      {
	$explanation .= "a " . $self->MakeGrammarLink("possessive pronoun", "=possessive_pronouns") . ".";
      }
    }
    else
    {
      my $adj_strong_endings = $self->HashGet("endings", "adj_strong_endings");
      my $suffix = GetEnding($adj_strong_endings, $gender, $singularOrPlural, $case);
      $oToken->SetToken(AddSuffix($token, $suffix));
      $explanation = "<i>$token</i> adds the " . $self->MakeGrammarLink("strong ending", "=Adjectives=strong_endings") . " <i>-$suffix</i> to become %currentToken% in this context (cf. " . $self->MakeGrammarLink("adjectives", "=Adjectives") . " for more info).";
    }
    $explanation .= $self->{"noteDivider"} . "To focus your studies on German's complicated adjective endings, go to " .  $self->CgiLink("adjective endings drills", "de_adjective_endings") . ".";
  }
  $oToken->AddNote($explanation);
  print "German_grammar::MakeAdjectiveConformToCharacteristics($token, $gender, $singularOrPlural, $case):  (" . $oToken->ToString() . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $oToken;
}

sub LooksLikeAnAdjective
{
  my($self, $token) = @_;
  my $val;
  if ($token =~ /^:?[A-Z]/
  ||  $token =~ /^([0-9]0er|sehr)$/)	# first one is to catch 70er (70's)
  {
    $val = 0;
  }
  else
  {
    $val = $self->SUPER::LooksLikeAnAdjective($token);
  }
  #print "German_grammar::LooksLikeAnAdjective($token): $val\n";
  return $val;
}

sub DuplicateMutableWithPrefix
{
  my($self, $prefix, $baseMutable) = @_;
  my $baseMutableHash = $self->HashGet("mutables", $baseMutable);
  #print "German_grammar::DuplicateMutableWithPrefix($prefix, $baseMutable)\n";
  if (defined $self->HashGet("mutables", "$prefix$baseMutable"))
  {
    ;         # the job has already been done
  }
  elsif (!defined  $baseMutableHash)
  {
    nutil::Warn("German_grammar::DuplicateMutableWithPrefix($prefix): cannot find $baseMutable mutable hash");
  }
  else
  {
    my %newHash = %$baseMutableHash;
    foreach my $key (keys %newHash)
    {
      next if $key =~ /^whatItIs/;
      $newHash{$key} = $prefix . $baseMutableHash->{$key};
    }
    $self->HashPut("mutables", "$prefix$baseMutable", \%newHash); 
  } 
}

sub ConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $case) = @_;
  my $oToken = new o_token($self, $token);

  nutil::Warn("no case") if !defined $case;

  if ($token =~ /^(irgend)(.*)/)
  {
    my($prefix, $baseMutable) = ($1, $2);
    $self->DuplicateMutableWithPrefix($prefix, $baseMutable);
  }
  my $isNoun = $self->IsNoun($token);
  if (($case ne 'n') && ($singularOrPlural eq 's'))
  {
    if ($self->IsStrongMasculineNoun($token, $gender))
    {
      if ($case eq 'g')
      {
	my $genitiveSuffix = $self->HashGet("genitiveSuffixHash", $token);
	die $token unless defined $genitiveSuffix;
	$oToken = new o_token($self, $self->Combine($token, $genitiveSuffix));
	$oToken->AddNote("<i>$token</i> takes a suffix <i>$genitiveSuffix</i> in the genitive case");
      }
    }
    elsif ($gender eq 'm' && $isNoun)
    {
      # this is a weak masculine noun to which we should add -n or -en
      my $suffix = 'en';
      $oToken->SetToken(AddSuffix($token, $suffix));
      $oToken->AddNote("<i>$token</i> is a weak masculine noun, and takes a suffix <i>-$suffix</i> in the accusative, dative and genitive cases (see " . $self->MakeGrammarLink("nouns", "=Nouns") . " for more info).");
    }
  }
  if (!$oToken->HasNotes())
  {
    $oToken = $self->SUPER::ConformToCharacteristics($token, $gender, $singularOrPlural, $case);
  }

  if (defined $self->{"whyIsTheNounInTheCaseThatItIs"} && $isNoun)
  {
    if (!$oToken->HasNotes())
    {
      # we know there will be a note, i.e., it'll be $self->{"whyIsTheNounInTheCaseThatItIs"}; add the
      # basic info first:
      $oToken->AddNote("%currentToken% is a" 
      . $self->PrintGender($gender)
      . $self->PrintSingularOrPlural($singularOrPlural) . " noun.");
    }
    $oToken->AddNote($self->{"whyIsTheNounInTheCaseThatItIs"});
  }
        
  print "German_grammar::ConformToCharacteristics($token, $gender, $singularOrPlural, $case): (" . $oToken->ToString() . ")\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $oToken;
}

# In the case of German, the magic arg is simply the case of the object phrase.
sub ExtractOrExplainMagicThruPhraseAnalysis
{
  my($self, $key, $s, $magicStuff) = @_;

  $self->{"phrase"} = $s;

  my $prepRequires_why = "";
  my $verb_b = $self->Get_verb_b_fromKey($key);

  delete($self->{"whyIsTheNounInTheCaseThatItIs"});

  my $case = undef;
  my $e = undef;
  my $caseExplicitlySetInBetweenGreaterThans = undef;

  if ($magicStuff)
  {
    if ($magicStuff =~ /^(.)(:(.*))?$/)
    {
      $caseExplicitlySetInBetweenGreaterThans = $1;
      my $note = $3;
      if ($note)
      {
	$e = $self->ExplainCase($caseExplicitlySetInBetweenGreaterThans, $note);
      }
      $case = $caseExplicitlySetInBetweenGreaterThans;
    }
    else
    {
      warn "$key: " . $self->GetLang() . ": $magicStuff";
      $case = 'a';
    }
  }
  elsif ($self->AddendIsSubject($key))
  {
    $case = 'n';
    my $note = "because it is the subject.";
    $e = "ExplainCase('$case', '$note')";
  }

  if ($s =~ /^(\S+)\s/)
  {
    my $firstToken = $1;
    my $mandatoryCase = $self->HashGet("prepositions", $firstToken);
    if (defined $mandatoryCase)
    {
      #print "German_grammar::ExtractOrExplainMagicThruPhraseAnalysis($s): found case: $mandatoryCase\n";
      my $prepRequires;

      if ($mandatoryCase =~ /^.$/)
      {
	$prepRequires = "the" . PrintCase($mandatoryCase) . " case";
	if (defined $case && $mandatoryCase ne $case)
	{
	  warn "$key: German: $mandatoryCase ne $case";
	}
	$case = $mandatoryCase;
      }
      elsif ($mandatoryCase =~ /^dative_or_accusative$/)
      {
	$prepRequires = "one of either the dative or accusative cases";
	if (!defined $case)
	{
	  my $global_case     = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), "German/global_case");
	  if (defined $global_case)
	  {
	    nutil::Warn($global_case) unless $global_case =~ /(.):(.*)/;
	    $case = $1;
	    $prepRequires_why = "  In this case, the " . PrintCase($case) . " case is appropriate $2.";
	  }
	  if (!defined $case)
	  {
	    $case = 'd';
	    nutil::Warn("which case should be used: dative or accusative? $s");
	  }
	}
      }
      else
      {
	die $mandatoryCase;
      }
      if (defined $e)
      {
	$e .= ".  (Note that <i>$firstToken</i> is one of those "
	. $self->MakeGrammarLink("German prepositions after which $prepRequires is required.", "=Prepositions=$mandatoryCase")
	. ")";
      }
      else
      {
	my $note = "because it follows <i>$firstToken</i>, which is one of those "
	. $self->MakeGrammarLink("German prepositions after which $prepRequires is required", "=Prepositions=$mandatoryCase")
	. ".$prepRequires_why";

	$e = "ExplainCase('$case', '$note')";
      }
    }
  }
  if (!defined $case && defined $verb_b && defined $self->HashGet("dativeVerbs", $verb_b))
  {
    $case = 'd';
    my $note = "because <i>$verb_b</i> is one of those "
    . $self->MakeGrammarLink("verbs which requires its objects to be in the dative case", "=Verbs=dative")
    . ".";
    $e = "ExplainCase('$case', '$note')";
  }
  if (!defined $case)
  {
    my $global_case     = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), "German/global_case");
    if (defined $global_case)
    {
      nutil::Warn($global_case) unless $global_case =~ /(.):(.*)/;
      $case = $1;
      $e = "ExplainCase('$case', '$2.')";
    }
    elsif ($key =~ /^vocab/)
    {
      $case = 'n';
    }
    else
    {
      $case = 'a';
    }
  }
  if (!defined $e)
  {
    if ($case eq 'a')
    {
      $e = 'ExplainCase("a", "because it is a direct object.")';
    }
    elsif ($case eq 'g')
    {
      $e = 'ExplainCase("g", "to indicate possession.")';
    }
    elsif ($case eq 'n')
    {
      ;
    }
    else
    {
      warn "$key: German: $case (dative?) why?";
    }
  }
  $self->{"whyIsTheNounInTheCaseThatItIs"} = $e;
  
  print "German_grammar::ExtractOrExplainMagicThruPhraseAnalysis($s): $case\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $case;
}

sub IsNounOfForeignOrigin
{
  my($self, $noun) = @_;
  my $plural = $self->HashGet("pluralHash", $noun);
  my $val;
  if (!defined $plural)
  {
    warn "German_grammar::IsNounOfForeignOrigin($noun): no plural";
    $val = 0;
  }
  else
  {
    $val = $plural eq "-s";
  }
  print "German_grammar::IsNounOfForeignOrigin($noun): $val\n";
  return $val;
}

sub PForeignToGerman
{
  my($self, $noun) = @_;
  return "<i>$noun</i> is a word of foreign origin, and so forms its plural by adding ,-s (just like English words do).";
}

sub MakePlural
{
  my($self, $noun, $case) = @_;
  my $oToken = $self->SUPER::MakePlural($noun, $case);
  my $plural = $oToken->GetToken();
  if ($plural eq "${noun}s")
  {
    $oToken->AddNote("PForeignToGerman('$noun')");
  }
  elsif ($case eq 'd' && $plural !~ /n$/)
  {
    $plural .= "n";
    $oToken->SetToken($plural);
    $oToken->AddNote("The <i>n</i> is added to the end because this is the dative case.");
  }
  
  #print "German_grammar::MakePlural($noun, $case): (" . $oToken->ToString() . "\n";
  return $oToken;
}

 









sub DativeVerb
{
  my($self, $verb_b) = @_;
  #print "German_grammar::DativeVerb($verb_b)\n";
  $self->HashPut("dativeVerbs", $verb_b, 1);

  return $self->ListVerb($verb_b);
}

sub PrintCase
{
  my($case) = @_;
  return " nominative" if ($case eq 'n');
  return " accusative" if ($case eq 'a');
  return " genitive" if ($case eq 'g');
  return " dative" if ($case eq 'd');
  die $case;
}

sub PrintMagic
{
  my($self, $case) = @_;
  return ($case ? PrintCase($case) : "");
}


sub GetPronounName
{
  my($self, $pronounCode) = @_;

  return 'ich' if $pronounCode =~ /s1/;
  return 'du' if $pronounCode =~ /s2b/;
  return 'er' if $pronounCode =~ /s3a/;
  return 'sie' if $pronounCode =~ /(p3|s3b)/;
  return 'es' if $pronounCode =~ /s3c/;
  return 'wir' if $pronounCode =~ /p1/;
  return 'Sie' if $pronounCode =~ /[sp]2a/;
  return 'ihr' if $pronounCode =~ /p2b/;
  die $pronounCode;
}

sub ReplacePronounWithAddend
{
  my($self, $other, $adjustedAddend) = @_;
  $other =~ s/(ich|du|er|sie|es|wir|ihr)/$adjustedAddend/i;
  return $self->SUPER::ReplacePronounWithAddend_common($other, $adjustedAddend);
}

sub OnSelectionBasedOnMagic
{
  my($self, $val, $mutableHash, $gender, $singularOrPlural) = @_;
}

sub ExtractCharacteristicsThruPhraseAnalysis
{
  my($self, $key, $s) = @_;

  if ($s =~ /^(\S+)>L>$/)
  {
    my $adjective = $1;
    my $note = "There is no change for <i>$adjective</i> because adjectives never change in German when used with a linking verb like <i>sein</i>, <i>scheinen</i>, <i>werden</i>, etc. (cf. " . $self->MakeGrammarLink("adjectives", "=Adjectives") . " for more info).";

    $self->SetNote($key, $adjective, $note);
    return (undef, undef, undef, $s);
  }

  my($gender, $singularOrPlural, $magic);
  ($gender, $singularOrPlural, $magic, $s) = $self->SUPER::ExtractCharacteristicsThruPhraseAnalysis($key, $s);

  if (($singularOrPlural eq "p") && ($s =~ /(.*)\bein (.*>x>.*)/))
  {
    $s = $1 . $2; 
  }

  return ($gender, $singularOrPlural, $magic, $s);
}

sub DuplicateOverrides
{
  my($self, $verb, $paradigmVerb, $before, $after, $suffixBefore, $suffixAfter) = @_;
  return $self->SUPER::DuplicateOverrides($verb, $paradigmVerb, $before, $after, $suffixBefore, $suffixAfter, 1);
}

sub GetThat
{
  my($self) = @_;
  return "daBB";
}
1;
# xtest with: perl -w $DROP/adyn/httpdocs/teacher/German_grammar.pm
