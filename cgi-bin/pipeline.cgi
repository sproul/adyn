use strict;
#!c:/cygwin/bin/perl.exe --
use diagnostics;
use send_post;
use CGI qw(:standard);

my $query = new CGI(\*STDIN);

print $query->header(
-status=>'200 OK',
-expires=>'-1d',
-type=>'text/html');

my $post_data_version_1 = $query->query_string;

my $post_data_version_2 = $post_data_version_1;
$post_data_version_2 =~ s/first/second/;

send_post::SendAndShowResult("http://localhost/bin/echo.cgi", $post_data_version_2);
