:
old=$BACKUP_DIR/teacher_data	# $HOME/work/bin/get_new, find_new_data_init.sh also work with this directory
mkdir -p $old

cd $HOME/work/adyn.com/httpdocs/teacher

newBaseScript=$tmp/.new_base_teacher_data_update.sh	# $HOME/work/bin/get_new also works with this file
if [ ! -f $newBaseScript ]; then
        echo ':' > $newBaseScript
        echo "cd $HOME/work/adyn.com/httpdocs/teacher/data" >> $newBaseScript
fi


Hit()
{
        f=$1
        echo "`pwd`/$f"
        echo "cp $f $old/$f" >> $newBaseScript
}


if [ ! -d $BACKUP_DIR/teacher_data ]; then
        cp -pr data $BACKUP_DIR/teacher_data
else
        cd data
        for f in `ls *|sed -e '/^_/d' -e '/^out/d'`; do
                if [ -f $old/$f ]; then
                        if [ -n "`cmp $f $old/$f`" ]; then
                                Hit $f
                        fi
                else
                        Hit $f
                fi
        done | sed -e 's;^[a-zA-Z]:/;;'
fi
exit
sh $HOME/work/adyn.com/httpdocs/teacher/find_new_data.sh 