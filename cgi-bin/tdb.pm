package tdb;
use strict;
use diagnostics;
use ndb_sql;
use iso_8859_1_convert;

my $__db = new ndb_sql("data", "teacher", "^out_");
my $__trace = 0;

sub GetDb
{
  return $__db;
}

sub GetAreaAndIdNumber
{
  my($x) = @_;
  if ($x =~ m{(.*)[_\.](\d+)$})
  {
    return ($1, $2);
  }
  else
  {
    return ($x, 0);
  }
}

sub Set
{
  my($id, $key, $data, $print) = @_;
  #print "tdb::Set($id, $key, " . nutil::ToString($data) . ")\n";
  $data =~ s/\n/ /g if (defined $data);
  $data =~ s/ +/ /g if (defined $data);

  my $oldKey = $key;
  my $oldKey2 = undef; # I call it oldKeyAdditional instead of oldKey2 because if key is "au2", then oldKeyAdditional will be "au" -- I don't want to imply an equivalence of, e.g., oldKey2 to "au2".
  if ($key =~ /(.*[^2])(;;.*)$/)
  {
    $oldKey2 = $1 . "2" . $2;
  }
  elsif ($key =~ /(.*)2(;;.*)$/)
  {
    $oldKey2 = $1 . $2;
  }
  my $oldData  =                     tdb::Get($id, $oldKey);
  my $oldData2 = (defined $oldKey2 ? tdb::Get($id, $oldKey2) : undef);

  my $noChange = ((defined $data && ((defined $oldData && $data eq $oldData) || (defined $oldData2 && $data eq $oldData2)))
  ||             (!defined $data && !defined $oldData));

  $print = $print || $__trace;
  if ($noChange)
  {
    print "tdb::Set($id, $key, " . nutil::ToString($data) . " (oldData=" . nutil::ToString($oldData) . "): no change\n" if $print;
  }
  else
  {
    my($area, $idNumber) = GetAreaAndIdNumber($id);
    $__db->SetA($area, $idNumber, $key, $data);

    if ($print)
    {
      $data = "undef" unless defined $data;
      $oldData = (defined $oldData ? "		[\"$oldData\"]" : "");
      print "tdb::Set($id, $key, $data)$oldData\n\n";
    }
  }
}

sub SetText
{
  my($id, $key, $data) = @_;
  $data = iso_8859_1_convert::DoSplits($data);
  Set($id, $key, $data);
}

sub GetTextOrwarn
{
  my($id, $category) = @_;
  my $text = tdb::Get($id, $category);
  if (!defined $text)
  {
    print "Warning: tdb::GetTextOrwarn($id, $category) got nothing...\n";
    $text = "";
  }
  $text =~ s/{.*?}//g;
  return $text;
}

sub GetText
{
  my($id, $category) = @_;
  my $textMe = tdb::GetTextOrwarn($id, $category);
  $textMe = iso_8859_1_convert::UndoSplits($textMe);
  die "double quotes won't cut it in HTML" if $textMe =~ /"/;  # another " for elisp indent balance
  return $textMe;
}

sub SetTransient
{
  my($lang, $id, $key, $data, $print) = @_;
  #print "tdb::SetTransient($lang, $id, $key, $data)\n";
  die "no data" unless defined $data;	# guard against forgetting $lang parm
  my $adjustedKey = ndb::MakeShadedKey($key, "tmp");
  Set($id, $adjustedKey, $data, $print);
}

sub GetTransient
{
  my($lang, $id, $key) = @_;
  return Get($id, ndb::MakeShadedKey($key, "tmp"));
}



sub GetMatchingKeys
{
  my($id, $regexp) = @_;
  my $hashForThisExercise = tdb::GetHash($id);
  my @x;
  foreach my $key (keys %$hashForThisExercise)
  {
    push @x, $key if ($key=~ /$regexp/);
  }
  return @x;
}


