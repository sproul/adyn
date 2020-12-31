my $__trace = 0;
use strict;
use HTTP::Request;
use LWP::UserAgent;
use diagnostics;
use IO::File;
use adynware::utility_file;
use tdb;


my $__topic = $ARGV[0];
my $__x = 0;

sub fetch1Html
{
  my($topic, $url) = @_;
  die "cannot retrieve base name from $url" unless $url =~ m{/([^/]+)$};
  my $baseName = $1;
  my $localFn = "transform_into_flashcards/topics/$topic/html/$baseName";
  #print "transform_into_flashcards::fetch1Html($url) -> $localFn\n";
  if (-f $localFn)
  {
    #print "  already got it\n";
  }
  else
  {
    my $request = HTTP::Request->new("POST");
    $request->url($url);
    my $ua = new LWP::UserAgent();
    my $response = $ua->request($request);
    my $s;
    if ($response->is_success)
    {
      $s = $response->content;
    }
    else
    {
      $s = $response->error_as_HTML;
    }

    $s =~ s/\r//g;
    utility_file::setContent($localFn, $s, 1);
  }
  return $localFn;
}

sub parseQA
{
  my($topic, $url) = @_;
  warn "qa not impl";
}

sub fetchData
{
  my($topic) = @_;
  my $urlsFn = "c:/users/nsproul/work/doc/facts/$topic.facts";
  die $urlsFn unless -f $urlsFn;

  my $f = new IO::File("< $urlsFn");
  die "cannot open $urlsFn" unless defined $f;
  my @localFns = ();
  while (<$f>)
  {
    chomp;
    my $url = $_;

    my $localFn = undef;
    if ($url =~ /^http:/)
    {
      $localFn = fetch1Html($topic, $url);
    }
    else
    {
      $localFn = $url;
    }

    push @localFns, $localFn;
  }

  $f->close();
  return @localFns;
}

sub initUser
{
  my($topic) = @_;
  my $user_dir = "$ENV{'DROP'}/adyn/httpdocs/teacher/usr/";
  if (-d "$user_dir/$topic")
  {
    #print "transform_into_flashcards::initUser($topic): already done\n";
  }
  else
  {
    system("mkdir $user_dir/$topic");
    utility_file::setContent("$user_dir/$topic/ip", "127.0.0.1", 1);
    utility_file::setContent("$user_dir/$topic/pw", "x", 1);
  }
}

sub getContent
{
  my($localFn) = @_;

  my $s = utility_file::getContent($localFn, 1);
  $s =~ s/{/&#123;/g;
  $s =~ s/}/&#125;/g;
  
  return $s;
}

sub FormatClassBrowserOutput_methods
{
  my($methods) = @_;
  $methods =~ s{^(.*)\s+([-!@]*?\w+\(.*\).*)}{<tr><td width=20%>$1</td><td>$2</td></tr>}gm;
  $methods =~ s{<td>(.*?)!</td>}{<td>!!$1!!</td>}g;
  if ($methods)
  {
    $methods = "<table border=1 cellpadding=0 cellspacing=0 width=100%>$methods</table>";
  }

  return $methods;
}

sub FormatClassBrowserOutput_1class
{
  my($s) = @_;
  #
  # previously I separated the class name from the methods with something like
  #             ^( *)(([\.\w])+) __.*?\n(.*)}
  # but then classes which don't have any methods, and therefore don't have any embedded carriage returns in the
  # argument to this routine, do not get processed at all.  That's why I switched it to the following:
  #
  $s =~ s{^( *)(([\.\w])+) __[^\n]*\n?(.*)}{"$1<font size=-1>$2</font>" . FormatClassBrowserOutput_methods($4)}es;
  $s =~ s{\n}{}g;	# eventually all carriage returns are replaced by <br>, which we won't need within this output
  return $s;
}

sub FormatClassBrowserOutput
{
  my($s) = @_;
  while ($s =~ s/^( *([\.\w])+ __.*?)(\n *([\.\w])+ __)/"!" . FormatClassBrowserOutput_1class($1) . $3/ems)
  {
    ;
  }
  $s =~ s/^( *([\.\w])+ ___.*)/FormatClassBrowserOutput_1class($1)/egms;

  $s =~ s/^!//gm;
  return $s;
}

