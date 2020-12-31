:
language=$1		# no arg -> get them all

cd can

mkdir -p review

for lang in `(cd grammar; ls -d $language|grep -v English)`; do
	echo "$0 dumping $lang..."
	../dump_one_lang.sh $lang - combineToOneLine | sort > review/$lang.raw
done
exit
cd $HOME/work/adyn.com/httpdocs/teacher; sh -x dump_langs.sh French