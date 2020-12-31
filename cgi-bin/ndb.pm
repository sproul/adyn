package ndb;

# $self->{"dataDir"}		points at dir containing the data files
# $self->{"fileKeysHash"}	a hash whose keys match files in the data dir
# Load1 takes a key and grabs the corresponding file, and then evals the contents

use strict;
use diagnostics;
use adynware::utility_file;
use Data::Dumper;

sub Save
{
  my $self = shift;
  my $hashRef = $self->{"fileKeysHash"};
  my $somethingWasSaved = 0;
  foreach my $fileKey (keys %$hashRef)
  {
    next unless defined $self->GetDirty($fileKey);
    $somethingWasSaved = 1;
    my $a = $hashRef->{$fileKey};
    die "ndb::Save: undefined array for $fileKey" unless defined $a;
    print "ndb.Save(fileKey=$fileKey)...\n";

    $self->Save1($fileKey, $a);
  }
  return $somethingWasSaved;
}

sub Save1
{
  my($self, $fileKey, $a) = @_;
  #print "ndb::Save1($fileKey, $a)\n";
  
  if (!defined $a)
  {
    #warn "ndb::Save1($fileKey, undef)\n";
    return;
  }
  
  my $fn = $self->{"dataDir"} . "/" . $fileKey;
  my $f = new IO::File("> $fn") || die "can't open $fn: $!//$?";

  print $f "\@val = (\n";
  for (my $j = 0; $j < scalar(@$a); $j++)
  {
    print $f "{\n";
    
    my $h = $a->[$j];
    foreach my $hKey (sort keys %$h)
    {
      my $val = $h->{$hKey};
      if ($val !~ /^-?\d+$/)
      {
	$val =~ s/'/\\'/g;
	$val = "'$val'";
      }
      print $f "'$hKey' => $val,\n"
    }
    print $f "},\n";
  }
  print $f ");\n";
  $f->close();
}

sub Save1_using_DataDumper
{
  my($self, $fileKey, $val) = @_;
  $Data::Dumper::Purity = 1;
    
  #print "ndb::Save1($fileKey, $val) newing...\n";
  my $Dumper = Data::Dumper->new([ \@$val ], [ qw(*val) ]);
  #print "ndb::Save1($fileKey, $val) Dumping...\n";
  my $newContent = $Dumper->Dump();
  		
  my $fn = $self->{"dataDir"} . "/" . $fileKey;
  utility_file::setContent($fn, $newContent, 1);
  $self->SetDirty($fileKey, undef);
  #print "ndb::Save1($fileKey, $val) -------------------------------------------------------------------------------done\n";
}

sub Close1
{
  my($self, $fileKey) = @_;
  #print "ndb::Close1($fileKey)\n";
  my $hashRef = $self->{"fileKeysHash"};
  if (defined $self->GetDirty($fileKey))
  {
    my $a = $hashRef->{$fileKey};
    $self->Save1($fileKey, $a);
  }
  delete($hashRef->{$fileKey});
}

sub GetUnderlyingFileName
{
  my($self, $fileKey) = @_;
  my $dataDir = $self->{"dataDir"};
  return "$dataDir/$fileKey";
}

sub Load1
{
  my($self, $fileKey) = @_;
  die "illegal file system divider char in key \"$fileKey\"" if $fileKey =~ m{[;:/\s]};
    		
  my $fn = $self->GetUnderlyingFileName($fileKey);
  my $content = utility_file::getContent($fn, 1);
  my $a;
  if ((!defined $content) || (!$content))
  {
    @$a = ();
  }
  else
  {
    my @val;
    #print "Load1($fileKey) eval...";
    ##print "eval(\$h = $content);\n";
    eval("$content");
    if ($@)
    {
      die "ndb::Load1($fileKey) expected perl data in $fn, but the load failed:\n$@";
    } 
    #print " ok\n";
    $a = \@val;
  }
  $self->{"fileKeysHash"}->{$fileKey} = $a;
  ##print "Load1: $fileKey > $a (", ref($a), ")\n";
  return $a;
}

