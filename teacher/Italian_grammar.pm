package Italian_grammar;
use o_token;
use Argv_db;
use strict;
use diagnostics;
use nlist;
use arrayOfArrays;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);

sub GetStem
{
  my($self, $verb, $tense) = @_;

  $tense = "subjunctive" if ($tense eq "imperative");

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
    if ($tense eq "imperfect")
    {
      die $verb unless $verb =~ /(.*)..$/;
      $conjugationStem = $1;
    }
    elsif ($tense eq "preterite")
    {
      die $verb unless $verb =~ /(.*)...$/;
      $conjugationStem = $1;
    }
    elsif ($tense eq "subjunctive")
    {
      $s1_b = $self->Combine($stem_b, $s1_b);

      die $s1_b unless $s1_b =~ /(.*)o$/;	# works for produrre et. al.
      $conjugationStem = $1;

      if (($verb =~ /.*[aeiou].*iare/)	# -iare with another vowel in front, eg, studiare
      && ($conjugationStem =~ /(.*)i$/))
      {
	$conjugationStem = "$1";
      } 
      elsif ($conjugationStem =~ /((.*)[i])$/)
      {
	$conjugationStem = "$1;$2";
      }
    }
    elsif (($tense eq "future")
    || ($tense eq "conditional"))
    {
      die $verb unless $verb =~ /(.*)e$/;
      $conjugationStem = "$1";
      
      $conjugationStem =~ s/ar$/er/;
    }
    $conjugationStem =~ s{/$}{} if defined $conjugationStem;
  } 
  #print "GetStem($verb, $tense) => $conjugationStem;\n";
  return $conjugationStem;
}
  
sub GetHelperVerb
{
  my($self, $verb, $reflexive) = @_;
  return "essere" if $reflexive;
  return "essere" if defined $self->Get__hasSecondaryHelperVerb($verb);
  return "avere";
}

sub LooksLikeAModifiedPastParticiple
{
  my($self, $token, $id) = @_;
  if ($token =~ /[aei]$/)
  {
    $token =~ s/[aei]$/o/;
    return $token;
  }
  return 0;
}

