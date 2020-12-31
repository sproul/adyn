package Spanish_grammar;
use o_token;
use strict;
use diagnostics;
use arrayOfArrays;
use nlist;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);


sub GetStem
{
  my($self, $verb, $tense) = @_;
  $tense = "subjunctive" if ($tense eq "imperative");

  if ($verb =~ /^(\S+) /)
  {
    $verb = $1;
  }

  my $conjugationStem = $self->SUPER::GetStem($verb, $tense);
  if (defined $conjugationStem)
  {
    #print "SUPER::GetStem returned $conjugationStem\n";
  }
  else
  {
    my $argsRef = $self->GetVerbArgs($verb);
    my($stem_b, $inf_b, $pastParticiple_b,
    $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2b_b, $s3_b, $p1_b, $p2b_b, $p3_b, $argRef_reflexive_a, $argRef_reflexive_b) = @$argsRef;
    if (($tense eq "imperfect")
    ||  ($tense eq "preterite"))
    {
      die $verb unless $verb =~ /(.*)..$/;
      $conjugationStem = $1;
    }
    elsif (($tense eq "subjunctive")
    ||  ($tense eq "imperative")
    )
    {
      $s1_b = $self->Combine($stem_b, $s1_b);
      die $s1_b unless $s1_b =~ /(.*)o$/;
      $conjugationStem = $1;
    }
    elsif (($tense eq "future")
    || ($tense eq "conditional"))
    {
      $conjugationStem = $verb;
    } 
  }
  $conjugationStem =~ s{/$}{} if defined $conjugationStem;
  #print "GetStem($verb, $tense) => $conjugationStem;\n";
  return $conjugationStem;
}
  
sub GetHelperVerb
{
  my($self, $verb, $reflexive) = @_;
  return "haber";
}

