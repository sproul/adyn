#!c:/perl/bin/perl.exe
#!c:/cygwin/bin/perl.exe --
my $__local = ((-d "c:/") && 0);
use strict;
use CGI qw(:standard);
use adyn_cgi_util;

my $__dftSize = 1;
my $__trace = 1;
my $__borderSize = $__dftSize;
my $__cellpadding = $__dftSize;
my $__cellspacing = $__dftSize;
my $__mailable = 0;

my $__webSite = ($__local ? "127.0.0.1" : "www.adyn.com");
my $__resumeVersion;
my $__minimalJavaScript = 0;
my %__employersAlreadySeen = ();
my %__employers = ();


my $query;
if (-d "c:/")
{
  $query = new CGI(\*STDIN);
}
else
{
  $query = new CGI;
}

print $query->header(
-status=>'200 OK',
-expires=>'-1d',
-type=>'text/html');


$__employers{"personal"} = "<b>1/1965--present Man on this earth</b>";
$__employers{"BEA"} = "<b>7/2003--present Senior Software Engineer for \n<a href='http://www.bea.com'>BEA</a> (formerly <a href='http://www.plumtree.com'>Plumtree Software</a>), San Francisco, CA</b>";
$__employers{"Monroe"} = "<b>2/2003--8/2003 Web Application Consultant for Monroe Securities, [via telecommute] Rochester, NY</b>";
$__employers{"adynware"} = "<b>7/2001--2/2003 Principal Consultant for \n<a href='http://www.adyn.com'>Adynware Corporation</a>, San Francisco, CA</b>";
$__employers{"extensity"} = "<b>1/1999--7/2001 Software Engineer for \n<a href='http://www.extensity.com'>Extensity Corporation</a>, Emeryville, CA</b>";
$__employers{"adynware.0"} = "<b>9/1997--1/1999 Principal Consultant for \n<a href='http://www.adyn.com'>Adynware Corporation</a>, San Francisco, CA</b>";
$__employers{"whitelight"} = "<b>4/1996--9/1997 Software Engineer for \n<a href='http://www.whitelight.com'>Whitelight Systems</a>, Palo Alto CA </b>";
$__employers{"sybase"} = "<b>4/1992--4/1996 Software Engineer 2 for \n<a href='http://www.sybase.com'>Sybase Corporation</a>, Emeryville, CA </b>";
$__employers{"trw"} = "<b>7/1990--3/1992 Systems Analyst for TRW Corporation, Berkeley, CA </b>";
$__employers{"aion"} = "<b>6/1988--6/1990 Software Development Engineer for Aion Corporation. Palo Alto, CA </b>";
$__employers{"ibm"} = "<b>5/1985--12/1985, 6/1986--8/1986 Systems Programmer for I.B.M. Poughkeepsie, NY</b>";

my @projects = (
[
"BEA", 1,
 "<b>Java/C# Selenium Remote Control Ajax test framework</b>: architected and implemented proxy injection mode (a solution to the cross domain testing problem and the problem of handling multiple frames and windows).  Designed and implemented browser session caching an optimization which tripled Selenium RC's performance.  Designed and implemented drag-and-drop support in <a href=http://www.openqa.org/selenium-core/>Selenium Core</a>.  The work was implemented in Java within the Selenium server, JavaScript within the browser Ajax client (with support for IE, Firefox, Navigator, Konqueror, and Safari), C#  in the remote test client, with build infrastructure using ant and maven."
],
);


my $footer = "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>
<tr>
<td>
<b>Education:</b>
<ul>
<li>University of California at Berkeley, B.S. Computer Science</li>
<li>University of California at Berkeley, B.A. French</li>
</ul>
</td>
</tr>
</table>
</form>
</body>
</html>";



my $cellBegin = "\n<tr><td>";
my $cellEnd = "\n</td></tr>";
my $fullTableBegin = "\n<center><table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>$cellBegin\n";
my $tableBegin = "\n<center><table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=90%>$cellBegin\n";
my $tableEnd = "$cellEnd</table></center>";

my @__savedHtmlTags = ();

sub StripHtmlTags
{
  my($s) = @_;
  my $j = 0;
  $s =~ s/(<.*?>)//g;
  return $s;
}

