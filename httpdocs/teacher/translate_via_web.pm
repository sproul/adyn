package translate_via_web;
# UNUSED -- replaced by calls to goog_xlate
use strict;
use diagnostics;
use IO::Socket;
use URI::Escape;
use iso_8859_1_convert;

my $__trace = 0;

my $__fromLang;
my $__toLang  ;
my $__addingPeriod = 0;

my $__machine = undef;
my $__port = 80;
my $__bdy = "Xy.";


sub BuildRequest_AltaVistaTranslation
{
	#die "need to reflect fromLang, toLang";
	my($inputString) = @_;
	
	$inputString =~ s/[\n ]+/+/g;
	$inputString = uri_escape($inputString);
	my $arg = "doit=done&urltext=$inputString&lp=en_it";

	$__machine = "babelfish.altavista.com";
	#$__machine = "o4";
	
	return "POST /cgi-bin/translate? HTTP/1.0\r\n" .
	"Referer: http://babelfish.altavista.com/cgi-bin/translate\r\n" .
	"Connection: Keep-Alive\r\n" .
	"User-Agent: Mozilla/4.7 [en] (WinNT; I)\r\n" .
	"Host: babelfish.altavista.com\r\n" .
	"Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*\r\n" .
	"Accept-Language: en\r\n" .
	"Accept-Charset: iso-8859-1,*,utf-8\r\n" .
	"Content-type: application/x-www-form-urlencoded\r\n" .
	"Content-length: " . length($arg) . "\r\n" .
	"\r\n" .
	"$arg\r\n";
}

sub BuildRequest_EtsTranslation
{
	my($inputString) = @_;
	$inputString =~ s/[\n ]+/+/g;
	$inputString = uri_escape($inputString);
		
	my $arg = "Sequence=core&Mode=html&template=TextResult2.htm&Language=$__fromLang%2F$__toLang&SrcText=$inputString&a=a&e=e&i=i&o=o&u=u&Other=misc";

	$__machine = "ets.freetranslation.com";
	#$__machine = "o4";
		
	$__port = 5081;
	
	return "POST / HTTP/1.0\r\n" .
	"Connection: Keep-Alive\r\n" .
	"User-Agent: Mozilla/4.7 [en] (WinNT; I)\r\n" .
	"Host: ets.freetranslation.com:5081\r\n" .
	"Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*\r\n" .
	"Accept-Encoding: gzip\r\n" .
	"Accept-Language: en\r\n" .
	"Accept-Charset: iso-8859-1,*,utf-8\r\n" .
	"Content-type: application/x-www-form-urlencoded\r\n" .
	"Content-length: " . length($arg) . "\r\n" .
	"\r\n" .
	"$arg\r\n";
}

sub NoTrailingPunctuation
{
  my($linesRef) = @_;
  for (my $j=0; $j < scalar(@$linesRef); $j++)
  {
    my $line = $linesRef->[$j];
    #print "translate_via_web::NoTrailingPunctuation($line)\n";
    return 0 if $line =~ /[\.\?!]$/;
  }
  #print "translate_via_web::NoTrailingPunctuation: 1\n";
  return 1;
}


    
  
sub WrapInput
{
	my($inputLinesRef) = @_;
	my $inputString = "";
		
	$__addingPeriod = NoTrailingPunctuation($inputLinesRef);
	my $following = ($__addingPeriod ? "." : " "); 
	
	for (my $j=0; $j < scalar(@$inputLinesRef); $j++)
	{
		my $line = $inputLinesRef->[$j];
		#print "input: $line";
		$inputString = $inputString . $__bdy . " " . $line . $following . $__bdy . "\n";
	}
	return $inputString;
}	

