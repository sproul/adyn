package utility;
use strict;
use adynware::utility_file;

my $HTML_HEADER_NORMAL = "HTTP/1.0 200 OK\nContent-type: text/html\n\n";
my $HTML_HEADER_REDIRECT = "HTTP/1.0 301 Moved Temporarily\nMIME-Version: 1.0\nContent-Length: 0\nLocation: ";

my $__baseTime = time();
my $__cacheDir = "(uninitialized)";
my $__program = "";
my $__verbose = 4;
my $__logFast = 0;
my $__logBuffer = "";

sub GetMaxCacheFileSize()
{
        return 100000;
}

sub getStandardHtmlHeader
{
        return $HTML_HEADER_NORMAL;
}

sub Init
{
        my($program, $verbose, $cacheDir, $inputPort, $outputHost, $outputPort) = @_;
                
        if (defined $inputPort and $inputPort==$outputPort and $outputHost eq "127.0.0.1")
        {
                Die("$program: infinite port loop:$inputPort");
        }
        ($__program, $__verbose, $__cacheDir) = ($program, $verbose, $cacheDir);
}

sub LogInMemory
{
        my ($fast) = @_;
        $__logFast = $fast;
        LogFlush() unless $fast;
}

sub Log
{
        my ($message) = @_;
        $message =~ s/\n/\n\t/g;
        my $timeStampedMessage = sprintf("%04d[%s] %s\n", ($__baseTime - time()), $__program, $message);
        if ($__logFast)
        {
                $__logBuffer .= $timeStampedMessage;
        }
        else
        {
                print $timeStampedMessage;
        } 
}

sub LogFlush
{
        print $__logBuffer if $__logBuffer;
        $__logBuffer = "";
}

sub IsImage
{
        my($fileName) = @_;
        return ($fileName =~ /\.(gif|jpg)(\.new)?$/i);
}

sub Read
{
        my($caller, $input, $buffer, $length) = @_;
        my $n = undef;
        while()
        {
                #utility::Log("utility::Read about to call sys read");
                $n = sysread($input, $$buffer, $length); 
                #utility::Log("utility::Read back from sys read");
                
                last unless (!defined $n) and $! =~ /^Interrupted/;
        } 
        if ((!defined $n) or ($n < 0))
        {
                Log("__Read from $caller: sysread:$!");
                return 0;
        }
                                                        
        Log("just read $n bytes") if $__verbose >= 10;
        return $n;
}


sub Write
{
        my($caller, $output, $buffer, $length) = @_;
        my $offset = 0;
        while()
        {
                my $n = syswrite($output, $buffer, $length, $offset); 
                next if (!defined $n) and $! =~ /^Interrupted/;
                if ((!defined $n) or ($n < 0))
                {
                        Log("__Write from $caller: syswrite:$!");
                        return $offset;
                }
                Log("just wrote $n bytes");
                $length -= $n;
                $offset += $n;
                last unless $length>0;
        }
        return $offset;
}


sub SendRequest 
{
        my ($server, $clientRequest) = @_;
	$clientRequest =~ s/^Accept-Encoding: gzip.*?\n//im;
	Log("utility::SendRequest:$clientRequest") ;#if $__verbose >= 9;
	        	                                        
        my($savedSelectedFile) = select($server); $| = 1; select($savedSelectedFile);
        $clientRequest =~ s/\n/\r\n/g;
        $clientRequest =~ s/\r\r/\r/g;
        print $server $clientRequest;
}


