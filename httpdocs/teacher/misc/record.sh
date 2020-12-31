:
lang=$1
which=$2
redo=$3
needToStartSoundRecordingApp=$4

if [ -z "$needToStartSoundRecordingApp" ]; then
	needToStartSoundRecordingApp="no"
fi 


YesOrNo()
{
	echo "$* (y/n)?"
	read x
	if [ "$x" = "yes" ]; then
		echo yes
	elif [ "$x" = "y" ]; then
		echo yes
	elif [ -n "$x" ]; then
		echo yes
	fi 
}


Record1()
{
	#echo stubbed; return
	
	fn=$1
	speed=$2
		
	shift
	shift
	prompt=$*
	if [ -f "$fn" ]; then
		if [ "$redo" = "noRedo" ]; then
			continue
		fi 
	fi
	record_sound `pwd`/$fn $needToStartSoundRecordingApp yes $speed $prompt
		
	needToStartSoundRecordingApp="no"
}

RemoveFunnyCharacters()
{
	sed -e 's/[^A-Za-z]/_/g' -e 's/_$//' -e 's/^_//'
} 

RecordAll()
{
        (
	cd data
		
	j=1
	while [ 1 ]; do
		soundDir=sounds
		#soundDir=sounds.$$
				
		prompt="$lang.$j =================: `extract_line $j $which.$lang.text.me`"
		phrase=`extract_line $j $which.en.text.me`
		
		
		prefix=$soundDir/$lang.`echo $phrase|RemoveFunnyCharacters`
						
		echo "\"$prompt\""
		echo "================= b-back up, q-quit, Enter-record =========="
		read command
		case "$command" in
			b)
				j=`expr $j - 1`
			;;
			q)
				exit
			;;
			*)
				#Record1 $prefix.slow.wav	SLOW	$prompt 
				Record1 $prefix.normal.wav	NORMAL	$prompt
				#Record1 $prefix.fast.wav	FAST	$prompt
				
				(
				echo "mtab"
				)| sh macro_jam.sh				

				j=`expr $j + 1`
			;;
		esac
	done
        )
}

RecordAll

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/misc/record.sh fr 1 redo no