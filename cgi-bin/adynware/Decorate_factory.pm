use strict;
package Decorate_factory;
use Decorate;

use vars '@ISA';
require adynware::s_user_factory;
@ISA = qw(s_user_factory);

sub Create
{
        my($self, $target, $status) = @_;
        return Decorate->new($target, $status);
}

sub Configure
{
	my($self, $s) = @_;
	$s = "Decorate::" . $s;
	eval($s);
        if ($@)
        {
		warn "Decorate_factory.pm: eval $s failed:$@";
        }
}


sub new
{
        my $this = shift;
        my $class = ref($this) || $this;
        my $self = {};
        
        bless $self, $class;
        return $self;
}

1;