#my $ss = "a<aa>b<bb>c<cc>";
#$ss = StripHtmlTags($ss);
#print "saved: $ss\n";
#$ss = RestoreHtmlTags($ss);
#print "rest: $ss\n";
#exit();

sub SearchTarget
{
  my($breakLine, $matchWord, $target) = @_;
  my $patternParameter = CGI::escape($target);
  my $s;
  if ($__mailable || $__minimalJavaScript)
  {
    $s =  "\n<b>$target</b>&nbsp;&nbsp;&nbsp;\n";
  }
  else
  {
    $s =  "\n<input value='$target' type=button onclick='G1($matchWord, \"$target\")'>\n";
  }
  $s .= "\n<br>" if $breakLine;
  return $s;
}

sub CleanPattern
{
  my($originalPattern, $matchWord) = @_;
  my $pattern;

  if ($originalPattern and $matchWord)
  {
    $pattern = "\\b$originalPattern\\b";
  }
  else
  {
    $pattern = $originalPattern;
  }
  $pattern =~ s/([+])/\\$1/g;   # prevent '+' from being interpreted as a regexp character

  # prevent a match if the line begins with "<" or ends with "/"
  # the first qualification prevents HTML, the second, JavaScript
  $pattern = "^([^<].*?)?($pattern)" if $pattern;
  #$pattern = "(.)($pattern)" if $pattern;

  return $pattern;
}