sub GetPastParticiple
{
  my($self, $verb) = @_;
  if ($verb =~ /(.*)se$/)
  {
    $verb = $1;
  } 
      
  my $val;
  if ($verb =~ /(\S+)( .*)$/)
  {
    $val = $self->GetPastParticiple($1);
  } 
  else
  {
    $val = $self->GetOverride($verb, "past participle");
    if (!defined $val)
    {
      if ($verb =~ /(.*)ar$/)
      {
	$val = $1 . "ado";
      }
      elsif ($verb =~ /(.*)aer$/)
      {
	$val = $1 . "a/ido";
      }
      elsif ($verb =~ /(.*)er$/)
      {
	$val = $1 . "ido";
      }
      elsif ($verb =~ /(.*)ir$/)
      {
	$val = $1 . "ido";
      }
      else
      {
	die "verb $verb"; 
      } 
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
  if ($verb_b =~ /^(\S+)( .*)/)
  {
    $verb_b = $1;
    if (!$trailingString_b)
    {
      $self->{"trailingString"} = " $2";
    } 
    $trailingString_b = $2 . $trailingString_b;
  }
    
  #print "GetVTtoSParms($verb_b, $tense, $trailingString_a, $trailingString_b, $reflexive_a, $reflexive_b, $compoundPast)\n	Got stem_b=$stem_b, inf_b=$inf_b, pastParticiple_b=$pastParticiple_b, stem_a=$stem_a, inf_a=$inf_a, s1_a=$s1_a, s2_a=$s2_a, s3_a=$s3_a, p1_a=$p1_a, p2_a=$p2_a, p3_a=$p3_a, s1_b=$s1_b, s2b_b=$s2b_b, s3_b=$s3_b, p1_b=$p1_b, p2b_b=$p2b_b, p3_b=$p3_b, argRef_reflexive_a=$argRef_reflexive_a, argRef_reflexive_b=$argRef_reflexive_b)\n";
      
  die "kx" unless !defined $p1_b || ($self->VerbArgs_get_p1_b($argsRef) eq $p1_b);
  die "kz"         unless  $self->VerbArgs_get_stem_b($argsRef) eq $stem_b;
            		
  $reflexive_a = $argRef_reflexive_a unless defined $reflexive_a;
  $reflexive_b = $argRef_reflexive_b unless defined $reflexive_b;
              		
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
  my($p2a_b, $p3a_b, $p3b_b) = ($p3_b, $p3_b, $p3_b);
  my $s2b_no_b = undef;
  my $p2b_no_b = undef;
            	
  if (($tense eq "past_conditional")
  || ($tense eq "future_perfect")
  || ($tense eq "past")
  || ($tense eq "pluperfect"))
  {
    my $helperVerb_b = $self->GetHelperVerb($verb_b, $reflexive_b);
    ($dummy, $dummy, $dummy, $dummy, 
    $dummy, $dummy, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
    $s1_b, $s2a_b, $s2b_b, $s2b_no_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p2b_no_b, $p3a_b, $p3b_b, $reflexive_a, $reflexive_b) 
    = $self->GetVTtoSParms($helperVerb_b,
    $self->GetHelperTense($tense),
    " " . $self->GetPastParticiple_English($verb_a) . $trailingString_a, 
    " " . $self->GetPastParticiple("$stem_b$inf_b") . $trailingString_b, 
    $reflexive_a,
    $reflexive_b,
    1);
  }
  elsif (($tense eq "imperfect")
  || ($tense eq "future")
  || ($tense eq "imperative")
  || ($tense eq "preterite")
  || ($tense eq "subjunctive")
  || ($tense eq "conditional"))
  {
    ($s1_b, $s2b_b, $s2b_no_b, $s3a_b, $p1_b, $p2b_b, $p2b_no_b, $p3a_b) = $self->ResolveEndings($stem_b, $inf_b, $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3_b, $tense, $trailingString_b);
    #print "got back from ResolveEndings: $s1_b, $s2b_b, $s2b_no_b, $s3a_b, $p1_b, $p2b_b, $p2b_no_b, $p3a_b\n";
    $s3b_b = $s3a_b;
    $p2a_b = $p3b_b = $p3a_b;
    $s2a_b = $s3a_b;
    ($s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a) = $self->GetEnglishConjugation("__unused__", $tense, $verb_a, $compoundPast, $trailingString_a, $s1_a, $s2_a, $s3a_a, $p1_a, $p2_a, $p3_a);
    $s3b_a = $s3a_a;
  } 				
  else
  {
    $s1_b  = $self->Combine($stem_b, $s1_b)  . "$trailingString_b" if defined $s1_b;
    $s2a_b = $self->Combine($stem_b, $s3a_b) . "$trailingString_b" if defined $s2a_b;
    $s2b_b = $self->Combine($stem_b, $s2b_b) . "$trailingString_b" if defined $s2b_b;
    $s3a_b = $self->Combine($stem_b, $s3a_b) . "$trailingString_b" if defined $s3a_b;
    $s3b_b = $self->Combine($stem_b, $s3b_b) . "$trailingString_b" if defined $s3b_b;
    $p1_b  = $self->Combine($stem_b, $p1_b)  . "$trailingString_b" if defined $p1_b;
    $p2a_b = $self->Combine($stem_b, $p2a_b) . "$trailingString_b" if defined $p2a_b;
    $p2b_b = $self->Combine($stem_b, $p2b_b) . "$trailingString_b" if defined $p2b_b;
    $p3a_b = $p3b_b = $self->Combine($stem_b, $p3a_b) . "$trailingString_b" if defined $p3a_b;
        							
    $s1_a  = $self->Combine($verb_a, $s1_a)  . "$trailingString_a" if defined $s1_a;
    $s2_a  = $self->Combine($verb_a, $s2_a)  . "$trailingString_a" if defined $s2_a;
    $s3a_a = $self->Combine($verb_a, $s3a_a) . "$trailingString_a"; # always
    $s3b_a = $self->Combine($verb_a, $s3b_a) . "$trailingString_a" if defined $s1_a;#elle faut?
    $p1_a  = $self->Combine($verb_a, $p1_a)  . "$trailingString_a" if defined $p1_a;
    $p2_a  = $self->Combine($verb_a, $p2_a)  . "$trailingString_a" if defined $p2_a;
    $p3_a  = $self->Combine($verb_a, $p3_a)  . "$trailingString_a" if defined $p3_a;
  }
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
  $verb_a, "", $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s2b_no_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p2b_no_b, $p3a_b, $p3b_b,
  $reflexive_a, $reflexive_b);
}

sub GetPersonalPronouns
{
  my($self, $reflexive, @actions) = @_; # @actions was $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b
  if ($reflexive)
  {
    return ( "yo me ", "usted\n se ", "t`u\nte ", "/el se ", "ella se ", "nosotros nos ", "ustedes\n se ", "vosotros\n os ", "ellos se ", "ellas se " );
  }
  else
  {
    ("yo ", "usted\n", "t`u\n", "/el ", "ella ", "nosotros ", "ustedes\n ", "vosotros\n ", "ellos ", "ellas ");
  }
}

sub AffirmativeImperative_AttachPronoun
{
  my($verbForm, $pronoun) = @_;
  my $val = undef;
  if (defined $verbForm)
  {
    if ($pronoun eq "os")
    {
      die unless $verbForm =~ /(.*)d/;
      $val = $1 . "os";
    }
    else
    {
      if ($pronoun eq "nos")
      {
	die unless $verbForm =~ /(.*)s/;
	$verbForm = $1;
      }
      
      die $verbForm unless $verbForm =~ m{(.*[^/`:])([aeiou])([^aeiou]*)([aeiou]n?)$};
      $val = "$1/$2$3$4$pronoun";
    }
  }
  return $val;
}

sub VTtoS
{
  my($self, $verb_b, $tense, $doingVerbTable) = @_;
  print "VTtoS($verb_b, $tense)\n" if $self->{"Trace_Vtl_requested"};

  my($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a,
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s2b_no_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p2b_no_b, $p3a_b, $p3b_b,
  $reflexive_a, $reflexive_b)
  = $self->GetVTtoSParms($verb_b,$tense,'','',undef,undef,0);
  #print "GetPersonalPronouns($verb_b, $reflexive_b)\n";

  my $hdr_inf_a = $self->Get_verb_a_withToIfAppropriate($verb_b);

  $self->VerbGenInit($verb_b);
  my @s = ();
  my @p = ();
  if ($tense eq "imperative")
  {
    my $p1_no_b = $self->GetOverride($verb_b, "p1_no_b");

    if ($reflexive_b)
    {
      my $t = AffirmativeImperative_AttachPronoun($s2a_b, "se");
      push @s, $self->X($tense, "$s2_a!", "s2a", "$t!", "$t") if defined $s2a_b;
      if (defined $s2b_b)
      {
	push @s, $self->X($tense, "don't $s2_a!", "s2b_no", "no te ${s2b_no_b}!", "${s2b_no_b}");

	$t = AffirmativeImperative_AttachPronoun($s2b_b, "te");
	push @s, $self->X($tense, "$s2_a!", "s2b", "$t!", "$t");
      }

      $t = AffirmativeImperative_AttachPronoun($p1_b, "nos");
      push @p, $self->X($tense, "let's $p1_a!", "p1", "$t!", "$t") if defined $p1_b;
      $p1_no_b = $p1_b if !defined $p1_no_b;
      push @p, $self->X($tense, "let's not $p1_a!", "p1_no", "no nos $p1_no_b!", $p1_no_b) if defined $p1_no_b;
      $t = AffirmativeImperative_AttachPronoun($p2a_b, "se");
      push @p, $self->X($tense, "$p2_a!", "p2a", "$t!", "$t") if defined $p2a_b;
      push @p, $self->X($tense, "don't $p2_a!", "p2b_no", "no os ${p2b_no_b}!", "${p2b_no_b}") if defined $p2b_no_b;
      $t = AffirmativeImperative_AttachPronoun($p2b_b, "os");
      push @p, $self->X($tense, "$p2_a!", "p2b", "$t!", "$t") if defined $p2b_b;
    }
    else
    {
      push @s, $self->X($tense, "$s2_a!", "s2a", "${s2a_b} (\nusted\n)!", $s2a_b) if defined $s2a_b;
      push @s, $self->X($tense, "don't $s2_a!", "s2b_no", "no ${s2b_no_b} (\nt`u\n)!", $s2b_no_b) if defined $s2b_no_b;
      push @s, $self->X($tense, "$s2_a!", "s2b", "${s2b_b} (\nt`u\n)!", $s2b_b) if defined $s2b_b;

      push @p, $self->X($tense, "let's $p1_a!", "p1", "${p1_b}!", $p1_b) if defined $p1_b;
      if (defined $p1_no_b)
      {
	push @p, $self->X($tense, "let's not $p1_a!", "p1_no", "no ${p1_no_b}!", $p1_no_b);
      }
      else
      {
	$self->X($tense, "let's not $p1_a!", "p1_no", "no ${p1_b}!", $p1_b) if defined $p1_b;
      }
      push @p, $self->X($tense, "$p2_a!", "p2a", "${p2a_b} (\nustedes\n)!", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "don't $p2_a!", "p2b_no", "no ${p2b_no_b} (\nvosotros\n)!", $p2b_no_b) if defined $p2b_no_b;
      push @p, $self->X($tense, "$p2_a!", "p2b", "${p2b_b} (\nvosotros\n)!", $p2b_b) if defined $p2b_b;
    }
  }
  else
  {
    my($pp_s1_b, $pp_s2a_b, $pp_s2b_b, $pp_s3a_b, $pp_s3b_b, $pp_p1_b, $pp_p2a_b, $pp_p2b_b, $pp_p3a_b, $pp_p3b_b) = $self->GetPersonalPronouns($reflexive_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b);
    if ($self->GetOverride("$verb_b", "it only"))
    {
      push @s, $self->X($tense, "it $s3a_a", "s3a", "$s3a_b", $s3a_b) ;
    }
    else
    {
      push @s, $self->X($tense, "I $s1_a", "s1", "$pp_s1_b$s1_b", $s1_b) if defined $s1_b;
      push @s, $self->X($tense, "you $s2_a", "s2a", "$pp_s2a_b\n$s2a_b", $s2a_b) if defined $s2a_b;
      push @s, $self->X($tense, "you $s2_a", "s2b", "$pp_s2b_b\n$s2b_b", $s2b_b) if defined $s2b_b;
      push @s, $self->X($tense, "he $s3a_a", "s3a", "$pp_s3a_b$s3a_b", $s3a_b) if defined $s3a_b;
      push @s, $self->X($tense, "she $s3b_a", "s3b", "$pp_s3b_b$s3b_b", $s3b_b) if defined $s3b_b;
      $self->X($tense, "one $s3a_a", "s3c", "todo el mundo $s3a_b", $s3a_b) if defined $s3a_b;

      push @p, $self->X($tense, "we $p1_a", "p1", "$pp_p1_b$p1_b", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "you $p2_a", "p2a", "$pp_p2a_b\n$p2a_b", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "you $p2_a", "p2b", "$pp_p2b_b\n$p2b_b", $p2b_b) if defined $p2b_b;
      push @p, $self->X($tense, "they $p3_a", "p3a", "$pp_p3a_b$p3a_b", $p3a_b) if defined $p3a_b;
      push @p, $self->X($tense, "they $p3_a", "p3b", "$pp_p3b_b$p3b_b", $p3b_b) if defined $p3b_b;
    }
  }
  return $self->ComposeVTOutput($tense, $hdr_inf_a, $verb_b, $doingVerbTable, \@s, \@p);
}

sub GetTenses
{
  return [ "present", "preterite", "past", "imperfect", "future", "conditional", "past_conditional", "future_perfect", "pluperfect", "subjunctive", "imperative" ];
}

sub PossibleSpellingChange
{
  my($tense, $verb_b, $stem, $s) = @_;
  #print "PossibleSpellingChange($tense, $verb_b, $stem, $s)...\n";
  die "cannot extract base from $stem" unless $stem =~ /(.*)(.)$/;
  my($baseStem, $finalLetter) = ($1, $2);
  
  if ($verb_b =~ /car$/)
  {
    $s =~ s{$stem(/?e.*)}{${baseStem}qu$1};
  }
  elsif ($verb_b =~ /gir$/
  && $finalLetter eq "g"
  && $s =~ /^[ao]/)
  {
    my $newStem = $stem;
    $newStem =~ s/g$/j/;
    $s =~ s/^$stem/$newStem/;
  }
  elsif ($verb_b =~ /gir$/
  && $stem =~ /j$/
  && $s =~ /^[e]/)
  {
    my $newStem = $stem;
    $newStem =~ s/j$/g/;
    $s =~ s/^$stem/$newStem/;
  }
  elsif ($verb_b =~ /gar$/)
  {
    $s =~ s{$stem(/?e.*)}{${baseStem}gu$1};
  }
  elsif ($verb_b =~ /g[ei]r$/)
  {
    #print "in coger Poss.: bs=$baseStem, s=$s\n";
    $s =~ s{${baseStem}g(/?[ao].*)}{${baseStem}j$1};	# (coger) cogo -> cojo
  }
  elsif ($verb_b =~ /guir$/)
  {
    $s =~ s{$stem(/?[ao].*)}{${baseStem}$1};	# gu -> g
  }
  elsif ($verb_b =~ /zar$/)
  {
    $s =~ s{$stem(/?e.*)}{${baseStem}c$1};
  }
  elsif ($verb_b =~ /eer$/)
  {
    $s =~ s{${stem}i(.*)}{${stem}y$1};
  }
  elsif ($verb_b =~ /cer$/)
  {
    $s =~ s{${stem}o$}{${baseStem}zo};	# (hacer) hico -> hizo
  }
  elsif ($verb_b =~ /uir$/)
  {
    #print "in construir Poss.: bs=$baseStem, s=$s\n";
    #PossibleSpellingChange(preterite, construir, constru, construieron)...in construir Poss.: bs=constr, s=construieron
    $s =~ s{${stem}ie(.*)}{${stem}ye$1};	# (construir) construieron -> construyeron
  }
  
  $s =~ s/(.*)ji(e.*)/${1}j$2/;		# (conducir) condujieron -> condujeron 
  $s =~ s/(.*)zc([ei].*)/${1}c$2/;	# (conducir) conduzce -> conduce, conduzcid -> conducid 
  $s =~ s/(.*)ge$/$1/;			# (valer) s2b imperative: valge -> val (also tener, venir) 
  
  #print "...yielded $s\n";
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
    
sub AddEndings
{
  my($self, $verb_b, $stem_b, $tense, $trailingString) = @_;
  
  #print "AddEndings($verb_b, $stem_b, $tense, $trailingString)\n";
  $verb_b = $1 if ($verb_b =~ /^(\S+) /);

  my ($stem_s12, $stem_sp3, $stem_p12) = $self->SplitItem($stem_b);
  if ($tense eq "future")
  {
    return (
    "${stem_b}/e$trailingString",
    "${stem_b}/as$trailingString",
    undef,
    "${stem_b}/a$trailingString",
    "${stem_b}emos$trailingString",
    "${stem_b}/eis$trailingString",
    undef,
    "${stem_b}/an$trailingString"
    );
  }
  elsif ($tense eq "conditional")
  {
    return (
    "${stem_b}/ia$trailingString",
    "${stem_b}/ias$trailingString",
    undef,
    "${stem_b}/ia$trailingString",
    "${stem_b}/iamos$trailingString",
    "${stem_b}/iais$trailingString",
    undef,
    "${stem_b}/ian$trailingString",
    );
  }
  elsif ($tense eq "imperfect")
  {
    if ($verb_b =~ /ar$/)
    {
      return (
      "${stem_b}aba$trailingString",
      "${stem_b}abas$trailingString",
      undef,
      "${stem_b}aba$trailingString",
      "${stem_b}/abamos$trailingString",
      "${stem_b}abais$trailingString",
      undef,
      "${stem_b}aban$trailingString",
      );
    }
    else
    {
      return (
      "${stem_b}/ia$trailingString",
      "${stem_b}/ias$trailingString",
      undef,
      "${stem_b}/ia$trailingString",
      "${stem_b}/iamos$trailingString",
      "${stem_b}/iais$trailingString",
      undef,
      "${stem_b}/ian$trailingString",
      );
    }
  } 
  elsif ($tense eq "preterite")
  {
    if ($self->GetOverride($verb_b, "preterite_irregular"))
    {
      $stem_b = $self->GetOverride($verb_b, "preterite_irregular");
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}iste$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}o$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}imos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}isteis$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_b, "${stem_b}ieron$trailingString")
      );
    }
    elsif ($verb_b =~ /[ae]er$/)
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}/i$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}/iste$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}y/o$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/imos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/isteis$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}yeron$trailingString")
      );
    }
    elsif ($verb_b =~ /ar$/)
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}/e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}aste$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}/o$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}amos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}asteis$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}aron$trailingString")
      );
    }
    else
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}/i$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}iste$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}i/o$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}imos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}isteis$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}ieron$trailingString")
      );
    }
  }
  elsif ($tense eq "subjunctive")
  {
    if ($verb_b =~ /([ie])r$/)
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}a$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}as$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}a$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}amos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/ais$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}an$trailingString")
      );
    }
    else
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}es$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}emos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/eis$trailingString"),
      undef,
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}en$trailingString")
      );
    }
  }
  elsif ($tense eq "imperative")
  {
    my $p2b_b = $verb_b;
    $p2b_b =~ s/r$/d/;
    
    if ($verb_b =~ /([ie])r$/)
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}a$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}as$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}a$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}amos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "$p2b_b$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/ais$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}an$trailingString")
      );
    }
    else
    {
      return (
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}a$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}es$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}e$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}emos$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "$p2b_b$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}/eis$trailingString"),
      PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}en$trailingString")
      );
    }
  }
  else
  {
    die "tense $tense";
  }
}

