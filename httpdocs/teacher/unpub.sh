:

echo 'sorry: i deleted the good one.  you must slowly recreate this guy'
exit

cd $web
chmod +w bin/*

touch tmp.gz tmp.tar
rm *.gz *.tar

tar xvf $HOME/teacher.tar

if [ `ls exercises.*.tar.gz | wc -l` != 7 ]; then
	echo "$0: cannot see all tars: disk quota exceeded?"
	echo Proposed:
	echo spaces
	echo 'rm /home/sites/site200/web/teacher/html/*1*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*2*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*3*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*4*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*5*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*6*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*7*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*8*.html'
	echo 'rm /home/sites/site200/web/teacher/html/*9*.html'
	exit
fi

rm $HOME/teacher.tar
ls -l *.tar.gz

rm /home/sites/site200/web/teacher/data/out* 	# make way!

for f in *.tar.gz; do
	gzip -d $f
	f=`echo $f|sed -e 's/.gz//'`
	ls -l $f
	tar xf $f
	rm $f
done
chmod +x bin/*.cgi
chmod +w bin/*.pm teacher/html/*.js
exit
sh /home/sites/site200/web/teacher/unpub.sh