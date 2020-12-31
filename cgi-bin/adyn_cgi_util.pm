package adyn_cgi_util;
use strict;
use diagnostics;
use IO::File;
use nutil;

my $__trace = 0;
my %__params = ();

sub MailAdyn
{
  my($subject, $contents) = @_;

  $contents = "" unless defined $contents;
  if (-d "c:/")
  {
    print STDERR "adyn_cgi_util::MailAdyn($subject, $contents): would mail adyn if I were on unix\n";
  }
  elsif (-f "/usr/bin/Mail")
  {
    system("echo \"$contents\" | /usr/bin/Mail -s \"$subject\" nelson\@adyn.com");
  }
  elsif (-d "/www-data-msgs")
  {
    my $fn = "/www-data-msgs/todo.$ENV{'HOST'}";
    my $f = new IO::File(">> $fn");
    my $d = `date`;
    chomp $d;
    print $f "$d $subject: $contents\n";
    $f->close();
  }
  else
  {
    print STDERR "cannot find tell_nelson; $subject: contents\n"; 
  } 
}

sub MailAdynError
{
  my($emsg, $email) = @_;

  MailAdyn($emsg, "email is $email");
  return "<h3>$emsg</h3>\n"
  . "\n"
  . "I have sent mail to <a href=\"mailto:support\@adyn.com\">adynware support</a> to ask them to look into it.  I asked them to contact $email with the results of their investigation.\n";
}


sub RememberParm
{
  my($parmName, @vals) = @_;
  if ($parmName)	# $parmName is empty when "all" parameters are requested (e.g., in paramsStartingWith)
  {
    foreach my $value (@vals)
    {
      my $setting = "$parmName=$value";
      #print "adyn_cgi_util::RememberParm(): $setting\n";
      $__params{"$parmName=$value"} = 1;
    }
  }
}

sub ListCgiParms
{
  my($logToStderr) = @_;
  my $s = join(';', keys %__params);
  print "adyn_cgi_util::ListCgiParms: $s\n" if $__trace;
  return $s;
}

sub param
{
  my($query, $parmName, $dft) = @_;
        
  print STDERR "adyn_cgi_util::param($query, " . nutil::ToString($parmName) . ", " . nutil::ToString($dft) . ")\n" if $__trace;
  if (wantarray)
  {
    my @valFromUrl;
    my @valFromPost;

    if (defined $parmName)
    {
      @valFromUrl  = $query->url_param($parmName);
    }
    else
    {
      @valFromUrl  = $query->url_param();
    }
    #Ndmp::Ah("inner.url_",@valFromUrl);

    if (defined $parmName)
    {
      @valFromPost = $query->param($parmName);
    }
    else
    {
      @valFromPost = $query->param();
    }
    #Ndmp::Ah("inner.posturl_",@valFromPost);

    @valFromUrl  = () if (scalar(@valFromUrl) ==1) && (!defined $valFromUrl[0]);
    @valFromPost = () if (scalar(@valFromPost)==1) && (!defined $valFromPost[0]);

    if (("" eq scalar(@valFromUrl)) && ("" eq scalar(@valFromPost)))
    {
      print STDERR "adyn_cgi_util::param returning default\n" if $__trace;
      if (!defined $dft)
      {
	return ();
      }
      return $dft;
    }
    if (@valFromPost)
    {
      print STDERR "adyn_cgi_util::param returning array from post\n" if $__trace;
      RememberParm($parmName, @valFromPost);
      return @valFromPost;
    }
    print STDERR "adyn_cgi_util::param returning array from url\n" if $__trace;
    RememberParm($parmName, @valFromUrl);
    return @valFromUrl;
  }
  else
  {
    my $valFromUrl  = $query->url_param($parmName);
    my $valFromPost = $query->param($parmName);

    $valFromUrl  = "" if !defined $valFromUrl;
    $valFromPost = "" if !defined $valFromPost;

    if (("" eq $valFromUrl) && ("" eq $valFromPost))
    {
      print STDERR "adyn_cgi_util::param returning default\n" if $__trace;
      return $dft;
    }
    if ($valFromUrl)
    {
      print STDERR "adyn_cgi_util::param returning $valFromUrl from url\n" if $__trace;
      RememberParm($parmName, $valFromUrl);
      return $valFromUrl;
    }
    print STDERR "adyn_cgi_util::param returning $valFromPost from post\n" if $__trace;
    RememberParm($parmName, $valFromPost);
    return $valFromPost;
  }
}

