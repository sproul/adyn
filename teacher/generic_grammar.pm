package generic_grammar;


my $__Trace_ConformingToCharacteristics = 0;
my $__Trace_MassageAndFootnote = 0;
my $__Trace_Relink = 0;
my $__Trace_VerbCharacteristicPropagation = 0;
my $__Trace_Vtl_requested = 0;
my $__Trace_XGen = 0;

use strict;
use diagnostics;
use Ndmp;
use exercise_generator;
use Argv_db;
use DirHandle;
use arrayOfArrays;
use teacher_DumpedPerl;
use teacher;
use o_token;
use js;
use Cwd; 
use vars '@ISA';
require nobj;
@ISA = qw(nobj);

# This is needed because if the addend is out of date, this will be detected
# by the file date compare logic for the first language whose exercises are
# being generated.  When this language is complete, however, the tdb::Save will
# reset the data file times and prevent the file date compare logic from working
# correctly.  Therefore this data structure will record addends which are out of date.
my %__outOfDateAddend = ();

# I declare this in a separate section because I want to always have a
# disabled during the ShowVT calls which are made from GenerateGrammar.
# Once we are past that stage, I reset this variable using the contents of
# $__Trace_Vtl_requested.
my $__Trace_Vtl = 0;

# alphabetize
my $__ExtractCharacteristicsThruPhraseAnalysis_indirect_recursion_stopping_counter;
my $__MassageAndFootnoteCalled = 0;
my $__currentToken;	# token which is currently being processed
my $__exerciseGenerator;
my $__idOfExBeingGenerated = undef;
my $__mostRecentVerbNoted = undef;
my $__proposeNotesTokensCurrent;
my $__thisTokenIsPermanentlyIdentified = undef;
my $__verbHits = undef;
my %__invisibleVerbs = ();
my %__notesByToken = ();
my %__notesByVerb = ();
my %__pastEnglish = ();
my %__pastParticipleEnglish = ();
my @__proposeNotesNormalizedTokens;
my @__proposeNotesTokens;

# alphabetize
$__pastEnglish{"@@"} = "@@";
$__pastEnglish{"@@"} = "@@";
$__pastEnglish{"@@"} = "@@";
$__pastEnglish{"be able to"} = "could [past tense]";
$__pastEnglish{"beat"} = "beat";
$__pastEnglish{"become"} = "became";
$__pastEnglish{"begin"} = "began";
$__pastEnglish{"bite"} = "bit";
$__pastEnglish{"blow"} = "blew";
$__pastEnglish{"break"} = "broke";
$__pastEnglish{"build"} = "built";
$__pastEnglish{"can"} = "could [past tense]";
$__pastEnglish{"choose"} = "chose";
$__pastEnglish{"come"} = "came";
$__pastEnglish{"cut"} = "cut";
$__pastEnglish{"do"} = "did";
$__pastEnglish{"drink"} = "drank";
$__pastEnglish{"drive"} = "drove";
$__pastEnglish{"eat"} = "ate";
$__pastEnglish{"fall"} = "fell";
$__pastEnglish{"feel"} = "felt";
$__pastEnglish{"fly"} = "flew";
$__pastEnglish{"forbid"} = "forbade";
$__pastEnglish{"forget"} = "forgot";
$__pastEnglish{"freeze"} = "froze";
$__pastEnglish{"get"} = "got";
$__pastEnglish{"give"} = "gave";
$__pastEnglish{"go"} = "gone";
$__pastEnglish{"go"} = "went";
$__pastEnglish{"grow"} = "grew";
$__pastEnglish{"hear"} = "heard";
$__pastEnglish{"hide"} = "hid";
$__pastEnglish{"know"} = "knew";
$__pastEnglish{"left"} = "left [past tense]";
$__pastEnglish{"put"} = "put";
$__pastEnglish{"ride"} = "rode";
$__pastEnglish{"rise"} = "rose";
$__pastEnglish{"run"} = "ran";
$__pastEnglish{"say"} = "said";
$__pastEnglish{"see"} = "saw";
$__pastEnglish{"sing"} = "sang";
$__pastEnglish{"sink"} = "sank";
$__pastEnglish{"speak"} = "spoke";
$__pastEnglish{"steal"} = "stole";
$__pastEnglish{"stink"} = "stank";
$__pastEnglish{"stride"} = "strode";
$__pastEnglish{"swear"} = "swore";
$__pastEnglish{"swim"} = "swam";
$__pastEnglish{"take"} = "took";
$__pastEnglish{"tell"} = "told";
$__pastEnglish{"think"} = "thought";
$__pastEnglish{"throw"} = "threw";
$__pastEnglish{"wake"} = "woke";
$__pastEnglish{"write"} = "wrote";
$__pastParticipleEnglish{"@@"} = "@@";
$__pastParticipleEnglish{"@@"} = "@@";
$__pastParticipleEnglish{"@@"} = "@@";
$__pastParticipleEnglish{"@@"} = "@@";
$__pastParticipleEnglish{"be"} = "been";
$__pastParticipleEnglish{"beat"} = "beaten";
$__pastParticipleEnglish{"begin"} = "begun";
$__pastParticipleEnglish{"bend"} = "bent";
$__pastParticipleEnglish{"bind"} = "bound";
$__pastParticipleEnglish{"bite"} = "bitten";
$__pastParticipleEnglish{"blow"} = "blown";
$__pastParticipleEnglish{"break"} = "broken";
$__pastParticipleEnglish{"bring"} = "brought";
$__pastParticipleEnglish{"burst"} = "burst [past tense]";
$__pastParticipleEnglish{"buy"} = "bought";
$__pastParticipleEnglish{"catch"} = "caught";
$__pastParticipleEnglish{"choose"} = "chosen";
$__pastParticipleEnglish{"cost"} = "cost [past tense]";
$__pastParticipleEnglish{"creep"} = "crept";
$__pastParticipleEnglish{"cut"} = "cut [past tense]";
$__pastParticipleEnglish{"dig"} = "dug";
$__pastParticipleEnglish{"do"} = "done";
$__pastParticipleEnglish{"drink"} = "drunk";
$__pastParticipleEnglish{"drive"} = "driven";
$__pastParticipleEnglish{"eat"} = "eaten";
$__pastParticipleEnglish{"fall"} = "fallen";
$__pastParticipleEnglish{"feel"} = "felt";
$__pastParticipleEnglish{"fight"} = "fought";
$__pastParticipleEnglish{"find"} = "found";
$__pastParticipleEnglish{"flee"} = "fled";
$__pastParticipleEnglish{"fly"} = "flown";
$__pastParticipleEnglish{"forbid"} = "forbidden";
$__pastParticipleEnglish{"freeze"} = "frozen";
$__pastParticipleEnglish{"give"} = "given";
$__pastParticipleEnglish{"go"} = "gone";
$__pastParticipleEnglish{"grind"} = "ground";
$__pastParticipleEnglish{"grow"} = "grown";
$__pastParticipleEnglish{"hang"} = "hung";
$__pastParticipleEnglish{"have"} = "had";
$__pastParticipleEnglish{"hear"} = "heard";
$__pastParticipleEnglish{"hide"} = "hidden";
$__pastParticipleEnglish{"hurt"} = "hurt [past tense]";
$__pastParticipleEnglish{"know"} = "known";
$__pastParticipleEnglish{"lie down"} = "laid down";
$__pastParticipleEnglish{"lead"} = "led";
$__pastParticipleEnglish{"leave"} = "left";
$__pastParticipleEnglish{"lend"} = "lent";
$__pastParticipleEnglish{"light"} = "lit";
$__pastParticipleEnglish{"lose"} = "lost";
$__pastParticipleEnglish{"make"} = "made";
$__pastParticipleEnglish{"meet"} = "met";
$__pastParticipleEnglish{"pay"} = "paid";
$__pastParticipleEnglish{"put"} = "put";
$__pastParticipleEnglish{"read"} = "read [past tense]";
$__pastParticipleEnglish{"ride"} = "ridden";
$__pastParticipleEnglish{"rise"} = "risen";
$__pastParticipleEnglish{"run"} = "run [past tense]";
$__pastParticipleEnglish{"say"} = "said";
$__pastParticipleEnglish{"see"} = "seen";
$__pastParticipleEnglish{"sell"} = "sold";
$__pastParticipleEnglish{"send"} = "sent";
$__pastParticipleEnglish{"shoot"} = "shot";
$__pastParticipleEnglish{"sing"} = "sung";
$__pastParticipleEnglish{"sink"} = "sunk";
$__pastParticipleEnglish{"sit"} = "sat";
$__pastParticipleEnglish{"sleep"} = "slept";
$__pastParticipleEnglish{"speak"} = "spoken";
$__pastParticipleEnglish{"spend"} = "spent";
$__pastParticipleEnglish{"spin"} = "spun";
$__pastParticipleEnglish{"steal"} = "stolen";
$__pastParticipleEnglish{"sting"} = "stung";
$__pastParticipleEnglish{"stink"} = "stunk";
$__pastParticipleEnglish{"swear"} = "sworn";
$__pastParticipleEnglish{"sweep"} = "swept";
$__pastParticipleEnglish{"swim"} = "swum";
$__pastParticipleEnglish{"take"} = "taken";
$__pastParticipleEnglish{"teach"} = "taught";
$__pastParticipleEnglish{"tell"} = "told";
$__pastParticipleEnglish{"think"} = "thought";
$__pastParticipleEnglish{"throw"} = "thrown";
$__pastParticipleEnglish{"wake"} = "woken";
$__pastParticipleEnglish{"win"} = "won";
$__pastParticipleEnglish{"wind"} = "wound";
$__pastParticipleEnglish{"write"} = "written";

sub Init_genExercisesHash
{
  my %genExercisesHash = ();
  #$genExercisesHash{"be born"} = 1;	disabled because I'm not handling German passive voice correctly
  #$genExercisesHash{"be worth"} = 1;

  $genExercisesHash{"abolish"} = 1;
  $genExercisesHash{"achieve"} = 1;
  $genExercisesHash{"acquire"} = 1;
  $genExercisesHash{"act"} = 1;
  $genExercisesHash{"advance"} = 1;
  $genExercisesHash{"advise"} = 1;
  $genExercisesHash{"agree"} = 1;
  $genExercisesHash{"amuse"} = 1;
  $genExercisesHash{"anger"} = 1;
  $genExercisesHash{"announce"} = 1;
  $genExercisesHash{"appear"} = 1;
  $genExercisesHash{"argue"} = 1;
  $genExercisesHash{"arrive"} = "common";
  $genExercisesHash{"attend"} = 1;
  $genExercisesHash{"avoid"} = 1;
  $genExercisesHash{"awaken"} = 1;
  $genExercisesHash{"bake"} = 1;
  $genExercisesHash{"be able to"} = "common";
  $genExercisesHash{"be acquainted with"} = 1;
  $genExercisesHash{"be wrong"} = 1;
  $genExercisesHash{"be"} = "common";
  $genExercisesHash{"beat"} = 1;
  $genExercisesHash{"become"} = 1;
  $genExercisesHash{"begin"} = "common";
  $genExercisesHash{"believe"} = "common";
  $genExercisesHash{"bend"} = 1;
  $genExercisesHash{"bind"} = 1;
  $genExercisesHash{"bite"} = 1;
  $genExercisesHash{"blow"} = 1;
  $genExercisesHash{"bore"} = 1;
  $genExercisesHash{"break"} = "common";
  $genExercisesHash{"bring"} = "common";
  $genExercisesHash{"brush"} = 1;
  $genExercisesHash{"bump"} = 1;
  $genExercisesHash{"burn"} = 1;
  $genExercisesHash{"burst"} = 1;
  $genExercisesHash{"buy"} = "common";
  $genExercisesHash{"call"} = "common";
  $genExercisesHash{"carry"} = 1;
  $genExercisesHash{"catch"} = 1;
  $genExercisesHash{"celebrate"} = 1;
  $genExercisesHash{"choose"} = 1;
  $genExercisesHash{"clean"} = 1;
  $genExercisesHash{"borrow"} = 1;
  $genExercisesHash{"climb"} = 1;
  $genExercisesHash{"close"} = 1;
  $genExercisesHash{"come"} = "common";
  $genExercisesHash{"complain"} = 1;
  $genExercisesHash{"conclude"} = 1;
  $genExercisesHash{"construct"} = 1;
  # fortsetzen is too much trouble! $genExercisesHash{"continue"} = 1;
  $genExercisesHash{"correct"} = 1;
  $genExercisesHash{"count"} = 1;
  $genExercisesHash{"crawl"} = 1;
  $genExercisesHash{"create"} = 1;
  $genExercisesHash{"creep"} = 1;
  $genExercisesHash{"cut"} = 1;
  $genExercisesHash{"deceive"} = 1;
  $genExercisesHash{"deny"} = 1;
  $genExercisesHash{"depend"} = 1;
  $genExercisesHash{"describe"} = 1;
  $genExercisesHash{"devour"} = 1;
  $genExercisesHash{"die"} = 1;
  $genExercisesHash{"dig"} = 1;
  $genExercisesHash{"direct"} = 1;
  $genExercisesHash{"disappear"} = 1;
  $genExercisesHash{"discern"} = 1;
  $genExercisesHash{"displease"} = 1;
  $genExercisesHash{"do"} = "common";
  $genExercisesHash{"dream"} = 1;
  $genExercisesHash{"drink"} = "common";
  $genExercisesHash{"drive"} = 1;
  $genExercisesHash{"dwindle"} = 1;
  $genExercisesHash{"eat"} = "common";
  $genExercisesHash{"employ"} = 1;
  $genExercisesHash{"enjoy"} = "common";
  $genExercisesHash{"err"} = 1;
  $genExercisesHash{"escape"} = 1;
  $genExercisesHash{"excuse"} = 1;
  $genExercisesHash{"fall"} = "common";
  $genExercisesHash{"fear"} = 1;
  $genExercisesHash{"feel emotionally"} = 1;
  $genExercisesHash{"feel physically"} = 1;
  $genExercisesHash{"find"} = "common";
  $genExercisesHash{"finish"} = "common";
  $genExercisesHash{"flee"} = 1;
  $genExercisesHash{"flow"} = 1;
  $genExercisesHash{"fly"} = 1;
  $genExercisesHash{"follow"} = 1;
  $genExercisesHash{"forbid"} = 1;
  $genExercisesHash{"forget"} = "common";
  $genExercisesHash{"freeze"} = 1;
  $genExercisesHash{"fry"} = 1;
  $genExercisesHash{"get married"} = 1;
  $genExercisesHash{"get undressed"} = 1;
  $genExercisesHash{"get up"} = 1;
  $genExercisesHash{"give"} = "common";
  $genExercisesHash{"glide"} = 1;
  #$genExercisesHash{"glimmer"} = 1;
  $genExercisesHash{"go out"} = "common";
  $genExercisesHash{"go"} = "common";
  $genExercisesHash{"grab"} = 1;
  $genExercisesHash{"grow"} = 1;
  $genExercisesHash{"gush"} = 1;
  $genExercisesHash{"hang"} = 1;
  $genExercisesHash{"have"} = "common";
  $genExercisesHash{"hear"} = "common";
  $genExercisesHash{"help"} = "common";
  $genExercisesHash{"hold"} = 1;
  $genExercisesHash{"hope"} = "common";
  $genExercisesHash{"hunt"} = 1;
  $genExercisesHash{"hurry up"} = 1;
  $genExercisesHash{"hurt"} = 1;
  $genExercisesHash{"instruct"} = 1;
  $genExercisesHash{"intend"} = 1;
  $genExercisesHash{"jump"} = 1;
  $genExercisesHash{"kill"} = 1;
  $genExercisesHash{"kiss"} = 1;
  $genExercisesHash{"know"} = "common";
  $genExercisesHash{"laugh"} = "common";
  $genExercisesHash{"lead"} = 1;
  $genExercisesHash{"learn"} = "common";
  $genExercisesHash{"leave"} = 1;
  $genExercisesHash{"lend"} = 1;
  $genExercisesHash{"lift"} = 1;
  $genExercisesHash{"listen"} = "common";
  $genExercisesHash{"live in"} = "common";
  $genExercisesHash{"live"} = "common";
  $genExercisesHash{"load"} = 1;
  $genExercisesHash{"look for"} = "common";
  $genExercisesHash{"lose"} = "common";
  $genExercisesHash{"love"} = "common";
  $genExercisesHash{"maintain"} = 1;
  $genExercisesHash{"make an effort"} = 1;
  $genExercisesHash{"measure"} = 1;
  $genExercisesHash{"meditate"} = 1;
  $genExercisesHash{"meet"} = "common";
  $genExercisesHash{"melt"} = 1;
  $genExercisesHash{"move"} = 1;
  $genExercisesHash{"name"} = "common";
  $genExercisesHash{"need"} = "common";
  $genExercisesHash{"obtain"} = 1;
  $genExercisesHash{"offer"} = 1;
  $genExercisesHash{"open"} = "common";
  $genExercisesHash{"order"} = 1;
  $genExercisesHash{"paint"} = 1;
  $genExercisesHash{"pay"} = "common";
  $genExercisesHash{"penetrate"} = 1;
  $genExercisesHash{"perceive"} = 1;
  $genExercisesHash{"permit"} = 1;
  $genExercisesHash{"persuade"} = 1;
  $genExercisesHash{"pick up"} = 1;
  $genExercisesHash{"pinch"} = 1;
  $genExercisesHash{"play"} = "common";
  $genExercisesHash{"please"} = 1;
  $genExercisesHash{"possess"} = 1;
  $genExercisesHash{"pour"} = 1;
  $genExercisesHash{"praise"} = 1;
  $genExercisesHash{"prefer"} = 1;
  $genExercisesHash{"produce"} = 1;
  $genExercisesHash{"promise"} = 1;
  $genExercisesHash{"protect"} = 1;
  $genExercisesHash{"pull"} = 1;
  $genExercisesHash{"put"} = "common";
  $genExercisesHash{"quarrel"} = 1;
  $genExercisesHash{"rain"} = 1;
  $genExercisesHash{"read"} = "common";
  $genExercisesHash{"realize"} = 1;
  $genExercisesHash{"receive"} = 1;
  $genExercisesHash{"recommend"} = 1;
  $genExercisesHash{"relax"} = 1;
  $genExercisesHash{"remain"} = "common";
  $genExercisesHash{"remember"} = "common";
  $genExercisesHash{"repeat"} = 1;
  $genExercisesHash{"replace"} = 1;
  $genExercisesHash{"request"} = 1;
  $genExercisesHash{"rescue"} = 1;
  $genExercisesHash{"resemble"} = 1;
  $genExercisesHash{"reserve"} = 1;
  $genExercisesHash{"resolve"} = 1;
  $genExercisesHash{"rest"} = 1;
  $genExercisesHash{"return"} = "common";
  $genExercisesHash{"rip"} = 1;
  $genExercisesHash{"rub"} = 1;
  $genExercisesHash{"run"} = 1;
  $genExercisesHash{"say"} = "common";
  $genExercisesHash{"scold"} = 1;
  $genExercisesHash{"see"} = "common";
  $genExercisesHash{"seem"} = 1;
  $genExercisesHash{"seize"} = 1;
  $genExercisesHash{"sell"} = "common";
  $genExercisesHash{"send"} = "common";
  $genExercisesHash{"separate"} = 1;
  $genExercisesHash{"serve"} = "common";
  $genExercisesHash{"share"} = 1;
  $genExercisesHash{"sharpen"} = 1;
  $genExercisesHash{"shoot"} = 1;
  $genExercisesHash{"shout"} = "common";
  $genExercisesHash{"show"} = "common";
  $genExercisesHash{"sing"} = "common";
  $genExercisesHash{"sink"} = 1;
  $genExercisesHash{"sit"} = 1;
  $genExercisesHash{"sleep"} = "common";
  $genExercisesHash{"smile"} = 1;
  $genExercisesHash{"smell"} = 1;
  $genExercisesHash{"snow"} = 1;
  $genExercisesHash{"speak"} = "common";
  $genExercisesHash{"spend"} = 1;
  $genExercisesHash{"spin"} = 1;
  $genExercisesHash{"spoil"} = 1;
  $genExercisesHash{"be located"} = 1;
  $genExercisesHash{"stay"} = 1;
  $genExercisesHash{"steal"} = 1;
  $genExercisesHash{"step"} = 1;
  $genExercisesHash{"sting"} = 1;
  $genExercisesHash{"stink"} = 1;
  $genExercisesHash{"stop"} = "common";
  $genExercisesHash{"strengthen"} = 1;
  $genExercisesHash{"stride"} = 1;
  $genExercisesHash{"stroke"} = 1;
  $genExercisesHash{"study"} = "common";
  $genExercisesHash{"succeed"} = 1;
  $genExercisesHash{"suffer"} = 1;
  $genExercisesHash{"suffice"} = 1;
  $genExercisesHash{"swear"} = 1;
  $genExercisesHash{"swell"} = 1;
  $genExercisesHash{"swim"} = "common";
  $genExercisesHash{"take"} = 1;
  $genExercisesHash{"teach"} = 1;
  $genExercisesHash{"tell"} = 1;
  $genExercisesHash{"think"} = "common";
  $genExercisesHash{"thrive"} = 1;
  $genExercisesHash{"throw"} = 1;
  $genExercisesHash{"tire"} = 1;
  $genExercisesHash{"travel"} = "common";
  $genExercisesHash{"try"} = "common";
  $genExercisesHash{"turn"} = 1;
  $genExercisesHash{"understand"} = "common";
  $genExercisesHash{"updateVtlOnly"} = 1;
  $genExercisesHash{"use"} = 1;
  $genExercisesHash{"vanquish"} = 1;
  $genExercisesHash{"wait for"} = "common";
  $genExercisesHash{"wake up"} = 1;
  $genExercisesHash{"walk"} = 1;
  $genExercisesHash{"want"} = "common";
  $genExercisesHash{"wash"} = 1;
  $genExercisesHash{"weigh"} = 1;
  $genExercisesHash{"whistle"} = 1;
  $genExercisesHash{"win"} = 1;
  $genExercisesHash{"wish"} = 1;
  $genExercisesHash{"work"} = "common";
  $genExercisesHash{"write"} = "common";
  return \%genExercisesHash;
}


sub OverrideVerbTableLookup
{
  my($self, $token, $val) = @_;
  $self->SetByLang("vtl", $token, $val);
}


sub GetLang
{
  my($self) = @_;
  return $self->{"lang"};
}

sub Get__exerciseGenerator
{
  my($self) = @_;
  return $__exerciseGenerator;
}

#sub Set__exerciseGenerator
#{
#  my($self, $val) = @_;
#  $__exerciseGenerator = $val;
#}

sub SetReflexivity_a
{
  my($self, $argsRef) = @_;
  my $stem_a_ref = \$argsRef->[3];

  if (defined $$stem_a_ref
  && ($$stem_a_ref =~ /(.*) oneself$/))
  {
    $$stem_a_ref = $1;
    $argsRef->[17] = 1;
  }
  else
  {
    $argsRef->[17] = 0;
  }
}

sub Get_verb_a
{
  my($self, $verb_b, $mightNotExist) = @_;
  my $argsRef = $self->GetVerbArgs($verb_b, 1);
  my $val;
  if (defined $argsRef)
  {
    $val = $argsRef->[3] .  $argsRef->[4];
  }
  if (defined $val)
  {
    $val =~ s/2$//;
  }
  else
  {
    if (!defined $mightNotExist)
    {
      $mightNotExist = 0;
    } 
    die "cannot find verb_a for $verb_b" unless $mightNotExist;
    $val = undef;
  }
  #print "Get_verb_a($verb_b): $val\n";
  return $val;
}

sub Get_verb_b
{
  my($self, $verb_a) = @_;
  my $val = undef;

  my $argRef = $self->{"verbsByEnglish"}->{$verb_a};
  #Ndmp::Ah("Get_verb_b($verb_a)", @$argRef);
  if (defined $argRef)
  {
    $val = VerbArgs_get_verb_b_with_reflexivity_if_it_exists($argRef);
  }
  #print "Get_verb_b($verb_a): " . nutil::ToString($val) . "\n";
  if (!defined $val && $verb_a =~ /(.*) oneself/)
  {
    $val = $self->Get_verb_b($1);
  }

  if (!defined $val && $verb_a !~ / oneself/)
  {
    $argRef = $self->{"verbsByEnglish"}->{"$verb_a oneself"};

    $val = VerbArgs_get_verb_b_with_reflexivity_if_it_exists($argRef) if defined $argRef;
  }

  return $val;
}


sub Get_verb_b_fromKey
{
  my($self, $key) = @_;

  my $val = undef;
  if ($key =~ /^verb_(.*)\.\d+$/)
  {
    my $verb_a = $1;
    $verb_a =~ s/ /_/g;

    $val = $self->Get_verb_b($verb_a);
  }
  #print "Get_verb_b_fromKey($key): " . nutil::ToString($val) . "\n";
  return $val;
}

sub GetHelperTense
{
  my($self, $tense) = @_;
  return "conditional" if $tense eq "past_conditional";
  return "present" if $tense eq "past";
  return "future" if $tense eq "future_perfect";
  return "imperfect" if $tense eq "pluperfect"; 
  return "k2" if $tense eq "past_k2";
  die "tense $tense";
}

sub StartTracingVtl_ifThisHasBeenRequested
{
  my($self) = @_;
  $__Trace_Vtl = $__Trace_Vtl_requested;
  print "StartTracingVtl_ifThisHasBeenRequested() enabled \$__Trace_Vtl\n" if $__Trace_Vtl;
}

sub GetPresentParticiple_English
{
  my($verb) = @_;
  my $stem;
  if ($verb =~ /^be$/)
  {
    $stem = $verb;
  }
  elsif ($verb =~ /^(.*)ie$/)
  {
    $stem = $1 . "y";
  }
  elsif ($verb =~ /(.*[^e])e$/)  # odd, I know -- Don't match "agree", etc.
  {
    $stem = "${1}";
  }
  else
  {
    $stem = "${verb}";
  }
  if ($verb =~ /^(\S+) (.*)/) # cover "get" and "get up" and "sit down"
  {
    my $initial = $1;    # get
    my $trailing = $2;   # up
    my $initialPp = GetPresentParticiple_English($initial);
    my $val = $initialPp;


    # We don't want to do this because verbs with multiple words are detected earlier, and the trailing words are pulled off and stored in the trailing_string_a variable.  If we include the trailing words in the past participle here, then the trailing_string_a variable will duplicate them in the conjugation.
    # $val .= " $trailing";
    #




    return $val;
  }
  elsif ($stem =~ /^(.*)ie$/)
  {
    return "${1}ying";
  }
  else
  {
    my $charToBeDoubled = IsDoublerOfLastCharWhenCombined_English($verb);
    if (defined $charToBeDoubled)
    {
      return $verb . $charToBeDoubled . "ing";
    }
  }
  return $stem . "ing";
}

