# UNUSED
use strict;
use diagnostics;
use IO::Socket;
use URI::Escape;

die "Usage:$0 fromLang toLang" unless $#ARGV>=1;

my $__fromLang = $ARGV[0];
my $__toLang   = $ARGV[1];

my $__machine = undef;
my $__port = 80;
my $__itemCount;

my @langs = ( "en", "es", "fr", "de", "it" );
my %langNames = ( "en" => "English", "es" => "Spanish", "fr" => "French", "de" => "German", "it" => "Italian" );

sub Boundary
{
  my($n) = @_;
  return "X" . $n . "Y.";
}

sub BuildRequest_EtsTranslation
{
  my($inputString) = @_;
  $inputString =~ s/[\n ]+/+/g;
  $inputString = uri_escape($inputString);

  my($lang1, $lang2) = ($langNames{$__fromLang}, $langNames{$__toLang});

  my $arg = "Sequence=core&Mode=html&template=TextResult2.htm&Language=$lang1%2F$lang2&SrcText=$inputString&a=a&e=e&i=i&o=o&u=u&Other=misc";

  $__machine = "ets.freetranslation.com";
  #$__machine = "o3";
		
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

sub WrapInput
{
	my @inputLines = <STDIN>;
	my $inputString = "";
		
	for (my $j=0; $j <= $#inputLines; $j++)
	{
		my $line = $inputLines[$j];
		#print "input: $line";
		chop $line;
		$inputString = $inputString . Boundary($j) . " " . $line . " " . Boundary($j) . "\n";
	}
	$__itemCount = $#inputLines + 1;
	return $inputString;
}	

sub UnwrapOutput
{
	my($s) = @_;
	#print "$s\nunwrapping========================================================\n";
	$s =~ s/\n/ /g;
	
	for (my $j = 0; $j < $__itemCount; $j++)
	{
		my $bdy = Boundary($j);
		die "xlate:UnwrapOutput: could not find $bdy in $s" unless $s =~ m/.*?$bdy(.*?)$bdy(.*)/s;
		my $oneLineTranslated = $1;
		$s = $2;
				
		$oneLineTranslated =~ s/ +/ /g;
		$oneLineTranslated =~ s/^ //g;
		$oneLineTranslated =~ s/ $//g;
		
		#print "output: ";
		print "$oneLineTranslated\n";
	}
}

	
sub ExecuteQuery
{
	my($input) = @_;
	die "translate_via_web.pl: no input" unless $input;
	#print "Translating from $__fromLang to $__toLang\n";
	
	my  $request = BuildRequest_EtsTranslation($input);
	
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
	return $buffer;
}

UnwrapOutput(ExecuteQuery(WrapInput()));
	
# test with: cd $HOME/Dropbox/adyn/httpdocs/teacher/; cat translate_via_web_test.dat |perl -w translate_via_web.pl en fr
