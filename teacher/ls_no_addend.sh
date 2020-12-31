:

for f in data/verb_*; do
	if [ -z "`grep -l z/English/addend $f`" ]; then
		echo $f
	fi 
done

exit
cd $HOME/work/adyn.com/httpdocs/teacher/; sh ls_no_addend.sh 