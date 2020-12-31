use strict;
use diagnostics;

while (<STDIN>)
{
  chop;
  next unless $_;
  s/\..*//;
  s/.*> .//;
  s/[(),!\?;:]//g;
  my @tokens = split(/ /);
  
  $tokens[0] =~ s/(.*)/\L$1/;
  print $tokens[0], "\n";
  
  for (my $j = 1; $j < scalar(@tokens); $j++)
  {
    print $tokens[$j], "\n";
  } 
}
# 
# $HOME/work/bin/k:
# :
# cd $HOME/Dropbox/adyn/httpdocs/teacher/data/
# grep English verb_come | grep -v / | grep '=>' | perl $HOME/Dropbox/adyn/httpdocs/teacher/size_report_vocab_filter.pl | uniq | wc -l
# exit
# sh -x $HOME/work/bin/k 
# 
# # test with: sh -x $HOME/work/bin/k
