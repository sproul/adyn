package Vtl;

use strict;
use diagnostics;

sub Conclusions
{
  my $winners = $self->{"vtlVals"}->[0];
  return @$winners;
}

sub VerbTableDataParse
{
  my($self->$rawData) = @_;
  my @rawVals = split(/;/, $rawData);
  my @vtlVals = ();
  for (my $j = 0; $j < scalar(@rawVals); $j++)
  {
    my @entryVals = split(/\//, $rawData[$j]);
    push @vtlVals, \@entryVals;
  }
  return \@vtlVals;
} 

sub IsAmbiguous
{
  my $vtlVals = $self->{"vtlVals"};
  die "oops" unless (defined $vtlVals);
  return scalar(@$vtlVals) > 1;
}


sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
              
  my $rawData = shift;
    
  if (defined $rawData)
  {
    $self->{"vtlVals"} = VerbTableDataParse($rawData);
    #print "Vtl.new: found nothing for $token\n";
  } 
  bless $self, $class;
    	
  return $self;
}


# test with: perl -w $DROP/adyn/httpdocs/teacher/Vtl.pm
