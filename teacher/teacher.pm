package teacher;
use diagnostics;
use IO::File;
use adynware::settings;
use Ndmp;
use Argv_db;
#use translate_via_web; # using goog.xlate now
use tdb;
use nutil;
use grammar;


# alphabetize
my $__g = undef;
my $__globalJS = "new2.js";
my $__initialSitNotHilit = 0;	# i.e., situation indexed by 0
my $__settings = Settings->new("teacher");
my $__state = undef;
my $__varNameSeed = 0;
my %__fonts = ();
my %__makeNoteCache;
my %__tokenUseHash = ();
my @__tenses = ("present", "preterite", "past", "imperfect", "future", "conditional", "past_conditional", "future_perfect", "pluperfect", "subjunctive", "imperative", "k1", "k2", "past_k2");
my $__web_root = "/cygdrive/c/Users/nelsons/Dropbox/adyn/httpdocs";

# loaded from settings:
# alphabetize
my $__linksExpanded = 0;
my $__promptCategory;
my %__links = (); # e.g., ich/German -> "[German/]pronouns[.html]"
my @__categories = ('English', 'French', 'German', 'Spanish', 'Italian'); # by convention, the first one is the prompt category

my $__j =<<'EOSj';
.
.  disabled for now
.
EOSj



my $__js =<<'EOSjs';
.
.  disabled for now
.
EOSjs

sub xck
{
  my($label) = @_;
  my $ofn = "/cygdrive/c/Users/nelsons/Dropbox/teacher/data/out_base";
  if (-f $ofn)
  {
    print "$label $ofn exists\n";
  }
  else
  {
    print "$label $ofn NO\n";
    die "gone now";
  }
}


sub AddNewlyTranslatedExercise
{
  my($dataFile, $idNumber, $exercise, $xlateCapitalizeGerman) = @_;
  if (!defined $xlateCapitalizeGerman)
  {
    my $english = $exercise->{"English"};
    my $englishCapitalized = 0;
    if (defined $english)
    {
      $englishCapitalized = ($english =~ /^[A-Z]/);
    }
    $xlateCapitalizeGerman = $englishCapitalized;
  }
  foreach my $key (keys %$exercise)
  {
    my $val = $exercise->{$key};
    if (!defined $val)
    {
      $val = "\@\@";
      print "No result for $dataFile.$idNumber: $key\n";
    }
    elsif ($key eq "English")
    {
      ;
    }
    elsif (($key eq "German") && $xlateCapitalizeGerman)
    {
      # was reduced case on the first item (which is probably an article)
      print "teacher::AddNewlyTranslatedExercise($dataFile, $idNumber, $exercise, $xlateCapitalizeGerman): $val\n";
      $val =~ s/^\s*(\S+)/\L$1/;
      print "to $val\n";

    }
    else
    {
      $val =~ s/(.*)/\L$1/;
      $val =~ s/\^d /^D /g;
    }
    tdb::Set("$dataFile.$idNumber", $key, $val, 1);
  }
}

sub Translate_via_web__DoVector
{
  my($promptCategory, $category, $input_list) = @_;
  die "unexpected $promptCategory" unless $promptCategory eq "English";
  my @inputs = @$input_list;
  my @outputs = ();
  for (my $j = 0; $j < scalar(@inputs); $j++)
  {
    my $input = $inputs[$j];
    my $output = `goog.xlate $category $input`;
    chomp $output;
    print "teacher.pm saw goog.xlate output $output...\n";
    $outputs[$j] = $output;
  }
  return \@outputs;
}

sub Translate
{
  my($fn) = @_;
  die "could not determine area of $fn" unless $fn =~ m{(.*)/[^/]+$};
  my $area = $1;

  my $f = new IO::File("< $fn");
  if (!$f)
  {
    die "Translate couldn't open $fn\n";
  }
  my %langToVectorOfText = ();
  my @inputLines = <$f>;
  foreach (@inputLines)
  {
    chop $_;
  }

  $langToVectorOfText{$__promptCategory} = \@inputLines;
  $f->close();

  foreach my $category (@__categories)
  {
    next if ($category eq $__promptCategory);
    #$langToVectorOfText{$category} = translate_via_web::DoVector($__promptCategory, $category, $langToVectorOfText{$__promptCategory});
    $langToVectorOfText{$category} = Translate_via_web__DoVector($__promptCategory, $category, $langToVectorOfText{$__promptCategory});

    my $x = $langToVectorOfText{$category};
    ##Ndmp::A("xlate to $category result", @$x);
  }

  Ndmp::H("langToVectorOfText", %langToVectorOfText);

  my $dataFile              = Argv_db::FlagArg("xlatePath");
  my $xlateCapitalizeGerman = Argv_db::FlagArg("xlateCapitalizeGerman");
  for (my $j = 0; $j <= $#inputLines; $j++)
  {
    my %exercise = ();
    foreach my $category (@__categories)
    {
      $exercise{$category} = $langToVectorOfText{$category}->[$j];
    }
    Ndmp::H("exercise", %exercise);
    AddNewlyTranslatedExercise($dataFile, $j, \%exercise, $xlateCapitalizeGerman);
  }
  tdb::Save();
  ##exit(0);
}

sub FindMatchingResponseTokenIndex
{
  my($promptTokenIndex, $promptMapRef) = @_;

  ##print "FindMatchingResponseTokenIndex($promptTokenIndex)\n";
  ##Ndmp::Ah("promptMapRef", @$promptMapRef);

  $promptTokenIndex--; # to make it zero-based
  my $responseTokenIndex = 0;
  for (my $j = 1; $j < scalar(@$promptMapRef); $j++)
  {
    $responseTokenIndex++ unless ($promptMapRef->[$j] < 0);
          				 
    if ($responseTokenIndex==$promptTokenIndex)
    {
      ##print "...returning ${j}th: $promptMapRef->[$j]\n";
      return $promptMapRef->[$j];
    } 
  }
  die "no match for tokens";
}
   
sub MakeTokenUseHashKey
{
  my($token, $category, $setPath) = @_;
  $token = grammar::NormalizeToken($token); 
  return $token . "/" . $category . "/" . $setPath;
}
   
sub TokenUsedInSet
{
  my($responseToken, $category, $link) = @_;
  if ($link !~ m{(.*)/index}) # links to sets always end w/ '/index'
  {
    return 0;	# link doesn't refer to a set
  }
  my $setPath = $1;
            				 
  BuildTokenUseHash() unless %__tokenUseHash;
  my $key = MakeTokenUseHashKey($responseToken, $category, $setPath);
  my $isUsed = (defined $__tokenUseHash{$key});
  print "TokenUsedInSet($key): $isUsed\n";
  return $isUsed;
}
   
sub PromptForSubjunctiveForSimpleExercises
{
  my($id) = @_;
  if ($id !~ /^base\./)
  {
    if (tdb::IsPropSet($id, "areas", "subjunctive"))
    {
      my $english = tdb::Get($id, "English");
      if ($english !~ /\[subjunctive\]/)
      {
	die "This shouldn't be needed -- the fixups have been run; how are new unprompted exercises being entered into the system?";
	$english =~ s/([\.!\?])$/ [subjunctive]$1/; # insert prompt just inside the punctuation
	tdb::Set($id, "English", $english, 1);
      }
    }
  }
}
   
sub Fixup_rmGeneratedNonTmpNotes
{
  my($id) = @_;
  if (defined tdb::Get($id, 'generated'))
  {
    my $ref = tdb::GetKeys($id);
    foreach my $key (@$ref)
    {
      if ($key =~ /_note#/)
      {
	my $val = tdb::Get($id, $key);
	if ($val =~ /FormOf/)
	{
	  tdb::Set($id, $key, undef);
	} 
      } 
    }
  }
}
    
sub Print_if
{
  my($id, $pronounRegexp, $tenseRegexp, $lang) = @_;
  $pronounVal = $self->GetPronoun($id);
  return 0 unless defined $pronounVal;
  return 0 unless $pronounVal =~ /$pronounRegexp/;

  $tenseVal = tdb::Get($id, 'tense');
  return 0 unless defined $tenseVal;
  return 0 unless $tenseVal eq $tenseRegexp;

  print "\n";
  tdb::ShowText($id, 'English');
  tdb::ShowText($id, $lang);
  return 1;
}

sub DoFixups
{
  #Xlate_fixup("verb_restore.0"); exit(0);

  foreach my $verbArea (generic_grammar::GetAllExerciseAreas())
  {
    my $imperfectSeen = 0;
    my $preteriteSeen = 0;
    my $max = tdb::GetSize("$verbArea") - 1;
    for (my $j = 0; $j <= $max; $j++)
    {
      my $id = "$verbArea.$j";
      tdb::Set($id, 'id', $id);
      die "sldfkj";
      warn "only resetting id's "; next;


      foreach my $category (@__categories)
      {
	my $s = tdb::Get($id, $category);
	if (!defined $s)
	{
	  print "tdb::Set(\"$id\", \"$category\", \"@@\");\n";
	  next;
		
		
	
	  die "No prompt category for $id" if $__promptCategory eq $category;
	  my $xlation;
	  	  	  	  
	  if (!defined $promptString)
	  {
	    $promptString = $rawPromptString;
	    	      	      	      
	    # stop parenthetical pronoun prompts
	    $promptString =~ s/ \([^\)]+\)//;
	    	      	          
	    # eliminate tense prompts
	    $promptString =~ s/ \[[^\]]+\]//;
	  } 
	  print "TranslateAsNeeded $id: $__promptCategory to $category: $promptString\n";
          die "unexpected $__promptCategory" unless $__promptCategory eq "English";
	  #$xlation = translate_via_web::DoString($__promptCategory, $category, $promptString);
          $xlation = `goog.xlate $category $promptString`;
          chomp $xlation;
	  $xlationDone = 1;
	  tdb::Set($id, $category, $xlation, 1);
	  tdb::Set($id, "$category/unreviewed", 1);
	  tdb::Set($id, "map/$category", undef); # should be a nop
	}
	#if (!defined (tdb::Get($id, "map/$category")))
	#{
	#AddNmwTodoItem("map/$category", $id);
	#}
      }						
      #Xlate_fixup($id);
    }
    tdb::Close1($verbArea);
  }
  tdb::Save();	# because often the bottom of the loop above is commented out
  exit(0);
}
   
