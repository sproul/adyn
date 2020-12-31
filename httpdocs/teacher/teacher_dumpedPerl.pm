package teacher_DumpedPerl;
use strict;
use diagnostics;
use dumpedPerl;

sub GetFileNames
{
  my($lang) = @_;
  return ("grammar/$lang.dp", "grammar/$lang.dat.htm");
}

sub Load
{
  my($lang, $readyToRegen) = @_;
    
  my ($DumpedFn, $srcFn) = GetFileNames($lang);
   
  if (!defined $readyToRegen || !$readyToRegen)
  {
    $srcFn = undef;
  }
  my $dp = new dumpedPerl($DumpedFn, $srcFn, "\\\$g");
  return $dp->load();
}

sub Save
{
  my($lang, $g) = @_;
    
  if (!$g->{"usingCachedGrammarInfo"})
  {
    my ($DumpedFn, $srcFn) = GetFileNames($lang);
     
    my $dp = new dumpedPerl($DumpedFn, $srcFn, "\\\$g");
    $dp->save($g, qw(*g), "\$g");
  }
}



1;
