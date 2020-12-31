use strict;
use diagnostics;
require LWP;
package web_get;

my $__debug = 0;
my $__username = undef;
my $__password = undef;
my $__url = undef;

{
  package authenticated_UserAgent;
  use vars '@ISA';
  @ISA = qw(LWP::UserAgent);

  sub new
  {
    my $self = LWP::UserAgent::new(@_);
    $self->agent("mgr");
    $self;
  }

  sub get_basic_credentials
  {
    my($self, $realm, $uri) = @_;

    if (defined $__username && defined $__password)
    {
      #print "get_basic_credentials(): ($__username, $__password)\n";
      return ($__username, $__password);
    }
    else
    {
      return (undef, undef)
    }
  }
}

sub get
{
  my($url, $username, $password) = @_;
  $__url = $url;
  $__username = $username;
  $__password = $password;

  my $request = HTTP::Request->new("GET");
  $request->url($__url);
  my $ua = new authenticated_UserAgent();
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

  $s =~ s/\xd//g;
  return "$s";
}
