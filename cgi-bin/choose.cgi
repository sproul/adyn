#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
my $__trace = 0;
use strict;
use diagnostics;
use IO::File;
use teacher_user;
use Ndmp;
use adyn_cgi_util;
use nutil;
use CGI qw(:standard);
use tdb;

my $EXCLUDE_EXERCISES_SEEN_BEFORE = 0;
my $EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED = 1;
my $EXCLUDE_NONE = 2;

# this hash is used to maintain uniqueness of exercises.  I used to use %selectedExercisesWithWeights
# for this purpose, but the weights attached to the exercise IDs from the review set allowed duplicates to sneak through:
my %__selectedExercises = ();
my %__selectedExercisesWithWeights = ();

my $__canonizedTest = 0;
my $__chosenTenses = ();
my @__chosenTopics = ();
my $__exerciseTargetCnt = 15;
my $__exerciseType;
my $__randomSeed;
my $__reviewExerciseTargetCnt;
my $__specific_exercise_IDs_for_testing = undef;

sub pickiness_toString
{
  my($pickiness) = @_;

  return "EXCLUDE_EXERCISES_SEEN_BEFORE" if ($pickiness==$EXCLUDE_EXERCISES_SEEN_BEFORE);
  return "EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED" if ($pickiness==$EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED);
  return "EXCLUDE_NONE" if ($pickiness==$EXCLUDE_NONE);
  die "unexpected value $pickiness";
}

sub Log
{
  my($s) = @_;
  print "// $s\n" if $__trace;
}

sub ChooseVerbs
{
  my($user, $query) = @_;
  Log("ChooseVerbs(" . nutil::ToString($user) . ", " . nutil::ToString($__exerciseType) . ")");
  my $startingRandomIndexIntoOneVerbsExercises = nutil::random(1024);
  my %randomIndicesByChosenCategory = ();

  if ((defined $__exerciseType) && ($__exerciseType eq "base"))
  {
    $randomIndicesByChosenCategory{"base"} = $startingRandomIndexIntoOneVerbsExercises;
  }
  else
  {
    my $atLeast1Selected = 0;
    if (defined $__exerciseType)
    {
      if ($__exerciseType eq "verb_selected")
      {
	@__chosenTopics = adyn_cgi_util::param($query, "chosenVerbs");
        Log("ChooseVerbs($user, $query, $__exerciseType) asked for chosen verbs");
	foreach my $verb (@__chosenTopics)
	{
          Log("ChooseVerbs($user, $query, $__exerciseType): proposed verb $verb...");
	  #
	  # the following clause is checking to see if there are exercises corresponding to this topic.
	  # The assumption is that if this is a verb topic, then present tense exercises must exist.
	  # this is really not strictly true -- it could happen that the only interesting tense is some
	  # other tense, and that I never bothered putting in a present tense exercise.
	  #
	  if (defined tdb::Get_arrayOfData("cgi_verbsToExGroupedByTense", "$verb/present"))
	  {
	    $atLeast1Selected = 1;
            Log("ChooseVerbs($user, $query, $__exerciseType): chose verb $verb");
	    $randomIndicesByChosenCategory{$verb} = $startingRandomIndexIntoOneVerbsExercises;
	  }
	}
      }
      #elsif ($__exerciseType eq "vocab_selected")
      else
      {
	@__chosenTopics = adyn_cgi_util::param($query, "chosenCategories");
	foreach my $category (@__chosenTopics)
	{
	  $atLeast1Selected = 1;
          Log("ChooseVerbs($user, $query, $__exerciseType): chose category $category");
	  $randomIndicesByChosenCategory{$category} = $startingRandomIndexIntoOneVerbsExercises;
	}
      }
    }
    Ndmp::Ah("chosenTopics (" . nutil::ToString($__exerciseType) . ") (atLeast1Selected=$atLeast1Selected)", @__chosenTopics) if $__trace;
    if (!$atLeast1Selected)
    {
      my $mostCommonVerbsAreWanted = (!defined $__exerciseType || ($__exerciseType ne "verb_all") && ($__exerciseType ne "vocab_selected"));
      if (defined $__exerciseType)
      {
        Log("ChooseVerbs: expecting the $__exerciseType == verb_common (actual value: $__exerciseType");
      }
      my $allVerbs;
      if ($mostCommonVerbsAreWanted)
      {
        Log("ChooseVerbs: selecting from the most common verbs");
	$allVerbs = tdb::Get_arrayOfData("cgi_mostCommonVerb", "keys");
      }
      elsif ($__exerciseType eq "vocab_selected")
      {
        Log("ChooseVerbs: selecting from all the vocab");
	$allVerbs = tdb::Get_arrayOfData("cgi_vocab", "keys");
      }
      else
      {
        Log("ChooseVerbs: selecting from all the verbs");
	$allVerbs = tdb::Get_arrayOfData("cgi_verbsToExGroupedByTense", "keys");
      }
      if (!defined $allVerbs)
      {
	warn "no reference to verb exercises sorted by tense";
      }
      else
      {
	my $max = scalar(@$allVerbs) - 1;
	my $verbsStillNeeded = $__exerciseTargetCnt - $__reviewExerciseTargetCnt;
	my $verbIndex = nutil::random($max);
        Log("ChooseVerbs(max=$max, verbsStillNeeded=$verbsStillNeeded, verbIndex=$verbIndex");
	for (my $j = 0; $j <= $max; $j++)
	{
	  my $verb = $allVerbs->[$verbIndex];
          Log("ChooseVerbs: all: picked $verb");
	  if (!defined $user || $user->IsInteresting($verb))
	  {
            Log("ChooseVerbs: all: picked $verb");
	    $randomIndicesByChosenCategory{$verb} = $startingRandomIndexIntoOneVerbsExercises;
	    last if --$verbsStillNeeded <= 0;
	  }
	  $verbIndex = ($verbIndex >= $max) ? 0 : $verbIndex + 1;
	}
	if ($verbsStillNeeded > 0)
	{
	  if (defined $user)
	  {
	    $user->IncrementWeights();
	  }
	  else
	  {
	    last;
	  }
	}
      }
    }
  }
  Ndmp::Hh("ChooseVerbs", %randomIndicesByChosenCategory) if $__trace;
  return \%randomIndicesByChosenCategory;
}

