:


Grammar()
{
	lang=$1
	if [ $lang = "all" ]; then
		Grammar Spanish $genExercises
		Grammar Italian $genExercises
		Grammar French $genExercises
		Grammar German $genExercises
		return
	fi 
	fn=grammar/$lang.html
	perl -w tx.pl -lang $lang -grammar $genExercises $ProposeNotesDebug $ProposeNotes -genPath $area -genId $id
}

ProposeNotesDebug="-ProposeNotesDebug"
ProposeNotes="-ProposeNotes"
id=58
area=verb_bring
area=base
area=verb_possess
#Grammar Spanish $genExercises
#Grammar Italian $genExercises
Grammar French $genExercises
#Grammar German $genExercises
#Grammar all $genExercises
exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/t_debug_ProposeNotes.ksh 