sub LoadNmwSettings
{
  #my $inputFileFromEmacs = "$ENV{'NMW_TO_TEACHER_TMP'}";
  my $inputFileFromEmacs = "$ENV{'TMP'}";
  die "nmw_to_teacher_tmp not defined" unless defined  $inputFileFromEmacs;
        	 
  if (-f $inputFileFromEmacs)
  {
    my $s = filer::getContent($inputFileFromEmacs);
    $s =~ s/\x0D\x0A?/\n/g;
    #print "About to evaluate '$s'\n";
    eval($s);
    if ($@)
    {
      print "teacher.Init $inputFileFromEmacs load failed: $@\n";
    }
    else
    {
      print "teacher.Init $inputFileFromEmacs load succeeded: $@\n";
      system("mv -f $inputFileFromEmacs c:/old/nmw_to_teacher_tmp");
    } 
    tdb::Save();
  } 
}			
   
sub AddNmwTodoItem
{
  my($workType, $id) = @_;
  my $outputFileToEmacs = "$ENV{'TEACHER_TO_NMW_TMP'}";
  die "nmw_to_teacher_tmp not defined" unless defined  $outputFileToEmacs;
      	 
  my $f = new IO::File(">> $outputFileToEmacs");
  if (!$f)
  {
    die "AddNmwTodoItem couldn't open $outputFileToEmacs\n";
  }
  print $f "(n-database-list-push \"nmw/$workType\" \"$id\")\n";
  $f->close();
}
   
   
sub SampleIdFixup
{
  my($self) = @_;
  my %sampleIdTransform = ();
            
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    print "s,";	 # signal progress
    my $max = tdb::GetSize($dataFile) - 1;
    for (my $idNumber = 0; $idNumber <= $max; $idNumber++)
    {
      my $id = "$dataFile.$idNumber"; 
      tdb::Set($id, 'id', $id);
      my $idUsedForSample = tdb::Get($id, 'z/sampleId');
      next unless defined $idUsedForSample;
      if ($idUsedForSample ne $id)
      {
	$sampleIdTransform{$idUsedForSample} = $id; 
      } 
    } 
    tdb::Close1($dataFile);
  }
        
  print "tx::SampleIdFixup()\n";
  foreach my $category (@__categories)
  {
    print "tx::SampleIdFixup(): $category\n";
    
    my $fn = "grammar/$category.dat.htm";
    if (! -f $fn)
    {
      warn "$fn does not exist";
    }
    else
    {
      print "tx::SampleIdFixup() adjusting sample IDs in $fn...\n";
      
      my $s = filer::getContent($fn, 1);
      foreach my $idUsedForSample (keys %sampleIdTransform)
      {
	my $id = $sampleIdTransform{$idUsedForSample};
	$s  =~ s/Sample\('$idUsedForSample'\)/Sample\('$id'\)/g;
	print "s/Sample\('$idUsedForSample'\)/Sample\('$id'\)/g\n";
      }
      filer::setContent($fn, $s, 1);
    }
  }
  print "\n";
  tdb::Save();
  exit(0); 
}
     
