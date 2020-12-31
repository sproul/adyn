:
lang=$1

Lang()
{
	lang=$1
	perl -w dump_one_lang.pl $lang base 0                          |grep '^base' >> base.new
	#perl -w dump_one_lang.pl $lang base 0 d:/old/teacher/data/base|grep '^base' >> base.old
}

#rm -f base.old
rm -f base.new 

#Lang English
Lang French
Lang German
Lang Italian
Lang Spanish

exit
cd $HOME/work/adyn.com/httpdocs/teacher; sh -x dump_bases.sh 