sub GetPastParticiple
{
  my($self, $verb) = @_;
  $verb =~ s/2$//;
  if ($verb =~ /(\S+)( .*)$/)
  {
    return $self->GetPastParticiple($1) . $2;
  }  
  my $val = $self->GetOverride($verb, "past participle");
  if (!defined $val)
  {
      if ($verb =~ /(.*)si$/)
      {
	$verb = $1 . "e";
	return $self->GetPastParticiple($verb);
      } 
      
      if ($verb =~ /(.*[ai])re$/)
      {
	$val = $1 . "to";
      }
      elsif ($verb =~ /(.*)ere$/)
      {
	$val = $1 . "uto";
      }
      else
      {
	die "verb $verb"; 
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
    if ($trailingString_b)
    {
      $trailingString_b = $2 . $trailingString_b;
    }
    else
    {
      $trailingString_b = $2;
      $self->{"trailingString"} = $trailingString_b; 
    }

    $inf_b =~ s/ .*//;
  }
  
  #print "GetVTtoSParms($verb_b, $tense, $trailingString_a, $trailingString_b, $reflexive_a, $reflexive_b, $compoundPast)\n	Got stem_b=$stem_b, inf_b=$inf_b, pastParticiple_b=$pastParticiple_b, stem_a=$stem_a, inf_a=$inf_a, s1_a=$s1_a, s2_a=$s2_a, s3_a=$s3_a, p1_a=$p1_a, p2_a=$p2_a, p3_a=$p3_a, s1_b=$s1_b, s2b_b=$s2b_b, s3_b=$s3_b, p1_b=$p1_b, p2b_b=$p2b_b, p3_b=$p3_b, argRef_reflexive_a=$argRef_reflexive_a, argRef_reflexive_b=$argRef_reflexive_b)\n";
    
  die "kx" unless !defined $p1_b || ($self->VerbArgs_get_p1_b($argsRef) eq $p1_b);
  die "kz"         unless  $self->VerbArgs_get_stem_b($argsRef) eq $stem_b;
          		
  $reflexive_a = $argRef_reflexive_a unless defined $reflexive_a;
  $reflexive_b = $argRef_reflexive_b unless defined $reflexive_b;
  if ($verb_b =~ /(.*)(si)$/)
  {
    $reflexive_b = $2;
    $verb_b = $1 . "e";
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
  my($p2a_b, $p3a_b, $p3b_b) = ($p3_b, $p3_b, $p3_b);
          	
  die "bad stem" unless defined $stem_a;
          		
  if (($tense eq "past_conditional")
  || ($tense eq "future_perfect")
  || ($tense eq "past")
  || ($tense eq "pluperfect"))
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
    if ($helperVerb_b eq "essere")
    {
      $s3b_b = AdjustPastParticipleEnding($s3b_b, "a");
      $p1_b = AdjustPastParticipleEnding($p1_b, "i");
      $p2a_b = AdjustPastParticipleEnding($p2a_b, "i");
      $p2b_b = AdjustPastParticipleEnding($p2b_b, "i");
      $p3a_b = AdjustPastParticipleEnding($p3a_b, "i");
      $p3b_b = AdjustPastParticipleEnding($p3b_b, "e");
    }
  }
  elsif (($tense eq "imperfect")
  || ($tense eq "future")
  || ($tense eq "imperative")
  || ($tense eq "preterite")
  || ($tense eq "subjunctive")
  || ($tense eq "conditional"))
  {
    ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3a_b) = $self->ResolveEndings($stem_b, $inf_b, $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3_b, $tense, $trailingString_b);
    #print "got back from ResolveEndings: $s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3a_b\n";
    $s3b_b = $s3a_b;
    $p2a_b = $p3a_b;
    $p3b_b = $p3a_b;
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
    $p3a_b = $self->Combine($stem_b, $p3a_b) . "$trailingString_b" if defined $p3a_b;
    $p3b_b = $self->Combine($stem_b, $p3b_b) . "$trailingString_b" if defined $p3b_b;
    							
    $s1_a  = $self->Combine($stem_a, $s1_a)  . "$trailingString_a" if defined $s1_a;
    $s2_a  = $self->Combine($stem_a, $s2_a)  . "$trailingString_a" if defined $s2_a;
    $s3a_a = $self->Combine($stem_a, $s3a_a) . "$trailingString_a"; # always
    $s3b_a = $self->Combine($stem_a, $s3b_a) . "$trailingString_a" if defined $s1_a;
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
  my($self, $reflexive, @actions) = @_; # @actions was $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b
  if ($reflexive)
  {
    return ( "io mi ", "Lei\nsi ", "tu\nti ", "lui si ", "lei si ", "noi ci ", "Loro\nsi ", "voi\nvi ", "loro si " );
  }
  else
  {
    return ( "io ", "Lei\n", "tu\n", "lui ", "lei ", "noi ", "Loro\n", "voi\n", "loro " );
  }
}

sub VTtoS
{
  my($self, $verb_b, $tense, $doingVerbTable) = @_;
  #print "VTtoS($verb_b, $tense)\n";
    				
  my($stem_b, $inf_b, $pastParticiple_b, $pastParticiple_a, 
  $stem_a, $inf_a, $s1_a, $s2_a, $s3a_a, $s3b_a, $p1_a, $p2_a, $p3_a,
  $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b, $p3b_b,
  $reflexive_a, $reflexive_b) 
  = $self->GetVTtoSParms($verb_b,$tense,'','',undef,undef,0);
    			
  #print "got back from GetVTtoSParms: $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b\n";

  
  my $hdr_inf_a = $self->Get_verb_a_withToIfAppropriate($verb_b);
    					
  $self->VerbGenInit($verb_b);
  my @s = ();
  my @p = ();
  if ($tense eq "imperative")
  {
    my $s2b_non = $verb_b;
    if ($s2b_non =~ /(.*)si$/)
    {
      $s2b_non = $1 . "e";
    }

    if ($reflexive_b)
    {
      push @s, $self->X($tense, "$s2_a!", "s2a", "si ${s2a_b}!", $s2a_b) if defined $s2a_b; 
      if (defined $s2b_b)
      {
	push @s, $self->X($tense, "don't $s2_a!", "s2b_no", "non ti $s2b_non!",   $s2b_non, 1);
	push @s, $self->X($tense,       "$s2_a!", "s2b",    "${s2b_b}^D ti!", $s2b_b);
      }
      
      push @p, $self->X($tense, "let's $p1_a!", "p1", "${p1_b}^D ci!", $p1_b) if defined $p1_b;
      $self->X($tense, "let's not $p1_a!", "p1_no", "non ${p1_b}^D ci!", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "$p2_a!", "p2a", "si ${p2a_b}!", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "$p2_a!", "p2b",     "${p2b_b}^D vi!", $p2b_b) if defined $p2b_b;
      $self->X(   $tense, "don't $p2_a!", "p2b_no", "non ${p2b_b}^D vi!", $p2b_b) if defined $p2b_b;
    }
    else
    {
      push @s, $self->X($tense, "$s2_a!", "s2a", "${s2a_b} (\nLei\n)!", $s2a_b) if defined $s2a_b; 
      push @s, $self->X($tense, "don't $s2_a!", "s2b_no", "non $s2b_non (\ntu\n)!", $s2b_non, 1) if defined $s2b_b;
      push @s, $self->X($tense, "$s2_a!",       "s2b",     "${s2b_b} (\ntu\n)!", $s2b_b) if defined $s2b_b;
      
      push @p, $self->X($tense, "let's $p1_a!",     "p1", "${p1_b}!",     $p1_b) if defined $p1_b;
      $self->X(         $tense, "let's not $p1_a!", "p1_no", "non ${p1_b}!", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "$p2_a!", "p2a", "${p2a_b} (\nLoro\n)!", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "$p2_a!", "p2b",     "${p2b_b} (\nvoi\n)!", $p2b_b) if defined $p2b_b;
      $self->X($tense, "don't $p2_a!",    "p2b_no", "non ${p2b_b} (\nvoi\n)!", $p2b_b) if defined $p2b_b;
    } 
  }
  else
  {
    my($pp_s1_b, $pp_s2a_b, $pp_s2b_b, $pp_s3a_b, $pp_s3b_b, $pp_p1_b, $pp_p2a_b, $pp_p2b_b, $pp_p3a_b) = $self->GetPersonalPronouns($reflexive_b, $s1_b, $s2a_b, $s2b_b, $s3a_b, $s3b_b, $p1_b, $p2a_b, $p2b_b, $p3a_b);
    if ($self->GetOverride("$verb_b", "it only"))
    {
      push @s, $self->X($tense, "it $s3a_a", "s3a", "$s3a_b", $s3a_b);
    }
    else
    {
      push @s, $self->X($tense, "I $s1_a", "s1", "$pp_s1_b$s1_b", $s1_b) if defined $s1_b;
      push @s, $self->X($tense, "you $s2_a", "s2a", "$pp_s2a_b\n$s2a_b", $s2a_b) if defined $s2a_b;
      push @s, $self->X($tense, "you $s2_a", "s2b", "$pp_s2b_b\n$s2b_b", $s2b_b) if defined $s2b_b;
      push @s, $self->X($tense, "he $s3a_a", "s3a", "$pp_s3a_b$s3a_b", $s3a_b) if defined $s3a_b;
      push @s, $self->X($tense, "she $s3b_a", "s3b", "$pp_s3b_b$s3b_b", $s3b_b) if defined $s3b_b;
      $self->X($tense, "one $s3b_a", "s3c", "ognuno $s3b_b", $s3b_b) if defined $s3b_b;
          						
      push @p, $self->X($tense, "we $p1_a", "p1", "$pp_p1_b$p1_b", $p1_b) if defined $p1_b;
      push @p, $self->X($tense, "you $p2_a", "p2a", "$pp_p2a_b\n$p2a_b", $p2a_b) if defined $p2a_b;
      push @p, $self->X($tense, "you $p2_a", "p2b", "$pp_p2b_b\n$p2b_b", $p2b_b) if defined $p2b_b;
      push @p, $self->X($tense, "they $p3_a", "p3a", "$pp_p3a_b$p3a_b", $p3a_b) if defined $p3a_b;
      push @p, $self->X($tense, "they $p3_a", "p3b", "$pp_p3a_b$p3b_b", $p3b_b) if defined $p3b_b;
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
  #print "PossibleSpellingChange($tense, $verb_b, $stem, $s)...";
  die "cannot extract base from $stem" unless $stem =~ /(.*)(.)$/;
    
    
    
  $s =~ s/ii/i/;
  
  
  #my($baseStem, $finalLetter) = ($1, $2);
  #
  #if ($verb_b =~ /car$/)
  #{
    #$s =~ s{$stem(/?e.*)}{${baseStem}qu$1};
  #}
  #elsif ($verb_b =~ /gar$/)
  #{
    #$s =~ s{$stem(/?e.*)}{${baseStem}gu$1};
  #}
  #elsif ($verb_b =~ /g[ei]r$/)
  #{
    ##print "in coger Poss.: bs=$baseStem, s=$s\n";
    #$s =~ s{${baseStem}g(/?[ao].*)}{${baseStem}j$1};	# (coger) cogo -> cojo
  #}
  #elsif ($verb_b =~ /guir$/)
  #{
    #$s =~ s{$stem(/?[ao].*)}{${baseStem}$1};	# gu -> g
  #}
  #elsif ($verb_b =~ /zar$/)
  #{
    #$s =~ s{$stem(/?e.*)}{${baseStem}c$1};
  #}
  #elsif ($verb_b =~ /eer$/)
  #{
    #$s =~ s{${stem}i(.*)}{${stem}y$1};
  #}
  #elsif ($verb_b =~ /cer$/)
  #{
    #$s =~ s{${stem}o$}{${baseStem}zo};	# (hacer) hico -> hizo
  #}
  #elsif ($verb_b =~ /uir$/)
  #{
    #$s =~ s{${stem}ie(.*)}{${stem}ye$1};	# (construir) construieron -> construyeron
  #}
  #
  ##print "...yielded $s\n";
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
  
  my $all = $self->GetOverrideList($verb_b, $tense);
  if (defined $all)
  {
    return @$all;
  }
  
  #print "AddEndings($verb_b, $stem_b, $tense, $trailingString)\n";
  my ($stem_s12, $stem_sp3, $stem_p12) = $self->SplitItem($stem_b);
  if ($tense eq "future")
  {
    return (
    "${stem_b}`o$trailingString",
    "${stem_b}ai$trailingString",
    "${stem_b}`a$trailingString",
    "${stem_b}emo$trailingString",
    "${stem_b}ete$trailingString",
    "${stem_b}anno$trailingString"
    );
  }
  elsif ($tense eq "preterite")
  {
    my $middle = "$1" if ($verb_b =~ /(.)re$/);
    my $preterite133 = $self->GetOverride($verb_b, "preterite 133");
    my($s1, $s3, $p3);
    if (defined $preterite133)
    {
      ($s1, $s3, $p3) = ("${preterite133}i", "${preterite133}e", "${preterite133}ero");
    }
    else
    {
      if ($middle eq "a")	# -are verbs
      {
	$s3 = "$stem_b`o";
      }
      elsif ($middle eq "e")	# -ere verbs
      {
	$s3 = "$stem_b`e";
      }
      elsif ($middle eq "i")	# -ire verbs
      {
	$s3 = "$stem_b`i";
      }
      else
      {
	$s3 = "";
	warn $verb_b;
      }
      
      ($s1, $p3) = ("$stem_b${middle}i", "$stem_b${middle}rono");
    }
        
    return (
    "$s1$trailingString",
    "${stem_b}${middle}sti$trailingString",
    "$s3$trailingString",
    "${stem_b}${middle}mmo$trailingString",
    "${stem_b}${middle}ste$trailingString",
    "$p3$trailingString"
    );
  }
  elsif ($tense eq "conditional")
  {
    return (
    "${stem_b}ei$trailingString",
    "${stem_b}esti$trailingString",
    "${stem_b}ebbe$trailingString",
    "${stem_b}emmo$trailingString",
    "${stem_b}este$trailingString",
    "${stem_b}ebbero$trailingString",
    );
  }
  elsif ($tense eq "imperfect")
  {
    #    if ($verb_b =~ /are$/)
    {
      return (
      "${stem_b}vo$trailingString",
      "${stem_b}vi$trailingString",
      "${stem_b}va$trailingString",
      "${stem_b}vamo$trailingString",
      "${stem_b}vate$trailingString",
      "${stem_b}vano$trailingString",
      );
    }
  } 
  elsif (($tense eq "subjunctive")
  ||     ($tense eq "imperative"))
  {
    my $sNEnding;
    #my $s2aImperativeEnding;
    #my $p2bImperativeEnding;
    if ($verb_b =~ /are$/)
    {
      $sNEnding = "i";
      #$s2aImperativeEnding = "a";
      #$p2bImperativeEnding = "ate";
    }
    elsif ($verb_b =~ /ere$/)
    {
      $sNEnding = "a";
      #$s2aImperativeEnding = "i";
      #$p2bImperativeEnding = "ete";
    }
    elsif ($verb_b =~ /ire$/)
    {
      $sNEnding = "a";
      #$s2aImperativeEnding = "i";
      #$p2bImperativeEnding = "ite";
    }
    else
    {
      $sNEnding = "a";
    }
        
    my $subjunctive_s1 = PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}$sNEnding$trailingString");
    my $subjunctive_s2 = PossibleSpellingChange($tense, $verb_b, $stem_s12, "${stem_s12}$sNEnding$trailingString");
    my $subjunctive_s3 = PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}$sNEnding$trailingString");
    my $subjunctive_p1 = PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}iamo$trailingString");
    my $subjunctive_p2 = PossibleSpellingChange($tense, $verb_b, $stem_p12, "${stem_p12}iate$trailingString");
    my $subjunctive_p3 = PossibleSpellingChange($tense, $verb_b, $stem_sp3, "${stem_sp3}${sNEnding}no$trailingString");
    
    if ($tense eq "subjunctive")
    {
      return (
      $subjunctive_s1,
      $subjunctive_s2,
      $subjunctive_s3,
      $subjunctive_p1,
      $subjunctive_p2,
      $subjunctive_p3
      );
    }
    elsif ($tense eq "imperative")
    {
      my $ref = $self->GetOverrideList($verb_b, "subjunctive");
      if (defined $ref)
      {
	($subjunctive_s1, $subjunctive_s2, $subjunctive_s3,
	$subjunctive_p1, $subjunctive_p2, $subjunctive_p3) = @$ref;
      }
      
      my $argsRef = $self->GetVerbArgs($verb_b); 
      #Ndmp::Ah("imp ref", @$argsRef);
      my($presentTenseStem_b, $dummy1, $dummy2,
      $dummy3, $dummy4, $dummy5, $dummy6, $dummy7, $dummy8, $dummy9, $dummy10,
      $indicative_s1_b, $indicative_s2b_b, $indicative_s3_b, $indicative_p1_b, $indicative_p2b_b, $indicative_p3_b) = @$argsRef;
            
      $indicative_s2b_b = $self->Combine($presentTenseStem_b, $indicative_s2b_b) if defined $indicative_s2b_b;
      if ($verb_b =~ /iare$/)
      {
	$indicative_s2b_b =~ s/i$/ia/;
      }
      elsif ($verb_b =~ /are$/)
      {
	$indicative_s2b_b =~ s/i$/a/;
      }
      
      $indicative_p1_b  = $self->Combine($presentTenseStem_b, $indicative_p1_b) if defined $indicative_p1_b;
      
      $indicative_p2b_b = $self->Combine($presentTenseStem_b, $indicative_p2b_b) if defined $indicative_p2b_b;
      
      return (
      undef,
      $indicative_s2b_b,
      $subjunctive_s3,
      $indicative_p1_b,
      $indicative_p2b_b,
      $subjunctive_p3
      );
    }
    else
    {
      die $tense;
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
    my @conjugationCopy = @$conjugation;
    my $ref = nlist::catAll(\@conjugationCopy, $trailingString_b);
    #Ndmp::Ah("ResolveEndings from catAll", $ref);
    return @$ref;
  }
    
  
  my $conjugationStem = $self->GetOverride("$verb_b", "$tense");
    					
  if (defined $conjugationStem)
  {
    #print "ResolveEndings: taking $conjugationStem from Override\n";
  }
  else
  {
    $conjugationStem = $self->GetStem($verb_b, $tense);
  } 
  ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3_b) = $self->AddEndings($verb_b, $conjugationStem, $tense, $trailingString_b);
  return ($s1_b, $s2b_b, $s3a_b, $p1_b, $p2b_b, $p3_b);
}

