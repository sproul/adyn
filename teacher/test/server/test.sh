:

Diff()
{
	f1=$1
	f2=$2
	perl -w -p -e 's/(.........................................................................................................................)/$1XX\n/g' < $f1 > $f1.diffable
	perl -w -p -e 's/(.........................................................................................................................)/$1XX\n/g' < $f2 > $f2.diffable
	diff  $f1.diffable $f2.diffable
	rm -f $f1.diffable $f2.diffable
}

Init()
{
	testDir="$HOME/work/adyn.com/httpdocs/teacher/test/server"
	outputDir="$testDir/output"
	inputDir="$testDir/input"
	canDir="$testDir/can"

	mkdir -p $outputDir
	mkdir -p $canDir

        cd $HOME/work/adyn.com/cgi-bin/
}

ListTestCases()
{
        (
        cd $DROP/adyn/httpdocs/teacher/test/server/input/
        ls
        )
}


TestServer()
{
	testName=$1

	inputFn="$inputDir/$testName"
	outputFn="$outputDir/$testName"
	canFn="$canDir/$testName"

	echo "Test case $testName..."

	REMOTE_ADDR="127.0.0.1"
	export REMOTE_ADDR

	(
	cat $inputFn
	echo randomSeed=123456
	) | (perl -w choose.cgi | tail +6) 2> $outputFn.err | tr -d '\15\32' > $outputFn 

	cat $outputFn.err >> $outputFn
	
	if [ -f $canFn ]; then
		if [ -n "`cmp $canFn $outputFn`" ]; then
			echo "	$inputFn"
			echo "	$outputFn"
			Diff $canFn $outputFn
			echo cp -p $outputFn $canFn
		fi
	else
		cp -p $outputFn $canFn
	fi
}

Init
for f in `ListTestCases`; do
	TestServer $f
done

exit 0