sub GetTenses
{
  my($query, $__exerciseType) = @_;
  my $atLeastOneTenseSpecified = adyn_cgi_util::param($query, "tense");

  my $chosenTensesRef = undef;
  if (defined $__exerciseType && $__exerciseType eq "vocab_selected")
  {
    my @t = ("present");
    die "I think this never happens";
    $chosenTensesRef = \@t;
  }
  else
  {
    if ($atLeastOneTenseSpecified)
    {
      my @selectedTenses = adyn_cgi_util::param($query, "tense");
      foreach my $tense (@selectedTenses)
      {
	if ($tense eq "all")
	{
	  Log("all tenses selected");
	  @selectedTenses = ();
	  last;
	}
      }
      $chosenTensesRef = \@selectedTenses if @selectedTenses;
      Ndmp::Ah("GetTenses", @$chosenTensesRef) if $__trace && defined $chosenTensesRef;
    }
    if (!defined $chosenTensesRef && !defined $__exerciseType)
    {
      # default tense when the user hasn't specified anything.  Normally this will be a new user coming via simple_choose.htm:
      #my @t = ("present", "past", "future");
      my @t = ("present");
      $chosenTensesRef = \@t;
    }
  }

  if ($__trace)
  {
    Ndmp::Ah("GetTenses", @$chosenTensesRef)                  if  defined $chosenTensesRef;
    Log("choose::GetTenses($query, $__exerciseType): undef")  if !defined $chosenTensesRef;
  }
  return $chosenTensesRef;
}

