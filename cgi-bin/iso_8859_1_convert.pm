package iso_8859_1_convert;
use strict;
use diagnostics;
use nutil;
use filer;

# *.text: raw files from web translators, containing data from foreign character sets
# *.text.me: *.text converted to my U.S. character set scheme for foreign
#	characters (e.g., /e, `a, etc.)
# *.text.hmtl: html
#

my %convert_html;
my %convert_me;

# Because I want constructions like "d'aller" to be treated as to separate tokens by the highlighting logic, and because breaking up the tokens by anything except white space is a pain in the ass, I am inserting extra spaces to split these tokens.  I also add a marker to indicate that the spaces are temporary and should not be visible to end-users.  So, the trick is to change "d'aller" to "d'^D aller", but to leave "he said, 'what?'" alone.

# I didn't use ^H after the space because I didn't want to mess up the token lookups for the word following the apostrophe.

#spanish ?, !
$convert_me{"BF"} = "_?";
$convert_html{"_\\?"} = "&iquest;";

$convert_me{"A1"} = "_!";
$convert_html{"_!"} = "&iexcl;";

#double-s, or sz ligature       �     DF   &#223; --> �   &szlig;   --> �
$convert_me{"DF"} = "BB";
$convert_html{"BB"} = "&szlig;";

#capital A grave                �     C0   &#192; --> �   &Agrave;   --> �
$convert_html{"`A"} = "&Agrave;";
$convert_me{"C0"} = "`A";

#capital A acute                �     C1   &#193; --> �   &Aacute;   --> �
$convert_html{"/A"} = "&Aacute;";
$convert_me{"C1"} = "/A";

#capital A circumflex           �     C2   &#194; --> �   &Acirc;    --> �
$convert_html{"\\^A"} = "&Acirc;";
$convert_me{"C2"} = "^A";

#capital A tilde                �     C3   &#195; --> �   &Atilde;   --> �
$convert_html{"\\~A"} = "&Atilde;";
$convert_me{"C3"} = "~A";

#capital A dieresis or umlaut   �     C4   &#196; --> �   &Auml;     --> �
$convert_html{":A"} = "&Auml;";
$convert_me{"C4"} = ":A";

#capital A ring                 �     C5   &#197; --> �   &Aring;    --> �
$convert_html{"\\.A"} = "&Aring;";
$convert_me{"C5"} = ".A";

#capital AE ligature            �     C6   &#198; --> �   &AElig;    --> �
$convert_html{"AE"} = "&AElig;";
$convert_me{"C6"} = "AE";

#capital C cedilla              �     C7   &#199; --> �   &Ccedil;   --> �
$convert_html{",C"} = "&Ccedil;";
$convert_me{"C7"} = ",C";

#capital E grave                �     C8   &#200; --> �   &Egrave;   --> �
$convert_html{"`E"} = "&Egrave;";
$convert_me{"C8"} = "`E";

#capital E acute                �     C9   &#201; --> �   &Eacute;   --> �
$convert_html{"/E"} = "&Eacute;";
$convert_me{"C9"} = "/E";

#capital E circumflex           �     CA   &#202; --> �   &Ecirc;    --> �
$convert_html{"#E"} = "&Ecirc;";
$convert_me{"CA"} = "#E";

#capital E dieresis or umlaut   �     CB   &#203; --> �   &Euml;     --> �
$convert_html{":E"} = "&Euml;";
$convert_me{"CB"} = ":E";

#capital I grave                �     CC   &#204; --> �   &Igrave;   --> �
$convert_html{"`I"} = "&Igrave;";
$convert_me{"CC"} = "`I";

#capital I acute                �     CD   &#205; --> �   &Iacute;   --> �
$convert_html{"/I"} = "&Iacute;";
$convert_me{"CD"} = "/I";

#capital I circumflex           �     CE   &#206; --> �   &Icirc;    --> �
$convert_html{"#I"} = "&Icirc;";
$convert_me{"CE"} = "#I";

#capital I dieresis or umlaut   �     CF   &#207; --> �   &Iuml;     --> �
$convert_html{":I"} = "&Iuml;";
$convert_me{"CF"} = ":I";

