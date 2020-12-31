package minimal_grammar;

use o_token;
use Argv_db;
use strict;
use diagnostics;
use arrayOfArrays;

use vars '@ISA';
require generic_grammar;
@ISA = qw(generic_grammar);

sub GetTenses
{
  return [];
}

sub MeToHtml
{
  my($self, $s) = @_;
  # for the foreign language modules, I support a transformation here to convert my personal notation for foreign
  # accents into the standard HTML escape sequences.  But for non-foreign language modules -- i.e., ones which are using
  # this module -- there is no translation step.
  return $s;
}

sub new
{
  my $this = shift;
  my $lang = shift;
  die "need a language" unless defined $lang;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  $self->Init($lang);
  return $self;
}

1;
