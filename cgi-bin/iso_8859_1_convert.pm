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

#double-s, or sz ligature       ß     DF   &#223; --> ß   &szlig;   --> ß
$convert_me{"DF"} = "BB";
$convert_html{"BB"} = "&szlig;";

#capital A grave                À     C0   &#192; --> À   &Agrave;   --> À
$convert_html{"`A"} = "&Agrave;";
$convert_me{"C0"} = "`A";

#capital A acute                Á     C1   &#193; --> Á   &Aacute;   --> Á
$convert_html{"/A"} = "&Aacute;";
$convert_me{"C1"} = "/A";

#capital A circumflex           Â     C2   &#194; --> Â   &Acirc;    --> Â
$convert_html{"\\^A"} = "&Acirc;";
$convert_me{"C2"} = "^A";

#capital A tilde                Ã     C3   &#195; --> Ã   &Atilde;   --> Ã
$convert_html{"\\~A"} = "&Atilde;";
$convert_me{"C3"} = "~A";

#capital A dieresis or umlaut   Ä     C4   &#196; --> Ä   &Auml;     --> Ä
$convert_html{":A"} = "&Auml;";
$convert_me{"C4"} = ":A";

#capital A ring                 Å     C5   &#197; --> Å   &Aring;    --> Å
$convert_html{"\\.A"} = "&Aring;";
$convert_me{"C5"} = ".A";

#capital AE ligature            Æ     C6   &#198; --> Æ   &AElig;    --> Æ
$convert_html{"AE"} = "&AElig;";
$convert_me{"C6"} = "AE";

#capital C cedilla              Ç     C7   &#199; --> Ç   &Ccedil;   --> Ç
$convert_html{",C"} = "&Ccedil;";
$convert_me{"C7"} = ",C";

#capital E grave                È     C8   &#200; --> È   &Egrave;   --> È
$convert_html{"`E"} = "&Egrave;";
$convert_me{"C8"} = "`E";

#capital E acute                É     C9   &#201; --> É   &Eacute;   --> É
$convert_html{"/E"} = "&Eacute;";
$convert_me{"C9"} = "/E";

#capital E circumflex           Ê     CA   &#202; --> Ê   &Ecirc;    --> Ê
$convert_html{"#E"} = "&Ecirc;";
$convert_me{"CA"} = "#E";

#capital E dieresis or umlaut   Ë     CB   &#203; --> Ë   &Euml;     --> Ë
$convert_html{":E"} = "&Euml;";
$convert_me{"CB"} = ":E";

#capital I grave                Ì     CC   &#204; --> Ì   &Igrave;   --> Ì
$convert_html{"`I"} = "&Igrave;";
$convert_me{"CC"} = "`I";

#capital I acute                Í     CD   &#205; --> Í   &Iacute;   --> Í
$convert_html{"/I"} = "&Iacute;";
$convert_me{"CD"} = "/I";

#capital I circumflex           Î     CE   &#206; --> Î   &Icirc;    --> Î
$convert_html{"#I"} = "&Icirc;";
$convert_me{"CE"} = "#I";

#capital I dieresis or umlaut   Ï     CF   &#207; --> Ï   &Iuml;     --> Ï
$convert_html{":I"} = "&Iuml;";
$convert_me{"CF"} = ":I";

##capital ETH                    Ð     D0   &#208; --> Ð   &ETH;      --> Ð
#$convert_html{"_D"} = "&ETH;";
#$convert_me{"D0"} = "_D";

#capital N tilde                Ñ     D1   &#209; --> Ñ   &Ntilde;   --> Ñ
$convert_html{"\\~N"} = "&Ntilde;";
$convert_me{"D1"} = "~N";

#capital O grave                Ò     D2   &#210; --> Ò   &Ograve;   --> Ò
$convert_html{"`O"} = "&Ograve;";
$convert_me{"D2"} = "`O";

