package q_count;
use strict;
use adynware::utility;

my %q__activeQueryCount = ();
my $__imageQueryCount = 0;

sub GetPossibleNonImageQueryCount
{
        return scalar(keys %q__activeQueryCount) - $__imageQueryCount;
}

sub IncrementQueryCount
{
        my($target) = @_;
        #utility::Log("increment query count:fetching $target");
        $__imageQueryCount++ if utility::IsImage($target);
        $q__activeQueryCount{$target} = 1;
}

sub DecrementQueryCount
{
        my($target) = @_;
        #utility::Log("decrement query count:$target done");
        $__imageQueryCount-- if utility::IsImage($target);
        delete($q__activeQueryCount{$target});
}

sub GetQueryCount
{
        return scalar(keys %q__activeQueryCount);
}

sub GetQueryCountString
{
        my @k = keys %q__activeQueryCount;
        my $s = scalar(@k);
        $s .= " active queries";
        if (scalar(@k))
        {
                $s .= ": [ ";
                foreach (@k)
                {
                        $s .= $_ . " ";
                }

                $s .= "]";
        }
        return $s;
}


sub GuardAgainstCorruptQueryCount
{
        my($idleCount) = @_;
        return $idleCount + 1 unless $idleCount > 3;
        # we have been idle for a long time.  Just in case the query count
        # is screwed up, arbitrarily remove a query from the count:
        my @activeQueries = keys %q__activeQueryCount;
        if (@activeQueries)
        {         
                utility::Log("guarding against query count corruption");
                delete($q__activeQueryCount{$activeQueries[0]}) ;
        } 
        return 0;
}


1;
