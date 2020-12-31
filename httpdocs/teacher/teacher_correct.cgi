#!/usr/local/bin/perl
use strict;
use IO::File;

if (-d "c:/")
{
        exit();  # this allows a perl compile-time check on the PC
}
use CGI qw(:standard);

my $query = new CGI;
my $language	= $query->param('language');
my $id		= $query->param('id');
my $text	= $query->param('text');
my $nextPage	= "html/" . $query->param('nextPage');
my $output = "";

print $query->header(-status=>'200 OK',
-expires=>'-1d', 
-expires=>'-1d', 
-type=>'text/html');

sub SaveCorrection
{
        return unless $output;
	
	my $fn = "$HOME/work/adyn.com/httpdocs/teacher/corrections";
	if (! -f $fn)
	{
		my $mail = new IO::File("| /usr/ucb/Mail -s '$language correction' teacher\@adyn.com");
		print $mail "$fn updated\n";
		$mail->close();
	}
	my $update = new IO::File(">> $fn");
	print $update $output;
	$update->close();
}

$text =~ s/'/\\'^D /g;
$text =~ s/\n/\\n/g;
$output .= "tdb::Set(\"$id\", \"${language}\", iso_8859_1_convert::doSplits('$text'));\n";
$output .= "tdb::Set(\"$id\", \"map/${language}\", undef); AppendProp(\"$id\", \"reviewers\", \"@@\");\n";

print "<html><body>\n";

print "<h2>Thank you for your feedback</h2>\n";

print "<form name=onward>\n";
print "<input type=button name=Next value='On to the next exercise' onClick='on_Next_click()'>\n";
print "</form>\n";

print "<script language=\"JavaScript\">\n";
print "function on_Next_click()\n";
print "{\n";
print "	window.location='$nextPage' \n";
print "}\n";

print "document.onward.Next.focus();\n";
print "</script>\n";
print "</body> </html>\n";

SaveCorrection();

# test with: cd $HOME/work/adyn.com/httpdocs/teacher/; (echo "language=Deutsche"; echo "id=5"; echo "nextPage=n.html"; echo "text='hey world'") |perl -w teacher_correct.cgi