#capital O acute                Ó     D3   &#211; --> Ó   &Oacute;   --> Ó
$convert_html{"/O"} = "&Oacute;";
$convert_me{"D3"} = "/O";

#capital O circumflex           Ô     D4   &#212; --> Ô   &Ocirc;    --> Ô
$convert_html{"#O"} = "&Ocirc;";
$convert_me{"D4"} = "#O";

#capital O tilde                Õ     D5   &#213; --> Õ   &Otilde;   --> Õ
$convert_html{"~O"} = "&Otilde;";
$convert_me{"D5"} = "~O";

#capital O dieresis or umlaut   Ö     D6   &#214; --> Ö   &Ouml;     --> Ö
$convert_html{":O"} = "&Ouml;";
$convert_me{"D6"} = ":O";

#capital O slash                Ø     D8   &#216; --> Ø   &Oslash;   --> Ø
$convert_html{"/O"} = "&Oslash;";
$convert_me{"D8"} = "/O";

#capital U grave                Ù     D9   &#217; --> Ù   &Ugrave;   --> Ù
$convert_html{"`U"} = "&Ugrave;";
$convert_me{"D9"} = "`U";

#capital U acute                Ú     DA   &#218; --> Ú   &Uacute;   --> Ú
$convert_html{"/U"} = "&Uacute;";
$convert_me{"DA"} = "/U";

#capital U circumflex           Û     DB   &#219; --> Û   &Ucirc;    --> Û
$convert_html{"#U"} = "&Ucirc;";
$convert_me{"DB"} = "#U";

#capital U dieresis or umlaut   Ü     DC   &#220; --> Ü   &Uuml;     --> Ü
$convert_html{":U"} = "&Uuml;";
$convert_me{"DC"} = ":U";

#capital Y acute                Ý     DD   &#221; --> Ý   &Yacute;   --> Ý
$convert_html{"/Y"} = "&Yacute;";
$convert_me{"DD"} = "/Y";

#small a grave                  à     E0   &#224; --> à   &agrave;   --> à
$convert_html{"`a"} = "&agrave;";
$convert_me{"E0"} = "`a";

#small a acute                  á     E1   &#225; --> á   &aacute;   --> á
$convert_html{"/a"} = "&aacute;";
$convert_me{"E1"} = "/a";

#small a circumflex             â     E2   &#226; --> â   &acirc;    --> â
$convert_html{"#a"} = "&acirc;";
$convert_me{"E2"} = "#a";

#small a tilde                  ã     E3   &#227; --> ã   &atilde;   --> ã
$convert_html{"~a"} = "&atilde;";
$convert_me{"E3"} = "~a";

#small a dieresis or umlaut     ä     E4   &#228; --> ä   &auml;     --> ä
$convert_html{":a"} = "&auml;";
$convert_me{"E4"} = ":a";

#small a ring                   å     E5   &#229; --> å   &aring;    --> å
$convert_html{"\\.a"} = "&aring;";
$convert_me{"E5"} = ".a";

#small c cedilla                ç     E7   &#231; --> ç   &ccedil;   --> ç
$convert_html{",c"} = "&ccedil;";
$convert_me{"E7"} = ",c";

#small e grave                  è     E8   &#232; --> è   &egrave;   --> è
$convert_html{"`e"} = "&egrave;";
$convert_me{"E8"} = "`e";

#small e acute                  é     E9   &#233; --> é   &eacute;   --> é
$convert_html{"/e"} = "&eacute;";
$convert_me{"E9"} = "/e";

#small e circumflex             ê     EA   &#234; --> ê   &ecirc;    --> ê
$convert_html{"#e"} = "&ecirc;";
$convert_me{"EA"} = "#e";

#small e dieresis or umlaut     ë     EB   &#235; --> ë   &euml;     --> ë
$convert_html{":e"} = "&euml;";
$convert_me{"EB"} = ":e";

#small i grave                  ì     EC   &#236; --> ì   &igrave;   --> ì
$convert_html{"`i"} = "&igrave;";
$convert_me{"EC"} = "`i";