sub ResolveEndings
{
  my($self, $stem_b, $inf_b, $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3_b, $tense, $trailingString_b) = @_;
  my $verb_b = "$stem_b$inf_b";
      			
  my $conjugation = $self->GetOverrideList($verb_b, $tense);
  if (defined $conjugation)
  {
    #Ndmp::Ah("ResolveEndings fetched overridden tense for ($verb_b, $tense) $trailingString_b", $conjugation);
    my $ref = nlist::catAll($conjugation, $trailingString_b);
    #Ndmp::Ah("ResolveEndings from catAll", $ref);
    return @$ref;
  }
  

  my $conjugationStem = $self->GetOverride("$verb_b", "$tense");
  					
  my $s2b_no_b = undef;
  my $p2b_no_b = undef;
  
  if (defined $conjugationStem)
  {
    #print "ResolveEndings: taking $conjugationStem from Override\n";
  }
  else
  {
    $conjugationStem = $self->GetStem($verb_b, $tense);
  }
  ($s1_b, $s2b_b, $s2b_no_b, $s3a_b, $p1_b, $p2b_b, $p2b_no_b, $p3_b) = $self->AddEndings($verb_b, $conjugationStem, $tense, $trailingString_b);
  return ($s1_b, $s2b_b, $s2b_no_b, $s3a_b, $p1_b, $p2b_b, $p2b_no_b, $p3_b);
}

