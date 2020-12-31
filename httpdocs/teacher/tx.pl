use Ndmp;
use grammar;
use Argv_db;		
use teacher;
use adyn_cgi_util;
#use Devel::Trace;

# alphabetize
my $__currentPosition = undef;
my $__g = undef;	# pointer to grammar.pm or French_grammar.pm obj
my $__isNote;
my $__lastNoteKey = undef;
my $__line;
my $__newExercisesFile = undef;
my $__out = undef;
my $__outMostlyJS = 0;
my $__titleOrNote;
my %__headers = ();
my @__actionByLevel = ( "h1", "h2", "h3" );
my @__last = ();

# alphabetize

sub Init
{
  $| = 1;		# turn off buffering stdout

  Argv_db::Init("tx", 
  "-FindNoteless", 
  "-ConfirmReview", 
  "-MakeReview", 
  "-ProposeExercises", 
  "-MassageAndFootnote", 
  "-MassageAndFootnoteDebug", 
  "-ReadReview", 
  "-categories", 
  "-cutLinkToPath", 
  "-fillInLinks",
  "-fixups", 
  "-genAll", 
  "-genExercises", 
  "-genId", 
  "-genInfrastructure", 
  "-genPath", 
  "-grammar", 
  "-id", 
  "-lang", 
  "-linkToPath", 
  "-relinkAll", 
  "-reviewerHTML",
  "-SampleIdFixup", 
  "-verb_a", 
  "-verb_b",
  "-Verify_loadability",
  "-xlate", 
  "-xlateAsNeeded", 
  "-xlateCapitalizeGerman", 
  "-xlatePath");
   
  teacher::Init();
}

sub DeclareNoteTemplate
{
  my($key, $val) = @_;
  $val = $__g->Cook($val);
  $val =~ s/\n/ /g;
  $__g->Set("noteTemplate", $key, $val);
  return undef;
}


sub Cook
{
  my($s) = @_;
  $s =~ s/^([^<>\n]+)$/AddLinksWithinGrammar($1)/egm;
      
  $s = $__g->Cook($s);
    
  $s =~ s/\(\n/(/g;
  $s =~ s/\n\)/)/g;
  return $s;
}


sub Pout
{
  my($s) = @_;
  if (defined $__out)
  {
    $s = Cook($s);
    print $__out $s, "\n";
  }
}

sub TimeStamp
{
  my($label) = @_;
  my $x = `date '+%H.%M'`;
  chomp $x;
  print "TIME: $x: $label\n";
}


sub SampleCell
{
  my($id, $lang) = @_;
  Pout("<tr><td><center>");
  Pout(tdb::GetText($id, $lang));

  Pout("</center></td></tr>");
  return undef;
}

sub Sample
{
  my($id, $other) = @_;

  my $lang = $__g->{"lang"};
  if (!Argv_db::FlagSet("SampleIdFixup"))
  {
    tdb::Set($id, "z/sampleId", $id);	# record the ID for reconciliation later if IDs are shuffled
  }
  Pout("<p><center><table bgcolor=#eeeeee border=1 cellpadding=5 cellspacing=5 width=70%>");
  SampleCell($id, $__g->GetLang());
  SampleCell($id, "English");
  Pout("</table></center><p>");
  return undef;
}

sub OpenFileHandle
{
  my($fn, $outMostlyJS, $title) = @_;
  $fn = "html/$fn";
  %__headers = ();

  CloseFile() if defined $__out;

  #print "Opening $fn\n";
  die "bad fn $fn" unless $fn =~ /.html$/;
  $__out = new IO::File("> $fn");
  die "cannot open $fn" unless $__out;

  $__outMostlyJS = $outMostlyJS;
  print $__out adyn_cgi_util::html_header($title) . "\n";
  print $__out "<script src=vt.js></script>\n";
  print $__out "<script src=jquery-1.9.0.js></script>\n";
  print $__out "<script src=jquery-cookie-1.4.0/jquery.cookie.js></script>\n";
  print $__out "<script src=choose.js></script>\n";
  print $__out "<script src=cookie_field.js></script>\n";
  print $__out "<script src=cookie_field__defaults.js></script>\n";
  print $__out "<script src=u.js></script>\n";
  print $__out "<script src=new2.js></script>\n";
  print $__out "</head>\n";
  print $__out "<body bgcolor=#ccceee><font face='arial'>\n";
  print $__out "<script language=JavaScript>" if $outMostlyJS;
  print $__out "cookie_field__defaults()\n";

  die "can't open $fn.html" unless defined $__out;
}