sub prepAsHtml
{
  my($s) = @_;

  #print "transform_into_flashcards::prepAsHtml($s)...\n";
  $s =~ s/\s*$//s;
  my $firstNonWhiteSpaceColumn = 999;
  while ($s =~ /^(\s*)/gm)
  {
    my $x = length($1);
    last if $x==0;
    $firstNonWhiteSpaceColumn = $x if $x < $firstNonWhiteSpaceColumn;
  }
  my $before = (' ' x $firstNonWhiteSpaceColumn);
  $s =~ s/^$before//gm;

  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;

  $s =~ s/\\/&#092;/g;

  $s =~ s/{/&#123;/g;
  $s =~ s/}/&#125;/g;

  $s =~ s{&lt;(/?(b|blockquote|br|code|h\d|i|li|ol|p|pre|ul))&gt;}{<$1>}gi;	# allow some HTML tags
  $s =~ s{&lt;(/?(a|table|td|tr)( .*?)?)&gt;}{<$1>}gi;				# allow some HTML tags with attributes
  $s =~ s/\s*$//;
  $s =~ s{\s*(</?(font|ul|ol|li|table|td|tr)>)\s*}{$1}gi;			# tighten up the lists, tables
  $s =~ s/<a href/<a target=win2 href/g;
  $s =~ s/^                                                //gm;
  $s =~ s/^\s*//s;
  $s =~ s/^( *([\.\w]+) ____.*)/FormatClassBrowserOutput($1)/egms;
  #print "transform_into_flashcards::prepAsHtml(): $s\n\n";
  $s =~ s/^(\s+)/'&nbsp;' x length($1)/egm;
  $s =~ s/\n/<br>/g;
  $s =~ s{!!(.*?)!!}{<font color=red>$1</font>}gs;
  
  $s =~ s{([^"'=])(http://[^\[\]\(\)\s,;]+)}{$1<a href='$2'>$2</a>}g;

  $s .= "\n";
  return $s;
}

sub addEx
{
  my($question, $answer, $isAlreadyHtml) = @_;

  if ($question eq "@@\n" && $answer eq "@@\n")
  {
    return;
  }


  $isAlreadyHtml = 0 if !defined $isAlreadyHtml;

  if (!$isAlreadyHtml)
  {
    $question = prepAsHtml($question);
    $answer   = prepAsHtml($answer);
  }
  tdb::Set("$__topic.$__x", "Q", $question);
  tdb::Set("$__topic.$__x", "A", $answer);
  tdb::Set("$__topic.$__x", "id", $__x);
  $__x++;
}

sub extractExercisesFromHtml
{
  my($topic, $localFn) = @_;
  
  my $s = getContent($localFn);
  my $header_junk_boundary = "</h3>";
  my $question_boundary_tag = "h3";
  $s =~ s/.*?$header_junk_boundary//is;
  $s =~ s{.*?<$question_boundary_tag>}{<$question_boundary_tag>}s;

  while ($s =~ s{^(<$question_boundary_tag>.*?</$question_boundary_tag>)(.*?)(<$question_boundary_tag>|</body>)}{$3}is)
  {
    my $question = $1;
    my $answer = $2;
    #print "-----------------------------------------------------------------------------------------------\n";
    #print "question: $question\n";
    #print "-----------------------------------------------------------------------------------------------\n";
    #print "answer: $answer\n";
    #print "-----------------------------------------------------------------------------------------------\n";
    
    next if $answer =~ /TODO/;

    addEx($question, $answer, 1);
  }
}

sub extractExercisesFromQA
{
  my($topic, $localFn) = @_;

  my $s = getContent($localFn);
  $s =~ s/^\d+\n//gm;

  print "transform_into_flashcards::extractExercisesFromQA($topic, $localFn)\n";
  while ($s =~ s{^q$(.*?)\na$(.*?)(q\n.*)}{$5}mis)
  {
    my $question = $2;
    my $answer = $4;
    #print "-----------------------------------------------------------------------------------------------\n";
    #print "question: $question\n";
    #print "-----------------------------------------------------------------------------------------------\n";
    #print "answer: $answer\n";
    #print "-----------------------------------------------------------------------------------------------\n";

    next if $answer =~ /TODO/;

    addEx($question, $answer);
  }
}

sub extractExercisesFromFacts
{
  my($topic, $localFn) = @_;

  my $f = new IO::File("< $localFn") || die "cannot open $localFn";
  my $question = "";
  my $answer = "";
  my $isQuestion = 0;
  my $isAnswerUntilLoneQ = 0;
  my $isAnswerUntilBlankLine = 0;
  while (<$f>)
  {
    my $line = $_;

    next if $line =~ /^\d+\n$/;
    next if $line =~ /^#/;

    $line =~ s/\t/        /g;
    if ($isAnswerUntilLoneQ)
    {
      if ($line =~ /^q\n$/i)
      {
	print STDERR "isAnswerUntilLoneQ = 0;\n" if $__trace;
	$isAnswerUntilLoneQ = 0;
      }
    }
    #
    # the following condition applies if we are looking at the output from my class browser, e.g.,
    #  DriverManager ___________________ $JAVA/src/java/sql/DriverManager.java:1765
    #
    # warning: if you have only two underscores in this regexp, you'll match __DATA__ from perl.facts
    elsif ($line =~ /\s*([\.\w]+) ___/)
    {
      my $className = $1;
      print STDERR "$className class browser output\n" if $__trace;

      if ($answer =~ /\n\n$/)
      {
	print STDERR "2 blanx\n" if $__trace;
	addEx($question, $answer);
	$question = "";
	$answer = "";
      }

      if ($question =~ /^\s*$/)
      {
	print STDERR "empty question\n" if $__trace;
	$question = "describe the $className class";
      }
      $isQuestion = 0;
      $isAnswerUntilBlankLine = 1;
    }

    if (!$isAnswerUntilLoneQ)
    {
      if ($isQuestion)
      {
	if ($line =~ /^\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s\s/)
	{
	  print STDERR "leading blanks seen: question no longer\n" if $__trace;
	  $isQuestion = 0;
	}
	elsif (($line =~ /^a\n$/i)
	||     ($line =~ /^answer\n$/i))
	{
	  print STDERR "^a\$ seen: will be answer until ^q\$\n" if $__trace;
	  $isAnswerUntilLoneQ = 1;
	  $isQuestion = 0;
	  next;
	}
      }
      elsif ((!$isAnswerUntilBlankLine && ($line =~ /^(\s?\s?\s?\s?)\S/ || $line =~ /^q\n$/i))
      ||      ($isAnswerUntilBlankLine && $line =~ /^\n$/))
      {
			
	if ($answer)
	{
	  addEx($question, $answer);
	  $question = "";
	  $answer = "";
	}
	$isQuestion = 1;
	$isAnswerUntilBlankLine = 0;

	if ($line =~ /^q\n$/i)
	{
	  next;
	}
      }
    }
    
    if ($isQuestion)
    {
      $question .= $line;
    }
    else
    {
      $answer .= $line;
    }
  }
  addEx($question, $answer);
  $f->close();
}

sub extractExercises
{
  my($topic, @localFns) = @_;
  foreach my $localFn (@localFns)
  {
    die "cannot find $localFn for extraction" unless -f $localFn;
                
    if ($localFn =~ /\.html?$/)
    {
      extractExercisesFromHtml($topic, $localFn);
      }
      elsif ($localFn =~ /\.facts$/)
    {
      extractExercisesFromFacts($topic, $localFn);
    }
    elsif ($localFn =~ /\.qa$/)
    {
      extractExercisesFromQA($topic, $localFn);
    }
    else
    {
      die "didn't know what to do w/ $localFn";
    }
            
            
  }
  tdb::Save();
}

initUser($__topic);
my $localFn = "$ENV{'DROP'}/doc/facts/$__topic.facts";

extractExercises($__topic, $localFn);