sub UnwrapOutput
{
	my($s) = @_;
	##print "$s\nunwrapping========================================================\n";
	$s =~ s/\n/ /g;
	#$s =~ s/.*<p>$__bdy/$__bdy/;
	#$s =~ m{^XX\. XX(.*?)<p>}{XX

	
	my @outputLines = ();
	
	while ($s =~ m/.*?$__bdy(.*?)$__bdy(.*)/s)
	{
		my $oneLineTranslated = $1;
		$s = $2;
				
		$oneLineTranslated =~ s/ +/ /g;
		$oneLineTranslated =~ s/^ //g;
		$oneLineTranslated =~ s/ $//g;
		
		$oneLineTranslated =~ s/\.\s*$//g if ($__addingPeriod); # now getting rid of it
		
		#print "output: ";
		push(@outputLines, $oneLineTranslated);
	}
	##print "uo: $outputLines[0]\n";
	##print "uo: $outputLines[1]\n";
	##print "uo: $outputLines[2]\n";

	return @outputLines;
}

	
sub ExecuteQuery
{
	my($input) = @_;
	die "translate_via_web.pl: no input" unless $input;
	#print "Translating from $__fromLang to $__toLang\n";
	
	#my $request = BuildRequest_AltaVistaTranslation($input);
	my $request = BuildRequest_EtsTranslation($input);
		
	print "translate_via_web::ExecuteQuery($request)\n" if $__trace;
	
	my $server = IO::Socket::INET->new(PeerAddr => $__machine, PeerPort => $__port, Proto => 'tcp');
	if (!defined $server)
	{
		print "translate_via_web.ExecuteQuery: unable to connect to $__machine:$__port.\n";
		exit(0);
	}


	my($savedSelectedFile) = select($server); $| = 1; select($savedSelectedFile);
	print $server $request;

	my $buffer;
	my $n = 0;
	my $bytesRead;
	while ($bytesRead = sysread($server, $buffer, 16384, $n))
	{
		$n += $bytesRead;
	}
	close $server;
			
	print "==========================================================\ntranslate_via_web::ExecuteQuery(): raw: $buffer\n==========================================================\n" if $__trace;

	# hacks to reduce data size
	$buffer =~ s/.*Translation Results by Transparent Language//s;
	$buffer =~ s/Your Original Text.*//s;
	
	print "==========================================================\ntranslate_via_web::ExecuteQuery(): reduced: $buffer\n==========================================================\n" if $__trace;
	return $buffer;
}

sub DoVectorChunk
{
	my($fromLang, $toLang, $inputLinesRef) = @_;
	my @inputLines = @$inputLinesRef;

	$__fromLang = $fromLang;
	$__toLang = $toLang;
	#print "translate_via_web::DoVectorChunk($__fromLang, $__toLang, ", scalar(@$inputLinesRef), " items starting w/ '$inputLinesRef->[0]')\n";

	my $s = WrapInput($inputLinesRef);
	##print "2:$s\n";
	$s    = ExecuteQuery($s);
	##print "3:$s\n";
	return $s;
}

sub DoString
{
	my($fromLang, $toLang, $s) = @_;
	my @a = ($s);
	my $b = DoVector($fromLang, $toLang, \@a);
	return $b->[0];
}

sub DoVector
{
	my($fromLang, $toLang, $inputLinesRef) = @_;
	my $currentBatchLen = 0;
	my @inputLines;
	my $s = "";
	for (my $j = 0; $j < scalar(@$inputLinesRef); $j++)
	{
		$inputLines[$currentBatchLen++] = $inputLinesRef->[$j];
		my $maxBatchLen = 50;
		if (($currentBatchLen >= $maxBatchLen) || ($j >= (scalar(@$inputLinesRef) - 1)))
		{
			$s .= DoVectorChunk($fromLang, $toLang, \@inputLines);
			@inputLines = ();
			$currentBatchLen = 0;
		}
	}
	$s = iso_8859_1_convert::RawToMe($s);

	my @outputLines = UnwrapOutput($s);
	##print "translate_via_web.pm: $outputLines[0]\n";
	##print "translate_via_web.pm: $outputLines[1]\n";
	##print "translate_via_web.pm: $outputLines[2]\n";
	return \@outputLines;
}

sub DoStdin
{
	die "Usage:$0 fromLang toLang" unless $#ARGV>=1;

	$__fromLang = $ARGV[0];
	$__toLang   = $ARGV[1];


	my @inputLines = <STDIN>;
	my @outputLines = DoVector($__fromLang, $__toLang, @inputLines);
	foreach my $outputLine (@outputLines)
	{
		print $outputLine, "\n";
	}
}
1;
	
# test with: cd $HOME/Dropbox/adyn/httpdocs/teacher/; cat data/en.text|perl -w translate_via_web.pm en it
#my @x;
#$x[0] = "I go.";
#$x[1] = "You go.";
#$x[2] = "He goes.";
#DoVector("English", "German", \@x);
#print DoString("English", "German", "She is an idiot."), "\n";

# test with: cd $HOME/Dropbox/adyn/httpdocs/teacher/; perl -w translate_via_web.pm 