sub Set
{
  my($self, $fileKey, $key, $val) = @_;
  $self->SetA($fileKey, 0, $key, $val);
}

sub MakeShadedKey
{
  my($key, $shade) = @_;
  die $key unless defined $shade && defined $key;
  my $val = "$key;;$shade";
  #print "ndb::MakeShadedKey($key, $shade): $val\n";
  return $val;
}

sub ShadedSet
{
  my($self, $shade, $fileKey, $key, $val) = @_;
  $self->Set($fileKey, MakeShadedKey($key, $shade), $val);
}

sub MatchesShade
{
  my($key, $shade) = @_;
  my $val;
  if ($key =~ m{;;$shade$})
  {
    $val = 1;
  }
  else
  {
    $val = 0; 
  } 
  #print "MatchesShade($key, $shade): $val\n";
  #exit(0) if $key =~ /tmp/;
  return $val; 
}


sub CleanseShade
{
  my($self, $shade, $fileKey) = @_;
  for (my $j = 0;; $j++)
  {
    my $kRef = $self->KeysA($fileKey, $j);
    last unless defined $kRef;
    foreach my $key (@$kRef)
    {
      if (MatchesShade($key, $shade))
      {
	$self->SetDirty($fileKey, 1);
	$self->SetA($fileKey, $j, $key, undef);
	#print "SetA($fileKey, $j, $key, undef);\n";
      } 
    } 
  } 
}

sub Keys
{
  my($self, $fileKey) = @_;
  return $self->KeysA($fileKey, 0);
}

  
sub KeysA
{
  my($self, $fileKey, $x) = @_;
  my $h = $self->GetHash($fileKey, $x, 0);
  if (defined $h)
  {
    return [ keys(%$h) ];
  }
  else
  {
    return undef;
  }
}


sub GetHash
{
  my($self, $fileKey, $x, $growIfNeeded) = @_;
  die "sldkj" unless defined $fileKey;
  my $a = $self->{"fileKeysHash"}->{$fileKey};
  if (!defined $a)
  {
    $a = $self->Load1($fileKey);
  }
  if (!defined $a)
  {
    @$a = ();
    $self->{"fileKeysHash"}->{$fileKey} = $a;
    ##print "GetHash defining array: $a\n";
  } 
  my $h = $a->[$x];
  if ((!defined $h) && $growIfNeeded)
  {
    %$h = ();
    $a->[$x] = $h;
    ##print "GetHash defining hash: $h\n";
  } 
  ##print "GetHash($fileKey, $x): a=$a, h=$h\n";
  return $h;
}

sub SetDirty
{
  my($self, $fileKey, $val) = @_;
  $self->{$fileKey . "_dirty"} = $val;
}

sub GetDirty
{
  my($self, $fileKey) = @_;
  return $self->{$fileKey . "_dirty"};
}

sub SetA
{
  my($self, $fileKey, $x, $key, $val) = @_;
  #print "			inside SetA($self, $fileKey, $x, $key, " . nutil::ToString($val) . ")\n";
  $self->SetDirty($fileKey, 1);
  my $h = $self->GetHash($fileKey, $x, 1);
      
  if (defined $val)
  {
    $h->{$key} = $val;
  } 
  else
  {
    delete($h->{$key});
  } 
}


sub GetUnderlyingArraySize
{
  my($self, $fileKey) = @_;
  my $a = $self->GetUnderlyingArray($fileKey);
  if (defined $a)
  {
    return scalar(@$a);
  }
  else
  {
    return 0;
  }
}
            
sub GetUnderlyingArray
{
  my($self, $fileKey) = @_;
  my $a = $self->{"fileKeysHash"}->{$fileKey};
  
  if (!defined $a)
  {
    $a = $self->Load1($fileKey);
  }
  return $a;
}