##capital ETH                    �     D0   &#208; --> �   &ETH;      --> �
#$convert_html{"_D"} = "&ETH;";
#$convert_me{"D0"} = "_D";

#capital N tilde                �     D1   &#209; --> �   &Ntilde;   --> �
$convert_html{"\\~N"} = "&Ntilde;";
$convert_me{"D1"} = "~N";

#capital O grave                �     D2   &#210; --> �   &Ograve;   --> �
$convert_html{"`O"} = "&Ograve;";
$convert_me{"D2"} = "`O";

#capital O acute                �     D3   &#211; --> �   &Oacute;   --> �
$convert_html{"/O"} = "&Oacute;";
$convert_me{"D3"} = "/O";

#capital O circumflex           �     D4   &#212; --> �   &Ocirc;    --> �
$convert_html{"#O"} = "&Ocirc;";
$convert_me{"D4"} = "#O";

#capital O tilde                �     D5   &#213; --> �   &Otilde;   --> �
$convert_html{"~O"} = "&Otilde;";
$convert_me{"D5"} = "~O";

#capital O dieresis or umlaut   �     D6   &#214; --> �   &Ouml;     --> �
$convert_html{":O"} = "&Ouml;";
$convert_me{"D6"} = ":O";

#capital O slash                �     D8   &#216; --> �   &Oslash;   --> �
$convert_html{"/O"} = "&Oslash;";
$convert_me{"D8"} = "/O";

#capital U grave                �     D9   &#217; --> �   &Ugrave;   --> �
$convert_html{"`U"} = "&Ugrave;";
$convert_me{"D9"} = "`U";

#capital U acute                �     DA   &#218; --> �   &Uacute;   --> �
$convert_html{"/U"} = "&Uacute;";
$convert_me{"DA"} = "/U";

#capital U circumflex           �     DB   &#219; --> �   &Ucirc;    --> �
$convert_html{"#U"} = "&Ucirc;";
$convert_me{"DB"} = "#U";

#capital U dieresis or umlaut   �     DC   &#220; --> �   &Uuml;     --> �
$convert_html{":U"} = "&Uuml;";
$convert_me{"DC"} = ":U";

#capital Y acute                �     DD   &#221; --> �   &Yacute;   --> �
$convert_html{"/Y"} = "&Yacute;";
$convert_me{"DD"} = "/Y";

#small a grave                  �     E0   &#224; --> �   &agrave;   --> �
$convert_html{"`a"} = "&agrave;";
$convert_me{"E0"} = "`a";

#small a acute                  �     E1   &#225; --> �   &aacute;   --> �
$convert_html{"/a"} = "&aacute;";
$convert_me{"E1"} = "/a";

#small a circumflex             �     E2   &#226; --> �   &acirc;    --> �
$convert_html{"#a"} = "&acirc;";
$convert_me{"E2"} = "#a";

#small a tilde                  �     E3   &#227; --> �   &atilde;   --> �
$convert_html{"~a"} = "&atilde;";
$convert_me{"E3"} = "~a";

#small a dieresis or umlaut     �     E4   &#228; --> �   &auml;     --> �
$convert_html{":a"} = "&auml;";
$convert_me{"E4"} = ":a";

#small a ring                   �     E5   &#229; --> �   &aring;    --> �
$convert_html{"\\.a"} = "&aring;";
$convert_me{"E5"} = ".a";

#small c cedilla                �     E7   &#231; --> �   &ccedil;   --> �
$convert_html{",c"} = "&ccedil;";
$convert_me{"E7"} = ",c";

#small e grave                  �     E8   &#232; --> �   &egrave;   --> �
$convert_html{"`e"} = "&egrave;";
$convert_me{"E8"} = "`e";

#small e acute                  �     E9   &#233; --> �   &eacute;   --> �
$convert_html{"/e"} = "&eacute;";
$convert_me{"E9"} = "/e";

#small e circumflex             �     EA   &#234; --> �   &ecirc;    --> �
$convert_html{"#e"} = "&ecirc;";
$convert_me{"EA"} = "#e";

