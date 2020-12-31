use strict;
use diagnostics;
use send_post;

my $post_data_version_1 = "postData=this_is_the_first_version_of_the_POST_data";

send_post::SendAndShowResult("http://localhost/bin/pipeline.cgi", $post_data_version_1);
