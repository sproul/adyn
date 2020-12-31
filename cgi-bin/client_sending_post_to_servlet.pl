use strict;
use diagnostics;
use send_post;

my $post_data_version_1 = "postData=this_is_the_first_version_of_the_POST_data";

#send_post::SendAndShowResult("http://localhost:8080/pipeline_app/echo", $post_data_version_1);
send_post::SendAndShowResult("http://localhost:8080/pipeline_app/pipeline", $post_data_version_1);
