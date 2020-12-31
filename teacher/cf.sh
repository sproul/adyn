:
what=$1
if [ -z "$what" ]; then
	what=all
fi

DiffCode()
{
        for f in `echo *.pm *.pl *.sh`; do
                s="$BACKUP_DIR/incremental_saves/work/adyn.com/httpdocs/teacher/$f $f"
                if [ -n "`eval diff -b $s`" ]; then
                        echo diff $s
                        eval diff -b $s
                fi
        done
}

Diff()
{
        canDir=$1
        newDir=$2
        prefix=$3
        suffix=$4

        if [ "$prefix" = "-" ]; then
                prefix=""
        fi


        mkdir -p $canDir
        out=$TEMP/cf_sh.dat

        diff -r -b $canDir $newDir|grep -v 'Only in' > $out
        if [ -n "`head.exe -1 $out`" ]; then
                cat $out
                echo "cp $newDir/$prefix*$suffix $canDir"
        else
                echo "cp $newDir/$prefix*$suffix $canDir"
        fi
}

DiffLang()
{
        lang=$1
        Diff can/grammar/$lang html $lang html
}

DiffData()
{
        Diff can/data data '[bhipstvw]'
}

DiffTest()
{
        Diff can/teacher_test_output $TEMP/teacher_test_output - log
}

case $what in
        all)
                DiffLang 'Spanish'
                DiffLang 'French'
                DiffLang 'Italian'
                DiffLang 'German'
                DiffCode
                DiffData
        ;;
        test)
                DiffTest
        ;;
        code)
                DiffCode
        ;;
        Data)
                DiffData
        ;;
        world_except_test)
                DiffData
                DiffLang 'Spanish'
                DiffLang 'French'
                DiffLang 'Italian'
                DiffLang 'German'
        ;;
        *)
                DiffLang $what
        ;;
esac

exit
cd $HOME/work/adyn.com/httpdocs/teacher; sh cf.sh code