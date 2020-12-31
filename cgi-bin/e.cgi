#!c:/cygwin/bin/bash.exe
#!c:/cygwin/bin/perl.exe --

echo "Content-type: text/plain"
echo ""
export HOME=/cygdrive/c/Users/nelsons
export PATH=/bin
. $HOME/.profile
perl -w choose.cgi # 2>&1
echo done
