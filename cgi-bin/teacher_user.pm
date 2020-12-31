my $__trace = 0;
package teacher_user;
use strict;
use diagnostics;
use nobj;
use Ndmp;
use tmp_teacher_user_irreg_verbs;

my $__LIGHTEST_REVIEW_EXERCISE_WEIGHT = 1001;
my $__WEIGHT_DELTA_DISCARDING_FROM_REVIEWSET = -9999;

# exercises are divided into
# 	1. review set -- exercises w/ weights >= $__LIGHTEST_REVIEW_EXERCISE_WEIGHT
# 	2. "uninteresting" exercises and 'data files' (e.g., "verb_fall")
#
# 	Note that there are no 'data files' in the review set.
#

use vars '@ISA';
require nobj;
@ISA = qw(nobj);

sub GetFn
{
  my($userID) = @_;
  if (!defined $userID)
  {
    return undef;
  }
  return "../httpdocs/teacher/usr/$userID/data";
}

sub IsReviewExercise
{
  my($self, $id) = @_;

  if ($id =~ /\./)
  {
    nutil::Warn("seeing old style id $id: periods should now be underscores...");
  }


  my $weight = $self->HashGet("reviewExercisesHash", $id);

  #$self->HashDump("reviewExercisesHash");

  my $val = (defined $weight);
  print "teacher_user::IsReviewExercise($id): $val\n" if $__trace;
  return $val;
}

sub IsInteresting
{
  my($self, $id) = @_;
  my $weight = $self->HashGet("reviewExercisesHash", $id);
  my $val = 1;
  chomp $weight if (defined $weight);
  print "teacher_user::IsInteresting($id): looking at $weight\n" if $__trace;
  if (defined $weight)
  {
    $val = ($weight >= $__LIGHTEST_REVIEW_EXERCISE_WEIGHT);
  }
  else
  {
    if ($id =~ /^(.*)[_\.](\d+)$/)
    {
      $id = $1;
      $val = $self->IsInteresting($id);
    }
  }
  print "teacher_user::IsInteresting($id): $val\n" if $__trace;
  return $val;
}

sub IsDataFile
{
  my($id) = @_;
  return $id !~ /^(.*)[_\.](\d+)$/;
}

sub ReadFromDisk
{
  my($self) = @_;
  my $fn = GetFn($self->{"userID"});

  my $f = new IO::File("< $fn") if defined $fn;

  if (defined $f)
  {
    my $exCnt = 0;
    while (<$f>)
    {
      my $line = $_;
      chomp $line;
      # ignore the random char after the '/' -- this is just to prevent clumping from the sort

      print "teacher_user::ReadFromDisk(): looking at $line\n" if $__trace;

      if ($line =~ m{^-})
      {
        ; # ignore -- negative scores aren't kosher
      }
      elsif ($line =~ m{^(-?\d+)/.([\w\.]+)$})
      {
        my($exId, $exWeight) = ($2, $1);

        $exId =~ s/\.(\d+)$/_$1/;	# convert from old system: verb_do.32 to new: verb_do_32

        if (defined $self->HashGet("reviewExercisesHash", $exId))
        {
          #
          # there was above which allowed multiple entries referring to the same exercise to be saved
          # in the user's review exercise database, due to the shift from verb_whatever.32 to
          # the verb_whatever_32 format.  This check guards against the possibility of recommending
          # the same exercise twice.
          #
          print "teacher_user::ReadFromDisk(): skipping duplicate reviewExercisesHash.$exId = $exWeight\n" if $__trace;
        }
        else
        {
          $self->HashPut("reviewExercisesHash", $exId, $exWeight);
          $self->ArraySet("reviewExercisesArray", $exCnt++, $exId);
          print "teacher_user::ReadFromDisk(): adding reviewExercisesHash.$exId = $exWeight\n" if $__trace;
        }
      }
      else
      {
        print "teacher_user::ReadFromDisk(" . $self->{"userID"} . "): ignoring $line" if $__trace;
      }
    }
  }
}
# Before describing the solution, I'll describe the problem that this
# routine is intended to solve.
# Sometimes there is a flashcard which is especially difficult to deal with
# for the user.  So this card cycles and cycles, and its weight becomes
# increasingly large until it is much heavier than any of the other
# flashcards.  At this point the user suddenly gets it, and does not need to
# see this flashcard so constantly.  But because of my weighting scheme, this
# flashcard is going to be a part of every set of flashcards including
# any review exercises for a large number of sessions.  That's no good.
#
# To avoid this, this routine looks at the heaviest exercises, and if there
# is an exercise or set of exercises which are much heavier than the rest,
# it reduces their weights to bring them closer to the others.
#
sub FlattenWeights
{
  my($diskDataArrayRef, $weightsRef) = @_;  # the diskDataArrayRef is sorted in reverse order by weight
  if (!scalar(@$diskDataArrayRef))
  {
    return; # it is empty
  }

  my $last_flattened_weight = $__LIGHTEST_REVIEW_EXERCISE_WEIGHT;
  my $heaviestExerciseCount = scalar(@$diskDataArrayRef) - 1;
  my $last_pre_flattened_weight = $weightsRef->{   $diskDataArrayRef->[$heaviestExerciseCount]   };
  # loop through, lightest exercises first
  for (my $j = $heaviestExerciseCount; $j >= 0; $j--)
  {
    my $current_pre_flattening_weight = $weightsRef->{   $diskDataArrayRef->[$j]     };
    if ($current_pre_flattening_weight > $__LIGHTEST_REVIEW_EXERCISE_WEIGHT)
    {
      my $current_flattened_weight;
      if ($current_pre_flattening_weight == $last_pre_flattened_weight)
      {
        $current_flattened_weight = $last_flattened_weight;
      }
      else
      {
        $last_pre_flattened_weight = $current_pre_flattening_weight;
        $current_flattened_weight = $last_flattened_weight + 1;
        $last_flattened_weight = $current_flattened_weight;
      }
      #my $weight_j_1 = $weightsRef->{   $diskDataArrayRef->[$j-1]   };
      #my $weight_j
      #
      #    $weight_j_1 = 0 if !defined $weight_j_1;
      #    $weight_j   = 0 if !defined $weight_j;
      #
      #    $weight_j_1 -= $cumulativeAdjustment;
      #
      #    my $gap = $weight_j_1 - $weight_j;
      #
      #    if ($gap > $maxGap)
      #    {
      #      my $adjustment = $gap - $maxGap;
      #      $cumulativeAdjustment += $adjustment;
      #      $weight_j_1 -= $adjustment;
      #
      #    }
      #    delete($weightsRef->{   $diskDataArrayRef->[$j-1]   });	# cuz weight's part of the key
      
      my $old = $diskDataArrayRef->[$j];
      $diskDataArrayRef->[$j] =~ s/^(......)/sprintf("%06d", $current_flattened_weight)/e;
      my $new = $diskDataArrayRef->[$j];
      #print "FlattenWeights: $j:\t$old\tto $new ($current_flattened_weight)\n";

       
      # $weightsRef->{   $diskDataArrayRef->[$j-1]  } = $weight_j_1;
    } 
  }
}

