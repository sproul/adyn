package ts_grammar;

use o_token;
use Argv_db;
use strict;
use diagnostics;
use arrayOfArrays;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->Init("ts");
  return $self;
}

1;