sub PrintHeader
{
  my($originalPattern, $pattern, $showAll, $matchCase, $matchWord) = @_;
  #print "<html><head>";
  print adyn_cgi_util::html_header("Nelson Sproul's resume");
  
  if (!$__mailable && !$__minimalJavaScript)
  {
    print "<script language=JavaScript>
    function G1(matchWord, pattern)
    {
      document.searchForm.showAll.value = 0;
      if(matchWord)
      {
        document.searchForm.matchWord.checked = true
      }
      else
      {
        document.searchForm.matchWord.checked = false
      }
      //
      // for some reason, if I skip this substitution, plus signs get stripped off by the time adyn_cgi_util.param gets 'em.  Thus, 'C++' becomes 'C'!
      pattern = pattern.replace(/\\+/g, '%2B');	
      pattern = pattern.replace(/#/g, '%23');	
      document.searchForm.pattern.value = pattern;
      //alert(document.searchForm.pattern.value);
            
      document.searchForm.submit();
    }
    function G2(all)
    {
      document.searchForm.showAll.value = all;
      document.searchForm.pattern.value = '';
      document.searchForm.submit();
    }
    </script>";
  }
  print "<title>Nelson Sproul's resume</title>
  </head>
  <body" . ($__local ? "" : " bgcolor=#cccccc") . "><font face='arial'>
  <script language=JavaScript> function Speak(category)
  {
    window.open('http://$__webSite/cgi-bin/speak.cgi?category=' + category,'Speak','width=300,height=250,screenX=100,screenY=100,alwaysRaised=yes,toolbar=no')
  }
  </script>

  <!--anchor file_consult-->\n";

  if (!$__mailable)
  {
    print "<form name=searchForm action='http://$__webSite/cgi-bin/resume.cgi#searchForm'>\n";
  }
  print "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>
  <tr><td><tr><td colspan=2> <center> <font size=+2> <b><a href='mailto:nelson@"."adyn.com' alt='mail nelson@"."adyn.com'>Nelson Sproul</a></b> </font> </center> </td> </tr><tr> <td>
  <a href='mailto:nelson@"."adyn.com'>nelson@"."adyn.com</a><br>
  1209 Glen<br>
  Berkeley, CA 94708<br>
  510.868.0926<br></td><td>";

  if ($__mailable)
  {
    print "See <a href='http://www.adyn.com/resume/resume.html'>http://www.adyn.com/resume/resume.html</a> for an intelligent version of this resume, supporting searching and filtering.\n";
  }
  else
  {
    print "<input type=hidden name=showAll value=$showAll><input type=hidden name=resumeVersion value=$__resumeVersion>";

    if (!$__minimalJavaScript && !$__mailable)
    {
      if ($pattern)
      {
        print "
        \n<input type=button value='Click to show all projects'      name=x onclick='G2(1)'>
        \n<input type=button value='Click to show career highlights' name=x onclick='G2(0)'>";
      }
      elsif ($showAll)
      {
        print "All projects shown below.
        \n<input type=button value='Click to show only highlights' name=x onclick='G2(0)'><br>\n";
      }
      else
      {
        print "Abridged list of projects below.
        \n<input type=button value='Click to show all projects' name=x onclick='G2(1)'><br>\n";
      }
    }
    print " $fullTableBegin Or search:
    \n<input value=\"$originalPattern\" type=text name=pattern size=12>
    \n<input value='Search Work History' type=submit size=12>
    \n</td><td>
    \n<input value=1 type=checkbox name=matchCase " . ( $matchCase ? "checked":"") . ">Match case<br>
    \n<input value=1 type=checkbox name=matchWord " . ( $matchWord ? "checked":"") . ">Match whole word<br>";
  }
  print "$tableEnd</td> </tr> </table>";
}

sub PrintSearchTargets
{
  print "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%><tr><td>Objective:</td><td><b>Software position where I can use my strong software development skills.</b></td></tr><tr><td>Languages:</td><td>",
  SearchTarget(0, 1, "Java"),
  SearchTarget(0, 1, "Perl"),
  SearchTarget(0, 1, "UML"),
  SearchTarget(0, 1, "XML"),
  SearchTarget(0, 0, "C++"),
  SearchTarget(0, 0, "C#"),
  SearchTarget(0, 1, "SQL"),
  SearchTarget(0, 1, "PL/SQL"),
  SearchTarget(0, 1, "LISP"),
  SearchTarget(0, 1, "yacc"),
  SearchTarget(0, 1, "JavaScript"),
  SearchTarget(0, 1, "Bourne Shell"),
  "\n</td> </tr> <tr> <td> Software: </td> <td>",
  SearchTarget(0, 1, "J2EE"),
  SearchTarget(0, 1, "JDBC"),
  SearchTarget(0, 1, "ODBC"),
  SearchTarget(0, 1, "ClearCase"),
  SearchTarget(0, 1, "Network"),
  #SearchTarget(0, 1, "XSLT"),
  SearchTarget(0, 1, "SOAP"),
  SearchTarget(0, 1, "ant"),
  SearchTarget(0, 1, "Apache"),
  SearchTarget(0, 1, "Tomcat"),
  SearchTarget(0, 1, "IIS"),
  SearchTarget(0, 1, "JUnit"),
  SearchTarget(0, 1, "Prevayler"),
  "\n</td> </tr> <tr> <td> Databases: </td> <td>",
  SearchTarget(0, 1, "Oracle"),
  SearchTarget(0, 1, "MS SQL Server"),
  SearchTarget(0, 1, "Sybase"),
  SearchTarget(0, 1, "MySQL"),
  SearchTarget(0, 1, "MS Access"),
  "\n</td> </tr> <tr> <td> OS: </td> <td>",
  SearchTarget(0, 1, "Unix"),
  SearchTarget(0, 1, "Windows"),

  "$tableEnd";
}

sub OnNewEmployer
{
  my($newEmployer) = @_;
  #print "resume::OnNewEmployer($newEmployer)\n";
  die "out of order project: $newEmployer already seen somewhere else" if defined $__employersAlreadySeen{$newEmployer};
  $__employersAlreadySeen{$newEmployer} = 1;
}


sub BuildResume
{
  my($originalPattern, $showAll, $matchCase, $matchWord) = @_;

  my $pattern = CleanPattern($originalPattern, $matchWord);
  #print "$originalPattern becomes $pattern\n";
  PrintHeader($originalPattern, $pattern, $showAll, $matchCase, $matchWord);
  PrintSearchTargets();

  my $lastEmployer = "";
  my $lastEmployerPrinted = "";
  my $nullResult = 1;
  my $employerHeader = "";
  my $currentEmployerMatchesPattern = 0;

  my $emphasize = "<b><font color=red>";
  my $relax = "</font></b>";

  foreach my $projectVector (@projects)
  {
    my($employer, $significant, $project) = @$projectVector;

    if ($employer ne $lastEmployer)
    {
      $employerHeader = $__employers{$employer};
      next if (!defined $employerHeader);

      OnNewEmployer($employer);

      if ($pattern)
      {
        if ($matchCase)
        {
          $currentEmployerMatchesPattern = ($employerHeader =~ s{$pattern}{$1$emphasize$2$relax}gm);
        }
        else
        {
          $currentEmployerMatchesPattern = ($employerHeader =~ s{$pattern}{$1$emphasize$2$relax}gim);
        }
      }
    }

    print STDERR "pattern=$pattern; project=$project, significant=$significant, resumeVersion=$__resumeVersion\n\n" if $__trace;
    my $printIt;
    if ($currentEmployerMatchesPattern)
    {
      $printIt = 1;
    }
    elsif (!$pattern)
    {
      if ($significant eq "1")
      {
        $printIt = 1;
      }
      elsif ($showAll and ($employer ne "personal") and ($significant !~ /^only_/))
      {
        $printIt = 1;
      }
      elsif ($significant =~ /^only_$__resumeVersion/)
      {
        $printIt = 1;
      }
    }
    else
    {
      my $strippedProject = StripHtmlTags($project);
      #
      # throw in the new line so that the second substitution in the body of the "if"
      # will have a chance to match (the pattern will normally have a prefix preventing
      # a match if there are <> around, as there will be from the font change).  Only by
      # adding a new line can we avoid the <> and match a second instance of the pattern
      # on the same line.  Of course, subsequent instances of the pattern will be ignored.
      #
      #print STDERR "trying: matchCase=$matchCase\npattern=$pattern\nproject=$strippedProject\nemphasize=$emphasize\nrelax=$relax\n";
      
      if (($matchCase and ($pattern and $strippedProject =~ s{$pattern}{$1$emphasize$2$relax\n}gm))
      or (!$matchCase and ($pattern and $strippedProject =~ s{$pattern}{$1$emphasize$2$relax\n}gim)))
      {
	$project =~ s{$pattern}{$1$emphasize$2$relax}gim;
	$printIt = 1;
      }
    }
    print STDERR "hiiiiiiiiiiiiiiiiiiiii\n";
      
    if ($printIt)
    {
      if ($employer ne $lastEmployerPrinted)
      {
	if ($lastEmployerPrinted)
	{
	  print $tableEnd;
	  print $tableEnd;
	}
	$lastEmployerPrinted = $employer;
	print $fullTableBegin;
	print $employerHeader;
	print $tableBegin;
      }
      else
      {
	print $cellBegin;
      }
      $nullResult = 0;
      print $project;
      print $cellEnd;
    }
    
    $lastEmployer = $employer;
  } # foreach project
  if ($nullResult)
  {
    print $fullTableBegin;
    print "Did not see '$originalPattern' in my history.";
  }
  else
  {
    print $tableEnd;
  }
  print $tableEnd;
  print $footer;
}

my $pattern = adyn_cgi_util::param($query, 'pattern');
$pattern = "" unless defined $pattern;

$__mailable      = adyn_cgi_util::param($query, 'mailable');
$__mailable = 0 unless defined $__mailable;

$__resumeVersion = adyn_cgi_util::param($query, 'resumeVersion');
$__resumeVersion = "default";

my $showAll = adyn_cgi_util::param($query, 'showAll');
$showAll = 0 unless defined $showAll;

$__minimalJavaScript = adyn_cgi_util::param($query, 'minimalJavaScript');
$__minimalJavaScript = 0 unless defined $__minimalJavaScript;


my $matchCase = adyn_cgi_util::param($query, 'matchCase');
$matchCase = 0 unless defined $matchCase;

my $matchWord = adyn_cgi_util::param($query, 'matchWord');
$matchWord = 0 unless defined $matchWord;

if ($pattern eq "C")
{
  $matchWord = 1;
}

$matchWord = 0 unless defined $matchWord;

BuildResume($pattern, $showAll, $matchCase, $matchWord);

# xtest with: cd $HOME/Dropbox/adyn/cgi-bin/; (echo showAll=0; echo pattern=picture;)|perl -w resume.cgi
# test with: cd $HOME/Dropbox/adyn/cgi-bin/; (echo showAll=0; echo pattern=C++;)|perl -w resume.cgi > c:/k.html; browser c:/k.html
