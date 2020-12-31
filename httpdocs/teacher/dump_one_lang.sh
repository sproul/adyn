:
lang=$1
area=$2
combineToOneLine=$3

cd data

if [ "$area" = "-" ]; then
	area=""
fi
if [ -z "$area" ]; then
	area="base vocab_* verb_*"
fi

for f in $area; do
	cd ..
	if [ -n "`echo $f|grep verb_`" ]; then
		noAddendKeyCycle=1
	else
		noAddendKeyCycle=0
	fi
	perl -w dump_one_lang.pl $lang $noAddendKeyCycle $f $combineToOneLine
	cd data
done

exit
cd $HOME/work/adyn.com/httpdocs/teacher/; sh -x dump_one_lang.sh German 1 verb_depend combineToOneLine