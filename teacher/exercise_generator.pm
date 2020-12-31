package exercise_generator;
use strict;
use diagnostics;
use tdb;

# normally not allowed.  I turn it on when I realize there is a class of generated 
# exercises which I haven't been adding, and I want them added everywhere:
my $__addingNewExercisesIsAllowed = 0;

my $__g;

sub InOneOfTheCategoryOfExercisesWhichMustBeAdded
{
  my($tense, $pronounCode) = @_;
  if (($tense ne "subjunctive") && ($tense ne "imperative"))
  {
    $pronounCode = "s2b" if ($pronounCode eq "s2");	 # make fr match up w/ es
    $pronounCode = "p2b" if ($pronounCode eq "p2");	 # make fr match up w/ es
    if (($pronounCode ne "s2b") && ($pronounCode ne "p2b"))
    {
      return 1;
    }
  }
  return 0;
}


sub AddExercise
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm) = @_;
  
  
  
  #return unless ($tense eq "past");
  #return unless InOneOfTheCategoryOfExercisesWhichMustBeAdded($tense, $pronounCode);    
  
  
  
  
  #print "AddExercise($tense, $english, $pronounCode, $other, $verbForm)\n";
    
  if ($pronounCode eq "s3c")
  {
    return;	# doesn't map well to other languages -- screw it...
  }
    
  if ($self->{"firstTimeGeneratingExercisesForThisVerb"}
  && (($pronounCode =~ /[sp]3/) || ($tense eq "past"))) # too langweile to save 'em all
  {
    my $zero_or_one = nutil::random(1);
    return if $zero_or_one == 1;
  }
      
  if (($pronounCode eq "p2") || ($pronounCode eq "p3") || ($pronounCode eq "s2"))
  {
    $self->AddExercise($tense, $english, "${pronounCode}a", $other, $verbForm);
    $self->AddExercise($tense, $english, "${pronounCode}b", $other, $verbForm);
  } 
  else
  {
    my $exerciseS = $pronounCode . "=" . $tense . "=" . $other . "=" . $verbForm . "=" . $english;
    
    #print "AddExercise: $pronounCode/$tense ($exerciseS).\n";
    $self->{"exercisesByPronounAndTense"}->{"$pronounCode/$tense"} = $exerciseS;
    
    if (defined $self->{"exercisesByTenseAndPronounCode"}->{$english})
    {
      $self->{"exercisesByTenseAndPronounCode"}->{"$tense/$pronounCode"} .= "=" . $exerciseS;
    }
    else
    {
      $self->{"exercisesByTenseAndPronounCode"}->{"$tense/$pronounCode"} = $exerciseS;
    } 
  } 
}

sub SaveExercise
{
  my($self, $id, $exerciseS, $justPrint, $newlyAdding) = @_;
  print "exercise_generator::SaveExercise($id, $exerciseS, $justPrint, $newlyAdding)\n";
  return if $__g->VetoSaveExercise($id, $self->{"verb_b"});
  
  my($pronounCode, $tense, $other, $verbForm, $english) = split('=', $exerciseS);
              
  print "SaveExercise($id, $english, $exerciseS, $justPrint): $verbForm/$other\n";
  my $lang = $self->{"lang"};
                
  my $oldPronounCode = $__g->GetPronoun($id);
  if (defined $oldPronounCode && ($oldPronounCode ne $pronounCode))
  {
    die "$id is $oldPronounCode; not in sync w/ $pronounCode" 
  }
          
  ($english, $other, $verbForm) = $__g->OnExerciseGeneration($id, $english, $tense, $pronounCode, $other, $verbForm, $self->{"verb_a"}, $self->{"verb_b"});
          
  delete($self->{"exercisesRemainingToBeUpdated"}->{$id});
  
  if ($justPrint)
  {
    print "$english -> $other\n";
  }
  else
  {
    if (defined $english
    && $__g->ShouldUpdateEnglish($id, $tense))
    {
      my $oldEnglish = tdb::Get($id, 'English');                                    
      if (!(defined $oldEnglish) || ($oldEnglish ne $english))
      {
	tdb::Set($id, 'English', $english, 1);
      }
    }
    print "exercise_generator::SaveExercise($id, $exerciseS, $justPrint, $newlyAdding): $other\n";
    tdb::Set($id, $lang, $other, 1);
    if ($newlyAdding)
    {
      die $id unless $id =~ /\.(\d+)$/;
      tdb::Set($id, 'id', $1);
                        
      tdb::Set($id, 'pronoun', $pronounCode);
      tdb::Set($id, 'generated', 1);
      tdb::Set($id, 'tense', $tense);
      tdb::SetProp($id, 'areas', $tense);
    }               
  }
}
    
