:
cd $HOME/work/adyn.com/httpdocs/teacher/data
grep addendKey ve* |grep 0|grep -v '[0-9]0'|sort|uniq
