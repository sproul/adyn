:
German()
{
        (
        cd data; grep -n German [tph]* vocab* | grep -v _note|sed -e 's/.*=> .//' -e "s/',$//"|grep '[A-Z]'|grep -v "{" > /tmp/out
        )
}

French()
{
        (
        cd data
        grep -n French [tph]* vocab* | grep -v _note|
        sed	\
        -e 's/.*=> .//' 	\
        -e "s/',$//" 	\
        -e 's/ [tsm]on / le /g'	\
        -e 's/ au / le /g'	\
        -e 's/ du / le /g'	\
        -e 's/ ce / le /g'	\
        -e 's/ de / /g'	\
        -e 's/ plus / /g'	\
        -e 's/ moins / /g'	\
        -e 's/ des / /g'	\
        -e 's/ `a / /g'	\
        -e 's/ cette / la /g'	\
        -e 's/ [tsm]a / la /g'	\
        -e 's/ [vn]otre //g'	\
        |grep ' '|grep -v "{" > /tmp/out
        )
}

Spanish()
{
        (
        cd data
        grep -n Spanish [tph]* vocab* | grep -v _note|
        sed	\
        -e 's/.*=> .//' 	\
        -e "s/',$//" 	\
        -e 's/^a //'	\
        -e 's/^su /? /'	\
        -e 's/^mi /? /'	\
        -e 's/^alg.un /? /'	\
        -e 's/^sus /? /'	\
        -e 's/^mis /? /'	\
        -e 's/^nuestro /el /'	\
        -e 's/^al /el /'	\
        -e 's/^nuestra /la /'	\
        -e 's/^nuestras /la /'	\
        -e 's/^nuestro /el /'	\
        -e 's/^nuestros /el /'	\
        -e 's/^alguna /la /'	\
        -e 's/^algunas /la /'	\
        -e 's/^alguno /el /'	\
        -e 's/^algunos /el /'	\
        -e 's/^vuestra /la /'	\
        -e 's/^vuestras /la /'	\
        -e 's/^vuestro /el /'	\
        -e 's/^vuestros /el /'	\
        -e 's/^una /la /'	\
        -e 's/^esta /la /g'	\
        -e 's/^este /el /g'	\
        -e 's/^estas /la /g'	\
        -e 's/^estos /el /g'	\
        -e 's/^esa /la /g'	\
        -e 's/^ese /el /g'	\
        -e 's/^esas /la /g'	\
        -e 's/^esos /el /g'	\
        -e 's/^unas /la /g'	\
        -e 's/^unos /el /g'	\
        -e 's/^las /la /g'	\
        -e '/ m\/as /d'	\
        -e '/^m\/as /d'	\
        -e 's/^los /el /g' |
        grep -v 'que' |grep ' '|grep -v "{" |sort|uniq > /tmp/out
        )
}

Italian()
{
        (
        cd data
        grep -n Italian [tph]* vocab* | grep -v _note|
        sed	\
        -e 's/.*=> .//' 	\
        -e "s/',$//" 	\
        -e 's/^a //'	\
        -e 's/ suo / /'	\
        -e 's/ sue / /'	\
        -e 's/ sua / /'	\
        -e 's/ sui / /'	\
        -e 's/ mio / /'	\
        -e 's/ mie / /'	\
        -e 's/ mia / /'	\
        -e 's/ mii / /'	\
        -e 's/^alla /la /'	\
        -e 's/^alle /la /'	\
        -e 's/^all...D /? /'	\
        -e 's/^della /la /'	\
        -e 's/^delle /la /'	\
        -e 's/^dell...D /? /'	\
        -e 's/^sus /? /'	\
        -e 's/^alcuni /? /'	\
        -e 's/^alcune /? /'	\
        -e 's/^alcuna /la /'	\
        -e 's/^alcuno /il /'	\
        -e 's/^del /il /'	\
        -e 's/^dei /il /'	\
        -e 's/^dei /il /'	\
        -e 's/^d...D /? /'	\
        -e 's/^mis /? /'	\
        -e 's/ nostro / /'	\
        -e 's/^al /il /'	\
        -e 's/ nostra / /'	\
        -e 's/nostras //'	\
        -e 's/nostro //'	\
        -e 's/^los /el /g'	\
        -e 's/nostros //'	\
        -e 's/vostra //'	\
        -e 's/vostras //'	\
        -e 's/vostro //'	\
        -e 's/vostros //'	\
        -e 's/^questa /la /g'	\
        -e 's/^queste /il /g'	\
        -e 's/^questas /la /g'	\
        -e 's/^questos /il /g'	\
        -e 's/^unas /la /g'	\
        -e 's/^unos /il /g'	\
        -e 's/^.* il /il /g'	\
        -e 's/^.* la /la /g'	\
        -e 's/^i /? /g'		\
        -e 's/^gli /il /g'	\
        -e '/^di /d'		\
        -e 's/^in /? /'		\
        -e 's/^l...D /? /'	\
        -e 's/^les /? /g'	\
        -e 's/^un /il /g'	\
        -e 's/^uno /il /g'	\
        -e 's/^une /la /g'	\
        -e 's/^le /la /g'	\
        -e '/^pi`u /d'		\
        -e '/^cue /d'		\
        -e '/^menos /d'		\
        -e 's/^lo /il /g'	|
        grep -v 'que' |grep ' '|grep -v "{" |sort|uniq > /tmp/out
        )
} 

Italian
#Spanish
#French
exit
cd $HOME/work/adyn.com/httpdocs/teacher/;sh -x grep_data_for_all.sh 