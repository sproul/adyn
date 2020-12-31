:
for topic in `ls.topics`; do
        if [ $topic != "langs" ]; then
                sh $DROP/teacher/transform1_into_flashcards.sh $topic
        fi
done
exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/transform_into_flashcards.sh 