package execute;
use strict;
use IO::File;
use utility_file;

sub go
{
        my($program, $input) = @_;
        my $inputFileName = "tmp.input";
        my $outputFileName = "tmp.output";
        
        my $inputFile = new IO::File("> $inputFileName") or die "could not open $inputFileName: $!";
        binmode $inputFile;
        print $inputFile $input;
        $inputFile->close();
        
        my $command = "$program < $inputFileName > $outputFileName";
        system($command);
        
        my $outputData = utility_file::getContent($outputFileName);
        unlink($inputFileName);
        unlink($outputFileName);
        return $outputData;
}
1;




