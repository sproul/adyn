package s_user;
use strict;


sub DocumentStart
{
        my($self) = @_;
        print "s_user::DocumentStart called\n";
        return "";
}

sub DocumentFinish
{
        my($self) = @_;
        print "s_user::DocumentFinish called\n";
        return "";
}

sub DocumentChunk
{
        my($self, $chunk) = @_;
        print "s_user::DocumentChunk called\n";
        return $chunk;
}

sub Redirect
{
        my($self,$oldURL, $newURL) = @_;
}

sub new
{
        my $this = shift;
        my $base = shift;
        my $class = ref($this) || $this;
        my $self = {};
        bless $self, $class;
        return $self;
}

1;