sub ChooseExerciseWithTense
{
  my($randomIndicesByChosenCategory, $indexIntoChosenTenses, $verb, $user, $pickiness) = @_;
  Log("oseExerciseWithTense...");


  my $val = undef;

  # it's ok to cycle through tenses because they're already random:
  my $firstCycle = 1;
  for (my $startingTenseIndex = -1;; $indexIntoChosenTenses++)
  {
    $indexIntoChosenTenses = 0 if $indexIntoChosenTenses >= scalar(@$__chosenTenses);

    if ($firstCycle)
    {
      $firstCycle = 0;
      $startingTenseIndex = $indexIntoChosenTenses;
    }
    elsif ($startingTenseIndex == $indexIntoChosenTenses)
    {
      Log("oseExerciseWithTense exiting loop because $startingTenseIndex==$indexIntoChosenTenses"); 
      last;
    }

    my $tense = $__chosenTenses->[$indexIntoChosenTenses];

    my $arrayOfExercises = tdb::Get_arrayOfData("cgi_verbsToExGroupedByTense", "$verb/$tense");
    Ndmp::Ah("indexIntoChosenTenses=$indexIntoChosenTenses => $tense for $verb: yields", @$arrayOfExercises) if $__trace;

    my $len = defined $arrayOfExercises ? scalar(@$arrayOfExercises) : 0;
    if ($len != 0)
    {
      my $exIndex = $randomIndicesByChosenCategory->{$verb} % $len;

      my $selectedExerciseId = $verb . "_" . $arrayOfExercises->[$exIndex];
      if ($pickiness==$EXCLUDE_EXERCISES_SEEN_BEFORE && defined $user && $user->IsReviewExercise($selectedExerciseId))
      {
	Log("$selectedExerciseId is a rvw ex.  Skipping...");
	next;
      }
      elsif ($pickiness==$EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED && defined $user && !$user->IsInteresting($selectedExerciseId))
      {
	Log("$selectedExerciseId has been mastered.  Skipping...");
	next;
      }
      else
      {
	Log("$selectedExerciseId is accepted...");
	$val = $selectedExerciseId;
	$randomIndicesByChosenCategory->{$verb} = $exIndex + 1;
	last;
      }
    }
  }
  Log("choose::ChooseExerciseWithTense($verb) " . nutil::ToString($val) . "");

  $indexIntoChosenTenses++;
  return ($indexIntoChosenTenses, $val);
}

sub ChooseExerciseWithoutTense
{
  my($randomIndicesByChosenCategory, $category, $user, $pickiness) = @_;

  if (!defined $category)
  {
    Log("oseExerciseWithoutTense returns undef because no category");
    return undef;
  } 

  my $max = tdb::GetSize("$category") - 1;
  if (!defined $max || $max < 0)
  {
    Log("oseExerciseWithoutTense returns undef because $category.max=" . (defined $max ? $max : "undef") . "");
    return undef; 
  } 

  my $val = undef;

  my $startingExId;
  my $exId = $randomIndicesByChosenCategory->{$category};
  for (my $firstCycle = 1;; $exId++)
  {
    if ($max > 0)
    {
      $exId %= $max;
    }
    else
    {
      $exId = 0;
    }

    if ($firstCycle)
    {
      $startingExId = $exId;
      $firstCycle = 0;
    }
    elsif ($startingExId == $exId)
    {
      Log("ChooseExerciseWithoutTense: full cycle with nothing found: (picky=$pickiness)");
      last;
    }
    my $selectedExerciseId = $category . "_" . $exId;
    if ($pickiness==$EXCLUDE_EXERCISES_SEEN_BEFORE && defined $user && $user->IsReviewExercise($selectedExerciseId))
    {
      Log("ChooseExerciseWithoutTense: $selectedExerciseId is a rvw ex: skipping");
      next;
    }
    if ($pickiness==$EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED && defined $user && !$user->IsInteresting($selectedExerciseId))
    {
      Log("ChooseExerciseWithoutTense: $selectedExerciseId has been mastered.  Skipping...");
      next;
    }

    Log("ChooseExerciseWithoutTense: $selectedExerciseId (picky=$pickiness, user=" . nutil::ToString($user) . "): will do it");
    $val = $selectedExerciseId;
    last;
  }
  $randomIndicesByChosenCategory->{$category} = $exId + 1;
  Log("choose::ChooseExerciseWithoutTense($category) " . nutil::ToString($val) . "");
  return $val;
}

