package French_grammar;
use o_token;
use Argv_db;
use strict;
use diagnostics;
use arrayOfArrays;
use Carp;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);

my %__endings;


sub GetAreas
{
  my($self, $id) = @_;
  my $areas = tdb::Get($id, "areas");
  
  $areas =~ s/preterite/past/ if defined $areas;
  
  return $areas;
}

sub GetAuxTense
{
  my($self, $id) = @_;

  my $tense = tdb::Get($id, "tense");
  if (defined $tense && ($tense eq "preterite"))
  {
    return "present";
  }
  return $self->SUPER::GetAuxTense($id);
}

sub GetStem
{
  my($self, $verb, $tense) = @_;

  my $conjugationStem = $self->SUPER::GetStem($verb, $tense);
  if (!defined $conjugationStem)
  {
    my $argsRef = $self->GetVerbArgs($verb);
    my($stem_b, $inf_b, $pastParticiple_b,
    $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2_b, $s3_b, $p1_b, $p2_b, $p3_b, $argRef_reflexive_a, $argRef_reflexive_b) = @$argsRef;

    if ($tense eq "subjunctive")
    {
      $conjugationStem = $self->GetSubjunctiveStem($verb);
    }
    elsif ($tense eq "imperfect")
    {
      my $expanded_p1_b;
      if ($p1_b =~ /^-(.*)/)
      {
	$expanded_p1_b = "$stem_b$1";
      }
      else
      {
	$expanded_p1_b = "$p1_b";
      }

      if ($expanded_p1_b =~ /(.*)ons$/)
      {
	$conjugationStem = $1;
      }
      else
      {
	nutil::Warn("bad $expanded_p1_b from " . Ndmp::Ah("args", @$argsRef));
	$conjugationStem = "place_holder";
      }

      if ($conjugationStem =~ /(.*)e$/)	# manger -> mange
      {
	$conjugationStem = "$conjugationStem;$1";
      }
      elsif ($conjugationStem =~ /(.*),c$/)	# commencer -> commen,cons
      {
	$conjugationStem = "$conjugationStem;${1}c";
      }
    }
    elsif ($tense eq "passe_simple")
    {
      my $stem = $self->GetPastParticiple($verb);
      if ($stem =~ s{/e$}{a})	# -er verbs
      {
	$stem =~ s{ga$}{gea};
	$stem =~ s{ca$}{,ca};
      }
      elsif ($verb =~ /ure$/)
      {
	;
      }
      elsif ($verb =~ /[dpt]re$/)
      {
	$stem =~ s{u$}{i};
      }
      elsif ($verb =~ /uire$/)
      {
	$stem =~ s/uis$/uisi/;
      }
      
      $stem =~ s/nt$/gni/;
      $stem =~ s{is$}{i};
      
      return $stem;
    }
  }
  print "GetStem($verb, $tense) => $conjugationStem\n" if ($tense eq "passe_simple");
  return $conjugationStem;
}

sub GetHelperVerb
{
  my($self, $verb, $reflexive) = @_;
  return "#etre" if $reflexive;
  return "#etre" if defined $self->Get__hasSecondaryHelperVerb($verb);
  return "avoir";
}

sub LooksLikeAModifiedPastParticiple
{
  my($self, $token, $id) = @_;
      
  my $val = 0;
  if (($token !~ m{^[A-Z]}) # pp's don't start sentences.  This is a proper.
  &&  ($token !~ m{^...?$})) # 2 or 3 chars?  Too short, normally.
  {
    # undo the effects of adjectival agreement:
    if ($token =~ m{(.*[^/])e$})		# feminine?
    {
      $val = $1;
    }
    elsif ($token =~ m{(.*[^/])es$})	# feminine plural?
    {
      $val = $1;
    }
    elsif ($token =~ /(.*[^i])s$/)	# plural?
    {
      $val = $1;
    }
    elsif ($token =~ /(.*i)s$/)		# plural?
    {
      $val = $1;
      # avoid false hits (eg, permis) but catch the real ones (eg, ils sont sortis)
      my($context, $verb, $possiblyAmbiguous) = $self->VtlLookup($token, $id, "past participle");
      if (!defined $context)
      {
	$val = 0;
      }
    }
  }
  #print "French_grammar::LooksLikeAModifiedPastParticiple($token, $id): $val\n";
  return $val;
}