sub Init
{
  print "teacher::Init()\n"; 
  eval($__settings->load());
  if ($@)
  {
    print "teacher.Init settings load failed: $@\n";
  } 
      
  my $categoryVal = Argv_db::FlagArg("categories");
  if (defined $categoryVal)
  {
    @__categories = split(/\//, $categoryVal);
    my $lastTopic = $__categories[$#__categories];
    if (-f "html/$lastTopic.js")
    {
      $__globalJS = $lastTopic . ".js";
    }
    else
    {
      #warn "Using $__globalJS because I did not see a html/$lastTopic.js";
    } 
  }
  LoadNmwSettings();
  $__promptCategory = $__categories[0];
      		 
  #Ndmp::Ah("tenses: ", @__tenses);
    
  $__fonts{"hiliteOn"} = "<font color=red>";
  $__fonts{"hiliteOff"} = "</font>";
  $__fonts{"linkBegin"} = "<font color=blue><u>";	# <u> is IE-only
  $__fonts{"linkEnd"} = "</u></font>"; 
  $__fonts{"hilitLinkBegin"} = "<font color=red><u>";	# <u> is IE-only
  $__fonts{"hilitLinkEnd"} = "</u></font>"; 
  print "leaving teacher::Init()\n";
}
   
sub MakeReview
{
  my $areaName = Argv_db::FlagArg("genPath");
  my @dataFiles;
  if (defined  $areaName)
  {
    $dataFiles[0] = $areaName;
  }
  else
  {
    @dataFiles = generic_grammar::GetAllExerciseAreas();
  }
  foreach my $dataFile (@dataFiles)
  {    
    my $max = tdb::GetSize("$dataFile") - 1;
    print "teacher::MakeReview($dataFile to $max)\n";
    for (my $idNumber = 0; $idNumber <= $max; $idNumber++)
    {
      my $id = "$dataFile.$idNumber"; 
      print "\n# ";
            
      tdb::ShowText($id, "English");
      tdb::ShowText($id, "French");
      tdb::ShowText($id, "German");
      tdb::ShowText($id, "Spanish");
      tdb::ShowText($id, "Italian");
    }
    tdb::Close1($dataFile);
  }
  exit(0);  
}
    
sub ReadReview
{
  my $fn = Argv_db::FlagArg("ReadReview");
  my $f = new IO::File("< $fn");
  die "ReadReview: could not open $fn" unless defined $f;
  print "ReadReview reading $fn...";
  while (<$f>)
  {
    die "unprocessed comment: $_" if /^;/;
    next if /^#/;

    if (/(\w+\.\d+) (\w+) (.*\S)/)
    {
      my($id, $lang, $s) = ($1, $2, $3);
      print "tdb::SetText($id, $lang, $s);\n";
      tdb::SetText($id, $lang, $s, 1);
    }
  }
  tdb::Save();
  exit(0);
}

# Given a file containing some corrections which have been applied to the data, this routine will go and fetch
# the corresponding data and print it out.  This facilitates a diff to reveal corrections which somehow
# have not made it into the data.
sub ConfirmReview
{
  my $fn = Argv_db::FlagArg("ConfirmReview");
  my $f = new IO::File("< $fn");
  die "ConfirmReview: could not open $fn" unless defined $f;
  print "ConfirmReview reading $fn...\n";
  while (<$f>)
  {
    my $line = $_;
    chop $line;
    # There are two formats for the data, with the second favored for working with addends.
    # The language is repeated to facilitate m--'ing straight to the data of interest:
    #
    # verb_sleep.0: German: Sie w:urden geschlafen haben.
    # how_to_sleep.1: German/verb_sleep.1: German: Du w:urdest geschlafen haben.
    #
    if ($line =~ m{^(\w+\.\d+): ([A-Z]\w+)/(\w+\.\d+): ([A-Z]\w+): (.*)})
    {
      my($addendId, $addendLang, $id, $lang, $s) = ($1, $2, $3, $4, $5);
      $s = tdb::GetText($id, $lang);
      print "$addendId: $addendLang/$id: $lang: $s\n";
    }
    else
    {
      die "teacher::ConfirmReview(): $line: other format not implemented";
    }
  }
  tdb::Save();
  exit(0);
}

sub GenHtmlDbForTopic
{
  my($areaName, $id1, $id2) = @_;
  if (!defined $id2)
  {
    $id2 = tdb::GetSize($areaName) - 1;
  }
  #print "\nGenHtmlDbForTopic($areaName, $id1, $id2)";

  my $maxId = tdb::GetSize($areaName) - 1;
  print "Generating HTML for $areaName, exercise $id1 to $id2...\n";
  my $htmlDbFn = "out_$areaName";

  #print "teacher::GenHtmlDbForTopic($areaName, $id1, $id2): vs. " . Argv_db::FlagArg("verb_a") . "\n";

  my $arg = Argv_db::FlagArg("verb_a");
  if (defined $arg)
  {
    $arg =~ s/[^_]*_//;	# verb_agree -> agree
  }
  else
  {
    $arg = "";
  }

  if ($arg eq $areaName
  || tdb::DataModifiedSinceFileWasGenerated($areaName, $htmlDbFn))
  {
    for (my $j = $id1; $j <= $id2; $j++)
    {
      GenHtmlDb_forOneExercise($areaName, $j, $htmlDbFn);
    }
  }
  tdb::Save();
  #tdb::PropagatePerlToSql_table("out_$areaName");
  #print "GenHtmlDbForTopic($areaName): done\n";
}


sub GetIdListsByTense
{
  my($dataFile) = @_;

  my %idListsByTense = ();

  my $max = tdb::GetSize("$dataFile") - 1;
  for (my $idNumber = 0; $idNumber <= $max; $idNumber++)
  {
    my $id = "$dataFile.$idNumber";
    if ($dataFile =~ /^vocab_/)
    {
      my $ref = $idListsByTense{"present"};
      $ref = [] unless defined $ref;
      push @$ref, $idNumber;
      $idListsByTense{"present"} = $ref;
    }
    else
    {
      foreach my $tense (@__tenses)
      {
	if (tdb::IsPropSet($id, "areas", $tense))
	{
	  my $ref = $idListsByTense{$tense};
	  $ref = [] unless defined $ref;
	  push @$ref, $idNumber;
	  $idListsByTense{$tense} = $ref;

	  # base* are the only ones which have exercises w/ multiple tenses:
	  last unless $dataFile =~ /^base/;
	}
      }
    }
  }
  return %idListsByTense;
}

sub Gen_choose_cgi_data
{
  print "teacher::Gen_choose_cgi_data()\n";
  tdb::PropagatePerlToSql_init(0);
  my @verbsToExGroupedByTenseKeys = ();
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    my %idListsByTense = GetIdListsByTense($dataFile);

    foreach my $tense (@__tenses)
    {
      my $ref = $idListsByTense{$tense};
      tdb::Set_arrayOfData("cgi_verbsToExGroupedByTense", "$dataFile/$tense", $ref);
    }
    push @verbsToExGroupedByTenseKeys, $dataFile;
    tdb::Close1($dataFile);
  }
  tdb::Set_arrayOfData("cgi_verbsToExGroupedByTense", "keys", \@verbsToExGroupedByTenseKeys);
  tdb::PropagatePerlToSql_table("cgi_verbsToExGroupedByTense");

  $__g = grammar::GetLangGrammar("French");
  my @vocabKeys = ();
  my @mostCommonVerbKeys = ();
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    if ($dataFile =~ /^vocab/)
    {
      push @vocabKeys, $dataFile;
    }
    else
    {
      my $verb_a = $__g->GetVerb_a_fromDataFile($dataFile);
      if (defined $verb_a && $__g->IsCommon($verb_a))
      {
	push @mostCommonVerbKeys, $dataFile;
      }
    }
  }

  tdb::Set_arrayOfData("cgi_vocab", "keys", \@vocabKeys);
  tdb::PropagatePerlToSql_table("cgi_vocab");
  tdb::Set_arrayOfData("cgi_mostCommonVerb", "keys", \@mostCommonVerbKeys);
  tdb::PropagatePerlToSql_table("cgi_mostCommonVerb");
  print "about to tdb::Save...\n";
  tdb::Save();
  print "done tdb::Save\n";
  tdb::PropagatePerlToSql_finish();
}

sub Gen_choose_html_UI_inserts
{
  my $gen_dir = $__web_root . "/teacher/html/gen";
  mkdir($gen_dir) unless -d $gen_dir;
  my $fn = $gen_dir . "/choose_html_populated_selects.js";
  my $f = new IO::File("> $fn");
  die "Gen_choose_html_UI_inserts could not create $fn" unless $f;
  print $f "function choose_html_populated_selects__chosenVerbs() { return \"<select multiple id=chosenVerbs name=chosenVerbs size=10 onChange='SelectingVerb()'>\"\n";
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    next if $dataFile =~ /^(base)$/;
    next if $dataFile =~ /^vocab/;

    print $f "+ \"<option value='$dataFile'>$dataFile\"\n";
  }
  print $f "+ \"</select>\"; }\n";
  
  
  
  print $f "function choose_html_populated_selects__chosenCategories() { return \"<select multiple id=chosenCategories name=chosenCategories size=10 onChange='SelectingVocab()'>\"\n";
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    next unless $dataFile =~ /^vocab/;
    
    print $f "+ \"<option value='$dataFile'>$dataFile\"\n";
  }

  print $f "+ \"</select>\"; }\n";  
  $f->close();
}

