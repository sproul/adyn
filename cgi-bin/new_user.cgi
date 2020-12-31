#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
use strict;
use diagnostics;
use IO::File;
use teacher_user;
use Ndmp;
use adyn_cgi_util;
use nutil;
use CGI qw(:standard);

sub InitFile
{
  my($query, $dir, $email, $required, $parmName) = @_;
  my $val = adyn_cgi_util::param($query, $parmName);

  if (!defined $val)
  {
    if ($required)
    {
      return adyn_cgi_util::MailAdynError("$parmName is undefined", $email);
    }
    else
    {
      return;
    } 
  } 

  my $f = new IO::File("> $dir/$parmName");
  if (!$f)
  {
    my $s = "Could not create $dir/$parmName";
    return adyn_cgi_util::MailAdynError($s, $email);
  }
  print $f $val;
  $f->close();
  return "";
}

sub Main
{
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

  my $email = adyn_cgi_util::param($query, "email");
  $email = "" unless defined $email;

  my $userID = adyn_cgi_util::param($query, "userID");
  $userID = "" unless defined $userID;

  my $proposedNewUserDir = "../httpdocs/teacher/usr/$userID";

  if (!$email || !$userID)
  {
    print adyn_cgi_util::html_header("teacher: internal error");
    print "</head>\n";
    print "<body bgcolor=#cccccc><font face='arial'>\n";
    print "<h3>Expected parms not seen.</h3>\n";
    adyn_cgi_util::MailAdyn("new_user.cgi internal error: undefined $email or $userID", "yikes!");
    print "This problem has been reported to adynware support.  Try again in a few days.\n\nSorry!\n";
    print "</body></html>\n";
  }
  elsif (-d $proposedNewUserDir)
  {
    print adyn_cgi_util::html_header("teacher: <i>$userID</i> has already been used");
    print "</head>\n";
    print "<body bgcolor=#cccccc><font face='arial'>\n";
    print "<h3>Someone else has already chosen <i>$userID</i> as a user ID</h3>\n";
    print "\n";
    print "Click on the <b>Back</b> button to return to the form, where you should choose a different user ID.\n";
    print "</body></html>\n";
  }
  elsif (!mkdir($proposedNewUserDir, 0777))
  {
    print adyn_cgi_util::html_header("teacher: could not create <i>$userID</i>");
    
    print "</head>\n";
    print "<body bgcolor=#cccccc><font face='arial'>\n";
    print adyn_cgi_util::MailAdynError("My attempt to create the user ID <i>$userID</i> failed: dir creation failure", $email);
    print "</body></html>\n";
  }
  else
  {
    my $s = "";
    $s .= InitFile($query, $proposedNewUserDir, $email, 1, "email");
    $s .= InitFile($query, $proposedNewUserDir, $email, 1, "pw");
    $s .= InitFile($query, $proposedNewUserDir, $email, 1, "userID");

    InitFile($query, $proposedNewUserDir, $email, 0, "school");
    InitFile($query, $proposedNewUserDir, $email, 0, "instructor");

    if ($s)
    {
      print adyn_cgi_util::html_header("Error");
      
      print "</head>\n";
      print "<body bgcolor=#cccccc><font face='arial'>\n";

      print adyn_cgi_util::MailAdynError("My attempt to create the user ID $userID failed", $email);
      print "</body></html>\n";
    }
    else
    {
      adyn_cgi_util::MailAdyn("successful user creation: $userID ($email)");

      my $f = new IO::File("< ../httpdocs/teacher/html2simple_choose.htm");
      if (!$f)
      {
        print adyn_cgi_util::html_header("teacher: could not create exercise selection panel");
        
        print "</head>\n";
	print "<body bgcolor=#cccccc><font face='arial'>\n";
	print adyn_cgi_util::MailAdynError("My attempt to display a form for user <i>$userID</i> failed", $email);
	print "</body></html>\n";
	return;
      }
      while (<$f>)
      {
	my $line = $_;
	$line =~ s{(<script language=JavaScript>)}{$1 adyn_url_offset='../httpdocs/teacher/html2'\n};

	if ($line =~ /<h2>Choose/)
	{
	  print "<h3>New user <i>$userID</i> was successfully created</h3>";
	  print $line;
	}
	elsif ($line =~ /^function _onload/)
	{
	  print $line;
	  $line = <$f>;		# absorb first curly bracket
	  print "{\n";
	  print "document.teacher_form.userID.value = '$userID'\n";

	  #adyn_cgi_util::VerifyLogin_setIpFile("../httpdocs/teacher/usr/$userID", $ENV{"REMOTE_ADDR"});
	}
	elsif ($line =~ m{</body>})
	{
	  adyn_cgi_util::StreamInFile("../httpdocs/teacher/html2welcome.htm");
	  print $line;
	}
	else
	{
	  print adyn_cgi_util::RedirectRelativeURLsEtc($line, "/teacher/html");
	}
      }
    }
  }
}
Main();
  
# xtest with: cd $HOME/Dropbox/adyn/cgi-bin/;(echo email=axe@adyn.com; echo userID=test543; echo pw=x)|perl -w new_user.cgi
