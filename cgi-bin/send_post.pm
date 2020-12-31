package send_post;

use strict;
use diagnostics;
use HTTP::Request;
use LWP::UserAgent;

sub SendAndShowResult
{
  my($url, $postData) = @_;

  my $request = HTTP::Request->new("POST");
  my $contentRef = $request->content_ref();
  $$contentRef = $postData;
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
  print "$s\n";
}

1;
