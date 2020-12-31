:
verb_a=$1
verb_a=`echo $verb_a|sed 's/_/ /g'`

cd html
hits=`grep -l "</i>: to $verb_a</h3>" *_vt_*.html`
echo "Will remove:"
echo $hits
rm -f $hits

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/clean1.sh be