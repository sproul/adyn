:
catResult=""
export REMOTE_ADDR=127.0.0.1

if [ ! -d "c:/" ]; then
	catResult="yes"
fi


Gen()
{
        cd $DROP/teacher
	perl -w tx.pl -genInfrastructure
}

Choose_by_url()
{
        url="$1"
        export PERL5LIB=/cygdrive/c/Users/nelsons/Dropbox/adyn/cgi-bin:/lib/perl5/site_perl/5.8/libwww-perl-5.805/lib:/lib:/cygdrive/c/Users/nelsons/Dropbox/bin/perl
        
        parms=`echo $url | sed -e 's/.*?//'`
        while [ 1 ]; do
                parm1=`echo $parms | sed -e 's/&.*//'`
                parms=`echo $parms | sed -e 's/^[^&]*&//'`
                echo $parm1
                if [ "$parm1" = "$parms" ]; then
                        break
                fi 
        done | perl -w choose.cgi
}

ChooseSet()
{
        url="$1"
        echo ""
        echo "ChooseSet $1 $2 $3"

        tense=$1
        verbs=$2
        exerciseType=$3

        REMOTE_ADDR="127.0.0.1"
        export REMOTE_ADDR

        cd $DROP/adyn/cgi-bin

        if [ -n "$verbs" ]; then
                out="${verbs}.$tense.$exerciseType"
        elif [ -f $tense.html ]; then
                out="${tense}_custom"	# don't let ts overwrite lang "reference" page
        else
                out="${tense}"
        fi
        rm -f $out.htm

        (
        echo "verboseMode=yes"
        if [ $tense = "vocab_selected" ]; then
                #echo "specific_exercise_IDs_for_testing=verb_wait_for.1:verb_wait_for.2:verb_wait_for.3:verb_wait_for.4:verb_wait_for.5:verb_wait_for.6:verb_wait_for.7:verb_wait_for.8:verb_wait_for.9:verb_wait_for.10:verb_wait_for.11:verb_wait_for.12:verb_wait_for.13:verb_wait_for.14:verb_wait_for.15:verb_wait_for.16:verb_wait_for.17:verb_wait_for.18:verb_wait_for.19:verb_wait_for.20:verb_wait_for.21:verb_wait_for.22:verb_wait_for.23:verb_wait_for.24:verb_wait_for.25:verb_wait_for.26:verb_wait_for.27:verb_wait_for.28:verb_wait_for.29:verb_wait_for.30:verb_wait_for.31:verb_wait_for.32:verb_wait_for.33:verb_wait_for.34:verb_wait_for.35:verb_wait_for.36:verb_wait_for.37:verb_wait_for.38:verb_wait_for.39:verb_wait_for.40:verb_wait_for.41:verb_wait_for.42:verb_wait_for.43"
                echo "specific_exercise_IDs_for_testing=verb_wait_for.43"
                echo "resetReviewExercises=1"
                echo "userID=nsproul"
                echo "exerciseType=vocab_selected"
                #echo "lang_Spanish=1"
                #echo "lang_French=1"
                echo "lang_Italian=1"
                echo "tense=present"
                echo "chosenCategories=verb_wait_for"
                echo "chosenCategories=verb_advise"
                echo reviewPercentage=100
                echo "exerciseSetTargetSize=1"
        elif [ $tense = "verb_selected" ]; then
                echo "userID=nsproul"
                echo "exerciseType=verb_selected"
                echo "lang_Italian=1"
                echo "tense=present"
                echo "chosenVerbs=verb_wait_for"
                echo "chosenVerbs=verb_advise"
                echo reviewPercentage=0
                echo "exerciseSetTargetSize=5"
        elif [ $tense = "custom" ]; then
                echo "userID=de"
                echo "exerciseType=vocab_selected"
                echo "lang_German=1"
                echo "chosenCategories=de_adjective_endings"
                echo "exerciseSetTargetSize=14"
                #echo "tense=preterite"
        elif [ $tense = "custom2_GoF" ]; then
                echo reviewPercentage=100
                echo whichPanel=choose.html
                #echo tense=all
                #echo randomSeed=12983
                echo exerciseSetTargetSize=3
                echo userID=GoF
                echo pw=x
                echo "lang_A=1";
                echo "promptLang=Q";
                #echo promptLang=English
                echo "exerciseType=vocab_selected";
                echo "chosenCategories=GoF"
                #echo exerciseType=verb_common
        elif [ $tense = "custom2_simple_arithmetic" ]; then
                        echo "reviewPercentage=0"
                        echo "exerciseSetTargetSize=15";
                        echo "exerciseType=vocab_selected";
           echo "chosenCategories=simple_arithmetic"
                        echo "lang_A=1";
                        echo "promptLang=Q";
                        echo "userID=ava"
                        echo "randomSeed=2208"
                elif [ $tense = "custom2_explicit" ]; then
                        echo "explicitlyRequestedExercises=base_396/verb_load_51"
                        echo "exerciseSetTargetSize=25";
                        echo "exerciseType=verb_all";
                        echo "lang_French=1";
                        echo "lang_German=1";
                        echo "lang_Italian=1";
                        echo "lang_Spanish=1";
                        #echo "canonizedTest=1";
                        echo "userID=user_100"
                elif [ $tense = "custom2_user100" ]; then
                        echo "reviewPercentage=50"
                        echo "exerciseSetTargetSize=15";
                        echo "exerciseType=verb_all";
                        echo "lang_French=1";
                        echo "lang_German=1";
                        echo "lang_Italian=1";
                        echo "lang_Spanish=1";
                        #echo "canonizedTest=1";
                        echo "userID=user_100"
                elif [ $tense = "custom2" ]; then
                        echo "reviewPercentage=0"
                        echo "exerciseSetTargetSize=25"
                        echo "userID=nsproul"
                        #echo "userID=interview"
                        #echo "tense=future_perfect"
		#echo "tense=present"
		echo "tense=all"
		echo "chosenVerbs=verb_have"
		echo "exerciseType=verb_selected"
	elif [ $tense = "j2ee" ]; then
		echo "chosenCategories=j2ee"
		echo "chosenCategories=jwsdp"
		echo "exerciseType=vocab_selected"
		echo "pageFromWhichNewQueriesWillBeInitiated=/teacher/html/alln.htm"
		echo "promptLang=Q"
		echo "lang_A=1"
		echo "userID=j2ee"
		
		
	elif [ $tense = "custom3" ]; then
		echo "userID=nsproul"
		echo "exerciseType=vocab_selected"
		#echo "exerciseType=verb_common"
		echo "tense=subjunctive"
		echo "userID=nsproul"
		echo reviewPercentage=0
		echo "exerciseSetTargetSize=15"
	else
		echo "userID=$tense"
		echo "exerciseType=vocab_selected"
		echo "promptLang=Q"
		echo "lang_A=1"
		echo "reviewPercentage=50"
		echo "chosenCategories=$tense"
		echo "exerciseSetTargetSize=25"
	fi
	) | perl -w choose.cgi |	cat; return

	if [ -n "$catResult" ]; then
		cat
	else
		cat > $out.htm
                echo test_choose.sh wrote $out.htm
	fi
}

#Gen
topic=$1
if [ -z "$topic" ]; then
        topic="verb_selected"
fi

#ChooseSet $topic
Choose_by_url "$1"
exit 0
