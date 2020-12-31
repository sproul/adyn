:
which=$1
cd $HOME/work/adyn.com/httpdocs/teacher/html

chmod +w new.js
cat forms.js cookie.js common.js > new.js
chmod -w new.js

chmod +w vt.js
cat forms.js cookie.js common.js vt_common.js > vt.js
chmod -w vt.js

exit
sh -x $HOME/work/adyn.com/httpdocs/teacher/build_common_js.sh 