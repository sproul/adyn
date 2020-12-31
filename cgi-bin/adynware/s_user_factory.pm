use strict;
package s_user_factory;
use adynware::s_user;

sub Create
{
        my($self, $base, $status);
        return s_user->new($base);
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