sub ReadHeader
{
        my($caller, $input) = @_;
        my $buffer = "";
        Log("ReadHeader reading") if $__verbose >= 8;
        my $header = "";
        my $consecutiveZeroByteReads = 0;
        while()
        {
                my $chunk;
                my $n = 0;
                $n = Read($caller, $input, \$chunk, 9184);
                if ($chunk eq "stop")
                {
                        Log("utility::ReadHeader: shutdown request received.  Exiting...");
                        LogFlush();
                        exit(0);
                }
                $buffer .= $chunk;
                Log("ReadHeader has $buffer") if $__verbose >= 20;
                last if $buffer eq "prefetch";
                if ($buffer =~ s/(.*?\n\r?\n)//s)
                {
                        $header = $1;
                        $header =~ s/\r//g;
                        last;
                }
                if ($n)
                {
                        $consecutiveZeroByteReads = 0;
                }
                else
                {
                        $consecutiveZeroByteReads++;
                        last if ($consecutiveZeroByteReads > 10);
                } 
        }
        if ($header =~ /^post/i
        and $header =~ /content-length: (\d+)/i)
        {
                my $postedDataLength = $1;
                my $dataRead = length($buffer);
                while ($postedDataLength > $dataRead)
                {
                        my $chunk;
                        my $n = 0;
                        $n = Read($caller, $input, \$chunk, 9184);
                        Log("reading posted data: $dataRead read, got $n, need $postedDataLength") if $__verbose >= 10;
                        if ($n)
                        {
                                $buffer .= $chunk if $n;
                                $dataRead += $n;
                                $consecutiveZeroByteReads = 0;
                        }
                        else
                        {
                                $consecutiveZeroByteReads++;
                                last if ($consecutiveZeroByteReads > 10);
                        } 
                }
        }
              
        Log("$caller called ReadHeader got $header") if $__verbose >= 4;
        Log("ReadHeader saw posted data: $buffer") if $__verbose >= 20;
        
        return $header . $buffer;
}

sub ReadFirstChunk
{
        my($caller, $server, $target, $referenceToExcess, $referenceContentType, $referenceContentLength, $suppressContentLength, $suppressDate) = @_;
        my $serverResponse = utility::ReadHeader($caller, $server);
        return undef unless $serverResponse;
        my $header;
        if ($serverResponse =~ s/(.*?\n\r?\n)//s)
        {
                $header = $1;
        }
        else
        {
                $header = $serverResponse;
                $serverResponse = "";
        }
                        
        my $contentType;
        if ($header =~ /^content-type:\s*(\S+)/im)
        {
                $contentType = $1;
        }
        else
        {
                $contentType = "image"; # we don't know what this is; resist the temptation to treat it as HTML to be modified
        }
        Log("content type is $contentType") if $__verbose >= 3;
                
        if (defined $referenceContentLength)
        {
                $$referenceContentLength = undef;
                if ($header =~ /^content-length:\s*(\d+)/im)
                {
                        $$referenceContentLength = $1;
                }
        } 
        
        if ($contentType =~ "text/html")
        {
                $header =~ s/content-length.*\n//i if $suppressContentLength;
                $header =~ s/Date:.*\n//i          if $suppressDate;
        }
                                                         
        $$referenceContentType = $contentType if defined $referenceContentType;
        $$referenceToExcess = $serverResponse;
        return $header;
}


sub LogState
{
        my($label, $handleKey, $stateReference) = @_;
        my $message = "logging state: " . $label . " " . $handleKey . "=>";
        if (!defined $stateReference)
        {
                $message .= "(undefined)";
        }
        else
        {
                my @state = @$stateReference;
                my $element;
                $message .= "[";
                my $j = 0;
                foreach $element (@state)
                {
                        $j++;
                        $message .= "," if $j > 1;
                                                
                        if (defined $element)
                        {
                                my $s = "";
                                $s .= $element;
                                $s =~ s/\n.*/.../s;
                                $s = "(long string)" if length($s) > 25;
                                $message .= $s;
                        }
                        else
                        {
                                $message .= "undef";
                        }
                }
                $message .= "]";
        }
        Log("$message") if $__verbose >= 9;
}

sub GetCacheName
{
        my($queryFile) = @_;
        
        my $fileName = utility_file::flattenURL($queryFile);
        
        # allow 55 characters for the cache directory name
        $fileName = substr($fileName, 0,  255 - 55) if (length($fileName) >=  255 - 55);

        return "$__cacheDir/$fileName";
}

sub Die
{
        my($message) = @_;
        print "utility::Die($message)\n";
        executeAdynware("fatalError", $message);
        die $message;
}

sub TruncateForDisplay
{
        my($maximum, $s) = @_;
        my $newS;
        if (length($s) < $maximum)
        {
                $newS = $s;
        }
        else
        { 
                if ($maximum < 10)
                {
                        $newS = "";
                }
                else
                {
                        $newS = substr($s, 0, $maximum - 3) . "...";
                }
        }
        #print "truncate($maximum, $s) yielded $newS\n";
        return $newS;
}

sub packIPMask
{
        my($mask) = @_;
	if ($mask !~ /^(\d+)(\.(\d+))?(\.(\d+))?(\.(\d+))?$/)
	{
		return $mask; # this is a host name or regexp, not a numeric IP @.  We cannot pack it.
	}
                        
        my($b0, $b1, $b2, $b3) = ($1, $3, $5, $7);
        my $packed;
        if (!defined $b0)
        {
                $packed = 0;
        }
        elsif (!defined $b1)
        {
                $packed = pack("C1", $b0);
        } 
        elsif (!defined $b2)
        {
                $packed = pack("C2", $b0, $b1);
        } 
        elsif (!defined $b3)
        {
                $packed = pack("C3", $b0, $b1, $b2);
        } 
        else
        {
                $packed = pack("C4", $b0, $b1, $b2, $b3);
        }
        
        #printf "packIPMask(%s):%s\n", $mask, unpack("H" . (2 * length($packed)), $packed);
        return $packed; 
}

sub IPInMask
{
        my($i, $mask) = @_;
        my $length = length($mask);
        my $in = (substr($i, 0, $length) eq $mask);
                                
        return $in;
}

sub IPtoString
{
	my($ip) = @_;
	return sprintf "%s", unpack("H8", $ip);
}

sub IPInMaskSet
{
        my($host, @set) = @_;
        return 0 unless scalar(@set); 
        my($name, $aliases, $addressType, $length, @addresses) = gethostbyname($host);
        foreach my $address (@addresses)
        {
                foreach my $mask (@set)
                {
			if ((($mask !~ /^[\w\*\.]+$/) && IPInMask($address, $mask))
			|| ($host =~ /^$mask$/))
			{
                                Log("IPInMaskSet($host) should be accessed directly") if $__verbose >= 9; 
                                return 1;
                        } 
                }
        }
        Log("IPInMaskSet($host) should be accessed through the proxy server") if $__verbose >= 9; 
        return 0;
}

sub constructIPMaskSet
{
        my($s) = @_;
        my @strings = split(/;/, $s);
        return constructIPMaskSetFromVector(@strings);
} 

sub constructIPMaskSetFromVector
{
        my @strings = @_;
	my @ipStrings = ();
        my @ipSet = ();
        foreach my $s (@strings)
        {
                if ($s =~ /(\d+\.)+\d+/)
                {
                        push(@ipStrings, $s);
                }
                else
                {
			my(      $name, $aliases, $addressType, $length, @addresses);
			if ($s !~ /\*/)
			{
				($name, $aliases, $addressType, $length, @addresses) = gethostbyname($s);
			}
			else
			{
				$s = "." . $s if $s =~ /^\*/;   # convert sh regexp to perl, e.g., *.sun.com to .*.sun.com
			}
			my $message = "proxy exception $s will be accessed directly";
			Log($message);
						
			push(@ipSet, $s);
                        if (scalar(@addresses))
                        {
				Log("resolved proxy exception $s to " . @addresses . " addresses");
                                foreach my $address (@addresses)
                                {
					Log("resolved proxy exception $s to " . @addresses . " addresses, including " . IPtoString($address));
                                        push(@ipSet, $address);
                                }                                                                  
                        }                                                                  
                }
        }
                                
        foreach my $maskString (@ipStrings)
        {
                my $i = utility::packIPMask($maskString);
		if ($i)
		{
			Log("IP masking $maskString");
			push(@ipSet, $i);
		} 
		else
		{
			Log("IP mask $maskString rejected");
		}

        }
        return @ipSet;
}

sub executeAdynware
{
        my($flag, $arguments) = @_;
        Log('system(' . "c:\\perl\\bin\\$__program.exe -$flag $arguments" . ')');
        system("c:\\perl\\bin\\$__program.exe -$flag $arguments");
} 
sub unescape
{
        my($data) = @_;
        $data =~ s/%([\da-fA-F][\da-fA-F])/'sprintf("%c", 0x' . $1 . ')'/eeg;
        return $data;
}

sub HandleAdynware
{
        my($client, $operation, $data) = @_;
        $data = unescape($data);
        my $redirectTarget = undef;
        if ($operation eq "perl")
        {
                Log("handle adynware: evaluating $data");
                eval($data);
                if ($@)
                {
                        Log("eval failed:$@");
                }
        }
        else
        {
                executeAdynware($operation, $data);
        } 
        answerBrowser($client, $redirectTarget);
        return 1;
}


sub answerBrowser
{
        my($client, $redirectTarget) = @_;
        if (defined $redirectTarget)
        {
                print $client $HTML_HEADER_REDIRECT, $redirectTarget, "\n\n";
        }
        else
        {
                print $client $HTML_HEADER_NORMAL, "<html> <body>";
                print $client "<script language='JavaScript'> onLoad=close; </script> ";
                print $client "</body> </html> ";
        }
}


sub Spit
{
        my($port) = @_;
        Log("about to attempt to shut down any server at $port.  This will result in an error message (IO::Socket::INET: Invalid argument) unless a server was already running there");
        my $server = IO::Socket::INET->new(PeerAddr => "127.0.0.1", PeerPort => $port, Proto => 'tcp');
        return unless $server;
        Log("found a server; shutting it down");
        print $server "stop";
        close $server;
        sleep 4;
}

1;