sub CapitalizeAndMoveNotesIfNeeded
{
  my($self, $key, $parmS) = @_;
  my $s = $parmS;
  if ($s =~ /^{}(.*)/)
  {
    $s = "{}" . $self->CapitalizeAndMoveNotesIfNeeded($key, $1);
  }
  elsif (!grammar::IsCapitalized($s)
  && $s =~ /^([^\^{}\s]+)/)		# can I get a token out of it?  The \^ is so that I can skip '^D'.
  {
    my $firstToken = $1;
    my $capFirstToken = grammar::Capitalize($firstToken);
    $s =~ s/^$firstToken/$capFirstToken/;
    $self->MoveNotes($key, $firstToken, $capFirstToken);
  }
  #print "CapitalizeAndMoveNotesIfNeeded($key, $parmS): $s\n";
  return $s;
}

sub MoveNotes_withType
{
  my($self, $key, $oldToken, $newToken, $type) = @_;

  my $oldKey = $self->MakeTokenNoteKey($oldToken, $type);
  my $note = tdb::Get($key, $oldKey);
  if (defined $note)
  {
    my $newKey = (defined $newToken ? $self->MakeTokenNoteKey($newToken, $type) : undef);
    my $incumbentNoteAtNewKey = (defined $newKey ? tdb::Get($key, $newKey) : undef);
    if (defined $incumbentNoteAtNewKey)
    {
      if ($note ne $incumbentNoteAtNewKey && $__Trace_MassageAndFootnote)
      {
	warn "steamrolling incumbent anyway for $key (\n$note vs.\n$incumbentNoteAtNewKey)";
      }
      tdb::Set($key, $oldKey, undef);
    }
    else
    {
      tdb::Set($key, $oldKey, undef);
      tdb::Set($key, $newKey, $note) if defined $newKey;
    }
  }
}

sub MoveNotes
{
  my($self, $key, $oldToken, $newToken) = @_;
  $self->MoveNotes_withType($key, $oldToken, $newToken, undef);
  $self->MoveNotes_withType($key, $oldToken, $newToken, "2");
  $self->MoveNotes_withType($key, $oldToken, $newToken, "tmp");
}

sub DeleteNotes
{
  my($self, $key, $oldToken) = @_;
  $self->MoveNotes($key, $oldToken, undef);
}

sub GetPronoun
{
  my($self, $id) = @_;
  my $pronounCode = tdb::Get($id, "pronoun");
  if (defined $pronounCode)
  {
    if ($self->AddendIsSubject($id))
    {
      warn "$id: a pronoun should not be set in a datafile which has addend_is_subject";
    }
  }
  elsif (!$self->AddendIsSubject($id))
  {
    if ($id =~ /^verb_/
    && defined tdb::Get($id, "generated"))
    {
      warn "$id: a pronoun should be set in a datafile which is not addend_is_subject";
    }
    return undef;
  }
  else
  {
    my $addendId = tdb::Get($id, "addendKey");
    my $noun = undef;
    if (defined $addendId)
    {
      my $s = tdb::Get($addendId, $self->GetLang());
      if (!defined $s)
      {
	warn $self->GetLang() . ": $addendId: not set";
      }
      elsif ($s =~ /[\s{]([^\s{]+)>([ps]).*>/)
      {
	$noun = $1;
	my $singularOrPlural = $2;
	my $gender = $self->GetNounGender($noun, 1, $singularOrPlural);
	if (defined $gender)
	{
	  if ($gender eq "f")
	  {
	    $pronounCode = $singularOrPlural . "3b";
	  }
	  else
	  {
	    $pronounCode = $singularOrPlural . "3a";
	  }
	}
      }
      #print "GetPronoun($id) => $s => " . nutil::ToString($noun) . " => " . nutil::ToString($pronounCode) . "\n";
    }
  }
  #print "GetPronoun($id): " . nutil::ToString($pronounCode) . "\n";
  return $pronounCode;
}
  
sub IsIrregularVerb
{
  my($self, $verb_b) = @_;
  my $regular_verbs_regexp = $self->{"regular_verbs_regexp"};
  if (!defined $regular_verbs_regexp)
  {
    warn "regular_verbs_regexp not defined for $self";
  }
  my $paradigmVerb = $self->GetVerbThatThisOneIsPatternedAfter($verb_b);
  if (!defined  $paradigmVerb)
  {
    $paradigmVerb = $verb_b;
  }
  my $val = ($paradigmVerb !~ /^$regular_verbs_regexp$/);
  #print "IsIrregularVerb($verb_b): $val\n";
  return $val;
}

sub DropNotes
{
  my($self, $key, $token) = @_;
  my $tokenKey;
  $tokenKey = $self->MakeTokenNoteKey($token, undef);
  tdb::Set($key, $tokenKey, undef);
  $tokenKey = $self->MakeTokenNoteKey($token, "2");
  tdb::Set($key, $tokenKey, undef);
  $tokenKey = $self->MakeTokenNoteKey($token, "tmp");
  tdb::Set($key, $tokenKey, undef);
}

sub VerbGenInit
{
  my($self, $verb_b) = @_;
  $self->{"verb_b"} = $verb_b;
}

sub AddBullettedPoint
{
  my($self, $s) = @_;
  if ($s)
  {
    return "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#149;&nbsp;$s";
  }
  else
  {
    return "";
  }
}

sub MeToHtml_arrayOfArrays
{
  my($self, $arrayRef) = @_;
  for (my $j = 0; $j < @$arrayRef; $j++)
  {
    my $innerRef = $arrayRef->[$j];
    my $innerLen = scalar(@$innerRef);
    for (my $k = 0; $k < $innerLen; $k++)
    {
      $innerRef->[$k] = $self->MeToHtml($innerRef->[$k]);
    }
  }
}

sub ComposeVTOutput
{
  my($self, $tense, $to_verb_a, $verb_b, $doingVerbTable, $singularConstructionsRef, $pluralConstructionsRef) = @_;

  my $verb_a = $to_verb_a;
  $verb_a =~ s/to //;

  $self->GetTenseURL($tense);	# verify it, really

  my $data;
  my $dataFile = GetVerbExercisesHtmlFileSuffix($verb_a);
  if (-f "data/$dataFile")
  {
    $dataFile = "\"$dataFile\"";
  }
  else
  {
    #print "ComposeVTOutput($tense, $to_verb_a, $verb_b, $doingVerbTable): could not find $dataFile\n";
    $dataFile = "null";
  }

  my $vtFn = $self->GetVerbTableFn($verb_b);
  $vtFn = (($doingVerbTable || !defined $vtFn) ? "null" : "\"$vtFn\"");


  my $unused   = (defined $self->GetOverride($verb_b, "unused $tense"));
  my $suppress = (defined $self->GetOverride($verb_b, "suppress $tense"));
  my $cookedTense = $self->CookTense($tense);
  if ($unused || $suppress)
  {
    warn "$verb_b should not be used as an example for $tense" unless $doingVerbTable;
    $data = "vt_tense(\"$tense\",";
    if ($unused)
    {
      $data .= "new Array(\"" . $self->GetTenseOverride($verb_b, $tense) . "\")";
    }
    else
    {
      $data .= "new Array(\"<i>" . $self->Cook($verb_b) . "</i> is never used in the $cookedTense.\")";
    }
    $data .= ",null";	# placeholder for plural Array 'p'
  }
  else
  {
    $self->MeToHtml_arrayOfArrays($singularConstructionsRef);
    $self->MeToHtml_arrayOfArrays($pluralConstructionsRef);

    $data  = js::MakeJavaScriptArray_fromArrayOfArrays("s", $singularConstructionsRef);
    $data .= js::MakeJavaScriptArray_fromArrayOfArrays("p", $pluralConstructionsRef);
    $data .= "vt_tense(\"$tense\",s,p";
  }

  if ($cookedTense eq $tense)
  {
    $cookedTense = "null";
  }
  else
  {
    $cookedTense = "\"$cookedTense\"";
  }
  $data .= ",$cookedTense,$dataFile,$vtFn";
  $data =~ s/(,null)*$//;	# trailing null args can be omitted
  $data .= ")\n";
  print "ComposeVTOutput($tense, $verb_a, $verb_b, $doingVerbTable): $data\n" if $__Trace_Vtl;
  return $data;
}



sub SplitItem
{
  my($self, $stem) = @_;
  die $stem unless defined $stem;
  if ($stem =~ m{(.*);(.*)})
  {
    return ($1, $2);
  }
  return ($stem, $stem);
}

sub PossessiveVocab
{
  my($self) = @_;

  my $s = $self->ResolveNote("vocab_pronouns_possessive");

  if ($self->{"lang"} ne "Spanish")
  {
    $s .= $self->{"noteDivider"}
    . "<i>"
    . $self->Get__currentToken()
    . "</i> is appropriate if the object being possessed is masculine and singular";

    if ($self->{"lang"} eq "German")
    {
      $s .= ", and in the nominative case";
    }
    $s .= ".  But for feminine objects, or for the case where more than one object is being possessed, ";
    if ($self->{"lang"} eq "German")
    {
      $s .= ", or for objects which are not in the nominative case";
    }

    my $link = $self->MakeGrammarLink("possessive pronouns", "=possessive_pronouns");
    warn("nutil::Warn: no link?  how?") if !defined $link;
    $s .= " there may be other forms which are appropriate.  See $link for more info.";
  }
  return $s;
}

sub SubjectVocab
{
  my($self) = @_;

  my $s = "This is a subject pronoun."
  . $self->{"noteDivider"}
  . $self->ResolveNote("vocab_pronouns_subject");
  return $s;
}


sub StartTable
{
  my($self, $type) = @_;
  $type = "normal" unless defined $type;

  my $s;
  if ($type eq "lite")
  {
    return "<p><center><table border=0 cellpadding=0 cellspacing=0 width=100%>";
  }
  $s =  "<p><center><table bgcolor=#eeeeee border=1 cellpadding=5 cellspacing=5 ";
      
  if ($type eq "narrow")
  {
    return $s . "width=50%>";
  }
  elsif ($type eq "normal")
  {
    return $s . "width=90%>";
  } 
}

sub EndTable
{
  my($self) = @_;
  return "</table></p></center>\n";
}

sub Table
{
  my($self, @tableRefs) = @_;
  my $nestedTables = (@tableRefs > 1);
  		
  my $s = "";
  	
  if ($nestedTables)
  {
    $s .= $self->StartTable("lite");
    $s .= "<tr>";
  }
  	
  foreach my $tableRef (@tableRefs)
  {
    if ($nestedTables)
    {
      $s .= "<td>";
    }
    $s .= $self->StartTable("normal");
    foreach my $rowRef (@$tableRef)
    {
      $s .= "<tr>";
      foreach my $col (@$rowRef)
      {
	$s .= "<td>\n";
        warn("nutil::Warn: no_col_definted_yikes") unless defined $col;
	$s .= "$col\n";
	$s .= "</td>\n";
      } 
      $s .= "</tr>";
    }
    if ($nestedTables)
    {
      $s .= "</td>";
    }
    $s .= $self->EndTable();
  }
  if ($nestedTables)
  {
    $s .= $self->EndTable();
  } 
  return $s;
}

sub StartsWithVowel
{
  my($self, $s) = @_;
  #return($s =~ /^&?[aeio]/); # already converted to HTML escapes
  return ($s =~ /^[^a-z]?[aeio]/);
}

sub Combinable
{
  my($self, $s) = @_;
  return (($s =~ /^h/) || $self->StartsWithVowel($s));
}

sub AforVowels_BforConsonants
{
  my($self, $words, $aRef, $bRef) = @_;
  my @vals;
  for (my $j = 0; $j < @$words; $j++)
  {
    if (!defined($words->[$j]))
    {
      push @vals, undef;
    }
    elsif ($self->Combinable($words->[$j]))
    {
      push @vals, $aRef->[$j];
    }
    else
    {
      push @vals, $bRef->[$j];
    }
  }
  #Ndmp::Ah("vals", \@vals);
  return @vals;
}

sub Get__eqVerbs
{
  my($self, $key) = @_;
  warn("nutil::Warn: no key") unless defined $key;
  return $self->{"eqVerbs"}->{$key};
}

sub Set__eqVerbs
{
  my($self, $key, $val) = @_;
  $self->{"eqVerbs"}->{$key} = $val;
}

sub Build_verb_a
{
  my($self, $stem_a, $inf_a) = @_;
  my $verb_a = "$stem_a$inf_a";
  $verb_a =~ s/2//;
  return $verb_a;
}

sub Combine
{
  my($self, $stem, $possibleSuffix) = @_;
  my $val;
  if (!defined $possibleSuffix)
  {
    $val = undef;
  }
  elsif (!$possibleSuffix)
  {
    $val = $stem;
  }
  else
  {
    my $trailing = "";
    if ($stem =~ /(.*?) (.+)/)
    {
      $stem = $1;
      $trailing = $2;
    }
    
    if ($possibleSuffix eq "")
    {
      $val = $stem;
    }
    elsif ($possibleSuffix =~ /^-(.*)/)
    {
      $possibleSuffix = $1;
      if (($stem =~ /(.*[^aeiou])y$/) && ($possibleSuffix eq "s"))
      {
	$val = $1 . "ies";
      }
      elsif (($stem =~ /(.*(sh|ss))$/) && ($possibleSuffix eq "s"))
      {
	$val = $1 . "es";
      }
      else
      {
	$val = $stem . $possibleSuffix;
      } 
    }
    else
    {
      $val = $possibleSuffix;
    } 
      
    $val .= $trailing;
  }
  #print "$self->Combine($stem, $possibleSuffix) => " . nutil::ToString($val) . "\n";
  return $val;
}

sub Set__hasSecondaryHelperVerb
{
  my($self, $verb) = @_;
  $self->{"hasSecondaryHelperVerb"}->{$verb} = 1;
}

sub Get__hasSecondaryHelperVerb
{
  my($self, $verb) = @_;
  return $self->{"hasSecondaryHelperVerb"}->{$verb};
}

sub MakeOverrideKey
{
  my($verb, $what, $isScalar) = @_;
  die $verb unless defined $what && defined $isScalar;
  my $key;
  if ($isScalar)
  {
    $key = "$verb:$what";
  }
  else
  {
    $key = "$verb;$what";
  }
  return $key;
}

sub Override
{
  my($self, $verb_b, $what, $val, $onlyIfNotYetSet) = @_;
  #print "Override($verb_b, $what, $val, " . ((defined $onlyIfNotYetSet) ? $onlyIfNotYetSet : '') . ")\n";
  my $key = MakeOverrideKey($verb_b, $what, 1);
  
  if (!defined $onlyIfNotYetSet || !$onlyIfNotYetSet || !defined $self->{"verbOverrides"}->{$key})
  {
    $self->{"verbOverrideScalarWhats"}->{$what} = 1; 
    $self->{"verbOverrides"}->{$key} = $val;
    if ($what eq "future")
    {
      $self->{"verbOverrides"}->{MakeOverrideKey($verb_b, "conditional", 1)} = $val;
    }
    elsif ($what eq "it only")
    {
      $self->{"verbOverrides"}->{MakeOverrideKey($verb_b, "suppress imperative", 1)} = $val;
    }
  }
  return undef;
}

sub GetVerbArgs
{
  my($self, $verb_b, $mightNotExist) = @_;
    
  my $verb_b_suffix = $self->{"verb_b_suffix"};
  $verb_b_suffix = "" unless defined $verb_b_suffix;
  
  my $val = $self->{"verbs"}->{$verb_b . $verb_b_suffix};
  if (!defined $val)
  {
    my $recursive_verb_b = $self->MakeRecursive($verb_b);
    $val = $self->{"verbs"}->{$recursive_verb_b . $verb_b_suffix};
    $val = $self->{"verbs"}->{$verb_b}                            if (!defined $val);
    $val = $self->{"verbs"}->{$recursive_verb_b}                  if (!defined $val);
  } 
  die "cannot find argsRef for $verb_b ($verb_b_suffix)" unless $mightNotExist || (defined $val);
  return $val;
}

sub Get_all_verb_bs
{
  my($self) = @_;
  my $v = $self->{"verbs"};
  return keys %$v;
}

sub Set__verbs
{
  my($self, $key, $val) = @_;
  #Ndmp::Ah("$self->Set__verbs($key)", $val);
  $self->{"verbs"}->{$key} = $val;
}

sub Get__verbsByEnglish
{
  my($self, $key) = @_;
  die "bad key" unless defined $key;
  my $val = $self->{"verbsByEnglish"}->{$key};
  return $val if defined $val;

  # nothing matched.  Take a guess:
  my($stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a) = ($key, '', '', '', '-s', '', '', '');
  return [ 'dummy', 'dummy', 'dummy',
  $stem_a, $inf_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a ];
}

sub GetVerb_a
{
  my($self, $verb_b) = @_;
  my $verb_a = undef;
  my $argsRef = $self->GetVerbArgs($verb_b, 1);
  if (defined $argsRef)
  {
    my $dummy;
    ($dummy, $dummy, $dummy, $verb_a) = @$argsRef;

    #print "GetVerb_a($verb_b): $verb_a\n";
  }
  if ($verb_a)
  {
    return $verb_a;
  }
  else
  {
    return undef;
  }
}


sub GetVerb_a_fromDataFile
{
  my($self, $dataFile) = @_;
  my $s = $dataFile;
  $s =~ s/verb_//;
  $s =~ s/vocab_//;
  $s =~ s/_/ /g;
  #print "GetVerb_a_fromDataFile($dataFile): $s\n";
  return $s;
}


sub Set__verbsByEnglish
{
  my($self, $verb_a, $argsRef) = @_;
  $self->{"verbsByEnglish"}->{$verb_a} = $argsRef;
        
  if ($verb_a =~ /(ch|s|sh|x|z)$/)
  {
    $self->SetEnglishOddness("",     "",     "-es",  "",    $argsRef);
  }
  elsif ($verb_a eq "be")
  {
    $self->SetEnglishOddness("am",   "are",  "is",   "are", $argsRef);
  }
  elsif ($verb_a eq "do")
  {
    $self->SetEnglishOddness("",     "",     "does", "",    $argsRef);
  }
  elsif ($verb_a eq "go")
  {
    $self->SetEnglishOddness("",     "",     "goes", "",    $argsRef);
  }
  elsif ($verb_a eq "have")
  {
    $self->SetEnglishOddness("",     "",     "has",  "",    $argsRef);
  }
  
  #print "$self->Set__verbsByEnglish($verb_a, $argsRef)\n";
}

sub GetPastParticiple_English
{
  my($self, $verb) = @_;
  die $self unless defined $verb;
  my $val = $__pastParticipleEnglish{$verb};
  if (defined $val)
  {
    ;
  }
  elsif ($verb =~ /(.*)get$/)
  {
    $val = "${1}gotten";
  }
  elsif ($verb =~ /(.*)hold$/)
  {
    $val = "${1}held";
  }
  elsif ($verb =~ /^(\S+) (.*)$/)
  {
    my $initial = $1;    # get
    my $trailing = $2;   # up
    my $initialPp = $self->GetPastParticiple_English($initial);
    $val = "$initialPp";


    # We don't want to do this because verbs with multiple words are detected earlier, and the trailing words are pulled off and stored in the trailing_string_a variable.  If we include the trailing words in the past participle here, then the trailing_string_a variable will duplicate them in the conjugation.
    # $val .= " $trailing";
    #



  }
  elsif ($verb =~ /(.*)come$/)
  {
    $val = $verb;
  }
  elsif ($verb =~ /(.*)stand$/)
  {
    $val = "${1}stood";
  }
  elsif ($verb =~ /(play|stay)$/)
  {
    $val = "${1}ed";
  }
  elsif ($verb =~ /(.*[^uo])y$/)
  {
    $val = "${1}ied";
  }
  elsif ($verb =~ /e$/)
  {
    $val = "${verb}d";
  }
  else
  {
    my $charToBeDoubled = IsDoublerOfLastCharWhenCombined_English($verb);
    if (defined $charToBeDoubled)
    {
      $val = $verb . $charToBeDoubled . "ed";
    }
    else
    {
      $val = $verb . "ed";
    }
  }
  return $val;
}

sub IsDoublerOfLastCharWhenCombined_English
{
  my($verb) = @_;
  my $val = undef;
  if ($verb =~ /^(begin|chat|commit|control|cut|fit|get|grab|occur|permit|prefer|put|regret|rip|rub|run|sit|snap|step|stop)$/)
  {
    die $verb unless $verb =~ /(.)$/;
    $val = $1;
  }
  return $val;
}

sub GetOverride
{
  my($self, $verb, $what) = @_;
  my $key = MakeOverrideKey($verb, $what, 1);
  die $verb unless defined $key;
  my $val = $self->{"verbOverrides"}->{$key};
  #print "GetOverride($verb, $what): $val\n";
  return $val;
}

sub GetStem
{
  my($self, $verb, $tense) = @_;

  my $stem = $self->GetOverride($verb, $tense);
  if (defined $stem)
  {
    #print "GetStem($verb, $tense): $stem\n";
    return $stem;
  }
  return undef;
}

sub GetSortedVerbs
{
  my($self) = @_;
  if (!defined $self->{"sortedVerbs"})
  {
    my %mapToDirty = ();
    my $verbs = $self->{"verbs"};
    foreach my $key (keys %$verbs)
    {
      if (defined $__invisibleVerbs{$key})
      {
	#print "GetSortedVerbs(): $key invisible\n";
	next;
      }

      #print "GetSortedVerbs: looking at $key\n";
      my $cleanedKey = $self->CleanVerb($key);
      if (defined  $cleanedKey)
      {
	#print "GetSortedVerbs(): $cleanedKey => $key\n";
	$mapToDirty{$cleanedKey} = $key;
      }
    }
    my @cleaned = ();
    my $j = 0;
    foreach my $cleanedKey (sort(keys %mapToDirty))
    {
      #print "GetSortedVerbs(): $mapToDirty{$cleanedKey}\n";
      $cleaned[$j++] = $mapToDirty{$cleanedKey};
    }
    $self->{"sortedVerbs"} = \@cleaned;
  }
  return $self->{"sortedVerbs"};
}

sub VerbArgs_get_stem_b
{
  my($self, $argsRef) = @_;
  return $$argsRef[0];
}

sub VerbArgs_get_p1_b
{
  my($self, $argsRef) = @_;
  my $val = $$argsRef[14];
  return $val;
}

sub VerbArgs_get_s3_b
{
  my($self, $argsRef) = @_;
  my $val = $$argsRef[13];
  return $val;
}

sub VerbArgs_set_reflexive_b
{
  my($self, $argsRef, $reflexive_b) = @_;
  $$argsRef[18] = $reflexive_b;
}

sub VerbArgs_get_verb_b_with_reflexivity_if_it_exists
{
  my($argsRef) = @_;
  my $full_reflexive_name = $$argsRef[18];
  if (defined $full_reflexive_name && $full_reflexive_name)
  {
    return $full_reflexive_name;
  }
  else
  {
    return $argsRef->[0] . $argsRef->[1];
  }
}

sub VerbArgs_get_stem_a
{
  my($self, $argsRef) = @_;
  return $$argsRef[3];
}

sub Get_verb_a_withToIfAppropriate
{
  my($self, $verb_b) = @_;
  my $verb_a = $self->Get_verb_a($verb_b);
  if ($verb_a !~ /^(can|ought|should)\b/)
  {
    $verb_a = "to $verb_a";
  }
  return $verb_a;
}

sub UpdateVtlOnly
{
  my($self, $tense) = @_;
  return 0;
}

sub IsTense
{
  my($self, $what) = @_;
  my $val = 0;
  my $tenses = $self->GetTenses();
  foreach my $tense (@$tenses)
  {
    if ($what eq $tense)
    {
      $val = 1;
      last;
    }
  }
  #print "IsTense($what): $val\n";
    return $val;
  }

sub GetPast_English
{
  my($self, $verb_a) = @_;
  die $self unless defined $verb_a;
  my $val = $__pastEnglish{$verb_a};
  if (!defined $val)
  {
    if ($verb_a =~ /([^ ]+)( .+)/)
    {
      $val = $self->GetPast_English($1) . $2;
    }
    else
    {
      $val = $self->GetPastParticiple_English($verb_a);
    }
  }
  #print "GetPast_English($verb_a): $val\n";
  return $val;
}

sub GetVerbThatThisOneIsPatternedAfter
{
  my($self, $verb_b) = @_;

  my $paradigmVerb = $self->Get__eqVerbs($verb_b);
  if (!$paradigmVerb || $self->VerbsOnlyDifferInReflexivity($verb_b, $paradigmVerb))
  {
    return undef;
  }
  else
  {
    return $paradigmVerb;
  }
}

sub OverrideList
{
  my $self  = shift @_;
  my $verb  = shift @_;
  my $tense = shift @_;
  my @rest  =       @_;
  if ($__Trace_VerbCharacteristicPropagation)
  {
    Ndmp::Ah("OverrideList($verb, $tense)", \@rest);
  }
  $self->{"verbOverrideListWhats"}->{$tense} = 1;
  $self->{"verbOverrides"}->{MakeOverrideKey($verb, $tense, 0)} = \@rest;
  return undef;
}

sub GetOverrideList
{
  my($self, $verb, $tense) = @_;
  die $verb unless defined $tense;
  return $self->{"verbOverrides"}->{MakeOverrideKey($verb, $tense, 0)};
}

sub InsertReflexivePronoun_English
{
  my($self, $phrase, $reflexivePronoun) = @_;
  if ($phrase =~ /(.*) (up)$/) # have gotten up
  {
    return "$1 $reflexivePronoun $2";
  }
  return $phrase . " $reflexivePronoun";
}

sub SetVerbArgs
{
  my($self, $verb_b, $verb_a, $argsRef, $notFirstVerbWithThisEnglish) = @_;
  #print "SetVerbArgs($self, $verb_b, $verb_a, $argsRef)\n";
  #Ndmp::Ah("args", @$argsRef);
  $self->Set__verbs($verb_b, $argsRef);

  if ($verb_a =~ /(.*)2$/)
  {
    $notFirstVerbWithThisEnglish = 1;
    $verb_a = $1;
  }
  
        
  # Because of the logic of my German conjugating code which separates separable verbs in German, there is an assumption that the "base" verb exists.  In some cases, this is not valid.  But it makes life for the software much easier, so I define a "fake" verb to show how to conjugate it.  But this verb should not be used for any other purpose, and this is indicated by means of an undefined verb_a setting, or alternatively the special name "updateVtlOnly" which indicates that the vtl should be updated but no verb table or exercises generated.  This latter feature is needed to support the proper MassageAndFootnote functionality for separable verbs.
      
  if (!defined $verb_a)
  {
    $__invisibleVerbs{$verb_b} = 1;
  }
  else
  {
    # 'brillar con luz tenue' causes $__invisibleVerbs{'brillar'} = 1, 
    # but later on when we process 'brillar', we realize that we should delete($__invisibleVerbs{'brillar'}):
    delete($__invisibleVerbs{$verb_b});
    
    my $vfn = $self->GetVerbTableFn($verb_b);
    $self->AutoLink($verb_b, $vfn) if defined $vfn;
    if (defined $notFirstVerbWithThisEnglish && $notFirstVerbWithThisEnglish)
    {
      # take steps to prevent exercises from being generated for this verb, if needed
      if (defined $self->{"genExercisesHash"}->{$verb_a})
      {
	$self->Override($verb_b, "suppress gen_exercises", 1); 
      }
      $verb_a .= "2";
    }
        
    while ($verb_b =~ /(.*) \S+/)
    {
      $verb_b = $1;    
      last if $verb_b =~ /^(se|sich)$/;
      	          
      if (!defined $self->GetVerbArgs($verb_b, 1))	# don't overwrite prepositionless verbs which have already been defined
      {
	$__invisibleVerbs{$verb_b} = 1;
	$self->Set__verbs($verb_b, $argsRef, 1);	# prevent prepositions from stopping lookups
      } 
    } 
    
    $self->Set__verbsByEnglish($verb_a, $argsRef); 
  } 
}

sub AutoLink
{
  my($self, $s, $dest) = @_;
  #print "$self->AutoLink('$s' -> $dest)\n";
  $self->{"automaticallyLinkedStrings"}->{$s} = "$dest";
}

sub UnAutoLink
{
  my($self, $s) = @_;
  delete($self->{"automaticallyLinkedStrings"}->{$s});
}

sub GetAutoLink
{
  my($self, $key) = @_;
  my $url = $self->{"automaticallyLinkedStrings"}->{$key};
  if (defined $url)
  {
    return $url;
  }
  else
  {
    return 0;
  }
}

sub DuplicatePattern
{
  my($self, $initialS, $before, $after, $suffixBefore, $suffixAfter) = @_;
  die "lskfj" unless defined $after;
      
  return undef unless defined $initialS;
  
  my $s = $initialS;
  my $trailingString = "";
  if ($s =~ /(\S+)( .*)$/)
  {
    $s = $1;
    $trailingString = $2;
  } 
        
  $s =~ s{$before}{$after};
  $s =~ s{$suffixBefore}{$suffixAfter} if (defined $suffixBefore);
  #print "generic_grammar.DuplicatePattern($initialS, $before, $after, $suffixBefore, $suffixAfter): $s\n";
  return $s . $trailingString;
}
      
sub DuplicateOverrides
{
  my($self, $verb, $paradigmVerb, $before, $after, $suffixBefore, $suffixAfter, $overrideExistingSettings) = @_;
  
  $overrideExistingSettings = 0 unless defined $overrideExistingSettings;
  
  my $verbOverrideScalarWhats = $self->{"verbOverrideScalarWhats"};
  foreach my $what (keys %$verbOverrideScalarWhats)
  {
    next if !$overrideExistingSettings && defined $self->GetOverride($verb, $what);
    
    my $val = $self->GetOverride($paradigmVerb, $what);
    if (defined $val)
    {
      next if ($what eq "it only");	# don't propagate that one(e.g., schwinden -> verschwinden)
      
      if ($__Trace_VerbCharacteristicPropagation)
      {
	print "DuplicateOverrides($verb, $paradigmVerb, $before, $after";
	print ", $suffixBefore, $suffixAfter" if defined $suffixBefore;
	print "): found $val for $what...\n";
      }                              
      if ($what eq "suppress gen_exercises")
      {
	# This is an override which is never a characteristic of a conjugational class.
	# Don't propagate it.
	next;
      }
      elsif ($what eq "past participle")
      {
	$val = $self->TransformPastParticiple($val, $paradigmVerb, $verb, $before, $after, $suffixBefore, $suffixAfter);
      }
      else
      {
	my @vals = split(/;/, $val);
	for (my $j = 0; $j <= $#vals; $j++)
	{
	  $vals[$j] = $self->DuplicatePattern($vals[$j], $before, $after, $suffixBefore, $suffixAfter);
	}
	$val = join(';', @vals);
      }
      print "                                             ...converted to	$val\n\n" if $__Trace_VerbCharacteristicPropagation;
      $self->Override($verb, $what, $val);
    } 
  } 
          
  my $verbOverrideListWhats = $self->{"verbOverrideListWhats"};
  foreach my $what (keys %$verbOverrideListWhats)
  {
    next if !$overrideExistingSettings && defined $self->GetOverrideList($verb, $what);
    
    my $val = $self->GetOverrideList($paradigmVerb, $what);
    if (defined $val)
    {
      my @vals = @$val;
      #Ndmp::Ah("DuplicateOverrides($verb, $paradigmVerb, $before, $after, $suffixBefore, $suffixAfter): for $what", $val);
      for (my $j = 0; $j <= $#vals; $j++)
      {
	if (defined $vals[$j])
	{
	  $vals[$j] = $self->DuplicatePattern($vals[$j], $before, $after, $suffixBefore, $suffixAfter);
	}
      }
      #Ndmp::Ah("...converted to", $val);;
      $self->OverrideList($verb, $what, @vals);
    } 
  } 
}

sub SetEnglishOddness
{
  my($self, $s1, $s2, $s3, $p1, $argsRef) = @_; 
  #Ndmp::Ah("1", $argsRef);
              
  $argsRef->[5] = $s1;
  $argsRef->[6] = $s2;
  $argsRef->[7] = $s3;
  $argsRef->[8] = $p1;
  $argsRef->[9] = $p1;
  $argsRef->[10] = $p1;
              
  #Ndmp::Ah("2", $argsRef);
}

sub MarkThisVerbAsHavingGeneratedExercises
{
  my($self, $verb_a) = @_;
  #print "MarkThisVerbAsHavingGeneratedExercises($verb_a)\n";
  
  #$verb_a =~ s/ oneself//;
  $verb_a =~ s/2$//;
  
  if (!defined $self->{"genExercisesHash"}->{$verb_a})
  {
    print "MarkThisVerbAsHavingGeneratedExercises: could not find $verb_a\n";
  }
  delete($self->{"genExercisesHash"}->{$verb_a});
}

sub SyncWithXlationHash
{
  my($self, $dataFile) = @_;
  my $lang = $self->{"lang"};
  
  for (my $id = 0;; $id++)
  {
    my $english = tdb::Get("$dataFile.$id", "English");
    last unless defined $english;
    my $other   = tdb::Get("$dataFile.$id", $lang);
    my $otherFromDb = $self->HashGet("xlateDb", $english);
    
    if (!defined $otherFromDb)
    {
      $self->HashPut("xlateDb", $english, $other);
    }
    elsif (!defined $other)
    {
      print "SyncWithXlationHash($dataFile.$id: $lang: $english => otherFromDb";
      tdb::Set("$dataFile.$id", $lang, $otherFromDb);
    }
    elsif ($otherFromDb ne $other)
    {
      #warn "$dataFile.$id: $lang: $otherFromDb overriding $other";
      #tdb::Set("$dataFile.$id", $lang, $otherFromDb);
    }
  }
}
  
sub VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone
{
  my($self, $verb_b, $fn) = @_;
  #print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn)\n";
  my $val = 1;
  my $verb_a = $self->Get_verb_a($verb_b);
    
  my $verb_a_arg = Argv_db::FlagArgWithSpacesForUnderscores("verb_a", 0, "");
  my $verb_b_arg = Argv_db::FlagArgWithSpacesForUnderscores("verb_b", 0, "");
      
  my $dataFile = GetVerbExercisesHtmlFileSuffix($verb_a);
  my $addendNeedsToBeRelinked = Argv_db::FlagSet("relinkAll");
      
  if ((defined $fn && (! -f "html/$fn"))
  ||  ($verb_a_arg =~ /$verb_a/)	# use =~ instead of eq so a verb_a_arg of 'become2'...
  ||  ($verb_b_arg =~ /$verb_b/))	# ...succeeds with a verb_a of 'become'.
  {
    $addendNeedsToBeRelinked = 1;
    $val = 0;
  }
  elsif ($verb_a_arg || $verb_b_arg)
  {
    $val = 1;
  }
  elsif ($self->VerbUsedToGenerateExercises($verb_b))
  {
    my @addendDeps = tdb::GetAddendDeps($dataFile);
    if (!@addendDeps)
    {
      print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn): no deps\n" if $__Trace_Relink;
    }
    else
    {
      if (!$addendNeedsToBeRelinked)
      {
	foreach my $addendDep (@addendDeps)
	{
	  if (defined $__outOfDateAddend{$addendDep})
	  {
	    print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn): $addendDep marked out-of-date\n" if $__Trace_Relink;
	    $addendNeedsToBeRelinked = 1;
	    last;
	  }
	  print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn): sees dep to $addendDep\n" if $__Trace_Relink;
	  	  		                  			            	
	  if (!defined tdb::Get("$dataFile.0", "z/English/addend")	# never updated?
	  || filer::Newer("data/$addendDep", "data/$dataFile", $__Trace_Relink))
	  {
	    print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn): $addendDep has changed since last $dataFile save\n" if $__Trace_Relink;
	    tdb::Touch($dataFile);
	    $__outOfDateAddend{$addendDep} = 1;
	    $addendNeedsToBeRelinked = 1;
	    last;
	  }
	}
      }              
    }
  }    
  if ($addendNeedsToBeRelinked)
  {
    teacher::LinkData($dataFile);
        
    foreach my $addendDep (tdb::GetAddendDeps($dataFile))
    {
      $self->SyncWithXlationHash($addendDep);
    }
    $val = 0;
  }
  print "VerbTableAndOtherOutputsUpToDate_andNoReLinkDataDone($verb_b, $fn): $val\n" if $__Trace_Relink;
  return $val;
}
  
  
  