sub OpenFile
{
  my($title, $fn) = @_;
  OpenFileHandle($fn, 0, $title);

  Pout("<!--Copyright 2007 Adynware Corp., all rights reserved-->");

  Pout(adyn_cgi_util::html_header($title));

  Pout("</head>");
  Pout("<body bgcolor=#cccccc><font face='arial'>");
  return $__out;
}

sub OpenVTFile
{
  my($verb_b, $fn) = @_;
  OpenFileHandle($fn, 1, "$verb_b conjugation");
}

sub CloseFile
{
  return unless defined $__out;

  #Pout("<script language=JavaScript>") if (!$__outMostlyJS);
  #Pout("vt_cleanup()</script>");
  
  Pout("</script><hr align=bottom><b><font color=white size=-1><center>&copy 2002 Adynware Corp.  &nbsp All Rights Reserved.</center></font></b></body></html>\n");

  $__out->close();
  $__out = undef;
}

sub ShowTable
{
  Pout($__g->Table(@_));
  return undef;
}

sub Verb
{
  my($stem_b, $inf_b, $pastParticiple_b, $stem_a, $s1_b, $s2_b, $s3_b, $p1_b, $p2_b, $p3_b) = @_;
  $p3_b = "filler" unless defined $p3_b;	# for German, so we don't uninit errors in EqVerb

  VerbWithOddEnglish($stem_b, $inf_b, $pastParticiple_b,
  $stem_a, '', '', '', '-s', '', '', '',
  $s1_b, $s2_b, $s3_b, $p1_b, $p2_b, $p3_b);
  return undef;
}


sub VerbWithOddEnglish
{
  my @args = @_;
  #Ndmp::Ah("VerbWithOddEnglish", \@args);

  my $verb_a = $args[3];
  warn "not set up for split english...: $verb_a$args[4]" if $args[4];

  $args[3] =~ s/2$//;
  
  my $verb_b = $args[0];
  $verb_b .= $args[1] if defined $args[1];
    
    
  my $reflexive_a = $__g->SetReflexivity_a(\@args);
  my $reflexive_b = $__g->SetReflexivity_b($verb_b, \@args);
      		 
  my $pastParticiple_b = $args[2];    			    			
  if (defined  $pastParticiple_b)
  {
    $__g->Override($__g->StripReflexivity($verb_b), "past participle", $pastParticiple_b);
  } 
      		
  #Ndmp::Ah("args: ", @args);
  $__g->SetVerbArgs($verb_b, $verb_a, [ @args ]);
  return undef;
}

sub GrammarAutoLink
{
  my($token, $dest) = @_;
  #print "tx::GrammarAutoLink($token, $dest)\n";
  if ($dest !~ /^=/)
  {
    $dest = "=" . $dest;
  }
  $__g->AutoLink($token, $__g->MakeGrammarURL($dest));
  return undef;
}

sub PoutVerbTablesTOC
{
  my $vt_toc = $__g->StartTable("normal");
  my $sortedVerbs = $__g->GetSortedVerbs();
  foreach my $verb_b (@$sortedVerbs)
  {
    my $verb_a = $__g->Get_verb_a($verb_b);
    if ($verb_a !~ /^updateVtlOnly$/
    &&  $verb_a !~ /[2 ]/
    &&  $verb_b !~ /[2 ]/)
    {
      $vt_toc .= "<tr><td>\n$verb_b\n</td><td>" . $__g->Get_verb_a_withToIfAppropriate($verb_b) . "</td></tr>";
    }
  }
  $vt_toc .= $__g->EndTable();

  Pout($vt_toc);
  return undef;
}

