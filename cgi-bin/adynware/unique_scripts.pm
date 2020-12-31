package unique_scripts;
use strict;
use diagnostics;

my @__all = ();


sub create
{
        my($listFormsFirst, $frameGroupID, $frameSetURL) = @_;
        my $x = unique_scripts->new($listFormsFirst, $frameGroupID, $frameSetURL);
        if (scalar(@__all) < 10)
        {
                push(@__all, \$x);
        }
        else
        {
                my $oldestIndex = 0;
                my $y = $__all[0];
                my $oldestAge = $$y->{"age"};
                                                 
                for (my $j = 1; $j < scalar(@__all); $j++)
                {
                        $y = $__all[$j];
                        if ($oldestAge < $$y->{"age"})
                        {
                                $oldestIndex = $j;
                                $oldestAge = $$y->{"age"};
                        }
                }
                $y = $__all[$oldestIndex];
                utility::Log("unique scripts create: ejected group " . $$y->{"frameGroupID"});
                $__all[$oldestIndex] = \$x;
        }
        utility::Log("unique scripts create: added group " . $x->{"frameGroupID"});
        return \$x;
}

sub findFrameGroup
{
        my($target, $removeMatch) = @_;
        foreach my $x (@__all)
        {
                if (defined $$x->matchTarget($target, $removeMatch))
                {
                        utility::Log("unique scripts find frame group($target, $removeMatch): " . $$x->{"frameGroupID"}); #@@
                        return $x;
                }
        }
        utility::Log("unique scripts find frame group($target, $removeMatch): nothing"); #@@
        return undef;
}

sub redirect
{
        my($oldURL, $newURL) = @_;
                
        utility::Log("unique redirect:$oldURL, $newURL");
        
        my $x = findFrameGroup("http://$oldURL", 1);
        return unless defined $x;
        $$x->addFrame($newURL);
}

sub replaceFrame
{
        my($frameGroupID, $documentID, $URL) = @_;
        my $hit = 0;
        foreach my $x (@__all)
        {
                if (!$hit and $$x->getFrameGroupID()==$frameGroupID)
                {
                        $hit = 1;
                        $$x->free($documentID);
                        $$x->addFrame($URL);
                        $$x->adjustAge(-1);
                }
                else
                {
                        $$x->adjustAge(1);
                }
        }
        utility::Log("unique scripts replace frame($frameGroupID, $documentID, $URL): nothing") unless $hit;
}

sub addFrame
{
        my($self, $URL) = @_;
        utility::Log("add frame to group " . $self->{"frameGroupID"} . ":$URL");#@@
        $self->{$URL} = 1;
}

sub adjustAge
{
        my($self, $change) = @_;
        $self->{"age"} += $change;
        utility::Log("adjust age for group " . $self->{"frameGroupID"} . ": " . $self->{"age"});#@@
}

sub matchTarget
{
        my($self, $URL, $removeMatch) = @_;
        return delete($self->{$URL}) if $removeMatch;
        return $self->{$URL};
}

sub getFrameGroupID
{
        my($self) = @_;
        return $self->{"frameGroupID"};
}

sub getIndex
{
        my($self, $documentID, $isLink) = @_;
        my $index = 0;
        my $uniqueAllocation = $self->{"allocation"};
        if (!$isLink and defined $self->{"formFieldIndex"})
        {
                for (; (25 >= $self->{"formFieldIndex"}); $self->{"formFieldIndex"}++)
                {
                        if (!defined $$uniqueAllocation[$self->{"formFieldIndex"}] or !$$uniqueAllocation[$self->{"formFieldIndex"}])
                        {
                                $index = $self->{"formFieldIndex"}++;
                                last;
                        } 
                }
        } 
        if (!$index)
        {
                while (defined $$uniqueAllocation[$self->{"index"}] and $$uniqueAllocation[$self->{"index"}])
                {
                        $self->{"index"}++;
                } 
                $index = $self->{"index"}++;
        }
        $$uniqueAllocation[$index] = $documentID;
        return $index;
}

sub free
{
        my($self, $documentID) = @_;
        my $uniqueAllocation = $self->{"allocation"};
        for (my $j=1; $j < scalar(@$uniqueAllocation); $j++)
        {
                if ($$uniqueAllocation[$j] == $documentID)
                {
                        $$uniqueAllocation[$j] = 0;
                        if (defined $self->{"formFieldIndex"} and ($j <= 25))
                        {
                                $self->{"formFieldIndex"} = $j if ($j < $self->{"formFieldIndex"});
                        }
                        elsif ($j < $self->{"index"})
                        {
                                $self->{"index"} = $j;
                        } 
                }
        }
}


sub new
{
        my $this = shift;
        my $listFormsFirst = shift;
        my $frameGroupID = shift;
        my $frameSetURL = shift;
        my $class = ref($this) || $this;
        my $self = {};
        
        bless $self, $class;
        
        $self->{"age"} = 0;
        $self->{"allocation"} = [];
        $self->{"frameGroupID"} = $frameGroupID;
        $self->{"frameSetURL"} = $frameSetURL;
        if ($listFormsFirst)
        {
                $self->{"index"} = 26;		# counter for generating superscripts for links
                $self->{"formFieldIndex"} = 1;	# counter for generating superscripts for form fields
        }
        else
        {
                $self->{"index"} = 1;		# counter for generating superscripts for all items
        }
        return $self;
}

1;
