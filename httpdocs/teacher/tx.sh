#!/bin/sh
# sshe NSPROUL-US $DROP/bin/mid $DROP/adyn/teacher/tx.sh
# o88:
# TIME: 07.24: start
# TIME: 07.24: post init
# TIME: 07.24: post xlate
# TIME: 07.24: fixups+
# TIME: 07.24: pre link
# TIME: 07.24: post link
# TIME: 07.24: post rvw
# TIME: 07.26: post es
# TIME: 07.26: post fr
# TIME: 07.27: post it
# TIME: 07.28: post langs
# TIME: 07.32: post massage
# TIME: 07.32: post save
# TIME: 08.24: post html gen
# TIME: 08.24: post save
# TIME: 08.25: post infra
# TIME: 08.25: post propose
# TIME: 08.25: end
#

date
cd $DROP/adyn/teacher
. bin/teacher.env

# no deletion til we straighten out how to recreate *_vt_*.html
#rm -rf $DROP/adyn/httpdocs/teacher/html
rm -rf $DROP/adyn/httpdocs/teacher/data

rm -rf /cygdrive/c/Users/nelsons/Dropbox/teacher/grammar/gen
chmod -w /cygdrive/c/Users/nelsons/Dropbox/teacher/grammar

rm -rf $DROP/adyn/httpdocs/teacher/data/out* 2> /dev/null
rm -rf $DROP/adyn/teacher/data/out*               2> /dev/null

mkdir $TMP/sql # to avoid crash in  n_db_sql_load.pm:30 .GetFile

t=$TMP/tx.sh.$$
# -lang all        -- generates French.html, etc.
# -grammar         -- generates verb tables *_vt_*.html
# -genAll          -- generates out_*
# -genInfrastructure -- generates cgi_* categorization data

#touch $DROP/adyn/teacher/data/things_to_know; perl -w tx.pl -genExercises -lang German -grammar -verb_a know

assert.no_match $DROP/adyn/teacher/data/out_verb_speak
assert.no_match $DROP/adyn/teacher/html/French_vt_parler.html

# trying to relink, InsertAddend where appropriate, so adding -relinkAll
touch $DROP/adyn/teacher/data/places_to_swim
perl -w tx.pl -genInfrastructure -genAll -genExercises -grammar -lang all -relinkAll > $t 2>&1

ls -l /cygdrive/c/Users/nelsons/Dropbox/teacher/data/out_base

echo OUTPUT in $t
echo TAILING OUTPUT in $t
tail -500 $t

mkdir -p $DROP/adyn/httpdocs/teacher/data
mkdir -p $DROP/adyn/httpdocs/teacher/html/gen
cp -p $DROP/adyn/teacher/data/* $DROP/adyn/cgi-bin/data
cp -p $DROP/adyn/teacher/*.html $DROP/adyn/httpdocs/teacher

mv $DROP/adyn/teacher/html/*_vt_*.html $DROP/adyn/httpdocs/teacher/html
cp -pr $DROP/adyn/teacher/html/*.html  $DROP/adyn/httpdocs/teacher/html

$DROP/adyn/teacher/bin/teacher.test

date
echo done, test at http://127.0.0.1:81/teacher/html/login.htm
exit
bx $DROP/adyn/teacher/tx.sh 