sub AddNonReviewExercises
{
  my($user, $targetSize, $query, $pickiness) = @_;

  my $randomIndicesByChosenCategory = ChooseVerbs($user, $query);

  @__chosenTopics = keys %$randomIndicesByChosenCategory;

  if (!@__chosenTopics)
  {
    Log("AddNonReviewExercises: no chosen topics, so exiting w/ no exercises selected");
  } 
  else
  {
    my $indexIntoChosenTenses = 0;
    my $numberOfExercisesStillWanted = $targetSize;
    my $failureCount = 0;
    my $maxFailureCount = 10;
    
    for (my $x = 0; ($failureCount < $maxFailureCount) && ($numberOfExercisesStillWanted > 0); $x++)
    {
      $x = 0 if ($x >= scalar(@__chosenTopics));
      
      # don't try to set up a random array cuz usually the set of verbs will be small; get randomness by varying each choice:
      my $verb = $__chosenTopics[ $x ];
      Log("AddNonReviewExercises: Picked $x ($verb) to pass on to ChooseExerciseWithTense");
      
      my $selectedExerciseId;
      if (defined $__chosenTenses)
      {
        ($indexIntoChosenTenses, $selectedExerciseId) = ChooseExerciseWithTense($randomIndicesByChosenCategory, $indexIntoChosenTenses, $verb, $user, $pickiness);
      }
      else
      {
        $selectedExerciseId = ChooseExerciseWithoutTense($randomIndicesByChosenCategory, $verb, $user, $pickiness);
      }
      
      if (!defined $selectedExerciseId)
      {
        $failureCount++;
        Log("AddNonReviewExercises: Got nothing from $verb (pickiness=$pickiness, failureCount=$failureCount)");
      }
      elsif (defined $__selectedExercises{$selectedExerciseId})
      {
        $failureCount++;
        Log("AddNonReviewExercises: Rejected $selectedExerciseId -- already have it, failureCount=$failureCount");
      }
      else
      {
        $__selectedExercisesWithWeights{$selectedExerciseId} = 1;
        $__selectedExercises{           $selectedExerciseId} = 1;
        Log("AddNonReviewExercises: chose $selectedExerciseId");
        $numberOfExercisesStillWanted--;
      }
    }
    Ndmp::Ah("choose::AddNonReviewExercises($targetSize, " . pickiness_toString($pickiness) . "): still want $numberOfExercisesStillWanted", %__selectedExercisesWithWeights) if $__trace;
  }
}

sub SatisfiesCriteria
{
  my($id) = @_;

  my $isOneOfTheChosen = 0;

  my($idTopic, $idNumber) = tdb::GetAreaAndIdNumber($id);
  if (@__chosenTopics)
  {
    foreach my $topic (@__chosenTopics)
    {
      if ($idTopic eq $topic)
      {
	$isOneOfTheChosen = 1;
	last;
      }
    }
  }
  my $satisfiesCriteria = $isOneOfTheChosen;
  if ($satisfiesCriteria)
  {
    if (defined $__chosenTenses)
    {
      if (!tdb::IsPropSet($id, "areas", @$__chosenTenses))
      {
	$satisfiesCriteria = 0;
      }
    }
  }
  Log("choose::SatisfiesCriteria($id): $satisfiesCriteria");
  return $satisfiesCriteria;
}

sub ComputeShortfall
{
  my $selectedCnt = scalar(keys %__selectedExercisesWithWeights);
  $selectedCnt = 0 if !defined $selectedCnt;

  my $shortFall = $__exerciseTargetCnt - $selectedCnt;
  return $shortFall;
}