sub ShowVT
{
  my($verb_b, $tense, $doingVerbTable, $updateVtlOnly) = @_;

  $updateVtlOnly = 0 unless defined $updateVtlOnly;
  $doingVerbTable = 0 unless !$updateVtlOnly && defined $doingVerbTable;	# in dat.htm, no arg submitted

  #print "ShowVT($verb_b, $tense)\n";
  my $output = "";

  if (!$doingVerbTable || $tense eq "present")
  {
    $output .= $__g->Get_vt_init_call($verb_b, $doingVerbTable);
  }
  $output .= $__g->VTtoS($verb_b, $tense, $doingVerbTable);

  # rm tense markers (e.g., "[past tense]")
  $output =~ s/ \[.*?\]//g;

  if (!$__outMostlyJS)
  {
    $output = "<script language=JavaScript>$output</script>";
  }

  if (!$updateVtlOnly && $__out)
  {
    print $__out $output;
  }
  #print "ShowVT done.\n";
  return undef;
}

sub StartVerbPastParticipleTable
{
  Pout($__g->StartTable("narrow"));
  VerbPastParticiple(0, "<b>verb</b>", "<b>" . $__g->GetLang() . " past participle</b>", "<b>English</b>");
  return undef;
}

sub EndVerbPastParticipleTable
{
  Pout($__g->EndTable());
  return undef;
}

sub VerbPastParticiple
{
  my($hasSecondaryHelperVerb, $verb_b, $pastParticiple_b, $verb_a) = @_;

  die "unexpected undef" unless defined $hasSecondaryHelperVerb && defined $verb_b && defined $pastParticiple_b;
  
  $__g->Override($verb_b, "past participle", $pastParticiple_b); 
  $__g->Set__hasSecondaryHelperVerb($verb_b) if $hasSecondaryHelperVerb;
  
  #print "VerbPastParticiple($hasSecondaryHelperVerb, $verb_b, $pastParticiple_b, $verb_a)\n";
  if (!defined $verb_a)
  {
    $verb_a = $__g->GetVerb_a($verb_b);
    #print "VerbPastParticiple() looking for verb_a: " . nutil::ToString($verb_a) . "\n";
    return unless defined $verb_a;
  }
         		
  # Separate out those items which might contain embedded HTML accent abbreviations from the HTML tags.  This will allow Pout() to do the substitution.
  Pout("<tr><td>");
  Pout("$verb_b");
  Pout("</td><td>");
  Pout("$pastParticiple_b");
  Pout("</td><td>$verb_a</td></tr>");
  return undef;
} 

sub PastParticipleTable
{
  StartVerbPastParticipleTable();
  foreach my $verb_b ($__g->GetIrregularPastParticiples())
  {
    VerbPastParticiple(0, $verb_b, $__g->GetOverride($verb_b, "past participle"));
  }
  EndVerbPastParticipleTable();
}

sub StartVerbTable
{
  Pout($__g->StartTable("narrow"));
  VerbInTable(0, "<b>verb</b>", "<b>" . $__g->GetLang() . "</b>", "<b>English</b>");
  return undef;
}

sub EndVerbTable
{
  Pout($__g->EndTable());
  return undef;
}


sub VerbInTable
{
  my($hasSecondaryHelperVerb, $verb_b) = @_;
  die "unexpected undef" unless defined $hasSecondaryHelperVerb && defined $verb_b;
  
  my $verb_a = $__g->GetVerb_a($verb_b);
  return unless defined $verb_a;
  
  $__g->Set__hasSecondaryHelperVerb($verb_b) if $hasSecondaryHelperVerb;
  		
  # Separate out those items which might contain embedded HTML accent abbreviations from the HTML tags.  This will allow Pout() to do the substitution.
  Pout("<tr><td>");
  Pout("$verb_b");
  Pout("</td><td>$verb_a</td></tr>");
  return undef;
} 

sub MakeAnchor
{
  my($cp) = @_;
  $__currentPosition = $cp if defined $cp;
  Pout("<a name=\"$__currentPosition\"></a>");
  return undef;
}

sub Hack
{
  my($level) = @_;
    	
  $__isNote = 0;
    	
  return undef unless $__line =~ m{^=([^=\t]+)(.*)};
  my $component = $1;
  $__line = $2;
    		
  my $shouldAutoLink = 0;
    
  if ($component =~ /(.*?)(:+)(.*)/)
  {
    $component = $1;
    my $divider = $2;
    $__titleOrNote = $__g->MeToHtml($3);
        				
    $__isNote = 1 if $divider eq "::";
    if ($__isNote)
    {
      my $urlOffset = $__currentPosition;
      $__g->SaveNote($__currentPosition . "=$component", $__titleOrNote, $urlOffset, $__headers{$__currentPosition});
    }
    $shouldAutoLink = 1;
  }
  else
  {
    $__titleOrNote = $component;
  } 
  if (!defined $__currentPosition)
  {
    $__currentPosition = "=" . $component;
  }
  else
  {
    $__currentPosition .= "=" . $component;
  }
    		
  GrammarAutoLink($component, $__currentPosition) if ($shouldAutoLink);
  return $component;
}