sub OnceInABlueMoonPruneReviewExercises
{
  if (nutil::random(100)==0)
  {
    warn "teacher_user::OnceInABlueMoonPruneReviewExercises(): time to truncate the review exercises\n";
    return 1;
  }
  return 0;
}

sub SaveToDisk
{
  my($self) = @_;
  my $fn = GetFn($self->{"userID"});

  if (!defined $fn)
  {
    warn "teacher_user.SaveToDisk: no fn for ". $self->{"userID"};
    return;
  }
  
  if (OnceInABlueMoonPruneReviewExercises())
  {
    unlink($fn);
    return;
  }

  my $reviewExercisesHashRef = $self->{"reviewExercisesHash"};
  my @diskDataArray = ();
  my %weights = ();
  
  foreach my $reviewExerciseKey ($self->HashKeys("reviewExercisesHash"))
  {
    # gen a random char to prevent clumping from the sort
    my $randomChar = (nutil::random(25) + 97);  # 97 is 'a'.  There must be a better way to do this!
    my $weight = $self->HashGet("reviewExercisesHash", $reviewExerciseKey);
    if (!defined $weight)
    {
      warn "teacher_user::SaveToDisk(): undef weight for $reviewExerciseKey\n";
      $self->HashDump("reviewExercisesHash");
    }
    else
    {
      # FlattenWeights uses a regexp which depends on the following format:
      my $key = sprintf("%06d/%c%s", $weight, $randomChar, $reviewExerciseKey);
      push @diskDataArray, $key;
      #print "teacher_user::SaveToDisk(): weights->$key = $weight\n";
      $weights{$key} = $weight;
    }
  }
  @diskDataArray = reverse(sort(@diskDataArray));
  
  print "teacher_user.pm.SaveToDisk pre   flattening: diskDataArray=@diskDataArray\n" if $__trace;
  FlattenWeights(\@diskDataArray, \%weights);
  print "teacher_user.pm.SaveToDisk after flattening: diskDataArray=@diskDataArray\n" if $__trace; 
  
  my $f = new IO::File("> $fn");
  if (!defined $f)
  {
    print "Could not write to $fn\n";
  }
  else
  {
    foreach my $reviewExercise (@diskDataArray)
    {
      next if $reviewExercise eq "";
      
      print $f "$reviewExercise\n";
      print "teacher_user.pm.SaveToDisk writing $reviewExercise...\n" if $__trace;
    }
  }
}