sub ChooseExercises
{
  my($user, $query) = @_;

  my $explicitlyRequestedExercises = adyn_cgi_util::param($query, "explicitlyRequestedExercises");
  if (defined $explicitlyRequestedExercises)
  {
    my @a = split(/\//, $explicitlyRequestedExercises);
    return \@a;
  }
  $__chosenTenses = ((defined $__exerciseType && $__exerciseType eq "vocab_selected") ? undef : GetTenses($query, $__exerciseType));

  if ($__reviewExerciseTargetCnt > 0)
  {
    if (defined $user)
    {
      $user->AddReviewExercises(\%__selectedExercises, \%__selectedExercisesWithWeights, $__reviewExerciseTargetCnt);
      $__reviewExerciseTargetCnt = scalar(keys %__selectedExercisesWithWeights);
    }
    else
    {
      $__reviewExerciseTargetCnt = 0;
    }
  }
  AddNonReviewExercises($user, $__exerciseTargetCnt - $__reviewExerciseTargetCnt, $query, $EXCLUDE_EXERCISES_SEEN_BEFORE);

  my $shortFall = ComputeShortfall();
  if ($shortFall > 0)
  {
    # we were short.  This is probably due to an unusual tense being called for (e.g., conditional).
    if (defined $user)
    {
      $user->AddReviewExercises(\%__selectedExercises, \%__selectedExercisesWithWeights, $shortFall, \&SatisfiesCriteria);
      $shortFall = ComputeShortfall();
    }
  }
  if ($shortFall > 0)
  {
    AddNonReviewExercises($user, $shortFall, $query, $EXCLUDE_EXERCISES_THAT_HAVE_BEEN_MASTERED);
    $shortFall = ComputeShortfall();
  }
  if ($shortFall > 0)
  {
    AddNonReviewExercises($user, $shortFall, $query, $EXCLUDE_NONE);
    $shortFall = ComputeShortfall();
  }

  Ndmp::Hh('pre shf', %__selectedExercisesWithWeights) if $__trace;
  my @all;
  nutil::shuffleCopy(\@all, [keys %__selectedExercisesWithWeights]);	# keys() returns keys in order, so shuffle
  Ndmp::Ah('post shf', @all) if $__trace;
  return \@all;
}

sub GetLangs
{
  my($query) = @_;

  my $promptLang = adyn_cgi_util::param($query, "promptLang");

  my %langHash = ();

  if (!defined $promptLang)
  {
    $promptLang = "English";
  }
  elsif ($promptLang =~ /^(French|Italian|German|Spanish)$/)
  {
    $langHash{"English"} = 1;
  }

  my @allLangParms = adyn_cgi_util::paramsStartingWith($query, "lang_");
  if (!@allLangParms)
  {
    ##$langHash{'French'} = 1;
    ##$langHash{'German'} = 1;
    ##$langHash{'Italian'} = 1;
    ## no langs specified: default is Spanish only:
    #$langHash{'Spanish'} = 1;
    
    
    $langHash{'A'} = 1;
    $promptLang = 'Q';
  }
  else
  {
    foreach my $langParm (@allLangParms)
    {
      if ($langParm =~ /lang_(.*)/)
      {
	my $which = $1;
	$langHash{$which} = 1;
      }
      else
      {
	die 'could not understand langParm=$langParm';
      }
    }
  }
  my @langs = ();
  delete($langHash{$promptLang});
  push @langs, $promptLang;		# the convention is that the first language mentioned is the prompt language
  push @langs, keys %langHash;
  #Ndmp::Ah("ls", @langs);
  return \@langs;
}

sub GetTraceInfoInHTMLComments
{
  my $s = "";
  $s .= "// exerciseType=" . nutil::ToString($__exerciseType) . ", ";
  $s .= "chosenTenses=" . (defined $__chosenTenses ? @$__chosenTenses : "undef" ) . ", ";
  $s .= "chosenTopics=" . @__chosenTopics . ", ";
  $s .= "canonizedTest=$__canonizedTest, ";
  $s .= "exerciseTargetCnt=$__exerciseTargetCnt, ";
  $s .= "reviewExerciseTargetCnt=$__reviewExerciseTargetCnt\n";
  return $s;
}

sub GenHtml_header
{
  my($query, $userID, $langs) = @_;

  print adyn_cgi_util::html_header(undef, undef, 1);  # , adyn_cgi_util::ListCgiParms(1), " -->  <title>Teacher</title>\n";
  print "<script src=/teacher/html/jquery-1.9.0.js></script>\n";
  print "<script src=/teacher/html/jquery-cookie-1.4.0/jquery.cookie.js></script>\n";
  print "<script src=/teacher/html/choose.js></script>\n";
  print "<script src=/teacher/html/cookie_field.js></script>\n";
  print "<script src=/teacher/html/cookie_field__defaults.js></script>\n";
  print "<script src=/teacher/html/u.js></script>\n";
  print "<script src=/teacher/html/julien-maurel-jQuery-Storage-API-e5a8a64/jquery.storageapi.js></script>\n";
  print "<script src=/teacher/html/test.js></script>\n"; 
  print "<script src=/teacher/html/stg.js></script>\n"; 
  print "<script src=/teacher/html/forms.js></script>\n";
  print "<script src=/teacher/html/win.js></script>\n";
  print "<script src=/teacher/html/new2.js></script>\n";
  print "</head>\n";
  my $host = $ENV{'HOST'};
  $host = "HOST_not_set_by_apache" unless defined $host;
  my $bgcolor = "#cccccc";
  if ($host =~ /^vagrant-/)
  {
    
    
    
    
    #print "<body><script language=\"JavaScript\">window.location.href='http://162.222.176.130:82/teacher/html/login.htm'</script></body></html>\n"; return;
    
    
    
    
    $bgcolor = "#aaaaaa";
  }
  elsif ($host eq "lt")
  {
    $bgcolor = "green";
  }
  print "<body bgcolor=$bgcolor><font face='arial'>\n";
  print "<div id=ex></div>\n";
  print "<script language=\"JavaScript\">\n";

  # cookieInitStr: This variable is needed to propagate settings for the cookie down in the
  # exercise.  The reason I can't just use the cookie as a global data area is
  # that I have not been able to update a universal cookie under Internet
  # Explorer; instead I get a separate cookie for each directory from which I
  # attempt and update.  This means that I end up with similar -- but not
  # necessarily identical -- cookies in the HTML and bin directories.  Thus I
  # need to take tiresome steps to propagate the appropriate settings.

  print "var adyn_url_offset='/teacher/html/'\n";
  print "userID = '" . $userID . "'\n";
  
  my $test_output_fn = adyn_cgi_util::param($query, "test_output_fn", "");
  my $special_op = adyn_cgi_util::param($query, "special_op", "");
  
  print "var test_output_fn = \"$test_output_fn\"\n";
  print "var special_op = \"$special_op\"\n";
  
  my $whichPanel = adyn_cgi_util::param($query, "whichPanel"); 
  print "var whichPanel='" . $whichPanel . "'\n";
  
  
  
  print "var cookieInitStr='";

  my @allLangs = ("French", "Spanish", "Italian", "German");
  my %selectedLanguages = ();
  foreach my $lang (@$langs)
  {
    print "teacherCookie.lang_${lang}_checked = \"true\";";
    $selectedLanguages{$lang} = 1;
  }
  foreach my $lang (@allLangs)
  {
    print "teacherCookie.lang_${lang}_checked = \"false\";" unless defined $selectedLanguages{$lang} && $selectedLanguages{$lang};
  }
  print "'\n";
  
  
  print "var selected_languages = new Array(";
  my $first = 1;
  foreach my $lang (@$langs)
  {
      print "," unless $first;
      print "\"${lang}\"";
      $first = 0;
  }
  print ")\n";
  print "stg_set_mutually_dependent_category_groups(new Array(selected_languages))\n";

  my $pageFromWhichNewQueriesWillBeInitiated = adyn_cgi_util::param($query, "pageFromWhichNewQueriesWillBeInitiated");
  if (defined  $pageFromWhichNewQueriesWillBeInitiated)
  {
    print "\nvar pageFromWhichNewQueriesWillBeInitiated = \"$pageFromWhichNewQueriesWillBeInitiated\";\n";
  }

  print GetTraceInfoInHTMLComments();
}

sub GenHtml_initFirstExercise
{
  my($userID, $chosenExerciseString) = @_;
  if (!$chosenExerciseString)
  {
    adyn_cgi_util::MailAdyn("choose.cgi: no exercises matched your criteria");
    print "</script><h3>Sorry, I could not find any exercises matching your criteria</h3>\n";
    print "\n";
    print "Click on the <b>Back</b> button to return to the form, where you should modify your request to be less restrictive.\n";
  }
  else
  {
    print "</script>\n"
    . "</font>\n";
  }
}

sub GenHtml
{
  my($userID, $query, $chosenExerciseArray) = @_;
  my $langs = GetLangs($query);
  GenHtml_header($query, $userID, $langs);

  my $cached_keys = adyn_cgi_util::param_as_hash($query, "cached_keys");


  for (my $j = 0; $j < scalar(@$chosenExerciseArray); $j++)
  {
    my $exId = $chosenExerciseArray->[$j];
    $exId =~ s{/(.*)}{};	# rm weight from rvw exercises
    my $weight = $1;
    if (!defined $weight)
    {
      $weight = 0;
    }
    my $jsExId = $exId;

    # shouldn't be needed -- I've standardized everywhere on underscores...    -ns 2-21-03
    $jsExId =~ s/\./_/;		# in the JavaScript world, I refer to verb_run.3 as verb_run_3.

    my $s = "se('$jsExId',$weight,";
    my $firstLangSeen = 0;

    my $outExId = "out_$exId";
    foreach my $lang (@$langs)
    {
      my $other = tdb::Get($outExId, $lang);
      next unless defined $other;

      if (!$firstLangSeen)
      {
	$firstLangSeen = 1;
      }
      else
      {
	$s .= ",";
      }
      $s .= "'$lang',";

      if ($cached_keys->{$exId})
      {
        $s .= "null,null";
      }
      else
      {
        $s .= adyn_cgi_util::CleanAndQuoteString($other);
        $s .= ",";
        
        my $footnotes = tdb::Get($outExId, "${lang}_footnotes");
        if (defined $footnotes)
        {
          $s .= adyn_cgi_util::CleanAndQuoteString($footnotes);
        }
        else
        {
          $s .= "''";
        }
      }
    } # foreach lang
                
    $s .= ")";
    if ($firstLangSeen)
    {
      print "$s\n";
    }
    else
    {
      Log("choose::GenHtml($userID): could not find any data for $outExId (looked at @$langs)");
      print "<!-- $s -->\n";
      $chosenExerciseArray->[$j] = "";
    }
  }

  my $chosenExerciseString = join(";", @$chosenExerciseArray);
  $chosenExerciseString =~ s/\./_/g;

  # clean up after empty exercise IDs, which don't need ;'s:
  $chosenExerciseString =~ s/;+/;/g;
  $chosenExerciseString =~ s/;$//;
  $chosenExerciseString =~ s/^;//;

  GenHtml_initFirstExercise($userID, $chosenExerciseString);
  
  return $chosenExerciseString;
}

# if I eliminate some exercises from a data file, this may cause references to exercises
# with higher IDs to become invalid.  Guard against this situation:
sub AdjustInvalidExerciseIds
{
  my($user, $chosenExerciseArray) = @_;
  if (!defined $user)
  {
    return;
  }

  my $saveUser = 0;
  for (my $j = 0; $j < scalar(@$chosenExerciseArray); $j++)
  {
    my $id = $chosenExerciseArray->[$j];
    if ($id =~ m{^(\w+)\.(\d+)(/(\d+))?})
    {
      my($dataFile, $idOffset, $weight) = ($1, $2, $4);

      my $maxId = tdb::GetSize("$dataFile") - 1;
      my $validDataFile = defined $maxId;

      if (!$validDataFile || ($idOffset > $maxId))
      {
	my $oldId = "$dataFile\.$idOffset";
	if (!$validDataFile)
	{
	  # this exercise is not valid.  Remove it from the list, replacing it with the last exercise in the list.
	  # Reset the loop control so that we don't skip the j'th exercise:
	  $chosenExerciseArray->[$j] = $chosenExerciseArray->[$#$chosenExerciseArray];
	  $#$chosenExerciseArray = $#$chosenExerciseArray - 1;
	  $j--;
	  next;
	}
	else
	{
	  my $newIdOffset = nutil::random(tdb::GetSize("$dataFile") - 1);
	  my $newId = "$dataFile\.$newIdOffset";

	  $weight = 0 unless defined $weight;
	  #print "pre: s/$oldId/$newId/\n";
	  #$user->HashDump("reviewExercisesHash");

	  $user->HashPut("reviewExercisesHash", $newId, $weight);
	  $chosenExerciseArray->[$j] =~ s/$id/$newId/;
	}
	$user->HashDelete("reviewExercisesHash", $oldId);
	$saveUser = 1;

	#print "post: s/$id/$newId/\n";
	#$user->HashDump("reviewExercisesHash");


      }
    }
  }
  $user->SaveToDisk() if $saveUser;
}


sub Main
{
  my $query;
  if (($#ARGV >= 0) && ($ARGV[0] eq "-test"))
  #if (-d "c:/")
  {
    $query = new CGI(\*STDIN);
  }
  else
  {
    $query = new CGI;
  }

  #Ndmp::Hh("query hash", %$query);

  print $query->header(
  -status=>'200 OK',
  -expires=>'-1d',
  -type=>'text/html');

  if (!adyn_cgi_util::VerifyLogin($query))
  {
    print("<br>choose.cgi exiting because no Login");
    return;
  }

  # the following would combine stderr into stdout to make err output visible
  # open(STDERR, ">&STDOUT");

  $__canonizedTest                      = adyn_cgi_util::param($query, "canonizedTest", 0);
  $__exerciseTargetCnt                  = adyn_cgi_util::param($query, "exerciseSetTargetSize", 15);
  $__exerciseType                       = adyn_cgi_util::param($query, "exerciseType", "verb_all");
  $__specific_exercise_IDs_for_testing  = adyn_cgi_util::param($query, "specific_exercise_IDs_for_testing");
  $__randomSeed                         = adyn_cgi_util::param($query, "randomSeed", 0);
  my $reviewPercentage                  = adyn_cgi_util::param($query, "reviewPercentage", 50);
  my $userID                            = adyn_cgi_util::param($query, "userID");

  my $chosenExerciseArray;
  my $user = (defined $userID ? new teacher_user($userID) : undef);
  $__reviewExerciseTargetCnt = int($reviewPercentage * $__exerciseTargetCnt / 100.0);
  if (defined $__specific_exercise_IDs_for_testing)
  {
    $chosenExerciseArray = [ $__specific_exercise_IDs_for_testing ];
  }
  else
  {
    $__randomSeed = $$ if !$__randomSeed;

    #print "<!-- ";
    #adyn_cgi_util::RememberParm("randomSeed", $__randomSeed);
    nutil::random_init($__randomSeed);
    
    if (defined $userID && adyn_cgi_util::param($query, "resetReviewExercises", 0))
    {
      unlink("../httpdocs/teacher/usr/$userID/data");
    }
        
    Log("choose::Main(): $userID => $user for $reviewPercentage % rvw");
    
    if (!defined $user)
    {
      $reviewPercentage = 0;
    }
    elsif ((defined $__exerciseType) && ($__exerciseType eq "reviewExercises"))
    {
      $reviewPercentage = 100;
    }
    Log("Hoping for $__reviewExerciseTargetCnt rvw exercises out of $__exerciseTargetCnt exercises...");
    
    $chosenExerciseArray = ChooseExercises($user, $query);
  } 
  
  Log("Got " . scalar(@$chosenExerciseArray) . " exercises...");
  AdjustInvalidExerciseIds($user, $chosenExerciseArray);
  Ndmp::Ah('post inv', @$chosenExerciseArray) if $__trace;
    
  if ($__canonizedTest)
  {
    my $x = join("\n", sort(@$chosenExerciseArray));
    print "$x\n";
  }
  else
  {
    my $chosenExerciseString = GenHtml($userID, $query, $chosenExerciseArray);
    Ndmp::Ah('post html', @$chosenExerciseArray) if $__trace;
  
    #my $subject = "choose.cgi exercises selected " . (defined $userID ? $userID : "unknown grammatical ref user");
    #my $contents = $chosenExerciseString;
    #
    #adyn_cgi_util::MailAdyn($subject, $contents);
  }
}
Main();