sub ProcessLine
{
  ($__line) = @_;
  $__currentPosition = undef;
  die "bad line" unless defined $__line;
  return if $__line =~ /^#.*/;
    	
  for (my $level = 0;; $level++)
  {
    my $x = Hack($level);
    last unless defined $x;
        														
    if (($level > $#__last)
    ||  ($x ne $__last[$level]))
    {
      if ($level > $#__actionByLevel)
      {
	print "excessive level $level in $__line; ignoring...";
	next;
      }
            													
      my $action = $__actionByLevel[$level];
      my $tag;
      if ($__isNote)
      {
	$tag = undef;
      }
      else
      {
	$tag = $action;
	#print "Setting header{$__currentPosition} = $__titleOrNote\n";
	$__headers{$__currentPosition} = $__titleOrNote;
      } 
      MakeAnchor();
      Pout("<$tag>")		if defined $tag;
      Pout($__titleOrNote);
      Pout("</$tag>")		if defined $tag;
    }
    $__last[$level] = $x;
  }
    						
  #print "Looking at $__line\n";
    
    
  $__line =~ s/^((Adjective|AutoNote|Contraction|CookTense|City|DativeVerb|CgiLink|Endings|EndTable|EqVerb|ListItem|ListVerb|Mutable|MutableDer|MutableEin|Noun|Override|OverrideList|Prep|StartTable|Table|VowelChangingVerb)\(.*\))/\$__g->$1/;
    
  my $evalInput = undef;
  if ($__line =~ /^[::\w\$]+(->)?\w+\(.*\)\s*$/)
  {
    #print "evaluating: $__line\n";
    $evalInput = $__line;
    $__line = "\$__line = " . $__line;
    eval($__line);
    if ($@)
    {
      print "tx.pl eval failed on ($__line): $@\n";
    }
  }

  
  if (defined $__line)
  {
    Pout($__line);
    #Pout("<!--from $evalInput-->") if defined $evalInput;
  }
}

sub GenerateGrammar
{
  PrepLinksWithinGrammar();
  my $f = OpenInputFile();
  my $lang = $__g->GetLang();
  $__out = OpenFile("$lang Grammar", "$lang.html");
  
  print $__out adyn_cgi_util::html_header("$lang Grammar");
  
  while (ReadLine($f))
  {
    ProcessLine($__line);
  }
  CloseFile();
}

sub OpenInputFile
{
  my $fn = "grammar/" . $__g->GetLang() . ".dat.htm";
  my $f = new IO::File("< $fn");
  die "can't open $fn" unless defined $f;
  return $f;
}

sub ReadLine
{
  my($f) = @_;
  $__line = <$f>;
  if (!$__line)
  {
    return 0;
  }
  chomp $__line;
  $__line =~ s/\015//g;
  #print "__line=$__line\n";
  return 1;
}

sub PrepLinksWithinGrammar
{
  my $f = OpenInputFile();
  while (ReadLine($f))
  {
    my $completeAddress;
    if ($__line =~ /^(=[^:\t]+)/)
    {
      die $__line if $__line =~ /\015/;
      # e.g., '=French=Verbs=personal_pronouns=tu_versus_vous:,tu versus ,vous'
      # 	$completeAddress = '=French=Verbs=personal_pronouns=tu_versus_vous'
      $completeAddress = $__g->GetLang() . ".html#$1";
      $completeAddress =~ s/ /_/g;
    }
    else
    {
      next;
    }
    #print "tx::PrepLinksWithinGrammar(): HashPut(\"validGrammarURLs\", $completeAddress, 1) for " . $__g->{"lang"} . "\n";
    $__g->HashPut("validGrammarURLs", $completeAddress, 1);
  }
  $f->close();
}

sub AddLinksWithinGrammar
{
  my($s) = @_;
  #print "AddLinksWithinGrammar($s):";
  my $link = $__g->GetAutoLink($s);
  if ($link)
  {
    $s = $__g->CookTense($s);
    $s = "<a href='" . $link . "'>" . $__g->MeToHtml($s) . "</a>";
    #print "hit: $s\n";
  }
  else
  {
    #print "no\n";
  }
  return $s;
}

sub SaveNoteAndPrint
{
  my($key, $note, $link, $linkText) = @_;
  SaveNote($key, $note, $link, $linkText);
  Pout($note);
  return undef;
}

sub SaveNote
{
  my($key, $note, $link, $linkText) = @_;
  $__lastNoteKey = $key;
  $__g->SaveNote($key, $note, $link, $linkText);
  return undef;
}

sub MassageAndFootnote
{
  my($category) = @_;
  #print "tx::MassageAndFootnote($category) skipping\n"; return;
  $category = "all" unless defined $category;
  if ($category ne "all")
  {
    $__g = grammar::GetLangGrammar($category);
    $__g->MassageAndFootnote();
  }
  else
  {
    $__g = grammar::GetLangGrammar("French"); $__g->MassageAndFootnote();
    $__g = grammar::GetLangGrammar("German"); $__g->MassageAndFootnote();
    $__g = grammar::GetLangGrammar("Spanish"); $__g->MassageAndFootnote();
    $__g = grammar::GetLangGrammar("Italian"); $__g->MassageAndFootnote();
  }
}

sub ProposeExercises
{
  my($category) = @_;
  #print "tx::ProposeExercises($category)\n";
  $category = "all" unless defined $category;
  if ($category ne "all")
  {
    $__g = grammar::GetLangGrammar($category);
    $__g->ProposeExercises();
  }
  else
  {
    $__g = grammar::GetLangGrammar("French"); $__g->ProposeExercises();
    $__g = grammar::GetLangGrammar("German"); $__g->ProposeExercises();
    $__g = grammar::GetLangGrammar("Spanish"); $__g->ProposeExercises();
    $__g = grammar::GetLangGrammar("Italian"); $__g->ProposeExercises();
  }
}
   
sub Grammar
{
  my($lang) = @_;
  $__g = grammar::GetLangGrammar($lang, 1);
  my $usingCachedGrammarInfo = $__g->{"usingCachedGrammarInfo"};
  if (!$usingCachedGrammarInfo)
  {
    GenerateGrammar();
  } 
                    
  if (Argv_db::FlagSet("grammar"))
  {
    my $lang = $__g->GetLang();
    my $vtlFn = "data/_${lang}_vtl";
      
    PrintVerbTables($usingCachedGrammarInfo);
    tdb::Save();
  }
  $__g->OnEndOfGrammarGeneration();
}
 
sub PruneExercises
{
  my($self) = @_;
  foreach my $dataFile (generic_grammar::GetAllExerciseAreas())
  {
    next unless  $dataFile =~ /^verb_/;
    print "P";	# signal progress
    my $past_conditional_seen = 0;
    my $future_perfect_seen = 0;
    my $pluperfect_seen = 0;
    my $pronounCode = undef;
    my $max = tdb::GetSize($dataFile) - 1;
    for (my $idNumber = 0; $idNumber <= $max; $idNumber++)
    {
      my $id = "$dataFile.$idNumber";
      #print "$id\n";
      next unless defined tdb::Get($id, 'generated');
      #print "is gen\n";
      next if defined tdb::Get($id, 'z/sampleId');
      #print "not sam\n";

      my $tense = tdb::Get($id, 'tense');
      #print "tense: $tense\n";

      if ($tense eq "future_perfect")
      {
	if (!$future_perfect_seen)
	{
	  $future_perfect_seen = 1;
	  $pronounCode = $__g->GetPronoun($id);
	}
	else
	{
	  tdb::Set($id, "z/prune", $pronounCode);
	}
      }
      if ($tense eq "past_conditional")
      {
	if (!$past_conditional_seen)
	{
	  $past_conditional_seen = 1;
	  $pronounCode = $__g->GetPronoun($id);
	}
	else
	{
	  tdb::Set($id, "z/prune", $pronounCode);
	}
      }
      if ($tense eq "pluperfect")
      {
	if (!$pluperfect_seen)
	{
	  $pluperfect_seen = 1;
	  $pronounCode = $__g->GetPronoun($id);
	}
	else
	{
	  tdb::Set($id, "z/prune", $pronounCode);
	}
      }
    }
    tdb::Close1($dataFile);
  }
  print "\n";
  tdb::Save();
  exit(0); 
}
     
sub Main
{
  TimeStamp("start");
  Init();
  TimeStamp("post init");
  #Devel::Trace::trace('on');
  my $xlateFn = Argv_db::FlagArg("xlate");
  teacher::Translate($xlateFn)		if (defined $xlateFn);
  TimeStamp("post xlate");
  teacher::DoFixups()			if Argv_db::FlagSet("fixups");
  TimeStamp("fixups+");
  teacher::SampleIdFixup() 		if Argv_db::FlagSet("SampleIdFixup");
  
  if (Argv_db::FlagSet("cutLinkToPath"))
  {
    teacher::CutLinkData(Argv_db::FlagArg("genPath"), Argv_db::FlagArg("linkToPath"));
  }
  TimeStamp("pre link");
  if (Argv_db::FlagSet("linkToPath"))
  {
    # not sur eof this code -- just added it 4/1/14 to stop warning when an addend is first linked
    my $areaName = Argv_db::FlagArg("genPath");
    my $addendName = Argv_db::FlagArg("linkToPath");
    teacher::LinkData($areaName);
    tdb::Set("$areaName.0", "addendKey", "$addendName.0");
    tdb::Save();
    exit(0);
  }
  TimeStamp("post link");
  
  teacher::ConfirmReview()		if Argv_db::FlagSet("ConfirmReview");
  teacher::MakeReview()			if Argv_db::FlagSet("MakeReview");
  teacher::ReadReview()			if Argv_db::FlagSet("ReadReview");
  TimeStamp("post rvw");
  
  my $lang = Argv_db::FlagArg("lang");
          
  if (defined $lang)
  {
    if ($lang ne "all")
    {
      Grammar($lang);
    }
    else
    {
      Grammar('Spanish');
      TimeStamp("post es");
      Grammar('French');
      TimeStamp("post fr");
      Grammar('Italian');
      TimeStamp("post it");
      Grammar('German');
    }
    TimeStamp("post langs");
    MassageAndFootnote($lang);
    TimeStamp("post massage");
    tdb::Save();
    TimeStamp("post save");
  }
                  
  if (Argv_db::FlagSet("genPath") || Argv_db::FlagSet("genAll"))
  {
    teacher::GenHtmlDb();
    TimeStamp("post html gen");
  }
  tdb::Save();
  TimeStamp("post save");
  if (Argv_db::FlagSet("genInfrastructure") || Argv_db::FlagSet("genAll"))
  {
    teacher::GenInfrastructure();
  } 
  if (Argv_db::FlagSet("Verify_loadability") || Argv_db::FlagSet("genAll"))
  {
    teacher::Verify_loadability();
  } 
  TimeStamp("post infra");
  ProposeExercises() if (Argv_db::FlagSet("ProposeExercises"));
  TimeStamp("post propose");
  tdb::Cleanup();
  #print STDERR "tx::Main() end reached\n";
  TimeStamp("end");
  exit(0);
}
  
sub Print1VerbTableAndGenX
{
  my($verb_b, $verb_a) = @_;

  my $trace = $__g->{"Trace_XGen"} || $__g->{"Trace_Relink"};
  print "tx::Print1VerbTableAndGenX($verb_b, " . nutil::ToString($verb_a) . ")\n" if $trace;

  my $fn = $__g->GetVerbTableFn($verb_b);
  $verb_a = $__g->GetVerb_a($verb_b) if !defined $verb_a;

  # be sure to order the following test as follows, because
  # VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone calls LinkData as a
  # side effect if the linked data have been updated.
  my $eligibleForExerciseGeneration = (Argv_db::FlagSet("genExercises") && $__g->VerbUsedToGenerateExercises($verb_b));

  my $nothingToDo = ($__g->VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn) && $__g->{"usingCachedGrammarInfo"});

  $__g->MarkThisVerbAsHavingGeneratedExercises($verb_a) if ($eligibleForExerciseGeneration);

  if ($nothingToDo)
  {
    print "tx::Print1VerbTableAndGenX($verb_b, " . nutil::ToString($verb_a) . "): no update to cached data\n" if $trace;
    return;
  }
  if ($eligibleForExerciseGeneration)
  {
    $__g->ArrangeToCreateNewExercises($verb_b);
  }

  #print "Print1VerbTableAndGenX($verb_b)\n";
  print ".";

  my $updateVtlOnly = ($verb_a eq "updateVtlOnly");

  my $genXOnly;
  if (!defined $fn)
  {
    $genXOnly = 1;
  }
  elsif ($verb_b =~ /2$/)
  {
    $genXOnly = 1;
    $__g->{"verb_b_suffix"} = "2";
    $verb_b =~ s/2$//;
  }
  else
  {
    $genXOnly = 0;
    $__g->{"verb_b_suffix"} = "";
  }

  # Call VtlUpdateInit even if $genXOnly (i.e., we're not going to be
  # generating a verb table file); we need the vtl updates in order to
  # correctly footnote the generated exercises:
  $__g->VtlUpdateInit($verb_b);

  OpenVTFile($verb_b, $fn) unless $updateVtlOnly || $genXOnly;

  my $tensesRef = $__g->GetTenses();
  for (my $j = 0; $j < @$tensesRef; $j++)
  {
    my $tense = $tensesRef->[$j];

    my $updateVtlOnlyThisTense = $updateVtlOnly;
    $updateVtlOnlyThisTense = 1 if $__g->UpdateVtlOnly($tense);

    ShowVT($verb_b, $tense, !$genXOnly, $updateVtlOnlyThisTense);
  }
  #print "...Print1VerbTableAndGenX done\n";
  CloseFile();

  $__g->OnEndofPrint1VerbTableAndGenX($verb_a);
}


sub PrintVerbTables
{
  my($usingCachedGrammarInfo) = @_;

  my $lang = $__g->GetLang();
  if (!$usingCachedGrammarInfo)
  {
    OpenFile("$lang Verb Tables", "${lang}_vt_toc.html");
    PoutVerbTablesTOC();
  }

  my $test1 = 0;

  $__g->StartTracingVtl_ifThisHasBeenRequested();

  my $verb_a = Argv_db::FlagArgWithSpacesForUnderscores("verb_a");
  my $verb_b = Argv_db::FlagArgWithSpacesForUnderscores("verb_b");
  if ((!defined $verb_b) && (defined $verb_a))
  {
    $verb_b = $__g->Get_verb_b($verb_a);
    if (!defined $verb_b)
    {
      if ($verb_a !~ /^verb /)
      {
        print "tx::PrintVerbTables(): ignoring non-verb topic $verb_a\n";
      }
      else
      {
	die "no verb_b defined for $verb_a";
      }
    }
  }
  if ((!defined $verb_a) && (defined $verb_b))
  {
    $verb_a = $__g->Get_verb_a($verb_b);
    die "no verb_a defined for $verb_b" unless $verb_a;
  }

  if (defined $verb_a)
  {
    $test1 = 1;
    Print1VerbTableAndGenX($verb_b, $verb_a) if defined $verb_b;
  }
  else
  {
    if (!$usingCachedGrammarInfo)
    {
      tdb::Clear("_${lang}_vtl");
    }
    my $sortedVerbs = $__g->GetSortedVerbs();
    foreach my $verb_b (@$sortedVerbs)
    {
      #print "tx::PrintVerbTables(): $verb_b	" . $__g->GetPastParticiple($verb_b) . "\n";
      Print1VerbTableAndGenX($verb_b);
    }

    # now take care of sit where a single verb_b matches to multiple verb_a's:
    # This situation can be dealt with by processing the verbs starting with
    # the verb_a's which have not been processed:

    my $genExercisesHash = $__g->{"genExercisesHash"};
    my @unprocessed_verbs_a_whichShouldHaveGeneratedExercises = keys %$genExercisesHash;
    if (@unprocessed_verbs_a_whichShouldHaveGeneratedExercises)
    {
      foreach my $verb_a (@unprocessed_verbs_a_whichShouldHaveGeneratedExercises)
      {
	$verb_b = $__g->Get_verb_b($verb_a);
	Print1VerbTableAndGenX($verb_b, $verb_a) if defined $verb_b;
      }
    }
    print "\n";
  }
  CloseFile();

  $__g->ListExercisesWhichWereNotGeneratedButShouldHaveBeen() unless $test1;
}

Main();
