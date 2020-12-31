#!/bin/bash
wget -O - 'http://127.0.0.1:81/cgi-bin/login.cgi?userID=pay&whichPanel=simple_choose.htm' --post-data=pw=xx
exit
bx $DROP/adyn/teacher/bin/teacher.test.login 