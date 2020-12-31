:
sh gd addendKey|sed -e 's/:.*//'|uniq|
while [ 1 ]; do
	read df
	if [ -z "$df" ]; then
		break
	fi
	already="dump_English_with_addends.list_of_verbs_already_dumped"
	if [ -z "`grep $df $already`" ]; then
		perl -w dump_one_lang.pl English $df
		echo $df >> $already
	fi
done
exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/dump_English_with_addends.sh 