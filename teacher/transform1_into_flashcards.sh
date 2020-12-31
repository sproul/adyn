:

browse_mode=''
while [ -n "$1" ]; do
        case "$1" in
                -browse)
                        browse_mode=yes
                ;;
                *)
                        break
                ;;
        esac
        shift
done

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
if [ -n "$browse_mode" ]; then
        $DROP/bin/facts.rvw $topic
fi

exit
topic=alta_CA
sh -x $HOME/work/adyn.com/httpdocs/teacher/transform1_into_flashcards.sh $topic