sub Verify_loadability
{
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    next if $dataFile =~ /^(base)$/;
        
    tdb::Get("$dataFile.0", "lsdkj"); # just force a load
    tdb::Close1($dataFile);
  }
}
   
sub InitMaxIdHash
{
  my($f) = @_;
  print $f "static\n{\n";
  foreach my $areaName (generic_grammar::GetAllExerciseAreas())
  {
    print $f "m_maxIds.put(\"$areaName\", new Integer(", tdb::GetSize($areaName), "));\n";
    tdb::Close1($areaName);
  }
  print $f "}\n";
}

sub GenInfrastructure
{
  print "teacher::GenInfrastructure()\n";
  Gen_choose_html_UI_inserts();
  Gen_choose_cgi_data();
}

sub GenHtmlDb
{
  my $genAll = Argv_db::FlagSet("genAll");

  tdb::PropagatePerlToSql_init($genAll);
  my $z = (defined $genAll ? $genAll : "undef");
  print "GenHtmlDb($z)...\n";

  if (defined $genAll)
  {
    foreach my $verbArea (generic_grammar::GetAllExerciseAreas())
    {
      GenHtmlDbForTopic($verbArea, 0, undef);
      tdb::Close1($verbArea);
    }
    print "\nteacher::GenHtmlDb(for all) done\n";
  }
  else
  {
    my $areaName = Argv_db::FlagArg("genPath");
    if (defined($areaName))
    {
      my $genId = Argv_db::FlagArg("genId");
      my $id1;
      my $id2;
      
      if (defined($genId))
      {
	$id1 = $genId;
	$id2 = $genId;
      }
      else
      {
	$id1 = 0;
	$id2 = undef;
      }
      GenHtmlDbForTopic($areaName, $id1, $id2);
      print "\nteacher::GenHtmlDb(for $areaName) done\n";
    }
  }
  tdb::PropagatePerlToSql_finish();
}

# break out nteacher vector into a set of bit vectors, one for each mouse pointer situation.
# Each vector indicates w/ 1s that the corresponding token should be highlighted (red);
# w/ 0 that it should not be highlighted.
# consumes 1-based data from nteacher; produces 1-based vectors.
sub GetPtrSituationToColorBitVectors
{
  my($maxPromptCategorySituation, $mapRef, $tokensRef) = @_;
  my @map = @$mapRef;
  my @ptrSituationToColorBitVectors;
    
  ##Ndmp::A("GetPtrSituationToColorBitVectors map", @map);

  # init to 0's
  for (my $situation = 1; $situation <= $maxPromptCategorySituation; $situation++)
  {
    $ptrSituationToColorBitVectors[$situation] = undef;
    for (my $tokenIndex = 1; $tokenIndex < scalar(@$tokensRef); $tokenIndex++)
    {
      #print "init to 0 ptrSituationToColorBitVectors($situation,$tokenIndex) = 0\n";
      $ptrSituationToColorBitVectors[$situation]->[$tokenIndex] = 0;
    }
  }
          					 
  # first map 1-to-1, n-to-1
  my $situation = 1;
  for (my $j = 0; $j < scalar(@map); $j++)
  {
    my $x = $map[$j];
    if (!defined $x)
    {
      Ndmp::A("map undefined at $j", @map);
      die "undefined elt";
    } 
          		 
    if ($x < 0)
    {
      next;
    }
    elsif ($x == 0)
    {
      $situation++;
    } 
    else
    {
      #print "1-to-1, n-to-1: map[$j]=$map[$j], ptrSituationToColorBitVectors[situation=$situation]->[x=$x]) = 1\n";##
      if ($situation > $maxPromptCategorySituation)
      {
	Ndmp::A("map w/ bad situation $situation (max is $maxPromptCategorySituation)", @map);
	#die "bad situation $situation";
      } 
      $ptrSituationToColorBitVectors[$situation]->[$x] = 1;
      $situation++;
    }
  }
      					 
  # now map 1-to-n
  my $chunkStartSituation;
  $situation = 1;
  for (my $j = 0; $j < scalar(@map); $j++)
  {
    my $x = $map[$j];
    if ($x == 0)
    {
      $chunkStartSituation = undef;
      $situation++; 
    } 
    elsif ($x > 0)
    {
      				 
      				 
      print "die" . "bad situation $situation" if $situation > $maxPromptCategorySituation;
      #die "bad situation $situation" if $situation > $maxPromptCategorySituation;
      				 
      				 
      				 
      $chunkStartSituation = $situation;
      $situation++; 
    }
    else
    {
      $x = - $x;
      ##print "1-to-n: ptrSituationToColorBitVectors($chunkStartSituation, $x) = 1;\n";##
      $ptrSituationToColorBitVectors[$chunkStartSituation]->[$x] = 1;
    }
  }
  return @ptrSituationToColorBitVectors;
}
   
sub GenVarName
{
  return "x" . $__varNameSeed++;
}
   
sub GetLinkTitle
{
  my($category, $token, $linkDest) = @_;
  if ($linkDest =~ m{ex:verb_(.*)})
  {
    my $verb = $1;
    return "exercises for the verb $verb";
  }
  $linkDest =~ s/_/ /g;
  if ($linkDest =~ m{ex:(.*)})
  {
    my $topic = $1;
    return "$topic exercises";
  }
  $linkDest =~ s/.*://g;
  return "explanation for the $linkDest";
}
   
sub ExpandLinks
{
  foreach my $key (keys %__links)
  {
    if ($key =~ m{v/(.*)/(.*)})
    {
      my $stem = $1;
      my $lang = $2;
      my $dest = $__links{$key};		
      							 
      if ($lang eq "English")
      {
	;
      } 
      elsif ($lang eq "French")
      {
	if ($stem =~ /y$/)
	{
	  $stem =~ s/y$/i/;
	  $__links{"v/$stem/$lang"} = $dest;
	}
	elsif ($stem =~ /et$/)  # acheter
	{
	  $stem =~ s/et$/&egrave;t/;
	  $__links{"v/$stem/$lang"} = $dest;
	}
	elsif ($stem =~ /ien$/)	# eg, venir
	{
	  $stem =~ s/ien$/ienn/;
	  $__links{"v/$stem/$lang"} = $dest;
	  $stem =~ s/ienn$/iend/;
	  $__links{"v/$stem/$lang"} = $dest;
	  $stem =~ s/iend$/en/;
	  $__links{"v/$stem/$lang"} = $dest;
	  $stem =~ s/en$/enir/;
	  $__links{"$stem/$lang"} = $dest;    # infinitive
	}
	elsif ($stem =~ /eux$/)	# eg, pouvoir
	{
	  $stem =~ s/eux$/eut/;
	  $__links{"$stem/$lang"} = $dest;
	  $stem =~ s/eut$/ouv/;
	  $__links{"v/$stem/$lang"} = $dest;
	  $__links{"${stem}oir/$lang"} = $dest;    # infinitive
	  	    					 
	  $stem =~ s/ouv$/oul/; # vouloir
	  $__links{"v/$stem/$lang"} = $dest;
	  $__links{"${stem}oir/$lang"} = $dest;    # infinitive
	  $stem =~ s/oul$/our/;
	  $__links{"v/$stem/$lang"} = $dest;
	  $stem =~ s/our$/oud/;
	  $__links{"v/$stem/$lang"} = $dest;
	}
      } 
    } 
  }
  $__linksExpanded = 1;
}
   
