require 5.004;
use strict;
use IO::Socket;
use IO::File;

my $spit__host = "127.0.0.1";
my $spit__port = 38200;
my $spit__data = "stop";

sub Init
{
        return unless @ARGV;
        $_ = shift @ARGV;
        if (/([\w\.]+):(\d+)/)
        {
                $spit__host = $1;
                $spit__port = $2;
                $_ = shift @ARGV;
        }
        $spit__data = $_ if $_;
}

sub Main
{
        my $server = IO::Socket::INET->new(PeerAddr => $spit__host, PeerPort => $spit__port, Proto => 'tcp');
        if (!$server)
        {
                print "could not connect to $spit__host:$spit__port\n";
                return;
        }
        print "sending '$spit__data' to $spit__host:$spit__port\n";
        print $server $spit__data;
        close $server;
}

Init();
Main();

# test with: perl -w $HOME/work/bin/perl/spit.pl