# If 'id' is not a 'place_holder', use it as an address; fetch value of the attribute whose name matches 'key'.
#
# If no such attribute exists, and 'addendKey' is defined and is not a 'place_holder', then
#
#	1. Go to the data addressed by 'id'; fetch value of the attribute whose name matches 'addendKey'.
#	2. Use this value as the 'id' for a new call to Get(id, key).
#
sub Get
{
  my($id, $key, $addendKey) = @_;
  #print "tdb::Get($id, $key, " . nutil::ToString($addendKey) . ")\n";
  
  return undef if $id =~ /\.place_holder$/;

  nutil::Warn($id) unless defined $key;
  my $val;

  my($area, $idNumber) = GetAreaAndIdNumber($id);
  if ($key eq "area")
  {
    $val = $area;
  }
  else
  {
    $val = $__db->GetA($area, $idNumber, $key);
  }

  if (!defined $val && defined $addendKey && $addendKey !~ /\.place_holder$/)
  {
    print "tdb::Get($id, $key, $addendKey)\n" if $__trace;
    my $addendKeyVal = Get($id, $addendKey);
    if (defined $addendKeyVal)
    {
      $val = Get($addendKeyVal, $key);
      print "tdb::Get($id, $key, $addendKey) => $addendKeyVal => " . nutil::ToString($val) . "\n" if $__trace;
    }
    else
    {
      $val = undef;
    }
  }
  print "tdb::Get($id, $key): " . nutil::ToString($val) . "\n" if $__trace;
  return $val;
}


sub GetIncludingTransients
{
  my($category, $x, $key) = @_;
  my $val = Get($x, $key);
  if (!defined $val)
  {
    return GetTransient($category, $x, $key);
  }
  return $val;
}

sub CleanseTransients
{
  my($lang, $area) = @_;
  #print "CleanseTransients($lang, $area)\n";
  $__db->CleanseShade("$lang;;tmp", $area);
}


my $__OnISP = undef;

sub OnISP
{
  if (!defined $__OnISP)
  {
    $__OnISP = !(-d "c:/");
  }
  return $__OnISP;
}

sub GetSize
{
  my($key) = @_;
  my $val;
  if (OnISP() && $key !~ /^out_/ && -f "../httpdocs/teacher/data/out_$key")
  {
    print "tdb::GetSize($key): prepending out_\n" if $__trace;
    $key = "out_$key";
  }

  $val = $__db->GetUnderlyingArraySize($key);
  print "tdb::GetSize($key): $val\n" if $__trace;
  return $val;
}

sub GetOrDie
{
  my($x, $key) = @_;
  my $val = Get($x, $key);
  if (!defined $val)
  {
    die "GetOrDie($x, $key) found nothing";
  }
  return $val;
}

sub Save
{
  print("tdb::Save()\n");
  if ($__db->Save())
  {
    my $markerFileForFormatWorkFn = ".format_data_done"; 
    unlink($markerFileForFormatWorkFn) if -f $markerFileForFormatWorkFn;
  }
}

sub Clear
{
  my($fileKey) = @_;
  $__db->Clear($fileKey);
}

sub Close1
{
  my($fileKey) = @_;
  $__db->Close1($fileKey);
}


sub ShowText
{
  my($id, $lang) = @_;
  my $s = GetText($id, $lang);
  
  
  
  
  # I switched to make the ^D breaks to be revealed as I switch over to
  #       the new scheme for gender and number
  ######################$s =~ s/\^D.//g;
 
 
 
  print "$id $lang ", $s, "\n"; 
}
   
sub IsPropSet
{
  my($id, $propName, @props) = @_;
  #print "tdb::IsPropSet($id, $propName, $props[0], @props)\n";
  my $areas = tdb::Get($id, $propName);
  return 0 unless defined $areas;
  foreach my $possibleArea (@props)
  {
    return 1 if $areas =~ /\|$possibleArea\|/;
  }
  return 0;
}
   
