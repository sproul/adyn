package Ndmp;
use strict;
use diagnostics;
use Data::Dumper;

sub a
{
        my(@a) = @_;
	call_Dumper([ \@a], [ qw(*a)], undef, 0);
}

sub A
{
	my($s, @a) = @_;
	call_Dumper([ \@a], [ qw(*a) ], $s, 0);
}


sub Ah
{
	my($s, @a) = @_;
	call_Dumper([ \@a], [ qw(*a) ], $s, 1);
}

sub As
{
  my($quote, @a) = @_;
  call_Dumper_to_compressed_string([ \@a], [ qw(*a) ], $quote);
}

sub h
{
        my(%h) = @_;
	call_Dumper([ \%h], [ qw(*h)], undef, 0);
}


sub H
{
  my($s, %h) = @_;
  call_Dumper([ \%h], [ qw(*h)], $s, 0);
}

sub Hh
{
  my($s, %h) = @_;
  call_Dumper([ \%h], [ qw(*h)], $s, 1);
}

sub Hs
{
  my($quote, %h) = @_;
  call_Dumper_to_compressed_string([ \%h], [ qw(*h)], $quote);
}

sub call_Dumper_to_compressed_string
{
  my($valuesReference, $namesReference, $quote) = @_;
  $Data::Dumper::Purity = 1;
  my $Dumper = Data::Dumper->new($valuesReference, $namesReference);
  my $d = $Dumper->Dump();
  $d =~ s/^[ \t]+//gm;
  $d =~ s/[ \t]+\n/\n/g;
  $d =~ s/ => /=>/g;
  $d =~ s/'0'/0/g;
  $d =~ s/\n//g;
  $d =~ s/;$//;
  $d =~ s/ = /=/;
  if (defined $quote)
  {
    
    
    
    #$d =~ s/$quote/\\$quote/g;
    warn "nested >$quote< seen in $d" if $d =~ /$quote/;
        
        
    
    $d = $quote . $d . $quote;
  }

  return $d; # . "\n";
}

sub call_Dumper
{
  my($valuesReference, $namesReference, $s, $horizontal) = @_;
  $Data::Dumper::Purity = 1;
  my $Dumper = Data::Dumper->new($valuesReference, $namesReference);
  	
  $s .= ": " if defined $s;
  	
  print STDERR ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$s\n";
  my $d = $Dumper->Dump();
  if ($horizontal)
  {
    #$d =~ s/^\s+//gm;
    		
    $d =~ s/',\n/'/g;
    $d =~ s/(\d),\n/$1/g;
    $d =~ s/undef,\n/undef/g;
    		
    $d =~ s/[ \t]+/ /g;
    $d =~ s/'0'/0/g;
  } 
  print STDERR $d;
  print STDERR "EOD================================$s\n";
}

#my %x = ();
#$x{4} = 45;
#h(%x);


1;
# #test with: cd $HOME/work/bin/perl; perl -w ndmp.pm