sub MakeRecursive
{
  my($self, $verb) = @_;
  return "${verb}se";
}

sub StripReflexivity
{
  my($self, $verb_b) = @_;
  $verb_b =~ s/se( .*)?$//;
  return $verb_b;
}

sub SetReflexivity_b
{
  my($self, $verb_b, $argsRef) = @_;
  #Ndmp::Ah("SetReflexivity_b", $argsRef);
  my $reflexive_b = '';
  if ($verb_b =~ /.*(se)$/)
  {
    $reflexive_b = $verb_b;
  }
  $argsRef->[18] = $reflexive_b;
  return $reflexive_b;
}

sub EqVerbDerivePatterns
{
  my($self, $verb, $paradigmVerb) = @_;
  if ($verb =~ /(\S+)( .*)$/)
  {
    $verb = $1;
  } 
  $verb = $1 if $verb =~ /(.*)2$/;
    
  if ($verb =~ /(.*)se$/)
  {
    $verb = $1;
  }
  my $a1;
  my $b1;
  my $b2 = undef;
  my $a2 = undef;
  if ($paradigmVerb =~ m{^(seguir)$})
  {
    die "lskdj" unless $verb =~ /(.*s)eguir$/;
    $a1 = $1;
    $b1 = "^s";
  }
  elsif ($paradigmVerb =~ m{^(jugar)$})
  {
    die "lskdj" unless $verb =~ /(.*j)ugar$/;
    $a1 = $1;
    $b1 = "^j";
  }
  elsif ($self->IsStemChangingVerb($paradigmVerb)
  && ($verb =~ /(.*[^aeiou])[aeiou]+([^aeiou]+)..$/))
  {
    ($a1, $a2) = ($1, $2);
    die "lskdj" unless $paradigmVerb =~ /(.*[^aeiou])[aeiou]+([^aeiou]+)..$/;
    ($b1, $b2) = ("^$1", $2);
  }
  elsif ($paradigmVerb =~ m{^(coger|conducir|describir|dirigir)$})
  {
    die "lskdj" unless $verb =~ /(.*)...$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*)...$/;
    $b1 = "^$1";
  }
  elsif ($paradigmVerb =~ m{^(cerrar)$})
  {
    die "lskdj" unless $verb =~ /^(.*)e(.*)ar$/;
    $a1 = $1;
    $a2 = $2;
    die "lskdj" unless $paradigmVerb =~ /(.*)e(.*)ar$/;
    $b1 = "^$1";
    $b2 = "$2";
  }
  elsif ($paradigmVerb =~ m{^(mover)$})
  {
    die "lskdj" unless $verb =~ /^(.*)o(.)er$/;
    $a1 = $1;
    $a2 = $2;
    die "lskdj" unless $paradigmVerb =~ /(.*)o(.)er$/;
    $b1 = "^$1";
    $b2 = "$2";
  }
  elsif ($paradigmVerb =~ m{^(cono)cer$})
  {
    $b1 = "^$1";
    die "lskdj" unless $verb =~ /(.*)...$/;
    $a1 = $1;
  }
  elsif ($paradigmVerb =~ m{^(hacer|re/ir|tener)$})
  {
    die "lskdj" unless $verb =~ /(.*)....$/;
    $a1 = $1;
    die "lskdj" unless $paradigmVerb =~ /(.*)....$/;
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

sub IsStemChangingVerb
{
  my($self, $v) = @_;
  my $o = $self->GetOverride($v, "subjunctive");
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
  $verb1 = $1 if $verb1 =~ /(.*)se$/;
  $verb2 = $1 if $verb2 =~ /(.*)se$/;
  return $verb1 eq $verb2;
}

sub GetAuxiliaryVerbs
{
  my($self) = @_;
  return ( "haber" );
}


sub OnEndOfGrammarGeneration
{
  my($self) = @_;
  $self->OverrideVerbTableLookup("nada");	# es: nadar v. nothing
  $self->OverrideVerbTableLookup("casa");	# es: casar v. una casa
  $self->OverrideVerbTableLookup("para");	# es: parar v. para
  $self->SUPER::OnEndOfGrammarGeneration();
}  

sub ExercisesAreAppropriateFor
{
  my($self, $verb_a, $verb_b) = @_;
  if ($verb_b eq "haber")
  {
    return 0;
  }
  else
  {
    return $self->SUPER::ExercisesAreAppropriateFor($verb_a, $verb_b);
  }
}

sub Init
{
  my($self, $lang) = @_;
  $self->{"s2a_possessive"} = "su";
  $self->{"s2b_possessive"} = "tu";
  $self->{"p2a_possessive"} = "su";
  $self->{"p2b_possessive"} = "vuestro";
  $self->{"regular_verbs_regexp"} = "(hablar|comer|vivir)";
  
  my $tenerArgsRef = $self->GetVerbArgs("tener", 1);
  generic_grammar:$self->Set__verbsByEnglish("have", $tenerArgsRef); # not haber
  
  $self->SUPER::Init($lang);
}

sub IsRecursive
{
  my($self, $verb) = @_;
  return $verb =~ /se( .*)?$/;
}

sub ExplainAdjectivalChange
{
  my($self, $modifiedAdjective, $unmodifiedAdjective) = @_;
    
  if ($modifiedAdjective =~ /as$/)
  {
    return "feminine and plural";
  }
  elsif ($modifiedAdjective =~ /s$/)
  {
    return "plural";
  }
  elsif ($modifiedAdjective =~ /a$/)
  {
    return "feminine";
  }
  else
  {
    die "odd: $unmodifiedAdjective, " . $self->Get__currentToken();
  }
}

sub X
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm, $suppressVtl) = @_;
  if ($tense eq "imperative")
  {
    $other = "_!$other";
  }
  elsif ($other =~ /(.*)\?\.?$/)
  {
    $other = "_?^D $1?";
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
    $adjustedPronoun = "nos";
  }
  elsif ($pronounCode =~ /p2b/)
  {
    $adjustedPronoun = "os";
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
  #print "Spanish_grammar::InsertAddend_adjustRecursiveInfinitiveToMatchPronoun($id, $adjustedAddend) ($pronounCode => $adjustedPronoun)\n";
  return $adjustedAddend;
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->Init("Spanish");
  return $self;
}


