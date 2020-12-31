package nobj;
use strict;
use diagnostics;

my $__debugMode = 0;

sub HashGet
{
  my($self, $hashName, $key) = @_;
  die unless defined $key;
  $self->Validate($hashName);
  my $hash = $self->{$hashName};
  return undef unless defined $hash;
  return $hash->{$key};
}

sub HashDelete
{
  my($self, $hashName, $key) = @_;
  if (defined $key)
  {
    $self->Validate($hashName);
    my $hash = $self->{$hashName};
    delete $hash->{$key};
  }
}

sub HashKeys
{
  my($self, $hashName) = @_;
  $self->Validate($hashName);
  my $hash = $self->{$hashName};
  if (defined $hash)
  {
    return keys %$hash;
  }
  return ();
}

sub HashDump
{
  my($self, $hashName) = @_;

  $self->Validate($hashName);
  print STDERR "HashDump($hashName): ";
  my $hash = $self->{$hashName};
  if (!defined $hash)
  {
    print STDERR "undef\n";
  }
  elsif (!$hash)
  {
    print STDERR "empty\n";
  }
  else
  {
    print STDERR "\n";
    foreach my $key (keys %$hash)
    {
      my $val = $hash->{$key};
      nutil::Warn($key) if !defined $val;
      print STDERR "$hashName" . "{" . $key . "} => \"" . $val . "\"\n";
    }
    print STDERR "EOD\n";
  }
}

sub HashPut
{
  my($self, $hashName, $key, $val) = @_;
  $self->SetValidity($hashName, 1);
  print "HashPut($hashName, $key, $val)\n" if $__debugMode;
  my $hash = $self->{$hashName};
  if (!defined $hash)
  {
    my %h = ();
    $hash = \%h;
  }
  if (defined $val)
  {
    $hash->{$key} = $val;
  }
  else
  {
    delete($hash->{$key});
  }
  $self->{$hashName} = $hash;
}

sub HashOfArrays_ArrayCount
{
  my($self, $hashName, $arrayName) = @_;
  my $array = $self->HashGet($hashName, $arrayName);
  my $val;
  if (!defined $array)
  {
    print "nobj::HashOfArrays_ArrayCount($arrayName): undef\n" if $__debugMode;
    $val = 0;
  }
  else
  {
    $val = scalar(@$array);
  }
  print "nobj::HashOfArrays_ArrayCount($arrayName): $val\n" if $__debugMode;
  return $val;
}  

sub HashOfArrays_ArrayDump
{
  my($self, $hashName, $arrayName) = @_;
  my $array = $self->HashGet($hashName, $arrayName);
  if (defined $array)
  {
    Ndmp::A("nobj::HashOfArrays_ArrayDump($arrayName)", @$array);
  }
  else
  {
    print "nobj::HashOfArrays_ArrayDump($arrayName): empty\n";
  }
}

sub HashOfArrays_ArrayGet
{
  my($self, $hashName, $arrayName, $n) = @_;
  my $array = $self->HashGet($hashName, $arrayName);
  return undef unless defined $array;
  return $array->[$n] if defined $n;
  return $array;
}

sub HashOfArrays_ArraySet
{
  my($self, $hashName, $arrayName, $n, $val) = @_;
  my $array = $self->HashGet($hashName, $arrayName);
  if (!defined $array)
  {
    if (!defined $val)
    {
      warn "nobj::HashOfArrays_ArraySet($hashName, $arrayName, $n): strange: no val, so I assume you want to zero out an array entry, and yet no array yet exists in this obj.  Ignoring...\n";
      return;
    }

    my @a = ();
    $array = \@a;
  }
  $array->[$n] = $val;
  $self->HashPut($hashName, $arrayName, $array);
}

sub HashOfArrays_ArrayPush
{
  my($self, $hashName, $arrayName, @vals) = @_;
  die "no val" unless defined $vals[0];
  my $array = $self->HashGet($hashName, $arrayName);
  if (!defined $array)
  {
    $array = [];
  }
  push @$array, @vals;
  $self->HashPut($hashName, $arrayName, $array);
}


sub ArrayCount
{
  my($self, $arrayName) = @_;
  $self->Validate($arrayName);
  my $array = $self->{$arrayName};
  my $val;
  if (!defined $array)
  {
    print "nobj::ArrayCount($arrayName): undef\n" if $__debugMode;
    $val = 0;
  }
  else
  {
    $val = scalar(@$array);
  }
  print "nobj::ArrayCount($arrayName): $val\n" if $__debugMode;
  return $val;
}

sub ArrayDump
{
  my($self, $arrayName) = @_;
  $self->Validate($arrayName);
  my $array = $self->{$arrayName};
  Ndmp::A("nobj::ArrayDump($arrayName)", @$array);
}

sub ArrayGet
{
  my($self, $arrayName, $n) = @_;
  $self->Validate($arrayName);
  my $array = $self->{$arrayName};
  my $val;
  if (!defined $array)
  {
    $val = undef;
  }
  elsif (defined $n)
  {
    $val = $array->[$n];
  }
  else
  {
    $val = $array;
  }
  #print "nobj::ArrayGet($arrayName, $n): " . nutil::ToString($val) . "\n";
  return $val;
}

sub ArraySet
{
  my($self, $arrayName, $n, $val) = @_;
  #print "nobj::ArraySet($arrayName, $n, $val)\n";
  $self->SetValidity($arrayName, 1);
  my $array = $self->{$arrayName};
  if (!defined $array)
  {
    my @a = ();
    $array = \@a;
  }
  $array->[$n] = $val;
  $self->{$arrayName} = $array;
}

sub ArrayPush
{
  my($self, $arrayName, @vals) = @_;
  $self->SetValidity($arrayName, 1);
  my $array = $self->{$arrayName};
  if (!defined $array)
  {
    $array = [];
  }
  push @$array, @vals;
  $self->{$arrayName} = $array;
}

sub SetValidity
{
  my($self, $dataName, $valid) = @_;
  #print "nobj::SetValidity($dataName, $valid)\n" if $__debugMode;
  if ($valid)
  {
    delete($self->{"invalid_$dataName"});
  }
  else
  {
    nutil::Warn("nobj::SetValidity($dataName, 0") if $__debugMode;
    delete($self->{$dataName});
    $self->{"invalid_$dataName"} = 1;
  }
}

sub Validate
{
  my($self, $dataName) = @_;
  nutil::Warn($dataName) if (defined $self->{"invalid_$dataName"});
}

sub GetData
{
  my($self, $name) = @_;
  return $self->{$name};
}


1;
