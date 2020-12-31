use strict;
#!c:/cygwin/bin/perl.exe --
use diagnostics;

use CGI qw(:standard);

my $query = new CGI(\*STDIN);

print $query->header(
-status=>'200 OK',
-expires=>'-1d',
-type=>'text/html');

print "<title>echo post data</title>\n";
print "</head>\n";

print "<body>\n";
print "<h3>Post Data:</h3>\n";

print "<pre>" . $query->query_string . "</pre>";

print "</body>\n";
print "</html>\n";
