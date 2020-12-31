use strict;
package DecorateIE_factory;
use DecorateIE;

use vars '@ISA';
require adynware::s_user_factory;
@ISA = qw(s_user_factory);

sub Create
{
        my($self, $target, $status) = @_;
        return DecorateIE->new($target, $status);
}

sub Configure
{
	my($self, $s) = @_;
	$s = "DecorateIE::" . $s;
	eval($s);
        if ($@)
        {
		warn "DecorateIE_factory.pm: eval $s failed:$@";
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
