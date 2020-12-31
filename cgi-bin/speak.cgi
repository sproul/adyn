#!/usr/bin/perl --
#!c:/perl/bin/perl.exe
#!c:/cygwin/bin/perl.exe --
use strict;
use CGI qw(:standard);
use adyn_cgi_util;
use IO::File;

my $query = new CGI;

print $query->header(
-status=>'200 OK', 
-expires=>'-1d', 
-type=>'text/html');

#print "<html><head><title>Speak</title></head><body bgcolor=#cccccc><h3>";
print adyn_cgi_util::html_header("Speak");
print "</head><body bgcolor=#cccccc><h3>";

my $category = adyn_cgi_util::param($query, 'category');
$category = "Business" unless defined $category;

my %components = ();

$components{"biz"} = ["b_power.voc", "b_work.voc", "b_nouns.voc", "and.voc", "b_action.voc"];
$components{"tech"} = ["b_power.voc", "t_work.voc", "t_nouns.voc", "and.voc", "t_action.voc"];
$components{"new_age"} = ["u_u_will.voc", "nw_goals.voc", "u_via.voc", "nwmethod.voc"];

my $fileNamesReference = $components{$category};

srand();

my $s = "";

foreach my $fileName (@$fileNamesReference)
{
        my $file = new IO::File("< ../httpdocs/speak/$fileName") or die "could not open $fileName: $!";
        my @possibilities = <$file>;
        $file->close();
        
        $s .= " " if $s;
        $s .= $possibilities[int(rand(scalar(@possibilities)))];
        chop $s;
}
$s .= ".";
print "$s\n"; 
print "</h3> </body> </html>";
# test with: cd $HOME/Dropbox/adyn/cgi-bin/; echo category=tech |perl -w speak.cgi