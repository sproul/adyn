package English_grammar;

use strict;
use diagnostics;
use arrayOfArrays;

use vars '@ISA';
require generic_grammar;
@ISA = qw(grammar generic_grammar);

sub GetTenses
{
  return [];
}

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->Init("English");
  return $self;
}

1;