sub AddReviewExercises
{
  my($self, $selectedExercises, $selectedExercisesWithWeights, $targetSize, $approveExFuncRef  ) = @_;
  my $numberAdded = 0;
  print "teacher_user::AddReviewExercises($selectedExercisesWithWeights, $targetSize)\n" if $__trace;

  my $rvwExCnt = $self->ArrayCount("reviewExercisesArray");
  $targetSize = ($targetSize < $rvwExCnt) ? $targetSize : $rvwExCnt;
  for (my $j = 0; $j < $targetSize; $j++)
  {
    my $ex = $self->ArrayGet("reviewExercisesArray", $j);
    if (!$self->IsReviewExercise($ex) || !$self->IsInteresting($ex))
    {
      print "teacher_user::AddReviewExercises: ending loop cuz $ex is not a rvw OR is not interesting\n" if $__trace;
      last;
    }

    if (defined $approveExFuncRef)
    {
      next if !&$approveExFuncRef($ex);
    }
    if (defined $selectedExercises->{"$ex"})
    {
      print "teacher_user::AddReviewExercises: skipping $ex -- it's already in the selected set...\n" if $__trace;
      next;
    }

    my $weight = $self->HashGet("reviewExercisesHash", $ex);
    $weight =~ s/^0+//;
    $selectedExercisesWithWeights->{"$ex/$weight"} = 1;
    $selectedExercises->{           "$ex"}         = 1;
    $numberAdded++;
    print "teacher_user::AddReviewExercises: adding $ex/$weight...\n" if $__trace;
  }
  return $numberAdded;
}

# update exercise weights.
#
# after this routine runs, only the hash is valid.  I don't think I need
# the array anymore, so I just mark it as invalid instead of recreating it.
sub ApplyDeltas
{
  my($self, $weightChangesString) = @_;
  print "teacher_user.pm.ApplyDeltas(" . $self->{"userID"} . ", $weightChangesString): \n" if $__trace;
  if ($weightChangesString)
  {
    my @weightChanges = split(':', $weightChangesString);
    $self->SetValidity("reviewExercisesArray", 0);
    foreach my $weightChange (@weightChanges)
    {
      print "teacher_user.pm.ApplyDeltas($weightChangesString): $weightChange\n" if $__trace;
      if ($weightChange !~ m{(([\w_]+)[_\.]\d+)/ ?\+?(-?\d+)})
      {
        print "teacher_user.pm:ApplyDeltas: odd format ($weightChange) in $weightChangesString";
        next;
      }

      my $reviewExerciseKey = $1;
      my $dataFile = $2;
      my $weightDelta = $3;
      my $weight = $self->HashGet("reviewExercisesHash", $reviewExerciseKey);
      if (defined $weight)
      {
        if ($weightDelta == $__WEIGHT_DELTA_DISCARDING_FROM_REVIEWSET)
        {
          # get the ex out of the rvw ex set, but only barely.  I want exercises which
          # were troublesome at some pt to be higher ranked than ones which were immediately
          # dismissed.
          $weight = ($__LIGHTEST_REVIEW_EXERCISE_WEIGHT - 1);
          print "teacher_user.pm.ApplyDeltas reducing $reviewExerciseKey to $weight...\n" if $__trace;
        }
        else
        {
          $weight += $weightDelta;
          print "teacher_user.pm.ApplyDeltas: $reviewExerciseKey: new weight = $weight...\n" if $__trace;
        }
      }
      else
      {
        $weight = $__LIGHTEST_REVIEW_EXERCISE_WEIGHT + $weightDelta;
        print "teacher_user.pm.ApplyDeltas: $reviewExerciseKey: reset weight = $weight...\n" if $__trace;
      }

      if ($weight <= 0)
      {
        $weight = 1;
        print "teacher_user.pm.ApplyDeltas: $reviewExerciseKey: reset weight = $weight...\n" if $__trace;
      }

      print "teacher_user.pm.ApplyDeltas(): $weightDelta: updating\n" if $__trace;

      $self->HashPut("reviewExercisesHash", $reviewExerciseKey, $weight);
    }
  }
  $self->SaveToDisk();
}

sub IncrementWeights
{
  my($self) = @_;
  my $reviewExercisesHashRef = $self->{"reviewExercisesHash"};
  foreach my $id (keys %$reviewExercisesHashRef)
  {
    my $weight = $reviewExercisesHashRef->{$id};
    $weight += 3;
    if ($weight >= $__LIGHTEST_REVIEW_EXERCISE_WEIGHT
    && IsDataFile($id))
    {
      # we only track "interesting" exercises, not 'data files'
      #
      # increasing the weight for a data file which has been designated to be
      # uninteresting means making it less uninteresting, or, in this case,
      # removing it altogether from the list of uninteresting things.
      delete($reviewExercisesHashRef->{$id});
    }
    $reviewExercisesHashRef->{$id} = $weight;
  }
  $self->SaveAndReinitialize();
}

sub SaveAndReinitialize
{
  my($self) = @_;
  $self->SaveToDisk();
  $self->ReadFromDisk();
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
      
  my $userID = shift;
    
  $self->{"userID"} = $userID;
  $self->ReadFromDisk($userID);
  return $self;
}
1;