#small e dieresis or umlaut     �     EB   &#235; --> �   &euml;     --> �
$convert_html{":e"} = "&euml;";
$convert_me{"EB"} = ":e";

#small i grave                  �     EC   &#236; --> �   &igrave;   --> �
$convert_html{"`i"} = "&igrave;";
$convert_me{"EC"} = "`i";

#small i acute                  �     ED   &#237; --> �   &iacute;   --> �
$convert_html{"/i"} = "&iacute;";
$convert_me{"ED"} = "/i";

#small i circumflex             �     EE   &#238; --> �   &icirc;    --> �
$convert_html{"#i"} = "&icirc;";
$convert_me{"EE"} = "#i";

#small i dieresis or umlaut     �     EF   &#239; --> �   &iuml;     --> �
$convert_html{":i"} = "&iuml;";
$convert_me{"EF"} = ":i";

#small eth                      �     F0   &#240; --> �   &eth;      --> �
$convert_html{"#o"} = "&eth;";
$convert_me{"F0"} = "#o";

#small n tilde                  �     F1   &#241; --> �   &ntilde;   --> �
$convert_html{"~n"} = "&ntilde;";
$convert_me{"F1"} = "~n";

#small o grave                  �     F2   &#242; --> �   &ograve;   --> �
$convert_html{"`o"} = "&ograve;";
$convert_me{"F2"} = "`o";

#small o acute                  �     F3   &#243; --> �   &oacute;   --> �
$convert_html{"/o"} = "&oacute;";
$convert_me{"F3"} = "/o";

#small o circumflex             �     F4   &#244; --> �   &ocirc;    --> �
$convert_html{"#o"} = "&ocirc;";
$convert_me{"F4"} = "#o";

#small o tilde                  �     F5   &#245; --> �   &otilde;   --> �
$convert_html{"~o"} = "&otilde;";
$convert_me{"F5"} = "~o";

#small o dieresis or umlaut     �     F6   &#246; --> �   &ouml;     --> �
$convert_html{":o"} = "&ouml;";
$convert_me{"F6"} = ":o";

##small o slash                  �     F8   &#248; --> �   &oslash;   --> �
#$convert_html{"_o"} = "&oslash;";
#$convert_me{"F8"} = "_o";

#small u grave                  �     F9   &#249; --> �   &ugrave;   --> �
$convert_html{"`u"} = "&ugrave;";
$convert_me{"F9"} = "`u";

#small u acute                  �     FA   &#250; --> �   &uacute;   --> �
$convert_html{"/u"} = "&uacute;";
$convert_me{"FA"} = "/u";

#small u circumflex             �     FB   &#251; --> �   &ucirc;    --> �
$convert_html{"#u"} = "&ucirc;";
$convert_me{"FB"} = "#u";

#small u dieresis or umlaut     �     FC   &#252; --> �   &uuml;     --> �
$convert_html{":u"} = "&uuml;";
$convert_me{"FC"} = ":u";

#small y acute                  �     FD   &#253; --> �   &yacute;   --> �
$convert_html{"/y"} = "&yacute;";
$convert_me{"FD"} = "/y";

#small y dieresis or umlaut     �     FF   &#255; --> �   &yuml;     --> �
$convert_html{":y"} = "&yuml;";
$convert_me{"FF"} = ":y";

##capital THORN                  �     DE   &#222; --> �   &THORN;    --> �
#$convert_html{"_P_"} = "&THORN;";
#$convert_me{"DE"} = "_P_";

##small thorn                    �     FE   &#254; --> �   &thorn;    --> �
#$convert_html{"_p_"} = "&thorn;";
#$convert_me{"FE"} = "_p_";

#small ae ligature              �     E6   &#230; --> �   &aelig;    --> �
#############$convert_html{"ae"} = "&aelig;";
#$convert_me{"E6"} = "ae";

#division sign                  �     F7   &#247; --> �   &divide;   --> �
#############$convert_html{"/"} = "&divide;";
$convert_me{"F7"} = "/";