sub AdjustPastParticipleEnding
{
  my($x, $suffix) = @_;
  if (defined $x)
  {
    my $trailingString = undef;
    
    if ($x =~ /^(\S+ \S+)( .*)/)
    {
      $x = $1;
      $trailingString = $2;
    }
    die $x unless $x =~ /o$/;
    die $suffix unless  $suffix =~ /^[aoie]$/;
    $x =~ s/.$/$suffix/;
        
    $x .= $trailingString if defined $trailingString;
    #print "AdjustPastParticipleEnding($suffix): $x\n";
  }
  return $x;
}

sub MakeRecursive
{
  my($self, $verb) = @_;
  if ($verb =~ /(.*r)e$/)
  {
    return $1 . "si";
  }
  return $verb;	# already recursive or multi-word -- it's a no-op
}

sub StripReflexivity
{
  my($self, $verb_b) = @_;
  $verb_b =~ s/si( .*)?$/e/;
  return $verb_b;
}

sub SetReflexivity_b
{
  my($self, $verb_b, $argsRef) = @_;
  #Ndmp::Ah("SetReflexivity_b", $argsRef);
  my $reflexive_b = '';
  if ($verb_b =~ /.*(si)( .*)?$/)
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
  
  if ($verb =~ /(.*)si$/)
  {
    $verb = $1 . "e";
  }
  my $a1;
  my $b1;
  my $b2 = undef;
  my $a2 = undef;
  if (($paradigmVerb =~ /^uscire$/)
  && ($verb =~ /(.*)$paradigmVerb$/))
  {
    ($a1, $a2) = ("${1}u", "${1}e");
    ($b1, $b2) = ("^u", "^e");
  }
  elsif ($verb =~ /(.*)$paradigmVerb$/)
  {
    my $commonPrefix = $1;
    
    die $paradigmVerb unless $paradigmVerb =~ /^(.)/;
    my $paradigmVerbLetter1 = $1;
        
    die $verb unless $verb =~ /^(.)/;
    my $verbLetter1 = $1;
    
    $b1 =  "^$paradigmVerbLetter1";
    $a1 =  "$commonPrefix$paradigmVerbLetter1";
  }
  elsif ($paradigmVerb =~ m{^(cogliere|rispondere)$})
  {
    die $paradigmVerb unless $paradigmVerb =~ /^(.*)......$/;	# 6
    $b1 = "^$1"; 
    die $verb unless $verb =~ /(.*)......$/;
    $a1 = $1;
  }
  elsif ($paradigmVerb =~ m{^(crescere|leggere|prendere)$})
  {
    die $paradigmVerb unless $paradigmVerb =~ /^(.*).....$/;	# 5
    $b1 = "^$1"; 
    die $verb unless $verb =~ /(.*).....$/;
    $a1 = $1;
  }
  elsif ($paradigmVerb =~ m{^(aprire|cominciare|fingere|offrire|piacere|produrre|perdere|ridere)$})
  {
    die $paradigmVerb unless $paradigmVerb =~ /^(.*)....$/;
    $b1 = "^$1";
    die $verb unless $verb =~ /(.*)....$/;
    $a1 = $1;
  }
  elsif ($paradigmVerb =~ m{^(.*).re$})
  {
    $b1 = "^$1";
    die "lskdj" unless $verb =~ /(.*)...$/;
    $a1 = $1;
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
  $verb1 = $1 . "e" if $verb1 =~ /(.*)si$/;
  $verb2 = $1 . "e" if $verb2 =~ /(.*)si$/;
  return $verb1 eq $verb2;
}

sub GetAuxiliaryVerbs
{
  my($self) = @_;
  return ( "essere", "avere" );
}

sub Init
{
  my($self, $lang) = @_;
  $self->{"s2a_possessive"} = "Suo";
  $self->{"s2b_possessive"} = "tuo";
  $self->{"p2a_possessive"} = "Loro";
  $self->{"p2b_possessive"} = "vostro";
  $self->{"regular_verbs_regexp"} = "(parlare|cominciare|credere|dormire|cercare|prendere)";
  $self->SUPER::Init($lang);
}

sub GeneratePastExercises
{
  my($self) = @_;
  my $v = $self->{"verbs"};
  my $n = 0;
  my $f = new IO::File("> data/it_past");
  print $f "\@val = (\n"; 
  foreach my $verb_b (keys %$v)
  {
    next if $verb_b =~ / /;
    next if $verb_b =~ /si$/;
    next if $verb_b =~ /2$/;
            
    my $p133 = $self->GetOverride($verb_b, "preterite 133");
    my $pList = $self->GetOverrideList($verb_b, "preterite");
    my $ppOverridden = $self->GetOverride($verb_b, "past participle");
    if (defined $p133 || defined $pList || defined $ppOverridden || $self->IsIrregularVerb($verb_b))
    {
      my $pastStem = $self->GetStem($verb_b, "preterite");
      my $pp = $self->GetPastParticiple($verb_b);
                        
      print $f "{\n'English' => 'What are the past stem and past participle of <i>";
      print $f $self->GetVerbTableLink($verb_b, $verb_b, 0);
      print $f "</i> (and what does it mean)?',\n";
      print $f "'Italian' => '";
                  
      print $f ((defined $ppOverridden) ? "Irregular past participle:" : "Past participle:");
      print $f "<font color=red><i>$pp</i></font><br><br>"; 
                  
      if (defined $pList)
      {
	print $f "This verb is irregular in the past";
      }
      elsif (defined $p133)
      {
	if (defined $self->GetOverride($verb_b, "it only"))
	{
	  print $f "Past stem: <font color=red><i>$p133</i></font><br>";
	}
	else
	{
	  print $f "Past stem for <i>io/Lei/loro</i>: <font color=red><i>$p133</i></font><br>";
	  print $f "Past stem for <i>noi/voi/tu</i>: <font color=red><i>$pastStem</i></font>";
	}
      }
      else
      {
	print $f "Past stem: <font color=red><i>$pastStem</i></font>";
      }
      my @all = $self->AddEndings($verb_b, $pastStem, "preterite", "");
      my $loop1 = 1;
      if (defined $self->GetOverride($verb_b, "it only"))
      {
	print $f "<br><table bgcolor=white border=1 cellpadding=0 cellspacing=0 width=50%><tr><td>$all[2]</td></tr></table>";
      }
      else
      {
	print $f "<br><table bgcolor=white border=1 cellpadding=0 cellspacing=0 width=50%><tr><td>$all[0]</td><td>$all[3]</td></tr><tr><td>$all[1]</td><td>$all[4]</td></tr><tr><td>$all[2]</td><td>$all[5]</td></tr></table>";
      }
      print $f "<br><br><i>$verb_b</i> means <i>" . $self->Get_verb_a_withToIfAppropriate($verb_b) . "</i>\n";
      
      print $f "',\n'id' => $n,\n";
      print $f "},\n";
      $n++; 
    }
  }
  print $f ");\n";
  $f->close();
  print "it_past updated.\n"; 
  print "perl -w tx.pl -genPath it_past -categories English/Italian\n";
}

sub OnEndOfGrammarGeneration
{
  my($self) = @_;
  $self->OverrideVerbTableLookup("di");		# it: conjunction di v. s2b imperative decir
  $self->OverrideVerbTableLookup("da");		# it: conjunction di v. dare
  
  warn "skipping it_past for now...";
  #$self->GeneratePastExercises();
  
  $self->SUPER::OnEndOfGrammarGeneration();
}  

sub IsModifiedPastParticiple
{
  my($self, $token, $id) = @_;
  my $val = ($token =~ m{[aei]$});
  return $val;
}

sub PastParticipleMustAgreeWithSubject
{
  my($self, $subject) = @_;
  my $s = $self->AdjectivalExpressionMustAgree("When a compound past tense is formed using\n,essere\n, the past participle is treated like an adjective of the subject, and so must agree with that subject in gender and number.", $subject, "subject", "=Verbs=past=with_essere", "forming the past using ,essere");
  #print "Italian_grammar::PastParticipleMustAgreeWithSubject(" . nutil::ToString($subject) . "): $s\n";
  return $s;
}

sub ExplainAdjectivalChange
{
  my($self, $modifiedAdjective, $unmodifiedAdjective) = @_;

  if ($modifiedAdjective =~ /i$/)
  {
    return "plural";
  }
  elsif ($modifiedAdjective =~ /e$/)
  {
    return "feminine and plural";
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

sub DeriveUnmodifiedAdjective
{
  my($self, $token) = @_;
  die $token unless $token =~ /(.*)[aeio]$/;
  return $1 . "o";
}

sub MakeAdditionalNotes
{
  my($self, $context, $verb_b) = @_;
  die $context unless defined $verb_b;

  my $add = "";
  my $token = $self->Get__currentToken();

  if (($verb_b =~ /ire$/)
  && ($token =~ /isc.(no)?$/)
  && (($context eq "present") || ($context eq "subjunctive")))
  {
    my $link = $self->MakeURLToSpellingChanges($context, "-ire", "with_isc");
    $context .= " tense" unless $context eq "subjunctive";
    $add .= " This form illustrates " . $self->MakeLink("<i>-isc-</i> verbs' spelling changes in the $context", $link) . ".";
  }
  elsif ($context eq "preterite")
  {
    $add .= $self->{"noteDivider"} . "The " . $self->GetTenseLink("past", 1) . " tense would have also been correct here.";
    #print "Italian_grammar::MakeAdditionalNotes($context, $verb_b): $token\n";
    if ($verb_b =~ /[^t]ere$/ && $token =~ m{(ei|`e|erono)$})
    {
      my $suffix = $1;
      my $alternative;
      $alternative = "etti"   if ($suffix eq "ei");
      $alternative = "ette"   if ($suffix eq "`e");
      $alternative = "ettero" if ($suffix eq "erono");
      $token =~ s/$suffix$/$alternative/;
      $add .= $self->{"noteDivider"} . "<i>$token</i> would also have been acceptable (cf. "
      . $self->MakeGrammarLink("alternate past definite forms for <i>-ere</i> verbs", "=Verbs=preterite=alternate_forms_for_ere_verbs")
      . ".";
    }
    $add .= $self->{"noteDivider"} . "To study the definite past and its many irregular conjugations, go to " .  $self->CgiLink("Italian past and past participle drills", "it_past") . ".";
  }
  elsif ($context eq "past")
  {
    $add .= $self->{"noteDivider"} . "To study Italian's frequently irregular past participles, go to " .  $self->CgiLink("Italian past and past participle drills", "it_past") . ".";
  }

  print "Italian_grammar::MakeAdditionalNotes($context, $verb_b): $add\n" if (Argv_db::FlagSet("MassageAndFootnoteDebug"));
  return $add;
}

sub ResolveVtlLookupAmbiguity
{
  my($self, $token, $vtlVal, $areas, $id) = @_;
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "imperative", "subjunctive");
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "subjunctive", "present");
  $self->SUPER::ResolveVtlLookupAmbiguity($token, $vtlVal, $areas, $id);
}


sub LooksLikeRecursiveUse
{
  my($self, $rawToken, $s) = @_;
  my $val = 0;
  if ($s !~ /$rawToken/i)
  {
    # sometimes past participles are normalized, and so don't match up anymore
    # (eg, svegliati -> svegliato).
    # Compensate by hacking off the last character:
    die "$rawToken should be an unmodified past participle" unless $rawToken =~ /(.*)o$/;
    $rawToken = $1;
    die "$rawToken should be in $s" unless $s =~ /$rawToken/i;
  }


  if (($s =~ /non ti $rawToken/i)
  ||  ($s =~ /${rawToken}(ci|ti|vi)/i)
  ||  ($s =~ /si ${rawToken}/i))
  {
    # looks like imperative reflexive
    $val = 1;
  }
  else      ######## elsif ($rawToken =~ /t[aeio]$/) # looks like a pp
  {
    # the '.*' is to cover the possibility of a helper verb
    $val = ($s =~ /(io|tu|lei|loro|noi|voi) [mtscv]i .*$rawToken/i);
  }
  #print "Italian_grammar::LooksLikeRecursiveUse($rawToken, $s): $val\n";
  return $val;
}

sub IsRecursive
{
  my($self, $verb) = @_;
  return $verb =~ /si$/;
}

sub CookTense
{
  my($self, $tense) = @_;
  if ($tense eq "past")
  {
    return "present perfect";
  }
  elsif ($tense eq "preterite")
  {
    return "definite past";
  }
  return $self->SUPER::CookTense($tense);
}

sub MassageAndFootnoteForOneToken
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified) = @_;
  if ($thisTokenIsPermanentlyIdentified)
  {
    return;
  }
    
  if ($self->IsAnInfinitive($normalizedToken, "MassageAndFootnoteForOneToken"))
  {
    if ( $self->MassageAndFootnoteGetToken(-1) =~ /^non$/i
    || (($self->MassageAndFootnoteGetToken(-2) =~ /^non$/i) && ($self->MassageAndFootnoteGetToken(-1) =~ /^ti$/)))
    {
      my $context = "imperative";
      my $verb = $normalizedToken;
      $self->ProposeVerbTenseNote($verb, $normalizedToken, 0, $context, undef, $id);
    }
  }
  else
  {
    $self->SUPER::MassageAndFootnoteForOneToken($token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified);
  }
}

sub X
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm, $suppressVtl) = @_;
  if (($tense eq "imperative")
  &&  ($verbForm =~ /'$/))
  {
    $other =~ s/'/^D '/;     # separate special case tu forms w/ apostrophes (eg, andare: va')
    $verbForm =~ s/'$//;     # lop the apostrophe off of the verb form
  }
  return $self->SUPER::X($tense, $english, $pronounCode, $other, $verbForm, $suppressVtl);
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->Init("Italian");
  return $self;
}

# char 1: gender
# char 2: singularOrPlural
# char 3: 'v' or 'z' or nothing: before vowel 'v', before 's'+consonant or 'z', or other
sub Mutable
{
  my($self, $whatItIsLink, $whatItIs, $ms, $fs, $mp, $fp, $msv, $fsv, $msz, $mpv, $mpz) = @_;
  my %flavors = ();
  $flavors{'whatItIs'} = $self->MakeGrammarLink($whatItIs, $whatItIsLink);

  $flavors{'fs'} = $fs;
  $flavors{'ms'} = $ms;
  $flavors{'mp'} = $mp if defined $mp;
  $flavors{'fp'} = $fp if defined $fp;
  $flavors{'msv'} = $msv if defined $msv && ($msv ne $ms);
  $flavors{'fsv'} = $fsv if defined $fsv;
  $flavors{'msz'} = $msz if defined $msz;
  $flavors{'mpv'} = $mpv if defined $mpv;
  $flavors{'mpz'} = $mpz if defined $mpz;

  my @hdr = ('', 'singular');
  my @m = ('masculine', $ms);
  my @f = ('feminine', $fs);
  
  if (defined $msv)
  {
    $fsv = $msv if !defined $fsv;
    
    push @hdr, 'singular before vowel';
    push @m, $msv;
    push @f, $fsv;
  }
  if (defined $msz)
  {
    push @hdr, 'singular before ,s and consonant or ,z';
    push @m, $msz;
    push @f, $fs;
  }
  if (defined $mp)
  {
    $fp = $mp if !defined $fp;
    
    push @hdr, 'plural';
    push @m, $mp;
    push @f, $fp;
  }
  if (defined $mpv)
  {
    push @hdr, 'plural before vowel';
    push @m, $mpv;
    push @f, $fp;
  }
  if (defined $mpz)
  {
    push @hdr, 'plural before ,s and consonant or ,z';
    push @m, $msz;
    push @f, $fp;
  }
 
  $self->SaveMutable($ms, \%flavors);
  return $self->Table([\@hdr, \@m, \@f]);
}

sub ExtractMagicThruTokenAnalysis
{
  my($self, $token, $s) = @_;
  my $val = "";
  if ($s =~ /$token (\S+)/)
  {
    my $followingToken = $1;
    my $ex = "because <i>" . $self->Cook($followingToken) . "</i> starts with ";
    if ($followingToken =~ m{^[`/#]?[aeiou]}i)		# vowel
    {
      $self->{"explanationForSpellingTransformation"} = $ex . "a vowel.";
      $val = "v";
    }
    elsif ($followingToken =~ m{^h}i)	# unaspirated 'h'
    {
      $self->{"explanationForSpellingTransformation"} = $ex . "an unaspirated ,h.";
      $val = "v";
    }
    elsif ($followingToken =~ /^(z|s[^aeiouy])/i)	# 'z' or 's' + consonant
    {
      $self->{"explanationForSpellingTransformation"} = $ex . (($followingToken =~ /^z/) ? "a <i>z</i>" : "an <i>s</i> followed by a consonant.");
      $val = "z";
    }
    elsif ($followingToken =~ /^(gn|ps|pn|x)/i)	# 207 'lo' rules
    {
      $self->{"explanationForSpellingTransformation"} = $ex . "<i>" . $1 . "-</i>.";
      $val = "z";
    }
    elsif ($followingToken =~ m{^([yi][`/#]?[aeiou])}i)	# 207 'lo' rules
    {
      $self->{"explanationForSpellingTransformation"} = $ex . "<i>" . $1 . "-</i> followed by a vowel.";
      $val = "z";
    }
  }
  delete($self->{"explanationForSpellingTransformation"}) unless $val;
  print "Italian_grammar::ExtractMagicThruTokenAnalysis($token, $s): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub MakeAdjectiveConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $magic) = @_;
  my $val = undef;
  my $explanation = undef;
  if ($token =~ /^(blu|extra|marrone|rosa|viola)$/)
  {
    $val = $token;
    $explanation = "<i>$token</i> is an invariable adjective.";
  }
  elsif ($gender eq 'f')
  {
    if ($singularOrPlural eq 's')
    {
      if ($token =~ /(.*)o$/)
      {
	$val = $1 . "a";
      }
      elsif ($token =~ /(.*)one$/) # 229
      {
	$val = $1 . "ona";
      }
    }
    else
    {
      if ($token =~ /(.*[cg])[ao]$/)
      {
	$val = $1 . "he";
      }	
      elsif ($token =~ /(.*)[ao]$/)
      {
	$val = $1 . "e";
      }	
      elsif ($token =~ /(.*)e$/)
      {
	$val = $1 . "i";
      }	
    }
  }
  elsif ($singularOrPlural eq 'p')
  {
    if ($token =~ /(.*)io$/)
    {
      $val = $1 . "i";
    }	
    elsif ($token =~ /(.*)[eo]$/)
    {
      $val = $1 . "i";
    }	
  }
           
  if (defined $val && !defined $explanation)
  {
    $explanation = $self->ExplainAdjectiveChange($token, $val, $gender, $singularOrPlural, $magic);
  }
  my $oToken;
  if (!defined $val) 
  {
    $oToken = undef;
  }
  else
  {
    $oToken = new o_token($self, $val);
    $oToken->AddNote($explanation);
  }

  print "Italian_grammar::MakeAdjectiveConformToCharacteristics($token, $gender, $singularOrPlural, $magic): " . (defined $oToken ? $oToken->ToString() : "undef") . "\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $oToken;
}


sub GetNounGender
{
  my($self, $noun, $silent, $singularOrPlural) = @_;
          
  my $gender = $self->SUPER::GetNounGender($noun, 1, $singularOrPlural);
  if (!defined $gender)
  {
    if ($noun =~ /a$/)	# noun looks feminine; look to see if there is a masculine version
    {
      my $masculineNoun = $noun;
      $masculineNoun =~ s/a$/o/;
      $gender = 'f' if $self->IsNoun($masculineNoun);
    }
    if (!defined $gender)
    {
      if ($noun =~ m{(ma)$})	# -a tends to be 'f', but -ma are sometimes Greek words, which are 'm'
      {
	;
      }
      elsif ($noun =~ m{([cg]a)$})	# some number of nouns of both genders, w/ incompatible rules to form plurals
      {
	;
      }
      elsif ($noun =~ m{(ie|ione|udine|ite|igine|ice|gia|t/u|t/a)$})
      {
	$gender = "f";
      }
      elsif ($noun =~ m{(i)$})
      {
	$gender = "f";
      }
      elsif ($noun =~ m{(ore|ame|ale|ile|ere|o)$})
      {
	$gender = "m";
      }
    }
  }
  if (!defined $gender)
  {
    warn($self->{"lang"} . ": no gender for $noun");
    $gender = 'm';	# dft
  }
  #print "Italian_grammar::GetNounGender($noun): " . nutil::ToString($gender) . "\n";
  return $gender;
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
  
sub GuessPlural
{
  my($self, $noun) = @_;
  my $val = $noun;
  if ($noun =~ /(.*)io$/)
  {
    $val = $1 . "i";
  }
  elsif ($noun =~ /(.*)[eo]$/)
  {
    $val = $1 . "i";
  }
  elsif ($noun =~ /(.*[cg])a$/)
  {
    my $stem = $1;
    my $gender = $self->GetNounGender($noun, 0, 'p');
    if ($gender eq 'm')
    {
      $val = $stem . "hi";
    }
    else
    {
      $val = $stem . "he";      
    }
  }
  elsif ($noun =~ /(.*)[a]$/)
  {
    $val = $1 . "e";
  }
  print "Italian_grammar::GuessPlural($noun): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub GetPronounName
{
  my($self, $pronounCode) = @_;
    
  return 'io' if $pronounCode =~ /s1/;
  return 'Lei' if $pronounCode =~ /s2a/;
  return 'tu' if $pronounCode =~ /s2b/;
  return 'lui' if $pronounCode =~ /s3a/;
  return 'lei' if $pronounCode =~ /s3b/;
  return 'loro' if $pronounCode =~ /p3/;
  return 'noi' if $pronounCode =~ /p1/;
  return 'Loro' if $pronounCode =~ /p2a/;
  return 'voi' if $pronounCode =~ /p2b/;
  die $pronounCode;
}

sub ReplacePronounWithAddend
{
  my($self, $other, $adjustedAddend) = @_;
  $other =~ s/(io|tu|lui|lei|loro|noi|voi)/$adjustedAddend/i;
  return $self->SUPER::ReplacePronounWithAddend_common($other, $adjustedAddend);
}
  
sub LooksLikeAnAdjective
{
  my($self, $token) = @_;
  my $val;
  if ($token =~ m{^(a|da|di|in|per|verso)$})
  {
    $val = 0;
  }
  else
  {
    $val = $self->SUPER::LooksLikeAnAdjective($token);
  }
  print "Italian_grammar::LooksLikeAnAdjective($token): $val\n" if $self->{"Trace_ConformingToCharacteristics"};
  return $val;
}

sub ExplainWhatItIs
{
  my($self, $token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics) = @_;
        
  my $explanation = $self->SUPER::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics);
  if (defined $self->{"rejectedAlternativeThatOneWouldNormallyExpect"})
  {
    die unless defined $self->{"characteristicsFount"};
    die unless defined $self->{"explanationForSpellingTransformation"};
      
    $val =~ s/\^D$//;
    
    $explanation .= $self->{"noteDivider"}
    . "<i>"
    . $val
    . "</i> is used instead of the "
    . "$whatItIs <i>"
    . $self->{"rejectedAlternativeThatOneWouldNormallyExpect"}
    . "</i> "
    . $self->{"explanationForSpellingTransformation"};
  }      
  print "Italian_grammar::ExplainWhatItIs($token, $val, $gender, $singularOrPlural, $magic, $whatItIs): " . nutil::ToString($explanation) . "\n" if $self->{"Trace_ConformingToCharacteristics"};
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
      $mutableHash = $self->HashGet("mutables", 'il');
      $oToken = $self->SUPER::CheckMutables($mutableHash, 'il', $gender, $singularOrPlural, $magic);
      my $contraction = $self->HashGet("reverseContractions", "di " . $oToken->GetToken());
      if (!defined $contraction)
      {
	nutil::Warn("no contraction for 'di ' + " . $oToken->GetToken());
      }
      else
      {
	$oToken->SetToken($contraction);
	$oToken->InsertNote($self->ExplainContraction_getNoteText($contraction));
      }
      $oToken->InsertNote('it_partitive');
    }
  }
  return $oToken;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions
{
  my($self, $key, $val) = @_;
  $val = $self->SUPER::UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val);
  while ($val =~ m{[^/`#a-z]([aeo]) [/`#]?[aeiou]}i
  ||     $val =~         m{^([aeo]) [/`#]?[aeiou]}i)
  {
    my $old = $1;
    my $new = "${1}d";
    $val =~ s{([^/`#a-z])$old }{$1$new };
    $val =~           s{^$old }{$new };	#
    my $noteKey = $self->MakeTokenNoteKey("$new", "tmp");
    tdb::Set($key, $noteKey, "<i>$new</i> often replaces <i>$old</i> when preceding a vowel.");
  }
  $val =~ s{\bd[ei] ([`/#]?[aeiouh])}{d'^D $1}gi;
  $val =~ s/bell[ao] (h?[aeou])/bell'^D $1/gi;
  $val =~ s/buon[ao] (h?[aeou])/buon'^D $1/gi;
  $val =~ s/mezz[ao] (h?[aeou])/mezz'^D $1/gi;

  if ($val =~ s/(dell[aeo]) (h?[aeou])/dell'^D $2/gi)
  {
    $self->MoveNotes($key, $1, "dell");
  }

  #
  # here's a more general solution to the problem of joining consecutive vowels; but it was applied so often
  # that I thought it must be excessive.
  #
  #while ($val =~ /\b((\S+)[aeiou]) [aeiouh]/)
  #{
  #my $old = $1;
  #my $common = $2;
  #
  #my $new = $common . "'^D";
  #
  #$self->MoveNotes($key, $old, $common);
  #$val =~ s/$old/$new/;
  #}



  #print "Italian_grammar::UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val)\n";
  return $val;
}

sub GetThat
{
  my($self) = @_;
  return "che";
}

sub UnifyCharacteristicsOf_1_ObjectPhrase
{
  my($self, $key, $s) = @_;

  my $addendKey = tdb::Get($key, "addendKey");
  if ($s =~ /\S+>s>/
  && defined $addendKey
  && $addendKey =~ /^vocab_languages/)
  {
    if ($key !~ /verb_speak/)
    {
      $s = "il $s";
    }
    $self->SetNote($key, undef, "NoteHolder('it_langs_masculine', 'it_langs_def_article_required_except_with_parlare')", "2");
  }
  $self->SUPER::UnifyCharacteristicsOf_1_ObjectPhrase($key, $s);
}
 
1;
