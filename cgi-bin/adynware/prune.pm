require 5.004;
use strict;
#use diagnostics;
package prune;
use IO::File;
use adynware::utility_file;
use adynware::utility;

my $prune__blockSize = 0;
my $prune__cacheDirectory = 0;
my %prune__data = ();
my $prune__targetSize = 0;


sub RoundFileLength
{
        my($length) = @_;
        my $rounded = utility_file::RoundFileLength($prune__blockSize, $length);
        #print "rounding($length) = $rounded\n";
        return $rounded;
}

sub Get
{
        my($name, $index) = @_;
        my $value = $prune__data{$name};
        return $$value[$index];
}


sub Length
{
        my($name) = @_;
        return Get($name, 0);
}

sub Time
{
        my($name) = @_;
        return Get($name, 1);
}

sub X
{
        my($name) = @_;
        return Get($name, 2);
}
sub Dump
{
        my($key) = @_;
        my $data = $prune__data{$key};
        my($length, $time, $x) = @$data;
        return "$key:l=$length" . "t=$time" . "x=$x\n";
}

sub ReadCacheDatabase
{
        my $file = new IO::File("< $prune__cacheDirectory/cache.db") or return;
        for (my $j = 0; <$file>; $j++)
        {
                if (/(.*):l=(\d+)t=(\d+)x=(\d+)$/i)
                {
                        my($fileName, $length, $time, $x) = ($1, $2, $3, ($4 - 1));
                        print "examining:$fileName: $length\n";
                        if ($x < 0
                        or $fileName =~ /\.(exe|zip)$/i
                        or $length > utility::GetMaxCacheFileSize())
                        {
                                unlink(utility::GetCacheName($fileName));
                        }
                        else
                        {
                                $prune__data{$fileName} = [$length, $time, $x];
                        }
                }
                else
                {
                        print "cache database line $j ($_) corrupted; correcting...\n";
                }
        }
        $file->close();
}

sub WriteCacheDatabase
{
        my $file = new IO::File("> $prune__cacheDirectory/cache.db") or (utility::Log("could not open $prune__cacheDirectory/cache.db: $!"), return);
        foreach my $key (keys %prune__data)
        {
                print $file Dump($key);
        }
        $file->close();
}

sub GetCurrentSize
{
        my @keys = keys %prune__data;
                        
        my $size = RoundFileLength(67 * scalar(@keys));
                        
        foreach my $key (@keys)
        {
                $size += RoundFileLength(Length($key));
                #print "GetCurrentSize\t$key\t", Length($key), "\t$size\n";
        }
        return $size;
}

sub SortItems
{
        if (Dump($a) !~ /t=(\d+)x=(-?\d+)$/)
        {
                utility::Log("Sort Items:" . Dump($a));
                return -1;
        }
        my($time1, $x1) = ($1, $2);
        
        if (Dump($b) !~ /t=(\d+)x=(-?\d+)$/)
        {
                utility::Log("Sort Items:" . Dump($a));
                return  1;
        }
        my($time2, $x2) = ($1, $2);
                                                                
        return 1 if ($x1 > $x2);
        return -1 if ($x1 < $x2);
        return 1 if ($time1 > $time2);
        return -1 if ($time1 < $time2);
        return 0;
}

sub Prune
{
        my($currentSize, $targetSize, @sortedItems) = @_;
        foreach my $item (@sortedItems)
        {
                print Dump($item);
                my $cacheFileName = utility::GetCacheName($item);
                if (! -f $cacheFileName)
                {
                        print "$cacheFileName does not exist";
                }
                elsif ($targetSize >= $currentSize) 
                {
                        # file exists, but will be deleted
                        unlink("$cacheFileName") or print "could not unlink $cacheFileName:$!\n";
                }
                else
                {
                        next;	# file exists, and wasn't deleted
                }
                my $length = RoundFileLength(Length($item));
                $currentSize -= $length;
                delete($prune__data{$item});
                print "$currentSize---------------$cacheFileName no longer exists ($length)\n";
        }
        print "size is $currentSize";
        return $currentSize;
}