sub GetLinkViaRegexpMania_attempt
{
  my($token, $regexp, $suffix, $lang) = @_;
  return unless $token =~ /$regexp$/;
  my $match = $1;
  my $key = "v/$match$suffix/$lang";
  my $linkDest = $__links{$key};
  print "		GetLinkViaRegexpMania_attempt trying $key\n";
      		 
  if (defined $linkDest)
  {
    print "	GetLinkViaRegexpMania_attempt($token, $regexp, $suffix, $lang): $linkDest\n";
  }
  return $linkDest;
}
   
   
sub GetLinkViaRegexpMania
{
  my($token, $lang) = @_;
          			 
  my $linkDest = GetLinkViaRegexpMania_attempt("$token", "(.*)", "", $lang);
  return $linkDest if defined $linkDest;
          			 
  if ($lang eq "English")
  {
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)[pt](ing|ed|en)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(ing|d|e|ed|es|n)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(s)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)([td]en)", "e", $lang);
    return $linkDest if defined $linkDest;
  }
  elsif ($lang eq "French")
  {
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)ss(e|ons|ez|ent)", "", $lang);
    return $linkDest if defined $linkDest;				
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)s(e|ons|ez|ent)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(ons|ont|ez|ent|&eacute;e?)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)r(ai|as|a|ons|ez|ont|ais|ait|ions|iez|aient)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)v(ai|as|a|ons|ez|ont|ais|ait|ions|iez|aient)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(e|s|t)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)e(s|t)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)e(rai|ras|ra|rons|rez|ront)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)e(rais|rait|rions|riez|raient)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(ais|ait|ions|iez|aient|nent)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)e(rais|rait|rions|riez|raient)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)ss(ante?|r|t?re)", "", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*g)(aient|ent|i?ez|i?ons|&eacute;e?)", "e", $lang);
    return $linkDest if defined $linkDest;
                  						 
    $linkDest = GetLinkViaRegexpMania_attempt($token, "(.*)(ante?|r|t?re)", "", $lang);
    return $linkDest if defined $linkDest;
  }
  print "GetLinkViaRegexpMania($token, $lang): undef\n";
  return undef;
}
   
   
my %__categoryToNotes = ();
my %__noteSuperscripts = ();
   
sub ResetSuperscripts
{
  foreach my $category (@__categories)
  {
    $__noteSuperscripts{$category} = 1;
  } 
}
   
sub InitNotes
{
  foreach my $category (@__categories)
  {
    $__categoryToNotes{$category} = "";
  } 
  ResetSuperscripts();
}
   
sub PossiblyAssignSuperscriptToNote
{
  my($note, $category, $token) = @_;
                
  my $superscript = $__noteSuperscripts{$category};
  $__noteSuperscripts{$category}++;
                                				 
  $note = $__g->ResolveAndCookNotes($token, $note);
  if (!defined $note)
  {
    return "";
  }
  else
  {
    my $val = "<sup>" . $superscript . "</sup>";
    $__categoryToNotes{$category} .= "<br>$val$note";
    return $val;
  }
}
  
sub LookForNotes
{
  my($id, $category, $tokenIndex, $tokenKey) = @_;
  my $cacheKey = "$id, $category";
  $cacheKey .= $tokenIndex if (defined $tokenIndex);
  $cacheKey .= $tokenKey   if (defined $tokenKey);
  if (defined $__makeNoteCache{$cacheKey})
  {
    return $__makeNoteCache{$cacheKey};
  }

  # don't combine these two rounds into one because it would confuse
  # the note#tokenIndex logic:
  my $val = LookForNotes_noCache($id, $category, $tokenIndex, $tokenKey);
  my $lang = $__g->GetLang();
  if (!$val)
  {
    # The reason that I want the addendKey notes to be an alternative to the main entry notes instead of taking them in combination is that there was some confusion where redundant (or, in the case of German, incorrect) vocab_* footnotes were being added to the main entry's footnotes

    my $adfId = tdb::Get($id, "addendKey");
    if (defined $adfId)
    {
      $val .= LookForNotes_noCache($adfId, $category, undef, $tokenKey);
    }
  }
  $__makeNoteCache{$cacheKey} = $val;
  return $val;
}

sub LookForNotes_noCache
{
  my($id, $category, $tokenIndex, $tokenKey) = @_;

  my $tokenComponentOfNoteKey;
  if (!defined $tokenKey)
  {
    $tokenComponentOfNoteKey = "";
  }
  else
  {
    #print "LookForNotes_noCache using key \"$tokenKey\"\n";
    $tokenComponentOfNoteKey = "#" . $tokenKey;
    $tokenComponentOfNoteKey = $tokenKey;
  }
  my $keyByTokenIndex = undef;
  my $keyByToken      = $__g->MakeTokenNoteKey($tokenComponentOfNoteKey);
  my $keyByToken2     = undef;
  if (defined $tokenIndex)
  {
    $keyByTokenIndex  = $__g->MakeTokenNoteKey($tokenIndex);
  }

  if (defined $tokenKey)
  {
    $keyByToken2      = $__g->MakeTokenNoteKey($tokenComponentOfNoteKey, "2");
  }
  my $note;
  my $val = "";
  if (defined $keyByTokenIndex)
  {
    $note = tdb::Get($id, $keyByTokenIndex);
    if (defined $note)
    {
      $val .= PossiblyAssignSuperscriptToNote($note, $category, $tokenKey);
    }
  }

  if (defined $keyByToken)
  {
    $note = tdb::Get($id, $keyByToken, "addendKey");
    if (defined $note)
    {
      my $token = $tokenKey;
      $val .= PossiblyAssignSuperscriptToNote($note, $category, $token);
    }

    if (!defined $tokenIndex && !defined $tokenKey)
    {
      # look for global notes which applied to the entire sentence, not just one of the tokens:
      my $globalKeyByToken= ndb::MakeShadedKey("${category}_global_note", $category);
      $note = tdb::Get(grammar::GetGlobalIdForThisDataFile($id), $globalKeyByToken);
      if(defined $note)
      {
	$val .= PossiblyAssignSuperscriptToNote($note, $category, $tokenKey);
      }
    }

    $note = tdb::GetTransient($category, $id, $keyByToken);
    if (defined $note)
    {
      $val .= PossiblyAssignSuperscriptToNote($note, $category, $tokenKey);
    }
  }
  if (defined $keyByToken2)
  {
    $note = tdb::Get($id, $keyByToken2, "addendKey");
    if (defined $note)
    {
      $val .= PossiblyAssignSuperscriptToNote($note, $category, $tokenKey);
    }
  }
  return $val;
}

sub HotTokenString
{
  my($id, $category, $tokenIndex, $token) = @_;
  return "" unless defined $token;
          			 
  my($tokenKey, $trailingDeletion, $trailingQuoteOrHyphen, $htmlToken) = $__g->MakeIntoNoteKey($token);

  my $text = $htmlToken;
  
  if (!Argv_db::FlagSet("MassageAndFootnoteDebug")
  ||  ($category eq Argv_db::FlagArg("lang")))
  {
    $text .= LookForNotes($id, $category, $tokenIndex, $tokenKey);
  }
  
  $text .= $trailingQuoteOrHyphen if $trailingQuoteOrHyphen;
  
  if ($trailingDeletion)
  {
    ; # the ^D would have eaten this space, so just don't add either the space or the ^D
  }
  else
  {
    $text .= " ";
  } 
    
  return $text;
}
   
   
   
