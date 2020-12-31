:
rm -f $fn data/out_*
rm -f $fn html/Spanish*.html 
rm -f $fn html/French*.html 
rm -f $fn html/Italian*.html 
rm -f $fn html/German*.html 
rm -f $fn grammar/*.dp

# need to do this to protect choose.html
perl -w tx.pl -genInfrastructure

cd data
rm _*
ls verb_* |
while [ 1 ]; do
	read fn
	if [ -z "$fn" ]; then
		break
	fi
	rm -f ../html/$fn.*.html
done

# I don't just do this from the start because MKS can't handle it -- too many files in dir
rm -f ../html/verb_*.*.html	
rm -f ../html/base*.*.html	
rm -f ../html/*.html

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/clean.sh 