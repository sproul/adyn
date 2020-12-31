:
date
#perl -w tx.pl -genPath it_past              -categories English/Italian ;exit

Ts()
{
	touch data/ts

	#genId="-genId 0"

	perl -w tx.pl $genId -genPath ts -categories English/ts
	browser html/ts.0.html
	echo i am done
}
#Ts; exit

Grammar()
{
        date
        lang=$1
        genExercises=$2

        if [ -n "$genGrammar" ]; then
                touch grammar/*.htm
        fi

        if [ -n "$verb_a" ]; then
                area=`echo "$verb_a" | sed -e 's/-verb_a //' -e 's/2$//'`
                if [ $area != "base" ]; then
                        if [ ! -f data/$area ]; then
                                area="verb_${area}"
                        fi
                fi
                if [ -n "$id" ]; then
                        fileToGen=html/$area.$id.html
                        rm -f $fileToGen
                fi
                gen="-genId $id -genPath $area"		# -reviewerHTML
        else
                gen="-genPath"
        fi

        if [ -n "$profiling" ]; then
                profileArg="-d:DProf"
        else
                profileArg=""
        fi

        echo  perl $profileArg tx.pl $MassageAndFootnoteDebug $gen $fillInLinks $fixups $ConfirmReview $MakeReview $ReadReview $genInfrastructure $link $genExercises $verb_a $verb_b $relinkAll $SampleIdFixup $ProposeExercises -lang $lang -grammar
        perl       $profileArg tx.pl $MassageAndFootnoteDebug $gen $fillInLinks $fixups $ConfirmReview $MakeReview $ReadReview $genInfrastructure $link $genExercises $verb_a $verb_b $relinkAll $SampleIdFixup $ProposeExercises -lang $lang -grammar

        if [ -n "$profiling" ]; then
                dprofpp -u -I -O 100
        fi
        if [ -n "$genAll" ]; then
                date
                perl -w tx.pl $genAll
                date
        fi
        date
        echo "Ambiguous count: `grep ambiguous/$lang data/_grammar|wc -l`"

        if [ -n "$verb_a" ]; then
                # the *.dp files are invalid if we did a verb_a setting.
                # touch the *.htm to force regen of *.dp:
                touch grammar/*.dat.htm
                if [ -n "$fileToGen" ]; then
                        echo Maybe generated $fileToGen
                fi
        fi
        #diff $HOME/work/adyn.com/httpdocs/teacher/base.old  $HOME/work/adyn.com/httpdocs/teacher/data/base; exit


        #sh -x $HOME/work/adyn.com/httpdocs/teacher/dump_bases.sh
        #diff base.old base.new	|grep '[<>]' |sed -e 's/^[<>] //'
        #
        #-e /base.7:/d	\
        #

        #echo Skipping cf.sh in $HOME/work/adyn.com/httpdocs/teacher/t.sh ; return
}

#relinkAll="-relinkAll"
#ConfirmReview="-ConfirmReview $HOME/work/adyn.com/httpdocs/teacher/corrections/corrections.10.17.answer"
#MakeReview="-MakeReview"
#ReadReview="-ReadReview $HOME/work/adyn.com/httpdocs/teacher/corrections/corrections.9.30"
#fixups="-fixups"
#MassageAndFootnoteDebug="-MassageAndFootnoteDebug"
genExercises="-genExercises"
#profiling=y
#area=separate
#id=29
genGrammar=y
#SampleIdFixup=-SampleIdFixup
#genAll="-genAll"
#ProposeExercises="-ProposeExercises"

touch $HOME/work/adyn.com/httpdocs/teacher/grammar/*.dat.htm
echo touch all

#verb_a="-verb_a find"
#verb_b="-verb_b sich_unterhalten"
verb_a="-verb_a wait_for"

Grammar Spanish $genExercises
#Grammar French $genExercises
#Grammar Italian $genExercises
#Grammar German $genExercises
#Grammar all $genExercises
#Grammar
sh ./cf.sh
echo i am done
date
exit 0