# unperl.java uses stupid StringTokenizer class, which can't smoothly handle embedded
# quotes, etc.    
sub HackStringForUnperlJava 
{
  my($text) = @_;
  #$text =~ s/,/*/g; 
  $text =~ s/'/^/g; # string handling, which looks at apostrophes, is the only problem
  $text =~ s/"/@/g; # stop confusing Ndmp's string compressor
  #$text =~ s/\[/=/g; 
  return $text;
}
   
sub BuildCategoryText
{
  my($id, $category, $tokensRef) = @_;

  %__makeNoteCache = ();

  my $text = "";

  ResetSuperscripts();
  for (my $tokenIndex = 1; $tokenIndex <= scalar(@$tokensRef); $tokenIndex++)
  {
    $text .= HotTokenString($id, $category, $tokenIndex, $tokensRef->[$tokenIndex]);
  }
  $text =~ s/ #$//;
  $text = AddNotesAndAdjustFonts($text, $id, $category);
  return $text;
}

sub LookForNotesWhichAreNotSpecificToAToken
{
  my($id, $category) = @_;
  my $s = LookForNotes($id, $category, undef, undef);
  return $s;
}

sub AddNotesAndAdjustFonts
{
  my($text, $id, $category) = @_;
  $text .= LookForNotesWhichAreNotSpecificToAToken($id, $category);
  $text =~ s;</sup> *<sup>;,;g;
  $text =~ s;\. *(<sup>\d+</sup>);$1.;g;	# Get superscripts inside of the period.
  $text =~ s/ *$//;
  return $text;
}


# get a vector
#	1. indexed by answer (i.e., foreign translation) token index
#	2. containing corresponding prompt (i.e., English) token index
sub GetAnswerTokenToSituationVector
{
  my($mapRef) = @_;
  my @tokenToSituationVector;
  my $promptChunkStart;
  my $answerChunkIndex;
  my $situation = 1;
  for (my $j = 0; $j < scalar(@$mapRef); $j++)
  {
    my $x = $mapRef->[$j];
    if ($x > 0)
    {
      $promptChunkStart = $situation;
      $answerChunkIndex = $x;
      $tokenToSituationVector[$x] = $situation;
      #print "tSGen: (x>0) tokenToSituationVector[$x] = $situation;\n";##
      $situation++;
    }
    elsif ($x==0)
    {
      $situation++;
      $promptChunkStart = undef;
    }
    elsif ($x < 0)
    {
      $x = - $x;
      $tokenToSituationVector[$x] = $promptChunkStart;
      #print "tSGen: (x<0) tokenToSituationVector[$x] = $promptChunkStart;\n";##
    }
  }
      	 
  return @tokenToSituationVector;
}
   