#small i acute                  í     ED   &#237; --> í   &iacute;   --> í
$convert_html{"/i"} = "&iacute;";
$convert_me{"ED"} = "/i";

#small i circumflex             î     EE   &#238; --> î   &icirc;    --> î
$convert_html{"#i"} = "&icirc;";
$convert_me{"EE"} = "#i";

#small i dieresis or umlaut     ï     EF   &#239; --> ï   &iuml;     --> ï
$convert_html{":i"} = "&iuml;";
$convert_me{"EF"} = ":i";

#small eth                      ð     F0   &#240; --> ð   &eth;      --> ð
$convert_html{"#o"} = "&eth;";
$convert_me{"F0"} = "#o";

#small n tilde                  ñ     F1   &#241; --> ñ   &ntilde;   --> ñ
$convert_html{"~n"} = "&ntilde;";
$convert_me{"F1"} = "~n";

#small o grave                  ò     F2   &#242; --> ò   &ograve;   --> ò
$convert_html{"`o"} = "&ograve;";
$convert_me{"F2"} = "`o";

#small o acute                  ó     F3   &#243; --> ó   &oacute;   --> ó
$convert_html{"/o"} = "&oacute;";
$convert_me{"F3"} = "/o";

#small o circumflex             ô     F4   &#244; --> ô   &ocirc;    --> ô
$convert_html{"#o"} = "&ocirc;";
$convert_me{"F4"} = "#o";

#small o tilde                  õ     F5   &#245; --> õ   &otilde;   --> õ
$convert_html{"~o"} = "&otilde;";
$convert_me{"F5"} = "~o";

#small o dieresis or umlaut     ö     F6   &#246; --> ö   &ouml;     --> ö
$convert_html{":o"} = "&ouml;";
$convert_me{"F6"} = ":o";

##small o slash                  ø     F8   &#248; --> ø   &oslash;   --> ø
#$convert_html{"_o"} = "&oslash;";
#$convert_me{"F8"} = "_o";

#small u grave                  ù     F9   &#249; --> ù   &ugrave;   --> ù
$convert_html{"`u"} = "&ugrave;";
$convert_me{"F9"} = "`u";

#small u acute                  ú     FA   &#250; --> ú   &uacute;   --> ú
$convert_html{"/u"} = "&uacute;";
$convert_me{"FA"} = "/u";

#small u circumflex             û     FB   &#251; --> û   &ucirc;    --> û
$convert_html{"#u"} = "&ucirc;";
$convert_me{"FB"} = "#u";

#small u dieresis or umlaut     ü     FC   &#252; --> ü   &uuml;     --> ü
$convert_html{":u"} = "&uuml;";
$convert_me{"FC"} = ":u";

#small y acute                  ý     FD   &#253; --> ý   &yacute;   --> ý
$convert_html{"/y"} = "&yacute;";
$convert_me{"FD"} = "/y";

#small y dieresis or umlaut     ÿ     FF   &#255; --> ÿ   &yuml;     --> ÿ
$convert_html{":y"} = "&yuml;";
$convert_me{"FF"} = ":y";

##capital THORN                  Þ     DE   &#222; --> Þ   &THORN;    --> Þ
#$convert_html{"_P_"} = "&THORN;";
#$convert_me{"DE"} = "_P_";

##small thorn                    þ     FE   &#254; --> þ   &thorn;    --> þ
#$convert_html{"_p_"} = "&thorn;";
#$convert_me{"FE"} = "_p_";

#small ae ligature              æ     E6   &#230; --> æ   &aelig;    --> æ
#############$convert_html{"ae"} = "&aelig;";
#$convert_me{"E6"} = "ae";

#division sign                  ÷     F7   &#247; --> ÷   &divide;   --> ÷
#############$convert_html{"/"} = "&divide;";
$convert_me{"F7"} = "/";

#multiplication sign            ×     D7   &#215; --> ×   &times;    --> ×
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