sub RemovePageAndItsChildren
{
        my($target) = @_;
        ReadCacheDatabase();
        my $currentSize = GetCurrentSize();
        foreach my $item (keys %prune__data)
        {
                if ($item =~ $target)
                {
                        my $cacheFileName = utility::GetCacheName($item);
                        unlink("$cacheFileName") or print "could not unlink $cacheFileName ($item):$!\n";
                        $currentSize -= RoundFileLength(Length($item));
                        print "$currentSize----------------------unlinking $cacheFileName\n";
                }
        }
        return $currentSize;
}

sub GatherPrefetchTargets
{
        my($prefetchMaxItems, $sortedItemsReference, $noCacheListReference) = @_;
        if (!$prefetchMaxItems)
        {
                print "prune::GatherPrefetchTargets: prefetchMaxItems==0";
                return ();
        }
                
        my @sortedItems = @$sortedItemsReference;
        my %noCacheList = %$noCacheListReference;
        my @targets = ();
                                                        
        my $cutoffTime = time() - (24 * 60 * 60);
        for (my $j = $#sortedItems; $j > 0; $j--)
        {
                my $page = $sortedItems[$j];
                if (X($page) <= 0)
                {
                        my $cacheFileName = utility::GetCacheName($page);
                        print "prune::Gather prefetch targets: rm $cacheFileName\n";
                        unlink("$cacheFileName") or print "could not unlink $cacheFileName:$!\n";
                        next;                        
                }

                my $itemTime = Time($page);
                defined $itemTime or (utility::Log("Time($page) returned an undefined value"), next);
                print "item:$sortedItems[$j]: ", (time() - $itemTime), "\n";
                                                
                $page =~ m{^(.*?)/};
                my $machine = $1;
                
                if ($cutoffTime > $itemTime 
                and !defined $noCacheList{$page}
                and !defined $noCacheList{"$machine/"})
                {
                        $page =~ m{(.*?)/} or next;
                        my $machine = $1;
                        next if utility::IsImage($page);
                                                                                                
                        my $cacheFileName = utility::GetCacheName($page);
                        if (! -r $cacheFileName)
                        {
                                delete($prune__data{$page});
                        }
                        else
                        {
                                print "	prefetch\n";
                                                        
                                push(@targets, $page);
                                last if scalar(@targets) >= $prefetchMaxItems;
                        }
                }
        }
        return @targets;
}

sub PruneBrowserCatalog
{
        my $file = new IO::File("< $prune__cacheDirectory/b_cache.db") or return;
        my %items = ();
        while (<$file>)
        {
                $items{$_} = 1;
        }
        $file->close();
        $file = new IO::File("> $prune__cacheDirectory/b_cache.db") or (utility::Log("cannot overwrite $prune__cacheDirectory/b_cache.db:$!"), return);
        foreach my $item (keys %items)
        {
                print $file $item;
        }
        $file->close();
}


sub Init
{
        my($blockSize, $cacheDirectory, $limitSize, $prefetchMaxItems, $noCacheListReference) = @_;
        $prune__blockSize      = $blockSize;
        $prune__cacheDirectory = $cacheDirectory;
                        
        if (! -d $prune__cacheDirectory)
        {
                print "prune::Init creating $prune__cacheDirectory\n";
                if (!mkdir($prune__cacheDirectory, '777'))
                {
                        utility::Die("prune could not create $prune__cacheDirectory:$!");
                }
        }

        
        PruneBrowserCatalog();
        
        ReadCacheDatabase();
                
        my $currentSize = GetCurrentSize();
        my @sortedItems = sort SortItems keys %prune__data;
        if ($limitSize < $currentSize)
        {
                $currentSize = Prune($currentSize, $limitSize, @sortedItems);                
                @sortedItems = sort SortItems keys %prune__data;
        }
        my @prefetchTargets = GatherPrefetchTargets($prefetchMaxItems, \@sortedItems, $noCacheListReference);
        WriteCacheDatabase();
                       
        return [$currentSize, @prefetchTargets];
}
1;

