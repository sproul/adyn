use strict;
#!c:/cygwin/bin/perl.exe --
use CGI qw(:standard);
use adyn_cgi_util;
use diagnostics;
use Getopt::Long;
require LWP;
use XML::Simple;
use Data::Dumper;

my $query;
if (-d "c:/")
{
  $query = new CGI(\*STDIN);
}
else
{
  $query = new CGI;
}

print $query->header(
-status=>'200 OK',
-expires=>'-1d',
-type=>'text/html');


my $__debug = 0;
my $__tomcatManagerUser_username = undef;
my $__tomcatManagerUser_password = undef;

my $VERSION = "1.0"; 	# CVS: sprintf("%d.%02d", q$Revision: 1.39 $ =~ /(\d+)\.(\d+)/);

# perl -w c:/perl/bin/lwp-request -C 'x:' 'http://localhost:8080/manager/list'


{
  package mgr_UserAgent;
  use vars '@ISA';
  @ISA = qw(LWP::UserAgent);

  sub new
  {
    my $self = LWP::UserAgent::new(@_);
    $self->agent("mgr/$VERSION");
    $self;
  }
  
  sub get_basic_credentials
  {
    my($self, $realm, $uri) = @_;

    if (defined $__tomcatManagerUser_username && defined $__tomcatManagerUser_password)
    {
      return ($__tomcatManagerUser_username, $__tomcatManagerUser_password);
    }

    if ($main::options{'C'})
    {
      return split(':', $main::options{'C'}, 2);
    }
    elsif (-t)
    {
      my $netloc = $uri->host_port;
      print "Manager tomcat: ";
      my $user = <STDIN>;
      chomp($user);
      return (undef, undef) unless length $user;
      print "Password: ";
      system("stty -echo");
      my $__password = <STDIN>;
      system("stty echo");
      print "\n";  # because we disabled echo
      chomp($__password);
      return ($user, $__password);
    }
    else
    {
      return (undef, undef)
    }
  }
}

sub Manager
{
  my($arguments) = @_;

  my $s = "OK - Listed applications for virtual host localhost
  /manager:running:0:../server/webapps/manager
  /jaxm-translator:running:0:C:\\jwsdp-1_0_01\\webapps\\jaxm-translator.war
  /jaxm-soaprp:running:0:C:\\jwsdp-1_0_01\\webapps\\jaxm-soaprp.war
  /saaj-simple:running:0:C:\\jwsdp-1_0_01\\webapps\\saaj-simple.war
  /jaxm-remote:running:0:C:\\jwsdp-1_0_01\\webapps\\jaxm-remote.war
  /myapp:running:0:C:\\jwsdp-1_0_01\\webapps\\myapp
  /jstl-examples:running:0:C:\\jwsdp-1_0_01\\webapps\\jstl-examples.war
  /registry-server:running:0:C:\\jwsdp-1_0_01\\webapps\\registry-server.war
  /jaxmtags:running:0:C:\\jwsdp-1_0_01\\webapps\\jaxmtags.war
  /jaxm-simple:running:0:C:\\jwsdp-1_0_01\\webapps\\jaxm-simple.war
  /:running:0:C:\\jwsdp-1_0_01\\webapps\\ROOT
  /admin:running:0:../server/webapps/admin
  ";

  #my $request = HTTP::Request->new("GET");
  #$request->url("http://localhost:8080/manager/$arguments");
  #my $ua = new mgr_UserAgent();
  #my $response = $ua->request($request);
  #if ($response->is_success)
  #{
  #$s = $response->content;
  #}
  #else
  #{
  #$s = $response->error_as_HTML;
  #}

  $s =~ s/\xd//g;
  return $s;
}

sub GetTomcatCredentialsForRole
{
  my($role) = @_;
  my $fn = $ENV{"CATALINA_HOME"} . "/conf/tomcat-users.xml";
  my $tomcatUsers = XMLin($fn);
  print Dumper($tomcatUsers) if $__debug;
  my $users = $tomcatUsers->{"user"};
  foreach my $user (@$users)
  {
    if ($user->{"roles"} =~ /\bmanager\b/)
    {
      return ($user->{"username"}, $user->{"password"});
    }
  }
  return (undef, undef);
}

sub Button
{
  my($op) = @_;
  return "<input type=button name='$op' value='$op'>";
}


sub BuildAppControlForm
{
  #($__tomcatManagerUser_username, $__tomcatManagerUser_password) = GetTomcatCredentialsForRole("manager");
  my $s = Manager("list");
  if ($s =~ /^OK.*?\n(.*)/s)
  {
    $s = $1;
    my @apps = split(/\n/, $s);

    $s = "<html><head><title>Tomcat Manager</title></head><body bgcolor=#cccccc><font face='arial'><h3>Tomcat Manager</h3><form><table bgcolor=#cccccc border=1 cellpadding=1 cellspacing=1 width=100%>";
    $s .= "<tr><td><b>name</b></td><td></td><td></td><td><b>where deployed locally</b></td></tr>";
    $s .= "<tr><td><input name='name' size=30></td><td>" . Button("install") . "</td><td>" . Button("start") . "</td><td><input name='where' size=60></td></tr>";

    foreach my $app (@apps)
    {
      $s .= "<tr><td>";
      if ($app =~ m{^(.*?):(\w+):\d+:(.*)})
      {
	my($appName, $status, $fn) = ($1,$2,$3);
	$appName =~ s/^\s*//;
	next if $appName eq "/manager";
	$s .= "$appName</td>";
	$fn =~ s/.*webapps.//;
	$s .= "<td>" . Button("remove") . "</td>";
	if ($status eq "running")
	{
	  $s .= "<td>" . Button("stop") . "</td>";
	}
	else
	{
	  $s .= "<td>" . Button("start") . "</td>";
	}
	$s .= "<td>$fn";
      }
      else
      {
	$s .= $app;
      }
      $s .= "</td></tr>";
    }
    $s .= "</table></form></font></body></html>";
  }
  print "$s";
}

BuildAppControlForm();
