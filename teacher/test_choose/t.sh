:
InitTestUserTrees()
{
	RmTestUserTrees
	cp -pr usr/* ../usr
}

RmTestUserTrees()
{
	if [ `hostname` != "o4" ]; then
		echo "review this script code: operations are unsafe for the usr tree"
		exit
	fi
	touch  ../usr/test_dummy
	rm -rf ../usr/test_*
}

DiffCanon()
{
	diff -r can output
	echo 'cp -p output/* can'
}


InitTestUserTrees
perl -w test_choose.pl
RmTestUserTrees

DiffCanon