sub GuessPlural
{
  my($self, $token) = @_;
  my $val;
    
  if ($token =~ m{/e$})
  {
    $val = $token . "s";	# 100.1
  }
  elsif ($token =~ m{(.*i)z$})
  {
    $val = $1 . "ces";		# ? -- lapiz
  }
  elsif ($token =~ m{/[aiou]$})
  {
    $val = $token . "es";	# 100.1.5
  }
  elsif ($token =~ m{(.*)/([aeo][^aeiou])$})
  {
    $val = $1 . $2 . "es";	# 100.2
  }
  elsif ($token =~ m{[^aeiou]$})
  {
    $val = $token . "es";	# 100.2
  }
  elsif ($token =~ m{(.*[^/])([aeiou][^aeiou]en)$})
  {
    $val = $1 . "/" . $2 . "es";	# 101.1
  }
  elsif ($token =~ m{(.*[^/])([aeiou]s)$}	# 101.2
  ||     $token =~ m{x$})			# 101.3
  {
    $val = $token;
  }
  else
  {
    $val = $token . "s";    
  }
  print "Spanish_grammar::GuessPlural($token): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}



sub MakeAdjectiveConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $magic) = @_;
  
  my $oToken = new o_token($self, $token);
    
  if ($token =~ m{^(alerta|adiendo|escarlata|hembra|hirviendo|macho|malva|modelo|naranja|tab/u|violeta)$})
  {
    $oToken->AddNote("%currentToken% is an invariable adjective.");
  }
  else
  {
    if ($gender eq 'f')
    {
      if ($token =~ m{^(cort/es|marr/on|af/in)$})  # 129
      {
	$oToken->AddNote("%currentToken% does not have a distinct feminine form.");
      }
      elsif ($token =~ m{^(mej|anteri|exteri|inferi|interi|may|men|superi|pe|posteri|ulteri)or$})  # 129
      {
	$oToken->AddNote("Comparative adjectives which end with <i>-or</i> do not have distinct feminine forms.");
      } 
      elsif ($token =~ /(.*)o$/		# 127, 128
      ||  $token =~ /(.*[eo]t)e$/		# 128
      ||  $token =~ /(.*or)$/			# 129
      ||  $token =~ /^(espa~nol|andaluz$)/)	# 129, 130
      {
	$oToken->SetToken($1 . "a");
      }
      elsif ($token =~ m{(.*)/es$})
      {
	$oToken->SetToken($1 . "esa");
      }
      elsif ($token =~ m{(.*)/(es|[aeiou]n)$})  		# 128, 129
      {
	$oToken->SetToken($1 . $2 . "a");
      }
    }
    if ($singularOrPlural eq 'p')
    {
      $oToken = $self->MakePlural($oToken->GetToken(), $magic);
    }
  }
  if ($oToken->HasChanged() && !$oToken->HasNotes())
  {
    $oToken->AddNote($self->ExplainAdjectiveChange($token, $oToken->GetToken(), $gender, $singularOrPlural, $magic));
  }
  print "Spanish_grammar::MakeAdjectiveConformToCharacteristics($token, $gender, $singularOrPlural, $magic): " . $oToken->ToString() . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $oToken;
}

