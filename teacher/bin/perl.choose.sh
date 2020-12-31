:

Choose_by_url()
{
        url="$1"
        export PERL5LIB=/cygdrive/c/Users/nelsons/Dropbox/adyn/cgi-bin:/lib/perl5/site_perl/5.8/libwww-perl-5.805/lib:/lib:/cygdrive/c/Users/nelsons/Dropbox/bin/perl
        cd $DROP/adyn/cgi-bin
        export REMOTE_ADDR=127.0.0.1
        parms=`echo $url | sed -e 's/.*?//'`
        while [ 1 ]; do
                parm1=`echo $parms | sed -e 's/&.*//'`
                parms=`echo $parms | sed -e 's/^[^&]*&//'`
                echo $parm1
                if [ "$parm1" = "$parms" ]; then
                        break
                fi
        done | perl -w ./choose.cgi -test
}

url="$1"
Choose_by_url "$url"

exit
bx $DROP/adyn/teacher/bin/perl.choose.sh 'http://127.0.0.1:81/cgi-bin/choose.cgi?whichPanel=choose.htm&exerciseSetTargetSize=20&promptLang=Spanish&lang_French=French&lang_German=German&lang_Italian=Italian&lang_Spanish=Spanish&exerciseType=verb_common&reviewPercentage=50&tense=present&userID=t3&pw=x'
exit
bx $DROP/adyn/teacher/bin/perl.choose.sh 'http://g0:81/cgi-bin/choose.cgi?session_id=asIzdPpcVqc4g&whichPanel=choose.htm&promptLang=Spanish&exerciseSetTargetSize=4&lang_Spanish=Spanish&exerciseType=verb_common&reviewPercentage=50&tense=present&userID=t3&pw=x'