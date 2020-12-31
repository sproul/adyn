:
pattern=$1
if [ -z "$pattern" ]; then
	echo arg required
	exit
fi

if [ ! -f $HOME/work/adyn.com/httpdocs/teacher/data/verb_$pattern ]; then
	echo Cannot find  $HOME/work/adyn.com/httpdocs/teacher/data/verb_$pattern
else		
	rm -f  $HOME/work/adyn.com/httpdocs/teacher/data/verb_$pattern
fi
rm -f $HOME/work/adyn.com/httpdocs/teacher/html/verb_$pattern.*.html

for f in $HOME/work/adyn.com/httpdocs/teacher/usr/*/data; do
	grep -v $pattern $f > $f.tmp
	mv $f.tmp $f
done


exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh raise
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh wipe
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_obligated_to
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_silent
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_able_to
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh break
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh choose
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh come_after
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh come_down
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh cost
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh depend
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh displease
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh emerge
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh enter
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh exist
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh get_on_board
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh grow
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh happen
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh le
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh ris
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh abolish
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh act
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh stop
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh stay
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh spend
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh mount
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh owe
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh perish
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh pull
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh regrett
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh remain
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh retain
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh show
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh look_like
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_necessary
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh marry
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh could
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh tell
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh prevail
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh undress
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh restore
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh conclude
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh updateVtlOnly
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_lacking
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh be_born
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh retain
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh wipe
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh fatigue
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh retain
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh swing
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh sound
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh point
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh find_oneself
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh continue
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh feel
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh stand
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh wind
sh -x $HOME/work/adyn.com/httpdocs/teacher/rm1.sh glimmer
cp c:/users/nsproul/work/bin/perl/utility_file.pm c:/perl/lib/adynware/utility_file.pm
