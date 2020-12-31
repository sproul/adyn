:
mode=$1

Step()
{
        echo "===`date` $* ==================================="
}

CheckForSillyMistakes()
{
        grep -n "'Italian' => "  $HOME/work/adyn.com/httpdocs/teacher/data/*|grep ' de '
}

(
Step Verify_loadability
cd $HOME/work/adyn.com/httpdocs/teacher
date
perl -w tx.pl -Verify_loadability
date

Step generate doc
cd ..
perl -w adynware.pl -teacherOnly -generate
cd teacher

if [ "$mode" != "quick" ]; then
	Step clean out generated files
	sh ./clean.sh
	rm -f html/*.class
fi

mkdir -p c:/tmp/sql/
touch    c:/tmp/sql/dummy
rm       c:/tmp/sql/*

rm -f $fn $HOME/work/adyn.com/httpdocs/teacher/grammar/*.dp

Step ts
perl -w tx.pl -genPath ts                    -categories English/ts
perl -w tx.pl -genPath de_adjective_endings  -categories English/German
perl -w tx.pl -genPath it_past               -categories English/Italian

sh -x ./transform_into_flashcards.sh

Step generate $lang grammar and associated exercises
perl -w tx.pl -genAll -lang all -grammar -genExercises -relinkAll

cp html/English.htm	 html/English.html

Step cf previous generated stuff
sh ./cf.sh world_except_test

if [ "$mode" != "quick" ]; then
	Step find all
	$HOME/work/bin/find.all
fi

Step tag all
$HOME/work/emacs/tags/generate.sh teacher

Step build java
cd html
sh java116_make.sh build
cd ..

Step generate infrastructure code
perl -w tx.pl -genInfrastructure
if [ -z "`grep '^Main' ../bin/choose.cgi`" ]; then
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "genInfrastructure did not finish!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi

#Step eval size
#sh ./size_report.sh
#
#Step test
#sh -x ./test.sh $mode
#
#Step full test
#sh -x ./test.sh full

if [ "$mode" != "quick" ]; then
	Step back up
	mkdir -p d:/old
	rm -rf   d:/old/teacher
        cp -rp $HOME/work/adyn.com/httpdocs/teacher $BACKUP_DIR/teacher
fi

#sh ./size_report.sh

Step done
) | tee $HOME/tmp/all.out

perl -w generate_java_db.pl

sh dump_langs.sh
perl -w update_rvw_db.pl French
perl -w update_rvw_db.pl Italian
perl -w update_rvw_db.pl German
perl -w update_rvw_db.pl Spanish

$HOME/work/adyn.com/httpdocs/teacher/test/server/test.sh

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/all.sh all &
exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/all.sh quick