sub GetMatchingExercise
{
  my($self, $pronounCode, $tense) = @_;
            
  my $key = "$pronounCode/$tense";
        
  my $exercisesByPronounAndTenseRef = $self->{"exercisesByPronounAndTense"};
  my $exerciseS = $exercisesByPronounAndTenseRef->{$key};
  if (!defined $exerciseS)
  {
    my $secondaryTense = undef;
    if ($tense eq "preterite")
    {
      $secondaryTense = "past";
    }
    elsif ($tense eq "subjunctive")
    {
      $secondaryTense = "k1";
    }
    elsif ($tense eq "past subjunctive")
    {
      $secondaryTense = "k2";
    }
    if (defined $secondaryTense)
    {
      $key = "$pronounCode/$secondaryTense";
      #print "GetMatchingExercise($pronounCode, $tense) trying $key\n";
      $exerciseS = $exercisesByPronounAndTenseRef->{$key};
    }
  }    
  #print "GetMatchingExercise($pronounCode, $tense): " . nutil::ToString($exerciseS) . "\n"; 
  #Ndmp::Hh("...from exercisesByPronounAndTenseRef", %$exercisesByPronounAndTenseRef);
  return $exerciseS;
}

sub ComplainAboutexercisesWhichShouldHaveBeenGeneratedButWereNot
{
  my($self) = @_;
  
  my $exercisesRemainingToBeUpdated = $self->{"exercisesRemainingToBeUpdated"};
  foreach my $id (sort keys %$exercisesRemainingToBeUpdated)
  {
    warn "$id: " . $self->{"lang"} . ": should have updated";
  }
}

sub Save
{
  my($self, $justPrint) = @_;
  print "exercise_generator.pm Save($justPrint)\n";
    
  my $keySuffix = $self->{"verb_a_htmlFileSuffix"};
  my $x = 0;
  my $exercisesByTenseAndPronounCodeRef         = $self->{"exercisesByTenseAndPronounCode"};
  my $exercisesByPronounAndTenseRef = $self->{"exercisesByPronounAndTense"};
  my $lang = $self->{"lang"};
                  
  # these exercises are generated language by language.  Is this
  # the first round of this generation?
        
  if (!$self->{"firstTimeGeneratingExercisesForThisVerb"})
  {
    # not the first round of generation: just follow the lead of the first
    # round and match $pronounCode and $tense:
    for(;; $x++)
    {
      my $id = "$keySuffix.$x";
      if (!defined tdb::Get($id, 'English') && !defined tdb::Get($id, 'generated'))
      {
	#print "Save(): $id has no english; apparently it's the end\n";
	last;
      }
      
      next unless tdb::IsGenerated($id, $lang);
      if ($__g->VetoSaveExercise($id, $self->{"verb_b"}))
      {
	delete($self->{"exercisesRemainingToBeUpdated"}->{$id});
	next;
      }
            
      my $tense = tdb::Get($id, "tense");
      if (!defined $tense)
      {
	warn "$id: " . $self->{"lang"} . ": expected tense setting";
	next;
      }
                            
      if (!defined tdb::Get($id, "areas"))
      {
	tdb::Set($id, "areas", "|$tense|");
      }
                            
      my $pronounCode = $__g->GetPronoun($id);
      if (!defined $pronounCode && !$__g->AddendIsSubject($id))
      {
	$pronounCode = grammar::ChoosePronoun($id, $tense);
	warn "$id: " . $__g->GetLang() . ": setting pronoun to $pronounCode";
	tdb::Set($id, "pronoun", $pronounCode);
	tdb::Set($id, "English", "-") unless defined tdb::Get($id, "English");
      }
              
      my $exerciseS = $self->GetMatchingExercise($pronounCode, $tense);
      if (!defined $exerciseS)
      {
	next unless defined $exerciseS;
      }
                      
      $self->SaveExercise($id, $exerciseS, $justPrint, 0);
    }
  }
  if ($self->{"firstTimeGeneratingExercisesForThisVerb"}
  ||  $self->{"addingNewExercisesIsAllowed"})
  {
    #Ndmp::Ah("Now ready to add", %$exercisesByTenseAndPronounCodeRef);
    foreach my $key (keys %$exercisesByTenseAndPronounCodeRef)
    {
      my $exercises = $self->{"exercisesByTenseAndPronounCode"}->{$key};
                      
      my @exercisesA = split('=', $exercises);
      foreach my $exerciseS (@exercisesA)
      {
	my $key = "$keySuffix.$x";
	$self->SaveExercise($key, $exerciseS, $justPrint, 1);
	$x++;
      }
    }
  }
    
  $self->ComplainAboutexercisesWhichShouldHaveBeenGeneratedButWereNot();
}

