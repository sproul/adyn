package Settings;
use strict;
#use diagnostics;
use adynware::utility_file;
use Data::Dumper;

sub save
{
        my $self = shift;
        my($valuesReference, $namesReference) = @_;
        $Data::Dumper::Purity = 1;
        my $dumper = Data::Dumper->new($valuesReference, $namesReference);
        my $newContent = $dumper->Dump();
                        
        my $file = $self->{"file"};
        my $oldContent = utility_file::getContent("$file.ini");
        utility_file::setContent("$file.old", $oldContent);
        utility_file::setContent("$file.ini", $newContent);
}

sub load
{
        my($self) = @_;
        my $file = $self->{"file"};
        my $error = 0;
        my $content = utility_file::getContent("$file.ini");
        if (!$content)
        {
                print "Settings::load could not load $file.ini\n";
                $content = utility_file::getContent("$file.old");
                print "Settings::load could not load $file.old\n" unless $content;
        }
        if ($content)
        {
                $content =~ s/\015//g;
                return $content;
        }
        return "";
}

sub new
{
        my $class = shift;
        my $self = {};
        bless $self, $class;
        $self->{"file"} = shift;
        return $self;
}

1;