sub param_bool
{
  # default is false
  my($query, $parmName) = @_;
  my $val = param($query, $parmName, "n");
  if ($val =~ /^false|f|no|n/)
  {
    $val = 0;
  }
  else
  {
    $val = 1;
  }
  return $val;
}

sub param_as_hash
{
  my($query, $parmName) = @_;
  # assumes structure is key/val;key2/val2...
  my $v = param($query, $parmName, "");
  my @key_val_pairs = split(/;/, $v);
  my %h = ();
  foreach my $key_val_pair (@key_val_pairs)
  {
    my($key, $val) = split(/\//, $key_val_pair);
    $h{$key} = $val;
    print "//k=v: $key=$val\n";
  }
  return \%h;
}

sub paramsStartingWith
{
  my($query, $prefix) = @_;
  my @allParms = param($query);

  my @parmsWithPrefix = ();
  foreach my $parm (@allParms)
  {
    if ($parm =~ /^$prefix/)
    {
      push @parmsWithPrefix, $parm;
    }
  }
  return @parmsWithPrefix;
}

sub RedirectRelativeURLsEtc
{
  my($line, $whereTo) = @_;
  $line =~ s{(<script language=JavaScript src)=([^/])}{$1=$whereTo/$2}g;
  $line =~ s{<applet }{<applet codebase=$whereTo }g;
  return $line;
}

sub Log
{
  my($subject, $contents) = @_;
  $contents = "" unless defined $contents;
  #system("echo \"$contents\" | /usr/bin/Mail -s \"$subject\" support\@adyn.com");
}

sub GetPw
{
  my($userDir) = @_;

  my $f = new IO::File("< $userDir/pw");
  if (!$f)
  {
    return undef;
  }
  my $pw = <$f>;
  $f->close();
  return $pw;
}

sub LogError
{
  my($emsg, $email) = @_;

  my $s = "<h3>$emsg</h3>\n\n"
  . "I have sent mail to <a href=\"mailto:support\@adyn.com\">adynware support</a> to ask them to look into it.";
  if (defined $email)
  {
    Log($emsg, "email is $email");
    $s .= "I asked them to contact $email with the results of their investigation.\n";
  }
  return $s;
}

sub InternalError
{
  my($emsg) = @_;

  print "<title>teacher: internal error</title>\n";
  print "</head>\n";
  print "<body bgcolor=#cccccc><font face='arial'>\n";
  print "<h3>$emsg</h3>\n";
  Log("login.cgi internal error: $emsg", "yikes: ", nutil::GetStack());
  foreach my $arg (@ARGV)
  {
    print "<br>ARGV[$arg]=$ARGV[$arg]<br>\n";
  }
  #foreach my $key (keys %ENV)
  #{
  #  print "$key --> $ENV{$key}<br>";
  #}

  print "This problem has been reported to adynware support.  Try again in a few days.\n\nSorry!\n";
  print "</body>\n";
  print "</html>\n";
}

sub html_header
{
  my($title, $favicon_url, $no_cache) = @_;
  my $favicon_pointer = '';
  $title = "" if (!defined $title);
  if ($title)
  {
    $title = "<title>$title</title>";
  }
  if (!$favicon_url)
  {
    $favicon_url = "/favicon.GIF";
    $favicon_pointer = "<link rel=\"icon\" type=\"image/gif\" href=\"" . $favicon_url . "\" /> ";
  }
  # removed UTF-8 to avoid conflict w/ HTTP header (from perl CGI) which was declaring it to be iso-8859-1.  Not sure if this matters...
  #my $s = "<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n<head>\n$title<meta http-equiv=\"Content-type\" content=\"text/html;charset=UTF-8\"     >$favicon_pointer";
  my  $s = "<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n<head>\n$title<meta http-equiv=\"Content-type\" content=\"text/html;charset=iso-8859-1\">$favicon_pointer";
  if ($no_cache)
  {
    $s .= "<meta http-equiv=\"Content-type\" content=\"text/html;charset=UTF-8\">";
    $s .= "<META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">";
    $s .= "<META name=\"viewport\" content=\"width=device-width\">";
    $s .= "<META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\">";
  }
  return $s;
}

sub PrintPreamble200
{
  my($query, $title) = @_;
  print $query->header(
  -status=>'200 OK',
  -expires=>'-1d',
  -type=>'text/html');

  print "\n" . html_header($title);
  print "</head>\n";
  print "<body bgcolor=#cccccc><font face='arial'>\n";
}
sub Error
{
  my($emsg, $advice) = @_;

  print "<title>teacher: error</title>\n";
  print "</head>\n";
  print "<body bgcolor=#cccccc><font face='arial'>\n";
  print "<h2>$emsg</h2>\n";
  Log("login.cgi error: $emsg", "yikes...", nutil::GetStack());
  print "$advice\n";
  print "<p>\n";
  print "Click on the <b>Back</b> button to return to the previous page and fix the error.\n";
  print "<p>\n";
  print "If you think that you didn't make a mistake, and that this error is a result of a \n";
  print "software bug, please \n";
  print "<a href='mailto:teacher_bugs\@adyn.com?subject=teacher bug report'>tell me about it</a>.\n";

  #foreach my $key (keys %ENV)
  #{
  #  print "$key --> $ENV{$key}<br>";
  #}

  print "</body>\n";
  print "</html>\n";
}

sub VerifyLogin_setIpFile__UNUSED
{
  my($userDir, $ip) = @_;

  my $ipFn = "$userDir/ip";
  my $f = new IO::File("> $ipFn");

  $ip = "127.0.0.1" if !defined $ip;

  print $f $ip;
  $f->close();
}

sub Crypt
{
  my($s) = @_;
  my $salt = "asdf;lkj";
  return crypt($s, $salt);
}

sub VerifyLogin
{
  my($query) = @_;
  my $session_id_passed_in = adyn_cgi_util::param($query, "session_id");
  my $session_id = undef;
  my $ip = $ENV{'REMOTE_ADDR'};
  my $userID = adyn_cgi_util::param($query, "userID");
  my $session_id_expected = (defined $ip && defined $userID) ? adyn_cgi_util::Crypt("$userID/$ip") : "";
  my $status = "OK";
  if ($session_id_passed_in)
  {
    if ($session_id_expected eq $session_id_passed_in)
    {
      $status = "VerifyLogin ok, session ID passed in is valid ($session_id_passed_in)\n";
      $session_id = $session_id_passed_in;
    }
  }
  if (!defined $session_id)
  {
    $userID = "" unless defined $userID;
    my $userDir = "../httpdocs/teacher/usr/$userID";
    my $pw = adyn_cgi_util::param($query, "pw");
    my $storedPw = GetPw($userDir);

    if (!$userID)
    {
      $status = "undefined userID";
    }
    elsif (! -d $userDir)
    {
      $status = "unrecognized user $userID";
    }
    elsif (!defined $pw)
    {
      $status = "no password";
    }
    elsif (!defined $storedPw || !defined $pw || (($storedPw ne "*") && $pw ne $storedPw))
    {
      $status = "Login failure";
    }
    else
    {
      $session_id = $session_id_expected;
      $status = "VerifyLogin ok, returning $session_id";
    } 
  }
  if (!defined $session_id)
  {
    $userID = "null" if !defined $userID;
    print "$status\n";
    MailAdyn("login failure", "$status for user $userID");
  }
  return $session_id;
}

sub StreamInFile
{
  my($fn) = @_;
  my $f = new IO::File("< $fn");
  if (defined $f)
  {
    while (<$f>)
    {
      print;
    }
    $f->close();
  }
}

sub CleanAndQuoteString
{
  my($s) = @_;
  if (!defined $s)
  {
    $s = "";
  }
  else
  {
    $s =~ s/"/\\"/g;
    $s =~ s/\n/ /g;
    $s =~ s/ $//g;
    $s =~ s{(a href=)(['"]?http)}{a hreF=$2}g;
    $s =~ s{(a href=)}{$1/teacher/html/}g;
    $s =~ s{/teacher/html/"}{"/teacher/html/}g;
  }
  return "\"$s\"";
}

1;
