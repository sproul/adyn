package web_site;
use strict;
#use diagnostics;
use Ndmp;
use IO::Socket;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

my %verifiedLinks = ();

sub Find
{
        my $self = shift;
        my($target) = @_;
        print "web_site::Find($target)\n";        
                
        $self->Traverse($target, 
                
        sub 
        {
                my($name, $content) = @_; 
                #print "web_site::Find:$name\n";
        });
}

sub GetLinks
{
        my($base, $page) = @_;
        #print "GetLinks($base)\n";
        die "web_site::GetLinks cannot see protocolAndHost in $base" unless $base =~ m{([^/]*//[^/]*)/};
        my $protocolAndHost = $1;
        my @links = ();
                                                                                        
        my $tags = "(href|src|action)";
        while ($page =~ m
        {
                $tags\s*=\s*
                "([^"]+)"
        }gisx)
        {
                #print "match:3:$2\n";
                push(@links, web_site::makeAbsolute($2, $base, undef));
        }
                        
        while ($page =~ m
        {
                $tags\s*=\s*
                '([^']+)'
        }gisx)
        {
                #print "match:4:$2\n";
                push(@links, web_site::makeAbsolute($2, $base, undef));
        }
                        
        while ($page =~ m
        {
                $tags\s*=\s*
                ([^\s>'"]+)
        }gisx)
        {
                #print "match:5:$2\n";
                push(@links, web_site::makeAbsolute($2, $base, undef));
        }                          
        return @links;
}


sub InvalidLink
{
        my($from, $link, $statusCode, $message) = @_;
        $from = "(null)" unless defined $from;
        print "web_site::InvalidLink($from, $link, $statusCode, $message)\n";
}

sub Traverse
{
        my $self = shift;
        my($target, $function) = @_;
        my @in = ($target);
        my %out = ();
        %verifiedLinks = ();
                                                                
        while(scalar(@in))
        {
                my $currentTarget = pop @in;
                next if defined $out{$currentTarget};
                $out{$currentTarget} = 1;
                                                                                
                my $response = $self->{"agent"}->request(new HTTP::Request("GET", $currentTarget));
                my $content = $response->content();
                die "could not retrieve $currentTarget" unless defined $content; 
                                                                                
                &$function($currentTarget, $content) if defined $function;
                                                                                                                                
                my $base = $response->base();
                                                                
                my @links = GetLinks($base, $content);
                foreach my $link (@links)
                {
                        next if defined $out{$link} or defined $verifiedLinks{$link};
                        my $content_type = $self->GetContentType($link, $currentTarget);
                        if ($content_type and $content_type eq "text/html" and $link =~ /^$target/)
                        {
                                #print "should pursue $link\n";
                                push(@in, $link);
                        }
                }
        }
}

sub ValidLink
{
        my($from, $link) = @_;
        $from = "(null)" unless defined $from;
        $verifiedLinks{$link} = 1;
        print "web_site::ValidLink($link)\n";
}

sub GetContentType
{
        my $self = shift;
        my($link, $from) = @_;
        
        my $response = $self->{"agent"}->request(new HTTP::Request("HEAD", $link));
                
        if ($response->is_error())
        {
                $response = $self->{"agent"}->request(new HTTP::Request("GET", $link));
        }
        if ($response->is_error())
        {
                InvalidLink($from, $link, $response->code(), $response->message());
                return undef;
        }
        $verifiedLinks{$link} = 1;
        print "web_site::GetContentType($link): ok\n";
        ValidLink($from, $link);
        return $response->content_type();
}

sub CheckLink
{
        my($self, $link, $from) = @_;
        return 1 if defined $verifiedLinks{$link};
        return defined $self->GetContentType($link, $from); 
}

sub Verify_list_of_links
{
        my($list) = @_;
        my $agent = new LWP::UserAgent;
        foreach my $link (@$list)
        {
                CheckLink($agent, $link, undef);
        }
}

sub ResolveBase
{
        my($response) = @_;
        return undef unless defined $response;
        
        # if the response is from a https query, then the request can be null.
        # In this case, calling response->base() crashes perl.  So check:
        return undef unless defined $response->request;
        return ResolveBase2($response->content(), $response->base());
}

sub ResolveBase2
{
        my($content, $headerBase) = @_;
        return $headerBase unless $content =~ s/<\s*base\s*href\s*=\s*['"]?(.*?)['"]?\s*>//ims;
        my $contentBase = $1;
        return web_site::makeAbsolute($contentBase, $headerBase, undef);
}


sub CachedGet
{
  my($cacheDirectory, $target) = @_;
                  
  return undef unless $target =~ m{(.*)/([^/]*)$};
  my $dirname = utility_file::flattenURL($1);
  my $basename = $2;
                          
  $dirname = "$cacheDirectory/$dirname" if $cacheDirectory;
                                  
  $basename = "index.htm" unless $basename;
                          
  mkdir($dirname, 777) unless -d $dirname;
  my $fileName = "$dirname/$basename";
  #print "cached get: cache directory is $cacheDirectory; dir name is $dirname; base name is $basename\n"; exit();
          
          
  if (-f "$fileName.raw")
  {
    my $content = utility_file::getContent("$fileName.raw");
    die "could not extract base from $fileName.raw" unless $content =~ s/^base is (.*)//;
    my $base = $1;
    return ($content, $base, $fileName);
  }
  my($content, $base, $content_type) = Get($target);
  utility_file::setContent("$fileName.raw", "base is $base\n$content");
  return ($content, $base, $content_type, $fileName);
}
sub Get
{
  my($target, $retry) = @_;
  if ($target =~ m{(c:/.*)/([^/]+\.html?)})
  {
    my($base, $basename) = ($1, $2);	  
    my $content = utility_file::getContent($target);
    return ($content, $base, "text/html", $basename);
  }
  my $agent = new LWP::UserAgent;
  my $response = $agent->request(new HTTP::Request("GET", $target));
  #print "//" . ref($response->{"_headers"}->last_modified) . "//" . $response->header() . "\n";
  #Ndmp::H("res", %$response);
  
  return undef unless defined $response and $response;
                  
  my $location = $response->header('Content-Location');
  	
   
  my $basename;
  if ($location)
  {
    $basename = utility_file::basename($location);
  }
  else
  {
    $basename = utility_file::basename($target);
    $basename = "index.htm" unless $basename;
  }
          
  my $content = $response->content();
          
  if (!$content && $response->code() == 500 && !defined $retry) # read timeout on first attempt
  {
    return Get($target, 1);
  }
  
  if (!$content)
  {
    print "web_site.pm: Get($target) failure: ", $response->code(), ": ", $response->message(), "\n";
  }
  else
  {
    print "web_site.pm: Get($target): ", $response->content_type(), " ", $response->code(), ": ", $response->message(), " to $basename\n";
  }
  return ($content, web_site::ResolveBase($response), $response->content_type(), $basename);
}

sub GetToFn
{
  my($target, $fn) = @_;
  my($content, $base, $content_type, $basename) = Get($target);
  utility_file::setContent($fn, $content, 1);
}


sub new
{
  #web_site::Get("http://o266/r?pageid=idx-home&amp;idx&amp;comefrom=idx-ad&amp;proxyad"); exit();
  
  my $class = shift;
        my $self = {};
        bless $self, $class;
        $self->{"agent"} = new LWP::UserAgent;
        return $self;
}

sub makeAbsolute
{
        my($oldLink, $base, $current) = @_;
        $base = "" unless defined $base;
        $current = "" unless defined $current;
                
        #print "web_site::makeAbsolute($oldLink, $base, $current)\n";
        ##return $oldLink if !$base or $base eq "." or $oldLink =~ m{^[^/]+:};
                        
        my $link = $oldLink;
                                
        # looksmart.com has URL references which begin with http:/whatever; should be interpreted as /whatever
        $link =~ s{\w+:/([^/])}{$1};
                                                
        if ($link =~ /^#/)
        {
                $current =~ s/#.*//;
                $link = $current . $link;
        }
        #print "sending $link, $base\n";
        my $absolute = new URI::URL($link, $base)->abs();    
        
        $absolute =~ s/&amp;/&/g;
        
        $absolute =~ s{^([^:]+://[^/]+/)(\.\./)+}{$1}g;  # simply eliminate  leading "../" -- that's what navigator does
        $absolute =~ s{/[^/]+/\.\./}{/}g;
        
        #print "makeAbsolute($oldLink, $base) yielded $absolute\n";
        return $absolute;
}



#my $w = web_site->new();
#$w->Find("http://www.sterls.com/");
#$w->Find("http://www.adyn.com");
#$w->Find("http://www.adyn.com/k.html");
#$w->Find("http://www.adyn.com/spinach/faq.html");
#$w->Find("http://www.slip.net/");
#$w->Find("http://home.netscape.com/");

#my $agent = new LWP::UserAgent;
#my $request = new HTTP::Request("GET", "http://www.sterls.com/");
#my $response = $agent->request($request);
#my $content = $response->content();
#my $header = $response->base();
#
#my $x = new URI::URL("../spinach/spinach.html", "http://www.adyn.com/etc/link.html");
#print $x->abs()->as_string();
#$x = new URI::URL("#whatever", "http://www.adyn.com/etc/link.html");
#print $x->abs()->as_string();
#
#my $x;
# $x = makeAbsolute("http://www.m-w.com/cgi-bin/dictionary?book=Dictionary&amp;va=bloviate", "http://www.m-w.com/cool/newwords", undef);
# $x = makeAbsolute("../../index.html", "http://www.m-w.com/", undef);
# $x = makeAbsolute("#offset", "http://www.m-w.com/", "http://www.adyn.com/index.html#initial");
# $x = makeAbsolute("36.html", "http://www.geek-girl.com/emacs/faq/", "http://www.geek-girl.com/emacs/faq/index.html");
#
#my($content, $base, $type, $basename) = Get("c:/users/nsproul/work/ts/html/k.htm");
#print "$content\n======================$base/$type/$basename\n";

1;