sub AssembleExercisesWhichShouldBeUpdated
{
  my($verb_a, $category) = @_;
  
  my $dataFile = "verb_$verb_a";
  $dataFile =~ s/ /_/g;
  
  my $maxId = tdb::GetSize($dataFile) - 1;
  my %exercisesWhichShouldBeUpdated = ();
  for (my $idNumber = 0; $idNumber <= $maxId; $idNumber++)
  {
    my $id = "$dataFile.$idNumber";
    if (tdb::IsGenerated($id, $category))
    {
      $exercisesWhichShouldBeUpdated{$id} = 1;
    }
  } 
  return \%exercisesWhichShouldBeUpdated;
}

sub Test
{
  my($justPrint) = @_;
  my $fr = new exercise_generator("French", "acqu/erir", "acquire");
  
  $fr->AddExercise("present", "you acquire", "s2b", "tu acqu/eris", "acqu/eris");
  #$fr->AddExercise("subjunctive", "you acquire", "s2b", "tu acqu/erisses", "acqu/erisses");
  
  $fr->AddExercise("imperative", "let's acquire!", "p1", "acqu/erissons!", "acqu/erissons");
  #$fr->AddExercise("imperative", "acquire!", "s2", "acqu/erisse!", "acqu/erisse");
  $fr->Save($justPrint);
  
  #my $es = new exercise_generator("Spanish", "adquirir", "acquire");
  #$es->AddExercise("present", "you acquire", "s2b", "t`u adquieres", "adquieres");
  #$es->AddExercise("subjunctive", "you acquire", "s2b", "t`u adquieras", "adquieras");
  #$es->Save($justPrint);
}

#Test(1);

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
      
  my $lang   = shift;
  my $verb_b = shift;
  my $verb_a = shift;
  my $verb_a_htmlFileSuffix = shift;
    
  $__g = shift;
    
  $self->{"verb_a_htmlFileSuffix"} = $verb_a_htmlFileSuffix;
  if (!defined tdb::Get("$verb_a_htmlFileSuffix.0", 'English'))
  {
    warn "exercise_generator::new(): previously 'firstTimeGeneratingExercisesForThisVerb' would have been turned on since there is no English, but not now since I am assuming that I will handcraft $verb_a_htmlFileSuffix";
    #$self->{"firstTimeGeneratingExercisesForThisVerb"} = 1;
  }
  
  if ($self->{"firstTimeGeneratingExercisesForThisVerb"})
  {
    print "exercise_generator::new($verb_a_htmlFileSuffix.0 lacked English, and therefore firstTimeGeneratingExercisesForThisVerb = 1\n";
  }
      
  $self->{"verb_b"} = $verb_b;
  $self->{"verb_a"} = $verb_a;
  $self->{"exercisesRemainingToBeUpdated"} = AssembleExercisesWhichShouldBeUpdated($verb_a, $lang);
  $self->{"lang"} = $lang;
  $self->{"exercisesByTenseAndPronounCode"} = {};
  $self->{"exercisesByPronounAndTense"} = {};
    
  $self->{"addingNewExercisesIsAllowed"} = $__addingNewExercisesIsAllowed;
                    
  #Ndmp::Hh("exercise_generator::new()", %$self);
  bless $self, $class;
  return $self;
}

1;
