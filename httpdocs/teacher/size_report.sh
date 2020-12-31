:
cwd=`pwd`
if [ `dirname $cwd` != "teacher" ]; then
        echo 'am I in the right dir?'
        exit
fi

MeasureJavaSize()
{
	cd html
	js=`wc -c *.class | grep total | sed -e 's/[ 	]*total//' -e 's/[0-9][0-9][0-9]$/kb/'`
	cd ..
}

ReportSourceSize()
{
	echo "$1 source lines:	$2 lines"
}

Wc-l()
{
	wc -l $*|grep total|sed -e 's/ total$//'
}

MeasureSourceSize()
{
	ReportSourceSize Java `Wc-l html/*.java`
	ReportSourceSize JavaScript `Wc-l html/*.js`
	ReportSourceSize perl `Wc-l *.pm *.pl`
	ReportSourceSize 'perl data' `Wc-l data/*`
}


MeasureVocabulary()
{
	cd data
	vs=`grep English ???* | grep -v / | grep '=>' | perl ../vocab_filter_for_size_report.pl | sort | uniq | wc -l | sed -e 's/^[ 	]*//'`
	cd ..
}

CountNotes()
{
	cd data
	noteCnt=`grep _note * | wc -l | sed -e 's/[ 	]//g'`
	cd ..
}

MeasureSize()
{
	cd html
	total=`du|sed -e 's/ *//g' -e 's/.$//'`
	total=`expr $total \* 512`		# instead of 512-byte blocks
	
	exCnt=`ls| grep '.html$' |wc -l`
	echo "Java $js; vocabulary $vs; `expr $total / 1000000`MB/$exCnt: `expr $total / $exCnt` bytes/exercise; `expr $noteCnt / $exCnt` notes/exercise"
	cd ..	
}

MeasureJavaSize
MeasureVocabulary
CountNotes
MeasureSize
MeasureSourceSize

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/size_report.sh 