package filer;

use strict;
use IO::File;

#=================================================================================
my %utility__diskSizes = ();
my %utility__blockSizes = ();
my %utility__diskSpaceAvailable = ();

sub sniffDisk
{
        my($disk) = @_;
        
        # does not work: why not?
        #my $process = new IO::File("c:/perl/bin/spinach.exe -o c:/perl/disk.$disk -disk $disk |") or die "utility_file::sniffDisk could not execute process";
        #open(PROCESS, "c:/perl/bin/spinach.exe -o c:/perl/disk.$disk -disk $disk |") or die "utility_file::sniffDisk could not execute process";
        #my $processOutput = getContentHandle(PROCESS);
        #print "read ' $processOutput' from process\n";
        #$process->close();
        #
        # the following works, but results in a dos window appearing while the program runs.
        # I believe this window corresponds to cmd.exe.  This happens even if the spawning
        # process is detached.
        # system("c:\\perl\\bin\\setup.exe -o c:/perl/disk.dat -disk $disk");
       
        my $output = getContent("c:/perl/disk.$disk");
        unlink("c:/perl/disk.$disk");
        
        if ($output !~ /block size=(\d+).*disk size=(\d+).*free space=(\d+)/s)
        {
                print "sniffDisk got bad output: '$output'\n";
                print "sniffDisk just guessing...\n";
                                
                $utility__blockSizes{$disk} = 1024;
                $utility__diskSizes{$disk} = 10000000;
                $utility__diskSpaceAvailable{$disk} = 10000000;
        }
        else
        {
                $utility__blockSizes{$disk} = $1;
                $utility__diskSizes{$disk} = $2;
                $utility__diskSpaceAvailable{$disk} = $3;
                print "sniffDisk($disk) saw block size $1, disk size $2, available $3\n";
        }
}


sub RoundFileLength
{
        my($blockSize, $length) = @_;
        return $length unless $length % $blockSize;
        return (int($length/$blockSize) + 1) * $blockSize;
}
sub availableStorage
{
        my($disk) = @_;
                
        sniffDisk($disk) unless $utility__diskSpaceAvailable{$disk};
        return $utility__diskSpaceAvailable{$disk};
}

sub blockSize
{
        my($disk) = @_;
                
        sniffDisk($disk) unless defined $utility__blockSizes{$disk};
        return $utility__blockSizes{$disk};
}
#=================================================================================




sub mv
{
        my($oldName, $newName) = @_;
        unlink($oldName);
        rename($oldName, $newName) or die "mv $oldName $newName failed:$!";
}

sub getContent
{
  my($fileName, $asciiMode) = @_;
        $fileName = substr($fileName, 0, 255) if (length($fileName) >= 255);
        
        my $file = new IO::File("< $fileName") or return "";
	my $content = getContentHandle($file, $asciiMode);
        close $file;
        return $content;
}


sub setContent
{
  my($fileName, $content, $asciiMode) = @_;
        $fileName = substr($fileName, 0, 255) if (length($fileName) >= 255);
        
        my $file = new IO::File("> $fileName") or die "utility_file::setContent could not open $fileName";
	binmode $file unless defined $asciiMode;
        #print "-------------------------------------utility_file::setContent($fileName)\n";
        print $file $content;
        close $file;
}

sub directoryDepth
{
        my($fileName) = @_;
                
        $fileName = $1 if $fileName =~ m{^\./(.*)}; 
        
        my $j;
        for ($j = 0; $fileName =~ m{/}g; $j++)
        {
                ;
        }
        return $j;
}

sub getContentHandle
{
  my($file, $asciiMode) = @_;

        binmode $file unless defined $asciiMode;
        my $contents = "";
        for (;;)
        {
                my $buffer;
                my $n = read($file, $buffer, 9184);
                die "getContentHandle: error reading $file:$!" if $n < 0;
                last if $n==0;
                $contents .= $buffer;
        }
        return $contents;
}

sub cat
{
        my($file1, $file2) = @_;
 
        binmode $file1;
        binmode $file2;
        my $buffer;
        for (;;)
        {
                my $n = read($file1, $buffer, 9184);
                die "error in cat:$!" if $n < 0;
                last if $n==0;
                if (defined $file2)
                {
                        print $file2 $buffer;
                }
                else
                {
                        print STDERR $buffer;                        
                }
        }
}


sub flattenURL
{
        my($name) = @_;
        $name = tameURL($name);
        $name =~ s{/}{_}g;
        return $name;
}

sub tameURL
{
        my($name) = @_;
        die "tameURL got undefined" unless defined $name;
        $name =~ s{^http://}{};
        $name =~ s{[^\d\w/\._-]}{_}g;
        $name =~ s{/+}{/}g;
        $name =~ s{/$}{_};
        return $name;
}

sub basename
{
        my($name) = @_;
        return "" if $name =~ m{^https?://[^/]+(/~\w+)?$};	# no file specified; leading URL root
        return "" if $name =~ m{^https?://.*/$};		# no file specified; trailing /
        return $1 if ($name =~ m{/([^/]*)$});			# normal case
        return "";
}
sub dirname
{
        my($name) = @_;
        return $1 if $name =~ m{^(https?://[^/]+(/~\w+)?)/?$};	# no file specified
        return $1 if $name =~ m{^(https?://.*)/$};		# no file specified; trailing /
        return $name if $name =~ m{\w+://[^/]+$};		# internet protocol with host only
        return $1    if $name =~ m{(.+)/[^/]*$};		# normal case
        return ".";
}

sub mkdirP
{
        my($dir) = @_;
        return 1 if -d $dir;
        return 0 unless mkdirP(dirname($dir));
        return mkdir($dir, '777');
}

sub stripAnchor
{
        my($page) = @_;
        
        my $pageWithoutAnchor;
        if ($page =~ /(.*)#.*/)
        {
                $pageWithoutAnchor = $1;
        }
        else
        {
                $pageWithoutAnchor = $page;
        }
        return $pageWithoutAnchor;
}
                                        
sub isHtml
{
        my($fileName) = @_;
        return ($fileName =~ m{(\.s?html?|/)$}i);
}

sub TimeLastModified
{
  my($fn) = @_;
  my($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($fn);
  return $mtime;
}

sub Newer
{
  my($fn1, $fn2, $verbose) = @_;
  my $timeLastModified1 = TimeLastModified($fn1);
  my $timeLastModified2 = TimeLastModified($fn2);
  
  warn "filer.Newer: cannot get last modified time for $fn1" unless defined $timeLastModified1;
  warn "filer.Newer: cannot get last modified time for $fn2" unless defined $timeLastModified2; 
  
  if (defined $verbose && $verbose)
  {
    print "filer.Newer: $fn1 time=$timeLastModified1; $fn2 time=$timeLastModified2: $timeLastModified1 > $timeLastModified2: " . ($timeLastModified1 > $timeLastModified2 ? 1 : 0) . "\n";
  }
  return $timeLastModified1 > $timeLastModified2;
}

sub cpUpTo
{
  my($fn2, $fn1, $upTo) = @_;
  my $s = utility_file::getContent($fn1);
  die $fn1 unless $s;
  die $s unless $s =~ s/(.*?)$upTo.*/$1/s;
  utility_file::setContent($fn2, $s);
}


1;

## test with: perl -w c:/users/nsproul/work/bin/perl/utility_file.pm
