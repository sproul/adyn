use strict;
use diagnostics;

my $breakLongLines = $ARGV[0];

my $s = "";
while (<STDIN>)
{
  $s .= $_;
}
#my $__indentBegin = "!!";
#my $__indentEnd = "##";

$s =~ s{<script.*?</script>}{}gis;
$s =~ s{<!.*?->}{}gis;
$s =~ s{.*<body.*?>}{}is;
$s =~ s{</body>.*}{}is;
$s =~ s{</td>}{<br>}g;
$s =~ s{</li>}{<br>}g;
$s =~ s{</b>:}{:<br>\n}g;
$s =~ s{<input value='(.*?)' type=button .*?>}{ $1 }gis;
$s =~ s{</tr>}{<br>}g;
$s =~ s{\n}{ }g;
$s =~ s{ +}{ }g;
$s =~ s{<br>}{\n}g;
$s =~ s{</?center>}{}g;
$s =~ s{</td></tr>}{\n}g;
#$s =~ s{<table.*?>}{$__indentBegin}g;
#$s =~ s{</table>}{$__indentEnd}g;

$s =~ s/<.*?>//g;
$s =~ s{^\s*Abridged list of projects below.*Languages}{\nLanguages}ms;
$s =~ s{<input value='}{};
$s =~ s{Windows NT Windows}{Windows};
$s =~ s{^[ \t]*}{}gm;

$s =~ s/&gt;/>/g;
$s =~ s/&lt;/</g;
$s =~ s/&quot;/"/g;
$s =~ s/&nbsp;/ /g;
$s =~ s/&amp;/&/g;
$s =~ s/&amp;/&/g;
$s =~ s/\s*,/,/g;
$s =~ s/[A-Z][^\.]* feedback was [^\.]*\.//g;
#$s =~ s{$__indentBegin\s+(\d/\d\d\d\d--)}{$1}g;	# do not indent lines giving employment dates
#$s =~ s{$__indentEnd}{$__indentEnd\n}g;

$s =~ s{Education:}{Education:\n}g;
$s =~ s{\n\n+}{\n\n}g;

if ($breakLongLines)
{
  $s =~ s{([^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n][^\n]\S*)}{$1\n}g;
}

#$s =~ s/$__indentBegin//;	# eliminate indent for the header
#$s =~ s/$__indentEnd//;		# eliminate indent for the header

$s =~ s/^[ \t]+//gm;

#$s =~ s/^(.*?)$__indentBegin/$1\n$__indentBegin/gm;
#$s =~ s/^(.*?)$__indentEnd/$1\n$__indentEnd/gm;

sub IndentIt
{
  my($s) = @_;
  $s =~ s/^[ \t]+//gm;
  $s =~ s/^/   /gm;
  return $s;
}

#$s =~ s/$__indentBegin(.*?)$__indentEnd/IndentIt($1)/egs;

#$s =~ s/$__indentBegin//g;
#$s =~ s/$__indentEnd//g;

$s =~ s{\n\n+}{\n\n}g;

$s =~ s/^[ \t]+$//gm;
$s =~ s{^(\d+/\d\d\d\d--.*?)}{\n$1}gm;
$s =~ s{^(\d+/\d\d\d\d--[^\n]*?)\n([^\n]*?(CA|NY))}{$1 $2}gms;
$s =~ s{\b(CA|NY)\b *}{$1\n}g;


print "$s\n";


1;

