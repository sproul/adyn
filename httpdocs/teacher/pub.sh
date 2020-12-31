:

pub_out=`pwd`/can/pub.out

Backup()
{
	(
	tar cf backup.tar *.pm *.pl data 
	(
	cd $HOME/work/emacs
	tar cf backup.el.tar lisp
	)
	)
	mv $HOME/work/emacs/backup.el.tar .
}

Prevent()
{
	fn=$1
	pattern=$2
	whereToIfHit=$3
			
	if [ -z "$whereToIfHit" ]; then
		whereToIfHit=$pattern
	fi 
			
	out=`grep $s "$pattern" $fn`
			
	if [ -n "$out" ]; then
		echo "$fn$whereToIfHit"
		exit
	fi
}

CheckForTars()
{
	touch tmp.tar
	touch tmp.tar.gz
	for f in *.tar *.gz; do
		if [ $f != "tmp.tar" ]; then
			if [ $f != "tmp.tar.gz" ]; then
				echo "$0 found a tar file already.  I need a clear field for my work..."
				hits=`echo *.tar *.gz | sed -e 's/tmp.tar.gz//g' -e 's/tmp.tar//g'`
				echo "cd `pwd`;rm $hits"
				exit
			fi
		fi
	done
	rm -f tmp.tar*
}

GetLangs()
{
	ls `pwd`/teacher/grammar/*.dat.htm | sed -e 's;.*grammar/;;' -e 's/.dat.htm//'
}

VerifyNoDebugNonsenseInMyFiles()
{
	j=teacher/html/teacher.java
	Prevent $j 'boolean m_debugMode = true'
	Prevent $j 'boolean m_verboseMode = true'
	Prevent $j 'm_userID = NSPROUL'

	Prevent bin/choose.cgi "__debugMode = 1;"
	Prevent teacher/html/choose.html "//document.teacher_form.submit"
	Prevent teacher/html/common.js "//window.location='unsupported_browser.htm'"
	Prevent teacher/html/simple_choose.htm "//document.teacher_form.submit"

	cd teacher/html
	rm *.class ;make build
}

CopyPrivatePerlToPublicBin()
{
	fn=$1
	cp -pf $HOME/work/bin/perl/$fn ../bin
	chmod -w ../bin/$fn
}

GatherEnvDependencies()
{
	cp -pf $HOME/work/include/GetStack.* teacher/html
	chmod -w teacher/html/GetStack.*

	# now they live there
	#CopyPrivatePerlToPublicBin nutil.pm
	#CopyPrivatePerlToPublicBin nobj.pm
	#CopyPrivatePerlToPublicBin filer.pm
	#CopyPrivatePerlToPublicBin Ndmp.pm
}

cd ..
CheckForTars
GatherEnvDependencies
VerifyNoDebugNonsenseInMyFiles
langs=`GetLangs`

rm -f $pub_out
for lang in $langs; do
	tar cf $lang.tar teacher/html/$lang*html
done >> $pub_out

#sh c:/users/nsproul/work/bin/perl_pc2unix.sh

cp -p teacher/html/English.htm teacher/html/English.html
tar cf misc.tar teacher/*.jpg teacher/html/choose.html teacher/html/English.html bin/*.cgi teacher/html/*.class teacher/html/*.js bin/*.pm teacher/starters_for_generated_files teacher/*.html teacher/html/*.htm teacher/usr teacher/test_* bin/adynware teacher/data/cgi_* `ls teacher/data/out_*|grep -v '_.*_'` >> $pub_out

#sh c:/users/nsproul/work/bin/perl_pc2unix.sh not

Backup

for n in abc defgh ijklm nop qrs tu vwxyz; do
	tar cf exercises.$n.tar teacher/data/out_*_[${n}]*
done >> $pub_out

for f in *.tar; do
	gzip -f $f
done

ls -l *.gz
tar cf teacher.tar *.gz
ls -l *.tar
sh $HOME/work/bin/ftp.cp adyn.com binary . teacher.tar



mkdir -p d:/old
mv *.tar.gz *.tar d:/old

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/pub.sh &