sub GenPromptMapIfNeeded
{
  my($id, $situationCnt) = @_;
  my $x = $id;
  my $promptMapRef = tdb::Get($x, "map/$__promptCategory");
  if (defined $promptMapRef && (@$promptMapRef != $situationCnt))
  {
    print "Regenerating prompt map (@$promptMapRef != $situationCnt)\n";
    tdb::Set($x, "map/$__promptCategory", undef);
    $promptMapRef = undef;
  }
  if (!defined $promptMapRef)
  {
    my @tokens = generic_grammar::GetTokens($id, $__promptCategory);	
    my @map;
    
    # smoke out unnecessary Sets for the mapping -- 'ssup?
    # die "" . scalar(@tokens) . " != " . $situationCnt if scalar(@tokens) != $situationCnt;
    
    for (my $j = 0; $j < $#tokens; $j++)
    {
      # switch to 1-based values (but not map indices!), a la nteacher
      $map[$j] = $j + 1;
    }
    #print "gpm: set $x for map;\n";##
    tdb::Set($x, "map/$__promptCategory", \@map);
  }
}
   
   
# Given $ppgRef, a ref to an array of prompt groups, and two sit indices,
# this proc merges the prompt groups indexed by the indices into one.
sub MergePromptGroups
{
  my($ppgRef, $sit1, $sit2) = @_;
  return if $ppgRef->[$sit2] == $ppgRef->[$sit1];	# already merged
      		 
  # PG = "prompt group"
  my $PG1 = $ppgRef->[$sit1];
  my $PG2 = $ppgRef->[$sit2];
  foreach my $memberOfPG2 (keys %$PG2)
  {
    $PG1->{ $memberOfPG2 } = 1;
          		 
    # here I am changing all references to sit2's hash to point at sit1's hash:
    $ppgRef->[$memberOfPG2 ] = $PG1;
  }
  #Ndmp::a(@$ppgRef);##
}
   
   
sub GatherPromptGroups
{
  my($ptrSituationToColorBitVectorsRef, $situationCnt) = @_;
      	 
  # allocate a separate hash (i.e., prompt group) for each situation
  # (i.e., prompt token), initially just containing itself:
  my @ppg = [];
  for (my $situation = 1; $situation <= $situationCnt; $situation++)
  {
    $ppg[$situation] = ();
    $ppg[$situation]->{$situation} = 1;
  }
       
  #Ndmp::h(%$ptrSituationToColorBitVectorsRef);##
      	 
  foreach my $category (@__categories)
  {
    next if ($category eq $__promptCategory);
          		 
    # init a lookup vector indexed by tokenIndex, containing pointers to the 
    # prompt groupings:
    my @situationHashesByTokenIndex = [];
    my $tmp = $ptrSituationToColorBitVectorsRef->{$category}->[1];
    my $tokenCnt = scalar(@$tmp);
    for (my $tokenIndex = 1; $tokenIndex <= $tokenCnt; $tokenIndex++)
    {
      $situationHashesByTokenIndex[$tokenIndex] = undef;
    }
          		 
          		 
          		 
    for (my $situation = 1; $situation <= $situationCnt; $situation++)
    {
      die unless defined $ptrSituationToColorBitVectorsRef->{$category}->[$situation];
      my $colorBitVectorRef = $ptrSituationToColorBitVectorsRef->{$category}->[$situation];
      die "undefined colorBitVectorRef for $category > sit=$situation" unless defined $colorBitVectorRef;
      for (my $tokenIndex = 1; $tokenIndex <= scalar(@$colorBitVectorRef); $tokenIndex++)
      {
	next unless $colorBitVectorRef->[$tokenIndex];
		  				 
	if (defined $situationHashesByTokenIndex[$tokenIndex])
	{
	  #print "calling MergePromptGroups($situation, $situationHashesByTokenIndex[$tokenIndex]);\n";##
	  MergePromptGroups(\@ppg, $situation, $situationHashesByTokenIndex[$tokenIndex]);
	}
	else
	{
	  $situationHashesByTokenIndex[$tokenIndex] = $situation;
	} 
      } 
    } 
  }
  #Ndmp::a(@ppg);##
  return \@ppg;
}
   
sub OrBitVectors
{
  my($v1, $v2) = @_;
  if (scalar(@$v1) != scalar(@$v2))
  {
    Ndmp::Ah("OrBitVectors bad v1", @$v1);
    Ndmp::Ah("OrBitVectors bad v2", @$v2);
    die "OrBitVectors: unequal lengths: " . scalar(@$v1) . "!=" . scalar(@$v2);
  } 
      		 
  my $changed = 0;
  for (my $j = 1; $j < scalar(@$v1); $j++)
  {
    if (($v1->[$j] != $v2->[$j]) && ($v1->[$j] || $v2->[$j]))
    {
      $changed = 1;
      $v1->[$j] = 1;
      $v2->[$j] = 1;
    } 
  }
  return $changed;
}
   
sub OrAnswerHighlightingGroups
{
  my($grouping, $ptrSituationToColorBitVectorsRef, $situationCnt) = @_;
  my @keys = keys %$grouping;
  return 0 if (scalar(@keys)==1);
      			 
  my $changed = 0;
  for (my $j1 = 0; $j1 < scalar(@keys); $j1++)
  {
    for (my $j2 = 0; $j2 < scalar(@keys); $j2++)
    {
      my $sit1 = $keys[$j1];
      my $sit2 = $keys[$j2];
      next unless $sit1 != $sit2;
      foreach my $category (@__categories)
      {
	#print "or'ing $category $sit1, $sit2\n";##
	$changed |= OrBitVectors($ptrSituationToColorBitVectorsRef->{$category}->[$sit1],
	$ptrSituationToColorBitVectorsRef->{$category}->[$sit2]);
      }
    }
  }
  return $changed;
}
   
   
# propagate highlight grouping dependencies across all of the topics (i.e., languages).
# 
# $ptrSituationToColorBitVectorsRef->{$category}->[$situation]->[$tokenIndex] = 0 or 1
   
sub PropagateGroupingsAcrossTheCategories
{
  my($ptrSituationToColorBitVectorsRef, $situationCnt) = @_;
  my $groupBoundaryChanged = 0;
  do
  {
    $groupBoundaryChanged = 0;
    my $groupingsRef = GatherPromptGroups($ptrSituationToColorBitVectorsRef, $situationCnt);
    #Ndmp::Hh("pre OrAnswerHighlightingGroups.ptrSituationToColorBitVectorsRef", %$ptrSituationToColorBitVectorsRef);##
          										 
    for (my $situation = 1; $situation < scalar(@$groupingsRef); $situation++)
    {
      my $grouping = $groupingsRef->[$situation];
      $groupBoundaryChanged |= OrAnswerHighlightingGroups($grouping, $ptrSituationToColorBitVectorsRef, $situationCnt);
      #Ndmp::H("post OrAnswerHighlightingGroups", %$ptrSituationToColorBitVectorsRef);##
    }
  }
  while ($groupBoundaryChanged);
}
   
sub goofyCompress # unused
{
  my($s) = @_;
  #print "teacher::goofyCompress($s)\n";
  $s =~ s/\+/++/g;	# double the +'s to signal they aren't part of the compression
  
  $s =~ s{French.html#=}{+0}g;
  $s =~ s{Spanish.html#=}{+1}g;
  $s =~ s{German.html#=}{+2}g;
  $s =~ s{Italian.html#=}{+3}g;
  $s =~ s{</a> tense form of the verb }{+4}g;
  $s =~ s{</i> together make up a <a target=}{+5}g;
  $s =~ s{>exercises which use <i>}{+6}g;
  $s =~ s{>complete conjugation of <i>}{+7}g;
  $s =~ s{%h=\('English'=>}{+8}g;
  $s =~ s{'German'=>}{+9}g;
  $s =~ s{'French'=>}{+a}g;
  $s =~ s{'Italian'=>}{+b}g;
  $s =~ s{'Spanish'=>}{+c}g;
  $s =~ s{<a target=}{+d}g;
  $s =~ s{</a>}{+e}g;
  $s =~ s{<font size=-1><br><sup>}{+f}g;
  $s =~ s{</sup>}{+g}g;
  $s =~ s{</font>}{+h}g;
  $s =~ s{ #\(formal,}{+i}g;
  $s =~ s{ #singular\) }{+j}g;
  $s =~ s{#would }{+k}g;
  $s =~ s{#have }{+l}g;
  $s =~ s{French_vt_}{+m}g;
  $s =~ s{Spanish_vt_}{+n}g;
  $s =~ s{German_vt_}{+o}g;
  $s =~ s{Italian_vt_}{+p}g;
  $s =~ s{<sup>1</sup>}{+q}g;
  $s =~ s{Verbs=}{+r}g;
  $s =~ s{present}{+s}g;
  $s =~ s{past}{+t}g;
  $s =~ s{imperfect}{+u}g;
  $s =~ s{future}{+v}g;
  $s =~ s{conditional}{+w}g;
  $s =~ s{past_conditional}{+x}g;
  $s =~ s{future_perfect}{+y}g;
  $s =~ s{pluperfect}{+z}g;
  $s =~ s{subjunctive}{+A}g;
  $s =~ s{imperative}{+B}g;
  $s =~ s{</i> \(cf. }{+C}g;
  $s =~ s{past_conditional}{+D}g;
  $s =~ s{future_perfect}{+E}g;
  $s =~ s{pluperfect}{+F}g;
  $s =~ s{\[undef,}{+G}g;
  
  #$s =~ s{.0.html href=verb_}{+H}g;
  #print "teacher::goofyCompress: $s\n";
  return $s;
}
   
sub MarshalHashForJava
{
  my($hashRef) = @_;
  foreach my $key (keys %$hashRef)
  {
    $hashRef->{$key} = HackStringForUnperlJava($hashRef->{$key});
  }
  return Ndmp::Hs('"', %$hashRef);
}

sub Print_initApplet_call # unused
{
  my($f, $maxId, $id, $categoryToTextRef, $ptrSituationToColorBitVectors, $tokenToSituationVectorsRef, $categoryToFootnoteTextsRef) = @_;

  my($area, $idNumber) = tdb::GetAreaAndIdNumber($id);

  print $f "eval(document.teacher.iA(\"" . $area . "\"," . $maxId . "," . $idNumber . ",";

  my $s;

  #Ndmp::Hh("teacher::Print_initApplet_call: categoryToTextRef", %$categoryToTextRef);
  my $categoryToTextRefS = MarshalHashForJava($categoryToTextRef);
  $s = "$categoryToTextRefS,";
  #Ndmp::Hh("teacher::Print_initApplet_call: ptrSituationToColorBitVectors", %$ptrSituationToColorBitVectors);
  my $ptrSituationToColorBitVectorsS = MarshalHashForJava($ptrSituationToColorBitVectors);
  $s .= "$ptrSituationToColorBitVectorsS,";
  #Ndmp::H("teacher::Print_initApplet_call: tokenToSituationVectorsRef", %$tokenToSituationVectorsRef);
  my $tokenToSituationVectorsRefS = MarshalHashForJava($tokenToSituationVectorsRef);
  $s .= "$tokenToSituationVectorsRefS,";
  #Ndmp::Hh("teacher::Print_initApplet_call: categoryToFootnoteTextsRef", %$categoryToFootnoteTextsRef);
  my $categoryToFootnoteTextsRefS = MarshalHashForJava($categoryToFootnoteTextsRef);
  $s .= "$categoryToFootnoteTextsRefS,";
  $s .= "window.name))\n";

  #$s = goofyCompress($s);

  print $f $s;
  #print "teacher::Print_initApplet_call($id, $categoryToTextRefS, $ptrSituationToColorBitVectorsS, $tokenToSituationVectorsRefS, $categoryToFootnoteTextsRefS)\n";
}

sub GenHtmlDb_forOneExercise
{
  my($areaName, $x, $htmlDbFn) = @_;
  my $id = "$areaName.$x";
  #print "teacher::GenHtmlDb_forOneExercise($areaName, $id)\n";
  print ",";

  foreach my $category (@__categories)
  {
    $__g = grammar::GetLangGrammar($category);
    $__g->SetCurrentId($id);
  }

  InitNotes();
  foreach my $category (@__categories)
  {
    $__g = grammar::GetLangGrammar($category);
    my @tokens = generic_grammar::GetTokens($id, $category);
    my $text = BuildCategoryText($id, $category, \@tokens);
    tdb::Set("out_$id", $category, $text);

    my $notes = $__categoryToNotes{$category};
    if (defined $notes && ($notes ne ""))
    {
      tdb::Set("out_$id", "${category}_footnotes", $notes);
    }
  }
  %__categoryToNotes = ();
}

sub Inc
{
  my($n, $arrayRef) = @_;

  my $max = @$arrayRef;
  #print "Inc: max is  $max\n";

  if ($max==0)
  {
    return undef;
  }

  $n++;
  return ($n >= $max) ? 0 : $n;
}


sub Xlate_fixup_common
{
  my($other, $id, $category) = @_;

  $other = grammar::Capitalize($other);
  #
  # add period if no punctuation at end:
  if ($other !~ /[!\?\.]$/)
  {
    $other .= ".";
  }

  # stop unnecessary spaces, a specialty of my mother:
  $other =~ s/  +/ /g;	# no double spaces
  $other =~ s/ +$//;	# no spaces at eoln
  $other =~ s/\. \.$//;	# Mommy, what is this bs?
  $other =~ s/ ,/,/;	# yeesh...

  if ($category ne "English")
  {
    # stop parenthetical pronoun prompts
    $other =~ s/ \([^\)]+\)//;
    
    # eliminate tense prompts
    $other =~ s/ \[[^\]]+\]//;
  } 
  return $other;
}
  
sub Xlate_fixup
{
  my($id) = @_;
  my $English1 = tdb::Get($id, "English");
  my $German1  = tdb::Get($id, "German");
  my $Spanish1 = tdb::Get($id, "Spanish");
  my $Italian1 = tdb::Get($id, "Italian");
  my $French1  = tdb::Get($id, "French");
  #print "Xlate_fixup($id: $Spanish1)\n";
                  				 
  my $English = Xlate_fixup_common($English1, $id, "English");
  my $German  = Xlate_fixup_common($German1, $id, "German");
  my $Spanish = Xlate_fixup_common($Spanish1, $id, "Spanish");
  my $Italian = Xlate_fixup_common($Italian1, $id, "Italian");
  my $French  = Xlate_fixup_common($French1, $id, "French");
                				 
  if ($German =~ /[A-Z][A-Z]/)  # e.g., "Wir haben GEMACHT." -- a quirk of ets.freetranslation.com
  {
    $German =~ s/\b([A-Z][A-Z]+)/\L$1/g;
  }
        
  if (($French =~ /\bon\b/i) && ($English =~ /\bone\b/i))
  {
    if (($German =~ /\bein\b/i) && ($German !~ /\bman\b/i))
    {
      print "Xlate_fixup: ein to man...\n	$German\n";
      $German =~ s/\beine?\b/man/;
      $German =~ s/\bEine?\b/Man/;
    } 
    if (($Spanish =~ /\buno\b/i) && ($Spanish !~ /\btodo el mundo\b/i))
    {
      print "Xlate_fixup: uno to todo el mundo...\n	$Spanish\n";
      $Spanish =~ s/\buno\b/todo el mundo/;
      $Spanish =~ s/\bUno\b/Todo el mundo/;
    } 
    if (($Italian =~ /\bun\b/i) && ($Italian !~ /\bognuno\b/i))
    {
      print "Xlate_fixup: un to ognuno...\n	$Italian\n";
      $Italian =~ s/\bun\b/ognuno/;
      $Italian =~ s/\bUn\b/Ognuno/;
    } 
  }	
  tdb::Set($id, "English", $English, 1);
  tdb::Set($id, "German",  $German,  1);
  tdb::Set($id, "Spanish", $Spanish, 1);
  tdb::Set($id, "Italian", $Italian, 1);
  tdb::Set($id, "French",  $French,  1);
} 
   
sub CutLinkData
{
  my($dataFile, $addDataFile) = @_;
  my $maxDataFile = tdb::GetSize("$dataFile") - 1;
  my $maxAddDataFile = tdb::GetSize("$addDataFile") - 1;
  for (my ($adf, $df) = (0, 0); $df <= $maxDataFile; $adf++, $df++)
  {
    $adf = 0 if ($adf > $maxAddDataFile);	# cycle
                    
    my $dfId = "$dataFile.$df";
    my $adfId = "$addDataFile.$adf";
                        
    tdb::Set($dfId, "addendKey", undef, 1);
    foreach my $category (@__categories)
    {
      my $latestAddend = tdb::Get($dfId,   "$category/addend");
      my $oldAddend    = tdb::Get($dfId, "z/$category/addend");
      if (!defined $latestAddend)
      {
	tdb::Set($dfId, "$category/addend",  $oldAddend, 1);
      }
      tdb::Set($dfId, "z/$category/addend",  undef, 1);
    }
  }
  tdb::Save();
  exit(0);
}

# invoked from cmd line thusly: perl -w tx.pl -genPath verb_speak -linkToPath vocab_languages
# BUT THAT SHOULDN'T EVER BE NECESSARY since normally xlate.sh will make this call itself
sub LinkData
{
  my($dataFile) = @_;
  print "teacher::LinkData($dataFile)\n";
    
  my $noclobber = tdb::Get("$dataFile.0", "addend/noclobber");
  $noclobber = 0 unless defined $noclobber;
  if ($noclobber)
  {
    LinkData_WithoutAddingNewAddendKeys($dataFile);
  }
  else
  {
    LinkData_AddingNewAddendKeysToTheAddendlessGenerated($dataFile);
  }
}

sub LinkData_WithoutAddingNewAddendKeys
{
  my($dataFile) = @_;
        
  my $maxDataFile = tdb::GetSize("$dataFile") - 1;
  for (my $df = 0; $df <= $maxDataFile; $df++)
  {
    my $dfId = "$dataFile.$df";
    
    next unless defined tdb::Get($dfId, "generated");
    
    my $actualAdfId = tdb::Get($dfId, "addendKey");
    next unless defined $actualAdfId;
    foreach my $category (@__categories)
    {
      my $newAddend = tdb::Get($actualAdfId, $category);
      if (defined  $newAddend)
      {
	tdb::Set($dfId, "z/$category/addend", $newAddend, 1);
      } 
      else
      {
	warn "$actualAdfId: undef for $category";
      }
    }
  }
}


sub LinkData_AddingNewAddendKeysToTheAddendlessGenerated
{
  my($dataFile) = @_;
  my $firstAddendKey = tdb::Get("$dataFile.0", "addendKey");
  if (!defined $firstAddendKey)
  {
    warn "teacher::LinkData_AddingNewAddendKeysToTheAddendlessGenerated($dataFile): Get($dataFile.0, addendKey was undef";
    return;
  }
  die $firstAddendKey unless $firstAddendKey =~ /(.*)\.\d+$/ || $firstAddendKey =~ /(.*)\.place_holder$/;
  my $addDataFile = $1;
          
  my $maxDataFile = tdb::GetSize("$dataFile") - 1;
  my $maxAddDataFile = tdb::GetSize("$addDataFile") - 1;
  for (my ($adf, $df) = (0, 0); $df <= $maxDataFile; $adf++, $df++)
  {
    my $dfId = "$dataFile.$df";
    next unless defined tdb::Get($dfId, "generated");
    
    $adf = 0 if ($adf > $maxAddDataFile);	# cycle
                    
    my $adfId = tdb::Get($dfId, "addendKey");
    if (!defined $adfId)
    {
      $adfId = "$addDataFile.$adf"; 
      tdb::Set($dfId, "addendKey", $adfId, 1);
    }
    foreach my $category (@__categories)
    {
      my $newAddend = tdb::Get($adfId, $category);
      my $oldAddend = tdb::Get($dfId, "z/$category/addend");
            
      tdb::Set($dfId, "z/$category/addend", $newAddend, 1);
    }
  }
}

1;
