:

Project()
{
	topic=$1

	cd $DROP/teacher
        mv data/out_$topic data/$topic $TMP 2> /dev/null
	
	perl -w transform_into_flashcards.pl $topic
	perl -w tx.pl -genPath $topic -categories Q/A
        cp -p data/out_$topic data/$topic $DROP/adyn/cgi-bin/data
}

Project $1

exit
topic=alta_CA
sh -x $HOME/work/adyn.com/httpdocs/teacher/transform1_into_flashcards.sh $topic