sub PropUnion
{
  my($id, $propName, $propString) = @_;
  foreach my $prop (GetProps($propString))
  {
    SetProp($id, $propName, $prop, 1);
  }
}

sub GetProps
{
  my($propString) = @_;
  $propString =~ s/^\|(.*)\|$/$1/;
  my @props = split(/\|/, $propString);
  return @props;
}
   
sub SetProp
{
  my($id, $propName, $newVal, $adding) = @_;

  $adding = 1 unless defined $adding;

  my $isSet = IsPropSet($id, $propName, $newVal);
  return if ($isSet && $adding) || (!$isSet && !$adding);

  my $totalVal = tdb::Get($id, $propName);

  if (!$adding)
  {
    $totalVal =~ s/$newVal\|//;
    $totalVal = undef if $totalVal eq "|";
  }
  else
  {
    if (defined $totalVal)
    {
      $totalVal .= "$newVal|";
    }
    else
    {
      $totalVal = "|" . $newVal . "|";
    }
  }
  tdb::Set($id, $propName, $totalVal);
}

sub DataModifiedSinceFileWasGenerated
{
  my($areaName, $fn) = @_;
  return $__db->DataModifiedSinceFileWasGenerated($areaName, $fn);
}

sub GetKeys
{
  my($id) = @_;
  my($area, $idNumber) = GetAreaAndIdNumber($id);
  return $__db->KeysA($area, $idNumber);
}

sub GetHash
{
  my($id) = @_;
  my($area, $idNumber) = GetAreaAndIdNumber($id);
  return $__db->GetHash($area, $idNumber, 0);
}

sub Touch
{
  my($dataFile) = @_;
  $__db->Touch($dataFile);
}

sub IsGenerated
{
  my($id, $category) = @_;
  return 0 unless defined tdb::Get($id, 'generated');
  return 1 unless defined tdb::Get($id, "$category/no_gen");
  return 0;
}

sub V
{
  my($val) = @_;
  $__trace = $val;
}

sub GetAddendDeps
{
  my($dataFile) = @_;

  my $addendDeps = tdb::Get("$dataFile.0", "addendDeps");
  if (!defined $addendDeps)
  {
    my $firstAddendKey = tdb::Get("$dataFile.0", "addendKey");
    if (defined $firstAddendKey)
    {
      die $firstAddendKey unless $firstAddendKey =~ /(.*)\.(\d+|place_holder)$/;
      $addendDeps = $1;
    }
  }
  if (!defined $addendDeps || !$addendDeps)
  {
    return ();
  }
  else
  {
    return split(/;/, $addendDeps);
  }
}

sub PropagatePerlToSql_init
{
  my($refresh) = @_;
  $__db->PropagatePerlToSql_init("c:/users/nsproul/tmp/sql", $refresh);
}

sub PropagatePerlToSql_table
{
  my($tableName) = @_;
  $__db->PropagatePerlToSql_table($tableName);
}

sub PropagatePerlToSql_finish
{
  $__db->PropagatePerlToSql_finish();
}

sub Set_arrayOfData
{
  my($id, $key, $arrayRef) = @_;
  my $s = (defined $arrayRef) ? "@$arrayRef" : undef;
  #print "tdb::Set_arrayOfData($id, $key, " . nutil::ToString($arrayRef) . "): " . nutil::ToString($s) . "\n";
  Set($id, $key, $s);
}

sub Get_arrayOfData
{
  my($id, $key) = @_;
  my $arrayRefS = Get($id, $key);
  #print "tdb::Get_arrayOfData($id, $key): " . nutil::ToString($arrayRefS) . "\n";
  if (defined $arrayRefS)
  {
    my @a = split(/ /, $arrayRefS);
    return \@a;
  }
  return undef;
}


sub Cleanup
{
  $__db->Cleanup();
}

1;
