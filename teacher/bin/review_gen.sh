#!/bin/bash
area=$1
cd $DROP/adyn/teacher/
. bin/teacher.env
perl -w tx.pl -MakeReview -genPath $area
exit
bx $DROP/adyn/teacher/bin/review_gen.sh  verb_know