sub GetVerbExercisesHtmlFileSuffix
{
  my($verb_a) = @_;
  $verb_a =~ s/ /_/g;	# "wait for" -> "wait"
  $verb_a =~ s/_\(.*//;	# "raise (e.g., a child" -> "raise"
  return "verb_" . $verb_a;
}

sub ExercisesAreAppropriateFor
{
  my($self, $verb_a, $verb_b) = @_;
          
  my $val;
  if (defined $self->GetOverride($verb_b, "suppress gen_exercises"))
  {
    print "ExercisesAreAppropriateFor($verb_a, $verb_b): suppressed\n" if $__Trace_XGen;
    $val = 0;
  }
  else
  {
    #$self->HashDump("genExercisesHash");
    $val = (defined $self->{"genExercisesHash"}->{$verb_a});
  }
  print "ExercisesAreAppropriateFor($verb_a, $verb_b): $val\n" if $__Trace_XGen;
  return $val;
}

sub ListExercisesWhichWereNotGeneratedButShouldHaveBeen
{
  my($self) = @_;
  return unless Argv_db::FlagSet("genExercises");
      
  my $genExercisesHash = $self->{"genExercisesHash"};
  delete($genExercisesHash->{"updateVtlOnly"});
      
  my @all_verbs_a = keys %$genExercisesHash;
            
  if (@all_verbs_a)
  {
    print "Exercises should have been generated for the following " . scalar(@all_verbs_a) . " verbs, but weren't:\n"; 
    foreach my $verb_a (sort @all_verbs_a)
    {
      print "EqVerb('\@\@', '$verb_a', '\@\@')\n";
    } 
  }
}

sub VerbUsedToGenerateExercises
{
  my($self, $verb_b) = @_;
  my $val;
  my $verb_a = $self->Get_verb_a($verb_b);
  if ($verb_a eq "updateVtlOnly")
  {
    $val = 0;
  }
  else
  {
    $val = $self->ExercisesAreAppropriateFor($verb_a, $verb_b);
  }
  print "VerbUsedToGenerateExercises($verb_b): $val\n" if $__Trace_XGen;
  return $val;
}

sub OnEndofPrint1VerbTableAndGenX
{
  my($self, $verb_a) = @_;
  $self->Get__exerciseGenerator()->Save(0) if $self->Get__exerciseGenerator();  
  $self->VtlUpdateCleanup();
  tdb::Close1(GetVerbExercisesHtmlFileSuffix($verb_a));
  $__exerciseGenerator = undef;
}

sub ArrangeToCreateNewExercises
{
  my($self, $verb_b) = @_;
  print "ArrangeToCreateNewExercises($verb_b)\n" if $__Trace_Relink;
  my $verb_a = $self->Get_verb_a($verb_b);
  my $verb_a_htmlFileSuffix = GetVerbExercisesHtmlFileSuffix($verb_a); 
  my $lang = $self->GetLang();
                
  $__exerciseGenerator = new exercise_generator($self->GetLang(), $verb_b, $verb_a, $verb_a_htmlFileSuffix, $self);
}

# note that the pronounCode is used to match up the different languages'
# exercises into consistent packages, each of which will be presented to
# the user in a single HTML file.
sub X
{
  my($self, $tense, $english, $pronounCode, $other, $verbForm, $suppressVtl) = @_;
  print "X($tense, $english, $pronounCode, $other, $verbForm, " . nutil::ToString($suppressVtl) . ")\n" if $__Trace_XGen;
            
  $english =~ s/ (emotionally|physically)//;
  
  if (!$__exerciseGenerator)
  {
    print "X($tense, $english, $pronounCode): no __exerciseGenerator\n" if $__Trace_XGen;
  }
  else
  {
    my $otherForX = $other;
    # I split parenthesized lines unnaturally sometimes so tokens can get autolinked.  Undo that.
    # (
    # t`u
    # ) 
    # 
    # becomes
    # 
    # (t`u)
    # 
    $otherForX =~ s/\n/ /g;
    $otherForX =~ s/ +/ /g;
                  
    $otherForX =~ s/\( /(/g;
    $otherForX =~ s/ \)/)/g;
                     
    $suppressVtl = 0 if !defined $suppressVtl;
    
    print "X($tense, $english, $pronounCode, $otherForX, $verbForm, $suppressVtl): add exercise\n" if $__Trace_XGen;
    $__exerciseGenerator->AddExercise($tense, $english, $pronounCode, $otherForX, $verbForm);
  }
  if ($suppressVtl)
  {
    print "X($tense, $english, $pronounCode, $other, $verbForm, $suppressVtl): suppressed vtl update\n" if $__Trace_Vtl;
  }
  else
  {
    $self->VtlUpdate($verbForm, $tense)
  }
  return [$english, $other];
}

sub ResolveNote
{
  my($self, $note) = @_;
  my $originalNote = $note;
  while ($note =~ /^(\w+)\((.*)\)$/s)
  {
    my($proc, $args) = ($1, $2);
    $note = "\$self->" . $note;
    my $evalS = "\$note = $note";
    #print "grammar::ResolveNote: About to eval($evalS)...\n";
    eval($evalS);
    if ($@)
    {
      print "grammar.ResolveNote: $evalS failed: $@\n";
    }
    if (!defined $note)
    {
      warn("nutil::Warn: ($originalNote) no text from $evalS in $self");
      last;
    }
  }
  #print "ResolveNote($note): not evaling\n";
  if ($note =~ / /)  # text with at least one embedded space
  {
    $note = $self->Cook($note);
  }
  else
  {
    my $key = $note;
    my $universalNote = tdb::Get($self->UniversalKey(), "$key/note");
    if (defined $universalNote)
    {
      $note = $universalNote;
      my $url     = $self->GetNoteLink($key);
      my $linkText = $self->GetNoteLinkText($key);
      if ((!defined $linkText &&  defined $url)
      ||   (defined $linkText && !defined $url))
      {
        warn("nutil::Warn: url, link text not in sync for note $key: $url/$linkText under $universalNote");
      }
      elsif (defined $url)
      {
	$linkText = $self->Cook($linkText);

	# add link info to the eoln.  Don't allow a period ahead
	# of the parens:
	$note =~ s{(\.)?$}{" (more at " . $self->MakeLink($linkText, $url) . ")."}e;
      }
    }
    elsif ($note =~ /vocab_/)
    {
      $note = $self->VocabType($note);
    }
    else
    {
      warn("nutil::Warn: " . $self->{"lang"} . ": could not resolve note '$note'");
    }
  }

  #print "ResolveNote($note): nested?\n";
  if ($note =~ /^\w+\(.*\)$/s)	# get nested evals (e.g., informalP2IsImpliedVous)
  {
    #print "ResolveNote($note): nested.\n";
    $note = $self->ResolveNote($note);
  }
  else
  {
    #print "ResolveNote($note): NOT nested.\n";
  }
  #print "ResolveNote($originalNote): $note\n";
  return $note;
}



sub ItalicizeMyCommandTokens
{
  my($s) = @_;
  die "oops" unless defined $s;

  # don't corrupt ",c"
  # &; because this conversion sometimes happens after the conversion to HTML (with stuff like h&ouml;ren):
  $s =~        s{^,([-a-zA-Z#/`:&;]+)}  {<i>$1</i>}g;
  $s =~ s{([^a-z]),([-a-zA-Z#/`:&;]+)}{$1<i>$2</i>}g;
  return $s;
}



sub Cook
{
  my($self, $s) = @_;
  $s =~ s{<i>([^<]*?)</i>}{"<i>" . $self->MeToHtml($1) . "</i>"}eg;
  $s =~ s{>([^<]*?)</a>}{">" . $self->MeToHtml($1) . "</a>"}eg;
  $s =~ s/^([^<>\n]+)$/$self->MeToHtml($1)/egm;
  $s = ItalicizeMyCommandTokens($s);
  $s =~ s/[ \t],/,/g;		# I dunno why spaces are showing up before commas, but me no likey
  return $s;
}


sub SetCurrentId
{
  my($self, $id) = @_;
  #print "SetCurrentId($id)\n";
  $__idOfExBeingGenerated = $id;
}

sub GetCurrentId
{
  return $__idOfExBeingGenerated;
}

sub ResolveAndCookNotes
{
  my($self, $token, @noteKeys) = @_;

  my $savedToken = undef;
  if (!defined $token)
  {
    $token = $self->Get__currentToken();
  }
  else
  {
    $savedToken = $self->Get__currentToken();
    $self->Set__currentToken($token);
  }
  my $text = undef;
  foreach my $noteKey (@noteKeys)
  {
    my $text1 = $self->ResolveNote($noteKey);
    if (defined $text1)
    {
      $text .= $self->{"noteDivider"} if defined $text;
      $text .= $text1;
    }
  }
  if (defined $text)
  {
    $text =~ s{%currentToken%}{<i>$token</i>}g if defined $token;
    $text = $self->Cook($text);
    $text =~ s/\n/ /g;
    $text =~ s/^ *//;
    $text =~ s/^<i> */<i>/;
  }
  #print "ResolveAndCookNotes($noteKey, $token): $text\n";
  $self->Set__currentToken($savedToken) if defined $savedToken;
  return $text;
}

sub GetNoteLink
{
  my($self, $key) = @_;
  tdb::Get($self->UniversalKey(), "$key/url");
}

sub MeToHtml
{
  my($self, $s) = @_;
  die $self unless defined $s;
  $s =~ s/\^D.//g;
  $s =~ s/^(.[^=]*?)$/iso_8859_1_convert::MeToHtml($1)/egm;	# I'm trying to protect links (<a href=...)
  return $s;
}

sub GetNoteLinkText
{
  my($self, $key) = @_;
  tdb::Get($self->UniversalKey(), "$key/linkText");
}


sub RawFormOf
{
  my($self, $context, $verb_b, $citation, $note) = @_;
  #print "RawFormOf($context, $verb_b, $citation, " . nutil::ToString($note) . ")\n";
  $citation =~ s/-/ /g; # "suis-je rendu..." becomes "suis-rendu" in the citation without this
  my $v = "<i>$verb_b</i>";
  my $s = $citation;
  
  my $aOrAn = ($context =~ /^[aeiou]/) ? "an" : "a";
  
  if ($context eq "past participle")
  {
    $s .= "the past participle";
  }
  elsif ($context eq "subjunctive")
  {
    $s .= "$aOrAn " . $self->GetTenseLink($context) . " mood form";
  }
  else
  {
    my $tense;
    if ($context eq "imperative")
    {
      $tense = "present";
      $s .= "$aOrAn " . $self->GetTenseLink($context) . " form of the ";
      $s .= $self->GetTenseLink($tense) . " tense";
    }
    else
    {
      $tense = $context;
      $s .= "$aOrAn " . $self->GetTenseLink($tense) . " tense form";
    } 
  } 
  $s .= " of the verb ";
  my $verbTableLink = $self->GetVerbTableLink($verb_b, "$v", 1);
  if (defined $verbTableLink)
  {
    $s .= $verbTableLink;
  }
  else
  {
    $s .= $v;
  }
  my $exercisesLink = $self->GetExercisesLink($verb_b, undef, "exercises which use $v");
  		
  $s .= " (" if (defined $exercisesLink);
  if (defined $exercisesLink)
  {
    $s .= "cf. $exercisesLink";
  }
  $s .= ")" if (defined $exercisesLink);
  $s .= ".";
  		
  if (defined $note)
  {
    my $token = $self->Get__currentToken();
    my $resolvedNote = $self->ResolveNote($note);
    if (defined $resolvedNote)
    {
      $s .= $self->{"noteDivider"} . $resolvedNote;
    } 
    else
    {
      warn "Could not resolve note $note (on $token)";
    } 
  }
  else
  {
    my $additionalNotes = $self->MakeAdditionalNotes($context, $verb_b);
    if ($additionalNotes)
    {
      my $noteDivider = $self->{"noteDivider"};
      if ($additionalNotes !~ /^$noteDivider/)
      {
	$additionalNotes = $noteDivider . $additionalNotes;
      }
      $s .= $additionalNotes;
    }
  } 
  my $cookedS = $self->Cook($s);
  #print "RawFormOf($context, $verb_b, $citation, " . nutil::ToString($note) . "): $s/$cookedS\n";
  return $cookedS;
}

sub MakeAdditionalNotes
{
  my($self, $context, $verb_b) = @_;
  return "";
}

# unused:
sub FillNoteTemplate
{
  my($self, @vals) = @_;
      
  my $key = shift @vals;
  my $template = tdb::Get($self->UniversalKey(), "$key/noteTemplate");
  my $text = sprintf($template, @vals);
  #print "$self->FillNoteTemplate: returning $text (from $key:$template)\n";
  return $self->Cook($text);
}

sub AdjectivalExpressionMustAgreeWithPrecedingDirectObject
{
  my($self, $directObject) = @_;
  return $self->AdjectivalExpressionMustAgree("When the past participle comes after a direct object in a sentence, it must agree with that direct object in gender and number.", $directObject, "direct object", "=Verbs=past=preceding_direct_object", "direct objects preceding the past participle");
}
 
sub SaveNote
{
  my($self, $key, $note, $urlOffset, $linkText) = @_;
  print "$self->SaveNote($key, $note, " . nutil::ToString($urlOffset) . ", " . nutil::ToString($linkText) . ")\n" if $__Trace_XGen;

  die "note not ended correctly: " . $note unless $note =~ m{(</ul>|[!\?\.])$} || $note =~ /^(\w+)\((.*)\)$/s;

  if (defined $urlOffset)
  {
    $urlOffset = ("=" . $urlOffset) unless $urlOffset =~ /^=/;
    $self->Set("url",	$key, $self->MakeGrammarURL($urlOffset, 1));
    $self->Set("linkText", $key, $linkText);
  }
  $self->Set("note", $key, $note);
}

sub GetTenseURL
{
  my($self, $tense) = @_;
  $tense =~ s/ /_/g;
  my $dest = $self->MakeGrammarURL("=Verbs=$tense");
  return $dest;
}

sub GetTenseLink
{
  my($self, $tense, $notSeparateWindow) = @_;
  my $url = $self->GetTenseURL($tense);
  my $link = "<a href=$url";
  if (!defined $notSeparateWindow || !$notSeparateWindow)
  {
    $link .= " target=$url";
  }
  $link .= ">" . $self->CookTense($tense) . "</a>";
  return $link;
}

sub GetVerbTableFn
{
  my($self, $verb) = @_;
  my $cleanedVerb = $self->CleanVerb($verb);
  if (defined $cleanedVerb)
  {
    return $self->GetLang() . "_vt_" . $cleanedVerb . ".html";
  }
  else
  {
    return undef;
  }
}

sub GetVerbTableLink
{
  my($self, $verb, $linkText, $verifyExistenceFirst) = @_;
  my $link = undef;
  my $url = $self->GetVerbTableFn($verb);
  if (defined $url)
  {
    if ($verifyExistenceFirst && ! -f "html/$url")
    {
      if (!$self->IsRecursive($verb))
      {
        my $recursiveVerb = $self->MakeRecursive($verb);
        $url = $self->GetVerbTableFn($recursiveVerb);
        if (! -f "html/$url")
        {
          $url = undef;
        }
      }
      else
      {
        $url = undef;
      }
    }
    if (defined $url)
    {
      $link = "<a href=$url target=$verb>" . $self->MeToHtml($linkText) . "</a>";
    }
  }
  if ($verifyExistenceFirst)
  {
    if (!defined $url)
    {
      warn "GetVerbTableLink($verb, $linkText, $verifyExistenceFirst): url not defined from " . cwd() . "\n";
    }
    elsif (! -f "html/$url")
    {
      warn "GetVerbTableLink($verb, $linkText, $verifyExistenceFirst): cannot find html/$url from " . cwd() . "\n";
    }
  }
  #print "GetVerbTableLink($verb, $linkText, $verifyExistenceFirst): " . nutil::ToString($link) . "\n";
  return $link;
}

sub CleanVerb
{
  my($self, $verb) = @_;
  my $cleanedVerb = $verb;
  # the following adjustments are intended to make reflexive verbs
  # sort according to their stem names, not according to the reflexive
  # pronoun
  if (!defined $verb)
  {
    warn("nutil::Warn: undef");
    return undef;
  }

  $cleanedVerb =~ s/^se (.*)/${1}_se/g;
  $cleanedVerb =~ s/^s'(.*)/${1}_s/g;
  $cleanedVerb =~ s/^sich (.*)/${1}_sich/g;
  $cleanedVerb =~ s/\W(.)/${1}_/g;
  if ($cleanedVerb =~ /\W/)
  {
    #print "CleanVerb($verb): rejected ($cleanedVerb)\n";
    return undef;
  }
  else
  {
    #print "CleanVerb($verb): $cleanedVerb\n";
    return $cleanedVerb;
  }
}

sub GetDataFile
{
  my($verb_a) = @_;

  my $dataFile = "verb_$verb_a";
  $dataFile =~ s/ /_/g;

  if (! -f "data/$dataFile")
  {
    $dataFile = undef;
  }
  return       $dataFile;
}

sub GetExercisesLink
{
  my($self, $verb_b, $dataFile, $linkText) = @_;
  if (!defined $dataFile)
  {
    my $verb_a = $self->Get_verb_a($verb_b, 1);
    if (!defined $verb_a)
    {
      return undef;
    }
    $dataFile = GetDataFile($verb_a);
  }
  my $what;
  my $exerciseType;
  if (defined $verb_b)
  {
    $what = "using the verb <i>$verb_b</i>";
    $exerciseType = "verb_selected";
  }
  else
  {
    $what = "for $dataFile";
    $what =~ s/_/ /g;
    if ($dataFile =~ /^verb_/)
    {
      $exerciseType = "verb_selected";
    }
    else
    {
      $exerciseType = "vocab_selected";
    }
  }

  if (defined $dataFile)
  {
    my $exerciseCnt = tdb::GetSize($dataFile);
    # I have a few exercises for regular verbs which stand alone.  They are not sufficient for an exercise link -- they
    # will disappoint users, I think:
    if ($exerciseCnt > 5)
    {
      return $self->CgiLink("exercises $what", $dataFile);
    }
  }
  return undef;
}

sub GetVerbURL
{
  my($self, $verb) = @_;
  my $dest = $self->MakeVerbURL($verb, 1);
  return $dest;
}

sub MakeVerbURL
{
  my($self, $verb, $silent) = @_;
  $verb =~ s{[/\^`,]}{}g;
  $verb =~ s{ }{_}g;
  my $dest = $self->MakeGrammarURL("=Verbs=$verb", $silent);
  return $dest;
}

sub CompoundFormOf
{
  my($self, $context, $verb_b, $tokens, $note) = @_;
  return $self->RawFormOf($context, $verb_b, "<i>$tokens</i> together make up ", $note);
}

sub VocabType
{
  my($self, $dataFile) = @_;
  my $typeLabel = $dataFile;
  $typeLabel = $1 if ($typeLabel =~ /^vocab_(.*)/);
  $typeLabel =~ s/_/ /g;

  return "See " . $self->GetExercisesLink(undef, $dataFile, "$typeLabel vocabulary exercises") . " to drill your $typeLabel vocabulary.";
}


sub FormOf
{
  my($self, $context, $verb_b, $note, $token) = @_;
  $token = $self->Get__currentToken() unless defined $token;
  return $self->RawFormOf($context, $verb_b, "<i>$token</i> is ", $note);
}

sub Get__currentToken
{
  my($self) = @_;
  return $__currentToken;
}

sub Set__currentToken
{
  my($self, $val) = @_;
  $__currentToken = $val;
}

# unused -- debug
sub DumpValids
{
  my($self) = @_;

  my @keys = $self->HashKeys("validGrammarURLs");
  print "DumpValids().......................................\n";
  foreach my $key (@keys)
  {
    print "valid URL: \"$key\"\n";
  }
  print "EOD\n";

}

sub VerifyURL
{
  my($self, $url, $silent) = @_;
  
  if (!defined $self->HashGet("validGrammarURLs", $url))
  {
    if (!defined $silent || !$silent)
    {
      $self->DumpValids();
      warn "nutil::Warn: where is \"$url\"?";
    }
    return undef;
  }
  return $url;
}

sub MakeGrammarURL
{
  my($self, $offset, $silent, $dontVerify) = @_;
  my $lang = $self->{"lang"};
  my $url = "$lang.html#$offset";
  if (!defined $dontVerify || !$dontVerify)
  {
    $url = $self->VerifyURL($url, $silent);
  }
  return $url;
}

sub MakeGrammarLink
{
  my($self, $linkText, $offset, $silent, $dontVerify) = @_;
  my $url = $self->MakeGrammarURL($offset, $silent, $dontVerify);
  return $self->MakeLink($linkText, $url);
}

sub MakeLink
{
  my($self, $linkText, $url) = @_;
  $linkText =~ s/'/&#39;/g;       # use &#39; instead of &apos; because IE8 does not support &apos;
  if (defined $url)
  {
    return "<a href=$url target=" . $self->{"lang"} . ">$linkText</a>";
  }
  else
  {
    return undef;
  }
}

sub CgiLink
{
  my($self, $what, $area) = @_;
  my $url = "javascript:Choose(\"$area\")";
  #print "CgiLink($what, $area)\n";
  return "<a Href='$url'>$what</a>";		# Href instead of href to stop choose.cgi from prepending path
}

sub MakeURLToSpellingChanges
{
  my($self, $context, $verbType, $verbSubtype) = @_;
  my $url;
  my $lang = $self->{"lang"};
  if ($context eq "present")
  {
    $url = $self->MakeGrammarURL("=Verbs=$verbType=${verbSubtype}_$context");
  }
  else
  {
    $url = $self->MakeGrammarURL("=Verbs=$context=${verbType}_$verbSubtype");
  }
  return $url;
}


sub VtlUpdate
{
  my($self, $key, $tense, $verb_b) = @_;
  $verb_b = $self->{"vtlUpdateVerb_b"} unless defined $verb_b;

  if (!defined $verb_b)
  {
    print "VtlUpdate($key, $tense): no verb_b\n" if $__Trace_XGen||$__Trace_Vtl;
  }
  else
  {
    # this is to rule out compound tenses, which we needn't track, since the vtl 
    # is used in a token-by-token manner:
            
    my $trailingString = $self->{"trailingString"};
    if (defined $trailingString)
    {
      # e.g., rely on 'sein' for vtl updates, not 'sein geboren'
      $key =~ s/$trailingString$//;
      $verb_b =~ s/$trailingString$//;
    }
          
    print "VtlUpdate($key, $tense, $verb_b): key=$key trailingString=" . nutil::ToString($trailingString) . "\n" if $__Trace_XGen||$__Trace_Vtl;
    if ($key !~ / /)
    {
      print "VtlUpdate($key, $tense, $verb_b): OK\n" if $__Trace_XGen||$__Trace_Vtl;
      $self->AddArrayOfArraysProp("vtl", $key, $tense, $verb_b);
    } 
    else
    {
      print "VtlUpdate($key, $tense): rejected\n" if $__Trace_XGen||$__Trace_Vtl;
    } 
  } 
}

sub VtlUpdateVetoed
{
  my($self, $verb_b) = @_;
  return 0;
}

sub VtlUpdateInitVerb
{
  my($self, $verb_b) = @_;
  return $verb_b;
}

sub VtlUpdateInit
{
  my($self, $verb_b) = @_;
  
  if (defined $self->{"vtlUpdateVerb_b"})
  {
    warn("nutil::Warn: vtlUpdateVerb_b was inappropriately set (to " . $self->{"vtlUpdateVerb_b"} . ")");
    delete ($self->{"vtlUpdateVerb_b"});
  }
  
  print "VtlUpdateInit($verb_b)\n" if $__Trace_XGen||$__Trace_Vtl;
  $verb_b = $self->VtlUpdateInitVerb($verb_b);
  my $pastParticiple_b = $self->GetPastParticiple($verb_b);
  print "VtlUpdateInit($verb_b): VtlUpdate($pastParticiple_b, 'past participle', $verb_b)\n" if $__Trace_XGen;
  $self->VtlUpdate($pastParticiple_b, "past participle", $verb_b);
  if (!$self->VtlUpdateVetoed($verb_b))
  {
    print "VtlUpdateInit($verb_b) set vtlUpdateVerb_b\n" if $__Trace_Vtl;
    $self->{"vtlUpdateVerb_b"} = $verb_b;	# overwrite previous setting
  }
}

sub GetAuxTense
{
  my($self, $id) = @_;

  my $s;
  $s = tdb::Get($id, "tense");
  $s = tdb::Get($id, "areas") if !defined $s;

  my $val = undef;
  if ($s =~ /^(.*\|)?past(\|.*)?$/)
  {
    $val = "present";
  }
  elsif ($s =~ /^(.*\|)?past_conditional(\|.*)?$/)
  {
    $val = "conditional";
  }
  elsif ($s =~ /^(.*\|)?future_perfect(\|.*)?$/)
  {
    $val = "future";
  }
  elsif ($s =~ /^(.*\|)?pluperfect(\|.*)?$/)
  {
    $val = "imperfect";
  }
  elsif ($s =~ /^(.*\|)?past subjunctive(\|.*)?$/)
  {
    $val = "subjunctive";
  }
  elsif ($s =~ /^(.*\|)?(past)(\|.*)?$/)
  {
    $val = "present";
  }
  print "GetAuxTense($id): $s => " . nutil::ToString($val) . "\n" if $__Trace_MassageAndFootnote;
  return $val;
}

sub ResolveVtlLookupAmbiguity_preferTense
{
  my($self, $vtlVal, $preferredTense, $otherTense) = @_;
  if ($vtlVal->Size()==2)
  {
    my $context0 = $vtlVal->Get(0, 0);
    my $context1 = $vtlVal->Get(1, 0);
    if ($context0 eq $otherTense && $context1 eq $preferredTense)
    {
      $vtlVal->Delete(0);
    }
    if ($context0 eq $preferredTense && $context1 eq $otherTense)
    {
      $vtlVal->Delete(1);
    }
  }
}

sub ResolveVtlLookupAmbiguity
{
  my($self, $token, $vtlVal, $areas, $id) = @_;
  $self->ResolveVtlLookupAmbiguity_preferTense($vtlVal, "imperative", "present");
}

sub SupportsTense
{
  my($self, $tense) = @_;
  my $val;
  if (!defined $self->{"supportedTenses"})
  {
    my $tenses = $self->GetTenses();
    my %h = ();
    foreach my $tense (@$tenses)
    {
      $h{$tense} = 1;
    }
    $self->{"supportedTenses"} = \%h;
  }

  $val = $self->{"supportedTenses"}->{$tense};
  $val = (defined $val && $val);

  #print "SupportsTense($tense): $val\n";
  return $val;
}


sub VtlOverride
{
  my($self, $token, $id, $context, $verb_b, $possiblyAmbiguous) = @_;
  print "VtlOverride($token, $id, $context, $verb_b, $possiblyAmbiguous)\n" if $__Trace_MassageAndFootnote;
  tdb::Set($id, "vtlOverrides#$token", "$context#$verb_b#$possiblyAmbiguous");
}

sub GetAreas
{
  my($self, $id) = @_;
  return tdb::Get($id, "areas");
}

sub VtlLookup
{
  my($self, $rawToken, $id, $expectedContext) = @_;

  die "VtlLookup($rawToken, $id, $expectedContext)" unless defined $rawToken;
  my $possiblyAmbiguous = 0;
  my $context = undef;
  my    $verb = undef;

  my $token = grammar::NormalizeToken($rawToken);
  if ($token ne $rawToken)
  {
    print "VtlLookup($rawToken, $id): would have become $token\n" if $__Trace_MassageAndFootnote;
    $token = $rawToken;	# German requires that we not do normalize here, thus losing case
  }

  my $tmp = tdb::Get($id, "vtlOverrides#$token");
  if (defined $tmp)
  {
    ($context, $verb, $possiblyAmbiguous) = split(/#/, $tmp);
    print "VtlLookup($token, $id): overridden: $context, $verb, $possiblyAmbiguous\n" if $__Trace_MassageAndFootnote;
    return ($context, $verb, $possiblyAmbiguous);
  }

  # the structure: each array corresponds to a different meaning for $token.
  # each array consists of $context and $verb.
  my $rawVtlVal = $self->GetByLang("vtl", $token);
  print "VtlLookup($token, $id, " . nutil::ToString($expectedContext) . "): initial: " . nutil::ToString($rawVtlVal) . "\n" if $__Trace_MassageAndFootnote;

  if (defined $rawVtlVal)
  {
    my $vtlVal = new arrayOfArrays($rawVtlVal);

    my $areas = $self->GetAreas($id);
    my $tense = tdb::Get($id, "tense");

    if (defined $expectedContext)
    {
      $vtlVal->GrepEq(0, $expectedContext, 1);
      print "	post conformance to $expectedContext: ", $vtlVal->ToString(), "\n" if $__Trace_MassageAndFootnote;
    }
    if ($vtlVal->Size() > 0)
    {
      if (defined $areas && ($areas !~ /\|mix\|/))
      {
	my $tenseAnAuxiliaryVerbWouldHave = $self->GetAuxTense($id);
	if (($areas =~ /\|past/) || ($areas =~ /\|future_perfect/) ||($areas =~ /\|pluperfect/))
	{
	  # if the stmt is past tense, don't prune past participles...
	  if (defined $tense && ($tense eq "preterite") && $self->SupportsTense("preterite"))
	  {
	    # ...UNLESS this is a preterite exercise, and we're
	    # processing a lang which supports the preterite -- in this case, the p.p. is definitely not wanted.
	  }
	  else
	  {
	    $areas .= "past participle|";
	  }
	}
	
	if ($vtlVal->GrepForPropVal(0, $areas))
	{
	  print "VtlLookup: there were still some hits after pruning w/ no account of aux\n" if $__Trace_MassageAndFootnote;
	  $vtlVal->GrepForPropVal(0, $areas, 1);
	}
	elsif (defined $tenseAnAuxiliaryVerbWouldHave)
	{
	  print "VtlLookup: no hits after pruning w/ no account of aux; adding $tenseAnAuxiliaryVerbWouldHave\n" if $__Trace_MassageAndFootnote;
	  $areas .= $tenseAnAuxiliaryVerbWouldHave . "|";
	  # the risk here is that this will let non-auxiliary verbs w/ $tenseAnAuxiliaryVerbWouldHave sneak thru...
	  $vtlVal->GrepForPropVal(0, $areas, 1);
	}
	else
	{
	  $vtlVal->Clear();
	}
	print "	post prune ($areas): ", $vtlVal->ToString(), "\n" if $__Trace_MassageAndFootnote;
      }
    }
            
    if ($vtlVal->Size() > 1)
    {
      my $isRecursive = $self->LooksLikeRecursiveUse($rawToken, tdb::GetText($id, $self->{"lang"}));
      $self->PruneVerbsByRecursiveness($vtlVal, !$isRecursive);
      if ($__Trace_MassageAndFootnote)
      {
	print "	post PruneVerbsByRecursiveness(", ($isRecursive ? "include only recursive" : "exclude recursive");
	print "): ", $vtlVal->ToString(), "\n" 
      }
    }
                
    if ($vtlVal->Size() > 1)
    {
      $self->PruneVerbsByVerb_a($vtlVal, $id);
      print "	post PruneVerbsByVerb_a(): ", $vtlVal->ToString(), "\n" if $__Trace_MassageAndFootnote;
    }
                
    if ($vtlVal->Size() > 1)
    {
      $self->ResolveVtlLookupAmbiguity($token, $vtlVal, $areas, $id); 
      print "	post ResolveVtlLookupAmbiguity: ", $vtlVal->ToString(), "\n" if $__Trace_MassageAndFootnote;
    }
    if ($vtlVal->Size() > 0)
    {
      if ($vtlVal->Size() > 1)
      {
	$possiblyAmbiguous = "alternative: " . $vtlVal->ToString();
	$possiblyAmbiguous = "$id: $possiblyAmbiguous" if defined $id;
      } 
      print "	post all: ", $vtlVal->ToString(), "\n" if $__Trace_MassageAndFootnote;
                    
      $context = $vtlVal->Get(0, 0);
      $verb    = $vtlVal->Get(0, 1);
    }
  }
  if ($__Trace_MassageAndFootnote)
  {
    print "...VtlLookup($rawToken, $id): ";
    if (defined $context)
    {
      die "context" unless defined $context;
      die "verb" unless defined $verb;
      die "possiblyAmbiguous" unless defined $possiblyAmbiguous;
      
      print "($context, $verb, $possiblyAmbiguous)\n" 
    }
    else
    {
      print "undef\n";
    }
  }
  return ($context, $verb, $possiblyAmbiguous);
}

sub VtlUpdateCleanup
{
  my($self) = @_;
  delete($self->{"vtlUpdateVerb_b"});
}
 
sub AddArrayOfArraysProp
{
  my($self, $phylum, $key, @vals) = @_;
  return unless defined $key;
  	
  my $dataKey = $self->MakeDataKeyByLang($phylum);
  
  my $oldSet = tdb::Get($dataKey, $key);
  my $newVal = arrayOfArrays::UpdateSetIfNecessary($oldSet, @vals);
  if ($newVal)
  {
    #print "AddArrayOfArraysProp calling tdb::Set($dataKey, $key, $newVal)\n"; 
    tdb::Set($dataKey, $key, $newVal); 
  }
}

sub UniversalKey
{
  my($self) = @_;
  return $self->UniversalFileKey() . ".0";
}

sub Set
{
  my($self, $phylum, $key, $val) = @_;
  die "bad $phylum, $key, $val" unless defined $phylum && defined $key;
  tdb::Set($self->UniversalKey(), "$key/$phylum", $val);
}

sub Get
{
  my($self, $phylum, $key) = @_;
  die $phylum unless defined $key;
  
  my $val = tdb::Get($self->UniversalKey(), "$key/$phylum");
  return $val;
}

sub MakeDataKeyByLang
{
  my($self, $phylum) = @_;
  return "_" . $self->{"lang"} . "_" . $phylum . ".0";
}

sub SetByLang
{
  my($self, $phylum, $key, $val) = @_;
  tdb::Set($self->MakeDataKeyByLang($phylum), $key, $val);
}

sub GetByLang
{
  my($self, $phylum, $key) = @_;
  return tdb::Get($self->MakeDataKeyByLang($phylum), $key);
}


sub RmGeneratedData
{
  my($self) = @_;
  #  foreach my $key (tdb::Keys($self->UniversalKey()))
  #  {
  #    if (IsTransientKey($key))
  #    {
  #      $self->Set($key, undef);
  #    }
  #  }
  #tdb::Clear($self->UniversalFileKey());   # we need the data to build up across languages
}

sub UniversalFileKey
{
  my($self) = @_;
  return "_grammar";
}

my @__dataFromGetAllDataFiles = ();
my @__dataFromGetAllDataOutputFiles = ();
my @__dataFromGetAllExerciseAreas = ();

sub GetAllExerciseAreas
{
  return @__dataFromGetAllExerciseAreas if @__dataFromGetAllExerciseAreas;

  GetAllDataFiles();
  for (my $j = 0; $j < scalar(@__dataFromGetAllDataFiles); $j++)
  {
    my $fn = $__dataFromGetAllDataFiles[$j];
    next unless $fn =~ /^(base|verb|vocab)/;
    print "GetAllExerciseAreas() pushing $fn\n" if $__Trace_XGen;
    push(@__dataFromGetAllExerciseAreas, $fn);
  }
  #Ndmp::Ah("__dataFromGetAllExerciseAreas", @__dataFromGetAllExerciseAreas);
  return @__dataFromGetAllExerciseAreas;
}

sub GetAllDataFiles
{
  return @__dataFromGetAllDataFiles if @__dataFromGetAllDataFiles;

  my $d = new DirHandle "data";
  die "no data dir" unless (defined $d);
  @__dataFromGetAllDataFiles = ();
  while (defined($_ = $d->read))
  {
    my $fn = $_;
    next if $fn =~ /^_/;
    next if $fn =~ /^\./;
    push(@__dataFromGetAllDataFiles, $fn);
  }
  #Ndmp::Ah("__dataFromGetAllDataFiles", @__dataFromGetAllDataFiles);
  undef $d;
  return @__dataFromGetAllDataFiles;
}

sub GetAllDataOutputFiles # unused
{
  return @__dataFromGetAllDataOutputFiles if @__dataFromGetAllDataOutputFiles;

  my $d = new DirHandle "data";
  die "no data dir" unless (defined $d);
  @__dataFromGetAllDataOutputFiles = ();
  while (defined($_ = $d->read))
  {
    my $fn = $_;
    next unless $fn =~ /^out_/;
    push(@__dataFromGetAllDataOutputFiles, $fn);
  }
  undef $d;
  return @__dataFromGetAllDataOutputFiles;
}

sub GetTokens
{
  my($id, $category) = @_;
  my $text = tdb::GetTextOrwarn($id, $category);
          	 
  $text = "zeroth_token_not_used " . $text;
  return split(" ", $text);
} 


sub IsModifiedPastParticiple
{
  my($self, $token, $id) = @_;
  return 0;
}

sub FoundCompoundTense
{
  my($self, $notesByVerbRef, $verb, $token, $id, $possiblyAmbiguous, $context) = @_;

  print "FoundCompoundTense($verb, $token, $id, $possiblyAmbiguous, $context)\n" if $__Trace_MassageAndFootnote;
  if (($context eq "past participle")
  ||  ($context eq "possible past participle"))
  {
    foreach my $auxiliaryVerb ($self->GetAuxiliaryVerbs())
    {
      print "Cking aux $auxiliaryVerb\n" if $__Trace_MassageAndFootnote;
      #Ndmp::Hh( , %$notesByVerbRef);
      my $ref = $notesByVerbRef->{$auxiliaryVerb};
      next unless defined $ref;
      my($auxiliaryToken, $dummy, $auxiliaryContext, $dummy2) = @$ref;
      print "Aux use: $auxiliaryToken, $auxiliaryContext, $dummy\n" if $__Trace_MassageAndFootnote;

      $context = $self->Pastify($auxiliaryContext);
      if (defined $context)
      {
	$self->UnproposeVerbTenseNote($auxiliaryVerb, $auxiliaryToken);
	my $compoundTenseToken;

	if ($self->IsModifiedPastParticiple($token, $id))
	{
	  # yes, I know using $token for arg #2 below ($verb) is a little weird, but if I don't,
	  # then it will conflict w/ the compound tense note
	  $self->ProposeModifiedPastParticipleNote( $token, $token);
	  $compoundTenseToken = $auxiliaryToken;
	}
	else
	{
	  $compoundTenseToken = $token;
	}
	return [$verb,$compoundTenseToken,$context, "CompoundFormOf(\"$context\", \"$verb\", \"$auxiliaryToken $token\")"];
      }
    }
  }
  return undef;
}

sub ProposeModifiedPastParticipleNote
{
  my($self, $verb, $token) = @_;
  $self->ProposeVerbTenseNote($verb, $token, 0, "past participle", "PastParticipleMustAgreeWithSubject(undef)", undef);

}

sub ProcessingLastToken
{
  my($self) = @_;
  my $val = ($__proposeNotesTokensCurrent == (scalar(@__proposeNotesTokens) - 1));
  #print "ProcessingLastToken(): $val\n";
  return $val;
}

sub SuppressTo
{
  my($self, $verb_a) = @_;
  if ($verb_a =~ /^(can)$/)
  {
    return 1;
  }
  return 0;
}

sub Get_vt_init_call
{
  my($self, $verb_b, $doingVerbTable) = @_;

  my $paradigmVerb = $self->GetVerbThatThisOneIsPatternedAfter($verb_b);
  my $verb_a = $self->Get_verb_a($verb_b);
  my $possibleTo = $self->SuppressTo($verb_a);

  my $paradigm_verb_in_html;
  my $paradigm_verb_cleaned_for_href;
  if (defined $paradigmVerb)
  {
    $paradigm_verb_in_html = $self->MeToHtml($paradigmVerb);
    $paradigm_verb_cleaned_for_href = "\"" . $self->CleanVerb($paradigmVerb) . "\"";
    if ($paradigm_verb_cleaned_for_href ne $paradigm_verb_in_html)
    {
      $paradigm_verb_in_html = "\"$paradigm_verb_in_html\"";
    }
    else
    {
      $paradigm_verb_in_html = "null";
    }
  }
  else
  {
    $paradigm_verb_cleaned_for_href = "null";
    $paradigm_verb_in_html          = "null";
  }
  $paradigmVerb = undef;	# shouldn't need this anymore

  my $reflexive_b = $self->IsRecursive($verb_b);
  $reflexive_b = ($reflexive_b ? "1" : "0");

  $possibleTo = "null" if !$possibleTo;
  $reflexive_b = "null" if !$reflexive_b;
  
  my $s = "vti_init(\"" . $self->GetLang() . "\","
  . "\"" . $self->MeToHtml($verb_b) . "\","
  . "\"$verb_a\","
  . $reflexive_b;

  my $noDocTitle;
  if (defined $doingVerbTable)
  {
    $noDocTitle = "null";
  }
  else
  {
    $noDocTitle = 1;
  }

  $s .= ",$paradigm_verb_in_html,$paradigm_verb_cleaned_for_href,$possibleTo,$noDocTitle";
  $s =~ s/(,null)*$//;		# drop null trailing args for js
  $s .= ")\n";
  return $s;
}

sub MassageAndFootnoteGetToken
{
  my($self, $offsetFromCurrent) = @_;	# 0 gets current, -1 gets previous, -2 gets one before that...
  my $val = "";
  my $n = $__proposeNotesTokensCurrent + $offsetFromCurrent;
  if ($#__proposeNotesTokens >= $n
  && $n > 0)
  {
    $val = $__proposeNotesTokens[$n];
  }
  #print "MassageAndFootnoteGetToken($offsetFromCurrent): $val\n";
  return $val;
}

sub MassageAndFootnoteNormalizeToken
{
  my($self, $token) = @_;

  my $normalizedToken;
  if (($self->{"lang"} eq "German") && (scalar(@__proposeNotesTokens) > 0))
  {
    # case matters in German; normally the first word is just capitalized because
    # it begins this sentence, but in other cases we should preserve case to avoid
    # confusion between verbs and nouns (e.g., die Reise v. er reise), etc.:
    $normalizedToken = $token;
  }
  else
  {
    $normalizedToken = grammar::MakeLowerCase($token);
  }

  #print "MassageAndFootnoteNormalizeToken($token): $normalizedToken\n";
  return $normalizedToken;
}

sub IsContraction
{
  my($self, $normalizedToken) = @_;
  return defined $self->HashGet("contractions", $normalizedToken);
}

sub ExplainBiNoun
{
  my($self, %differentVersions) = @_;
  my $s = "";
  foreach my $determiner (keys %differentVersions)
  {
    $s .= "; " if defined $s;
    $s .= "<i>$determiner " . $__currentToken . "</i> means <i>" . $differentVersions{$determiner} . "</i>";
  }
  $s .= ".";
  return $s;
}

sub ExplainContraction_getNoteText
{
  my($self, $normalizedToken, $token) = @_;
  $token = $normalizedToken unless defined $token;
  my $componentWords = $self->HashGet("contractions", $normalizedToken);
  my $note = undef;
  if ($componentWords =~ m{^(\S+) (\S+)$})
  {
    my $lang = $self->{"lang"};
    my $componentWord1 = $1;
    my $componentWord2 = $2;
    $note = "<i>$token</i> is a " . $self->MakeGrammarLink("contraction", "=Contractions") . " of <i>"
    . $self->Cook($componentWord1) . "</i> and <i>"
    . $self->Cook($componentWord2) . "</i>.";
  }
  else
  {
    die $componentWords;
  }
  #print "ExplainContraction_getNoteText($normalizedToken, $token): $note\n";
  return $note;
}

sub AutoNotedToken
{
  my($self, $normalizedToken) = @_;
  return defined $self->HashGet("autoNotedTokens", $normalizedToken);
}

sub AutoNote
{
  my($self, $pattern, $note) = @_;
  if ($pattern =~ / /)	# e.g., there are multiple tokens in $pattern
  {
    $self->HashPut("autoNotedPhrases", $pattern, $note);
  }
  else
  {
    $self->HashPut("autoNotedTokens", $pattern, $note);
  }
  return undef;
}

sub ApplyAutoNote
{
  my($self, $pattern, $token) = @_;
  my $note;
  if ($pattern =~ / (\S+)/)	# e.g., there are multiple tokens in $pattern
  {
    $token = $1 unless defined $token;
    $note = $self->HashGet("autoNotedPhrases", $pattern);
  }
  else
  {
    $token = $pattern unless defined $token;
    $note = $self->HashGet("autoNotedTokens", $pattern);
  }
  $self->ProposeLangNote($token, undef, 0, undef, $note);
}

sub CheckForAutoNotedPhrases
{
  my($self, $text) = @_;
  foreach my $phrase ($self->HashKeys("autoNotedPhrases"))
  {
    if ($text =~ /\b$phrase\b/i)
    {
      $self->ApplyAutoNote($phrase);
    }
  }
}

sub MassageAndFootnoteForOneToken
{
  my($self, $token, $normalizedToken, $id, $expectedVerbCnt, $notesByVerbRef, $thisTokenIsPermanentlyIdentified) = @_;
            
  if (!$thisTokenIsPermanentlyIdentified)
  {
    if ($self->AutoNotedToken($normalizedToken))
    {
      $self->ApplyAutoNote($normalizedToken, $token);
    }
  }
  my($context, $verb, $possiblyAmbiguous) = $self->VtlLookup($normalizedToken, $id);

  if ((!defined $context) || (($__verbHits==1) && ($expectedVerbCnt==1)))
  {
    my $unmodifiedPastParticiple = $self->LooksLikeAModifiedPastParticiple($token, $id);
    if ($unmodifiedPastParticiple)
    {
      my($context2, $verb2, $possiblyAmbiguous2) = $self->VtlLookup($unmodifiedPastParticiple, $id, "past participle");
      if (defined $context2)
      {
	$context = "possible past participle";
	$verb = $verb2;
	$possiblyAmbiguous = 0; 
      }
    }
  }
                                        
  if (defined $context)
  {
    my $ref = $self->FoundCompoundTense(\%__notesByVerb, $verb, $token, $id, $possiblyAmbiguous, $context);
    # need to call FoundCompoundTense (above) before checking $thisTokenIsPermanentlyIdentified (below)
    # because I rely on FoundCompoundTense to eliminate initial notes for the auxiliary verbs
    # if they are part of a compound verb.  This has to be done even if $thisTokenIsPermanentlyIdentified
    # tells us then to leave w/out proposing any further verb-identifying notes.
    if ($thisTokenIsPermanentlyIdentified)
    {
      print "MassageAndFootnoteForOneToken exiting since thisTokenIsPermanentlyIdentified\n" if $__Trace_MassageAndFootnote;
      return;
    }
    if (defined $ref)
    {
      my($compoundTenseVerb, $compoundTenseToken, $compoundTenseContext, $compoundTenseNote) = @$ref;
      $self->ProposeVerbTenseNote($compoundTenseVerb, $compoundTenseToken, 0, $compoundTenseContext, $compoundTenseNote, $id);
      #($verb, $compoundTenseToken, 0, $context, "CompoundFormOf...", $id);
    }
    else
    {
      return if ($context eq "possible past participle");
      return if ($context eq          "past participle");
                  
      $self->ProposeVerbTenseNote($verb, $token, $possiblyAmbiguous, $context, undef, $id);
    }
  }
}

sub AddExpectedVerbCounts
{
  my($expectedVerbCnt1, $expectedVerbCnt2) = @_;
  return $expectedVerbCnt1 unless defined $expectedVerbCnt2;
  return $expectedVerbCnt2 unless defined $expectedVerbCnt1;
  return -1 if $expectedVerbCnt1==-1;	# unknown + n = unknown
  return -1 if $expectedVerbCnt2==-1;	# n + unknown = unknown
  return $expectedVerbCnt1 + $expectedVerbCnt2;
}

sub GetExpectedVerbCount
{
  my($self, $id) = @_;
  my $expectedVerbCnt = tdb::Get($id, "expectedVerbCnt");
  $expectedVerbCnt = 1 unless defined $expectedVerbCnt;			# dft is 1 in exercises
      
  my $addendId = tdb::Get($id, "addendKey");
  if (defined $addendId)
  {
    my $addendExpectedVerbCnt = tdb::Get($addendId, "expectedVerbCnt");
    if (defined $addendExpectedVerbCnt)
    {
      $addendExpectedVerbCnt = 0 unless defined $addendExpectedVerbCnt;	# dft is 0 in addends
      $expectedVerbCnt = AddExpectedVerbCounts($expectedVerbCnt, $addendExpectedVerbCnt);
    }
    #print "GetExpectedVerbCount($id): $expectedVerbCnt\n";
  }
  return $expectedVerbCnt;
}

sub DetectDanglingNotes
{
  my($self, $id, $tokensRef) = @_; 
  my $lang = $self->{"lang"};
  my $hashForThisExercise = tdb::GetHash($id);
      
  if (tdb::IsPropSet($id, "areas", "preterite"))
  {
    my $tense = tdb::Get($id, "tense");
    if (!defined $tense)
    {
      if ($id =~ /^verb_/)
      {
	warn "$id: undefined tense";
      } 
    }
    else
    {
      if ($tense eq "past")
      {
	warn "teacher::$self->DetectDanglingNotes($id, $lang): preterite v. past problem; fixing...";
	tdb::SetProp($id, "areas", "preterite", 0);
	tdb::Save();
      }
      else
      {
	#print "$self->DetectDanglingNotes($id, $lang, $tokensRef): not past: " . tdb::Get($id, "tense") . "\n";
      } 
    } 
  }
  else
  {
    #print "$self->DetectDanglingNotes($id, $lang, $tokensRef): OK: \n";
  }
    
  my %hashForThisExercise2 = %$hashForThisExercise;
    
  my $key = ndb::MakeShadedKey("${lang}_note#", $lang);	# general note for the exercise
  #print "$self->DetectDanglingNotes($id): deleting $key\n";
  delete($hashForThisExercise2{$key});
        
  for (my $tokenIndex = 1; $tokenIndex < scalar(@$tokensRef); $tokenIndex++)
  {
    my $tokenKey = $tokensRef->[$tokenIndex];
                    
    $key = ndb::MakeShadedKey("${lang}_note#$tokenIndex", $lang);
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
        
    my $suppressKey = "suppress_$key";
    #print "$self->DetectDanglingNotes($id): deleting $suppressKey\n";
    delete($hashForThisExercise2{$suppressKey});
                          
    $key = $self->MakeTokenNoteKey($tokenKey);
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
                    
    $key = $self->MakeTokenNoteKey($tokenKey, "2");		# secondary notes
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
                    
    $suppressKey = "suppress_$key";
    #print "$self->DetectDanglingNotes($id): deleting $suppressKey\n";
    delete($hashForThisExercise2{$suppressKey});
                          
    $key = $self->MakeTokenNoteKey($tokenKey, "tmp");
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
                          
    $key = $self->MakeTokenNoteKey(undef);
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
                          
    $key = $self->MakeTokenNoteKey(undef, "tmp");
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
                          
    $key = $self->MakeTokenNoteKey(undef, "2");
    #print "$self->DetectDanglingNotes($id): deleting $key\n";
    delete($hashForThisExercise2{$key});
  }
  foreach my $key (keys %hashForThisExercise2)
  {
    if ($key =~ /^${lang}_note#/)
    {
      $key =~ s/\\/\\\\/g;
      print "$id: unattached note: teacher.ini: tdb::Set(\"$id\", \"$key\", undef);\n";
    }
  }
}
    



sub PrepareTokens_andLookForDanglers_andVerifyMap
{
  my($self, $id, $lang) = @_;

  my @tokens = generic_grammar::GetTokens($id, $lang);
  for (my $k = 1; $k < scalar(@tokens); $k++)
  {
    my $token = $tokens[$k];
    $token = $self->MakeIntoNoteKey($token);
    my $normalizedToken = $self->MassageAndFootnoteNormalizeToken($token);

    $__proposeNotesTokens[$k] = $token;
    $__proposeNotesNormalizedTokens[$k] = $normalizedToken;
  }

  # map stuff:
  #
  #my $mapRef = tdb::Get($id, "map/$lang");
  #if (defined $mapRef)
  #{
  ## tokens -1 because 0th elt is unused
  #if (scalar(@$mapRef) != (scalar(@tokens)-1))
  #{
  #print "$id: $lang: map size mismatch: " . scalar(@$mapRef) . " != " . (scalar(@tokens)-1) . ": teacher.ini: tdb::Set(\"$id\", \"map/$lang\", undef);\n";
  #}
  #}

  $self->DetectDanglingNotes($id, \@__proposeNotesTokens);
  return $#__proposeNotesTokens;
}

sub MassageAndFootnoteForOneExercise
{
  my($self, $id) = @_;
  #print "MassageAndFootnoteForOneExercise($id)\n"; # if ($__Trace_MassageAndFootnote);

  my $lang = $self->GetLang();
  die "bad $id" if (!defined tdb::Get($id, 'id'));

  my $text = tdb::Get($id, $lang);

  return 0 if (!defined $text);

  $self->ClearMostRecentVerbNoted();
  %__notesByVerb = ();
  %__notesByToken = ();
  @__proposeNotesTokens = ();
  $__verbHits = 0;

  my $expectedVerbCnt = $self->GetExpectedVerbCount($id);

  my $tokenCount = $self->PrepareTokens_andLookForDanglers_andVerifyMap($id, $lang);
  for ($__proposeNotesTokensCurrent = 1; $__proposeNotesTokensCurrent <= $tokenCount; $__proposeNotesTokensCurrent++)
  {
    my           $token = $__proposeNotesTokens[$__proposeNotesTokensCurrent];
    my $normalizedToken = $__proposeNotesNormalizedTokens[$__proposeNotesTokensCurrent];

    $__thisTokenIsPermanentlyIdentified = $self->PermanentNoteAlreadyInPlace($id, $token, $__proposeNotesTokensCurrent);

    print "_____" . ($__thisTokenIsPermanentlyIdentified ? ">":"_") . "${normalizedToken}_______________________________________________________________________________________($__verbHits)\n" if $__Trace_MassageAndFootnote;

    next if ($self->TmpNoteShouldBeSuppressed($id, $__proposeNotesTokensCurrent, $token));
    $self->MassageAndFootnoteForOneToken($token, $normalizedToken, $id, $expectedVerbCnt, \%__notesByVerb, $__thisTokenIsPermanentlyIdentified);
  }
  $__proposeNotesTokensCurrent = undef;

  if ($expectedVerbCnt != -1)
  {
    if ($__verbHits != $expectedVerbCnt)
    {
      if (!$__verbHits)
      {
	if ($id !~ /^vocab/)
	{
	  if ($self->{"lang"} eq "German"
	  && $id =~ /^base/)
	  {
	    warn "ignoring German bass exercises which have unidentified verbs" if  $__Trace_MassageAndFootnote;
	  }
	  else
	  {
	    print "$id: $lang: no verb identified: >>$text<<\n";
	  }
	}
      }
      else
      {
	print "$id: $lang: expected $expectedVerbCnt verbs, but saw $__verbHits\n";
      }
    }
  }
  $self->CheckForAutoNotedPhrases($text);
  return $self->PrintNoteRecommendations($id, $text);
}

sub UnproposeVerbTenseNote
{
  my($self, $verb, $token) = @_;
  delete $__notesByVerb{$verb};
  $self->UnproposeLangNote($token);
  $__mostRecentVerbNoted = undef;
  $__verbHits--;
  print "UnproposeVerbTenseNote($verb, $token): ($__verbHits)\n" if $__Trace_MassageAndFootnote;
}

sub ProposeLangNote
{
  my($self, $token, $verb, $possiblyAmbiguous, $context, $note) = @_;
  print "ProposeLangNote($token, " . nutil::ToString($verb) . ", $possiblyAmbiguous, " . nutil::ToString($context) . ", $note)\n" if $__Trace_MassageAndFootnote;
  $__notesByToken{$token} = [$verb,  $possiblyAmbiguous, $context, $note];
  return 1;
}

sub UnproposeLangNote
{
  my($self, $token) = @_;
  delete $__notesByToken{$token};
}

sub MakeIntoNoteKey
{
  my($self, $token) = @_;

  my $val = $token;

  my $trailingDeletion = 0;
  if ($val =~ /(.*)(\^D)$/)
  {
    $trailingDeletion = 1;
    $val = $1;
  }

  my $trailingQuoteOrHyphen = 0;
  if ($val =~ /(.*)([-'])$/)	# I do this to avoid superscripts following the quote
  {
    $trailingQuoteOrHyphen = $2;
    $val = $1;
  }

  my $tokenKey = grammar::StripPunctuation($val);

  #print "teacher::ProcessToken($token): $tokenKey, $trailingDeletion, $trailingQuoteOrHyphen, $htmlToken\n";
  if (wantarray)
  {
    my $htmlToken = $self->MeToHtml($val);
    return($tokenKey, $trailingDeletion, $trailingQuoteOrHyphen, $htmlToken);
  }
  else
  {
    return $tokenKey;
  }
}

sub SetTenseAreaIfNeeded
{
  my($self, $id, $context, $execute, $token) = @_;
  if (($context eq "past participle")	# not tracking them...
  || tdb::IsPropSet($id, "areas", $context))
  {
    return;
  }
  else
  {
    my $areas = tdb::Get($id, "areas");
    if (!tdb::IsPropSet($id, "areas", "mix"))
    {
      if ((defined $areas)
      && !(($context eq "past")      && tdb::IsPropSet($id, "areas", "preterite"))
      && !(($context eq "preterite") && tdb::IsPropSet($id, "areas", "past"))) 
      {
	print "was tempted to add $context to $areas for $id\n" if $__Trace_MassageAndFootnote;
      }
      else
      {
	print "tdb::SetProp(\"$id\", \"areas\", \"$context\");\n";
	if ($execute)
	{
	  tdb::SetProp($id, "areas", $context);
	} 
      } 
    } 
  } 
}

sub PrintNoteRecommendations
{
  my($self, $id, $text) = @_; 
  my $ambiguousCount = 0;
  my $lang = $self->GetLang();
  print "===============================================================================\n" if $__Trace_MassageAndFootnote;
  foreach my $token (keys %__notesByToken)
  {
    my $ref = $__notesByToken{$token};
    my($verb_unused, $possiblyAmbiguous, $context, $note) = @$ref;
                                          
    if ($possiblyAmbiguous)
    { 
      my $areas = tdb::Get($id, "areas");
      $areas = "undef" unless defined $areas;
            
      # I stick an alternative tense in $possiblyAmbiguous, if there is one
      my $key = $self->MakeTokenNoteKey($token);
      print "\n$id: tdb::Set('$id', '$key', '$note');\n";	# manual, so permanent
      print "$possiblyAmbiguous\n" unless $possiblyAmbiguous eq "#";
      print "# $id: $lang: $text $areas\n" if (keys %__notesByVerb);
      $self->SetTenseAreaIfNeeded($id, $context, 0, $token) if defined $areas;
      
      $ambiguousCount++;
    }
    else
    {
      $self->SetNote($id, $token, $note);
    } 
  } 
  print "===============================================================================\n" if $__Trace_MassageAndFootnote;
  return $ambiguousCount;
}

sub GetVerbaDataFile
{
  my($required) = @_;
  my $dataFile = Argv_db::FlagArg("verb_a", $required);
  if (defined $dataFile)
  {
    if ($dataFile !~ /^(base|vocab_.*)$/)
    {
      $dataFile = "verb_" . $dataFile;
    }
  } 
  return $dataFile;
}


sub MassageAndFootnote
{
  my($self) = @_;
  #print "$self.MassageAndFootnote()...\n";
  $__MassageAndFootnoteCalled = 1;
  
  #warn "skipping MassageAndFootnote()..."; return;
                    
  if (Argv_db::FlagSet("MassageAndFootnoteDebug"))
  {
    $__Trace_MassageAndFootnote = 0;        
  }
    
  my @allDataFiles;
  $allDataFiles[0] = GetVerbaDataFile(0);
  my $genId = undef;
  if (!defined $allDataFiles[0])
  {
    @allDataFiles = generic_grammar::GetAllExerciseAreas();
  }
  else
  {
    my $max = tdb::GetSize($allDataFiles[0]) - 1;
    $genId = Argv_db::FlagArg("genId");
    if (defined $genId && $genId > $max)
    {
      $genId = undef;
    }
  } 
  
  my $ambiguousCount = 0;
  foreach my $dataFile (@allDataFiles)
  {
    print "_";	# signal progress
    tdb::CleanseTransients($self->GetLang(), $dataFile);
    my $min;
    my $max = tdb::GetSize($dataFile) - 1;
    if (defined $genId)
    {
      warn("nutil::Warn: $max < $genId") if $max < $genId;
      $max = $min = $genId;
    }
    else
    {
      $min = 0;
    } 
    for (my $idNumber = $min; $idNumber <= $max; $idNumber++)
    {
      my $id = "$dataFile.$idNumber"; 
                                    
      tdb::Set($id, 'id', $idNumber);
      if (defined tdb::Get($id, '?'))
      {
	print "$id: " . $self->GetLang() . ": skipping an outstanding issue that I am aware of\n";
	next;
      }
      tdb::V($__Trace_MassageAndFootnote);	# so we can see what's going on if we are debugging
      #print "$id: " . $self->GetLang() . ": MassageAndFootnote...\n";
      $self->UnifyCharacteristicsOfObjectPhrasesForOneExercise($id);
      tdb::V(0);
            
      $ambiguousCount += $self->MassageAndFootnoteForOneExercise($id);
    }
    tdb::Close1($dataFile);
  }
  print "\n";
  print "$self->MassageAndFootnote: ambiguous cases requiring manual evaluation: $ambiguousCount\n" if $ambiguousCount;
  tdb::Save();
}


sub PermanentNoteAlreadyInPlace
{
  my($self, $id, $token, $tokenIndex) = @_;
                        
  my $lang = $self->{"lang"};
  my $key = $self->MakeTokenNoteKey($token);
                        
  my $permanentNote = tdb::Get($id, $key, "addendKey");
  my $verbHit = (defined $permanentNote && $permanentNote =~ /CombinedSeparatedVerb|FormOf/);
            
  #print "PermanentNoteAlreadyInPlace($id, $token): $key => " . nutil::ToString($permanentNote) . ")\n";
            
  if (!$verbHit)
  {
    $key = ndb::MakeShadedKey("${lang}_note#$tokenIndex", $lang);
    my $permanentNoteByTokenIndex = tdb::Get($id, $key);
    if (defined $permanentNoteByTokenIndex)
    {
      $verbHit = ($permanentNoteByTokenIndex =~ /CombinedSeparatedVerb|FormOf/);
      if (!defined $permanentNote)
      {
	$permanentNote = $permanentNoteByTokenIndex;
      } 
    }
  }
  
  if ($verbHit)
  {
    $__verbHits++;
    #print "PermanentNoteAlreadyInPlace($id, $token, $tokenIndex): ($__verbHits)\n";
  }
  return defined $permanentNote;
}

sub TmpNoteShouldBeSuppressed
{
  my($self, $id, $tokenIndex, $token) = @_;

  my $category = $self->{"lang"};
  my $base = "suppress_${category}_note#";
  my $suppressKeyByToken = ndb::MakeShadedKey("$base${token}", $category);
  my $val;

  if (defined tdb::Get($id, $suppressKeyByToken, "addendKey"))
  {
    $val = 1;
  }
  else
  {
    my $suppressKeyByTokenIndex = ndb::MakeShadedKey("$base${tokenIndex}", $category);
    $val = defined tdb::Get($id, $suppressKeyByTokenIndex);
  }
  $val = "0" unless $val;
  print "TmpNoteShouldBeSuppressed($id, $tokenIndex, $token): $val ($suppressKeyByToken)\n" if $__Trace_MassageAndFootnote && $val;
  return $val;
}

sub ProposeVerbTenseNote
{
  my($self, $verb, $token, $possiblyAmbiguous, $context, $note, $id) = @_;

  die if ($__thisTokenIsPermanentlyIdentified);
  if (!defined $note)
  {
    $note = "FormOf(\"$context\", \"$verb\")";
  }
  print "ProposeVerbTenseNote( $verb, " . nutil::ToString($token) . ", $possiblyAmbiguous, $context, $note, " . nutil::ToString($id) . "): $__thisTokenIsPermanentlyIdentified\n" if $__Trace_MassageAndFootnote;
  if ($context ne "past participle")
  {
    $__verbHits++;
  }
  $__notesByVerb{ $verb } = [$token, $possiblyAmbiguous, $context, $note];
  $__mostRecentVerbNoted = $verb;

  $self->ProposeLangNote($token, $verb, $possiblyAmbiguous, $context, $note);
  return 1;
}

sub InitAll_even_if_cached
{
  my($self) = @_;
  $self->{"genExercisesHash"} = Init_genExercisesHash();
  $self->{"Trace_ConformingToCharacteristics"} = $__Trace_ConformingToCharacteristics;
  $self->{"Trace_MassageAndFootnote"} = $__Trace_MassageAndFootnote;
  $self->{"Trace_Relink"} = $__Trace_Relink;
  $self->{"Trace_VerbCharacteristicPropagation"} = $__Trace_VerbCharacteristicPropagation;
  $self->{"Trace_XGen"} = $__Trace_XGen;
}

sub VerifyTenseNamesAreOk
{
  my($self) = @_;
  my $tensesRef = $self->GetTenses();
  for (my $j = 0; $j < @$tensesRef; $j++)
  {
    my $tense = $tensesRef->[$j];
    if ($tense =~ / /)
    {
      warn "$tense has an embedded space -- which leads to broken vt tense links";
    }
  }
}


sub Init
{
  my($self, $lang) = @_;
  print "generic_grammar::Init($lang)\n";
  die $self unless defined $lang;
  $self->{"lang"} = $lang;
  #####$self->RmGeneratedData();

  # alphabetize

  $__currentToken = undef;
  $__exerciseGenerator = undef;
  $self->{"NO_OP"} = -1;
  $self->{"automaticallyLinkedStrings"} = ();
  $self->{"eqVerbs"} = ();
  $self->{"hasSecondaryHelperVerb"} = ();
  $self->{"noteDivider"} = "<br>&nbsp;&nbsp;";
  $self->{"verbOverrideListWhats"} = ();
  $self->{"verbOverrideScalarWhats"} = ();
  $self->{"verbOverrides"} = ();
  $self->{"verbs"} = ();
  $self->{"verbsByEnglish"} = ();
  if ($lang eq "English")
  {
    my $subjunctive_although_not_really = "For purposes of this exercise, imagine a preceding phrase which obligates using the subjunctive.";
    $self->SaveNote('subjunctive_although_not_really', $subjunctive_although_not_really);
  }
  $self->VerifyTenseNamesAreOk();
}

# override this if past participles can be modified (eg, to agree w/ a preceding direct
# object in French).
sub LooksLikeAModifiedPastParticiple
{
  my($self, $token, $id) = @_;
  return 0;
}

sub PruneVerbsByRecursiveness
{
  my($self, $vtlVal, $pruneRecursiveVerbs) = @_;
  for (my $j = 0;;)
  {
    my $verb = $vtlVal->Get($j, 1);
    last unless defined $verb;
    my $isRecursive = $self->IsRecursive($verb);
    if (( $pruneRecursiveVerbs &&  $isRecursive)
    ||  (!$pruneRecursiveVerbs && !$isRecursive))
    {
      $vtlVal->Delete($j);
    }
    else
    {
      $j++;
    } 
  } 
}

sub PruneVerbsByVerb_a
{
  my($self, $vtlVal, $id) = @_;
  if ($id =~ /^verb_(.*)\.\d+$/)
  {
    my $expectedVerb_a = $1;
    $expectedVerb_a =~ s/_/ /g;
        
    my $sawVerb_a = 0;
    for (my $j = 0;; $j++)
    {
      my $verb_b = $vtlVal->Get($j, 1);
      last unless defined $verb_b;
      my $verb_a = $self->Get_verb_a($verb_b);
      #print "PruneVerbsByVerb_a($vtlVal, $id): cf $verb_a==$expectedVerb_a\n";
      if ($verb_a eq $expectedVerb_a)
      {
	$sawVerb_a = 1;
	last;
      }
    }
    if ($sawVerb_a)
    {
      for (my $j = 0;;)
      {
	my $verb_b = $vtlVal->Get($j, 1);
	last unless defined $verb_b;
        	my $verb_a = $self->Get_verb_a($verb_b);
	if ($verb_a ne $expectedVerb_a)
	{
	  $vtlVal->Delete($j);
	  #print "PruneVerbsByVerb_a($vtlVal, $id): deleted $verb_a entry: " . $vtlVal->ToString() . "\n";
	}
	else
	{
	  $j++;
	}
      }
    }
  }
}

sub LooksLikeRecursiveUse
{
  my($self, $rawToken, $s) = @_;
  return 0;
}

sub IsRecursive
{
  my($self, $verb) = @_;
  return 0; # default
}

sub TransformPastParticiple
{
  my($self, $oldPp, $oldVerb, $newVerb, $before, $after, $suffixBefore, $suffixAfter) = @_;
  return $self->DuplicatePattern($oldPp, $before, $after, $suffixBefore, $suffixAfter);
}

# unused
#sub GetReflexivity_b
#{
#  my($self, $verb_b, $argsRef) = @_;
#  if (defined $argsRef->[18] && $argsRef->[18] != '')
#  {
#    return 1;
#  }
#  return 0;
#}

sub EqVerb
{
  my($self, $verb_b, $verb_a, $paradigmVerb, $makeIntoAParadigmVerb, $pastParticipleOverride) = @_;

  my $notFirstVerbWithThisEnglish = undef;
  if (defined $verb_a)
  {
    if ($verb_a =~ /(.*)2$/)
    {
      $verb_a = $1;
      $notFirstVerbWithThisEnglish = 1;
    }
  }

  my $suffix = "";
  if (defined $paradigmVerb)
  {
    $self->Set__eqVerbs($verb_b, $paradigmVerb) unless $makeIntoAParadigmVerb;

    if (defined $self->GetVerbArgs($verb_b, 1)
    && ($verb_b !~ /^(acariciar|brillar|cuire|portare|prendere|rendre|chiamare|litigare|lottare|f:uhlen|laver|afferrare|lever|marcher|pizzicare|rendersi|scivolare|sich unterhalten|cruzar|tomar|trouver|unterhalten)$/))		# I know about these and am ok w/ them...
    {
      warn "$verb_b already defined before this $self->EqVerb!";
    }
  }
  else
  {
    if ($verb_b =~ /(.*)2/)
    {
      $verb_b = $1;
      $suffix = "2";
      $paradigmVerb = $verb_b;
    }
    elsif ($verb_b =~ /^(\S+) /)
    {
      $paradigmVerb = $1;
    }
    else
    {
      warn "EqVerb($verb_b, $verb_a): what is the paradigm?  Not doing this...\n";
      return;
    }
  }


  my $argsRef = $self->GetVerbArgs($paradigmVerb);
  die "Couldn't resolve " . $paradigmVerb unless defined $argsRef;
  my @args = @$argsRef;
  #x("init", \@$argsRef, \@args) if ($verb_b =~ /chiamare/);

  my($before, $after, $suffixBefore, $suffixAfter) = (undef, undef, undef, undef);
  if ($paradigmVerb ne $verb_b)
  {
    # The paradigm verb provides us with the conjugation pattern.
    # The ,before and ,after give us a regular expression transformation
    # which will let us transform the conjugation of the paradigm verb
    # into the equivalently conjugated verb.

    ($before, $after, $suffixBefore, $suffixAfter) = $self->EqVerbDerivePatterns($verb_b, $paradigmVerb);
    if ($__Trace_VerbCharacteristicPropagation)
    {
      print "EqVerbDerivePatterns($verb_b, $paradigmVerb): $before/$after";
      print ", $suffixBefore/$suffixAfter" if defined $suffixBefore;
      print "\n";
    }

    my $stem_b = $self->VerbArgs_get_stem_b(\@args);

    $stem_b = $self->DuplicatePattern($stem_b, $before, $after, $suffixBefore, $suffixAfter);

    $args[0] = $stem_b;
    my $pastParticiple = $args[2];
    if (defined $pastParticiple)
    {
      $pastParticiple = $self->DuplicatePattern($pastParticiple, $before, $after, $suffixBefore, $suffixAfter);
      $self->Override($verb_b, "past participle", $pastParticiple);
      $args[2] = $pastParticiple;
    }

    if ($verb_b =~ /^$stem_b(.+)/)
    {
      # capture what ever follows the stem (e.g., ' geboren' was being missed in 'sein geboren')
      $args[1] = $self->StripReflexivity($1);
    }
    $args[11] = $self->DuplicatePattern($args[11], $before, $after, $suffixBefore, $suffixAfter);
    $args[12] = $self->DuplicatePattern($args[12], $before, $after, $suffixBefore, $suffixAfter);
    $args[13] = $self->DuplicatePattern($args[13], $before, $after, $suffixBefore, $suffixAfter);
    $args[14] = $self->DuplicatePattern($args[14], $before, $after, $suffixBefore, $suffixAfter);
    $args[15] = $self->DuplicatePattern($args[15], $before, $after, $suffixBefore, $suffixAfter);
    $args[16] = $self->DuplicatePattern($args[16], $before, $after, $suffixBefore, $suffixAfter);
  }
  #x("pre", \@$argsRef, \@args) if ($verb_b =~ /chiamare/);
  $args[3] = $verb_a;
  #x("pre2", \@$argsRef, \@args) if ($verb_b =~ /chiamare/);

  my $reflexive_a = $self->SetReflexivity_a(\@args);
  my $reflexive_b = $self->SetReflexivity_b("$verb_b$suffix", \@args);

  $args[5]  = ''; # English defaults
  $args[6]  = '';
  $args[7]  = '-s';
  $args[8]  = '';
  $args[9]  = '';
  $args[10]  = '';

  #x("post", \@$argsRef, \@args) if ($verb_b =~ /chiamare/);
  $self->SetVerbArgs("$verb_b$suffix", $verb_a, [ @args ], $notFirstVerbWithThisEnglish);

  my $verb_b_withReflexivityStripped = $self->StripReflexivity($verb_b);
  if ($paradigmVerb ne $verb_b)
  {
    $self->DuplicateOverrides($verb_b_withReflexivityStripped, $paradigmVerb, $before, $after, $suffixBefore, $suffixAfter);
  }

  if (defined $pastParticipleOverride)
  {
    $self->Override($verb_b_withReflexivityStripped, 'past participle', $pastParticipleOverride);
  }

  return undef;
}

sub x
{
  my($s, $ar1, $ar2) = @_;
  Ndmp::Ah("old $s", @$ar1);
  Ndmp::Ah("new $s", @$ar2);
}

sub UnifyCharacteristicsOfObjectPhrasesForOneExercise
{
  my($self, $id) = @_;
  my $lang = $self->{"lang"};
  my $other = tdb::Get($id, $lang);
  print "UnifyCharacteristicsOfObjectPhrasesForOneExercise($id): $other\n" if $__Trace_ConformingToCharacteristics;
  if (defined $other)
  {
    $other = $self->UnifyCharacteristicsOfObjectPhrases($id, $other);
    tdb::Set($id, $lang, $other);

    my $text = tdb::GetText($id, $lang);
    if ($text =~ />/)
    {
      warn "$id: $lang: not completely processed?  $other ($text)";
    }
  }
}


# unused:
sub DataFile_UnifyCharacteristicsOfObjectPhrases
{
  my($self, $dataFile) = @_; 
  print "DataFile_UnifyCharacteristicsOfObjectPhrases($dataFile)\n";
  
  my $lang = $self->{"lang"};
  my $max = tdb::GetSize("$dataFile") - 1;
  for (my $idNumber = 0; $idNumber <= $max; $idNumber++)
  {
    my $id = "$dataFile.$idNumber"; 
    $self->UnifyCharacteristicsOfObjectPhrasesForOneExercise($id);
  }
}
  
# unused:
sub ListDataFilesWhichAreNotGenerated
{
  my($self) = @_;
  my @all = GetAllExerciseAreas();
  my @notGenerated = ();
  foreach my $area (@all)
  {
    if (!defined tdb::Get("$area.0", "generated"))
    {
      push @notGenerated, $area;
    } 
    tdb::Close1($area);
  }
  return @notGenerated;
}

# unused:
sub UngeneratedExercises_UnifyCharacteristicsOfObjectPhrases
{
  my($self) = @_;
  foreach my $addendDataFile (ListDataFilesWhichAreNotGenerated())
  {
    $self->DataFile_UnifyCharacteristicsOfObjectPhrases($addendDataFile);
  }
}
    
sub OnEndOfGrammarGeneration
{
  my($self) = @_;
    
  teacher_DumpedPerl::Save($self->{"lang"}, $self);
}
    
sub GetEnglishConjugation
{
  my($self, $__unused__, $tense, $verb_a, $compoundPast, $trailingString_a, $s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a) = @_;

  if ($tense eq "preterite"
  ||  $tense eq "passe_simple")
  {
    # there is special handling in GetPast_English for "to be able to"
    #print "/$verb_a/$trailingString_a/\n";
    if (($verb_a eq "be") && ($trailingString_a ne " able to"))
    {
      $s1_a = $s3_a                 = "was"  . $trailingString_a;
      $s2_a = $p1_a = $p2_a = $p3_a = "were" . $trailingString_a;
    }
    else
    {
      $s1_a = $s2_a = $s3_a = $p1_a = $p2_a = $p3_a = $self->GetPast_English($verb_a . $trailingString_a);
    }
  }
  elsif ($tense eq "imperfect")
  {
    if (($verb_a eq "have")
    || (($verb_a eq "be") && $compoundPast))
    {
      my $s = "had" . $trailingString_a;
      $s1_a = $s2_a = $s3_a = $p1_a = $p2_a = $p3_a = $s;
    }
    else
    {
      if ($verb_a =~ /^(advance|become|learn)$/)
      {
	$trailingString_a = " " . generic_grammar::GetPresentParticiple_English($verb_a) . $trailingString_a;
	$s1_a = "was"  . $trailingString_a;
	$s2_a = "were" . $trailingString_a;
	$s3_a = "was"  . $trailingString_a;
	$p1_a = "were" . $trailingString_a;
	$p2_a = "were" . $trailingString_a;
	$p3_a = "were" . $trailingString_a;
      }
      else
      {
	$trailingString_a = "used to " . $verb_a . $trailingString_a;
	$s1_a = $trailingString_a;
	$s2_a = $trailingString_a;
	$s3_a = $trailingString_a;
	$p1_a = $trailingString_a;
	$p2_a = $trailingString_a;
	$p3_a = $trailingString_a;
      }
    }
  }
  elsif ($tense eq "future")
  {
    my $s = "will $verb_a" . $trailingString_a;
    $s1_a = $s2_a = $s3_a = $p1_a = $p2_a = $p3_a = $s;
  }
  elsif ($tense =~ /^(conditional|k2)$/)
  {
    my $s = "would $verb_a" . $trailingString_a;
    $s1_a = $s2_a = $s3_a = $p1_a = $p2_a = $p3_a = $s;
  }
  elsif ($tense eq "imperative")
  {
    $s2_a = $verb_a . "$trailingString_a";
    $p1_a = $verb_a . "$trailingString_a";
    $p2_a = $verb_a . "$trailingString_a";
  }
  elsif ($tense =~ /^(k1|subjunctive)$/)
  {
    $s1_a = $verb_a . "$trailingString_a";
    $s2_a = $verb_a . "$trailingString_a";
    $s3_a = $verb_a . "$trailingString_a";
    $p1_a = $verb_a . "$trailingString_a";
    $p2_a = $verb_a . "$trailingString_a";
    $p3_a = $verb_a . "$trailingString_a";
  }
  elsif ($tense =~ /^(present|k2|.*subjunctive)$/)
  {
    $s1_a = $self->Combine($verb_a, $s1_a) . "$trailingString_a";
    $s2_a = $self->Combine($verb_a, $s2_a) . "$trailingString_a";
    $s3_a = $self->Combine($verb_a, $s3_a) . "$trailingString_a";
    $p1_a = $self->Combine($verb_a, $p1_a) . "$trailingString_a";
    $p2_a = $self->Combine($verb_a, $p2_a) . "$trailingString_a";
    $p3_a = $self->Combine($verb_a, $p3_a) . "$trailingString_a";
  }
  else
  {
    die "bad $tense";
  }
  return ($s1_a, $s2_a, $s3_a, $p1_a, $p2_a, $p3_a);
}

sub MakeNoteHolderCall
{
  my($self, $n1, $n2, $n3, $n4) = @_;
  my $s = "NoteHolder('$n1'";
  $s .= ", '$n2'" if defined $n2;
  $s .= ", '$n3'" if defined $n3;
  $s .= ", '$n4'" if defined $n4;
  $s .= ")";
  return $s;
}

sub NoteHolder
{
  my($self, $n1, $n2, $n3, $n4) = @_;
  my $s = $self->ResolveNote($n1);

  $s .= $self->{"noteDivider"} . $self->ResolveNote($n2) if (defined $n2);
  $s .= $self->{"noteDivider"} . $self->ResolveNote($n3) if (defined $n3);
  $s .= $self->{"noteDivider"} . $self->ResolveNote($n4) if (defined $n4);
  return $s;
}

sub AdjectiveMustAgree
{
  my($self, $unmodifiedAdjective, $note) = @_;
  # I used to say "=Adjectives=agreement" instead of just "=Adjectives" for the
  # ref link.  The Adjectives section overall was so skimpy, I thought it looked strange
  # to not just go to the top of it.
  return $self->AdjectivalExpressionMustAgree("Adjectives must agree in gender and number with the objects they modify.", undef, "subject", "=Adjectives", "adjectives", $unmodifiedAdjective, $note);

}

sub AdjectivalExpressionMustAgree
{
  my($self, $s, $thingWhichMustBeAgreedWith, $label, $link, $linkText, $unmodifiedAdjective, $note) = @_;
  if (!defined $unmodifiedAdjective)
  {
    $unmodifiedAdjective = $self->DeriveUnmodifiedAdjective($self->Get__currentToken());
  }

  $thingWhichMustBeAgreedWith = "" unless defined $thingWhichMustBeAgreedWith;

  $s .= "  In this case, <i>"
  . $unmodifiedAdjective
  . "</i> becomes <i>"
  . $self->Get__currentToken()
  . "</i> because the $label <i>"
  . $thingWhichMustBeAgreedWith
  . "</i> is ";

  $s .= $self->ExplainAdjectivalChange($self->Get__currentToken(), $unmodifiedAdjective);
  $s .= " (see " . $self->MakeGrammarLink("$linkText", $link) . " for more info).";

  if (defined $note)
  {
    $s .= $self->{"noteDivider"} . $self->ResolveAndCookNotes(undef, $note);
  }
  #print "AdjectivalExpressionMustAgree($s, " . nutil::ToString($thingWhichMustBeAgreedWith) . ", " . nutil::ToString($label) . ", " . nutil::ToString($link) . ", " . nutil::ToString($linkText) . ", " . nutil::ToString($unmodifiedAdjective) . ", " . nutil::ToString($note) . "): $s\n";
  return $s;
}

sub IsACompoundPastTense
{
  my($self, $context) = @_;
  my $val = ($context =~ /^(past.*|future_perfect|pluperfect)$/);
  return $val;
}

sub InsertAddendBefore
{
  my($self, $other, $addend, $countOfItemsToFollowAddend) = @_;
  my $regexpForItemsToFollowAddend;
  my $updatedOther = $other;
  my $divider = "XXX";
  $updatedOther =~ s/\^D /$divider/g;	# e.g., don't treat 'aus^D gehe' as 2 tokens
  if ($countOfItemsToFollowAddend!=$self->{"NO_OP"})
  {
    if ($countOfItemsToFollowAddend==0)
    {
      $regexpForItemsToFollowAddend = "";
    }
    elsif ($countOfItemsToFollowAddend==1)
    {
      $regexpForItemsToFollowAddend = " \\S+";
    }
    elsif ($countOfItemsToFollowAddend==2)
    {
      $regexpForItemsToFollowAddend = " \\S+ \\S+";
    }
    elsif ($countOfItemsToFollowAddend==3)
    {
      $regexpForItemsToFollowAddend = " \\S+ \\S+ \\S+";
    }
    else
    {
      warn("nutil::Warn: InsertAddendBefore($other, $addend, $countOfItemsToFollowAddend) excessive");
    }

    $updatedOther .= "." if ($updatedOther !~ /([\.!\?])$/);

    if (!($updatedOther =~ s/($regexpForItemsToFollowAddend)([\.!\?])$/ $addend$1$2/))
    {
      warn "InsertAddendBefore($other, $addend, $countOfItemsToFollowAddend) failed: $regexpForItemsToFollowAddend";
    }

    # mv addend punctuation to the end
    if ($updatedOther =~ /([!\?])/)
    {
      my $punctuation = $1;
      $updatedOther =~ s/([\.!\?])//g;
      $updatedOther =~ s/\.$//;
      $updatedOther .= $punctuation;

      if ($self->{"lang"} eq "Spanish"
      && ($punctuation eq "?" || $punctuation eq "!"))
      {
	$updatedOther =~ s/^_/_$punctuation/;
      }
    }

  }
  $updatedOther =~ s/$divider/^D /g;	# restore original divisions
  return $updatedOther;
}

sub GetSubjectCharacteristics
{
  my($self, $key) = @_;
  my $pronounCode = $self->GetPronoun($key);
  if (!defined $pronounCode)
  {
    warn "$key: no pronoun setting";
    return ('s', 'm', 'fake_pronoun_name');
  }
  my $gender = (($pronounCode =~ /^(s3b|p3b)$/) ? 'f' : 'm');
  my $subjectSingularOrPlural = (($pronounCode =~ /s/) ? 's' : 'p');
  my $subject = $self->GetPronounName($pronounCode);

  print "GetSubjectCharacteristics($key): ($subjectSingularOrPlural, $gender, $subject)\n" if $__Trace_ConformingToCharacteristics;

  return ($subjectSingularOrPlural, $gender, $subject);
}

sub AddendIsSubject
{
  my($self, $key) = @_;
  my $val = (defined tdb::Get(grammar::GetGlobalIdForThisDataFile($key), "addend_is_subject"));
  #print "AddendIsSubject($key): $val\n";
  return $val;
}


sub ReplacePronounWithAddend_common
{
  my($self, $other, $adjustedAddend) = @_;
  $other = grammar::Capitalize($other);
  return $other;
}

sub CombineAddendPrefixWithAddend
{
  my($self, $addend_prefix, $adjustedAddend) = @_;
  if (!($adjustedAddend =~ s/^{}.*?{/{}{$addend_prefix/)
  &&     !($adjustedAddend =~ s/^{/{$addend_prefix/))
  # )}))       this nonsense to satisfy elisp paren-balancing
  {
    $adjustedAddend = "$addend_prefix$adjustedAddend";
  }
  return 	$adjustedAddend;
}

sub InsertAddend_globals
{
  my($self, $key, $adjustedAddend) = @_;

  my $addend_prefix = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), $self->{"lang"} . "/addend_prefix");

  if (tdb::Get($key, $self->{"lang"} . "/suppress_addend_prefix"))
  {
    $addend_prefix = undef;
  }

  if (defined $addend_prefix)
  {
    my $trailingString = $self->{"trailingString"};
    if (!defined $trailingString)
    {
      $trailingString = "";
    }
    elsif ($adjustedAddend =~ /^$trailingString /)
    {
      $adjustedAddend =~ s/^$trailingString //;
      $trailingString .= " ";
    }
    else
    {
      # happens all the time for sp
      # warn "no '$trailingString ' in $adjustedAddend";
      $trailingString = "";
    }
    my $separatePhrase = "";
    # {
    if ($addend_prefix =~ /(.*}\s*)(.*)/)
    {
      $separatePhrase = $1;
      $addend_prefix = $2;
    }

    # Usually the prefix will be a proposition; is important for this proposition be
    # a part of any {...} clauses so that the ConformCharacteristics code will be able
    # to appropriately combine it with articles, and, for German, figure out the
    # appropriate case:

    $adjustedAddend = $self->CombineAddendPrefixWithAddend($addend_prefix, $adjustedAddend);

    $adjustedAddend = "$trailingString$separatePhrase$adjustedAddend";
  }
  
  my $addend_suffix = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), $self->{"lang"} . "/addend_suffix");
  if (defined $addend_suffix)
  {
    $adjustedAddend = "$adjustedAddend$addend_suffix";
  }
  #print "InsertAddend_globals($key, $adjustedAddend)\n";
  return $adjustedAddend;
}

sub InsertAddend
{
  my($self, $key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend) = @_;

  $placeToInsertAddend = 0 if !defined $placeToInsertAddend;
  print "InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend)\n" if $__Trace_Relink;


  if ($adjustedAddend =~ />se>/)
  {
    $adjustedAddend = $self->InsertAddend_adjustRecursiveInfinitiveToMatchPronoun($key, $adjustedAddend);
  }

  $adjustedAddend = $self->InsertAddend_globals($key, $adjustedAddend);

  my $updatedOther;
  if ($self->AddendIsSubject($key))
  {
    if ($tense ne "imperative")
    {
      $updatedOther = $self->ReplacePronounWithAddend($other, $adjustedAddend);
    }
    else
    {
      print "InsertAddend ignoring $key because AddendIsSubject and it is imperative\n" if $__Trace_Relink;
    }
  }
  else
  {
    $updatedOther = $self->InsertAddendBefore($other, $adjustedAddend, $placeToInsertAddend);
  }
  print "InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey, $placeToInsertAddend): $updatedOther\n" if $__Trace_Relink;

  return $updatedOther;
}

sub InsertAddend_English
{
  my($self, $key, $english) = @_;
  die "english" unless defined $english;

  my $englishAddend = tdb::Get($key, "English/addend");
  if (!defined $englishAddend)
  {
    $englishAddend = tdb::Get($key, "z/English/addend");
  }
  if (!defined $englishAddend)
  {
    tdb::Save();
    die "$key";
  }
  my $pronounCode = $self->GetPronoun($key);
  if (defined $pronounCode)
  {
    if ($englishAddend =~ / me$/ && $pronounCode =~ /s1/)
    {
      $englishAddend=~ s/ me$/ myself/;
    }
    elsif ($englishAddend =~ / you$/ && $pronounCode =~ /s2/)
    {
      $englishAddend =~ s/ you$/ yourself/;
    }
    elsif ($englishAddend =~ / you$/ && $pronounCode =~ /p2/)
    {
      $englishAddend =~ s/ you$/ yourselves/;
    }
    elsif ($englishAddend =~ / us$/ && $pronounCode =~ /p1/)
    {
      $englishAddend =~ s/ us$/ ourselves/;
    }
  }
  my $addend_prefix = tdb::Get(grammar::GetGlobalIdForThisDataFile($key), "English/addend_prefix");
  $addend_prefix = "" unless defined $addend_prefix;

  if ($self->AddendIsSubject($key))
  {
    my $tense = tdb::Get($key, "tense");
    if ($tense ne "imperative")
    {
      die "englishAddend" unless defined $englishAddend;
      die "addend_prefix" unless defined $addend_prefix;
      if ($english =~ /^(\.\.\.that )/)
      {
        $english =~ s/^(\.\.\.that )(I|you|he|she|we|they|it) /$1$addend_prefix$englishAddend /i;
      }
      else
      {
        $english =~ s/^(I|you|he|she|we|they|it) /$addend_prefix$englishAddend /i;
      }
      if ($english =~ /They \[feminine\]/
      ||  $english =~ /cut \[present\]/)
      {
        ;	# leave it alone
      }
      else
      {
        $english =~ s/\[.*?\] //g;	# get rid of the additional prompts added for ambiguous pronouns (e.g., "[feminine]")
      } 
      $english = grammar::Capitalize($english);
    }
  }
  else
  {
    $english .= "." unless $english =~ /([\.!\?])$/;
    $english =~ s/([\.!\?])$/ $addend_prefix$englishAddend$1/;
    $english =~ s/([\.!\?]).$/$1/;	# stop extra punctuation -- give $englishAddend the last word on question marks
  }

  #print "InsertAddend_English($key, $english): added (global=" . nutil::ToString($addend_prefix) . ") $englishAddend\n";

  return $english;
}

sub ResolveLinks
{
  my($self, $tense, $key, $english, $other, $verb_b) = @_;
  print "ResolveLinks($key)\n" if $__Trace_Relink;

  my $lang = $self->{"lang"};
  my $addendKey      = tdb::Get($key, "addendKey");

  if (defined $addendKey)
  {
    my $originalAddend = tdb::Get($key, "z/$lang/addend");
    my $adjustedAddend = tdb::Get($key, "$lang/addend");

    if (!defined $originalAddend)
    {
      warn "$addendKey yields nothing for $key: $lang";
    }
    else
    {
      if (!defined $adjustedAddend)
      {
	$adjustedAddend = $originalAddend;
      }
      else
      {
	if ($adjustedAddend eq $originalAddend)
	{
	  #print "$adjustedAddend eq $originalAddend, so no need for the adjusted setting:\n";
	  tdb::Set($key, "$lang/addend", undef, 1);
	}
      }
    }

    if (defined $adjustedAddend)
    {
      $other = $self->InsertAddend($key, $other, $adjustedAddend, $tense, $verb_b, $addendKey);
      $english = $self->InsertAddend_English($key, $english) if defined $english;
    }
    print "ResolveLinks($tense, $key): " . nutil::ToString($english) . ", $other (added " . nutil::ToString($adjustedAddend) . ")\n" if $__Trace_Relink;
  }
  return ($english, $other);
}

sub CookTense
{
  my($self, $tense, $precedingWord) = @_;
  $tense =~ s/_/ /g;
  if (!defined $precedingWord)
  {
    $precedingWord = "";
  }
  else
  {
    if ($precedingWord =~ /^(a)$/)
    {
      if ($tense =~ /^[aeiou]/)
      {
	$precedingWord = "an ";
      }
      else
      {
	$precedingWord .= " ";
      }
    }
  }
  return "$precedingWord$tense";
}

sub MostRecentVerbNoted
{
  my($self) = @_;
  return $__mostRecentVerbNoted;
}

sub IsInVtl
{
  my($self, $token, $context, $id) = @_;
  my($contextFound, $verb, $possiblyAmbiguous) = $self->VtlLookup($token, $id, $context);
  return (defined $contextFound && defined $verb && defined $possiblyAmbiguous);
}

sub IsAnInfinitive
{
  my($self, $possibleVerb, $caller) = @_;
  my $val = (defined $self->GetVerbArgs($possibleVerb, 1));
  print "IsAnInfinitive($possibleVerb) from $caller: $val\n" if $__Trace_MassageAndFootnote;
  return $val;
}

sub GetIrregularPastParticiples
{
  my($self, $s) = @_;
  my @irregulars = ();
  foreach my $verb_b ($self->Get_all_verb_bs())
  {
    if (defined $self->GetOverride($verb_b, "past participle"))
    {
      push(@irregulars, $verb_b);
    } 
  }
  return sort(@irregulars);
}

sub ContainsInfinitivePhrase
{
  my($self, $s) = @_;
  if ($s =~ /(\S+)$/)
  {
    my $possibleInfinitivePhrase = $1;
    if ($self->IsAnInfinitive($possibleInfinitivePhrase, "ContainsInfinitivePhrase"))
    {
      return $possibleInfinitivePhrase;
    }
  }
  return 0;
}

sub ClearMostRecentVerbNoted
{
  my($self) = @_;
  $__mostRecentVerbNoted = undef;
}

sub Pastify
{
  my($self, $context) = @_;
  if ($context eq "conditional")
  {
    return "past_conditional";
  }
  if ($context eq "imperfect")
  {
    return "pluperfect";
  }
  if ($context eq "present")
  {
    return "past";
  }
  if ($context eq "future")
  {
    return "future_perfect";
  }
  if ($context eq "subjunctive")
  {
    return "past subjunctive";
  }
  return undef;
}

# not used
#sub UnPastify
#{
#  my($self, $context) = @_;
#  $context = "conditional" if $context eq "past_conditional";
#  $context = "imperfect"       if $context eq "pluperfect";
#  $context = "present"             if $context eq "past";
#  $context = "future"   if $context eq "future_perfect";
#  $context = "subjunctive" if $context eq "past subjunctive";
#  return $context;
#}

sub GetTenseOverride
{
  my($self, $verb_b, $tense) = @_;
  return "<center>Using <i>$verb_b</i> in the " . $self->CookTense($tense) . " is archaic.</center>";
} 


sub VetoSaveExercise
{
  my($self, $id, $verb_b) = @_;
  my $val;
  my $explicitlyAuthorizedVerb_b = tdb::Get($id, $self->{"lang"} . "/verb_b", "addendKey");
  if (defined $explicitlyAuthorizedVerb_b)
  {
    $val = ($explicitlyAuthorizedVerb_b ne $verb_b);
  }
  else
  {
    $val = 0;
  }
  #print "VetoSaveExercise($id, $verb_b) (" . nutil::ToString($explicitlyAuthorizedVerb_b) . "): $val\n";
  return $val;
}

sub Contraction
{
  my($self, $contraction, $componentWords) = @_;
  $self->HashPut("contractions", $contraction, $componentWords);
  $self->HashPut("reverseContractions", $componentWords, $contraction);
  return "<tr><td>\n$componentWords\n</td><td>\n$contraction\n</td></tr>\n";
}

sub ListItem
{
  my($self, $word_b, $word_a) = @_;
  return "<tr><td>\n$word_b\n</td><td>$word_a</td></tr>";
}

sub ListVerb
{
  my($self, $verb_b) = @_;
  return $self->ListItem($verb_b, $self->Get_verb_a($verb_b));
}

# type can be:
# 	1. undef		permanent note key
# 	2. "2"			";;2" permanent secondary note key
# 	3. "tmp"		";;tmp" temporary note key
sub MakeTokenNoteKey
{
  my($self, $tokenKey, $type) = @_;

  $tokenKey =~ s/'//g if defined $tokenKey;	# won't be defined for global (i.e., unsuperscripted) notes

  my $makeTmp = 0;

  $tokenKey = "" unless defined $tokenKey;

  if (!defined $type)
  {
    $type = "";
  }
  elsif ($type eq "tmp")
  {
    $type = "";
    $makeTmp = 1;
  }
  else
  {
    warn("nutil::Warn: " . $type) unless $type eq "2";
  }
  $tokenKey = $self->MakeIntoNoteKey($tokenKey);
  my $lang = $self->GetLang();
  my $val = ndb::MakeShadedKey("${lang}_note#$tokenKey$type", $lang);

  $val = ndb::MakeShadedKey($val, "tmp") if $makeTmp;

  #print "MakeTokenNoteKey($tokenKey, $type): $val\n";
  if ($val eq "German_note#s2;;German")
  {
    die;
  }

  return $val;
}

sub PronounIsAmbiguousInEnglish
{
  my($pronounCode) = @_;
  my $val = ($pronounCode =~ /[sp]2/); # 2nd person singular or plural
  #print "PronounIsAmbiguousInEnglish($pronounCode): $val\n";
  return $val;
}

sub AddPronounPrompt
{
  my($s, $pronounCode) = @_;
  print "AddPronounPrompt($s, $pronounCode)\n";
  if ($pronounCode =~ /p2a/)
  {
    $s =~ s/(you(rselves)?)/$1 [formal, plural]/ ||
    $s =~ s/!/ [formal, plural]!/;
  }
  elsif ($pronounCode =~ /p2b/)
  {
    $s =~ s/(you(rselves)?)/$1 [familiar, plural]/ ||
    $s =~ s/!/ [familiar, plural]!/;
  }
  elsif ($pronounCode =~ /p2/)
  {
    $s =~ s/(you(rselves)?)/$1 [plural]/ ||
    $s =~ s/!/ [plural]!/;
  }
            
  elsif ($pronounCode =~ /s2a/)
  {
    $s =~ s/(you(rself)?)/$1 [formal, singular]/ ||
    $s =~ s/!/ [formal, singular]!/;
  }
  elsif ($pronounCode =~ /s2b/)
  {
    $s =~ s/(you(rself)?)/$1 [familiar, singular]/ ||
    $s =~ s/!/ [familiar, singular]!/;
  }
  elsif ($pronounCode =~ /s2/)
  {
    $s =~ s/(you(rself)?)/$1 [singular]/ ||
    $s =~ s/!/ [singular]!/;
  }
  else
  {
    die $pronounCode;
  }
  print "exercise_generator::AddPronounPrompt(): $s\n";
  return $s;  
}

sub TenseIsAmbiguousInEnglish
{
  my($self, $tense, $pronounCode, $verb_a) = @_;
  my $val = "";
  
  if ($tense eq "k1")
  {
    $tense = "subjunctive";
  }
  elsif ($tense eq "k2")
  {
    $tense = "past subjunctive";
  }
  
  if ($tense =~ /^(past subjunctive|subjunctive)$/)
  {
    $val = $tense;
  }
  elsif ((($tense eq "preterite") || ($tense eq "present"))
  && ($pronounCode !~ /s3/))
  { 
    if ($verb_a eq $self->GetPast_English($verb_a))
    {
      if ($tense eq "preterite")
      {
	$val = "past";
      }
      else
      {
	$val = $tense;
      } 
    } 
  }
  elsif ($verb_a =~ /^(could)$/)
  {
    $val = $tense;
  }
  #print "TenseIsAmbiguousInEnglish($tense, $pronounCode, $verb_a): $val\n";
  return $val;
}

sub ExtractOrExplainMagicThruPhraseAnalysis
{
  my($self, $key, $s, $magic) = @_;
  $magic = "";
  return $magic;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions
{
  my($self, $key, $val) = @_;
  if ($val =~ /^\S+$/)			# just one word -- can't be contracted
  {
    ;
  }
  elsif ($val =~ /^((\S+) (\S+))/)
  {
    my $possibleComponentWords = $1;
    my $componentWord1 = $2;
    my $componentWord2 = $3;
        
    $possibleComponentWords = $1 if $possibleComponentWords =~ /(.*)\^D$/;
    $componentWord1 = $1 if $componentWord1 =~ /(.*)\^D$/;
    $componentWord2 = $1 if $componentWord2 =~ /(.*)\^D$/;
    
    print "UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val): checking $possibleComponentWords\n" if $__Trace_ConformingToCharacteristics;
    my $contraction = $self->HashGet("reverseContractions", $possibleComponentWords);
    if (defined $contraction)
    {
      $val =~ s/^$possibleComponentWords/$contraction/;
            
      $self->MoveNotes($key, $componentWord1, $contraction);
      $self->MoveNotes($key, $componentWord2, $contraction);
      tdb::Set($key, $self->MakeTokenNoteKey($contraction, "2"), $self->ExplainContraction_getNoteText($contraction));
    } 
  }
  else
  {
    warn "UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val) could not parse\n";
  }

  return $val;
}

sub MakePlural_English
{
  my($self, $noun) = @_;
  my $val;
  if ($noun =~ /(.*[^aeiou])y$/
  ||  $noun =~ /(.*qu)y$/)
  {
    $val = $1 . "ies";
  }
  elsif ($noun =~ /(ch|s|sh|x|z)$/)
  {
    $val = $noun . "es";
  }
  else
  {
    $val = $noun . "s";
  } 
  return $val;
}

sub ExtractCharacteristicsThruPhraseAnalysis_updateEnglishNoun
{
  my($self, $key, $singularOrPlural) = @_;
  my $english = undef;
  if ($self->ShouldUpdateEnglish($key))
  {
    $english = tdb::Get($key, 'English');
    if ($english =~ /{(a )?(\S+)>x>}/)
    {
      my $noun = $2;
      if ($singularOrPlural eq "p")		# e.g., not canonical singular?
      {
	$english =~ s/{(a )?$noun>x>}/$self->MakePlural_English($noun)/e;
        	warn("nutil::Warn: code assumes that there will only be a single noun which must be adjusted: $english") if $english =~ /[{}]/;
      }
      else
      {
	$english =~ s/{(a? ?)$noun>x>}/$1$noun/g;
      }
      #print "ExtractCharacteristicsThruPhraseAnalysis_updateEnglishNoun($key, $singularOrPlural) ($noun in $english)\n";
      tdb::Set($key, 'English', $english);
    }
  }
  die $english if  $english =~ />x>/;
  #print "ExtractCharacteristicsThruPhraseAnalysis_updateEnglishNoun($key, $singularOrPlural): " . nutil::ToString($english) . "\n";
}

sub ExtractCharacteristicsThruPhraseAnalysis_indirect
{ 
  my($self, $key, $noun) = @_;
  
  my $text = tdb::Get($key, $self->GetLang());
  if ($text =~ /{($noun>[^{}]*)}/
  ||  $text =~ /{([^{}]*[^{}:]$noun>[^{}]*)}/)		# allow colons, just not next to noun (eg, {ein h:asslich Auto>s>})
  {
    my $s = $1;
    $__ExtractCharacteristicsThruPhraseAnalysis_indirect_recursion_stopping_counter++;
    if ($__ExtractCharacteristicsThruPhraseAnalysis_indirect_recursion_stopping_counter > 100)
    {
      warn $key . ": " . $self->GetLang() . ": infinite recursion in $s"; 
    }
    else
    {
      return $self->ExtractCharacteristicsThruPhraseAnalysis($key, $s);
    }
  }
  else
  {
    warn "could not find instruction for $noun in $text";
  }
  
  
  my($gender, $singularOrPlural, $magic) = ('m', 's', undef);	# dummy up some results so as not to sink this run...
  return ($gender, $singularOrPlural, $magic);
}

sub ExtractCharacteristicsThruPhraseAnalysis
{
  my($self, $key, $s) = @_;
  my ($gender, $magic, $singularOrPlural) = ('m', undef, 's');

  # { to balance regexp:
  if ($s !~ /^(.*[}\s])?(\S+)>(.)(.*)?>/)
  {
    print "ExtractCharacteristicsThruPhraseAnalysis($key, $s): could not parse: returning defaults...\n" if $__Trace_ConformingToCharacteristics;
  }
  else
  {
    my $token = $2;
    $singularOrPlural = $3;	# 's' or 'p'
    my $magicStuff = $4;		# this may be 'I'; if it's German, this may be _case_ (i.e., 'n', 'a', 'd', or 'g')
    #
    # _However_, it should be noted that even for the German module, the case is not always specified if it can be
    # determined by the context.
    #
    # Also: magicStuff can be case followed by a note explaining.  It's all interpreted by
    # ExtractOrExplainMagicThruPhraseAnalysis.
    print "ExtractCharacteristicsThruPhraseAnalysis($key, $s): $token/$singularOrPlural/$magicStuff\n" if defined $magicStuff && $__Trace_ConformingToCharacteristics;

    delete($self->{"characteristicsFount"});
    if ($singularOrPlural =~ /^(x|X)$/)
    {
      if ($magicStuff =~ /^:(.*)$/)
      {
	my $noun = $1;
	$self->{"characteristicsFount"} = $noun;
	$self->{"characteristicsFountType"} = "noun";

	($gender, $singularOrPlural, $magic) = $self->ExtractCharacteristicsThruPhraseAnalysis_indirect($key, $noun);

	$self->{"characteristicsFountWithOrnament"} = "the"
	. $self->PrintGender($gender)
	. $self->PrintSingularOrPlural($singularOrPlural)
	. " noun <i>$noun</i>";

	delete($self->{"adjustedCharacteristicsFount"});
      }
      else
      {
	my($subjectSingularOrPlural, $subjectGender, $subject) = $self->GetSubjectCharacteristics($key);

	if ($singularOrPlural ne "X" && $self->IsNoun($token))			# not an adjective?
	{
	  $singularOrPlural = $subjectSingularOrPlural;
	  # A noun with the '>x>' modifier has a one-to-one relationship with the subject (e.g., "your wife").  Its
	  # gender, however, cannot change.  Change the gender from that of the subject to that of the noun:
	  $gender = $self->GetNounGender($token, 0, $singularOrPlural);
          warn("nutil::Warn: $token") unless defined $gender;
	  $self->ExtractCharacteristicsThruPhraseAnalysis_updateEnglishNoun($key, $singularOrPlural);
	}
	else
	{
	  $self->{"characteristicsFount"} = $subject;
	  $self->{"characteristicsFountType"} = "subject";

	  $gender           = $subjectGender;
	  $singularOrPlural = $subjectSingularOrPlural;

	  $self->{"characteristicsFountWithOrnament"} = "the"
	  . $self->PrintGender($gender)
	  . $self->PrintSingularOrPlural($singularOrPlural)
	  . " subject <i>$subject</i>";

	  delete($self->{"adjustedCharacteristicsFount"});
	}
      }
    }

    if (!defined $self->{"characteristicsFount"})
    {
      if ($magicStuff =~ /^I:(.*)/)
      {
	my $impliedNoun = $1;
	$token = $impliedNoun;
	$self->{"characteristicsFountType"} = "implied noun";
	$magicStuff = '';	# don't confuse ExtractOrExplainMagicThruPhraseAnalysis() below
      }
      else
      {
	$self->{"characteristicsFountType"} = "noun";
      }
      $self->{"characteristicsFount"} = $token;
      $gender = $self->GetNounGender($token, 0, $singularOrPlural);

      $magic = $self->ExtractOrExplainMagicThruPhraseAnalysis($key, $s, $magicStuff);
      my $oToken = $self->ConformToCharacteristics($token, $gender, $singularOrPlural, $magic);
      $self->{"adjustedCharacteristicsFount"} = $oToken->GetToken();

      $self->{"characteristicsFountWithOrnament"} = "the"
      . $self->PrintGender($gender)
      . $self->PrintSingularOrPlural($singularOrPlural)
      . $self->PrintMagic($magic)
      . " "
      . $self->{"characteristicsFountType"} . " <i>" . $self->{"adjustedCharacteristicsFount"} . "</i>";
    }
  }
  if ($__Trace_ConformingToCharacteristics)
  {
    print "ExtractCharacteristicsThruPhraseAnalysis($key, $s): (" . nutil::ToString($gender) . ", $singularOrPlural, " . nutil::ToString($magic) . ")"
    . "\n	characteristicsFountType=" . $self->{"characteristicsFountType"}
    . "\n	characteristicsFount    =" . $self->{"characteristicsFount"}
    . "\n";
  }
  return ($gender, $singularOrPlural, $magic, $s);
}

sub ExtractMagicThruTokenAnalysis
{
  my($self, $token, $s) = @_;
  return "";
}

sub OnUnifyCharacteristicsOf_1_ObjectPhrase
{
  my($self, $key, $val, $addendKey) = @_;
  return $val;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase
{
  my($self, $key, $s) = @_;

  print "UnifyCharacteristicsOf_1_ObjectPhrase($key, $s [no curlies expected])\n" if $__Trace_ConformingToCharacteristics;

  $__ExtractCharacteristicsThruPhraseAnalysis_indirect_recursion_stopping_counter = 0;
  
  my($gender, $singularOrPlural, $phraseWideMagic);
  ($gender, $singularOrPlural, $phraseWideMagic, $s) = $self->ExtractCharacteristicsThruPhraseAnalysis($key, $s);

  $s =~ s/>.*?>//;
  warn("nutil::Warn: multiple instructions in $s") if $s =~ />..?>/;
  
  my $val;
  if (!defined $gender)
  {
    $val = $s;
    #print "UnifyCharacteristicsOf_1_ObjectPhrase($key, $s): set $val\n";
  }
  else
  {
    my @tokens = split(" ", $s);
    $val = "";
    foreach my $token (@tokens)
    {
	print "\n======UnifyCharacteristicsOf_1_ObjectPhrase($key, $s: $token)======================================\n" if $__Trace_ConformingToCharacteristics;
	my $trailingComma = ($token =~ s/,$//) ? "," : "";

	delete($self->{"rejectedAlternativeThatOneWouldNormallyExpect"});

	my $magic;
	if ($phraseWideMagic)
	{
	  $magic = $phraseWideMagic;
	}
	else
	{
	  $magic = $self->ExtractMagicThruTokenAnalysis($token, $s);
	}
	my $oToken = $self->ConformToCharacteristics($token, $gender, $singularOrPlural, $magic);
	my $adjustedToken = $oToken->GetToken();
	print "-------$adjustedToken----------------------------------------------------------------------\n" if $__Trace_ConformingToCharacteristics;

	$val .= " " if $val;
	$val .= $adjustedToken . $trailingComma;
	$oToken->SaveAnyNotes($key);
      }
    }
    $val = $self->UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $val);
    $val = $self->OnUnifyCharacteristicsOf_1_ObjectPhrase($key, $val, tdb::Get($key, "addendKey"));
    print "UnifyCharacteristicsOf_1_ObjectPhrase($key, $s): $val\n" if $__Trace_ConformingToCharacteristics;
  return $val;
}

sub UnifyCharacteristicsOfObjectPhrases_undoPreviousWork
{
  my($self, $other) = @_;
  $other =~ s/{}.*?{/{/g;
  print "UnifyCharacteristicsOfObjectPhrases_undoPreviousWork(): $other\n" if $__Trace_ConformingToCharacteristics;
  return $other;
}

sub MaybeAddPronounPrompt
{
  my($self, $english, $pronounCode) = @_;
    
  if (PronounIsAmbiguousInEnglish($pronounCode))
  {
    $english = AddPronounPrompt($english, $pronounCode);
  }
  if ($pronounCode eq "p3b") # feminine they
  {
    $english =~ s/(they)/$1 [feminine]/;
  }
  return $english;
}

sub MaybeAddTensePrompt
{
  my($self, $key, $english, $tense, $pronounCode, $verb_a) = @_;
        
  my $tensePrompt = $self->TenseIsAmbiguousInEnglish($tense, $pronounCode, $verb_a);
  if ($tensePrompt)
  {
    $english .= " [$tensePrompt]";
    if ($tense =~ /(subjunctive|k1|k2)/)
    {
      tdb::Set($key, 'English_note#;;English', "subjunctive_although_not_really");
    }
  }
  return $english;
}

sub ShouldUpdateEnglish
{
  my($self, $key, $tense) = @_;
  # For the sake of efficiency, the English does not get updated by every module.

  # there are two places in the process where the English gets updated:
  # 1. vtl generation
  #		there is a particular tense associated with this stage,
  #		and thus $tense will be defined during this call.  For this stage,
  #		if the tense is preterite and the language is Spanish, then update English.
  #		otherwise follow the rules below given for #2.
  # 2. ConformToCharacteristics
  # 		generally only the German module will update the English.  If
  # there is no German translation, then the Spanish module will be responsible.  If there is no
  # Spanish translation, then just always update the English.
  #
  #
  # btw: It is intuitive to think that the addend can be inserted separately from
  # the generation of the English, but this isn't true.  The English does not
  # come from the database; rather it is generated on the fly based on the
  # verb tables.  This means that German, which has no reckoning of the
  # preterite, is not capable of generating the correct English for that
  # tense.  The Spanish must, in addition to generating the correct English,
  # insert the English addend.

  my $lang = $self->{"lang"};

  # if it's both past and preterite, let the preterite exercise determine
  # what the english should be:
  if (defined $tense
  &&  $tense eq "past"
  &&  tdb::IsPropSet($key, "areas", "preterite"))
  {
    return 0;
  }
  return 1;
  
  #elsif (defined $tense
  #&&  $tense eq "preterite"
  #&&  $lang eq "Spanish")
  #{
    #$val = 1;
  #}
  #elsif ($lang eq "German"
  #||  (!defined tdb::Get($key, "German") && $lang eq "Spanish")
  #||  !defined tdb::Get($key, "Spanish"))
  #{
    #$val = 1;
  #}
  #return $val;
}

sub OnExerciseGeneration
{
  my($self, $key, $english, $tense, $pronounCode, $other, $verbForm, $verb_a, $verb_b) = @_;

  if (!$self->ShouldUpdateEnglish($key, $tense))
  {
    $english = undef;
  }
  else
  {
    $english = $self->MaybeAddPronounPrompt($english, $pronounCode);
    if ($tense =~ /^(k1|subjunctive)$/)
    {
      $english = "...that $english";
    }
    else
    {
      $english = grammar::Capitalize($english);
    }
    $english = $self->MaybeAddTensePrompt($key, $english, $tense, $pronounCode, $verb_a);
    $english .= "." if ($english !~ /([\.!\?])$/);
    if ($tense !~ /^(past|preterite)$/)
    {
      $english =~ s/ \[past tense\]//;
    }
  }

  if ($tense !~ /^(k1|subjunctive)$/)
  {
    if ($other =~ /^(_.)?$verbForm\b/) # ie, verbForm begins the sentence?
    {                                  # (Btw, the '(_.)' is to account for _!, _?, etc.)
      #print "...capping vf\n";

      $verbForm = grammar::Capitalize($verbForm);
    }
    $other      = grammar::Capitalize($other);
  }
  $other    = grammar::RegexpifyTeacherToken($other);
  $verbForm = grammar::RegexpifyTeacherToken($verbForm);

  $other .= "." if ($other !~ /([\.!\?])$/);
  ($english, $other) = $self->ResolveLinks($tense, $key, $english, $other, $verb_b);

  if ($tense =~ /^(k1|subjunctive)$/)
  {
    $other = "..." . $self->GetThat($other) . " " . $other;
  }

  # separate beginning and ending punctuation from the beginning and ending tokens, so as to
  # maintain the correspondence between those tokens and any notes which might be associated
  # with them:
  $other =~ s/^(_.)/$1^D /;
  $other =~ s/(!\?\.)$/^D $1/;

  print "OnExerciseGeneration($key, $tense, $pronounCode): (" . nutil::ToString($english) . ", $other, $verbForm)\n" if $__Trace_Relink || $__Trace_XGen;
  return ($english, $other, $verbForm);
}

sub IsNoun_asIdentifiedByConformanceSetting
{
  my($self, $possibleNoun) = @_;

  my $val = (defined $self->{"characteristicsFount"}
  &&  defined $self->{"characteristicsFountType"}
  &&  $self->{"characteristicsFountType"} =~ /\bnoun\b/
  &&  $possibleNoun eq $self->{"characteristicsFount"});
    
  #print "IsNoun_asIdentifiedByConformanceSetting($possibleNoun): $val\n";
  return $val;
}

  

# note: this works for all nouns only if I have every noun represented in the nounGenderHash hash
# (e.g., as I do in German).  But this is not true for all languages.
sub IsNoun
{
  my($self, $noun) = @_;
  if (!defined $noun)
  {
    die "undefined noun";
    return 0;
  }
  my $val;
  if ($self->IsNoun_asIdentifiedByConformanceSetting($noun))
  {
    $val = 1;
  }
  else
  {
    $val = defined $self->HashGet("nounGenderHash", $noun);
  }
  print "IsNoun($noun): $val\n" if $__Trace_ConformingToCharacteristics;
  return $val;
}
  
sub GetNounGender
{
  my($self, $noun, $silent, $singularOrPlural) = @_;
      
  my $gender = $self->HashGet("nounGenderHash", $noun);
  if (!defined $gender)
  {
    if (!$silent)
    {
      warn($self->{"lang"} . ": no gender for $noun");
      $gender = 'm';	# reduce red herrings...
    }
  }
  elsif ($gender eq "mf")
  {
    die "no sOrP" if !defined $singularOrPlural;
    $self->{"somethingOddAboutThisNounsPlural"} = "The noun <i>$noun</i> is masculine when it is singular, but becomes feminine in its plural form.";
    $gender = ($singularOrPlural eq 's') ? "m" : "f";
    #print "GetNounGender($noun, $silent, $singularOrPlural): saw goofy plural: $gender\n";
  }
  elsif ($gender !~ /^[mnf]$/)
  {
    warn("nutil::Warn: gender of noun $noun is strange: $gender");
  }
  else
  {
    if (defined $singularOrPlural && $singularOrPlural eq "s")
    {
      my $pluralForm = $self->HashGet("pluralHash", $noun);
      if (defined  $pluralForm &&  $pluralForm eq ">>>")
      {
	warn "$noun, which was defined with a plural of '>>>', meaning that there is no singular form, seems to be being used in the singular";
      }
    } 
  }
  print "GetNounGender($noun, $silent): " . nutil::ToString($gender) . "\n" if $__Trace_ConformingToCharacteristics;
  return $gender;
}
      
sub Noun
{
  my($self, $noun, $gender, $plural) = @_;
  
  warn $self->GetLang() . ": dupe $noun" if defined $self->HashGet("nounGenderHash", $noun);
  
  $self->HashPut("nounGenderHash", $noun, $gender);
  $self->HashPut("pluralHash", $noun, $plural) if defined $plural;
  return undef;
}

sub Adjective
{
  my($self, $adjective, $feminine, $plural) = @_;
  $self->HashPut("adjectiveFeminineHash", $adjective, $feminine) if defined $feminine;
  $self->HashPut("pluralHash", $adjective, $plural) if defined $plural;
  return undef;
}

sub PrintMagic
{
  my($self, $magic) = @_;
  return "";
}

sub PrintGender
{
  my($self, $gender) = @_;
  return " masculine" if $gender eq 'm';
  return " feminine" if $gender eq 'f';
  return " neuter" if $gender eq 'n';

  warn("nutil::Warn: " . $gender);
  return undef;
}

sub PrintSingularOrPlural
{
  my($self, $singularOrPlural) = @_;

  return " singular" if $singularOrPlural eq 's';

  die $singularOrPlural unless $singularOrPlural eq 'p';

  my $link = $self->MakeGrammarLink("plural", "=plural");
  return " $link";
}

sub ExplainWhatItIs
{
  my($self, $token, $val, $gender, $singularOrPlural, $magic, $whatItIs, $keyOfCharacteristics) = @_;

  my $explanation;

  $val = $1 if $val =~ /(.*)\^D$/;

  $explanation = "The";
  warn("nutil::Warn: null parms") unless defined $keyOfCharacteristics;
  $explanation .= $self->PrintGender($gender) if (!defined $keyOfCharacteristics) || ($keyOfCharacteristics =~ /^[mfn]/);
  $explanation .= $self->PrintSingularOrPlural($singularOrPlural);
  $explanation .= $self->PrintMagic($magic);
  $explanation .= " $whatItIs <i>$val</i> is appropriate because of the need to agree with ";
  if (defined $self->{"characteristicsFountWithOrnament"})
  {
    $explanation .= $self->{"characteristicsFountWithOrnament"};
  }
  else
  {
    $explanation .= "noun being described";
  }
  $explanation .= ".";
          
  if ($singularOrPlural eq "p"
  && defined $self->{"characteristicsFountType"}
  && $self->{"characteristicsFountType"} eq "implied noun"
  && $self->{"adjustedCharacteristicsFount"} ne ($self->{"characteristicsFount"} . "s"))
  {
    $explanation .= $self->{"noteDivider"}
    . $self->ExplainPlural($self->{"characteristicsFount"}, $self->{"adjustedCharacteristicsFount"});
  }

  return $explanation;
}

sub ExplainAdjectiveChange
{
  my($self, $token, $val, $gender, $singularOrPlural, $magic) = @_;

  my $adjectiveLink = $self->MakeGrammarLink("adjective", "=Adjectives");

  my $explanation = "The $adjectiveLink <i>$token</i> becomes <i>$val</i> to agree with "
  . $self->{"characteristicsFountWithOrnament"}
  . ".";
  return $explanation;
}

sub OnSelectionBasedOnMagic
{
  my($self, $val, $mutableHash, $gender, $singularOrPlural) = @_;
  $self->RecordWhatWouldHaveBeenSelectedWithoutMagic($val, $mutableHash, $gender, $singularOrPlural);
}

sub RecordWhatWouldHaveBeenSelectedWithoutMagic
{
  my($self, $val, $mutableHash, $gender, $singularOrPlural) = @_;
  my $tmp = nutil::HashGet($mutableHash, "$gender$singularOrPlural");
  $self->{"rejectedAlternativeThatOneWouldNormallyExpect"} = $tmp;

  print "RecordWhatWouldHaveBeenSelectedWithoutMagic($val, $mutableHash, $gender, $singularOrPlural): self.rejectedAlternativeThatOneWouldNormallyExpect = $tmp\n" if $__Trace_ConformingToCharacteristics;
}

sub CheckMutables
{
  my($self, $mutableHash, $token, $gender, $singularOrPlural, $magic) = @_;

  my $oToken = undef;

  my $val;
  my $keyOfCharacteristics;
  if (defined $magic && $magic)
  {
    $keyOfCharacteristics = "$gender$singularOrPlural$magic";
    $val = $mutableHash->{$keyOfCharacteristics};
    if (!defined $val)
    {
      $keyOfCharacteristics = "$singularOrPlural$magic";
      $val = $mutableHash->{$keyOfCharacteristics};
    }
    if (defined $val)
    {
      $self->OnSelectionBasedOnMagic($val, $mutableHash, $gender, $singularOrPlural);
    }
  }
  if (!defined $val)
  {
    $keyOfCharacteristics = "$gender$singularOrPlural";
    $val = $mutableHash->{$keyOfCharacteristics};
  }
  if (!defined $val)
  {
    $keyOfCharacteristics = "$singularOrPlural";
    $val = $mutableHash->{$keyOfCharacteristics};
  }

  if (defined $val)
  {
    $oToken = new o_token($self, $val);
    if ($token ne $val)
    {
      $oToken->AddNote($self->ExplainWhatItIs($token,$val,$gender,$singularOrPlural,$magic,$mutableHash->{"whatItIs"}, $keyOfCharacteristics));
    }
  }
  print "CheckMutables($mutableHash, $token, $gender, $singularOrPlural, " . nutil::ToString($magic) . "): " . (defined $oToken ? $oToken->ToString() : "undef") . ")\n" if $__Trace_ConformingToCharacteristics;
  return $oToken;
}

sub CanonicalCharacteristics
{
  my($self, $gender, $singularOrPlural, $magic) = @_;
  return ($gender eq 'm' && $singularOrPlural eq 's' && (!defined $magic || !$magic));
}

sub CallCheckMutables
{
  my($self, $token, $gender, $singularOrPlural, $magic) = @_;
        
  my $oToken = undef;
  my $capitalized = 0;
  my $mutableHash = $self->HashGet("mutables", $token);
  if (!defined $mutableHash)
  {
    $capitalized = 1;
    $token = grammar::UnCapitalize($token);
    $mutableHash = $self->HashGet("mutables", $token);
  }
  if (defined $mutableHash)
  {
    $oToken = $self->CheckMutables($mutableHash, $token, $gender, $singularOrPlural, $magic);
  } 
  if (defined $oToken && $capitalized)
  {
    my $adjustedToken = $oToken->GetToken();
    $adjustedToken = grammar::Capitalize($adjustedToken);
    $oToken->SetToken($adjustedToken);
  }
  return $oToken;
}

sub DoNounSexChange
{
  my($self, $noun, $gender, $singularOrPlural) = @_; # need $singularOrPlural for Italian
  warn("nutil::Warn: not impl");
  return $noun;
}  

sub ConformToCharacteristics
{
  my($self, $token, $gender, $singularOrPlural, $magic) = @_;
  my $oToken = undef;
  $magic = "" unless defined $magic;
  if (!$self->CanonicalCharacteristics($gender, $singularOrPlural, $magic))
  {
    $oToken = $self->CallCheckMutables($token, $gender, $singularOrPlural, $magic);
    if (!defined $oToken && ($singularOrPlural eq 'p') && $self->IsNoun_asIdentifiedByConformanceSetting($token))
    {
      $oToken = $self->MakePlural($token, $magic);
    }
  }
  if (!defined $oToken && $self->LooksLikeAnAdjective($token))
  {
    $oToken = $self->MakeAdjectiveConformToCharacteristics($token, $gender, $singularOrPlural, $magic);
  }
  if (!defined $oToken)
  {
    $oToken = new o_token($self, $token);
  }
  print "ConformToCharacteristics($token, $gender, $singularOrPlural, $magic): " . $oToken->ToString() . "\n" if $__Trace_ConformingToCharacteristics;
  return $oToken;
}

sub GuessPlural
{
  my($self, $noun) = @_;
  warn $self->{"lang"} . ": GuessPlural($noun)";
  return $noun;
}

sub ExplainPlural
{
  my($self, $singularNoun, $pluralNoun) = @_;
    
  my($i, $_i) = ("", "");
      
  if (defined $pluralNoun)
  {
    ($i, $_i) = ("<i>", "</i>");
  }
  else
  {
    $pluralNoun = "%currentToken%";
  }
    
  my $e;
  if ($pluralNoun ne $singularNoun)
  {
    if ($pluralNoun eq ">>>")
    {
      $pluralNoun = $singularNoun;
      $e = "There is no singular noun corresponding to the plural noun <i>$pluralNoun</i>." ;
    }
    else
    {
      $e = "$i$pluralNoun$_i is the" . $self->PrintSingularOrPlural('p') . " of <i>$singularNoun</i>.";
    }
  } 
  else
  {
    $e = "$i$pluralNoun$_i does not change in the plural." 
  }
  #print "ExplainPlural($singularNoun, $pluralNoun): $e\n";
  return $e;
}

sub MakePlural
{
  my($self, $noun, $magic) = @_;
  my $oToken = new o_token($self, $noun);
  my $plural = $self->HashGet("pluralHash", $noun);
  my $val;
  if (defined $plural)
  {
    if ($plural eq ">>>")
    {
      $val = $plural = $noun;
    }
    else
    {
      $val = $self->Combine($noun, $plural);
    }
  }
  else
  {
    $val = $self->GuessPlural($noun);
  }
  $oToken->SetToken($val);
  if (!defined $val)
  {
    die "no val";
  }
  if (!defined $noun)
  {
    die "no noun";
  }

  if ($val ne "${noun}s")
  {
    $oToken->AddNote("ExplainPlural('$noun', '$val')");
  }
  
  #
  # we don't care what the gender is, we just want to provoke GetNounGender
  # into setting $self->{"somethingOddAboutThisNounsPlural"}:
  $self->GetNounGender($noun, 1, "p");
  
  if (defined $self->{"somethingOddAboutThisNounsPlural"})
  {
    $oToken->AddNote($self->{"somethingOddAboutThisNounsPlural"});
    delete($self->{"somethingOddAboutThisNounsPlural"});
  }

  print "MakePlural($noun, $magic): (" . $oToken->ToString($oToken) . "\n" if $__Trace_ConformingToCharacteristics;
  return $oToken;
}

sub SaveMutable
{
  my($self, $ms, $flavorsRef) = @_;

  # first, massage the contents of the hash to prevent spaces from cropping up after trailing apostrophes
  # (leading to, e.g., "l' empereur")
  foreach my $key (keys %$flavorsRef)
  {
    my $val = $flavorsRef->{$key};
    if ($val =~ /'$/)
    {
      $val .= "^D";
      $flavorsRef->{$key} = $val;
    }
  }
  $self->HashPut("mutables", $ms, $flavorsRef);
}


# char 1: gender
# char 2: singularOrPlural - s or p
# char 3: before vowel or nothing - v or ''
# if mp is same as fp, it is stored as p.
sub Mutable
{
  my($self, $whatItIsLink, $whatItIs, $ms, $fs, $mp, $fp, $msv, $fsv, $vHeader) = @_;
            
  my %flavors = ();
  $flavors{'whatItIs'} = $self->MakeGrammarLink($whatItIs, $whatItIsLink);
    
  $flavors{'fs'} = $fs if defined $fs;
  $flavors{'ms'} = $ms if defined $ms;
  $flavors{'msv'} = $msv if defined $msv;
  $flavors{'fsv'} = $fsv if defined $fsv;
    
  if (defined $mp && defined $fp && $mp eq $fp)
  {
    $flavors{'p'} = $mp;
  } 
  else
  {
    $flavors{'mp'} = $mp if defined $mp;
    $flavors{'fp'} = $fp if defined $fp;
  }
  my $hdr;
  my $m;
  my $f;
    
  $fp = $mp if !defined $fp;
  $fs = $ms if !defined $fs;
    
  if (defined $fsv)
  {
    $vHeader = 'singular before a vowel';
    $hdr = ['', 'singular', $vHeader, 'plural'];
    $m = ['masculine', $ms, (defined $msv ? $msv : $ms), $mp];
    $f = ['feminine', $fs, $fsv, $fp];
  }
  elsif (defined $mp)
  {
    $hdr = ['', 'singular', 'plural'];
    $m = ['masculine', $ms, $mp];
    $f = ['feminine', $fs, $fp];
  }
  else
  {
    $m = ['masculine', $ms];
    $f = ['feminine',  $fs];
  }
  $self->SaveMutable($ms, \%flavors);
  return $self->Table([$hdr, $m, $f]);
}

sub LooksLikeAnAdjective
{
  my($self, $token) = @_;
  # I use IsNoun_asIdentifiedByConformanceSetting because some adj's are nouns too (like fran,cais).
  # but unfortunately I do not maintain a list of adjectives, so the only way that I can tell the two apart
  # is to see whether there are conformance settings associated with the token (e.g., >s>):
  if ($self->IsNoun_asIdentifiedByConformanceSetting($token)
  || defined $self->HashGet("mutables", $token)
  || defined $self->HashGet("prepositions", $token))
  {
    return 0;
  }
  return 1;
}

sub City
{
  my($self, $name) = @_;
  if ($name =~ / (\S+)/)  # for la Havane, etc.
  { 
    $self->GetNounGender($1);	# provoke a warning if it isn't there
  }
  else
  {
    $self->GetNounGender($name);	# provoke a warning if it isn't there
  }
  $self->HashPut("cities", $name, 1);
  return undef;
}

sub SetNote
{
  my($self, $id, $token, $note, $notTmp) = @_;
      
  warn("nutil::Warn: creating note which will be destroyed") if !$notTmp && !$__MassageAndFootnoteCalled;
  
  my $key = $self->MakeTokenNoteKey($token, ($notTmp ? undef : "tmp"));
  
  #print "SetNote($id, $token, $note): doing tdb::Set($id, $key, note, 0)\n";
  tdb::Set($id, $key, $note, 0);
}

sub AddToNote
{
  my($self, $note, $addition) = @_;
  return $self->ResolveAndCookNotes(undef, $note, $addition);
}

sub Prep
{
  my($self, $preposition, $english) = @_;
  $self->HashPut("prepositions", $preposition, 1);
  return undef;
}

my %__ProposeExerciseIfNotCovered_result = ();

sub IsCommon
{
  my($self, $verb_a) = @_;

  my $val = $self->{"genExercisesHash"}->{$verb_a};
  if (!defined $val)
  {
    # we don't need a warning here because of the vocab_* case
    #warn "no defn for $val";
    $val = "";
  }
  print "IsCommon($verb_a): $val\n";
  return ($val eq "common");
}

sub ProposeExerciseIfNotCovered
{
  my($self, $verb_a, $tense, $pronoun) = @_;

  #print "ProposeExerciseIfNotCovered($verb_a, $tense, " . nutil::ToString($pronoun) . ")\n";
  
  my $alreadyCovered = $self->{"genExercisesHash"}->{$verb_a};

    if (!defined $alreadyCovered || !$alreadyCovered)
    {
      $verb_a =~ s/ /_/g;
      my $key = "verb_${verb_a}/$tense";
      if (!defined $__ProposeExerciseIfNotCovered_result{$key})
      {
      $__ProposeExerciseIfNotCovered_result{$key} = $pronoun;
    }
    elsif ($pronoun ne "1")
    {
      $__ProposeExerciseIfNotCovered_result{$key} = $pronoun;
    }
  }
}

sub ProposeExercises_print_recommendations
{
  my($self) = @_;
 
  foreach my $result (keys %__ProposeExerciseIfNotCovered_result)
  {
    if ($result =~ m{^(.*)/(.*)$})
    {
      my($dataFile, $tense) = ($1, $2);
      my $pronoun = $__ProposeExerciseIfNotCovered_result{$result};
      
      my $fn = "data/$dataFile";
      print "$fn:";

      if (! -f $fn)
      {
	print "@" . "val = (";
	system("touch $fn")
      } 
      print "{" . "'generated' => '1', 'tense' => '$tense',";
      if (defined $pronoun && $pronoun ne "1")
      {
	print "'pronoun' => '$pronoun',";
      }
      print "},\n";
    }
  }
}

sub ProposeExercises
{
  my($self) = @_;
  my $verbOverridesHashRef = $self->{"verbOverrides"};
  foreach my $verbOverride (keys %$verbOverridesHashRef)
  {
    if ($verbOverride =~ /^(.*)[;:](.*)$/)
    {
      my($verb_b, $what) = ($1, $2);
      my $verb_a = $self->Get_verb_a($verb_b, 1);
      if (defined  $verb_a)
      {
	if ($what eq "vowels")
	{
	  $self->ProposeExerciseIfNotCovered($verb_a, "preterite");
	  $self->ProposeExerciseIfNotCovered($verb_a, "imperfect");
	  $self->ProposeExerciseIfNotCovered($verb_a, "present", "s3b");
	}
	elsif ($what eq "past participle")
	{
	  $self->ProposeExerciseIfNotCovered($verb_a, "preterite");
	}
	elsif ($self->IsTense($what))
	{
	  $self->ProposeExerciseIfNotCovered($verb_a, $what);
	}
      }
    }
  }
  ProposeExercises_print_recommendations();
}

sub MakePointWithParentheticalAdditions
{
  my($self, $mainPoint, @parentheticalAdditions) = @_;

  my $s = " with $mainPoint";
  my $parenAdded = 0;
  for (my $j = 0; $j < scalar(@parentheticalAdditions); $j++)
  {
    if ($parentheticalAdditions[$j])
    {
      if (!$parenAdded)
      {
	$parenAdded = 1;
	$s .= " (and ";
      }
      else
      {
	$s .= ", and also ";
      }
      $s .= $parentheticalAdditions[$j];
    }
  }
  $s .= ")" if $parenAdded;
  return $s;
}

sub UnifyCharacteristicsOfObjectPhrases_orientPossessives
{
  my($self, $key, $other) = @_;
  my $pronounCode = $self->GetPronoun($key);
  if (!defined $pronounCode)
  {
    return $other;
  }
  my $english = tdb::Get($key, 'English');
  if (!defined $english)
  {
    return $other;
  }

  my $s2a_possessive = $self->{"s2a_possessive"};
  my $s2b_possessive = $self->{"s2b_possessive"};
  my $p2a_possessive = $self->{"p2a_possessive"};
  my $p2b_possessive = $self->{"p2b_possessive"};

  #print "UnifyCharacteristicsOfObjectPhrases_orientPossessives($key, $english, $other): $pronounCode\n";
  if ($english =~ /\byour\b/)
  {
    if ($other =~ /^([^{}]*)({.*})([^{}]*)$/)
    {
      my($staticBeginning, $dynamic, $staticEnding) = ($1, $2, $3);
      #print "$staticBeginning, $dynamic, $staticEnding\n";
      # the idea is to go from a sentence like 'Donnez ton argent' to 'Donnez votre argent'...
      if ($pronounCode =~ /s2a/)
      {
	$dynamic =~ s/\b$s2b_possessive\b/$s2a_possessive/g;
	$dynamic =~ s/\b$p2a_possessive\b/$s2a_possessive/g;
	$dynamic =~ s/\b$p2b_possessive\b/$s2a_possessive/g;
      }
      elsif ($pronounCode =~ /s2b/)
      {
	$dynamic =~ s/\b$s2a_possessive\b/$s2b_possessive/g;
	$dynamic =~ s/\b$p2a_possessive\b/$s2b_possessive/g;
	$dynamic =~ s/\b$p2b_possessive\b/$s2b_possessive/g;
      }
      elsif ($pronounCode =~ /p2a/)
      {
	$dynamic =~ s/\b$s2a_possessive\b/$p2a_possessive/g;
	$dynamic =~ s/\b$s2b_possessive\b/$p2a_possessive/g;
	$dynamic =~ s/\b$p2b_possessive\b/$p2a_possessive/g;
      }
      elsif ($pronounCode =~ /p2b/)
      {
	$dynamic =~ s/\b$s2b_possessive\b/$p2b_possessive/g;
	$dynamic =~ s/\b$p2a_possessive\b/$p2b_possessive/g;
	$dynamic =~ s/\b$s2a_possessive\b/$p2b_possessive/g;
      }
      elsif ($pronounCode =~ /^p/
      && $dynamic =~ />x>/)
      {
	# in this case we should make the object plural to match the number of the subject (e.g.,
	# 'we will bring your [formal, singular] spouse' becomes
	# 'we will bring your [formal, plural] spouses'.
	$dynamic =~ s/\b$s2a_possessive\b/$p2a_possessive/g;
	$dynamic =~ s/\b$s2b_possessive\b/$p2b_possessive/g;
      }
      $other = "$staticBeginning$dynamic$staticEnding";
    }
  }

  print "UnifyCharacteristicsOfObjectPhrases_orientPossessives($key): $other\n" if $__Trace_ConformingToCharacteristics;
  return $other;
}

sub IsAuxiliaryVerb
{
  my($self, $verb) = @_;
  foreach my $auxiliaryVerb ($self->GetAuxiliaryVerbs())
  {
    return 1 if $verb eq $auxiliaryVerb;
  }
  return 0;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__cleanupChunk
{
  my($self, $key, $other) = @_;
  if ($other =~ /\S/)
  {
    my $beginningWhite = "";
    my $endingWhite = "";
    if ($other =~ /^(\s*)((\S.*)?\S)(\s*)$/)
    {
      $other= $2;
      $beginningWhite = $1;
      $endingWhite    = $4;
    }
    $other = $self->UnifyCharacteristicsOf_1_ObjectPhrase__checkForContractions($key, $other);
    $other = $beginningWhite . $other . $endingWhite;
  }
  return $other;
}

sub UnifyCharacteristicsOf_1_ObjectPhrase__cleanup
{
  my($self, $key, $other) = @_;

  # extract the chunks which are not part of curly bracketed expressions:
  $other =~ s/^([^{}]+){}/$self->UnifyCharacteristicsOf_1_ObjectPhrase__cleanupChunk($key, $1) . "{}"/eg;
  $other =~ s/([^{])}([^{}]+){}/"$1}" . $self->UnifyCharacteristicsOf_1_ObjectPhrase__cleanupChunk($key, $2) . "{}"/eg;
  $other =~ s/}([^{}]+)$/"}" . $self->UnifyCharacteristicsOf_1_ObjectPhrase__cleanupChunk($key, $1)/eg;

  return $other;
}

# GrammaticalInstructions are enclosed by curly braces, and tell us to
# adjust components to conform to language rules for gender and case
# conformance, e.g., to convert
#
# 'German' => 'Er w:urde {der L:owe>as>} gejagt haben.',
#
# to
#
# 'German' => 'Er w:urde {}den L:owen{der L:owe>as>} gejagt haben.',
#                        ^^^^^^^^^^^^
#                        added.......
#
# The idea is to do something that can be reversed by UnifyCharacteristicsOfObjectPhrases_undoPreviousWork
# to allow reprocessing with no commitments to any particular settings for 'L:owe'.
#
# >x> means that the grammatical constructs should agree with the subject
# >X> is the same as >x> cept the token MUST be an adj.  (This is needed for '/etranger', which could be either...)
# >x:NOUN> means that the grammatical constructs should agree with the noun NOUN
# >s> means that the noun should be single
# >p> means that the noun should be plural
# >L> means that the adjective is being used with a German linking verb (and so shouldn't change)
# >sI> means that the preceding noun is single and _implied_, and so should be visible to the user only in footnotes
# >pI> means that the preceding noun is plural and _implied_, and so should be visible to the user only in footnotes
# >sC> means that the noun should be single and its German case 'C' (where C =~ /[adgn]/)
# >pC> means that the noun should be plural and its German case 'C' (where C =~ /[adgn]/)
# >sC:([^>]+)> means >sC> with $1 an explanatory note
# >pC:([^>]+)> means >pC> with $1 an explanatory note
#
#
#
sub UnifyCharacteristicsOfObjectPhrases
{
  my($self, $key, $other) = @_;

  print "UnifyCharacteristicsOfObjectPhrases($key, $other)\n" if $__Trace_ConformingToCharacteristics;

  $other = $self->UnifyCharacteristicsOfObjectPhrases_undoPreviousWork($other);
  $other = $self->UnifyCharacteristicsOfObjectPhrases_orientPossessives($key, $other);

  # Because Perl does not correctly stack regular expression search results,
  # it is important to divide this processing into two stages.  In the first
  # stage, we simply locate the grammatical instructions and save them away
  # in a stack.
  my @grammaticalInstructionsStack = ();
  $other =~ s/{(.*?)}/push @grammaticalInstructionsStack, $1; $1/eg;
  foreach my $grammaticalInstruction (@grammaticalInstructionsStack)
  {
    # In the second stage, we actually execute the individual
    # grammatical instructions, and reflect them in the "other" variable:

    my $result = $self->UnifyCharacteristicsOf_1_ObjectPhrase($key, $grammaticalInstruction);
    $other =~ s/$grammaticalInstruction/{}${result}\{$grammaticalInstruction\}/g;
    #print "UnifyCharacteristicsOfObjectPhrases($key, $other) after $grammaticalInstruction to $result\n";
  }

  if ($other =~ /^{}/)
  {
    # vocab stuff tends to be included in exercises; if I capitalize it, then this complicates
    # the propagation of notes.  So don't cap it if it's vocab:
    if ($key !~ /vocab_/)
    {
      $other = $self->CapitalizeAndMoveNotesIfNeeded($key, $other);
    }
  }
    
  $other = $self->UnifyCharacteristicsOf_1_ObjectPhrase__cleanup($key, $other);

  return $other;
}

1;
