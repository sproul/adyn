use strict;
use diagnostics;
use iso_8859_1_convert;

iso_8859_1_convert::ProcessRawFile($ARGV[0]);

# test with: cd e:/users/nsproul/Dropbox/adyn/httpdocs/teacher/data;rm fr.text.me;  perl -w ../iso_8859_1_convert.pl fr.text; diff fr.text.html fr.text.me