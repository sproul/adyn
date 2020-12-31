package js;
use strict;
use diagnostics;

sub MakeJavaScriptArray_fromArrayOfArrays
{
  my($name, $arrayRef) = @_;
  my $s = "$name = new Array(";
  my $firstTimeThroughLoop = 1;
  foreach my $outer (@$arrayRef)
  {
    foreach my $inner (@$outer)
    {
      if ($firstTimeThroughLoop)
      {
	$firstTimeThroughLoop = 0;
      }
      else
      {
	$s .= ",";
      }
      $s .= "\"$inner\"";
    }
  }
  $s .= ")";
  
  $s =~ s/\n/ /g;
  $s =~ s/ +/ /g;
  
  return $s . "\n";
}  

1;