#multiplication sign            �     D7   &#215; --> �   &times;    --> �
#############$convert_html{"X"} = "&times;";
$convert_me{"D7"} = "X";


sub DoSplits
{
  my($s) = @_;
  $s =~ s/u'\^D est-ce/u'est-ce/g;	# Undo qu'est-ce (qui, etc.) splits
  $s =~ s/([Ee]st)-\^D ce/$1-ce/g;	# Undo est-ce splits
  $s =~ s/(\S)'(\S)/$1'^D $2/g;		# split d'aller into d'^D aller
  $s =~ s/([^a])n'\^D t/$1^D n't/g;	# split English "don't", "didn't", etc. as do/n't, etc -- but not can't
  $s =~ s/\bcannot\b/can^D not/g;		# split English "cannot"
  $s =~ s/(\S)-(\S)/$1-^D $2/g;		# split est-il into est-^D il...
  $s =~ s/([Ee]st)-\^D ce/$1-ce/g;	# ...but not if it's est-ce
  $s =~ s/([Pp]eut)-\^D \^etre/$1-^etre/g;# ...and not if it's peut-^etre
  $s =~ s/([Cc])'\^D est\b/$1'est/g;	# ...and not if it's c'est
  $s =~ s/-\^D est/-est/g;		# ...and not if it's sud-est, etc.
  $s =~ s/u'\^D est-ce/u'est-ce/g;	# ...and not if it's qu'est-ce (qui, etc.)
  $s =~ s/(ujourd)'\^D (hui)\b/$1'$2/g;	# ...and not if it's aujourd'hui

  $s =~ s/\^D \^D/^D/g;			# stop double processing

  return $s;
}

sub UndoSplits
{
  my($s) = @_;
  $s =~ s/\^D.//g;
  return $s;
}


sub RawToMe
{
  my($s) = @_;
  foreach my $from (keys %convert_me)
  {
    my $to = $convert_me{$from};
    $s =~ s/\x$from/$to/g;
  }
  return DoSplits($s);
}


sub MeToHtml
{
  my($s) = @_;
  #$s =~ s/\^D.//g;

  my $notReviewedString = "__notReviewedString__";
  $s =~ s{^//}{$notReviewedString};

  my $tagString = "_xXx_";
  $s =~ s{</(\w)>}{$tagString$1}g;

  foreach my $from (keys %convert_html)
  {
    my $to = $convert_html{$from};
    $s =~ s/$from/$to/g;
  }
  $s =~ s{^$notReviewedString}{//};
  $s =~ s{$tagString(\w)}{</$1>}g;
  $s =~ s/_h/h/g;	# get rid of French aspirated H indicator
  return $s;
}

sub HtmlToMe
{
  my($s) = @_;
  print "got $s\n";
  foreach my $to (keys %convert_html)
  {
    my $from = $convert_html{$to};
    $to =~ s/^\\//;		# I was escaping some regexp characters w/ a leading back-slash, but I don't need to do this in this context, since it's a 'to' string, not a 'from'
    $s =~ s/$from/$to/g;
  }
  print "made $s\n";
  return $s;
}


#
# generate *.me, *.html from a raw (i.e., possibly foreign character set) file
#
sub ProcessRawFile
{
	my($fn) = @_;
	my $s;
	
	if (-e "$fn.me")
	{
		print "NOT generating $fn.me; it already exists\n";
		$s = filer::getContent("$fn.me");
	}
	else
	{
		print "Generating $fn.me from $fn...\n";
		$s = filer::getContent("$fn");
		$s = RawToMe($s);
		filer::setContent("$fn.me", $s);
	}
	
	print "Generating $fn.html from $fn.me...\n";
	filer::setContent("$fn.html", MeToHtml($s));
}
1;




# test with: cd e:/users/nsproul/Dropbox/adyn/httpdocs/teacher/data;rm fr.text.me;  perl -w ../iso_8859_1_convert.pl fr.text; diff fr.text.html fr.text.me


#print MeToHtml("Er i_st!"), "\n";
# test with: cd $HOME/Dropbox/adyn/httpdocs/teacher/;  perl -w iso_8859_1_convert.pm