sub GetPastParticiple
{
  my($self, $verb) = @_;
  die "lksd" unless defined $verb;
  $verb =~ s/2//;
  if ($verb =~ /^(se |s')/)
  {
    if ($verb =~ /^(se |s')(\S+)( .*)$/)
    {
      $verb = "$1$2";
      my $trailingString = $3;
      return $self->GetPastParticiple($verb) . $trailingString;
    }
  }
  elsif ($verb =~ /(\S+)( .*)$/)
  {
    return $self->GetPastParticiple("$1");



    warn "truncating pp";
    #. $2;


  }

  my $val = $self->GetOverride($verb, "past participle");
  if (!defined $val)
  {
    if ($verb =~ /(.*en)ir$/)
    {
      $val = $1 . "u";
    }
    elsif ($verb =~ /(.*pr)endre/)
    {
      $val = $1 . "is";
    }
    elsif ($verb =~ /(.*)cevoir$/)
    {
      $val = $1 . ",cu";
    }
    elsif (($verb =~ /(.*)re$/)
    || ($verb =~ /(.*)oir$/))
    {
      $val = $1 . "u";
    }
    elsif ($verb =~ /(.*)er$/)
    {
      $val = $1 . "/e";
    }
    elsif ($verb =~ /(.*i)r$/)
    {
      $val = $1;
    }
    else
    {
      die "verb $verb"; 
    } 
  }
  $val =~ s/^(se |s')//;
  #print "GetPastParticiple($verb) = $val\n";
  return $val;
}

sub GetPresentParticipleStem
{
  my($self, $verb) = @_;
  my $val = undef;
  my $argsRef = $self->GetVerbArgs($verb);
  my $stem_b = $self->VerbArgs_get_stem_b($argsRef);
  my $p1_b   = $self->VerbArgs_get_p1_b($argsRef);
        
  if (!defined $p1_b)
  {
    Ndmp::Ah("bad p1_b", $argsRef);
    die "bad p1_b"; 
  } 
        
  my $expanded_p1_b;
  if ($p1_b =~ /^-(.*)/)
  {
    $expanded_p1_b = "$stem_b$1";
  }
  else
  {
    $expanded_p1_b = "$p1_b";
  } 
  die "bad $expanded_p1_b" unless ($expanded_p1_b =~ /(.*)ons$/);
  $val = $1;
  #print "GetPresentParticipleStem($lang, $verb) = $val\n";
  return $val;
}

sub GetSubjunctiveStem
{
  my($self, $verb) = @_;
  my $stem = $self->GetPresentParticipleStem($verb);
  if ($stem =~ /(.*),c$/)
  {
    $stem = "${1}c";
  }
  elsif ($stem =~ /y$/)
  {
    my $stem_sp3 = $stem;
    $stem_sp3 =~ s/y$/i/;
    				
    my $stem_p12 = $stem;
    $stem = "$stem_sp3;$stem_p12";
  }
  elsif ($stem =~ /(.*g)e$/)
  {
    $stem = $1;
  }
  return $stem;
}

sub GetVTtoSParms
{
  my($self, $verb_b, $tense, $trailingString_a, $trailingString_b, $reflexive_a, $reflexive_b, $compoundPast) = @_;
  #print "GetVTtoSParms($verb_b, $tense, $trailingString_a, $trailingString_b)\n";
  my $argsRef = $self->GetVerbArgs($verb_b);
  
  #Ndmp::Ah("GetVTtoSParms: argsRef for $verb_b", $argsRef);
          											
  my($stem_b, $inf_b, $pastParticiple_b,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2_b, $s3_b, $p1_b, $p2_b, $p3_b, $argRef_reflexive_a, $argRef_reflexive_b) = @$argsRef;
  
  die "kx" unless !defined $p1_b || ($self->VerbArgs_get_p1_b($argsRef) eq $p1_b);
  die "kz"         unless  $self->VerbArgs_get_stem_b($argsRef) eq $stem_b;
        		
  $reflexive_a = $argRef_reflexive_a unless defined $reflexive_a;
  $reflexive_b = $argRef_reflexive_b unless defined $reflexive_b;
  
  if ($verb_b =~ /(se |s')(.*)/)
  {
    $reflexive_b = $1;
    $verb_b = $2;
  } 
  if ($verb_b =~ /^(\S+)( .*)/)
  {
    $verb_b = $1;
    $trailingString_b = $2 . $trailingString_b;
  }
  my $verb_a = "$stem_a$inf_a";
  my $pastParticiple_a = $self->GetPastParticiple_English($verb_a);
  my $resetEnglish = undef;
  my $dummy;
  if ($verb_a =~ /(\S+) (.*)/)  # e.g., "be worth"
  {
    $trailingString_a = " $2$trailingString_a";
    $resetEnglish = "$1";
  }        				
  elsif ($compoundPast && ($verb_a eq "be"))
  {
    # #etre is apparently being used as an auxiliary verb in a compound 
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
        	
  my($s3a_a, $s3b_a, $s3c_a) = ($s3_a, $s3_a, $s3_a);
  my($s3a_b, $s3b_b, $s3c_b) = ($s3_b, $s3_b, $s3_b);
  my($p3a_b, $p3b_b)         = ($p3_b, $p3_b);
  my($s2a_b, $s2b_b)         = ($p2_b, $s2_b);
        	
  die "bad stem" unless defined $stem_a;
        		
  if (($tense eq "past_conditional")
  || ($tense eq "future_perfect")
  || ($tense eq "past")
  || ($tense eq "pluperfect"))
  {
    my $helperVerb_b = $self->GetHelperVerb($verb_b, $reflexive_b);
    ($dummy, $dummy, $dummy, $dummy, 
    $dummy, $dummy, $s1_a, $s2_a, $s3a_a, $s3b_a, $s3c_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b, $p3b_b, $reflexive_a, $reflexive_b) 
    = $self->GetVTtoSParms($helperVerb_b,
    $self->GetHelperTense($tense),
    " " . $self->GetPastParticiple_English($verb_a) . $trailingString_a, 
    " " . $self->GetPastParticiple($verb_b) . $trailingString_b, 
    $reflexive_a,
    $reflexive_b,
    1);
    if ($helperVerb_b eq "#etre")
    {
      # then add endings to past participles
      $s3b_b = AdjustPastParticipleEnding($s3b_b, "e");
      $p1_b = AdjustPastParticipleEnding($p1_b, "s");
      $p2_b = AdjustPastParticipleEnding($p2_b, "s");
      $p3_b = AdjustPastParticipleEnding($p3_b, "s");
      $p3a_b = AdjustPastParticipleEnding($p3a_b, "s");
      $p3b_b = AdjustPastParticipleEnding($p3b_b, "es");
    } 
  }
  elsif (($tense eq "imperfect")
  || ($tense eq "future")
  || ($tense eq "subjunctive")
  || ($tense eq "imperative")
  || ($tense eq "passe_simple")
  || ($tense eq "conditional"))
  {
    ($s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b) = $self->ResolveEndings($stem_b, $inf_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b, $tense, $trailingString_b);
    #print "got back from ResolveEndings: $s1_b, $s2a_b, $s2b_b, $s3a_b, $p1_b, $p2_b, $p3a_b\n";
    
    $p3b_b = $p3a_b;
    ($s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a) = $self->GetEnglishConjugation("__unused__", $tense, $verb_a, $compoundPast, $trailingString_a, $s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a);
    $s3b_a = $s3c_a = $s3a_a;
  } 				
  else
  {
    $s1_b  = $self->Combine($stem_b, $s1_b)  . "$trailingString_b" if defined $s1_b;
    $s2a_b = $self->Combine($stem_b, $s2a_b) . "$trailingString_b" if defined $s2a_b;
    $s2b_b = $self->Combine($stem_b, $s2b_b) . "$trailingString_b" if defined $s2b_b;
    $s3a_b = $self->Combine($stem_b, $s3a_b) . "$trailingString_b" if defined $s3a_b;
    $s3b_b = $self->Combine($stem_b, $s3b_b) . "$trailingString_b" if defined $s3b_b;
    $s3c_b = $self->Combine($stem_b, $s3c_b) . "$trailingString_b" if defined $s3c_b;
    $p1_b  = $self->Combine($stem_b, $p1_b)  . "$trailingString_b" if defined $p1_b;
    $p2_b  = $self->Combine($stem_b, $p2_b)  . "$trailingString_b" if defined $p2_b;
    $p3a_b = $p3b_b = $self->Combine($stem_b, $p3a_b) . "$trailingString_b" if defined $p3a_b;
    							
    $s1_a  = $self->Combine($stem_a, $s1_a)  . "$trailingString_a" if defined $s1_a;
    $s2_a  = $self->Combine($stem_a, $s2_a)  . "$trailingString_a" if defined $s2_a;
    $s3a_a = $self->Combine($stem_a, $s3a_a) . "$trailingString_a"; # always
    $s3b_a = $self->Combine($stem_a, $s3b_a) . "$trailingString_a" if defined $s1_a;#elle faut?
    $s3c_a = $self->Combine($stem_a, $s3c_a) . "$trailingString_a" if defined $s1_a;#on faut?
    $p1_a  = $self->Combine($stem_a, $p1_a)  . "$trailingString_a" if defined $p1_a;
    $p2_a  = $self->Combine($stem_a, $p2_a)  . "$trailingString_a" if defined $p2_a;
    $p3_a  = $self->Combine($stem_a, $p3_a)  . "$trailingString_a" if defined $p3_a;
  }
  if ($reflexive_a && !$compoundPast)
  {
    $s1_a = $self->InsertReflexivePronoun_English($s1_a, "myself");
    $s2_a = $self->InsertReflexivePronoun_English($s2_a, "yourself");
    $s3a_a = $self->InsertReflexivePronoun_English($s3a_a, "himself");
    $s3b_a = $self->InsertReflexivePronoun_English($s3b_a, "herself");
    $s3c_a = $self->InsertReflexivePronoun_English($s3c_a, "oneself");
    $p1_a = $self->InsertReflexivePronoun_English($p1_a, "ourselves");
    $p2_a = $self->InsertReflexivePronoun_English($p2_a, "yourselves");
    $p3_a = $self->InsertReflexivePronoun_English($p3_a, "themselves");
  }
  
  
  #print "returning $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $s3c_a, $p1_a, $p2_a, $p3_a\n";
  return ($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $s3c_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b, $p3b_b, $reflexive_a, $reflexive_b);
}

sub GetPersonalPronouns
{
  # @actions was $s1_b, $s2_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b, $p3b_b
  my($self, $reflexive, @actions) = @_;
     
  if ($reflexive)
  {
    return $self->AforVowels_BforConsonants(\@actions, 
    [ "je m'^D ", "tu\nt'^D ", "il s'^D ", "elle s'^D ", "on s'^D ", "nous nous ", "vous\nvous ", "ils s'^D ", "elles s'^D " ],
    [ "je me ", "tu\nte ", "il se ", "elle se ", "on se ", "nous nous ", "vous\nvous ", "ils se ", "elles se " ]);
  }
  else
  {
    return $self->AforVowels_BforConsonants(\@actions, 
    ["j'^D ", "tu\n", "il ", "elle ", "on ", "nous ", "vous\n", "ils ", "elles "],
    ["je ", "tu\n", "il ", "elle ", "on ", "nous ", "vous\n", "ils ", "elles "]);
  }
}

sub VTtoS
{
  my($self, $verb_b, $tense, $doingVerbTable) = @_;
  #print "VtoS($verb_b, $tense)\n";

  my($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $s3c_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b,$p3b_b,$reflexive_a, $reflexive_b)
  = $self->GetVTtoSParms($verb_b,$tense,'','',undef,undef,0);

  #print "VTtoS(stem_b=$stem_b, inf_b=$inf_b, pastParticiple_b=$pastParticiple_b, pastParticiple_a=$pastParticiple_a, stem_a=$stem_a, inf_a=$inf_a, s1_a=$s1_a, s2_a=$s2_a, s3a_a=$s3a_a, p1_a=$p1_a, p2_a=$p2_a, p3_a=$p3_a, s1_b=$s1_b, s2a_b=$s2a_b, s2b_b=$s2b_b, s3a_b=$s3a_b, p1_b=$p1_b, p2_b=$p2_b, p3a_b=$p3a_b, p3b_b=$p3b_b, $reflexive_a, $reflexive_b)\n";
  #exit(0);

  my $hdr_inf_a = $self->Get_verb_a_withToIfAppropriate($verb_b);

  $self->VerbGenInit($verb_b);
  my @s = ();
  my @p = ();
  if ($tense eq "imperative")
  {
    if ($reflexive_b)
    {
      $self->X(   $tense,       "$s2_a!", "s2a",     "$p2_b-vous!",     $p2_b) if defined $p2_b;

      push @s, $self->X($tense, "$s2_a!", "s2b",     "$s2b_b-toi!",     $s2b_b) if defined $s2b_b;
      $self->X(   $tense, "don't $s2_a!", "s2b_no", "ne $s2b_b-toi pas!", $s2b_b) if defined $s2b_b;

      push @p, $self->X($tense, "let's $p1_a!",     "p1",    "$p1_b-nous!",        $p1_b) if defined $p1_b;
      $self->X(         $tense, "let's not $p1_a!", "p1_no", "ne nous $p1_b pas!", $p1_b) if defined $p1_b;

      push @p, $self->X($tense, "$p2_a!", "p2a",     "$p2_b-vous!",     $p2_b) if defined $p2_b;
      $self->X(   $tense,       "$p2_a!", "p2b",     "$p2_b-vous!",     $p2_b) if defined $p2_b;
      $self->X(   $tense, "don't $p2_a!", "p2b_no", "ne $p2_b-vous pas!", $p2_b) if defined $p2_b;
    }
    else
    {
      $self->X(   $tense,       "$p2_a!", "s2a",     "$p2_b!",     $p2_b) if defined $p2_b;
      push @s, $self->X($tense, "$s2_a!", "s2b",     "$s2b_b!",     $s2b_b) if defined $s2b_b;
      $self->X(   $tense, "don't $s2_a!", "s2b_no", "ne $s2b_b pas!", $s2b_b) if defined $s2b_b;

      push @p, $self->X($tense, "let's $p1_a!",     "p1",    "$p1_b!",        $p1_b) if defined $p1_b;
      $self->X(         $tense, "let's not $p1_a!", "p1_no", "ne $p1_b pas!", $p1_b) if defined $p1_b;

      push @p, $self->X($tense, "$p2_a!", "p2a",     "$p2_b!",     $p2_b) if defined $p2_b;
      $self->X(   $tense,       "$p2_a!", "p2b",     "$p2_b!",     $p2_b) if defined $p2_b;
      $self->X(   $tense, "don't $p2_a!", "p2b_no", "ne $p2_b pas!", $p2_b) if defined $p2_b;
    }
  }
  else
  {
    my($pp_s1_b, $pp_s2_b, $pp_s3a_b, $pp_s3b_b, $pp_s3c_b, $pp_p1_b, $pp_p2_b, $pp_p3a_b, $pp_p3b_b) = $self->GetPersonalPronouns($reflexive_b, $s1_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3a_b, $p3b_b);
    if (!defined $pastParticiple_b)
    {
      $pastParticiple_b = $self->GetPastParticiple($verb_b);
    }

    if ($self->GetOverride("$verb_b", "it only"))
    {
      push @s, $self->X($tense, "it $s3a_a", "s3a", "$pp_s3a_b$s3a_b", $s3a_b);;
    }
    else
    {
      push @s, $self->X($tense, "I $s1_a", "s1", "$pp_s1_b$s1_b", $s1_b) if defined $s1_b;
      $self->X(         $tense, "you $s2_a", "s2a", "$pp_p2_b$s2a_b", $s2a_b) if defined $s2a_b;
      push @s, $self->X($tense, "you $s2_a", "s2b", "$pp_s2_b$s2b_b", $s2b_b) if defined $s2b_b;
      push @s, $self->X($tense, "he $s3a_a", "s3a", "$pp_s3a_b$s3a_b", $s3a_b) if defined $s3a_b;
      push @s, $self->X($tense, "she $s3b_a", "s3b", "$pp_s3b_b$s3b_b", $s3b_b) if defined $s3b_b;
      push @s, $self->X($tense, "one $s3c_a", "s3c", "$pp_s3c_b$s3c_b", $s3c_b) if defined $s3c_b;

      #if ($tense =~ /^(passe_simple|imperfect|present|future|subjunctive)$/)
      #{
      #print ">>$verb_b: he $s3a_a.  $pp_s3a_b$s3a_b\n";
      #print ">>$verb_b: we $p1_a.  $pp_p1_b$p1_b\n\n";
      #}

      push @p, $self->X($tense, "we $p1_a", "p1", "$pp_p1_b$p1_b", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "you $p2_a", "p2", "$pp_p2_b$p2_b", $p2_b) if defined $p2_b;
      push @p, $self->X($tense, "they $p3_a", "p3a", "$pp_p3a_b$p3a_b", $p3a_b) if defined $p3a_b;
      push @p, $self->X($tense, "they $p3_a", "p3b", "$pp_p3b_b$p3b_b", $p3b_b) if defined $p3b_b;
    }
  }
  return $self->ComposeVTOutput($tense, $hdr_inf_a, $verb_b, $doingVerbTable, \@s, \@p);
}

sub GetTenses
{
  return [ "present", "past", "passe_simple", "imperfect", "future", "conditional", "past_conditional", "future_perfect", "pluperfect", "subjunctive", "imperative" ];
}

sub AddEndings
{
  my($self, $stem_b, $tense, $trailingString) = @_;
  my ($stem_sp3, $stem_p12) = $self->SplitItem($stem_b);
  #print "AddEndings($stem_b( -> $stem_sp3, $stem_p12), $tense, $trailingString)\n";
  if ($tense eq "future")
  {
    return (
    "${stem_sp3}ai$trailingString",
    "${stem_sp3}as$trailingString",
    "${stem_sp3}a$trailingString",
    "${stem_sp3}a$trailingString",
    "${stem_sp3}a$trailingString",
    "${stem_p12}ons$trailingString",
    "${stem_p12}ez$trailingString",
    "${stem_sp3}ont$trailingString"
    );
  }
  elsif ($tense eq "passe_simple")
  {
    my $stem = $stem_sp3;
    warn $stem if $stem =~ /;/;
    die $stem unless $stem =~ /^(.*)(.)$/;
    $stem = $1;
    my $lastChar = $2;

    $stem_p12 = $stem;
    $stem_p12 =~ s/#$//;

    if ($lastChar eq "a")	# -er verbs
    {
      my $stem_p3 = $stem;
      $stem_p3 = $1 if $stem_p3 =~ /(.*)e$/;
      return (
      "${stem}ai$trailingString",
      "${stem}as$trailingString",
      "${stem}a$trailingString",
      "${stem}a$trailingString",
      "${stem}a$trailingString",
      "${stem_p12}#ames$trailingString",
      "${stem_p12}#ates$trailingString",
      "${stem_p3}`erent$trailingString"
      );
    }
    else
    {
      return (
      "${stem}${lastChar}s$trailingString",
      "${stem}${lastChar}s$trailingString",
      "${stem}${lastChar}t$trailingString",
      "${stem}${lastChar}t$trailingString",
      "${stem}${lastChar}t$trailingString",
      "${stem_p12}#${lastChar}mes$trailingString",
      "${stem_p12}#${lastChar}tes$trailingString",
      "${stem}${lastChar}rent$trailingString"
      );
    }
  }
  elsif (($tense eq "imperfect")
  || ($tense eq "conditional"))
  {
    return (
    "${stem_sp3}ais$trailingString",
    "${stem_sp3}ais$trailingString",
    "${stem_sp3}ait$trailingString",
    "${stem_sp3}ait$trailingString",
    "${stem_sp3}ait$trailingString",
    "${stem_p12}ions$trailingString",
    "${stem_p12}iez$trailingString",
    "${stem_sp3}aient$trailingString"
    );
  }
  elsif ($tense eq "subjunctive")
  {
    return (
    "${stem_sp3}e$trailingString",
    "${stem_sp3}es$trailingString",
    "${stem_sp3}e$trailingString",
    "${stem_sp3}e$trailingString",
    "${stem_sp3}e$trailingString",
    "${stem_p12}ions$trailingString",
    "${stem_p12}iez$trailingString",
    "${stem_sp3}ent$trailingString"
    );
  }
  else
  {
    die "tense $tense";
  }
}

sub ResolveEndings
{
  my($self, $stem_b, $inf_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b, $tense, $trailingString_b) = @_;
  my $verb_b = "$stem_b$inf_b";
  #print "French_grammar::ResolveEndings($stem_b, $inf_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b, $tense, $trailingString_b)\n";

  my $conjugation = $self->GetOverrideList($verb_b, $tense);
  if (defined $conjugation)
  {
    #Ndmp::Ah("ResolveEndings fetched overridden tense for ($verb_b, $tense) $trailingString_b", $conjugation);
    my $ref = nlist::catAll($conjugation, $trailingString_b);
    #Ndmp::Ah("ResolveEndings from catAll", $ref);
    ($s1_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b) = @$ref;
    $s2a_b = $p2_b;
    return ($s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b);
  }

  if ($tense eq "imperative")
  {
    $s1_b = $self->Combine($stem_b, $s1_b) . "$trailingString_b" if defined $s1_b;
    $s2a_b = $self->Combine($stem_b, $s2a_b) . "$trailingString_b" if defined $s2a_b;
    $s2b_b =~ s/es$/e/ if defined $s2b_b;
    $s2b_b = $self->Combine($stem_b, $s2b_b) . "$trailingString_b" if defined $s2b_b;
    $s3a_b = $self->Combine($stem_b, $s3a_b) . "$trailingString_b"; # always
    $s3b_b = $self->Combine($stem_b, $s3b_b) . "$trailingString_b" if defined $s1_b;
    $s3c_b = $self->Combine($stem_b, $s3c_b) . "$trailingString_b" if defined $s1_b;
    $p1_b = $self->Combine($stem_b, $p1_b) . "$trailingString_b" if defined $p1_b;
    $p2_b = $self->Combine($stem_b, $p2_b) . "$trailingString_b" if defined $p2_b;
    $p3_b = $self->Combine($stem_b, $p3_b) . "$trailingString_b" if defined $p3_b;

    return ($s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b); # no-op -- just use the present settings
  }

  my $conjugationStem = $self->GetOverride($verb_b, $tense);

  if (defined $conjugationStem)
  {
    ;
  }
  elsif ($tense eq "subjunctive"
  ||     $tense eq "imperfect"
  ||     $tense eq "passe_simple")
  {
    $conjugationStem = $self->GetStem($verb_b, $tense);
  }
  elsif (($tense eq "future")
  || ($tense eq "conditional"))
  {
    if ($verb_b =~ /(\S+)yer( .*)?$/)
    {
      $conjugationStem = "${1}ier";
    }
    elsif ($verb_b =~ /(\S+r)( .*)?/)
    {
      $conjugationStem = $1;
    }
    else
    {
      $conjugationStem = $verb_b;
    }
  }
  ($s1_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b) = $self->AddEndings($conjugationStem, $tense, $trailingString_b);
  $s2a_b = $p2_b;
  return ($s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $s3c_b, $p1_b, $p2_b, $p3_b);
}

sub AdjustPastParticipleEnding
{
  my($argX, $suffix) = @_;
  my $x = $argX;
  my $trailer = "";
  # allow one space to separate #etre form from the pp, but strip off rest:
  if ($x =~ /^([^ ]+ [^ ]+)( .*)/)
  {
    $x = $1;
    $trailer = $2;
  }

  #print "suffix=$suffix, x=$x\n";


  if (($suffix ne "s")
  || ($x !~ /s$/))
  {
    $x .= $suffix;
  }
  $x .= $trailer;
  #print "French_grammar::AdjustPastParticipleEnding($argX, $suffix): $x\n";
  return $x;
}

sub MakeRecursive
{
  my($self, $verb) = @_;
  return  "s'$verb" if $verb =~ m{^[`#/]?[aeiouh]};
  return "se $verb";
}

sub StripReflexivity
{
  my($self, $verb_b) = @_;
  $verb_b =~ s/^(se |s')//;
  return $verb_b;
}

sub SetReflexivity_b
{
  my($self, $verb_b, $argsRef) = @_;
  
  my $stem_b_ref = \$argsRef->[0];
  my $reflexive_b = '';
  if ($$stem_b_ref =~ /^(se )(.*)/ || $$stem_b_ref =~ /^(s')(.*)/)
  {
    $reflexive_b = $verb_b;
    $$stem_b_ref = $2;
  }
  elsif ($verb_b =~ /^(se )(.*)/ || $verb_b =~ /^(s')(.*)/)
  {
    # If this verb characteristic vector was set by EqVerb, and the
    # paradigm verb is not reflexive, then the first if-test will fail.  
    # However, if the new verb is reflexive, then we need to update 
    # the new verb characteristic vector:
    $reflexive_b = $verb_b;
  }

  #print "SetReflexivity_b($$stem_b_ref): $reflexive_b\n";
  $argsRef->[18] = $reflexive_b;
  return $reflexive_b;
}

sub EqVerbDerivePatterns
{
  my($self, $verb, $paradigmVerb) = @_;
  $verb = $2 if $verb =~ /(se |s')(.*)/;
  $verb = $1 if $verb =~ /(.*)2$/;
  $verb = $1 if $verb =~ /(\S+)( .*)$/;

  my $a1 = undef;
  my $a2 = undef;
  my $b1 = undef;
  my $b2 = undef;

  if ($paradigmVerb =~ /^jeter$/)
  {
    die "lskdj" unless $verb =~ /^(.*e(.))er$/;
    ($a1, $a2) = ($1, $2);
    ($b1, $b2) = ("^jet", "t");
  }
  elsif ($paradigmVerb =~ /^lever$/)
  {
    die "lskdj" unless $verb =~ /^(.*)(e.)er$/;
    ($a1, $a2) = ($1, $2);
    ($b1, $b2) = ("^l", "ev");
  }
  elsif ($paradigmVerb =~ m{^r/ep/eter$})
  {
    die "lskdj" unless $verb =~ m{^(.*)/(e.*)er$};
    ($a1, $a2) = ($1, $2);
    ($b1, $b2) = ("^r/ep", "et");
  }
  elsif ($paradigmVerb =~ /^recevoir$/)
  {
    die "lskdj" unless $verb =~ /^(.*)cevoir$/;
    ($b1, $a1) = ("^re", $1);
  }
  elsif ($paradigmVerb eq "conna#itre")
  {
    die "lskdj" unless $verb =~ /^(.*)a\#itre$/;
    ($b1, $a1) = ("^conn", $1);
  }
  elsif ($paradigmVerb eq "prendre")
  {
    die $verb unless $verb =~ /^(.*)endre$/;
    ($b1, $a1) = ("^pr", $1);
  }
  elsif ($paradigmVerb =~ /^(mettre|craindre)$/)
  {
    die "lskdj" unless $verb =~ /(.*).....$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*).....$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{([tv]enir|envoyer|faire|m/edire|plaire)$})
  {
    die "lskdj" unless $verb =~ /(.*)....$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*)....$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ /(^offrir|ouvrir|rire|.*[cgy]er)$/)
  {
    die "lskdj" unless $verb =~ /(.*)...$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*)...$/;
    $b1 = "^$1";
  }
  else
  {
    die "lskdj" unless $verb =~ /(.*)..$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*)..$/;
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

sub VerbsOnlyDifferInReflexivity
{
  my($self, $verb1, $verb2) = @_;
  $verb1 = $2 if $verb1 =~ /(s'|se )(.*)/;
  $verb2 = $2 if $verb2 =~ /(s'|se )(.*)/;
  return $verb1 eq $verb2;
}

sub GetAuxiliaryVerbs
{
  my($self) = @_;
  return ( "avoir", "#etre" );
}

sub IsModifiedPastParticiple
{
  my($self, $token, $id) = @_;
  my $val = ($token =~ m{([^/]e|[^i]s)$});
  if (!$val && ($token =~ /(.*i)s$/))
  {
    # avoid false hits (eg, permis) but catch the real ones (eg, ils sont sortis)
    my($context, $verb, $possiblyAmbiguous) = $self->VtlLookup($1, $id, "past participle");
    if (defined $context)
    {
      $val = 1;
    } 
  }
  #print "French_grammar::IsModifiedPastParticiple($token): $val\n";
  return $val;
}

sub ExplainAdjectivalChange
{
  my($self, $modifiedAdjective, $unmodifiedAdjective) = @_;
      
  my $val = undef;
  if ($modifiedAdjective =~ m{/es$})
  {
    $val = "plural";
  }
  elsif ($modifiedAdjective =~ /es$/)
  {
    $val = "feminine and plural";
  }
  elsif ($modifiedAdjective =~ /[sx]$/)
  {
    $val = "plural";
  }
  elsif ($modifiedAdjective =~ /e$/)
  {
    $val = "feminine";
  }
  else
  {
    die "odd: $unmodifiedAdjective, " . $self->Get__currentToken();
  }
  #print "French_grammar::ExplainAdjectivalChange($modifiedAdjective, $unmodifiedAdjective): $val\n";
  return $val;
}
 


sub PastParticipleMustAgreeWithSubject
{
  my($self, $subject) = @_;
  return $self->AdjectivalExpressionMustAgree("When a compound past tense is formed using\n,#etre\n, the past participle is treated like an adjective of the subject, and so must agree with that subject in gender and number.", $subject, "subject", "=Verbs=past=with_etre", "forming the past using ,#etre");
}

sub DeriveUnmodifiedAdjective
{
  my($self, $token) = @_;
  my $val;
  if ($token =~ m{(.*/e)s$})
  {
    $val = $1;
  }
  elsif ($token =~ m{(.*)e$})
  {
    $val = $1;
  }
  elsif ($token =~ m{(.*)es$})
  {
    $val = $1;
  }
  elsif ($token =~ m{(.*)s$})
  {
    $val = $1;
  }
  else
  {
    die "bad $token";
  }
  #print "French_grammar::DeriveUnmodifiedAdjective($token): $val\n";
  return $val;
}

sub MakeAdditionalNotes
{
  my($self, $context, $verb_b) = @_;
  die $context unless defined $verb_b;

  #print "$self->MakeAdditionalNotes($context, $verb_b) with ct = \"$self->Get__currentToken()\"\n";
  my $add = "";

  if ($context eq "passe_simple")
  {
    $add .= $self->{"noteDivider"} . $self->ResolveNote("fr_ps");
  }

  if (($verb_b =~ /er$/)
  && ($self->Get__currentToken() =~ /e$/)
  && ($context eq "imperative"))
  {
    $add .= $self->{"noteDivider"} . $self->ResolveNote("no_s_for_tu_with_er");
  }

  $context = "present" if $context eq "imperative";

  if (($verb_b =~ /[^di]re$/)
  && ($verb_b ne "#etre")
  && ($self->Get__currentToken() =~ /t$/)
  && ($context eq "present"))
  {
    $add .= $self->{"noteDivider"} . $self->ResolveNote("frenchNo_d_means_3s_t");
  }
  if (($verb_b =~ /cer$/)
  && ($self->Get__currentToken() =~ /,c[ao].?.?$/)
  && (($context eq "present") || ($context eq "imperfect")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-cer");
    $add .= " This form illustrates " . $self->MakeLink("<i>-cer</i> verbs' spelling changes in the $context tense", $link) . ".";
  }
  if (($verb_b =~ m{/e.er$})
  && ($self->Get__currentToken() =~ /`e.es?$/)
  && (($context eq "present")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-e.er");
    $add .= $self->{"noteDivider"} . "This form illustrates " . $self->MakeLink("$context tense spelling changes undergone by ,-er verbs' with\n,/e\nin the last syllable of the stem", $link) . ".";
  }
  if (($verb_b =~ m{[^/`]e.er$})
  &&
  (  (($self->Get__currentToken() =~ /`e.es?$/) && ($context eq "present"))
  || (($self->Get__currentToken() =~ /`e.er(ai|as|a|ons|ez|ont)$/) && ($context eq "future"))
  || (($self->Get__currentToken() =~ /`e.er(ais|ait|ions|iez|aient)$/) && ($context eq "conditional"))
  ))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "silent_e");
    $add .= $self->{"noteDivider"} . "This form illustrates " . $self->MakeLink("$context tense spelling changes undergone by ,-er verbs with a silent ,e in the last syllable of the stem", $link) . ".";

  }
  if (($verb_b =~ /ger$/)
  && ($self->Get__currentToken() =~ /ge[ao].?.?$/)
  && (($context eq "present") || ($context eq "imperfect") || ($context eq "future") || ($context eq "conditional")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-ger");
    $self->VerifyURL($link);
    $add .= " This form illustrates " . $self->MakeLink("<i>-ger</i> verbs' spelling changes in the $context tense", $link) . ".";
  }
  if (($verb_b =~ /yer$/)
  && ($self->Get__currentToken() =~ /[aou]ie/)
  && (($context eq "present") || ($context eq "future") || ($context eq "conditional")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-yer");
    $self->VerifyURL($link);
    $add .= " This form illustrates " . $self->MakeLink("<i>-yer</i> verbs' spelling changes in the $context tense", $link) . ".";
    if ($verb_b =~ /ayer$/)
    {
      $add .= " Note that these changes are <i>optional</i> for <i>$verb_b</i> (and all other <i>-ayer</i> verbs).";
    }
  }
  if (($verb_b =~ /eter$/)
  && ($self->Get__currentToken() =~ /ette/)
  && (($context eq "present") || ($context eq "future") || ($context eq "conditional")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-ler_and_ter");
    $self->VerifyURL($link);
    $add .= " This form illustrates " . $self->MakeLink("<i>-ter</i> verbs' spelling changes in the $context tense", $link) . ".";
  }
  if (($verb_b =~ /eler$/)
  && ($self->Get__currentToken() =~ /elle/)
  && (($context eq "present") || ($context eq "future") || ($context eq "conditional")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-er", "-ler_and_ter");
    $self->VerifyURL($link);
    $add .= " This form illustrates " . $self->MakeLink("<i>-ler</i> verbs' spelling changes in the $context tense", $link) . ".";
  }
  #print "French_grammar::MakeAdditionalNotes($context, $verb_b): $add\n" if (Argv_db::FlagSet("MassageAndFootnoteDebug"));
  return $add;
}

sub OnEndOfGrammarGeneration
{
  my($self) = @_;
  $self->OverrideVerbTableLookup("tu");	# fr: past participle of taire v. personal pronoun
  $self->OverrideVerbTableLookup("suis", ";present.#etre;"); # stop suivre from confusing things

  my $informalP2IsVous = 'Although ,vous is considered a formal form, since French has no informal plural second person pronoun, ,vous is appropriate for informally addressing more than one person, e.g., a couple of toddlers.';
  my $informalP2IsImpliedVous = 'Like in English, one does not explicitly use a pronoun in the imperative (e.g., "Stop smoking!" not "You stop smoking!"); in this case, there is an implied <i>vous</i>.';

  $informalP2IsImpliedVous .= $self->{"noteDivider"} . $informalP2IsVous;

  $self->SaveNote('informalP2IsVous',        $informalP2IsVous,        'Verbs=personal_pronouns', 'personal pronouns');
  $self->SaveNote('informalP2IsImpliedVous', $informalP2IsImpliedVous, 'Verbs=personal_pronouns', 'personal pronouns');
  $self->SaveNote('fr_ps', 'Note that French people don\'t use this tense in spoken conversation; instead they use the " . $self->MakeLink("<i>pass/e compos/e</i>", French.html#=Verbs=passe_simple) . ".', 'Verbs=passe_simple', '<i>pass/e simple</i>');

  $self->SUPER::OnEndOfGrammarGeneration();
}

sub FoundCompoundTense
{
  my($self, $notesByVerbRef, $verb, $token, $id, $possiblyAmbiguous, $context) = @_;

  if ($context eq "possible past participle")
  {
    if ($token =~ m{/et/e}i)
    {
      return 0;	# too many mis-hits
    }
  }
  return $self->SUPER::FoundCompoundTense($notesByVerbRef, $verb, $token, $id, $possiblyAmbiguous, $context);
}

sub ResolveVtlLookupAmbiguity
{
  my($self, $token, $vtlVal, $areas, $id) = @_;
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "subjunctive", "present");
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "subjunctive", "imperfect");
  $self->SUPER::ResolveVtlLookupAmbiguity($token, $vtlVal, $areas, $id);
}


sub LooksLikeRecursiveUse
{
  my($self, $rawToken, $s) = @_;

  my $val = 0;
  #print "French_grammar::LooksLikeRecursiveUse($rawToken, $s) after cleaning\n";

  if ($s =~ /$rawToken-(vous|nous|toi).*[^\?]/i)
  {
    # hypenated to a pronoun and it's not a question -- this must be imperative reflexive
    $val = 1;
  }
  else
  {
    # the '.*' is to cover the possibility of a helper verb
    $val = ($s =~ /(nous nous |vous vous |(elle|il|on)s? s('|e )|tu t('|e )|je m('|e )).*$rawToken/i);
  }
  #print "French_grammar::LooksLikeRecursiveUse($rawToken, $s): $val\n";
  return $val;
}

sub IsRecursive
{
  my($self, $verb) = @_;
  return $verb =~ /^(s'|se )/;
}

sub CookTense
{
  my($self, $tense, $precedingWord) = @_;
  if ($tense eq "past")
  {
    return $self->MeToHtml("<i>pass/e compos/e</i>");
  }
  elsif ($tense eq "passe_simple")
  {
    return $self->MeToHtml("<i>pass/e simple</i>");
  }
  return $self->SUPER::CookTense($tense, $precedingWord);
}

sub MassageAndFootnoteForOneToken
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified) = @_;
  if ($thisTokenIsPermanentlyIdentified)
  {
    return;
  }
  if ($normalizedToken eq "cet")
  {
    $self->ProposeLangNote($token, undef, 0, undef, "fr_cet");
  }
  else
  {
    $self->SUPER::MassageAndFootnoteForOneToken($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified);
  }
}

sub X
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm, $suppressVtl) = @_;
    
  $other =~ s/^ne (\W?[aehiou])/n'^D $1/g;	# the \W? is to account for accents
  if ($tense eq "imperative")
  {
    $other =~ s/-/^D -/;  # separate imperative reflexive constructs (eg, Accordez-vous!)
  }
  return $self->SUPER::X($tense, $english, $pronounCode, $other, $verbForm, $suppressVtl);
}

sub InsertAddend_adjustRecursiveInfinitiveToMatchPronoun
{
  my($self, $id, $adjustedAddend) = @_;
  my $pronounCode = $self->GetPronoun($id);
  die $id unless defined $pronounCode;
  my $adjustedPronoun = "se";
  if ($pronounCode =~ /p1/)
  {
    $adjustedPronoun = "nous";
  }
  elsif ($pronounCode =~ /(p2|s2)/)
  {
    $adjustedPronoun = "vous";
  }
  elsif ($pronounCode =~ /s1/)
  {
    $adjustedPronoun = "me";
  }
  elsif ($pronounCode =~ /s2b/)
  {
    $adjustedPronoun = "te";
  }
  $adjustedAddend =~ s/>se>/$adjustedPronoun/g;
  #print "French_grammar::InsertAddend_adjustRecursiveInfinitiveToMatchPronoun($id, $adjustedAddend)\n";
  return $adjustedAddend;
}

sub AnalyzeNounPhrase
{
  my($self, $other) = @_;

  my ($determiner, $place, $placeGender, $isModified);
  if ($other =~ m{(les) (/Etats-Unis)})
  {
    ($determiner, $place, $placeGender, $isModified) = ($1, $2, 'm', 0);
  }
  elsif ($other =~ m{^(\S+)$})
  {
    $determiner = undef;
    $place = $1;
    $placeGender = $self->GetNounGender($place, 0);
    $isModified = 0;
  }
  else
  {
    if ($other !~ m{^(les?|la|l'\^D) (\S+)$}
    && $other !~ m{^(les?|la|l'\^D) (\S+) (\S+)$}
    && $other !~ m{^(les?|la|l'\^D) (\S+) (\S+) (\S+)$})
    {
      return (undef, undef, undef, undef);
    }
    $determiner = $1;
    my $word1 = $2;
    my $word2 = $3;
    my $word3 = $4;

    #print "French_grammar::AnalyzeNounPhrase($other): regexp: " . nutil::ToString($determiner) . ", " . nutil::ToString($word1) . ", " . nutil::ToString($word2) . ", " . nutil::ToString($word3) . "\n";

    $placeGender = $self->GetNounGender($word1, 1);
    if (defined $placeGender)
    {
      $place = $word1;
    }
    else
    {
      $placeGender = $self->SUPER::GetNounGender($word2, 1);
      if (defined $placeGender)
      {
	$place = $word2;
      }
      else
      {
	$placeGender = $self->SUPER::GetNounGender($word3, 1);
	if (defined $placeGender)
	{
	  $place = $word3;
	}
	else
	{
	  nutil::Warn("Could not figure out the gender for this place: $other");
	}
      }
    }
    # The second part of the test is designed to avoid treating multiword place
    # names, like la Grande Bretagne, as modified place names.  "Grande" is part
    # of the name, and is not an adjective for the purposes of this test:
    $isModified = (defined $word2 && ($word1 !~ /^[A-Z]/));
  }
  #print "French_grammar::AnalyzeNounPhrase($other): (" . nutil::ToString($determiner) . ", " . nutil::ToString($place) . ", " . nutil::ToString($placeGender) . ", " . nutil::ToString($isModified) . ")\n";
  return($determiner, $place, $placeGender, $isModified);
}

sub OnUnifyCharacteristicsOf_1_ObjectPhrase
{
  my($self, $key, $otherParm, $addendKey) = @_;
  #print "French_grammar::OnUnifyCharacteristicsOf_1_ObjectPhrase($key, $otherParm, $addendKey)\n";

  my $other = $otherParm;

  if (defined $addendKey)
  {
    # need to look at the whole thing to catch multiword places like "la Havane"
    if (defined $self->HashGet("cities", $other))
    {
      $other = "`a $other";
      $self->SetNote($key, "`a", "toCity");
    }
    elsif (($addendKey =~ /^vocab_languages/) && ($key =~ /verb_speak/))
    {
      my $token = undef;
      if ($other =~ s/^(le|la) //)
      {
	$token = "$1";
      }
      if ($other =~ s/^(des|du) /de /)
      {
	$token = "$1";
      }
      elsif ($other =~ s/^l'(\^D )?//)
      {
	$token = "l";
      }
      tdb::Set($key, $self->MakeTokenNoteKey($token, "tmp"), undef) if defined $token;

      # This footnote is already in the vocab_languages data as a global note, and
      # so it gets picked up by the absorbing exercise as well.  So if we include
      # it here, the note shows up twice.  But this would be a little bit nicer,
      # associating the superscript with the language noun, instead of the entire
      # sentence.  Maybe another day...
      #
      # my $langNoun = $1 if $other =~ /(\S+)/;
      # $self->SetNote($key, $langNoun, "fr_le_lang");
    }
    elsif ($addendKey =~ /^vocab_geography/)
    {
      my($determiner, $place, $placeGender, $isModified) = $self->AnalyzeNounPhrase($other);

      #print "French_grammar::OnUnifyCharacteristicsOf_1_ObjectPhrase($key, $otherParm, $addendKey): " . nutil::ToString($determiner) . "/" . nutil::ToString($place) . "/" . nutil::ToString($placeGender) . "/" . nutil::ToString($isModified) . "\n";

      my $done = 0;
      if (defined $determiner && defined $place && defined $placeGender && defined $isModified)
      {
	if ($isModified)
	{
	  $other = "dans $other";
	  $self->SetNote($key, "dans", "toModifiedPlaceName");
	  $self->SetNote($key, $determiner, "placesRequireDeterminer", "2");
	  $done = 1;
	}
	elsif (defined $self->HashGet("cities", $place))
	{
	  $other =~ s/$place/`a $place/;
	  $self->SetNote($key, "`a", "toCity");
	  $done = 1;
	}
      }
      if (!$done && defined $place && defined $placeGender)
      {
	if ($placeGender eq "m")
	{
	  $other = "`a $other";
	  $self->SetNote($key, "`a", "toMasculineCountry");
	  $self->SetNote($key, $determiner, "placesRequireDeterminer", "2");
	  $other = $self->UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $other);
	}
	else
	{
	  $other =~ s/^(la|l'\^D)/en/;
	  $self->DropNotes($key, $determiner);
	  $self->SetNote($key, "en", "toFeminineCountry");
	}
      }
    }
  }
  #print "French_grammar::OnUnifyCharacteristicsOf_1_ObjectPhrase($key, $otherParm, $addendKey): $other\n";
  return $other;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions
{
  my($self, $key, $s) = @_;
  my $val = $s;
  $val = $self->SUPER::UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val);

  $val =~ s{\bde ([/`#]?[aeiouh])}{d'^D $1}gi;
  
  print "French_grammar::UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $s): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub CleanUpPartitive
{
  my($self, $key, $otherParm) = @_;
  my $other = $otherParm;
  my $deAlreadyInSentence = ($other =~ / de /);
  while ($other =~ s/ pas( ({})?)(des) / pas${1}de /g)
  {
    my $eliminatedToken = $3;
    $self->DeleteNotes($key, $eliminatedToken);
    if (!$deAlreadyInSentence)
    {
      my $note = "In negative expressions, use ,de after ,pas instead of ,des.";
      tdb::Set($key, $self->MakeTokenNoteKey("de", "2"), $note);
    }
  }
  while ($other =~ s{ pas( ({})?)de ([`/#]?[aeiouh])}{ pas${1}d'^D $3}g)
  {
    $self->MoveNotes($key, "de", "d");
  }

  # don't allow "de des"...
  if ($other =~ s/\bde des\b/de/g)
  {
    $self->DeleteNotes($key, "des");
  }

  #print "French_grammar::CleanUpPartitive($key, $otherParm): $other\n";
  return $other;
}


sub FootnoteAspiratedHs
{
  my($self, $key, $other) = @_;
  while ($other =~ /\b(de|je|la|le|ne) _(h\S+)/g)
  {
    my $precedingPotentialCombiner = $1;
    my $wordStartingWithAnAspiratedH = $2;

    my $shortenedPrecedingPotentialCombiner = $precedingPotentialCombiner;
    chop $shortenedPrecedingPotentialCombiner;

    my $note = "Although <i>$precedingPotentialCombiner</i> becomes <i>$shortenedPrecedingPotentialCombiner</i> before a silent <i>h</i> (or vowel), in this case the <i>h</i> following it is not silent (cf. " . $self->MakeGrammarLink("Words Starting with Vowels and Silent <i>h</i>'s", "=Contractions=aspirated_h") . ".";
    tdb::Set($key, $self->MakeTokenNoteKey($precedingPotentialCombiner, "2"), $note);
    $self->MoveNotes($key, "_$wordStartingWithAnAspiratedH", $wordStartingWithAnAspiratedH);
  }
}

sub OnExerciseGeneration
{
  my($self, $key, $english, $tense, $pronounCode, $other, $verbForm, $verb_a, $verb_b) = @_;

  # ignore imperatives since "vous" is not explicitly for them:
  if ($pronounCode =~ /p2b/)
  {
    # Add a note; a cannot be temporary, because we are at this time before the "propose Notes" stage,
    # which eliminates all temporary Notes as part of its initialization:
    if ($tense eq "imperative")
    {
      $self->SetNote($key, undef, "informalP2IsImpliedVous", 1);
    }
    elsif ($tense eq "subjunctive")
    {
      $self->SetNote($key, "vous", "informalP2IsVous", 1);	# no cap, since $other is "...que vous...", not "Vous..."
    }
    else
    {
      $self->SetNote($key, "Vous", "informalP2IsVous", 1);
    }
  }

  $self->FootnoteAspiratedHs($key, $other);
  return $self->SUPER::OnExerciseGeneration($key, $english, $tense, $pronounCode, $other, $verbForm, $verb_a, $verb_b);
}

sub UnifyCharacteristicsOfObjectPhrases
{
  my($self, $key, $other) = @_;
  $other = $self->SUPER::UnifyCharacteristicsOfObjectPhrases($key, $other);
  $other = $self->CleanUpPartitive($key, $other);
  return $other;
}


sub GuessPlural
{
  my($self, $noun) = @_;
  my $val;

  if ($noun =~ /(eau|eu)$/)
  {
    $val = $noun . "x";
  }
  elsif ($noun =~ /[^sx]$/)
  {
    $val = $noun . "s";
  }
  elsif ($noun =~ /(.*)al$/)
  {
    $val = $1 . "aux";
  }
  else
  {
    $val = $noun;
  }
  print "French_grammar::GuessPlural($noun): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->Init("French");
  return $self;
}

sub ExtractMagicThruTokenAnalysis
{
  my($self, $token, $s) = @_;
  my $val = "";
  if ($s =~ /$token (\S+)/)
  {
    my $followingToken = $1;
    if ($followingToken =~ m{^[`/#]?[aeiou]}i)		# vowel
    {
      $self->{"explanationForSpellingTransformation"} = "because <i>" . $self->Cook($followingToken) . "</i> starts with a vowel.";
      $val = "v";
    }
    elsif ($followingToken =~ m{^h}i)	# unaspirated 'h'
    {
      $self->{"explanationForSpellingTransformation"} = "because <i>" . $self->Cook($followingToken) . "</i> starts with an unaspirated <i>h</i>.";
      $val = "v";
    }
    else
    {
      delete($self->{"explanationForSpellingTransformation"});
    } 
  }
  print "French_grammar::ExtractMagicThruTokenAnalysis($token, $s): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub GetNounGender
{
  my($self, $noun, $silent) = @_;

  my $gender = $self->SUPER::GetNounGender($noun, 1);
  if (!defined $gender)
  {
    if ($noun =~ /(eau|ois)$/)
    {
      $gender = "m";
    }
    elsif ($noun =~ /(gie|ion)$/)
    {
      $gender = "f";
    }
    else
    {
      Carp::cluck($self->{"lang"} . ": no gender for $noun") if (!$silent);
      $gender = 'm';
    }
  }
  #print "French_grammar::GetNounGender($noun): " . nutil::ToString($gender) . "\n";
  return $gender;
}

sub GetPronounName
{
  my($self, $pronounCode) = @_;

  return 'je' if $pronounCode =~ /s1/;
  return 'tu' if $pronounCode =~ /s2b/;
  return 'il' if $pronounCode =~ /s3a/;
  return 'elle' if $pronounCode =~ /s3b/;
  return 'on' if $pronounCode =~ /s3c/;
  return 'nous' if $pronounCode =~ /p1/;
  return 'vous' if $pronounCode =~ /s2a|p2/;
  return 'ils' if $pronounCode =~ /p3a/;
  return 'elles' if $pronounCode =~ /p3b/;
  die $pronounCode;
}

sub ReplacePronounWithAddend
{
  my($self, $other, $adjustedAddend) = @_;
  $other =~ s/\b(ils|je|tu|il|elle|on|nous|vous|elles)\b/$adjustedAddend/i;
  return $self->SUPER::ReplacePronounWithAddend_common($other, $adjustedAddend);
}


sub MakeAdjectiveConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $magic) = @_;
  my $val = $token;
  my $explanation = undef;

  nutil::Warn() if ($val =~ /^(des)$/);
  
  if ($gender eq 'f')
  {
    if ($val =~ m{(bon)$})
    {
      $val .= "ne";
    }
    elsif ($val =~ m{(ais|is)$})
    {
      $val .= "e";
    }
    elsif ($val =~ m{(s)$})
    {
      $val .= "se";
    }
    elsif ($val =~ m{(.*)if$})
    {
      $val = $1 . "ive";
    }
    elsif ($val =~ m{(.*)ier$})
    {
      $val = $1 . "i`ere";
    }
    elsif ($val =~ m{(.*)eux$})
    {
      $val = $1 . "euse";
    }
    elsif ($val =~ m{(.*)eau$})
    {
      $val = $1 . "elle";
    }
    elsif ($val =~ m{(.*ien)$})
    {
      $val = $1 . "ne";
    }
    elsif ($val =~ m{(.*)el$})
    {
      $val = $1 . "elle";
    }
    elsif ($val =~ m{(.*)er$})
    {
      $val = $1 . "`ere";
    }
    elsif ($val =~ m{(/e|[^e])$})
    {
      $val = $val . "e";
    }
  }
  if ($singularOrPlural eq 'p')
  {
    if ($val =~ m{eau$})
    {
      $val .= "x";
    }

    if ($val =~ m{[^sx]$})
    {
      $val .= "s";
    }
  }
  my $oToken;
  if ($val eq $token)
  {
    $oToken = undef;
  }
  else
  {
    $oToken = new o_token($self, $val);
    $oToken->AddNote($self->ExplainAdjectiveChange($token, $val, $gender, $singularOrPlural, $magic));
  }
  print "French_grammar::MakeAdjectiveConformToCharacteristics($token, $gender, $singularOrPlural, $magic): (" . (defined $oToken ? $oToken->ToString() : "undef") . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $oToken;
}

sub CombineAddendPrefixWithAddend
{
  my($self, $addend_prefix, $adjustedAddend) = @_;
  $adjustedAddend = $self->SUPER::CombineAddendPrefixWithAddend($addend_prefix, $adjustedAddend);

  # Let's get the jusqu' away from the `a in the phrase.  It just confuses things.
  $adjustedAddend =~ s/{jusqu'/jusqu'^D {/g;

  return $adjustedAddend;
}

sub LooksLikeAnAdjective
{
  my($self, $token) = @_;
  my $val;
  if ($token =~ m{^(`a|contre|dans|de|du|en|et|la|peu|plus|pour|sur)$})
  {
    $val = 0;
  }
  else
  {
    $val = $self->SUPER::LooksLikeAnAdjective($token);
  }
  print "French_grammar::LooksLikeAnAdjective($token): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub ExplainWhatItIs
{
  my($self, $token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics) = @_;

  if (!defined $self->{"rejectedAlternativeThatOneWouldNormallyExpect"})
  {
    return $self->SUPER::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics);
  }

  die unless defined $self->{"characteristicsFount"};
  my $explanation;

  if ($val eq "l'^D")
  {
    $explanation = ""
    . $self->SUPER::ExplainWhatItIs($token, $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics)
    . "<br><i>" . $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}
    . "</i> becomes <i>l'</i> when preceding a word beginning with "
    . (($self->{"characteristicsFount"} =~ /^h/) ? "an unaspirated <i>h</i>" : "a vowel")
    . ".";
  }
  else
  {
    $explanation = "Although one would normally expect the feminine"
    . $self->PrintSingularOrPlural($singularOrPlural)
    . " $whatItIs <i>"
    . $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}
    . "</i> to be appropriate in order to agree with "
    . $self->{"characteristicsFountWithOrnament"}
    . ", the fact that the "
    . $whatItIs
    . " immediately precedes a word beginning with "
    . (($self->{"characteristicsFount"} =~ /^h/) ? "an unaspirated <i>h</i>" : "a vowel")
    . " means that instead we must use the masculine"
    . $self->PrintSingularOrPlural($singularOrPlural)
    . " $whatItIs <i>"
    . $val
    . "</i>.";
  }
  print "French_grammar::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics): " . nutil::ToString($explanation) . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $explanation;
}

sub CheckMutables
{
  my($self, $mutableHash, $token, $gender, $singularOrPlural, $magic) = @_;
  my $oToken = $self->SUPER::CheckMutables($mutableHash, $token, $gender, $singularOrPlural, $magic);
  if (!defined $oToken)
  {
    if (($token eq 'un') && ($singularOrPlural eq 'p'))
    {
      $mutableHash = $self->HashGet("mutables", 'le');
      $oToken = $self->SUPER::CheckMutables($mutableHash, 'le', $gender, $singularOrPlural, $magic);
      my $contraction = $self->HashGet("reverseContractions", "de " . $oToken->GetToken());
      if (!defined $contraction)
      {
	nutil::Warn("no contraction for 'de ' + " . $oToken->GetToken());
      }
      else
      {
	$oToken->SetToken($contraction);
	$oToken->InsertNote($self->ExplainContraction_getNoteText($contraction));
      }
      $oToken->InsertNote('fr_partitive');
    }
  }
  return $oToken;
}



sub Init
{
  my($self, $lang) = @_;
  $self->{"s2a_possessive"} = "votre";
  $self->{"s2b_possessive"} = "ton";
  $self->{"p2a_possessive"} = "votre";
  $self->{"p2b_possessive"} = "votre";
  $self->{"regular_verbs_regexp"} = "(parler|finir|prendre|vendre)";
  $self->SUPER::Init($lang);
}

sub GetThat
{
  my($self, $other) = @_;
  
  return "qu'^D " if $other =~ /^[{}]*[aehiou]/;
  return "que";
}
1;