sub IsNoun
{
  my($self, $noun) = @_;
  return 1 if $self->SUPER::IsNoun($noun);
      
  if ($noun =~ s/a$/o/)	# noun looks feminine; look to see if there is a masculine version
  {
    return $self->SUPER::IsNoun($noun); 
  }
    
  return 0;
}

sub ExtractMagicThruTokenAnalysis
{
  my($self, $token, $s) = @_;
  my $val = "";
  if ($s =~ /$token (\S+)/)
  {
    my $followingToken = $1;
    # detect a stressed 'a' sound:
    # 		either 1. an accented 'a' (/a)
    # 		or     2. 'a' followed by consonant(s) and a vowel
    if ($followingToken =~ m{^h?(/a|a[^aeiou]+[aeiou])}i)
    {
      $self->{"explanationForSpellingTransformation"} = "because <i>" . $self->Cook($followingToken) . "</i> starts with a stressed <i>a</i> sound.";
      $val = "v";
    }
    else
    {
      delete($self->{"explanationForSpellingTransformation"});
    } 
  }
  print "Spanish_grammar::ExtractMagicThruTokenAnalysis($token, $s): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub GetNounGender
{
  my($self, $noun, $silent, $singularOrPlural) = @_;
    
  my $gender = $self->SUPER::GetNounGender($noun, 1);
  if (!defined $gender)
  {
    if ($noun =~ /ista$/)
    {
      $gender = "m";
    }
    elsif ($noun =~ /(dad|a)$/)
    {
      $gender = "f";
    }
    elsif ($noun =~ /o$/)
    {
      $gender = "m";
    }
    else
    {
      warn $self->{"lang"} . ": no gender for $noun" if (!$silent);
      $gender = "m";
    }
  }
  #print "Spanish_grammar::GetNounGender($noun): " . nutil::ToString($gender) . "\n";
  return $gender;
}

sub GetPronounName
{
  my($self, $pronounCode) = @_;
  
  return 'yo' if $pronounCode =~ /s1/;
  return 'usted' if $pronounCode =~ /s2a/;
  return 't`u' if $pronounCode =~ /s2b/;
  return '/el' if $pronounCode =~ /s3a/;
  return 'ella' if $pronounCode =~ /s3b/;
  return 'ellos' if $pronounCode =~ /p3a/;
  return 'ellas' if $pronounCode =~ /p3b/;
  return 'nosotros' if $pronounCode =~ /p1/;
  return 'ustedes' if $pronounCode =~ /p2a/;
  return 'vosotros' if $pronounCode =~ /p2b/;
  die $pronounCode;
}

sub ReplacePronounWithAddend
{
  my($self, $other, $adjustedAddend) = @_;
  $other =~ s{(yo|usted|t`u|/el|ella|ellos|ellas|nosotros|ustedes|vosotros)\b}{$adjustedAddend}i;
  return $self->SUPER::ReplacePronounWithAddend_common($other, $adjustedAddend);
}

sub LooksLikeAnAdjective
{
  my($self, $token) = @_;
  my $val;
  if ($token =~ m{^(en|m/as|menos)$})
  {
    $val = 0;
  }
  else
  {
    $val = $self->SUPER::LooksLikeAnAdjective($token);
  }
  print "sp_grammar::LooksLikeAnAdjective($token): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub ExplainWhatItIs
{
  my($self, $token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics) = @_;

  my $explanation;
  if (!defined $self->{"rejectedAlternativeThatOneWouldNormallyExpect"})
  {
    $explanation = $self->SUPER::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics);
  }
  elsif ($val =~ /^(un|el)$/)
  {
    $explanation = ""
    . $self->SUPER::ExplainWhatItIs($token, $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics)
    . "<br>However, <i>" . $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}
    . "</i> becomes <i>$val</i> "
    . $self->{"explanationForSpellingTransformation"};
  }
  else
  {
    die "did not know how to format " . $self->{"rejectedAlternativeThatOneWouldNormallyExpect"};
  }
  print "Spanish_grammar::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs): " . nutil::ToString($explanation) . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $explanation;
}

sub OnUnifyCharacteristicsOf_1_ObjectPhrase
{
  my($self, $key, $otherParm, $addendKey) = @_;

  my $other = $otherParm;

  if (defined $addendKey)
  {
    if ($addendKey =~ /^vocab_languages/)
    {
      if ($key =~ /verb_(learn|speak)/)
      {
	warn "I thought all Spanish languages were masculine, yet look at this: $other" if $other =~ /^la /;

	$other =~ s/^el //;
	$self->SetNote($key, "el", undef);
      }

      my $langNoun = $1 if $other =~ /(\S+)/;
      $self->SetNote($key, $langNoun, "el_lang");
    }
    elsif ($addendKey =~ /^(people|vocab_professions|vocab_family)/
    && !$self->AddendIsSubject($key)
    && !defined tdb::Get(grammar::GetGlobalIdForThisDataFile($key), $self->{"lang"} . "/addend_prefix"))
    {
      $other =~ s/^/a /;
      tdb::Set($key, $self->MakeTokenNoteKey("a"), "personalA");
      $other = $self->UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $other);
    }
  }
  return $other;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions
{
  my($self, $key, $val) = @_;
  $val = $self->SUPER::UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val);
  $val =~ s{\by ([/`#]?i)}{e $1}gi;
  return $val;
}

sub GetThat
{
  my($self) = @_;
  return "que";
}
1;