sub SetUnderlyingArray
{
  my($self, $fileKey, $a) = @_;
  $self->{"fileKeysHash"}->{$fileKey} = $a;
  $self->SetDirty($fileKey, 1);
}


# access the (0th) hash in fileKey's file.
sub Get
{
  my($self, $fileKey, $key) = @_;
  if ($fileKey !~ /(.*)\.(\d+)/)
  {
    $fileKey .= ".0";
    print "ndb::Get($fileKey, $key), adjusted\n";
  }

  return $self->GetA($fileKey, 0, $key);
}


# access the xth hash in fileKey's file.
sub GetA
{
  my($self, $fileKey, $x, $key) = @_;
  die "GetA" unless defined $x && defined $key && defined $fileKey;
  my $h = $self->GetHash($fileKey, $x, 0);
  if (defined $h)
  {
    return $h->{$key};
  }
  return undef;
}


sub Clear
{
  my($self, $fileKey) = @_;
  $self->{"fileKeysHash"}->{$fileKey} = undef;

  my $fn = $self->GetUnderlyingFileName($fileKey);
  print "Removing $fn...\n";
  unlink($fn);
}


sub Init
{
  my($self, $dataDir) = @_;
  $self->{"dataDir"} = $dataDir;
  $self->{"fileKeysHash"} = ();
}

sub new
{
  my $class = shift;
  my $self = {};
  bless $self, $class;
  my $dataDir = shift;
  $self->Init($dataDir);
  return $self;
}

sub DataModifiedSinceFileWasGenerated
{
  my($self, $fileKey, $generatedFn) = @_;
  my $val = 0;
  if (! -f $generatedFn)
  {
    $val = 1;
  }
  else
  {
    my $dataMTime = $self->TimeLastModified($fileKey);
    die "no dataMTime from $fileKey" unless defined $dataMTime;

    my $fMTime = utility_file::TimeLastModified($generatedFn);
    die "no fMTime from $generatedFn" unless defined $fMTime;

    #print "DataModifiedSinceFileWasGenerated($fileKey, $generatedFn) f: $fMTime, d: $dataMTime\n";

    $val = ($fMTime < $dataMTime);
  }
  print "ndb::DataModifiedSinceFileWasGenerated($fileKey, $generatedFn): $val\n";

  return $val;
}

sub TimeLastModified
{
  my($self, $fileKey) = @_;
  my $fn = $self->GetUnderlyingFileName($fileKey);

  #print "TimeLastModified($fileKey) ($fn)\n";

  return utility_file::TimeLastModified($fn);
}

sub Touch
{
  my($self, $fileKey) = @_;
  $self->SetDirty($fileKey, 1);
  $self->Save();
}


1;

###my $x = new ndb("c:/temp/db");
###$x->Set("key1", "subkey1", "val1");
###$x->Set("key1", "subkey1b", "val1b");
###$x->Set("key2", "subkey2", "val2");
###$x->Set("key2", "subkey2b", "val2b");
###$x->ShadedSet("tmp", "key2", "subkey9tmp", "val9tmp");
###
###print "pre-cleanse key Dump: ";
###foreach my $key ($x->Keys("key2"))
###{
###  print "\"$key\" ";
###}
###print "\n";
###
###$x->CleanseShade("tmp", "key2");
###
###print "post-cleanse key Dump: ";
###foreach my $key ($x->Keys("key2"))
###{
###  print "\"$key\" ";
###}
###print "\n";
###
###$x->Save();
###
###$x = new ndb("c:/temp/db");
###print "key1 subkey1 retrieved ", $x->Get("key1", "subkey1"), "\n";
###
### test with: cd $HOME/work/bin/perl; rm c:/temp/db/*; perl -w ndb.pm; for f in c:/temp/db/*; do; echo here comes $f:; cat $f; done
